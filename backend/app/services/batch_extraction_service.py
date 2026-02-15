"""
Batch Extraction Service.

Orchestrates the batch extraction and generation pipeline.
Handles parallel extraction of multiple images and batched generation.
"""

import asyncio
import base64
import logging
from datetime import datetime
from typing import Any, Dict, List, Optional

import httpx

from app.agents.item_extraction_agent import get_item_extraction_agent
from app.agents.image_generation_agent import get_image_generation_agent
from app.services.batch_job_service import (
    BatchJob,
    BatchJobService,
    BatchJobStatus,
    DetectedItemData,
)
from app.utils.retry import with_retry

logger = logging.getLogger(__name__)

# Semaphores to limit concurrent AI calls
EXTRACTION_SEMAPHORE = asyncio.Semaphore(10)  # Max 10 concurrent extractions
GENERATION_SEMAPHORE = asyncio.Semaphore(5)   # Max 5 concurrent generations


class BatchExtractionService:
    """Orchestrates the batch extraction and generation pipeline."""

    def __init__(self, user_id: str, db):
        self.user_id = user_id
        self.db = db

    async def run_pipeline(self, job: BatchJob) -> None:
        """
        Run the complete batch processing pipeline.

        Phase 1: Extract items from ALL images in parallel
        Phase 2: Generate product images in batches of N (if auto_generate=True)
        """
        try:
            # Phase 1: Extraction
            await self._run_extraction_phase(job)

            # Check cancellation
            if job.is_cancelled():
                return

            # Phase 2: Generation (if enabled and items were detected)
            if job.auto_generate and job.detected_items:
                await self._run_generation_phase(job)

            # Mark complete
            if not job.is_cancelled():
                await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
                await self._broadcast_job_complete(job)

        except Exception as e:
            logger.error(
                "Batch pipeline failed",
                extra={"job_id": job.job_id, "error": str(e)},
            )
            await BatchJobService.set_error(job.job_id, str(e))
            await BatchJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat(),
            })

    async def _run_extraction_phase(self, job: BatchJob) -> None:
        """
        Phase 1: Extract items from ALL images in parallel.

        Uses asyncio.gather for parallel processing.
        Each image is processed independently.
        Failures don't stop other images.
        """
        await BatchJobService.update_status(job.job_id, BatchJobStatus.EXTRACTING)

        # Broadcast start
        await BatchJobService.broadcast_event(job.job_id, "extraction_started", {
            "job_id": job.job_id,
            "total_images": job.total_images,
            "timestamp": datetime.utcnow().isoformat(),
        })

        # Get extraction agent
        agent = await get_item_extraction_agent(user_id=self.user_id, db=self.db)
        user_profile_image_base64 = await self._fetch_user_avatar_base64()

        # Create tasks for all images
        tasks = []
        for image_id, image_data in job.images.items():
            task = asyncio.create_task(
                self._extract_single_image(
                    job,
                    image_id,
                    image_data.image_base64,
                    agent,
                    user_profile_image_base64=user_profile_image_base64,
                )
            )
            tasks.append(task)

        # Execute all tasks in parallel
        await asyncio.gather(*tasks, return_exceptions=True)

        # Broadcast extraction complete
        await BatchJobService.broadcast_event(job.job_id, "all_extractions_complete", {
            "job_id": job.job_id,
            "total_images": job.total_images,
            "successful": len(job.extraction_completed),
            "failed": len(job.extraction_failed),
            "total_items_detected": job.total_items,
            "timestamp": datetime.utcnow().isoformat(),
        })

        # Cache extraction results for single-image jobs (24-hour TTL)
        if job.total_images == 1 and job.detected_items:
            await self._cache_extraction_results(job)

    async def _extract_single_image(
        self,
        job: BatchJob,
        image_id: str,
        image_base64: str,
        agent,
        user_profile_image_base64: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Extract items from a single image with semaphore and retry."""
        if job.is_cancelled():
            return []

        async with EXTRACTION_SEMAPHORE:
            if job.is_cancelled():
                return []

            try:
                # Extract with retry
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

                # Add items to job
                await BatchJobService.add_detected_items(job.job_id, image_id, items)

                # Broadcast success
                await BatchJobService.broadcast_event(job.job_id, "image_extraction_complete", {
                    "job_id": job.job_id,
                    "image_id": image_id,
                    "items": items,
                    "items_count": len(items),
                    "completed_count": len(job.extraction_completed),
                    "total_images": job.total_images,
                    "timestamp": datetime.utcnow().isoformat(),
                })

                return items

            except Exception as e:
                error_msg = str(e)
                logger.error(
                    f"Extraction failed for image {image_id}",
                    extra={"job_id": job.job_id, "error": error_msg},
                )

                # Mark as failed
                await BatchJobService.mark_extraction_failed(job.job_id, image_id, error_msg)

                # Broadcast failure
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

            # Aggressive 5-second timeout - if avatar fetch is slow, skip it
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

    async def _run_generation_phase(self, job: BatchJob) -> None:
        """
        Phase 2: Generate product images in batches.

        Groups items into batches of `generation_batch_size`.
        Processes each batch in parallel.
        Waits for batch to complete before starting next.
        """
        await BatchJobService.update_status(job.job_id, BatchJobStatus.GENERATING)

        items = job.detected_items
        batch_size = job.generation_batch_size
        total_batches = (len(items) + batch_size - 1) // batch_size

        # Broadcast start
        await BatchJobService.broadcast_event(job.job_id, "generation_started", {
            "job_id": job.job_id,
            "total_items": len(items),
            "batch_size": batch_size,
            "total_batches": total_batches,
            "timestamp": datetime.utcnow().isoformat(),
        })

        # Get generation agent
        agent = await get_image_generation_agent(user_id=self.user_id, db=self.db)

        # Process items in batches
        for batch_num in range(total_batches):
            if job.is_cancelled():
                return

            start_idx = batch_num * batch_size
            end_idx = min(start_idx + batch_size, len(items))
            batch_items = items[start_idx:end_idx]

            # Broadcast batch start
            await BatchJobService.broadcast_event(job.job_id, "batch_generation_started", {
                "job_id": job.job_id,
                "batch_number": batch_num + 1,
                "total_batches": total_batches,
                "items_in_batch": len(batch_items),
                "item_ids": [item.temp_id for item in batch_items],
                "start_index": start_idx,
                "end_index": end_idx,
                "timestamp": datetime.utcnow().isoformat(),
            })

            # Process batch in parallel
            await self._generate_item_batch(job, batch_items, agent)

            # Broadcast batch complete
            await BatchJobService.broadcast_event(job.job_id, "batch_generation_complete", {
                "job_id": job.job_id,
                "batch_number": batch_num + 1,
                "total_batches": total_batches,
                "completed_in_batch": len([i for i in batch_items if i.status == "generated"]),
                "failed_in_batch": len([i for i in batch_items if i.status == "failed"]),
                "timestamp": datetime.utcnow().isoformat(),
            })

        # Broadcast all generations complete
        await BatchJobService.broadcast_event(job.job_id, "all_generations_complete", {
            "job_id": job.job_id,
            "total_items": len(items),
            "successful": len(job.generation_completed),
            "failed": len(job.generation_failed),
            "timestamp": datetime.utcnow().isoformat(),
        })

    async def _generate_item_batch(
        self,
        job: BatchJob,
        items: List[DetectedItemData],
        agent,
    ) -> None:
        """Generate product images for a batch of items in parallel."""
        tasks = []
        for item in items:
            task = asyncio.create_task(
                self._generate_single_item(job, item, agent)
            )
            tasks.append(task)

        await asyncio.gather(*tasks, return_exceptions=True)

    async def _generate_single_item(
        self,
        job: BatchJob,
        item: DetectedItemData,
        agent,
    ) -> Optional[str]:
        """Generate product image for a single item with semaphore and retry."""
        if job.is_cancelled():
            return None

        async with GENERATION_SEMAPHORE:
            if job.is_cancelled():
                return None

            try:
                # Build description
                description_parts = []
                if item.colors:
                    description_parts.append(item.colors[0])
                if item.sub_category:
                    description_parts.append(item.sub_category)
                elif item.category:
                    description_parts.append(item.category)

                item_description = item.detailed_description or " ".join(description_parts) or item.category

                # Generate with retry
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

                # Update item
                await BatchJobService.update_item_generation(
                    job.job_id,
                    item.temp_id,
                    generated_image_base64=image_base64,
                )

                # Broadcast success
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

                # Mark as failed
                await BatchJobService.update_item_generation(
                    job.job_id,
                    item.temp_id,
                    error=error_msg,
                )

                # Broadcast failure
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

            # Get the single image from the job
            if not job.images:
                return

            image_data = list(job.images.values())[0]
            image_base64 = image_data.image_base64

            # Prepare result to cache
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
            # Non-critical - log and continue
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
