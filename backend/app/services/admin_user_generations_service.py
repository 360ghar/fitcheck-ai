"""Admin per-user sub-resource reads: generations explorer, billing, referrals, body profile.

Read-only companions to ``admin_service.get_user_detail``. Routes stay thin in
``app/api/v1/admin/users.py``; all DB access goes through
``execute_with_reconnect`` and every section degrades to an empty result
instead of failing the whole read (same contract as the 360 helpers in
``admin_service``).

Two invariants the whole module enforces:

1. **No base64 ever leaves the server.** ``extraction_jobs.items`` keeps
   ``generated_image_base64`` values until job TTL and
   ``photoshoot_jobs.generated_images`` may too; ``_strip_base64`` removes
   every ``*_base64`` key before anything is returned.
2. **URLs are re-minted at read time.** Image columns hold durable storage
   keys plus short-lived URLs (see ``app/core/storage_keys``); admin surfaces
   must behave like the app read paths and never serve a stored URL that may
   be expired. ``_fresh_url`` derives the key via ``key_from_path``, gates on
   ``parse_key`` (so external CDN URLs — e.g. social-import thumbnails — are
   passed through untouched, never reshaped into garbage keys) and presigns a
   fresh URL via ``StorageService.get_public_url``. Objects that are gone
   (expired ``tmp/`` photoshoot images) fall back to the stored URL so the UI
   can render its own "unavailable" placeholder with the raw key.

Pagination contract for ``kind="all"``: each kind contributes its most recent
rows (``min(page * page_size, _ALL_KIND_WINDOW)`` per kind), merged and sorted
by ``created_at`` desc, then sliced. ``total`` is the sum of exact per-kind
counts CAPPED to the reachable recent window (``_ALL_KIND_WINDOW`` rows per
kind) so navigation never reaches empty pages beyond the merged set. "All" is
therefore a recent-activity view, not a deep archive — the per-kind tabs page
exactly.
"""

from __future__ import annotations

import asyncio
import logging
from datetime import datetime, timezone
from typing import Any, Callable, Dict, List, Optional, Tuple

from app.core.config import settings
from app.core.exceptions import NotFoundError, ValidationError
from app.core.storage_keys import key_from_path, parse_key
from app.services.admin_service import _iap_item, _page_range, plan_display_amount
from app.services.storage_service import StorageService
from app.utils.datetime_util import parse_utc_datetime
from app.utils.db import execute_with_reconnect, maybe_single_data

logger = logging.getLogger(__name__)

# Explorer kinds (the route segment vocabulary; ``all`` is list-only).
GEN_KINDS = ("item", "outfit", "outfit_render", "photoshoot", "social_import")

# kind -> counts key surfaced in the page payload (and mirrored into the user
# detail payload's ``counts``).
COUNT_KEYS: Dict[str, str] = {
    "item": "item_generations",
    "outfit": "outfits",
    "outfit_render": "outfit_renders",
    "photoshoot": "photoshoot_jobs",
    "social_import": "social_import_jobs",
}

# Per-kind window for the merged "all" view (rows fetched per kind per page).
_ALL_KIND_WINDOW = 50
# Media caps — the viewer pages nothing; generated sets are bounded jobs.
_MEDIA_CAP = 60
_SOURCE_CAP = 3
_IMPORT_PHOTO_CAP = 12


def _swallow(operation: str, exc: BaseException) -> None:
    """Best-effort sections degrade instead of failing the read — loudly."""
    logger.warning(
        "admin user sub-resource query failed; returning empty",
        extra={"operation": operation},
        exc_info=exc,
    )


def _strip_base64(value: Any) -> Any:
    """Recursively drop every ``*_base64`` key from parsed JSONB payloads."""
    if isinstance(value, dict):
        return {
            key: _strip_base64(item)
            for key, item in value.items()
            if not (isinstance(key, str) and key.endswith("_base64"))
        }
    if isinstance(value, list):
        return [_strip_base64(item) for item in value]
    return value


def _iso(value: Any) -> Optional[str]:
    return str(value) if value else None


def _duration_ms(created_at: Any, completed_at: Any) -> Optional[int]:
    started = parse_utc_datetime(created_at)
    finished = parse_utc_datetime(completed_at)
    if not started or not finished:
        return None
    delta = (finished - started).total_seconds() * 1000
    return int(delta) if delta >= 0 else None


async def _fresh_url(stored: Any, *, user_id: str, operation: str) -> Optional[str]:
    """Re-mint a presigned URL for a stored key/URL; pass through foreign URLs.

    ``key_from_path`` alone is not a safe gate: an unrelated relative string
    would flow through as a garbage key and presign a URL that 404s. The
    ``parse_key`` check keeps re-minting limited to keys the storage grammar
    actually recognizes (canonical/thumb/preview/export/public). Keys owned by
    a DIFFERENT user (copied URLs, shared references) pass through unminted:
    the admin view must not mint presigned URLs for another user's objects.
    """
    if not isinstance(stored, str) or not stored:
        return None
    key = key_from_path(stored)
    parsed = parse_key(key) if key else None
    if not key or parsed is None:
        return stored
    if parsed.user and parsed.user != user_id:
        return stored
    try:
        return await StorageService.get_public_url(key)
    except Exception as exc:  # object gone / backend down — keep the stored URL
        _swallow(f"{operation}.materialize", exc)
        return stored


