"""
Persistence layer for social import jobs.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict, Iterable, List, Optional

from app.models.social_import import (
    SocialImportItemStatus,
    SocialImportJobStatus,
    SocialImportPhotoStatus,
)


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


class SocialImportJobStore:
    """Database operations for social import resources."""

    @staticmethod
    async def create_job(
        db,
        *,
        user_id: str,
        platform: str,
        source_url: str,
        normalized_url: str,
    ) -> Dict[str, Any]:
        payload = {
            "user_id": user_id,
            "platform": platform,
            "source_url": source_url,
            "normalized_url": normalized_url,
            "status": SocialImportJobStatus.CREATED.value,
            "created_at": _utc_now_iso(),
            "updated_at": _utc_now_iso(),
        }
        result = db.table("social_import_jobs").insert(payload).execute()
        rows = result.data or []
        if not rows:
            raise RuntimeError("Failed to create social import job")
        return rows[0]

    @staticmethod
    async def get_job(db, *, job_id: str, user_id: str) -> Optional[Dict[str, Any]]:
        result = (
            db.table("social_import_jobs")
            .select("*")
            .eq("id", job_id)
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @staticmethod
    async def update_job(
        db,
        *,
        job_id: str,
        user_id: str,
        updates: Dict[str, Any],
    ) -> Optional[Dict[str, Any]]:
        payload = dict(updates)
        payload["updated_at"] = _utc_now_iso()
        result = (
            db.table("social_import_jobs")
            .update(payload)
            .eq("id", job_id)
            .eq("user_id", user_id)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @classmethod
    async def set_job_status(
        cls,
        db,
        *,
        job_id: str,
        user_id: str,
        status: SocialImportJobStatus,
        error_message: Optional[str] = None,
        completed: bool = False,
    ) -> Optional[Dict[str, Any]]:
        updates: Dict[str, Any] = {
            "status": status.value,
            "error_message": error_message,
        }
        if completed:
            updates["completed_at"] = _utc_now_iso()
        return await cls.update_job(db, job_id=job_id, user_id=user_id, updates=updates)

    @staticmethod
    async def add_discovered_photos(
        db,
        *,
        job_id: str,
        user_id: str,
        start_ordinal: int,
        photos: List[Dict[str, Any]],
    ) -> List[Dict[str, Any]]:
        if not photos:
            return []

        rows: List[Dict[str, Any]] = []
        now_iso = _utc_now_iso()
        for idx, photo in enumerate(photos):
            rows.append(
                {
                    "job_id": job_id,
                    "user_id": user_id,
                    "ordinal": start_ordinal + idx,
                    "source_photo_id": photo.get("source_photo_id"),
                    "source_photo_url": photo["source_photo_url"],
                    "source_thumb_url": photo.get("source_thumb_url"),
                    "source_taken_at": photo.get("source_taken_at"),
                    "status": SocialImportPhotoStatus.QUEUED.value,
                    "metadata": photo.get("metadata") or {},
                    "created_at": now_iso,
                    "updated_at": now_iso,
                }
            )

        result = db.table("social_import_photos").insert(rows).execute()
        inserted = result.data or []

        job = await SocialImportJobStore.get_job(db, job_id=job_id, user_id=user_id)
        if job:
            discovered_total = int(job.get("discovered_photos") or 0) + len(inserted)
            total_photos = max(int(job.get("total_photos") or 0), discovered_total)
            await SocialImportJobStore.update_job(
                db,
                job_id=job_id,
                user_id=user_id,
                updates={
                    "discovered_photos": discovered_total,
                    "total_photos": total_photos,
                },
            )

        return inserted

    @staticmethod
    async def get_photo(
        db,
        *,
        job_id: str,
        user_id: str,
        photo_id: str,
    ) -> Optional[Dict[str, Any]]:
        result = (
            db.table("social_import_photos")
            .select("*")
            .eq("id", photo_id)
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @staticmethod
    async def list_photos(
        db,
        *,
        job_id: str,
        user_id: str,
        statuses: Optional[Iterable[SocialImportPhotoStatus]] = None,
        limit: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        query = (
            db.table("social_import_photos")
            .select("*")
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .order("ordinal")
        )

        if statuses:
            status_values = [status.value for status in statuses]
            if len(status_values) == 1:
                query = query.eq("status", status_values[0])
            else:
                query = query.in_("status", status_values)

        if limit is not None:
            query = query.limit(limit)

        result = query.execute()
        return result.data or []

    @staticmethod
    async def update_photo(
        db,
        *,
        job_id: str,
        user_id: str,
        photo_id: str,
        updates: Dict[str, Any],
    ) -> Optional[Dict[str, Any]]:
        payload = dict(updates)
        payload["updated_at"] = _utc_now_iso()
        result = (
            db.table("social_import_photos")
            .update(payload)
            .eq("id", photo_id)
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @staticmethod
    async def claim_next_queued_photo(
        db,
        *,
        job_id: str,
        user_id: str,
    ) -> Optional[Dict[str, Any]]:
        queued = await SocialImportJobStore.list_photos(
            db,
            job_id=job_id,
            user_id=user_id,
            statuses=[SocialImportPhotoStatus.QUEUED],
            limit=1,
        )
        if not queued:
            return None

        candidate = queued[0]
        result = (
            db.table("social_import_photos")
            .update(
                {
                    "status": SocialImportPhotoStatus.PROCESSING.value,
                    "processing_started_at": _utc_now_iso(),
                    "updated_at": _utc_now_iso(),
                }
            )
            .eq("id", candidate["id"])
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .eq("status", SocialImportPhotoStatus.QUEUED.value)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @staticmethod
    async def get_slots(
        db,
        *,
        job_id: str,
        user_id: str,
    ) -> Dict[str, Optional[Dict[str, Any]]]:
        rows = await SocialImportJobStore.list_photos(
            db,
            job_id=job_id,
            user_id=user_id,
            statuses=[
                SocialImportPhotoStatus.AWAITING_REVIEW,
                SocialImportPhotoStatus.BUFFERED_READY,
                SocialImportPhotoStatus.PROCESSING,
            ],
        )

        awaiting = next((row for row in rows if row["status"] == SocialImportPhotoStatus.AWAITING_REVIEW.value), None)
        buffered = next((row for row in rows if row["status"] == SocialImportPhotoStatus.BUFFERED_READY.value), None)
        processing = next((row for row in rows if row["status"] == SocialImportPhotoStatus.PROCESSING.value), None)
        return {"awaiting": awaiting, "buffered": buffered, "processing": processing}

    @staticmethod
    async def count_by_status(
        db,
        *,
        job_id: str,
        user_id: str,
    ) -> Dict[str, int]:
        rows = await SocialImportJobStore.list_photos(db, job_id=job_id, user_id=user_id)
        counts: Dict[str, int] = {}
        for row in rows:
            status = row.get("status") or "unknown"
            counts[status] = counts.get(status, 0) + 1
        return counts

    @staticmethod
    async def upsert_photo_items(
        db,
        *,
        job_id: str,
        photo_id: str,
        user_id: str,
        items: List[Dict[str, Any]],
    ) -> List[Dict[str, Any]]:
        if not items:
            return []

        rows: List[Dict[str, Any]] = []
        now_iso = _utc_now_iso()
        for item in items:
            rows.append(
                {
                    "job_id": job_id,
                    "photo_id": photo_id,
                    "user_id": user_id,
                    "temp_id": item["temp_id"],
                    "name": item.get("name"),
                    "category": item.get("category") or "other",
                    "sub_category": item.get("sub_category"),
                    "colors": item.get("colors") or [],
                    "material": item.get("material"),
                    "pattern": item.get("pattern"),
                    "brand": item.get("brand"),
                    "confidence": item.get("confidence") or 0,
                    "bounding_box": item.get("bounding_box"),
                    "detailed_description": item.get("detailed_description"),
                    "generated_image_url": item.get("generated_image_url"),
                    "generated_thumbnail_url": item.get("generated_thumbnail_url") or item.get("generated_image_url"),
                    "generated_storage_path": item.get("generated_storage_path"),
                    "generation_error": item.get("generation_error"),
                    "status": item.get("status") or SocialImportItemStatus.GENERATED.value,
                    "metadata": item.get("metadata") or {},
                    "created_at": now_iso,
                    "updated_at": now_iso,
                }
            )

        result = db.table("social_import_items").upsert(
            rows,
            on_conflict="job_id,temp_id",
        ).execute()
        return result.data or []

    @staticmethod
    async def list_items_for_photo(
        db,
        *,
        job_id: str,
        photo_id: str,
        user_id: str,
    ) -> List[Dict[str, Any]]:
        result = (
            db.table("social_import_items")
            .select("*")
            .eq("job_id", job_id)
            .eq("photo_id", photo_id)
            .eq("user_id", user_id)
            .order("created_at")
            .execute()
        )
        return result.data or []

    @staticmethod
    async def update_item(
        db,
        *,
        job_id: str,
        photo_id: str,
        item_id: str,
        user_id: str,
        updates: Dict[str, Any],
    ) -> Optional[Dict[str, Any]]:
        payload = dict(updates)
        payload["updated_at"] = _utc_now_iso()
        result = (
            db.table("social_import_items")
            .update(payload)
            .eq("id", item_id)
            .eq("job_id", job_id)
            .eq("photo_id", photo_id)
            .eq("user_id", user_id)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    @staticmethod
    async def set_items_status_for_photo(
        db,
        *,
        job_id: str,
        photo_id: str,
        user_id: str,
        status: SocialImportItemStatus,
    ) -> None:
        (
            db.table("social_import_items")
            .update({"status": status.value, "updated_at": _utc_now_iso()})
            .eq("job_id", job_id)
            .eq("photo_id", photo_id)
            .eq("user_id", user_id)
            .execute()
        )

    @staticmethod
    async def create_event(
        db,
        *,
        job_id: str,
        user_id: str,
        event_type: str,
        payload: Dict[str, Any],
    ) -> Dict[str, Any]:
        result = (
            db.table("social_import_events")
            .insert(
                {
                    "job_id": job_id,
                    "user_id": user_id,
                    "event_type": event_type,
                    "payload": payload,
                    "created_at": _utc_now_iso(),
                }
            )
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else {}

    @staticmethod
    async def list_events(
        db,
        *,
        job_id: str,
        user_id: str,
        after_id: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        query = (
            db.table("social_import_events")
            .select("*")
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .order("id")
        )
        if after_id is not None:
            query = query.gt("id", after_id)

        result = query.execute()
        return result.data or []

    @staticmethod
    async def delete_job_artifacts(
        db,
        *,
        job_id: str,
        user_id: str,
    ) -> None:
        (
            db.table("social_import_auth_sessions")
            .delete()
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .execute()
        )

    @staticmethod
    async def get_photo_with_items(
        db,
        *,
        job_id: str,
        photo: Optional[Dict[str, Any]],
        user_id: str,
    ) -> Optional[Dict[str, Any]]:
        if not photo:
            return None

        items = await SocialImportJobStore.list_items_for_photo(
            db,
            job_id=job_id,
            photo_id=photo["id"],
            user_id=user_id,
        )
        enriched = dict(photo)
        enriched["items"] = items
        return enriched
