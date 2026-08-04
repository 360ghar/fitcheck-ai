"""
Image / presigned-URL read endpoints.

Railway Buckets are PRIVATE. The DB stores the durable ``storage_path`` (bucket
key), never a public URL; clients fetch a fresh short-lived presigned GET URL
at read time. This module is the serving path that replaces storing public URLs.

Routes:
- GET /api/v1/images/presigned?storage_path=...  -> fresh presigned GET URL

The endpoint is auth-protected and scoped to the caller's own objects: the key
layout is ``{user_id}/{category}/{uuid}.{ext}``, so a request is only served
when the requested ``storage_path`` starts with the authenticated user's ID
prefix. A request for another user's object is indistinguishable from a missing
one (404), so we never reveal whether an object exists.
"""

import re
from typing import Any, Dict, List

from fastapi import APIRouter, Depends, Query

from app.core.exceptions import NotFoundError
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

router = APIRouter()


_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?:items|outfits|avatars|sources|feedback)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
_TMP_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+?)/tmp/(?P<source>[^/\\]+?)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)


def _is_owned_by_user(storage_path: str, user_id: str) -> bool:
    """Validate a canonical StorageService key and its user ownership.

    Do not use a prefix-only check: encoded separators are decoded by the
    framework before this function, and ``../`` or a user-id prefix trick must
    never reach the presigner. Legacy valid keys may include ``tmp/{source}``.
    """
    if not isinstance(storage_path, str) or not isinstance(user_id, str):
        return False
    if storage_path != storage_path.strip() or any(c in storage_path for c in "\\\r\n"):
        return False
    match = _KEY_RE.fullmatch(storage_path) or _TMP_KEY_RE.fullmatch(storage_path)
    return bool(match and match.group("user") == user_id)


async def materialize_image_urls(images: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Regenerate fresh presigned URLs from ``storage_path`` (read-time materialization).

    The DB stores the durable ``storage_path``; the public ``image_url`` is a
    short-lived presigned URL that must be materialized at read time so it is
    never stale/expired. For each image dict that carries a ``storage_path``, a
    fresh URL is generated in place. Images without a ``storage_path`` (legacy
    Supabase public URLs) are left untouched. The Flutter-compat ``url`` field,
    when present, is kept in sync with the fresh URL.

    This is a shared helper for the items/outfits read paths (which surface
    image URLs) and lives here so the serving logic stays in one place.
    """
    if not images:
        return images
    for img in images:
        if not isinstance(img, dict):
            continue
        storage_path = img.get("storage_path")
        if not storage_path:
            continue
        try:
            fresh = await StorageService.get_public_url(storage_path)
            # Refresh BOTH image_url and thumbnail_url: the web/mobile cards
            # prefer thumbnail_url || image_url, so a stale thumbnail would win
            # over a fresh image_url and render a broken/expired asset.
            img["image_url"] = fresh
            img["thumbnail_url"] = fresh
        except Exception as e:
            logger.warning(
                "Failed to materialize presigned URL",
                storage_path=storage_path,
                error=str(e),
            )
        if "url" in img:
            img["url"] = img.get("image_url") or img.get("thumbnail_url") or ""
    return images


async def materialize_parent_images(parents: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Materialize presigned URLs for a list of parent rows' ``images`` lists.

    Convenience wrapper for read handlers that normalize a list of items/outfits
    (each carrying an ``images`` list) and may also carry nested ``items`` whose
    own ``images`` should be refreshed too.
    """
    for parent in parents or []:
        if not isinstance(parent, dict):
            continue
        await materialize_image_urls(parent.get("images") or [])
        nested_items = parent.get("items")
        if isinstance(nested_items, list):
            for nested in nested_items:
                if isinstance(nested, dict):
                    await materialize_image_urls(nested.get("images") or [])
    return parents


@router.get("/presigned", response_model=Dict[str, Any])
async def get_presigned_url(
    storage_path: str = Query(..., description="Bucket key (storage_path) to serve"),
    user_id: str = Depends(get_current_user_id),
):
    """Return a fresh short-lived presigned GET URL for a caller-owned object.

    The ``storage_path`` must be scoped to the authenticated user (key layout
    prefix ``{user_id}/``). A request for another user's object returns 404 so
    object existence is never revealed across users.
    """
    if not storage_path or not _is_owned_by_user(storage_path, user_id):
        raise NotFoundError(
            message="Image not found",
            resource_type="image",
            resource_id=storage_path,
        )
    url = await StorageService.get_public_url(storage_path)
    return {"data": {"url": url, "storage_path": storage_path}, "message": "OK"}