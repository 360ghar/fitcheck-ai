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
import re
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.config import settings
from app.core.exceptions import NotFoundError
from app.core.logging_config import get_context_logger
from app.api.v1.deps import get_active_user_id
from app.core.storage_keys import USER_ID_SEGMENT_RE
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

router = APIRouter()


_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?:items|outfits|avatars|sources|feedback)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
# Four-segment preview keys under the shared top-level folders,
# ``{tmp|generated}/{user}/{sub}/{name}.{ext}``, where the ``sub`` segment is:
#   tmp/{source}          - upload_temp_generated_image (social-import, batch,
#                           photoshoot review flows)
#   generated/{image_type}- image_generation_agent.save_generated_image, i.e. a
#                           try-on or outfit render the user asked to keep
# The top-level folder means every temp preview in the bucket shares ONE common
# prefix, so scripts/cleanup_temp_assets.py can list or clear the whole folder
# in a single pass.
# `generated` was originally missing here, which made those objects
# unrefreshable: their presigned URL is returned once (ai.py) and dies after
# OBJECT_STORAGE_PRESIGN_TTL, no DB row references them so no read path
# re-materializes them, and /images/presigned 404'd on the key. The image simply
# vanished an hour after it was generated.
_NESTED_KEY_RE = re.compile(
    r"^(?:tmp|generated)/(?P<user>[^/\\]+?)/(?P<sub>[^/\\]+?)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
# Pre-migration preview keys, ``{user}/{tmp|generated}/{sub}/{name}.{ext}``.
# Accepted ONLY until scripts/migrate_temp_keys_layout.py has rewritten every
# old key (delete this regex and the Worker's copy once the migration is
# verified complete). Keeping it during the migration window means a stored
# storage_path minted before the deploy keeps serving instead of 404ing.
_LEGACY_NESTED_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+?)/(?:tmp|generated)/(?P<sub>[^/\\]+?)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
# Thumbnail siblings, ``{stem}_thumb.webp``. Always .webp whatever the parent's
# format — see ``StorageService.THUMB_EXTENSION``. Servable so this endpoint and
# the Worker (infra/images-worker, which allows the same set) agree on what a
# valid key is.
_THUMB_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?:items|outfits|avatars|sources|feedback)/"
    r"(?P<name>[0-9a-f]{32})_thumb\.webp$"
)


def _is_owned_by_user(storage_path: str, user_id: str) -> bool:
    """Validate a canonical StorageService key and its user ownership.

    Do not use a prefix-only check: encoded separators are decoded by the
    framework before this function, and ``../`` or a user-id prefix trick must
    never reach the presigner. Valid keys are the canonical two-segment form,
    its ``_thumb.webp`` sibling, or the four-segment preview form under the
    top-level ``tmp/`` and ``generated/`` folders (plus the pre-migration
    ``{user}/{tmp|generated}/{type}`` form, see _LEGACY_NESTED_KEY_RE).

    ``infra/images-worker/worker.js`` enforces this same allowlist at the edge;
    the two must stay in step.
    """
    if not isinstance(storage_path, str) or not isinstance(user_id, str):
        return False
    if storage_path != storage_path.strip() or any(c in storage_path for c in "\\\r\n"):
        return False
    if ".." in storage_path:
        return False
    match = (
        _KEY_RE.fullmatch(storage_path)
        or _THUMB_KEY_RE.fullmatch(storage_path)
        or _NESTED_KEY_RE.fullmatch(storage_path)
        or _LEGACY_NESTED_KEY_RE.fullmatch(storage_path)
    )
    return bool(match and match.group("user") == user_id)


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
    key = StorageService.key_from_path(avatar_url)
    if not key or not USER_ID_SEGMENT_RE.fullmatch(key.split("/", 1)[0]):
        return None
    if presigned:
        return await StorageService.get_public_url(key)
    return await serve_url(key)


async def materialize_image_urls(images: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
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
        if not storage_path:
            continue
        thumb_key = StorageService.thumb_key_for(storage_path) if thumbnails_on else None
        jobs.append((img, storage_path, thumb_key))

    # Phase 2: mint all URLs concurrently. return_exceptions keeps one failing
    # key from aborting the whole batch; the per-image skip below mirrors the
    # old sequential try/except semantics.
    urls = await asyncio.gather(
        *(
            serve_url(key)
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


async def materialize_parent_images(parents: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Materialize presigned URLs for a list of parent rows' ``images`` lists.

    Convenience wrapper for read handlers that normalize a list of items/outfits
    (each carrying an ``images`` list) and may also carry nested ``items`` whose
    own ``images`` should be refreshed too.
    """
    async def _materialize_one(parent: Dict[str, Any]) -> None:
        if not isinstance(parent, dict):
            return
        await materialize_image_urls(parent.get("images") or [])
        nested_items = parent.get("items")
        if isinstance(nested_items, list):
            for nested in nested_items:
                if isinstance(nested, dict):
                    await materialize_image_urls(nested.get("images") or [])
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