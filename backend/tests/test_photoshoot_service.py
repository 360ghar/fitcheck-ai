"""
Tests for photoshoot service with retry logic.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import Mock, patch, AsyncMock
import asyncio

from app.services.photoshoot_service import PhotoshootService, USE_CASE_TEMPLATES, PhotoshootUseCase
from app.services.photoshoot_job_service import PhotoshootJobService, PhotoshootJob
from app.models.photoshoot import PhotoshootJobStatus, PhotoshootUseCase as PhotoshootUseCaseEnum
from app.core.exceptions import AIServiceError, RateLimitError
from app.models.subscription import PlanType


class TestPhotoshootRetryLogic:
    """Test retry behavior for photoshoot image generation."""

    @pytest.fixture
    def mock_db(self):
        """Create a mock database client."""
        db = Mock()
        db.table = Mock(return_value=db)
        db.select = Mock(return_value=db)
        db.eq = Mock(return_value=db)
        db.single = Mock(return_value=db)
        db.execute = Mock(return_value=Mock(data={"plan_type": "free"}))
        return db

    @pytest.fixture
    def mock_job(self):
        """Create a mock photoshoot job."""
        return PhotoshootJob(
            job_id="test-job-123",
            user_id="user-456",
            status=PhotoshootJobStatus.PENDING,
            created_at=datetime.utcnow(),
            photos=["base64photo1"],
            use_case="LINKEDIN",
            num_images=4,
            batch_size=2,
        )

    @pytest.mark.asyncio
    async def test_parallel_retry_on_transient_failure(self):
        """Test that transient failures are retried with exponential backoff."""
        from app.utils.parallel import parallel_with_retry, ParallelResult

        call_count = 0

        async def flaky_function(item, index):
            nonlocal call_count
            call_count += 1
            if call_count < 3:  # Fail first 2 attempts
                raise AIServiceError("Transient error")
            return f"success-{item}"

        results = await parallel_with_retry(
            items=["a"],
            fn=flaky_function,
            max_retries=3,
            initial_delay=0.01,  # Fast for tests
            retryable_exceptions=(AIServiceError,),
        )

        assert len(results) == 1
        assert results[0].success is True
        assert results[0].data == "success-a"
        assert call_count == 3  # 2 failures + 1 success

    @pytest.mark.asyncio
    async def test_parallel_retry_exhaustion(self):
        """Test that all retries are exhausted before giving up."""
        from app.utils.parallel import parallel_with_retry

        async def always_fails(item, index):
            raise AIServiceError("Persistent error")

        results = await parallel_with_retry(
            items=["a", "b"],
            fn=always_fails,
            max_retries=2,
            initial_delay=0.01,
            retryable_exceptions=(AIServiceError,),
        )

        assert len(results) == 2
        assert all(not r.success for r in results)
        assert all(isinstance(r.error, AIServiceError) for r in results)

    @pytest.mark.asyncio
    async def test_parallel_retry_non_retryable_exception(self):
        """Test that non-retryable exceptions fail immediately."""
        from app.utils.parallel import parallel_with_retry

        call_count = 0

        async def raises_validation_error(item, index):
            nonlocal call_count
            call_count += 1
            raise ValueError("Validation error - not retryable")

        results = await parallel_with_retry(
            items=["a"],
            fn=raises_validation_error,
            max_retries=3,
            initial_delay=0.01,
            retryable_exceptions=(AIServiceError,),  # ValueError not included
        )

        assert len(results) == 1
        assert not results[0].success
        assert call_count == 1  # Should not retry

    @pytest.mark.asyncio
    async def test_parallel_retry_with_callback(self):
        """Test that on_item_complete callback is called for each item."""
        from app.utils.parallel import parallel_with_retry

        callbacks = []

        def on_complete(index, result):
            callbacks.append((index, result.success))

        async def process_item(item, index):
            if item == "fail":
                raise AIServiceError("Fail")
            return f"success-{item}"

        results = await parallel_with_retry(
            items=["a", "fail", "c"],
            fn=process_item,
            max_retries=1,
            initial_delay=0.01,
            retryable_exceptions=(AIServiceError,),
            on_item_complete=on_complete,
        )

        assert len(callbacks) == 3
        assert callbacks[0] == (0, True)
        assert callbacks[1] == (1, False)
        assert callbacks[2] == (2, True)

    @pytest.mark.asyncio
    async def test_photoshoot_job_tracks_failed_indices(self, mock_job):
        """Test that failed image indices are tracked in the job."""
        await PhotoshootJobService._jobs.clear() if hasattr(PhotoshootJobService._jobs, 'clear') else None

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs[mock_job.job_id] = mock_job

        # Mark some indices as failed
        await PhotoshootJobService.mark_image_failed(mock_job.job_id, 2, "Generation failed")
        await PhotoshootJobService.mark_image_failed(mock_job.job_id, 5, "Rate limit")

        status = await PhotoshootJobService.get_job_status(mock_job.job_id)

        assert status["failed_count"] == 2
        assert status["failed_indices"] == [2, 5]
        assert status["partial_success"] is True

        # Cleanup
        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(mock_job.job_id, None)

    @pytest.mark.asyncio
    async def test_daily_limit_check_prevents_generation(self, mock_db):
        """Test that daily limit is checked before generation."""
        with patch.object(PhotoshootService, 'get_usage') as mock_get_usage:
            mock_get_usage.return_value = Mock(
                used_today=10,
                limit_today=10,
                remaining=0,
                plan_type="free",
            )

            can_generate, usage = await PhotoshootService.check_daily_limit(
                user_id="user-123",
                num_images=1,
                db=mock_db,
            )

            assert can_generate is False
            assert usage.remaining == 0

    @pytest.mark.asyncio
    async def test_daily_limit_allows_within_limit(self, mock_db):
        """Test that generation is allowed when within daily limit."""
        with patch.object(PhotoshootService, 'get_usage') as mock_get_usage:
            mock_get_usage.return_value = Mock(
                used_today=5,
                limit_today=10,
                remaining=5,
                plan_type="free",
            )

            can_generate, usage = await PhotoshootService.check_daily_limit(
                user_id="user-123",
                num_images=3,
                db=mock_db,
            )

            assert can_generate is True
            assert usage.remaining == 5


class TestPhotoshootUseCaseTemplates:
    """Test photoshoot use case templates."""

    def test_all_use_cases_have_required_fields(self):
        """Verify all use case templates have required fields."""
        for use_case, template in USE_CASE_TEMPLATES.items():
            assert "name" in template, f"{use_case} missing name"
            assert "description" in template, f"{use_case} missing description"
            assert "prompt_guidance" in template, f"{use_case} missing prompt_guidance"
            assert "example_prompts" in template, f"{use_case} missing example_prompts"

    def test_custom_use_case_allows_empty_guidance(self):
        """Test that CUSTOM use case has empty guidance for user-provided prompts."""
        custom = USE_CASE_TEMPLATES[PhotoshootUseCase.CUSTOM]
        assert custom["prompt_guidance"] == ""
        assert custom["example_prompts"] == []


class TestPhotoshootJobLifecycle:
    """Test photoshoot job lifecycle management."""

    @pytest.mark.asyncio
    async def test_job_cancellation(self):
        """Test that jobs can be cancelled."""
        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["photo1"],
            use_case="LINKEDIN",
            num_images=4,
        )

        result = await PhotoshootJobService.cancel_job(job.job_id, "user-123")

        assert result is True

        status = await PhotoshootJobService.get_job_status(job.job_id)
        assert status["status"] == "cancelled"

    @pytest.mark.asyncio
    async def test_cannot_cancel_completed_job(self):
        """Test that completed jobs cannot be cancelled."""
        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["photo1"],
            use_case="LINKEDIN",
            num_images=4,
        )

        # Mark as complete
        await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)

        result = await PhotoshootJobService.cancel_job(job.job_id, "user-123")

        assert result is False

    @pytest.mark.asyncio
    async def test_job_cleanup_removes_expired_jobs(self):
        """Test that expired jobs are cleaned up."""
        # Create a job with old timestamp
        old_job = PhotoshootJob(
            job_id="old-job",
            user_id="user-123",
            status=PhotoshootJobStatus.COMPLETE,
            created_at=datetime.utcnow() - timedelta(hours=2),  # Expired
            photos=["photo1"],
            use_case="LINKEDIN",
            num_images=4,
        )

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs["old-job"] = old_job

        await PhotoshootJobService._cleanup_expired_jobs()

        async with PhotoshootJobService._lock:
            assert "old-job" not in PhotoshootJobService._jobs

    @pytest.mark.asyncio
    async def test_event_history_for_replay(self):
        """Test that event history is maintained for late subscribers."""
        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["photo1"],
            use_case="LINKEDIN",
            num_images=4,
        )

        # Broadcast some events
        await PhotoshootJobService.broadcast_event(job.job_id, "test_event", {"data": 1})
        await PhotoshootJobService.broadcast_event(job.job_id, "test_event", {"data": 2})

        # Get history
        history = await PhotoshootJobService.get_event_history(job.job_id)

        assert len(history) == 2
        assert history[0]["data"]["data"] == 1
        assert history[1]["data"]["data"] == 2


class TestPhotoshootUsageTracking:
    """Test photoshoot usage tracking."""

    @pytest.mark.asyncio
    async def test_free_plan_daily_limit(self):
        """Test free plan has correct daily limit."""
        limit = PhotoshootService._get_daily_limit(PlanType.FREE)
        assert limit > 0
        assert limit <= 20  # Reasonable free limit

    @pytest.mark.asyncio
    async def test_pro_plan_higher_limit(self):
        """Test pro plan has higher daily limit than free."""
        free_limit = PhotoshootService._get_daily_limit(PlanType.FREE)
        pro_limit = PhotoshootService._get_daily_limit(PlanType.PRO_MONTHLY)

        assert pro_limit > free_limit

    @pytest.mark.asyncio
    async def test_usage_increment(self, mock_db):
        """Test that usage is incremented correctly."""
        with patch.object(PhotoshootService, 'get_or_create_daily_usage') as mock_get:
            mock_get.return_value = {"daily_photoshoot_images": 5}

            with patch.object(mock_db.table.return_value, 'update') as mock_update:
                mock_update.return_value = mock_update
                mock_update.eq = Mock(return_value=mock_update)
                mock_update.eq.return_value = mock_update
                mock_update.execute = Mock()

                await PhotoshootService.increment_usage("user-123", 3, mock_db)

                # Verify update was called (actual assertion depends on implementation)
                mock_update.execute.assert_called_once()