def _url_from_entry(entry: Any) -> Optional[str]:
    """Pull the most durable reference out of one parsed image entry."""
    if isinstance(entry, str):
        return entry or None
    if isinstance(entry, dict):
        return (
            entry.get("storage_path")
            or entry.get("generated_image_storage_path")
            or entry.get("image_url")
            or entry.get("generated_image_url")
            or entry.get("url")
            or entry.get("source_photo_url")
        )
    return None


# Public alias: ``admin_service`` re-mints item/outfit image URLs for the 360
# detail payload too (deferred import — this module imports shared helpers
# from ``admin_service``, so the edge must stay function-local there).
fresh_image_url = _fresh_url


# ---------------------------------------------------------------------------
# Row -> normalized generation mapping (one shape for every kind)
# ---------------------------------------------------------------------------


def _generation(
    *,
    kind: str,
    row: Dict[str, Any],
    title: Optional[str],
    subtitle: Optional[str],
    media: List[Dict[str, Any]],
    media_count: int,
    failed_count: int,
) -> Dict[str, Any]:
    created_at = row.get("created_at")
    completed_at = row.get("completed_at")
    status = row.get("status")
    return {
        "kind": kind,
        "id": str(row.get("id") or ""),
        "status": _iso(status),
        "created_at": _iso(created_at),
        "completed_at": _iso(completed_at),
        "duration_ms": _duration_ms(created_at, completed_at),
        "title": title or "",
        "subtitle": subtitle,
        "media": media,
        "media_count": media_count if media_count is not None else len(media),
        "failed_count": failed_count or 0,
        "error": _iso(row.get("error_message") or row.get("error")),
        "meta": {},
        "source": {"table": _SOURCE_TABLES[kind], "id": str(row.get("id") or "")},
    }


_SOURCE_TABLES: Dict[str, str] = {
    "item": "extraction_jobs",
    "outfit": "outfits",
    "outfit_render": "outfit_generations",
    "photoshoot": "photoshoot_jobs",
    "social_import": "social_import_jobs",
}


async def _media_from_image_rows(
    rows: Any,
    *,
    user_id: str,
    operation: str,
    label_fn: Optional[Callable[[Dict[str, Any]], Optional[str]]] = None,
) -> List[Dict[str, Any]]:
    """Materialize ``item_images``/``outfit_images`` style rows into media."""
    media: List[Dict[str, Any]] = []
    for row in rows or []:
        if not isinstance(row, dict):
            continue
        url = await _fresh_url(
            row.get("storage_path") or row.get("image_url"),
            user_id=user_id,
            operation=operation,
        )
        if not url:
            continue
        thumb = row.get("thumbnail_url")
        thumb_url = await _fresh_url(thumb, user_id=user_id, operation=operation) if thumb else None
        label = label_fn(row) if label_fn else None
        media.append({"url": url, "thumb_url": thumb_url or url, "label": label})
    return media


async def _media_from_urls(
    entries: Any,
    *,
    user_id: str,
    operation: str,
    label_fn: Optional[Callable[[Any, int], Optional[str]]] = None,
) -> List[Dict[str, Any]]:
    """Materialize a JSONB list of URLs (or url-bearing dicts) into media."""
    media: List[Dict[str, Any]] = []
    for index, entry in enumerate((entries or [])[:_MEDIA_CAP]):
        url = await _fresh_url(_url_from_entry(entry), user_id=user_id, operation=operation)
        if not url:
            continue
        media.append(
            {"url": url, "thumb_url": url, "label": label_fn(entry, index) if label_fn else None}
        )
    return media


# ---------------------------------------------------------------------------
# Per-kind fetchers: (paged rows, exact total). Each swallows its own errors.
# ---------------------------------------------------------------------------


async def _paged(
    db: Any,
    *,
    table: str,
    columns: str,
    user_id: str,
    operation: str,
    page: int,
    page_size: int,
    status: Optional[str],
    extra_filters: Optional[Callable[[Any], Any]] = None,
    supports_status: bool = True,
) -> Tuple[List[Dict[str, Any]], int]:
    """Exact pagination for one kind: head-count query + paged page query."""
    if status and not supports_status:
        # The kind has no status column (saved outfits are timeless
        # entities) — it matches no status predicate. Return empty without
        # querying so the DB never sees a bogus ``status`` filter.
        return [], 0

    def _count_builder(d: Any) -> Any:
        query = d.table(table).select("id", count="exact").eq("user_id", user_id)
        if status:
            query = query.eq("status", status)
        if extra_filters is not None:
            query = extra_filters(query)
        return query

    try:
        count_result = await execute_with_reconnect(
            lambda d: _count_builder(d).execute(),
            db,
            extra={"operation": f"{operation}.count", "user_id": user_id},
        )
        total = getattr(count_result, "count", 0) or 0
    except Exception as exc:
        _swallow(f"{operation}.count", exc)
        return [], 0

    offset, end = _page_range(page, page_size)

    def _page_builder(d: Any) -> Any:
        query = d.table(table).select(columns).eq("user_id", user_id)
        if status:
            query = query.eq("status", status)
        if extra_filters is not None:
            query = extra_filters(query)
        return query.order("created_at", desc=True).range(offset, end)

    try:
        page_result = await execute_with_reconnect(
            lambda d: _page_builder(d).execute(),
            db,
            extra={"operation": f"{operation}.page", "user_id": user_id},
        )
        return [dict(row) for row in (page_result.data or [])], total
    except Exception as exc:
        _swallow(f"{operation}.page", exc)
        return [], total


