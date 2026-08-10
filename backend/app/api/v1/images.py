"""
Image / presigned-URL read endpoints.

The object-storage bucket is PRIVATE (R2 / Railway alike). The DB stores the
durable ``storage_path`` (bucket key), never a public URL; clients fetch a fresh
short-lived presigned GET URL at read time. This module is the serving path that
replaces storing public URLs.

Routes:
- GET /api/v1/images/presigned?storage_path=...  -> fresh presigned GET URL

The endpoint is auth-protected and scoped to the caller's own objects: the
key layout is ``{user_id}/{category}/{uuid}.{ext}`` (canonical) or
``{tmp|generated}/{user_id}/{sub}/{uuid}.{ext}`` (preview folders), so a
request is only served when the owning path segment equals the authenticated
user's ID — the first segment for canonical keys, the second for the top-level
``tmp/`` and ``generated/`` preview folders. A request for another user's
object is indistinguishable from a missing one (404), so we never reveal
whether an object exists.
"""

import asyncio
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.config import settings
from app.core.exceptions import NotFoundError
from app.core.logging_config import get_context_logger
from app.api.v1.deps import get_active_user_id
from app.core.storage_keys import is_owned_storage_key, key_from_path, parse_key
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

router = APIRouter()

# The key grammar + ownership check live in app.core.storage_keys (routes AND
# services guard against the same rule — see the module docstring there). The
# alias keeps every historical call site (and its tests) reading the same name.
_is_owned_by_user = is_owned_storage_key


async def serve_url(storage_path: str) -> str:
    """Return a client-fetchable URL for a bucket key in the current serving mode.

    ``presigned`` (default): a short-lived signed GET URL from the S3 backend.
    The signature rotates on every refetch, so browser/CDN/disk caches never
    hit and full bytes re-stream from the bucket on every list load — the
    dominant egress driver (see the railway-egress RCA).

    ``worker``: a STABLE path-only URL on ``IMAGE_CDN_BASE_URL`` served by the
    Cloudflare Worker (``infra/images-worker``), which validates the app JWT
    and the per-user path prefix before serving the object from the R2 bucket.
    Stable URLs are cacheable at the Cloudflare edge, in the browser HTTP
    cache and in Flutter's disk cache, and R2 egress to the internet is free.
    """
    if settings.IMAGE_SERVING_MODE == "worker" and settings.IMAGE_CDN_BASE_URL:
        return f"{settings.IMAGE_CDN_BASE_URL.rstrip('/')}/{storage_path.lstrip('/')}"
    return await StorageService.get_public_url(storage_path)


async def materialize_avatar_url(
    avatar_url: Any,
    *,
    presigned: bool = False,
) -> Optional[str]:
    """Return a fresh URL for a stored ``users.avatar_url``, or None if not ours.

    ``users.avatar_url`` is written at upload time with the LIVE presigned URL
    (``users.py`` -> ``StorageService.upload_avatar``), so the stored value is
    dead as soon as ``OBJECT_STORAGE_PRESIGN_TTL`` elapses. Every read path that
    surfaces an avatar therefore has to re-materialize it from the bucket key.
    The column may also hold a bare key, a legacy public Supabase URL, or an
    external OAuth ``picture`` URL — hence the UUID first-segment guard: only our
    own objects are re-minted, anything else returns None so the caller can pass
    the stored value through untouched.

    ``presigned=True`` forces a signed URL even in worker mode. Required for two
    cases the Worker cannot serve:
      * provider-bound URLs (an AI provider cannot present the app's JWT);
      * ANOTHER user's avatar (the Worker's ownership rule is "first path
        segment == token sub", so a cross-user key is a 404 there).

    Single source of truth for this guard on purpose: it previously existed as
    two hand-synced copies (users.py and ai.py) while the leaderboard had none,
    which is exactly how the stale-avatar bug got in.
    """
    if not avatar_url or not isinstance(avatar_url, str):
        return None
    key = key_from_path(avatar_url)
    if not key:
        return None
    # Only our own avatar objects are re-minted. The current users/ layout
    # nests keys under `users/{user_id}/avatars/...` (first segment "users",
    # not a UUID), so the ownership guard is the structural parser, not the
    # old UUID-first-segment heuristic — that heuristic would silently stop
    # re-minting every avatar after the layout migration.
    ref = parse_key(key)
    if ref is None or ref.layout not in ("canonical", "thumb") or ref.category != "avatars":
        return None
    if presigned:
        return await StorageService.get_public_url(key)
    return await serve_url(key)


