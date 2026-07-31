"""
Batch Extraction Service.

Orchestrates the batch extraction and generation pipeline.
Extraction runs in parallel across images; product-image generation starts as
soon as each image's items are detected (overlapped with remaining extracts).
"""

import asyncio
import base64
import logging
from app.utils.datetime_util import utcnow_iso
from typing import Any, Awaitable, Callable, Dict, List, Optional

import httpx

from app.agents.item_extraction_agent import get_item_extraction_agent
from app.agents.image_generation_agent import get_image_generation_agent
from app.core.concurrency import EXTRACTION_SEMAPHORE, GENERATION_SEMAPHORE
from app.core.config import settings
from app.core.exceptions import AIServiceError
from app.services.batch_job_service import (
    BatchJob,
    BatchJobService,
    BatchJobStatus,
    DetectedItemData,
)
from app.services.storage_service import StorageService
from app.utils.image_processing import downscale_base64_image, resolve_product_reference_image
from app.utils.retry import is_retryable_error, with_retry

logger = logging.getLogger(__name__)

# EXTRACTION_SEMAPHORE / GENERATION_SEMAPHORE live in app.core.concurrency so
# they are shared process-wide across all concurrent jobs AND the variation
# fan-out in image_generation_agent. Cap is configurable via
# AI_EXTRACTION_CONCURRENCY / AI_GENERATION_CONCURRENCY env vars (default 30).

OnItemsReady = Optional[Callable[[List[DetectedItemData]], Awaitable[None]]]