async def _count_kind(
    db: Any,
    *,
    table: str,
    user_id: str,
    operation: str,
    status: Optional[str] = None,
    supports_status: bool = True,
) -> int:
    if status and not supports_status:
        return 0

    def _builder(d: Any) -> Any:
        query = d.table(table).select("id", count="exact").eq("user_id", user_id)
        if status:
            query = query.eq("status", status)
        return query

    try:
        result = await execute_with_reconnect(
            lambda d: _builder(d).execute(),
            db,
            extra={"operation": operation, "user_id": user_id},
        )
        return getattr(result, "count", 0) or 0
    except Exception as exc:
        _swallow(operation, exc)
        return 0


# -- items (extraction runs) -------------------------------------------------

_ITEM_COLUMNS = (
    "id,status,job_type,total_images,total_items,extractions_completed,"
    "extractions_failed,generations_completed,generations_failed,auto_generate,"
    "error_message,created_at,completed_at,items,images"
)


async def _normalize_item_job(row: Dict[str, Any], *, user_id: str) -> Dict[str, Any]:
    operation = "admin.user_generations.item"
    raw_items = row.get("items")
    items = _strip_base64(raw_items) if isinstance(raw_items, list) else []
    # Re-mint EVERY item URL for metadata (not just the media window): meta
    # entries past _MEDIA_CAP must not serve expired stored URLs.
    fresh_by_index: Dict[int, Optional[str]] = {}
    for index, extracted in enumerate(items):
        if not isinstance(extracted, dict):
            continue
        fresh_by_index[index] = await _fresh_url(
            extracted.get("generated_image_storage_path") or extracted.get("generated_image_url"),
            user_id=user_id,
            operation=operation,
        )
    media: List[Dict[str, Any]] = []
    for index, extracted in enumerate(items[:_MEDIA_CAP]):
        if not isinstance(extracted, dict):
            continue
        url = fresh_by_index.get(index)
        if not url:
            continue
        media.append(
            {
                "url": url,
                "thumb_url": url,
                "label": extracted.get("name") or extracted.get("category"),
            }
        )

    # Source photos the items were extracted from (job-level `images` JSONB).
    sources: List[Dict[str, Any]] = []
    for entry in (row.get("images") or [])[:_SOURCE_CAP]:
        url = await _fresh_url(
            _url_from_entry(entry), user_id=user_id, operation=f"{operation}.source"
        )
        if url:
            sources.append({"url": url, "thumb_url": url, "label": "source"})
    media.extend(sources)

    generations_completed = row.get("generations_completed") or 0
    total_items = row.get("total_items") or len(items)
    generation = _generation(
        kind="item",
        row=row,
        title=_iso(row.get("job_type")) or "extraction",
        subtitle=f"{generations_completed}/{total_items}",
        media=media,
        media_count=int(total_items or 0) + len(sources),
        failed_count=(row.get("generations_failed") or 0) + (row.get("extractions_failed") or 0),
    )
    generation["meta"] = {
        "job_type": _iso(row.get("job_type")),
        "total_images": row.get("total_images"),
        "total_items": total_items,
        "extractions_completed": row.get("extractions_completed"),
        "extractions_failed": row.get("extractions_failed"),
        "generations_completed": generations_completed,
        "generations_failed": row.get("generations_failed"),
        "auto_generate": row.get("auto_generate"),
        "source_images": [entry["url"] for entry in sources],
        "items": [
            {
                "name": item.get("name"),
                "category": item.get("category"),
                "image_url": fresh_by_index.get(index),
            }
            for index, item in enumerate(items)
            if isinstance(item, dict)
        ],
    }
    return generation


# -- saved outfits ------------------------------------------------------------

_OUTFIT_COLUMNS = (
    "id,name,description,style,season,occasion,item_ids,is_favorite,worn_count,"
    "created_at,updated_at,outfit_images(image_url,thumbnail_url,storage_path,"
    "pose,lighting,generation_type,is_primary,created_at)"
)


async def _normalize_outfit(row: Dict[str, Any], *, user_id: str) -> Dict[str, Any]:
    operation = "admin.user_generations.outfit"
    images = row.pop("outfit_images", None)

    def _label(image: Dict[str, Any]) -> Optional[str]:
        parts = [image.get("pose"), image.get("generation_type")]
        return " · ".join(str(part) for part in parts if part) or None

    media = await _media_from_image_rows(
        images if isinstance(images, list) else [],
        user_id=user_id,
        operation=operation,
        label_fn=_label,
    )
    item_ids = row.get("item_ids") or []
    generation = _generation(
        kind="outfit",
        row=row,
        title=_iso(row.get("name")),
        subtitle=f"{len(item_ids)} items" if item_ids else None,
        media=media,
        media_count=len(media),
        failed_count=0,
    )
    generation["meta"] = {
        "description": _iso(row.get("description")),
        "style": _iso(row.get("style")),
        "season": _iso(row.get("season")),
        "occasion": _iso(row.get("occasion")),
        "is_favorite": row.get("is_favorite"),
        "worn_count": row.get("worn_count"),
        "item_count": len(item_ids) if isinstance(item_ids, list) else None,
    }
    return generation


# -- outfit render runs --------------------------------------------------------

_RENDER_COLUMNS = (
    "id,outfit_id,status,progress,pose,lighting,variations,image_urls,error,"
    "created_at,started_at,completed_at"
)