async def materialize_image_urls(
    images: List[Dict[str, Any]], *, presigned: bool = False, owner_user_id: Optional[str] = None
) -> List[Dict[str, Any]]:
    """Regenerate fresh image URLs from ``storage_path`` (read-time materialization).

    The DB stores the durable ``storage_path``; the public ``image_url`` is
    either a short-lived presigned URL or a stable Worker URL and must be
    materialized at read time so it is never stale/expired. For each image
    dict that carries a ``storage_path``, fresh URLs are generated in place:
    ``image_url`` always points at the original object; ``thumbnail_url``
    points at the downscaled ``_thumb`` sibling when thumbnail serving is
    enabled AND the backfill has run (``THUMBNAIL_SERVING`` +
    ``THUMBNAILS_BACKFILLED``), otherwise it mirrors ``image_url`` so tiles
    never 404. The backfill gate exists because ``_thumb`` siblings are only
    guaranteed to exist after ``scripts/generate_thumbnails.py`` has covered
    the bucket: pre-backfill objects (and best-effort uploads whose thumb
    encode failed) have no sibling, and a presigned URL for a missing object
    returns 404, not a fallback. Images without a ``storage_path`` (legacy
    Supabase public URLs) are left untouched. The Flutter-compat ``url``
    field, when present, is kept in sync with the fresh URLs.

    ``owner_user_id`` enables the URL-derivation fallback: rows written by
    the web batch save before 2026-08-09 stored the short-lived presigned URL
    with a NULL ``storage_path`` (the read path could never re-mint it and
    the tile 403'd at TTL). When the caller is authenticated, the key is
    derived from the stored URL and re-minted — but ONLY when the derived key
    is owned by the caller (``_is_owned_by_user``): re-minting a cross-user
    key would hand out a fresh presigned URL for an object the caller does
    not own. Anonymous surfaces pass no owner and keep the legacy behavior.

    ``presigned=True`` forces short-lived signed URLs even in ``worker`` mode
    (mirrors ``materialize_avatar_url(..., presigned=True)``). Required for
    ANONYMOUS surfaces that cannot present the app's JWT to the Worker — the
    public shared-outfit endpoint, whose images render for share-link
    visitors and social crawlers. Without the flag, worker-mode URLs on that
    endpoint would 404 for every anonymous viewer.

    This is a shared helper for the items/outfits read paths (which surface
    image URLs) and lives here so the serving logic stays in one place.
    """
    if not images:
        return images

    thumbnails_on = settings.THUMBNAIL_SERVING and settings.THUMBNAILS_BACKFILLED

    # Phase 1: collect every key that needs a URL. Each serve_url is a network
    # round trip (presigned mode), so a 20-image page previously serialized up
    # to 40 of them — the dominant latency on every list/read path.
    jobs: List[tuple] = []  # (img, storage_path, thumb_key_or_None)
    for img in images:
        if not isinstance(img, dict):
            continue
        storage_path = img.get("storage_path")
        if not storage_path and owner_user_id:
            # Legacy/regression rows without a durable key carry the key
            # embedded in the stored URL (a presigned ``/<bucket>/<key>``
            # URL). Derive it and re-mint so the tile renders again — but
            # only when the derived key is owned by the requesting user.
            derived = key_from_path(img.get("image_url"))
            if derived and _is_owned_by_user(derived, owner_user_id):
                storage_path = derived
        if not storage_path:
            continue
        thumb_key = StorageService.thumb_key_for(storage_path) if thumbnails_on else None
        jobs.append((img, storage_path, thumb_key))

    def _mint_one(key: str):
        """Mint a URL for ``key`` in the caller's requested serving mode."""
        if presigned:
            return StorageService.get_public_url(key)
        return serve_url(key)

    # Phase 2: mint all URLs concurrently. return_exceptions keeps one failing
    # key from aborting the whole batch; the per-image skip below mirrors the
    # old sequential try/except semantics.
    urls = await asyncio.gather(
        *(
            _mint_one(key)
            for _img, storage_path, thumb_key in jobs
            for key in (storage_path, thumb_key)
            if key is not None
        ),
        return_exceptions=True,
    )

    # Phase 3: assign back in job order (same as the sequential loop).
    url_iter = iter(urls)
    for img, storage_path, thumb_key in jobs:
        fresh = next(url_iter)
        thumb_url = next(url_iter) if thumb_key else None
        if isinstance(fresh, Exception) or (thumb_key and isinstance(thumb_url, Exception)):
            error = fresh if isinstance(fresh, Exception) else thumb_url
            logger.warning(
                "Failed to materialize presigned URL",
                storage_path=storage_path,
                error=str(error),
            )
            continue
        # Refresh BOTH image_url and thumbnail_url: the web/mobile cards
        # prefer thumbnail_url || image_url, so a stale thumbnail would win
        # over a fresh image_url and render a broken/expired asset.
        img["image_url"] = fresh
        img["thumbnail_url"] = thumb_url if thumb_key else fresh
        if "url" in img:
            img["url"] = img.get("image_url") or img.get("thumbnail_url") or ""
    return images


