"""
Batch Extraction Service.

Orchestrates the batch extraction and generation pipeline.
Extraction runs in parallel across images; product-image generation starts as
soon as each image's items are detected (overlapped with remaining extracts).
"""

import asyncio
import base64
import logging
from datetime import datetime
from typing import Any, Awaitable, Callable, Dict, List, Optional

import httpx

from app.agents.item_extraction_agent import get_item_extraction_agent
from app.agents.image_generation_agent import get_image_generation_agent
from app.services.batch_job_service import (
    BatchJob,
    BatchJobService,
    BatchJobStatus,
    DetectedItemData,
)
from app.utils.image_processing import downscale_base64_image
from app.utils.retry import with_retry

logger = logging.getLogger(__name__)

# Semaphores to limit concurrent AI calls
EXTRACTION_SEMAPHORE = asyncio.Semaphore(10)  # Max 10 concurrent extractions
GENERATION_SEMAPHORE = asyncio.Semaphore(5)   # Max 5 concurrent generations

OnItemsReady = Optional[Callable[[List[DetectedItemData]], Awaitable[None]]]


class BatchExtractionService:
    """Orchestrates the batch extraction and generation pipeline."""

    def __init__(self, user_id: str, db):
        self.user_id = user_id
        self.db = db

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
                "timestamp": datetime.utcnow().isoformat(),
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
            "timestamp": datetime.utcnow().isoformat(),
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
            "timestamp": datetime.utcnow().isoformat(),
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
        if job.is_cancelled():
            return []
        if consumer_task is not None and consumer_task.done():
            # The generation consumer is already dead — stop here instead of
            # burning VLM quota on images whose items can never be generated.
            raise RuntimeError("Generation consumer failed; aborting extraction")

        async with EXTRACTION_SEMAPHORE:
            if job.is_cancelled():
                return []

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
                    max_retries=3,
                    initial_delay=2.0,
                    backoff_factor=2.0,
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
                    "timestamp": datetime.utcnow().isoformat(),
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
                logger.error(
                    f"Extraction failed for image {image_id}",
                    extra={"job_id": job.job_id, "error": error_msg},
                )

                await BatchJobService.mark_extraction_failed(job.job_id, image_id, error_msg)

                await BatchJobService.broadcast_event(job.job_id, "image_extraction_failed", {
                    "job_id": job.job_id,
                    "image_id": image_id,
                    "error": error_msg,
                    "completed_count": len(job.extraction_completed),
                    "failed_count": len(job.extraction_failed),
                    "total_images": job.total_images,
                    "timestamp": datetime.utcnow().isoformat(),
                })

                return []

    async def _fetch_user_avatar_base64(self) -> Optional[str]:
        """
        Best-effort avatar fetch for profile-aware person matching.

        Non-blocking with aggressive 5-second timeout - if avatar fetch is slow,
        skip it and continue without avatar. Don't block extraction pipeline.
        """
        try:
            user_result = (
                self.db.table("users")
                .select("avatar_url")
                .eq("id", self.user_id)
                .single()
                .execute()
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

    async def _generation_consumer(
        self,
        job: BatchJob,
        gen_queue: asyncio.Queue,
    ) -> None:
        """
        Consume detected-item batches and generate product images continuously.

        Uses GENERATION_SEMAPHORE for concurrency (same cap as former batch size).
        Items are processed as they arrive rather than waiting for all extracts.
        """
        agent = None
        generation_started = False
        in_flight: set[asyncio.Task] = set()
        concurrent_cap = max(1, min(5, job.generation_batch_size or 5))
        # Local semaphore so generation_batch_size can tighten below global 5
        local_sem = asyncio.Semaphore(concurrent_cap)

        async def run_one(item: DetectedItemData) -> None:
            async with local_sem:
                await self._generate_single_item(job, item, agent)

        try:
            while True:
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
                            "timestamp": datetime.utcnow().isoformat(),
                        },
                    )

                for item in batch:
                    if job.is_cancelled():
                        break
                    task = asyncio.create_task(run_one(item))
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
                        "timestamp": datetime.utcnow().isoformat(),
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

                result = await with_retry(
                    lambda: agent.generate_product_image(
                        item_description=item_description,
                        category=item.category,
                        sub_category=item.sub_category,
                        colors=item.colors,
                        material=item.material,
                        background="white",
                        view_angle="front",
                        include_shadows=False,
                    ),
                    max_retries=3,
                    initial_delay=2.0,
                    backoff_factor=2.0,
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
                    "timestamp": datetime.utcnow().isoformat(),
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
                    "timestamp": datetime.utcnow().isoformat(),
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
                "timestamp": datetime.utcnow().isoformat(),
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
            "timestamp": datetime.utcnow().isoformat(),
        })