async def _normalize_outfit_render(
    row: Dict[str, Any], *, user_id: str, outfit_names: Optional[Dict[str, str]] = None
) -> Dict[str, Any]:
    operation = "admin.user_generations.outfit_render"
    media = await _media_from_urls(
        row.get("image_urls"),
        user_id=user_id,
        operation=operation,
        label_fn=lambda _entry, index: f"render {index + 1}",
    )
    outfit_id = str(row.get("outfit_id") or "")
    name = (outfit_names or {}).get(outfit_id)
    generation = _generation(
        kind="outfit_render",
        row=row,
        title=name or outfit_id,
        subtitle=f"variations {row.get('variations') or 1}",
        media=media,
        media_count=len(media),
        failed_count=0,
    )
    generation["meta"] = {
        "outfit_id": outfit_id,
        "outfit_name": name,
        "progress": row.get("progress"),
        "pose": _iso(row.get("pose")),
        "lighting": _iso(row.get("lighting")),
        "variations": row.get("variations"),
    }
    return generation


# -- photoshoot jobs -----------------------------------------------------------

_PHOTOSHOOT_COLUMNS = (
    "id,status,use_case,custom_prompt,num_images,batch_size,aspect_ratio,"
    "total_batches,current_batch,generated_images,failed_indices,reference_photo_count,"
    "error_message,created_at,completed_at"
)
_PHOTOSHOOT_COLUMNS_EXTENDED = _PHOTOSHOOT_COLUMNS + ",image_failures"


async def _fetch_photoshoot_rows(
    db: Any,
    user_id: str,
    *,
    page: int,
    page_size: int,
    status: Optional[str],
) -> Tuple[List[Dict[str, Any]], int]:
    """photoshoot_jobs with the 035 ``image_failures`` column, falling back."""
    rows, total = await _paged(
        db,
        table="photoshoot_jobs",
        columns=_PHOTOSHOOT_COLUMNS_EXTENDED,
        user_id=user_id,
        operation="admin.user_generations.photoshoot",
        page=page,
        page_size=page_size,
        status=status,
    )
    if rows:
        return rows, total
    # image_failures absent (migration 035 not applied) OR genuinely empty —
    # retry once without the column so a schema gap never blanks the section.
    try:
        def _probe(d: Any) -> Any:
            return (
                d.table("photoshoot_jobs")
                .select("image_failures", count="exact")
                .eq("user_id", user_id)
                .execute()
            )

        probe = await execute_with_reconnect(
            _probe,
            db,
            extra={"operation": "admin.user_generations.photoshoot.probe", "user_id": user_id},
        )
    except Exception as exc:
        # The extended column select itself failed (035 not applied) — rerun
        # the page without it instead of leaving the section blank.
        _swallow("admin.user_generations.photoshoot.probe", exc)
        return await _paged(
            db,
            table="photoshoot_jobs",
            columns=_PHOTOSHOOT_COLUMNS,
            user_id=user_id,
            operation="admin.user_generations.photoshoot.fallback",
            page=page,
            page_size=page_size,
            status=status,
        )
    if getattr(probe, "count", 0):
        return rows, total
    return await _paged(
        db,
        table="photoshoot_jobs",
        columns=_PHOTOSHOOT_COLUMNS,
        user_id=user_id,
        operation="admin.user_generations.photoshoot.fallback",
        page=page,
        page_size=page_size,
        status=status,
    )


async def _fetch_photoshoot_row(
    db: Any, user_id: str, generation_id: str
) -> Optional[Dict[str, Any]]:
    """One photoshoot job by id, ownership-guarded.

    The detail view must reach jobs of any age — unlike the list path it
    cannot page a recent window and hope the id is inside. Same 035
    ``image_failures`` fallback as the list path: a missing column raises,
    a missing row returns None (no fallback query needed).
    """
    for columns in (_PHOTOSHOOT_COLUMNS_EXTENDED, _PHOTOSHOOT_COLUMNS):
        try:
            result = await execute_with_reconnect(
                lambda d: d.table("photoshoot_jobs")
                .select(columns)
                .eq("id", generation_id)
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "admin.user_generations.photoshoot.detail", "user_id": user_id},
            )
            return maybe_single_data(result)
        except Exception as exc:
            _swallow("admin.user_generations.photoshoot.detail", exc)
            continue
    return None


async def _normalize_photoshoot(row: Dict[str, Any], *, user_id: str) -> Dict[str, Any]:
    operation = "admin.user_generations.photoshoot"
    generated = _strip_base64(row.get("generated_images"))
    media = await _media_from_urls(
        generated if isinstance(generated, list) else [],
        user_id=user_id,
        operation=operation,
        label_fn=lambda entry, _index: (
            f"#{entry.get('index')}"
            if isinstance(entry, dict) and entry.get("index") is not None
            else None
        ),
    )
    failed_indices = row.get("failed_indices") or []
    raw_failures = row.get("image_failures") or []
    image_failures = _strip_base64(raw_failures) if isinstance(raw_failures, list) else []
    # failed_indices + image_failures are two views of the same failures;
    # dedupe on index so an image present in both counts once.
    failed_index_keys = {
        str(index)
        for index in (failed_indices if isinstance(failed_indices, list) else [])
    }
    failed_index_keys.update(
        str(detail.get("index"))
        for detail in (image_failures if isinstance(image_failures, list) else [])
        if isinstance(detail, dict) and detail.get("index") is not None
    )
    generation = _generation(
        kind="photoshoot",
        row=row,
        title=_iso(row.get("use_case")) or "photoshoot",
        subtitle=f"{len(media)}/{row.get('num_images') or '?'} images",
        media=media,
        media_count=row.get("num_images") or len(media),
        failed_count=len(failed_index_keys),
    )
    generation["meta"] = {
        "use_case": _iso(row.get("use_case")),
        "custom_prompt": _iso(row.get("custom_prompt")),
        "aspect_ratio": _iso(row.get("aspect_ratio")),
        "num_images": row.get("num_images"),
        "batch_size": row.get("batch_size"),
        "total_batches": row.get("total_batches"),
        "current_batch": row.get("current_batch"),
        "reference_photo_count": row.get("reference_photo_count"),
        "failed_indices": failed_indices if isinstance(failed_indices, list) else [],
        "image_failures": image_failures if isinstance(image_failures, list) else [],
    }
    return generation


