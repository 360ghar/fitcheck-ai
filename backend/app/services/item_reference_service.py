"""
Resolve wardrobe item reference images for outfit image generation.

Outfit generation used to describe garments to the image model in words only,
so the model invented a plausible lookalike for every item. This module turns
the `item_id`s on a generate-outfit request into the items' own stored images,
which the image agent then sends as labelled garment references alongside the
avatar identity reference.

One batched, user-scoped query, then a concurrent download + downscale. The
caller's item dicts come back in the SAME order with a
`reference_image_base64` key added to the ones that resolved — order is the
contract, because the agent numbers the prompt's "IMAGE n" labels off it.
Every failure mode degrades that one item to text-only rather than failing the
generation.
"""

from __future__ import annotations

import asyncio
from typing import Any, Dict, List, Optional, Tuple

from supabase import Client

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.services.storage_service import StorageService
from app.utils.image_processing import downscale_base64_image
from app.utils.parallel import parallel_map_settled

logger = get_context_logger(__name__)

# Key the image generation agent reads off each item dict.
REFERENCE_KEY = "reference_image_base64"

# Reference downloads run concurrently but not all at once: each in-flight
# download holds the raw image plus its base64 in memory, and a big outfit
# would otherwise open one connection per item. Eight rounds through a
# 60-item worst case still costs a fraction of the generation that follows.
_DOWNLOAD_CONCURRENCY = 8


async def resolve_outfit_item_references(
    db: Client,
    user_id: str,
    items: List[Dict[str, Any]],
    *,
    max_edge: Optional[int] = None,
) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    """Attach `reference_image_base64` to every item that has a stored image.

    Args:
        db: Supabase client (elevated service client from get_db).
        user_id: The caller. This is the security boundary — see the query below.
        items: Item dicts from GenerateOutfitRequest, optionally carrying
            `item_id`.
        max_edge: Longest edge for the downscaled references. Defaults to
            settings.AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE.

    Returns:
        (items, stats) where `items` is a NEW list in the input order (never
        mutated in place) and `stats` is a flat dict for one structured log
        line.
    """
    edge = max_edge or settings.AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE

    stats: Dict[str, Any] = {
        "items": len(items),
        "with_item_id": 0,
        "found_images": 0,
        "download_failed": 0,
        "resolved": 0,
        "reference_kb": 0,
    }

    # Ordered de-dup: the same item can legitimately appear once, but a client
    # bug repeating one must not download it twice.
    requested_ids: List[str] = []
    for item in items:
        item_id = item.get("item_id")
        if not item_id:
            continue
        stats["with_item_id"] += 1
        key = str(item_id)
        if key not in requested_ids:
            requested_ids.append(key)

    if not requested_ids:
        return list(items), stats

    # ONE batched query. The user_id filter is the security boundary: `db` is
    # the elevated service client, and item_images has no user_id column of its
    # own (see 001_full_schema.sql), so ownership can only be enforced through
    # the parent items row. Another user's item_id simply does not come back,
    # and that item degrades to text-only with no error and no leak.
    #
    # Deliberately no is_deleted filter: an outfit that still lists a
    # soft-deleted item should keep rendering that garment faithfully.
    try:
        res = await asyncio.to_thread(
            db.table("items")
            .select("id,item_images(image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .in_("id", requested_ids)
            .execute
        )
        rows = res.data or []
    except Exception as e:
        # ponytail: best-effort - generation still works from the text
        # inventory, so a DB hiccup must not fail the whole request.
        logger.warning(
            "Failed to fetch outfit item reference images",
            user_id=user_id,
            item_count=len(requested_ids),
            error=str(e),
        )
        stats["query_failed"] = True
        return list(items), stats

    # Pick the primary image else the first, same shape as
    # GET /outfits/available-items. Unlike that endpoint we prefer image_url
    # over thumbnail_url: thumbnails are sized for grid tiles and are too
    # low-res to carry print, weave, and hardware detail.
    url_by_item_id: Dict[str, str] = {}
    for row in rows:
        images = row.get("item_images") or []
        if not images:
            continue
        primary = next((i for i in images if i.get("is_primary")), images[0])
        url = primary.get("image_url") or primary.get("thumbnail_url")
        if url:
            url_by_item_id[str(row["id"])] = url

    stats["found_images"] = len(url_by_item_id)
    if not url_by_item_id:
        return list(items), stats

    semaphore = asyncio.Semaphore(_DOWNLOAD_CONCURRENCY)

    async def _fetch(item_id: str) -> Optional[str]:
        async with semaphore:
            raw = await StorageService.download_to_base64(url_by_item_id[item_id])
            if not raw:
                return None
            # PIL work is CPU-bound - off the event loop, as in
            # batch_extraction_service.
            return await asyncio.to_thread(downscale_base64_image, raw, edge)

    fetch_ids = list(url_by_item_id.keys())
    results = await parallel_map_settled(fetch_ids, _fetch)

    base64_by_item_id: Dict[str, str] = {}
    for item_id, result in zip(fetch_ids, results):
        image_base64 = result.data if result.success else None
        if image_base64:
            base64_by_item_id[item_id] = image_base64
        else:
            stats["download_failed"] += 1
            if result.error is not None:
                logger.warning(
                    "Outfit item reference image failed to load",
                    user_id=user_id,
                    item_id=item_id,
                    error=str(result.error),
                )

    resolved_items: List[Dict[str, Any]] = []
    for item in items:
        item_id = item.get("item_id")
        image_base64 = base64_by_item_id.get(str(item_id)) if item_id else None
        if image_base64:
            resolved_items.append({**item, REFERENCE_KEY: image_base64})
            stats["resolved"] += 1
            stats["reference_kb"] += len(image_base64) // 1024
        else:
            resolved_items.append(item)

    return resolved_items, stats
