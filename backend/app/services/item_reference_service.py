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
from collections import Counter
from typing import Any, Dict, List, Optional, Tuple

from supabase import Client

from app.core.config import settings
from app.core.concurrency import REFERENCE_DOWNLOAD_SEMAPHORE
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
        "skipped_references": 0,
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

    async def _fetch(item_id: str) -> Optional[str]:
        async with REFERENCE_DOWNLOAD_SEMAPHORE:
            raw = await StorageService.download_to_base64(url_by_item_id[item_id])
            if not raw:
                return None
            # PIL work is CPU-bound - off the event loop, as in
            # batch_extraction_service.
            return await asyncio.to_thread(downscale_base64_image, raw, edge)

    fetch_ids = list(url_by_item_id.keys())[: max(0, settings.AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES)]
    stats["skipped_references"] = max(0, len(url_by_item_id) - len(fetch_ids))
    if stats["skipped_references"]:
        logger.info(
            "Skipped outfit item reference images above configured limit",
            user_id=user_id,
            skipped_references=stats["skipped_references"],
            reference_limit=settings.AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES,
        )
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


async def resolve_outfit_source_reference(
    db: Client,
    user_id: str,
    items: List[Dict[str, Any]],
    *,
    max_edge: Optional[int] = None,
) -> Tuple[Optional[str], Dict[str, Any]]:
    """Resolve the original uploaded source photo for an outfit, if any.

    The upload flow (one auto-outfit per uploaded photo, see
    `frontend/src/lib/outfit-from-upload.ts`) opts in via
    `GenerateOutfitRequest.use_source_photo`. Every item in that outfit shares
    one source photo, which shows the garments AS WORN TOGETHER — real fit,
    draping, and layering that the extracted/generated item shots cannot
    carry. Sending it to the image model as one extra reference removes a
    lossy hop from the chain: the model copies the real clothes instead of
    re-deriving them from already-generated or cropped item images.

    Conservative, deterministic rules (see the config knobs in app/core/
    config.py):
    - Only `source_image_url` values on the caller's OWN items count — the
      same `.eq("user_id", ...)` boundary as `resolve_outfit_item_references`.
    - Duplicate URLs collapse; the URL shared by the most items wins.
    - A tie for the top slot is skipped entirely: two unrelated photos both
      claiming to be "the outfit" is ambiguity, and ambiguity is worse than
      no reference.
    - The winner must be shared by at least
      `AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS` items. The upload flow
      groups one photo per outfit, so 1 always passes there; the gate exists
      so a future caller cannot feed a scattered multi-photo outfit in.
    - At most `AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES` photos are ever sent
      (a floor-proof cap; the rules above already pick a single winner).
    - Every failure mode (missing URL, dead download, DB hiccup) returns
      None — the request proceeds exactly as it does today.

    Returns:
        (base64, stats) where `base64` is the downscaled source photo (or
        None) and `stats` is a flat dict for one structured log line.
    """
    edge = max_edge or settings.AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE

    stats: Dict[str, Any] = {
        "items": len(items),
        "with_item_id": 0,
        "distinct_source_urls": 0,
        "best_coverage": 0,
        "candidate_selected": False,
        "below_min_shared": False,
        "tie_skipped": False,
        "download_failed": False,
        "resolved": False,
        "reference_kb": 0,
    }

    # Ordered de-dup: the same item can legitimately appear once, but a client
    # bug repeating one must not double-count it.
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
        return None, stats

    # ONE batched, user-scoped query. The user_id filter is the security
    # boundary: the URL comes back only for the caller's own items, so another
    # user's photo can never be fetched (and StorageService is never handed an
    # attacker-chosen URL — no SSRF surface).
    try:
        res = await asyncio.to_thread(
            db.table("items")
            .select("id,source_image_url")
            .eq("user_id", user_id)
            .in_("id", requested_ids)
            .execute
        )
        rows = res.data or []
    except Exception as e:
        logger.warning(
            "Failed to fetch outfit source photo references",
            user_id=user_id,
            item_count=len(requested_ids),
            error=str(e),
        )
        stats["query_failed"] = True
        return None, stats

    url_counts: Counter = Counter()
    for row in rows:
        url = row.get("source_image_url")
        if url:
            url_counts[url] += 1

    stats["distinct_source_urls"] = len(url_counts)
    if not url_counts:
        return None, stats

    # Deterministic winner: the URL shared by the most items.
    ranked = sorted(url_counts.items(), key=lambda kv: (-kv[1], kv[0]))
    best_url, best_count = ranked[0]
    stats["best_coverage"] = best_count

    min_shared = max(1, settings.AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS)
    if best_count < min_shared:
        stats["below_min_shared"] = True
        return None, stats

    if sum(1 for _, count in ranked if count == best_count) > 1:
        stats["tie_skipped"] = True
        return None, stats

    max_images = max(0, settings.AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES)
    if max_images < 1:
        return None, stats

    stats["candidate_selected"] = True

    try:
        async with REFERENCE_DOWNLOAD_SEMAPHORE:
            raw = await StorageService.download_to_base64(best_url)
        if not raw:
            stats["download_failed"] = True
            return None, stats
        # PIL work is CPU-bound - off the event loop, as elsewhere.
        image_base64 = await asyncio.to_thread(downscale_base64_image, raw, edge)
    except Exception as e:
        logger.warning(
            "Outfit source photo reference failed to load",
            user_id=user_id,
            error=str(e),
        )
        stats["download_failed"] = True
        return None, stats

    stats["resolved"] = True
    stats["reference_kb"] = len(image_base64) // 1024
    return image_base64, stats