# -- social imports -------------------------------------------------------------

_IMPORT_COLUMNS = (
    "id,platform,source_url,status,total_photos,discovered_photos,processed_photos,"
    "approved_photos,rejected_photos,failed_photos,auth_required,error_message,"
    "created_at,completed_at"
)
_IMPORT_PHOTO_COLUMNS = (
    "id,ordinal,status,source_photo_url,source_thumb_url,reviewed_at"
)


async def _fetch_import_photos(db: Any, user_id: str, job_id: str) -> List[Dict[str, Any]]:
    try:
        result = await execute_with_reconnect(
            lambda d: d.table("social_import_photos")
            .select(_IMPORT_PHOTO_COLUMNS)
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .order("ordinal")
            .limit(_IMPORT_PHOTO_CAP)
            .execute(),
            db,
            extra={"operation": "admin.user_generations.social_import.photos", "user_id": user_id},
        )
        return [dict(row) for row in (result.data or [])]
    except Exception as exc:
        _swallow("admin.user_generations.social_import.photos", exc)
        return []


async def _normalize_social_import(
    db: Any, row: Dict[str, Any], *, user_id: str, photos: Optional[List[Dict[str, Any]]] = None
) -> Dict[str, Any]:
    operation = "admin.user_generations.social_import"
    photos = photos if photos is not None else await _fetch_import_photos(db, user_id, str(row.get("id") or ""))
    media: List[Dict[str, Any]] = []
    normalized_photos: List[Dict[str, Any]] = []
    for photo in photos:
        thumb = photo.get("source_thumb_url") or photo.get("source_photo_url")
        url = await _fresh_url(thumb, user_id=user_id, operation=operation)
        if not url:
            continue
        media.append({"url": url, "thumb_url": url, "label": f"#{photo.get('ordinal')}"})
        normalized_photos.append(
            {
                "id": str(photo.get("id") or ""),
                "ordinal": photo.get("ordinal"),
                "status": _iso(photo.get("status")),
            }
        )
    failed = row.get("failed_photos") or 0
    generation = _generation(
        kind="social_import",
        row=row,
        title=_iso(row.get("platform")) or "import",
        subtitle=_iso(row.get("source_url")),
        media=media,
        media_count=row.get("total_photos") or len(media),
        failed_count=failed,
    )
    generation["meta"] = {
        "platform": _iso(row.get("platform")),
        "source_url": _iso(row.get("source_url")),
        "auth_required": row.get("auth_required"),
        "total_photos": row.get("total_photos"),
        "discovered_photos": row.get("discovered_photos"),
        "processed_photos": row.get("processed_photos"),
        "approved_photos": row.get("approved_photos"),
        "rejected_photos": row.get("rejected_photos"),
        "failed_photos": failed,
        "photos": normalized_photos,
    }
    return generation


# ---------------------------------------------------------------------------
# Public API: list + get
# ---------------------------------------------------------------------------

_FETCHERS: Dict[str, Tuple[str, str]] = {
    # kind -> (table, operation)
    "item": ("extraction_jobs", "admin.user_generations.item"),
    "outfit": ("outfits", "admin.user_generations.outfit"),
    "outfit_render": ("outfit_generations", "admin.user_generations.outfit_render"),
    "photoshoot": ("photoshoot_jobs", "admin.user_generations.photoshoot"),
    "social_import": ("social_import_jobs", "admin.user_generations.social_import"),
}


async def _normalize_rows(
    db: Any, kind: str, rows: List[Dict[str, Any]], *, user_id: str
) -> List[Dict[str, Any]]:
    """Map raw rows of one kind to normalized generations.

    Rows normalize sequentially (presigning is local HMAC signing, not I/O);
    the per-photo queries for social imports fan out concurrently below, and
    the five kinds are gathered at the call site.
    """
    if not rows:
        return []
    if kind == "outfit_render":
        # Resolve outfit names in one bounded query so render runs show what
        # they rendered (FakeDB-friendly: plain in_ lookup, no embed).
        outfit_ids = [str(row.get("outfit_id")) for row in rows if row.get("outfit_id")]
        names: Dict[str, str] = {}
        if outfit_ids:
            try:
                result = await execute_with_reconnect(
                    lambda d: d.table("outfits")
                    .select("id,name")
                    .eq("user_id", user_id)
                    .in_("id", list(set(outfit_ids)))
                    .execute(),
                    db,
                    extra={"operation": "admin.user_generations.outfit_render.names", "user_id": user_id},
                )
                names = {str(r.get("id")): str(r.get("name") or "") for r in (result.data or [])}
            except Exception as exc:
                _swallow("admin.user_generations.outfit_render.names", exc)
        return [await _normalize_outfit_render(row, user_id=user_id, outfit_names=names) for row in rows]
    if kind == "social_import":
        # One bounded photo query per job — fan out concurrently (a full
        # page would otherwise pay N sequential PostgREST round trips).
        photo_lists = await asyncio.gather(
            *(
                _fetch_import_photos(db, user_id, str(row.get("id") or ""))
                for row in rows
            )
        )
        return [
            await _normalize_social_import(db, row, user_id=user_id, photos=photos)
            for row, photos in zip(rows, photo_lists)
        ]
    if kind == "item":
        return [await _normalize_item_job(row, user_id=user_id) for row in rows]
    if kind == "outfit":
        return [await _normalize_outfit(row, user_id=user_id) for row in rows]
    if kind == "photoshoot":
        return [await _normalize_photoshoot(row, user_id=user_id) for row in rows]
    return []