class BatchExtractionService:
    """Orchestrates the batch extraction and generation pipeline."""

    def __init__(self, user_id: str, db):
        self.user_id = user_id
        self.db = db
        # Set when an image fails with an unrecoverable upstream capacity/quota
        # error (both Gemini and the Agnes fallback failed). Subsequent images
        # waiting on EXTRACTION_SEMAPHORE see this and skip without burning more
        # guaranteed-to-fail VLM calls. Per-instance == per-job (the service is
        # constructed fresh for each pipeline run).
        self._extraction_capacity_exhausted = False

    async def run_pipeline(self, job: BatchJob) -> None:
        """
        Run extract + optional generate with overlap.

        Extraction runs for all images in parallel. As soon as items from any
        image are ready, they are enqueued for product-image generation so gen
        does not wait for every extract to finish.
        """
        gen_queue: Optional[asyncio.Queue] = None
        consumer_task: Optional[asyncio.Task] = None

        async def stop_consumer(*, cancel: bool) -> None:
            """Sentinel the queue and await the consumer; cancel aborts in-flight gens."""
            if gen_queue is not None:
                try:
                    await gen_queue.put(None)
                except Exception:
                    # Cleanup path - queue may already be closed.
                    pass
            if consumer_task is None:
                return
            if cancel and not consumer_task.done():
                consumer_task.cancel()
            try:
                await consumer_task
            except (asyncio.CancelledError, Exception):
                pass

        try:
            if job.auto_generate:
                gen_queue = asyncio.Queue()
                consumer_task = asyncio.create_task(
                    self._generation_consumer(job, gen_queue)
                )

            async def on_items_ready(items: List[DetectedItemData]) -> None:
                if gen_queue is not None and items:
                    await gen_queue.put(items)

            await self._run_extraction_phase(
                job, consumer_task=consumer_task, on_items_ready=on_items_ready
            )

            # Extraction is fully done: only now advance the status to
            # GENERATING (polling clients assume EXTRACTING always precedes it).
            if (
                consumer_task is not None
                and job.total_items > 0
                and not job.is_cancelled()
            ):
                await BatchJobService.update_status(
                    job.job_id, BatchJobStatus.GENERATING
                )

            # Drain generation to completion (the consumer exits early on cancel).
            await stop_consumer(cancel=False)

            if not job.is_cancelled():
                await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
                await self._broadcast_job_complete(job)
                # Keep generated_image_base64 on items until job TTL so
                # GET status / Flutter poll fallback still works. Free the
                # SSE replay buffer which duplicates those payloads.
                await BatchJobService.clear_event_history(job.job_id)

        except asyncio.CancelledError:
            # Shutdown / task cancellation: stop the consumer (which cancels its
            # in-flight generation tasks and awaits them) before unwinding.
            await stop_consumer(cancel=True)
            raise
        except Exception as e:
            logger.error(
                "Batch pipeline failed",
                extra={"job_id": job.job_id, "error": str(e)},
            )
            await stop_consumer(cancel=True)
            error_msg = str(e)
            # If the consumer itself crashed, retrieve and surface its root
            # cause too (also avoids asyncio's "exception never retrieved").
            if (
                consumer_task is not None
                and consumer_task.done()
                and not consumer_task.cancelled()
            ):
                consumer_exc = consumer_task.exception()
                if consumer_exc is not None and consumer_exc is not e:
                    error_msg = f"{e} (generation consumer also failed: {consumer_exc})"
            await BatchJobService.set_error(job.job_id, error_msg)
            await BatchJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": error_msg,
                "timestamp": utcnow_iso(),
            })
            await BatchJobService.release_image_payloads(job.job_id)
            await BatchJobService.clear_event_history(job.job_id)

    async def _run_extraction_phase(
        self,
        job: BatchJob,
        consumer_task: Optional[asyncio.Task] = None,
        on_items_ready: OnItemsReady = None,
    ) -> None:
        """
        Extract items from ALL images in parallel.

        When on_items_ready is set, invokes it with newly detected items so
        generation can start immediately (overlap).
        """
        await BatchJobService.update_status(job.job_id, BatchJobStatus.EXTRACTING)

        await BatchJobService.broadcast_event(job.job_id, "extraction_started", {
            "job_id": job.job_id,
            "total_images": job.total_images,
            "timestamp": utcnow_iso(),
        })

        agent = await get_item_extraction_agent(user_id=self.user_id, db=self.db)
        user_profile_image_base64 = await self._fetch_user_avatar_base64()

        tasks = []
        for image_id, image_data in job.images.items():
            task = asyncio.create_task(
                self._extract_single_image(
                    job,
                    image_id,
                    image_data.image_base64,
                    agent,
                    user_profile_image_base64=user_profile_image_base64,
                    consumer_task=consumer_task,
                    on_items_ready=on_items_ready,
                )
            )
            tasks.append(task)

        await asyncio.gather(*tasks, return_exceptions=True)

        await BatchJobService.broadcast_event(job.job_id, "all_extractions_complete", {
            "job_id": job.job_id,
            "total_images": job.total_images,
            "successful": len(job.extraction_completed),
            "failed": len(job.extraction_failed),
            "total_items_detected": job.total_items,
            "timestamp": utcnow_iso(),
        })

        # If the generation consumer already died, surface its real error now
        # instead of reporting a failed job with no useful cause.
        if (
            consumer_task is not None
            and consumer_task.done()
            and not consumer_task.cancelled()
            and consumer_task.exception() is not None
        ):
            raise consumer_task.exception()

        # Cache extraction results for single-image jobs (24-hour TTL)
        if job.total_images == 1 and job.detected_items:
            await self._cache_extraction_results(job)

        # Source base64 is only needed for extraction (and the single-image
        # cache key above). Drop it immediately so concurrent jobs do not
        # pin tens of MB of RAM until the job TTL expires.
        await BatchJobService.release_image_payloads(job.job_id)

    async def _skip_due_to_capacity(self, job: BatchJob, image_id: str) -> bool:
        """Mark an image skipped when upstream AI capacity is exhausted.

        Shared by the semaphore-entry check and the pre-call re-check: tasks
        admitted concurrently can all pass the entry check before the flag is
        set by the first failure, so the re-check guarantees only truly
        in-flight calls reach the provider.
        """
        if not self._extraction_capacity_exhausted:
            return False
        skip_msg = "Skipped: AI service capacity exhausted"
        await BatchJobService.mark_extraction_failed(job.job_id, image_id, skip_msg)
        await BatchJobService.broadcast_event(job.job_id, "image_extraction_failed", {
            "job_id": job.job_id,
            "image_id": image_id,
            "error": skip_msg,
            "code": "AI_SERVICE_ERROR",
            "error_kind": "upstream_quota",
            "completed_count": len(job.extraction_completed),
            "failed_count": len(job.extraction_failed),
            "total_images": job.total_images,
            "timestamp": utcnow_iso(),
        })
        return True

    async def _extract_single_image(
        self,
        job: BatchJob,
        image_id: str,
        image_base64: str,
        agent,
        user_profile_image_base64: Optional[str] = None,
        consumer_task: Optional[asyncio.Task] = None,
        on_items_ready: OnItemsReady = None,
    ) -> List[Dict[str, Any]]:
        """Extract items from a single image with semaphore and retry."""
        # Adopt a durable CANCELLED state persisted by a non-owner worker so
        # queued extractions stop promptly instead of waiting for the next
        # status flush.
        await BatchJobService.check_durable_cancel(job)
        if job.is_cancelled():
            return []
        if consumer_task is not None and consumer_task.done():
            # The generation consumer is already dead — stop here instead of
            # burning VLM quota on images whose items can never be generated.
            raise RuntimeError("Generation consumer failed; aborting extraction")

        async with EXTRACTION_SEMAPHORE:
            if job.is_cancelled():
                return []
            if await self._skip_due_to_capacity(job, image_id):
                return []

            # A prior image already exhausted the upstream AI capacity
            # (Gemini free-tier quota + Agnes fallback both failed). Don't
            # burn another guaranteed-to-fail VLM call; mark this image
            # skipped and move on. Checked here too (not only at semaphore
            # entry): tasks admitted concurrently can all pass the first
            # check before the flag is set, so only truly in-flight calls
            # proceed past this point.
            if await self._skip_due_to_capacity(job, image_id):
                return []

            # Persist the source photo to Supabase Storage BEFORE the vision
            # call. The returned URL is attached to every item detected in
            # this photo so the generation phase can re-fetch it as a
            # reference image (full image + bbox) for accurate reproduction.
            # Best-effort: failures degrade to text-only generation, not a
            # failed pipeline.
            image_data_ref = job.images.get(image_id)
            if (
                image_data_ref is not None
                and not image_data_ref.source_image_url
                and image_base64
            ):
                try:
                    upload = await self._persist_source_image(image_id, image_base64)
                    if upload:
                        image_data_ref.source_image_url = upload.get("image_url")
                        image_data_ref.source_image_storage_path = upload.get("storage_path")
                except Exception as upload_err:
                    logger.warning(
                        "Source image upload failed; falling back to text-only generation",
                        extra={"job_id": job.job_id, "image_id": image_id, "error": str(upload_err)},
                    )

            # ponytail: shrink the photo before the vision call. Off the event
            # loop because PIL decode is CPU-bound and would stall heartbeats.
            # Cache keys use the original payload (route looks up before this).
            image_base64 = await asyncio.to_thread(
                downscale_base64_image, image_base64
            )

            try:
                result = await with_retry(
                    lambda: agent.extract_multiple_items(
                        image_base64=image_base64,
                        user_profile_image_base64=user_profile_image_base64,
                    ),
                    max_retries=2,
                    initial_delay=2.0,
                    backoff_factor=2.0,
                    retryable_exceptions=(AIServiceError,),
                    should_retry=is_retryable_error,
                    on_retry=lambda attempt, error, delay: logger.warning(
                        f"Retrying extraction for image {image_id}",
                        extra={"attempt": attempt, "delay": delay, "error": str(error)},
                    ),
                )

                items = result.get("items", [])

                added = await BatchJobService.add_detected_items(job.job_id, image_id, items)

                await BatchJobService.broadcast_event(job.job_id, "image_extraction_complete", {
                    "job_id": job.job_id,
                    "image_id": image_id,
                    "items": items,
                    "items_count": len(items),
                    "completed_count": len(job.extraction_completed),
                    "total_images": job.total_images,
                    "timestamp": utcnow_iso(),
                })

                # Overlap: enqueue for generation immediately
                if on_items_ready and added and not job.is_cancelled():
                    try:
                        await on_items_ready(added)
                    except Exception as enqueue_err:
                        logger.warning(
                            "Failed to enqueue items for generation",
                            extra={"job_id": job.job_id, "error": str(enqueue_err)},
                        )

                return items

            except Exception as e:
                error_msg = str(e)
                # Pull the structured bucket off an AIServiceError so the UI can
                # show "AI busy, try again shortly" (upstream_quota/transient,
                # which are "on us") distinctly from a hard failure. The user's
                # own plan limit is a separate RateLimitError and never reaches
                # here (it is raised pre-flight, before the job starts).
                error_kind = getattr(e, "error_kind", None)
                retry_after = getattr(e, "retry_after_seconds", None)
                code = "AI_SERVICE_ERROR"

                # Unrecoverable upstream capacity exhaustion: stop grinding the
                # remaining images. The Agnes fallback already tried and failed
                # inside chat_with_vision, so retrying won't help.
                if error_kind == "upstream_quota" and not self._extraction_capacity_exhausted:
                    self._extraction_capacity_exhausted = True
                    await BatchJobService.broadcast_event(
                        job.job_id, "extraction_capacity_exhausted", {
                            "job_id": job.job_id,
                            "error": "AI service capacity exhausted; remaining images skipped",
                            "code": code,
                            "error_kind": error_kind,
                            "timestamp": utcnow_iso(),
                        }
                    )

                logger.error(
                    f"Extraction failed for image {image_id}",
                    extra={
                        "job_id": job.job_id,
                        "error": error_msg,
                        "error_kind": error_kind,
                        "retry_after_seconds": retry_after,
                    },
                )

                await BatchJobService.mark_extraction_failed(job.job_id, image_id, error_msg)

                await BatchJobService.broadcast_event(job.job_id, "image_extraction_failed", {
                    "job_id": job.job_id,
                    "image_id": image_id,
                    "error": error_msg,
                    "code": code,
                    "error_kind": error_kind,
                    "retry_after_seconds": retry_after,
                    "completed_count": len(job.extraction_completed),
                    "failed_count": len(job.extraction_failed),
                    "total_images": job.total_images,
                    "timestamp": utcnow_iso(),
                })

                return []

    async def _fetch_user_avatar_base64(self) -> Optional[str]:
        """
        Best-effort avatar fetch for profile-aware person matching.

        Non-blocking with aggressive 5-second timeout - if avatar fetch is slow,
        skip it and continue without avatar. Don't block extraction pipeline.
        """
        try:
            user_result = await asyncio.to_thread(
                self.db.table("users")
                .select("avatar_url")
                .eq("id", self.user_id)
                .single()
                .execute
            )
            if not user_result or not user_result.data:
                return None

            avatar_url = user_result.data.get("avatar_url")
            if not avatar_url:
                return None

            async with httpx.AsyncClient(
                timeout=httpx.Timeout(5.0),
                limits=httpx.Limits(max_connections=10),
            ) as client:
                response = await client.get(avatar_url)
                response.raise_for_status()
                return base64.b64encode(response.content).decode("utf-8")

        except asyncio.TimeoutError:
            logger.info(
                "Avatar fetch timed out (5s) - continuing without avatar",
                extra={"user_id": self.user_id},
            )
            return None
        except Exception as e:
            logger.info(
                "Failed to fetch user avatar - continuing without it",
                extra={"user_id": self.user_id, "error": str(e)},
            )
            return None

    async def _persist_source_image(
        self,
        image_id: str,
        image_base64: str,
    ) -> Optional[Dict[str, str]]:
        """Upload the original source photo to Supabase Storage.

        Returns {image_url, storage_path} on success, or None on decode/upload
        failure. Best-effort: callers degrade to text-only generation.
        """
        if not image_base64:
            return None
        try:
            # Strip data URL prefix if present
            raw_b64 = image_base64.split("base64,", 1)[-1] if "base64," in image_base64 else image_base64
            file_data = base64.b64decode(raw_b64)
            return await StorageService.upload_source_image(
                db=self.db,
                user_id=self.user_id,
                file_data=file_data,
                extension=".jpg",
            )
        except Exception as e:
            logger.warning(
                "Source image decode/upload failed",
                extra={"image_id": image_id, "error": str(e)},
            )
            return None

    async def _generation_consumer(
        self,
        job: BatchJob,
        gen_queue: asyncio.Queue,
    ) -> None:
        """
        Consume detected-item batches and generate product images continuously.

        Uses GENERATION_SEMAPHORE (process-wide ceiling, configurable via
        AI_GENERATION_CONCURRENCY) for concurrency. A per-job local semaphore
        (job.generation_batch_size) can only tighten below that ceiling.
        Items are processed as they arrive rather than waiting for all extracts.
        """
        agent = None
        generation_started = False
        in_flight: set[asyncio.Task] = set()
        # Local semaphore so generation_batch_size can tighten below the
        # process-wide GENERATION_SEMAPHORE ceiling when a caller passes a
        # smaller value. The global cap (AI_GENERATION_CONCURRENCY, default
        # 30) is the effective maximum; this local sem only narrows further.
        ceiling = max(1, settings.AI_GENERATION_CONCURRENCY)
        concurrent_cap = max(1, min(ceiling, job.generation_batch_size or ceiling))
        local_sem = asyncio.Semaphore(concurrent_cap)
        # Consumer-scoped cache of source-photo downloads, keyed by URL.
        # Sibling items detected across one or more batches share a photo, so
        # this turns N downloads of one multi-MB JPEG into one per unique photo.
        photo_cache: Dict[str, Optional[str]] = {}

        async def run_one(item: DetectedItemData, reference_image_base64: Optional[str]) -> None:
            async with local_sem:
                await self._generate_single_item(job, item, agent, reference_image_base64)

        try:
            while True:
                # Adopt a durable CANCELLED state persisted by a non-owner
                # worker between batches.
                await BatchJobService.check_durable_cancel(job)
                if job.is_cancelled():
                    # Drop remaining queue without generating; still wait in-flight below.
                    break

                batch = await gen_queue.get()
                if batch is None:
                    # Drain complete — wait for in-flight gens
                    break

                if job.is_cancelled():
                    # Discard this batch; keep draining until sentinel from producer.
                    continue

                if agent is None:
                    agent = await get_image_generation_agent(
                        user_id=self.user_id, db=self.db
                    )

                if not generation_started:
                    generation_started = True
                    # Status advances to GENERATING in run_pipeline once the
                    # extraction phase finishes. total_items is items detected
                    # SO FAR (extraction may still be running); per-item events
                    # carry the growing total — clients must backfill from them.
                    await BatchJobService.broadcast_event(
                        job.job_id,
                        "generation_started",
                        {
                            "job_id": job.job_id,
                            "total_items": job.total_items,
                            "batch_size": concurrent_cap,
                            # Continuous pool (not discrete waves). Clients may
                            # ignore total_batches when 0.
                            "total_batches": 0,
                            "timestamp": utcnow_iso(),
                        },
                    )

                for item in batch:
                    if job.is_cancelled():
                        break
                    # Resolve this item's source photo via the shared cache
                    # before dispatch, so sibling items on the same photo share
                    # one download instead of each re-GETting it under the
                    # generation semaphore.
                    src_url = getattr(item, "source_image_url", None)
                    reference_image_base64: Optional[str] = None
                    if src_url:
                        if src_url not in photo_cache:
                            photo_cache[src_url] = await StorageService.download_to_base64(src_url)
                        reference_image_base64 = photo_cache[src_url]
                    task = asyncio.create_task(run_one(item, reference_image_base64))
                    in_flight.add(task)
                    task.add_done_callback(in_flight.discard)

            # Wait for all in-flight generations
            if in_flight:
                await asyncio.gather(*in_flight, return_exceptions=True)

            if not job.is_cancelled() and generation_started:
                await BatchJobService.broadcast_event(
                    job.job_id,
                    "all_generations_complete",
                    {
                        "job_id": job.job_id,
                        "total_items": job.total_items,
                        "successful": len(job.generation_completed),
                        "failed": len(job.generation_failed),
                        "timestamp": utcnow_iso(),
                    },
                )

        except asyncio.CancelledError:
            for t in list(in_flight):
                t.cancel()
            if in_flight:
                # Await the cancelled tasks so they actually stop (and don't
                # emit stray events onto a torn-down job) before we unwind.
                await asyncio.gather(*in_flight, return_exceptions=True)
            raise
        except Exception as e:
            logger.error(
                "Generation consumer failed",
                extra={"job_id": job.job_id, "error": str(e)},
            )
            raise

    async def _generate_single_item(
        self,
        job: BatchJob,
        item: DetectedItemData,
        agent,
        reference_image_base64: Optional[str],
    ) -> Optional[str]:
        """Generate product image for a single item with global semaphore and retry."""
        if job.is_cancelled():
            return None

        async with GENERATION_SEMAPHORE:
            if job.is_cancelled():
                return None

            try:
                description_parts = []
                if item.colors:
                    description_parts.append(item.colors[0])
                if item.sub_category:
                    description_parts.append(item.sub_category)
                elif item.category:
                    description_parts.append(item.category)

                item_description = (
                    item.detailed_description
                    or " ".join(description_parts)
                    or item.category
                )

                # The source photo was pre-fetched by the consumer (one
                # download per unique photo, shared across sibling items) and
                # passed in here. resolve_product_reference_image then decides
                # whether to use it as-is, crop it to the item's bbox, or drop
                # it for text-only generation - see that function for why.
                if reference_image_base64 is None and item.source_image_url:
                    logger.info(
                        "Source image unavailable; text-only generation",
                        extra={
                            "job_id": job.job_id,
                            "temp_id": item.temp_id,
                            "image_id": item.image_id,
                        },
                    )

                sibling_count = sum(
                    1 for i in job.detected_items if i.image_id == item.image_id
                )
                reference_image_base64, reference_strategy = resolve_product_reference_image(
                    reference_image_base64,
                    item.bounding_box,
                    item.confidence,
                    sibling_count,
                )
                logger.info(
                    "Resolved product-image reference strategy",
                    extra={
                        "job_id": job.job_id,
                        "temp_id": item.temp_id,
                        "image_id": item.image_id,
                        "strategy": reference_strategy,
                        "sibling_count": sibling_count,
                        "confidence": item.confidence,
                        "has_bounding_box": item.bounding_box is not None,
                    },
                )

                result = await with_retry(
                    lambda: agent.generate_product_image(
                        item_description=item_description,
                        category=item.category,
                        sub_category=item.sub_category,
                        colors=item.colors,
                        material=item.material,
                        # "transparent" -> flat white prompt + server-side
                        # matte (app/utils/background_removal.py).
                        background="transparent",
                        view_angle="front",
                        include_shadows=False,
                        reference_image=reference_image_base64,
                    ),
                    max_retries=1,
                    initial_delay=2.0,
                    backoff_factor=2.0,
                    retryable_exceptions=(AIServiceError,),
                    should_retry=is_retryable_error,
                    on_retry=lambda attempt, error, delay: logger.warning(
                        f"Retrying generation for item {item.temp_id}",
                        extra={"attempt": attempt, "delay": delay, "error": str(error)},
                    ),
                )

                image_base64 = result.image_base64

                await BatchJobService.update_item_generation(
                    job.job_id,
                    item.temp_id,
                    generated_image_base64=image_base64,
                )

                await BatchJobService.broadcast_event(job.job_id, "item_generation_complete", {
                    "job_id": job.job_id,
                    "temp_id": item.temp_id,
                    "image_id": item.image_id,
                    "generated_image_base64": image_base64,
                    "completed_count": len(job.generation_completed),
                    "total_items": job.total_items,
                    "timestamp": utcnow_iso(),
                })

                return image_base64

            except Exception as e:
                error_msg = str(e)
                logger.error(
                    f"Generation failed for item {item.temp_id}",
                    extra={"job_id": job.job_id, "error": error_msg},
                )

                await BatchJobService.update_item_generation(
                    job.job_id,
                    item.temp_id,
                    error=error_msg,
                )

                await BatchJobService.broadcast_event(job.job_id, "item_generation_failed", {
                    "job_id": job.job_id,
                    "temp_id": item.temp_id,
                    "image_id": item.image_id,
                    "error": error_msg,
                    "completed_count": len(job.generation_completed),
                    "failed_count": len(job.generation_failed),
                    "total_items": job.total_items,
                    "timestamp": utcnow_iso(),
                })

                return None

    async def _cache_extraction_results(self, job: BatchJob) -> None:
        """
        Cache extraction results for single-image jobs.

        Caches by image hash with 24-hour TTL to avoid redundant AI processing.
        """
        try:
            from app.services.extraction_cache_service import ExtractionCacheService

            if not job.images:
                return

            image_data = list(job.images.values())[0]
            image_base64 = image_data.image_base64
            if not image_base64:
                return

            result = {
                "items": [item.to_dict() for item in job.detected_items],
                "timestamp": utcnow_iso(),
            }

            await ExtractionCacheService.set_cached_result(
                image_base64=image_base64,
                user_id=self.user_id,
                result=result,
            )

            logger.info(
                "Cached extraction results",
                extra={
                    "job_id": job.job_id,
                    "user_id": self.user_id,
                    "item_count": len(job.detected_items),
                },
            )

        except Exception as e:
            logger.warning(
                "Failed to cache extraction results",
                extra={"job_id": job.job_id, "error": str(e)},
            )

    async def _broadcast_job_complete(self, job: BatchJob) -> None:
        """Broadcast job completion with full results."""
        await BatchJobService.broadcast_event(job.job_id, "job_complete", {
            "job_id": job.job_id,
            "total_images": job.total_images,
            "total_items_detected": job.total_items,
            "successful_extractions": len(job.extraction_completed),
            "failed_extractions": len(job.extraction_failed),
            "successful_generations": len(job.generation_completed),
            "failed_generations": len(job.generation_failed),
            "items": [item.to_dict() for item in job.detected_items],
            "timestamp": utcnow_iso(),
        })
