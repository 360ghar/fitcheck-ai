"""
Orchestration for social URL import queue.
"""

from __future__ import annotations

import asyncio
import base64
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from app.agents.image_generation_agent import get_image_generation_agent
from app.agents.item_extraction_agent import get_item_extraction_agent
from app.core.exceptions import (
    SocialImportAuthRequiredError,
    SocialImportJobNotFoundError,
)
from app.models.social_import import (
    SocialImportItemStatus,
    SocialImportJobStatus,
    SocialImportPhotoStatus,
    SocialPlatform,
)
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.social_auth_service import SocialAuthService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_scraper_service import SocialScraperService
from app.services.storage_service import StorageService
from app.services.vector_service import get_vector_service


class SocialImportPipelineService:
    """Coordinates discovery, processing, and per-photo approval queueing."""

    _tasks: Dict[str, asyncio.Task] = {}
    _locks: Dict[str, asyncio.Lock] = {}
    _task_lock: asyncio.Lock = asyncio.Lock()

    def __init__(self, *, user_id: str, db):
        self.user_id = user_id
        self.db = db

    @classmethod
    def _job_lock(cls, job_id: str) -> asyncio.Lock:
        lock = cls._locks.get(job_id)
        if not lock:
            lock = asyncio.Lock()
            cls._locks[job_id] = lock
        return lock

    @classmethod
    async def schedule_job(
        cls, service: "SocialImportPipelineService", job_id: str
    ) -> None:
        async with cls._task_lock:
            existing = cls._tasks.get(job_id)
            if existing and not existing.done():
                return
            cls._tasks[job_id] = asyncio.create_task(service.run(job_id))

    @classmethod
    async def cancel_scheduled_job(cls, job_id: str) -> None:
        async with cls._task_lock:
            task = cls._tasks.pop(job_id, None)
            if task and not task.done():
                task.cancel()

    async def _cleanup_job_resources(self, job_id: str) -> None:
        """Clean up task and lock resources for a job."""
        async with self._task_lock:
            self._tasks.pop(job_id, None)
            self._locks.pop(job_id, None)

    async def run(self, job_id: str) -> None:
        lock = self._job_lock(job_id)
        async with lock:
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                await self._cleanup_job_resources(job_id)
                return

            status = job.get("status")
            if status in {
                SocialImportJobStatus.COMPLETED.value,
                SocialImportJobStatus.CANCELLED.value,
                SocialImportJobStatus.FAILED.value,
            }:
                await self._cleanup_job_resources(job_id)
                return

            try:
                if not job.get("discovery_completed"):
                    await self._discover_all_photos(job_id)
                    job = await SocialImportJobStore.get_job(
                        self.db, job_id=job_id, user_id=self.user_id
                    )
                    if not job:
                        await self._cleanup_job_resources(job_id)
                        return

                if job.get("status") == SocialImportJobStatus.AWAITING_AUTH.value:
                    return

                await self._run_queue(job_id)
            except SocialImportAuthRequiredError:
                # Job already moved to awaiting_auth and should resume after auth submission.
                return
            except asyncio.CancelledError:
                raise
            except Exception as e:
                await SocialImportJobStore.set_job_status(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    status=SocialImportJobStatus.FAILED,
                    error_message=str(e),
                )
                await SocialImportEventService.publish(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    event_type="job_failed",
                    payload={"job_id": job_id, "error": str(e)},
                )
            finally:
                # Clean up task reference after job finishes
                async with self._task_lock:
                    self._tasks.pop(job_id, None)

    async def _discover_all_photos(self, job_id: str) -> None:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            raise SocialImportJobNotFoundError(job_id)

        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.DISCOVERING,
            error_message=None,
        )
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="job_updated",
            payload={
                "job_id": job_id,
                "status": SocialImportJobStatus.DISCOVERING.value,
            },
        )

        cursor: Optional[str] = None
        ordinal = int(job.get("discovered_photos") or 0) + 1

        while True:
            auth_session = await SocialAuthService.get_active_session(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            result = await SocialScraperService.discover_profile_photos(
                normalized_url=job["normalized_url"],
                platform=SocialPlatform(job["platform"]),
                auth_session=auth_session,
                cursor=cursor,
            )

            if result.requires_auth:
                await SocialImportJobStore.update_job(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    updates={
                        "status": SocialImportJobStatus.AWAITING_AUTH.value,
                        "auth_required": True,
                        "error_message": None,
                    },
                )
                await SocialImportEventService.publish(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    event_type="auth_required",
                    payload={
                        "job_id": job_id,
                        "status": SocialImportJobStatus.AWAITING_AUTH.value,
                        "message": "Login required to continue importing this profile",
                    },
                )
                raise SocialImportAuthRequiredError()

            inserted = await SocialImportJobStore.add_discovered_photos(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                start_ordinal=ordinal,
                photos=[photo.model_dump() for photo in result.photos],
            )
            ordinal += len(inserted)

            if inserted:
                await SocialImportEventService.publish(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    event_type="photo_discovered",
                    payload={
                        "job_id": job_id,
                        "count": len(inserted),
                        "discovered_photos": ordinal - 1,
                    },
                )

            if result.exhausted:
                break

            cursor = result.next_cursor
            if not cursor:
                break

        await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "discovery_completed": True,
                "auth_required": False,
                "status": SocialImportJobStatus.PROCESSING.value,
            },
        )
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="job_updated",
            payload={
                "job_id": job_id,
                "status": SocialImportJobStatus.PROCESSING.value,
                "discovery_completed": True,
            },
        )

    async def _run_queue(self, job_id: str) -> None:
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.PROCESSING,
            error_message=None,
        )

        # Keep pumping until we are blocked on user review/auth or completed.
        while True:
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                return

            if job.get("status") in {
                SocialImportJobStatus.CANCELLED.value,
                SocialImportJobStatus.FAILED.value,
                SocialImportJobStatus.AWAITING_AUTH.value,
                SocialImportJobStatus.PAUSED_RATE_LIMITED.value,
            }:
                return

            slots = await SocialImportJobStore.get_slots(
                self.db, job_id=job_id, user_id=self.user_id
            )
            awaiting = slots["awaiting"]
            buffered = slots["buffered"]
            processing = slots["processing"]

            if processing:
                await self._process_single_photo(job_id, processing)
                continue

            if awaiting and buffered:
                # Queue full: one awaiting, one preprocessed. Wait for user decision.
                await self._sync_job_counters(job_id)
                return

            if not awaiting and buffered:
                promoted = await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=buffered["id"],
                    updates={
                        "status": SocialImportPhotoStatus.AWAITING_REVIEW.value,
                    },
                )
                promoted_full = await SocialImportJobStore.get_photo_with_items(
                    self.db,
                    job_id=job_id,
                    photo=promoted,
                    user_id=self.user_id,
                )
                await SocialImportEventService.publish(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    event_type="photo_ready_for_review",
                    payload={"job_id": job_id, "photo": promoted_full},
                )
                awaiting = promoted

            if not awaiting:
                claimed = await SocialImportJobStore.claim_next_queued_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                )
                if claimed:
                    await self._process_single_photo(job_id, claimed)
                    continue

            if awaiting and not buffered:
                # We can process one photo in background while user reviews current one.
                claimed = await SocialImportJobStore.claim_next_queued_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                )
                if claimed:
                    await self._process_single_photo(job_id, claimed)
                    continue

            done = await self._is_job_complete(job_id)
            if done:
                await self._complete_job(job_id)
                return

            await self._sync_job_counters(job_id)
            return

    async def _process_single_photo(self, job_id: str, photo: Dict[str, Any]) -> None:
        photo_id = photo["id"]
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="photo_processing_started",
            payload={
                "job_id": job_id,
                "photo_id": photo_id,
                "ordinal": photo.get("ordinal"),
            },
        )

        try:
            extraction_check = await AISettingsService.check_rate_limit(
                user_id=self.user_id,
                operation_type="extraction",
                db=self.db,
                count=1,
            )
            if not extraction_check["allowed"]:
                await self._pause_for_rate_limit(job_id, "extraction")
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={"status": SocialImportPhotoStatus.QUEUED.value},
                )
                return

            image_base64 = await SocialScraperService.fetch_photo_as_base64(
                photo["source_photo_url"]
            )
            extraction_agent = await get_item_extraction_agent(
                user_id=self.user_id, db=self.db
            )
            extraction_result = await extraction_agent.extract_multiple_items(
                image_base64=image_base64
            )
            raw_items = extraction_result.get("items") or []
            await AISettingsService.increment_usage(
                user_id=self.user_id,
                operation_type="extraction",
                db=self.db,
                count=1,
            )

            if not raw_items:
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={
                        "status": SocialImportPhotoStatus.FAILED.value,
                        "error_message": "No clothing items detected in photo",
                        "processing_completed_at": datetime.now(
                            timezone.utc
                        ).isoformat(),
                    },
                )
                await SocialImportEventService.publish(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    event_type="photo_failed",
                    payload={
                        "job_id": job_id,
                        "photo_id": photo_id,
                        "error": "No items detected",
                    },
                )
                await self._sync_job_counters(job_id)
                return

            generation_check = await AISettingsService.check_rate_limit(
                user_id=self.user_id,
                operation_type="generation",
                db=self.db,
                count=len(raw_items),
            )
            if not generation_check["allowed"]:
                await self._pause_for_rate_limit(job_id, "generation")
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={"status": SocialImportPhotoStatus.QUEUED.value},
                )
                return

            generation_agent = await get_image_generation_agent(
                user_id=self.user_id, db=self.db
            )
            processed_items: List[Dict[str, Any]] = []
            generation_success_count = 0

            for item in raw_items:
                temp_id = item.get("temp_id") or f"item-{uuid.uuid4().hex[:8]}"
                item_description = (
                    item.get("detailed_description")
                    or f"{(item.get('colors') or [''])[0]} {item.get('sub_category') or item.get('category') or 'clothing'}".strip()
                )
                try:
                    generated = await generation_agent.generate_product_image(
                        item_description=item_description,
                        category=item.get("category") or "other",
                        sub_category=item.get("sub_category"),
                        colors=item.get("colors") or [],
                        material=item.get("material"),
                        background="white",
                        view_angle="front",
                        include_shadows=False,
                    )

                    image_bytes = base64.b64decode(generated.image_base64)
                    uploaded = await StorageService.upload_temp_generated_image(
                        db=self.db,
                        user_id=self.user_id,
                        file_data=image_bytes,
                        source="social-import",
                    )
                    generation_success_count += 1
                    processed_items.append(
                        {
                            "temp_id": temp_id,
                            "name": self._suggest_item_name(item),
                            "category": item.get("category") or "other",
                            "sub_category": item.get("sub_category"),
                            "colors": item.get("colors") or [],
                            "material": item.get("material"),
                            "pattern": item.get("pattern"),
                            "brand": item.get("brand"),
                            "confidence": item.get("confidence") or 0,
                            "bounding_box": item.get("bounding_box"),
                            "detailed_description": item.get("detailed_description"),
                            "generated_image_url": uploaded.get("image_url"),
                            "generated_thumbnail_url": uploaded.get("thumbnail_url"),
                            "generated_storage_path": uploaded.get("storage_path"),
                            "status": SocialImportItemStatus.GENERATED.value,
                        }
                    )
                except Exception as generation_error:
                    processed_items.append(
                        {
                            "temp_id": temp_id,
                            "name": self._suggest_item_name(item),
                            "category": item.get("category") or "other",
                            "sub_category": item.get("sub_category"),
                            "colors": item.get("colors") or [],
                            "material": item.get("material"),
                            "pattern": item.get("pattern"),
                            "brand": item.get("brand"),
                            "confidence": item.get("confidence") or 0,
                            "bounding_box": item.get("bounding_box"),
                            "detailed_description": item.get("detailed_description"),
                            "generation_error": str(generation_error),
                            "status": SocialImportItemStatus.FAILED.value,
                        }
                    )

            if generation_success_count > 0:
                await AISettingsService.increment_usage(
                    user_id=self.user_id,
                    operation_type="generation",
                    db=self.db,
                    count=generation_success_count,
                )

            await SocialImportJobStore.upsert_photo_items(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
                items=processed_items,
            )

            slots = await SocialImportJobStore.get_slots(
                self.db, job_id=job_id, user_id=self.user_id
            )
            target_status = (
                SocialImportPhotoStatus.BUFFERED_READY
                if slots["awaiting"]
                else SocialImportPhotoStatus.AWAITING_REVIEW
            )

            updated_photo = await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": target_status.value,
                    "processing_completed_at": datetime.now(timezone.utc).isoformat(),
                    "error_message": None,
                },
            )
            updated_photo = await SocialImportJobStore.get_photo_with_items(
                self.db,
                job_id=job_id,
                photo=updated_photo,
                user_id=self.user_id,
            )

            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type=(
                    "photo_buffered_ready"
                    if target_status == SocialImportPhotoStatus.BUFFERED_READY
                    else "photo_ready_for_review"
                ),
                payload={"job_id": job_id, "photo": updated_photo},
            )
            await self._sync_job_counters(job_id)

        except Exception as e:
            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.FAILED.value,
                    "error_message": str(e),
                    "processing_completed_at": datetime.now(timezone.utc).isoformat(),
                },
            )
            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="photo_failed",
                payload={"job_id": job_id, "photo_id": photo_id, "error": str(e)},
            )
            await self._sync_job_counters(job_id)

    async def approve_photo(self, job_id: str, photo_id: str) -> Dict[str, Any]:
        lock = self._job_lock(job_id)
        async with lock:
            photo = await SocialImportJobStore.get_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
            )
            if not photo:
                raise SocialImportJobNotFoundError(job_id)

            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
            )
            saved_count = 0
            for item in items:
                if item.get("status") in {
                    SocialImportItemStatus.FAILED.value,
                    SocialImportItemStatus.DISCARDED.value,
                    SocialImportItemStatus.SAVED.value,
                }:
                    continue
                saved_item_id = await self._save_item_from_social_item(item)
                if saved_item_id:
                    saved_count += 1
                    await SocialImportJobStore.update_item(
                        self.db,
                        job_id=job_id,
                        photo_id=photo_id,
                        item_id=item["id"],
                        user_id=self.user_id,
                        updates={
                            "status": SocialImportItemStatus.SAVED.value,
                            "saved_item_id": saved_item_id,
                        },
                    )

            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.APPROVED.value,
                    "reviewed_at": datetime.now(timezone.utc).isoformat(),
                },
            )

            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="photo_approved",
                payload={
                    "job_id": job_id,
                    "photo_id": photo_id,
                    "saved_count": saved_count,
                },
            )

            await self._promote_buffered_if_available(job_id)
            await self._sync_job_counters(job_id)

        await self.schedule_job(self, job_id)
        return {"saved_count": saved_count}

    async def reject_photo(self, job_id: str, photo_id: str) -> Dict[str, Any]:
        lock = self._job_lock(job_id)
        async with lock:
            photo = await SocialImportJobStore.get_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
            )
            if not photo:
                raise SocialImportJobNotFoundError(job_id)

            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
            )
            temp_paths = [
                item.get("generated_storage_path")
                for item in items
                if item.get("generated_storage_path")
            ]
            await StorageService.cleanup_temp_images(self.db, temp_paths)

            await SocialImportJobStore.set_items_status_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
                status=SocialImportItemStatus.DISCARDED,
            )

            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.REJECTED.value,
                    "reviewed_at": datetime.now(timezone.utc).isoformat(),
                },
            )

            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="photo_rejected",
                payload={"job_id": job_id, "photo_id": photo_id},
            )

            await self._promote_buffered_if_available(job_id)
            await self._sync_job_counters(job_id)

        await self.schedule_job(self, job_id)
        return {"rejected": True}

    async def patch_item(
        self,
        job_id: str,
        photo_id: str,
        item_id: str,
        updates: Dict[str, Any],
    ) -> Optional[Dict[str, Any]]:
        payload = dict(updates)
        payload["status"] = SocialImportItemStatus.EDITED.value
        return await SocialImportJobStore.update_item(
            self.db,
            job_id=job_id,
            photo_id=photo_id,
            item_id=item_id,
            user_id=self.user_id,
            updates=payload,
        )

    async def cancel_job(self, job_id: str) -> None:
        lock = self._job_lock(job_id)
        async with lock:
            await SocialImportJobStore.set_job_status(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                status=SocialImportJobStatus.CANCELLED,
                completed=True,
            )
            await self._cleanup_unsaved_temp_assets(job_id)
            await SocialImportJobStore.delete_job_artifacts(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="job_cancelled",
                payload={"job_id": job_id},
            )
        await self.cancel_scheduled_job(job_id)

    async def accept_oauth_auth(self, job_id: str, payload: Dict[str, Any]) -> None:
        lock = self._job_lock(job_id)
        async with lock:
            job = await SocialImportJobStore.get_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            if not job:
                raise SocialImportJobNotFoundError(job_id)

            await SocialAuthService.store_oauth_session(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                provider_access_token=payload["provider_access_token"],
                provider_refresh_token=payload.get("provider_refresh_token"),
                provider_user_id=payload.get("provider_user_id"),
                provider_page_access_token=payload.get("provider_page_access_token"),
                provider_page_id=payload.get("provider_page_id"),
                provider_username=payload.get("provider_username"),
                expires_at=payload.get("expires_at"),
            )
            updated = await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={
                    "status": SocialImportJobStatus.PROCESSING.value,
                    "auth_required": False,
                },
            )
            if not updated:
                raise SocialImportJobNotFoundError(job_id)
            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="auth_accepted",
                payload={"job_id": job_id, "auth_type": "oauth"},
            )
        await self.schedule_job(self, job_id)

    async def accept_scraper_auth(self, job_id: str, payload: Dict[str, Any]) -> None:
        lock = self._job_lock(job_id)
        async with lock:
            job = await SocialImportJobStore.get_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            if not job:
                raise SocialImportJobNotFoundError(job_id)

            await SocialAuthService.store_scraper_session(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                username=payload["username"],
                password=payload["password"],
                otp_code=payload.get("otp_code"),
            )
            updated = await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={
                    "status": SocialImportJobStatus.PROCESSING.value,
                    "auth_required": False,
                },
            )
            if not updated:
                raise SocialImportJobNotFoundError(job_id)
            await SocialImportEventService.publish(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                event_type="auth_accepted",
                payload={"job_id": job_id, "auth_type": "scraper"},
            )
        await self.schedule_job(self, job_id)

    async def get_status(self, job_id: str) -> Dict[str, Any]:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            raise SocialImportJobNotFoundError(job_id)

        if job.get("status") == SocialImportJobStatus.PAUSED_RATE_LIMITED.value:
            resumed = await self._try_resume_rate_limited_job(job_id)
            if resumed:
                job = await SocialImportJobStore.get_job(
                    self.db, job_id=job_id, user_id=self.user_id
                )
                if not job:
                    raise SocialImportJobNotFoundError(job_id)

        slots = await SocialImportJobStore.get_slots(
            self.db, job_id=job_id, user_id=self.user_id
        )
        awaiting = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["awaiting"],
            user_id=self.user_id,
        )
        buffered = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["buffered"],
            user_id=self.user_id,
        )
        processing = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["processing"],
            user_id=self.user_id,
        )
        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )

        return {
            "id": job["id"],
            "status": job["status"],
            "platform": job["platform"],
            "source_url": job["source_url"],
            "normalized_url": job["normalized_url"],
            "total_photos": job.get("total_photos") or 0,
            "discovered_photos": job.get("discovered_photos") or 0,
            "processed_photos": job.get("processed_photos") or 0,
            "approved_photos": job.get("approved_photos") or 0,
            "rejected_photos": job.get("rejected_photos") or 0,
            "failed_photos": job.get("failed_photos") or 0,
            "auth_required": bool(job.get("auth_required")),
            "discovery_completed": bool(job.get("discovery_completed")),
            "error_message": job.get("error_message"),
            "awaiting_review_photo": awaiting,
            "buffered_photo": buffered,
            "processing_photo": processing,
            "queued_count": counts.get(SocialImportPhotoStatus.QUEUED.value, 0),
        }

    async def _promote_buffered_if_available(self, job_id: str) -> None:
        slots = await SocialImportJobStore.get_slots(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if slots["awaiting"] or not slots["buffered"]:
            return

        promoted = await SocialImportJobStore.update_photo(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            photo_id=slots["buffered"]["id"],
            updates={"status": SocialImportPhotoStatus.AWAITING_REVIEW.value},
        )
        promoted = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=promoted,
            user_id=self.user_id,
        )
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="photo_ready_for_review",
            payload={"job_id": job_id, "photo": promoted},
        )

    async def _sync_job_counters(self, job_id: str) -> None:
        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )
        total_processed = (
            counts.get(SocialImportPhotoStatus.AWAITING_REVIEW.value, 0)
            + counts.get(SocialImportPhotoStatus.BUFFERED_READY.value, 0)
            + counts.get(SocialImportPhotoStatus.APPROVED.value, 0)
            + counts.get(SocialImportPhotoStatus.REJECTED.value, 0)
            + counts.get(SocialImportPhotoStatus.FAILED.value, 0)
            + counts.get(SocialImportPhotoStatus.PROCESSING.value, 0)
        )

        await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "processed_photos": total_processed,
                "approved_photos": counts.get(
                    SocialImportPhotoStatus.APPROVED.value, 0
                ),
                "rejected_photos": counts.get(
                    SocialImportPhotoStatus.REJECTED.value, 0
                ),
                "failed_photos": counts.get(SocialImportPhotoStatus.FAILED.value, 0),
                "total_photos": sum(counts.values()),
            },
        )

        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="job_updated",
            payload={
                "job_id": job_id,
                "processed_photos": total_processed,
                "approved_photos": counts.get(
                    SocialImportPhotoStatus.APPROVED.value, 0
                ),
                "rejected_photos": counts.get(
                    SocialImportPhotoStatus.REJECTED.value, 0
                ),
                "failed_photos": counts.get(SocialImportPhotoStatus.FAILED.value, 0),
                "queued_count": counts.get(SocialImportPhotoStatus.QUEUED.value, 0),
            },
        )

    async def _pause_for_rate_limit(self, job_id: str, operation_type: str) -> None:
        message = self._build_rate_limit_pause_message(operation_type)
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.PAUSED_RATE_LIMITED,
            error_message=message,
        )
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="rate_limit_paused",
            payload={
                "job_id": job_id,
                "status": SocialImportJobStatus.PAUSED_RATE_LIMITED.value,
                "operation_type": operation_type,
                "message": message,
            },
        )

    async def _try_resume_rate_limited_job(self, job_id: str) -> bool:
        extraction_check = await AISettingsService.check_rate_limit(
            user_id=self.user_id,
            operation_type="extraction",
            db=self.db,
            count=1,
        )
        generation_check = await AISettingsService.check_rate_limit(
            user_id=self.user_id,
            operation_type="generation",
            db=self.db,
            count=1,
        )

        if not extraction_check.get("allowed") or not generation_check.get("allowed"):
            return False

        updated = await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "status": SocialImportJobStatus.PROCESSING.value,
                "error_message": None,
            },
        )
        if not updated:
            return False

        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="job_updated",
            payload={
                "job_id": job_id,
                "status": SocialImportJobStatus.PROCESSING.value,
                "message": "Daily limit reset detected. Resuming queued social import photos.",
            },
        )
        await self.schedule_job(self, job_id)
        return True

    @staticmethod
    def _build_rate_limit_pause_message(operation_type: str) -> str:
        op = operation_type.replace("_", " ")
        return (
            f"Daily {op} limit reached. Remaining photos stay queued and will auto-resume "
            "after the next daily reset. Refer friends to get Pro for free or upgrade to Pro "
            "for higher limits."
        )

    async def _is_job_complete(self, job_id: str) -> bool:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            return False
        if not job.get("discovery_completed"):
            return False

        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )
        return (
            counts.get(SocialImportPhotoStatus.QUEUED.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.PROCESSING.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.AWAITING_REVIEW.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.BUFFERED_READY.value, 0) == 0
        )

    async def _complete_job(self, job_id: str) -> None:
        await self._sync_job_counters(job_id)
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.COMPLETED,
            completed=True,
        )
        await self._cleanup_unsaved_temp_assets(job_id)
        await SocialImportJobStore.delete_job_artifacts(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
        )
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type="job_completed",
            payload={"job_id": job_id, "status": SocialImportJobStatus.COMPLETED.value},
        )

    async def _cleanup_unsaved_temp_assets(self, job_id: str) -> None:
        photos = await SocialImportJobStore.list_photos(
            self.db, job_id=job_id, user_id=self.user_id
        )
        temp_paths: List[str] = []
        for photo in photos:
            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo["id"],
                user_id=self.user_id,
            )
            for item in items:
                if item.get("status") != SocialImportItemStatus.SAVED.value:
                    storage_path = item.get("generated_storage_path")
                    if storage_path:
                        temp_paths.append(storage_path)
        if temp_paths:
            await StorageService.cleanup_temp_images(self.db, temp_paths)

    async def _save_item_from_social_item(
        self, social_item: Dict[str, Any]
    ) -> Optional[str]:
        storage_path = social_item.get("generated_storage_path")
        if not storage_path:
            return None

        promoted = await StorageService.promote_temp_image_to_item(
            db=self.db,
            user_id=self.user_id,
            temp_storage_path=storage_path,
            filename_hint=f"{social_item.get('temp_id') or 'generated'}.png",
        )

        item_id = str(uuid.uuid4())
        now_iso = datetime.now(timezone.utc).isoformat()
        item_data = {
            "id": item_id,
            "user_id": self.user_id,
            "name": social_item.get("name") or "Imported Item",
            "category": social_item.get("category") or "other",
            "sub_category": social_item.get("sub_category"),
            "brand": social_item.get("brand"),
            "colors": social_item.get("colors") or [],
            "style": None,
            "material": social_item.get("material"),
            "materials": [],
            "pattern": social_item.get("pattern"),
            "seasonal_tags": [],
            "occasion_tags": [],
            "size": None,
            "price": None,
            "purchase_date": None,
            "purchase_location": None,
            "tags": ["social-import"],
            "notes": "Imported from social profile",
            "condition": "clean",
            "is_favorite": False,
            "usage_times_worn": 0,
            "usage_last_worn": None,
            "cost_per_wear": None,
            "created_at": now_iso,
            "updated_at": now_iso,
            "is_deleted": False,
        }

        self.db.table("items").insert(item_data).execute()

        image_data = {
            "id": str(uuid.uuid4()),
            "item_id": item_id,
            "image_url": promoted["image_url"],
            "thumbnail_url": promoted["thumbnail_url"],
            "storage_path": promoted["storage_path"],
            "is_primary": True,
            "width": None,
            "height": None,
            "created_at": now_iso,
        }
        self.db.table("item_images").insert(image_data).execute()

        try:
            rate_check = await AISettingsService.check_rate_limit(
                user_id=self.user_id,
                operation_type="embedding",
                db=self.db,
            )
            if rate_check["allowed"]:
                embedding = await AIService.generate_item_embedding(
                    {**item_data, "images": [image_data]}
                )
                if embedding:
                    await AISettingsService.increment_usage(
                        user_id=self.user_id,
                        operation_type="embedding",
                        db=self.db,
                    )
                    vector_service = get_vector_service()
                    await vector_service.upsert_item(
                        item_id=item_id,
                        embedding=embedding,
                        metadata={
                            "user_id": self.user_id,
                            "category": item_data["category"],
                            "colors": item_data["colors"],
                            "brand": item_data.get("brand") or "",
                            "name": item_data["name"],
                        },
                    )
        except Exception:
            pass

        return item_id

    @staticmethod
    def _suggest_item_name(item: Dict[str, Any]) -> str:
        parts: List[str] = []
        colors = item.get("colors") or []
        if colors:
            parts.append(str(colors[0]).capitalize())
        sub_category = item.get("sub_category")
        category = item.get("category")
        if sub_category:
            parts.append(str(sub_category).replace("_", " ").title())
        elif category:
            parts.append(str(category).replace("_", " ").title())
        return " ".join(parts) or "Imported Item"