async def list_user_generations(
    db: Any,
    user_id: str,
    *,
    kind: str = "all",
    status: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
) -> Dict[str, Any]:
    """Paginated, normalized generations for one user across all kinds."""
    if kind != "all" and kind not in GEN_KINDS:
        raise ValidationError(
            message=f"Unknown generation kind '{kind}'",
            details={"allowed": ["all", *GEN_KINDS]},
        )
    page = max(int(page or 1), 1)
    page_size = min(max(int(page_size or 20), 1), 50)

    if kind != "all":
        rows, total = await _fetch_kind_rows(
            db, kind, user_id, page=page, page_size=page_size, status=status
        )
        items = await _normalize_rows(db, kind, rows, user_id=user_id)
        counts = await _generation_counts(db, user_id, status=status)
        return {
            "user_id": user_id,
            "items": items,
            "total": total,
            "page": page,
            "page_size": page_size,
            "counts": counts,
        }

    # Merged "all" view: per-kind recent window, merged + sliced. Exact
    # per-kind counts make up the total (see module docstring for the bound).
    window = min(page * page_size, _ALL_KIND_WINDOW)
    item_rows, _ = await _paged(
        db, table="extraction_jobs", columns=_ITEM_COLUMNS, user_id=user_id,
        operation="admin.user_generations.item", page=1, page_size=window, status=status,
    )
    outfit_rows, _ = await _paged(
        db, table="outfits", columns=_OUTFIT_COLUMNS, user_id=user_id,
        operation="admin.user_generations.outfit", page=1, page_size=window, status=status,
        supports_status=False,
    )
    render_rows, _ = await _paged(
        db, table="outfit_generations", columns=_RENDER_COLUMNS, user_id=user_id,
        operation="admin.user_generations.outfit_render", page=1, page_size=window, status=status,
    )
    photoshoot_rows, _ = await _fetch_photoshoot_rows(
        db, user_id, page=1, page_size=window, status=status
    )
    import_rows, _ = await _paged(
        db, table="social_import_jobs", columns=_IMPORT_COLUMNS, user_id=user_id,
        operation="admin.user_generations.social_import", page=1, page_size=window, status=status,
    )

    (
        item_items,
        outfit_items,
        render_items,
        photoshoot_items,
        import_items,
    ) = await asyncio.gather(
        _normalize_rows(db, "item", item_rows, user_id=user_id),
        _normalize_rows(db, "outfit", outfit_rows, user_id=user_id),
        _normalize_rows(db, "outfit_render", render_rows, user_id=user_id),
        _normalize_rows(db, "photoshoot", photoshoot_rows, user_id=user_id),
        _normalize_rows(db, "social_import", import_rows, user_id=user_id),
    )
    merged = [*item_items, *outfit_items, *render_items, *photoshoot_items, *import_items]
    merged.sort(key=lambda item: item.get("created_at") or "", reverse=True)
    offset = (page - 1) * page_size
    items = merged[offset : offset + page_size]
    counts = await _generation_counts(db, user_id, status=status)
    # Cap the reported total to the reachable recent window: each kind only
    # contributes its most recent _ALL_KIND_WINDOW rows to the merge, so the
    # total is the sum of per-kind reachable rows — never the uncapped sum,
    # which would offer pages past the merged set (e.g. one kind x 100 rows
    # reporting 100 while only 50 are reachable).
    reachable_total = sum(
        min(counts.get(COUNT_KEYS[kind], 0), _ALL_KIND_WINDOW) for kind in GEN_KINDS
    )
    return {
        "user_id": user_id,
        "items": items,
        "total": reachable_total,
        "page": page,
        "page_size": page_size,
        "counts": counts,
    }


async def _fetch_kind_rows(
    db: Any,
    kind: str,
    user_id: str,
    *,
    page: int,
    page_size: int,
    status: Optional[str],
) -> Tuple[List[Dict[str, Any]], int]:
    if kind == "photoshoot":
        return await _fetch_photoshoot_rows(
            db, user_id, page=page, page_size=page_size, status=status
        )
    table, operation = _FETCHERS[kind]
    columns = {
        "item": _ITEM_COLUMNS,
        "outfit": _OUTFIT_COLUMNS,
        "outfit_render": _RENDER_COLUMNS,
        "social_import": _IMPORT_COLUMNS,
    }[kind]
    return await _paged(
        db, table=table, columns=columns, user_id=user_id, operation=operation,
        page=page, page_size=page_size, status=status,
        # outfits is a saved-entity table with no status column.
        supports_status=kind != "outfit",
    )


async def _generation_counts(
    db: Any, user_id: str, status: Optional[str] = None
) -> Dict[str, int]:
    pairs = await asyncio.gather(
        *(
            _count_kind(
                db,
                table=table,
                user_id=user_id,
                operation=f"admin.user_generations.count.{kind}",
                status=status,
                supports_status=kind != "outfit",
            )
            for kind, (table, _operation) in _FETCHERS.items()
        )
    )
    return {COUNT_KEYS[kind]: count for (kind, _specs), count in zip(_FETCHERS.items(), pairs)}