async def _remint_parent_source_url(
    parent: Dict[str, Any], *, presigned: bool, owner_user_id: str
) -> None:
    """Re-mint an item row's ``source_image_url`` from its durable key.

    ``items.source_image_url`` is written at create time with the LIVE
    presigned URL (the batch save passes the job's URL through), so the stored
    value dies as soon as ``OBJECT_STORAGE_PRESIGN_TTL`` elapses. The durable
    key lives in ``source_image_storage_path``; every authenticated read
    re-mints from it — or, for rows that predate the key column, from the key
    embedded in the stored URL. Both are accepted ONLY when the key is owned
    by the requesting user (same rule as the ``materialize_image_urls``
    derivation): a crafted cross-user key must never yield a fresh presigned
    URL for another user's object. Anonymous surfaces (public shared outfits)
    never re-mint — source photos are not rendered there and re-minting
    without an ownership context is unsafe.
    """
    path = parent.get("source_image_storage_path") or key_from_path(
        parent.get("source_image_url")
    )
    if not path or not _is_owned_by_user(path, owner_user_id):
        return
    if presigned:
        parent["source_image_url"] = await StorageService.get_public_url(path)
    else:
        parent["source_image_url"] = await serve_url(path)


async def materialize_parent_images(
    parents: List[Dict[str, Any]], *, presigned: bool = False, owner_user_id: Optional[str] = None
) -> List[Dict[str, Any]]:
    """Materialize presigned URLs for a list of parent rows' ``images`` lists.

    Convenience wrapper for read handlers that normalize a list of items/outfits
    (each carrying an ``images`` list) and may also carry nested ``items`` whose
    own ``images`` should be refreshed too. ``presigned`` is passed through to
    :func:`materialize_image_urls` (see its docstring for when to force it).
    ``owner_user_id`` is passed through as well and additionally enables the
    ``source_image_url`` re-mint on item rows (see
    :func:`_remint_parent_source_url`); authenticated read handlers pass their
    ``user_id``, anonymous surfaces pass nothing.
    """
    async def _materialize_one(parent: Dict[str, Any]) -> None:
        if not isinstance(parent, dict):
            return
        await materialize_image_urls(
            parent.get("images") or [], presigned=presigned, owner_user_id=owner_user_id
        )
        # Item rows persist the source photo as a presigned URL at create time;
        # re-mint it from the durable key on every authenticated read.
        if owner_user_id:
            await _remint_parent_source_url(parent, presigned=presigned, owner_user_id=owner_user_id)
        nested_items = parent.get("items")
        if isinstance(nested_items, list):
            for nested in nested_items:
                if isinstance(nested, dict):
                    await materialize_image_urls(
                        nested.get("images") or [], presigned=presigned, owner_user_id=owner_user_id
                    )
                    if owner_user_id:
                        await _remint_parent_source_url(
                            nested, presigned=presigned, owner_user_id=owner_user_id
                        )
    await asyncio.gather(*(_materialize_one(p) for p in (parents or [])))
    return parents


@router.get("/presigned", response_model=Dict[str, Any])
async def get_presigned_url(
    storage_path: str = Query(..., description="Bucket key (storage_path) to serve"),
    user_id: str = Depends(get_active_user_id),
):
    """Return a fresh client-fetchable URL for a caller-owned object.

    The ``storage_path`` must be scoped to the authenticated user (key layout
    prefix ``{user_id}/``). A request for another user's object returns 404 so
    object existence is never revealed across users.

    Routed through ``serve_url``, so the URL matches whatever the list/read paths
    are emitting in the current ``IMAGE_SERVING_MODE``. Minting a presigned URL
    here regardless would hand clients an uncacheable URL for an object every
    other surface serves from the cacheable Worker origin — the response name is
    historical, the contract is "a URL you can fetch now".
    """
    if not storage_path or not _is_owned_by_user(storage_path, user_id):
        raise NotFoundError(
            message="Image not found",
            resource_type="image",
            resource_id=storage_path,
        )
    url = await serve_url(storage_path)
    return {"data": {"url": url, "storage_path": storage_path}, "message": "OK"}