async def get_user_generation(
    db: Any, user_id: str, kind: str, generation_id: str
) -> Dict[str, Any]:
    """One normalized generation (ownership-guarded: user_id must match)."""
    if kind not in GEN_KINDS:
        raise ValidationError(
            message=f"Unknown generation kind '{kind}'",
            details={"allowed": list(GEN_KINDS)},
        )
    if not generation_id:
        raise ValidationError(message="generation_id is required")

    if kind == "photoshoot":
        row = await _fetch_photoshoot_row(db, user_id, str(generation_id))
    else:
        table, operation = _FETCHERS[kind]
        columns = {
            "item": _ITEM_COLUMNS,
            "outfit": _OUTFIT_COLUMNS,
            "outfit_render": _RENDER_COLUMNS,
            "social_import": _IMPORT_COLUMNS,
        }[kind]
        try:
            result = await execute_with_reconnect(
                lambda d: d.table(table)
                .select(columns)
                .eq("id", generation_id)
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": f"{operation}.detail", "user_id": user_id},
            )
            row = maybe_single_data(result)
        except Exception as exc:
            _swallow(f"{operation}.detail", exc)
            row = None

    if not row:
        raise NotFoundError(
            message="Generation not found",
            resource_type="generation",
            resource_id=generation_id,
        )
    normalized = await _normalize_rows(db, kind, [dict(row)], user_id=user_id)
    return normalized[0]


# ---------------------------------------------------------------------------
# Billing / referrals / body profile
# ---------------------------------------------------------------------------


def _invoice_item(invoice: Any) -> Dict[str, Any]:
    """Attribute- or dict-access one Stripe invoice into a stable dict."""
    def _get(name: str) -> Any:
        if isinstance(invoice, dict):
            return invoice.get(name)
        return getattr(invoice, name, None)

    return {
        "id": _get("id"),
        "number": _get("number"),
        "created": _stripe_ts(_get("created")),
        "period_start": _stripe_ts(_get("period_start")),
        "period_end": _stripe_ts(_get("period_end")),
        "amount_paid": _get("amount_paid"),
        "currency": _get("currency"),
        "status": _get("status"),
        "hosted_invoice_url": _get("hosted_invoice_url"),
        "invoice_pdf": _get("invoice_pdf"),
    }


def _stripe_ts(value: Any) -> Optional[str]:
    """Normalize a Stripe unix-seconds timestamp to an ISO-8601 UTC string.

    Every other datetime in the admin API is an ISO string; Stripe sends
    seconds since epoch, which `new Date(n)`-style consumers read as
    milliseconds (→ January 1970). Pass strings through untouched.
    """
    if isinstance(value, bool):
        return None
    if isinstance(value, (int, float)):
        try:
            return datetime.fromtimestamp(value, tz=timezone.utc).isoformat().replace(
                "+00:00", "Z"
            )
        except (OverflowError, OSError, ValueError):
            return None
    if isinstance(value, str) and value:
        return value
    return None


async def get_user_billing(
    db: Any, user_id: str, *, include_iap: bool = True
) -> Dict[str, Any]:
    """Subscription + Stripe invoice history (+ IAP row when permitted).

    Best-effort by design: no Stripe key, no customer id, or a Stripe error
    all yield empty invoice lists — the console still shows the stored
    subscription and IAP state.
    """
    try:
        sub_result = await execute_with_reconnect(
            lambda d: d.table("subscriptions").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.user_billing.subscription", "user_id": user_id},
        )
        sub_row = maybe_single_data(sub_result) or {}
    except Exception as exc:
        _swallow("admin.user_billing.subscription", exc)
        sub_row = {}

    invoices: List[Dict[str, Any]] = []
    customer_id = sub_row.get("stripe_customer_id") if isinstance(sub_row, dict) else None
    if settings.STRIPE_SECRET_KEY and customer_id:
        def _list_invoices() -> Any:
            import stripe  # local import: stripe is only needed on this path

            stripe.api_key = settings.STRIPE_SECRET_KEY
            return stripe.Invoice.list(customer=customer_id, limit=12)

        try:
            result = await asyncio.to_thread(_list_invoices)
            invoices = [_invoice_item(invoice) for invoice in getattr(result, "data", []) or []]
        except Exception as exc:
            _swallow("admin.user_billing.invoices", exc)
            invoices = []

    iap: List[Dict[str, Any]] = []
    if include_iap:
        try:
            iap_result = await execute_with_reconnect(
                lambda d: d.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .in_("billing_provider", ["apple", "google"])
                .execute(),
                db,
                extra={"operation": "admin.user_billing.iap", "user_id": user_id},
            )
            iap = [_iap_item(dict(row)) for row in (iap_result.data or [])]
        except Exception as exc:
            _swallow("admin.user_billing.iap", exc)
            iap = []

    subscription = dict(sub_row) if isinstance(sub_row, dict) else {}
    if subscription:
        # Display-only mirror of configured plan prices (settings PLAN_*_PRICE);
        # not a live Stripe price — this function only fetches invoices.
        subscription["amount"] = plan_display_amount(subscription.get("plan_type"))
    return {
        "user_id": user_id,
        "subscription": subscription or None,
        "stripe_invoices": invoices,
        "iap_transactions": iap,
        "stripe_configured": bool(settings.STRIPE_SECRET_KEY),
    }


async def get_user_referrals(db: Any, user_id: str) -> Dict[str, Any]:
    """Referral code + who redeemed it + promo redemptions for one user."""
    try:
        code_result = await execute_with_reconnect(
            lambda d: d.table("referral_codes").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.user_referrals.code", "user_id": user_id},
        )
        code_row = maybe_single_data(code_result) or {}
    except Exception as exc:
        _swallow("admin.user_referrals.code", exc)
        code_row = {}

    redemptions: List[Dict[str, Any]] = []
    try:
        red_result = await execute_with_reconnect(
            lambda d: d.table("referral_redemptions")
            .select("*")
            .eq("referrer_user_id", user_id)
            .order("redeemed_at", desc=True)
            .limit(25)
            .execute(),
            db,
            extra={"operation": "admin.user_referrals.redemptions", "user_id": user_id},
        )
        raw = [dict(row) for row in (red_result.data or [])]
        # Referred-user identities via a bounded in_ lookup (no embed needed).
        referred_ids = list({str(row.get("referred_user_id")) for row in raw if row.get("referred_user_id")})
        users_by_id: Dict[str, Dict[str, Any]] = {}
        if referred_ids:
            users_result = await execute_with_reconnect(
                lambda d: d.table("users")
                .select("id,email,full_name")
                .in_("id", referred_ids)
                .execute(),
                db,
                extra={"operation": "admin.user_referrals.referred_users", "user_id": user_id},
            )
            users_by_id = {str(u.get("id")): dict(u) for u in (users_result.data or [])}
        for row in raw:
            referred = users_by_id.get(str(row.get("referred_user_id"))) or {}
            redemptions.append(
                {
                    "id": str(row.get("id") or ""),
                    "referred_user_id": str(row.get("referred_user_id") or ""),
                    "referred_email": referred.get("email"),
                    "referred_name": referred.get("full_name"),
                    "referrer_credit_applied": row.get("referrer_credit_applied"),
                    "referred_credit_applied": row.get("referred_credit_applied"),
                    "credit_months": row.get("credit_months"),
                    "redeemed_at": _iso(row.get("redeemed_at")),
                }
            )
    except Exception as exc:
        _swallow("admin.user_referrals.redemptions", exc)
        redemptions = []

    promo_redemptions: List[Dict[str, Any]] = []
    try:
        promo_result = await execute_with_reconnect(
            lambda d: d.table("promo_redemptions")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(10)
            .execute(),
            db,
            extra={"operation": "admin.user_referrals.promo", "user_id": user_id},
        )
        promo_rows = [dict(row) for row in (promo_result.data or [])]
        code_ids = list({str(row.get("promo_code_id")) for row in promo_rows if row.get("promo_code_id")})
        codes_by_id: Dict[str, Dict[str, Any]] = {}
        if code_ids:
            codes_result = await execute_with_reconnect(
                lambda d: d.table("promo_codes")
                .select("id,code,plan_type,months")
                .in_("id", code_ids)
                .execute(),
                db,
                extra={"operation": "admin.user_referrals.promo_codes", "user_id": user_id},
            )
            codes_by_id = {str(c.get("id")): dict(c) for c in (codes_result.data or [])}
        for row in promo_rows:
            code = codes_by_id.get(str(row.get("promo_code_id"))) or {}
            promo_redemptions.append(
                {
                    "id": str(row.get("id") or ""),
                    "code": code.get("code"),
                    "plan_type": row.get("plan_type"),
                    "months": row.get("months"),
                    "created_at": _iso(row.get("created_at")),
                }
            )
    except Exception as exc:
        _swallow("admin.user_referrals.promo", exc)
        promo_redemptions = []

    return {
        "user_id": user_id,
        "code": code_row.get("code") if isinstance(code_row, dict) else None,
        "times_used": code_row.get("times_used") or 0 if isinstance(code_row, dict) else 0,
        "redemptions": redemptions,
        "promo_redemptions": promo_redemptions,
    }


_BODY_PROFILE_COLUMNS = (
    "id,name,height_cm,weight_kg,body_shape,skin_tone,is_default,created_at,updated_at"
)


async def get_user_body_profile(db: Any, user_id: str) -> Dict[str, Any]:
    """Body profiles (photoshoot realism inputs). Never ``encrypted_data``."""
    try:
        profiles_result = await execute_with_reconnect(
            lambda d: d.table("body_profiles")
            .select(_BODY_PROFILE_COLUMNS)
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(10)
            .execute(),
            db,
            extra={"operation": "admin.user_body_profile.profiles", "user_id": user_id},
        )
        profiles = [dict(row) for row in (profiles_result.data or [])]
    except Exception as exc:
        _swallow("admin.user_body_profile.profiles", exc)
        profiles = []
    # Defense in depth: the select never names encrypted_data, but strip it
    # anyway so a future select("*") cannot leak ciphertext to the console.
    for profile in profiles:
        profile.pop("encrypted_data", None)

    gender: Optional[str] = None
    try:
        user_result = await execute_with_reconnect(
            lambda d: d.table("users").select("id,gender").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.user_body_profile.gender", "user_id": user_id},
        )
        user_row = maybe_single_data(user_result) or {}
        gender = user_row.get("gender") if isinstance(user_row, dict) else None
    except Exception as exc:
        _swallow("admin.user_body_profile.gender", exc)

    return {
        "user_id": user_id,
        "profiles": profiles,
        "gender": _iso(gender),
    }
