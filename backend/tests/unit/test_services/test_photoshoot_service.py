"""
Tests for photoshoot service with retry logic.
"""

import pytest
from datetime import datetime, timezone, timedelta
from unittest.mock import AsyncMock, Mock, patch

from app.services.photoshoot_service import PhotoshootService, USE_CASE_TEMPLATES, PhotoshootUseCase
from app.services.photoshoot_job_service import PhotoshootJobService, PhotoshootJob
from app.models.photoshoot import PhotoshootJobStatus
from app.core.exceptions import AIServiceError, ServiceError
from app.models.subscription import PlanType
from app.utils.json_utils import extract_json_block


class TestPromptJsonExtraction:
    def test_extract_json_object_from_prose(self):
        text = 'Sure! Here you go:\n{"subject_lock": "adult", "prompts": []}\nThanks'
        out = extract_json_block(text)
        assert out.startswith("{")
        assert "subject_lock" in out

    def test_extract_json_from_fence(self):
        text = '```json\n{"prompts": [{"index": 0}]}\n```'
        out = extract_json_block(text)
        assert '"prompts"' in out

    def test_extract_json_missing_raises(self):
        with pytest.raises(ValueError, match="did not contain JSON"):
            extract_json_block("no structured data here")

    def test_fallback_prompts_count(self):
        prompts = PhotoshootService._fallback_prompts(
            use_case=PhotoshootUseCase.LINKEDIN,
            num_prompts=4,
            custom_prompt=None,
            subject_hint="Same adult person as reference.",
        )
        assert len(prompts) == 4
        assert all(p.full_prompt for p in prompts)


@pytest.fixture
def mock_db():
    """Create a mock database client."""
    db = Mock()
    db.table = Mock(return_value=db)
    db.select = Mock(return_value=db)
    db.eq = Mock(return_value=db)
    db.single = Mock(return_value=db)
    db.execute = Mock(return_value=Mock(data={"plan_type": "free"}))
    return db


class TestPhotoshootRetryLogic:
    """Test retry behavior for photoshoot image generation."""

    @pytest.fixture
    def mock_job(self):
        """Create a mock photoshoot job."""
        return PhotoshootJob(
            job_id="test-job-123",
            user_id="user-456",
            status=PhotoshootJobStatus.PENDING,
            created_at=datetime.now(timezone.utc),
            photos=["base64photo1"],
            use_case="LINKEDIN",
            num_images=4,
            batch_size=2,
        )

    @pytest.mark.asyncio
    async def test_parallel_retry_on_transient_failure(self):
        """Test that transient failures are retried with exponential backoff."""
        from app.utils.parallel import parallel_with_retry

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

        await parallel_with_retry(
            items=["a", "fail", "c"],
            fn=process_item,
            max_retries=1,
            initial_delay=0.01,
            retryable_exceptions=(AIServiceError,),
            on_item_complete=on_complete,
        )

        # Items run concurrently and the failing item retries with a real delay,
        # so it completes (and fires its callback) later than the immediate
        # successes - assert the per-index outcome, not callback arrival order.
        assert dict(callbacks) == {0: True, 1: False, 2: True}

    @pytest.mark.asyncio
    async def test_photoshoot_job_tracks_failed_indices(self, mock_job):
        """Test that failed image indices are tracked in the job."""
        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.clear()

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
    async def test_update_status_does_not_overwrite_terminal_status(self):
        """A late status write from an unwinding pipeline must not un-cancel a job."""
        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["photo1"],
            use_case="LINKEDIN",
            num_images=4,
        )

        await PhotoshootJobService.cancel_job(job.job_id, "user-123")

        # A stale pipeline phase tries to flip it back to processing.
        await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.PROCESSING)

        status = await PhotoshootJobService.get_job_status(job.job_id)
        assert status["status"] == "cancelled"

    @pytest.mark.asyncio
    async def test_job_cleanup_removes_expired_jobs(self):
        """Test that expired jobs are cleaned up."""
        # Create a job with old timestamp
        old_job = PhotoshootJob(
            job_id="old-job",
            user_id="user-123",
            status=PhotoshootJobStatus.COMPLETE,
            created_at=datetime.now(timezone.utc) - timedelta(hours=2),  # Expired
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
        """The compatibility wrapper delegates to the atomic reservation path."""
        with patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new_callable=AsyncMock,
            return_value=(True, Mock()),
        ) as reserve:
            await PhotoshootService.increment_usage("user-123", 3, mock_db)

        reserve.assert_awaited_once_with("user-123", 3, mock_db)


class TestSceneLabels:
    """Scene labels broadcast in SSE events so clients show what's generating."""

    def test_prefers_setting_and_pose(self):
        from app.services.photoshoot_service import _scene_label
        from app.models.photoshoot import PhotoshootPrompt

        prompt = PhotoshootPrompt(
            index=0,
            setting="Sunlit cafe",
            outfit="linen shirt",
            pose="Seated upper body",
            lighting="window light",
            style="lifestyle",
            mood="approachable",
            full_prompt="x",
        )
        label = _scene_label(prompt)
        assert "Sunlit cafe" in label
        assert "Seated upper body" in label

    def test_truncates_long_label(self):
        from app.services.photoshoot_service import _scene_label
        from app.models.photoshoot import PhotoshootPrompt

        prompt = PhotoshootPrompt(
            index=1,
            setting="A very long and descriptive setting name that keeps going past the limit",
            pose="Standing mid-step with the face clearly toward the camera in soft golden light",
            outfit="x",
            lighting="x",
            style="editorial",
            mood="bold",
            full_prompt="x",
        )
        assert len(_scene_label(prompt)) <= 55

    def test_falls_back_to_style(self):
        from app.services.photoshoot_service import _scene_label
        from app.models.photoshoot import PhotoshootPrompt

        prompt = PhotoshootPrompt(
            index=2,
            setting="",
            outfit="x",
            pose="",
            lighting="x",
            style="editorial",
            mood="",
            full_prompt="x",
        )
        assert _scene_label(prompt) == "editorial"


class TestPhotoshootStreamingEvents:
    """Streaming pipeline broadcasts scene labels with batch/image events."""

    @pytest.fixture
    def fake_ai_service(self):
        class FakeChatResponse:
            images = ["SGVsbG8="]  # "Hello" - valid base64 payload
            model = "fake-image-model"
            provider = "fake"

        service = Mock()
        service.get_image_gen_model = Mock(return_value="fake-image-model")
        service.chat = AsyncMock(return_value=FakeChatResponse())
        service.close = AsyncMock()
        return service

    @pytest.mark.asyncio
    async def test_batch_and_image_events_carry_labels(self, fake_ai_service):
        from app.models.photoshoot import PhotoshootPrompt
        from app.services.photoshoot_service import PhotoshootStreamingService

        # Pipeline pulls the AI service through AISettingsService; the
        # per-photo downscale must not touch PIL on a fake payload.
        with (
            patch(
                "app.services.ai_settings_service.AISettingsService.get_ai_service_for_user",
                new_callable=AsyncMock,
                return_value=fake_ai_service,
            ),
            patch(
                "app.core.image_executor.run_image_op",
                new_callable=AsyncMock,
                side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs),
            ),
            patch(
                "app.utils.image_processing.downscale_base64_image",
                side_effect=lambda raw: raw,
            ),
        ):
            job = await PhotoshootJobService.create_job(
                user_id="user-123",
                photos=["data:image/jpeg;base64,SGVsbG8="],
                use_case="linkedin",
                num_images=2,
                batch_size=2,
            )
            prompts = [
                PhotoshootPrompt(
                    index=i,
                    setting=f"Setting {i}",
                    outfit="o",
                    pose=f"Pose {i}",
                    lighting="l",
                    style="s",
                    mood="m",
                    full_prompt="fp",
                )
                for i in range(2)
            ]

            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service._generate_images_streaming(job, prompts)

            history = await PhotoshootJobService.get_event_history(job.job_id)

            batch_started = next(e for e in history if e["type"] == "batch_started")
            assert "scene_labels" in batch_started["data"]
            assert batch_started["data"]["scene_labels"]["0"] == "Setting 0, Pose 0"

            image_events = [e for e in history if e["type"] == "image_complete"]
            assert len(image_events) == 2
            for event in image_events:
                assert event["data"]["label"]  # non-empty scene label

            # Cleanup the in-memory job
            async with PhotoshootJobService._lock:
                PhotoshootJobService._jobs.pop(job.job_id, None)


class TestDemoPhotoshootJob:
    """Demo jobs run under an IP-derived pseudo-user and skip quota."""

    @staticmethod
    def _fake_request(host: str):
        from types import SimpleNamespace

        class FakeRequest:
            def __init__(self, host):
                self.client = SimpleNamespace(host=host)
                self.headers = {}

        return FakeRequest(host)

    def test_demo_user_id_is_ip_derived_and_stable(self):
        from app.api.v1.photoshoot import _demo_user_id

        user_a = _demo_user_id(self._fake_request("203.0.113.7"))
        user_b = _demo_user_id(self._fake_request("203.0.113.7"))
        assert user_a == user_b
        assert user_a.startswith("demo_")
        assert "203.0.113.7" not in user_a  # raw IP never lands in the id

    def test_demo_user_id_differs_per_ip(self):
        from app.api.v1.photoshoot import _demo_user_id

        assert _demo_user_id(self._fake_request("203.0.113.7")) != _demo_user_id(
            self._fake_request("198.51.100.3")
        )

    def test_demo_user_id_uses_trusted_client_host_not_xff(self):
        """The pseudo-user must key on request.client.host (uvicorn proxy-
        resolved), never the client-supplied X-Forwarded-For header — parsing
        the header would let a caller mint a fresh pseudo-user per request and
        bypass the per-IP demo limit."""
        from app.api.v1.photoshoot import _demo_user_id
        from types import SimpleNamespace

        class SpoofedRequest:
            client = SimpleNamespace(host="198.51.100.3")
            headers = {"x-forwarded-for": "203.0.113.7"}

        assert _demo_user_id(SpoofedRequest()) == _demo_user_id(
            self._fake_request("198.51.100.3")
        )
        assert _demo_user_id(SpoofedRequest()) != _demo_user_id(
            self._fake_request("203.0.113.7")
        )

    @pytest.mark.asyncio
    async def test_demo_pipeline_skips_quota_reservation(self):
        from app.services.photoshoot_service import PhotoshootStreamingService

        job = await PhotoshootJobService.create_job(
            user_id="demo_abc",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="aesthetic",
            num_images=2,
            batch_size=2,
        )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ) as reserve,
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
            ),
        ):
            service = PhotoshootStreamingService(user_id="demo_abc", db=None, is_demo=True)
            await service.run_pipeline(job)

            reserve.assert_not_awaited()
            release.assert_not_awaited()

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_non_demo_pipeline_still_reserves_quota(self):
        from app.services.photoshoot_service import PhotoshootStreamingService
        from app.models.photoshoot import PhotoshootUsage

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        post_release_usage = PhotoshootUsage(
            used_today=0,
            limit_today=10,
            remaining=10,
            plan_type="free",
            resets_at=datetime.now(timezone.utc),
        )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ) as reserve,
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                return_value=post_release_usage,
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
            ),
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service.run_pipeline(job)

            reserve.assert_awaited_once()
            # No images were produced by the mocked streaming step, so the
            # full reservation (2) is handed back for the user to retry.
            release.assert_awaited_once()
            release.assert_awaited_with("user-123", 2, service.db)

        # A run that produced nothing is FAILED (parity with the sync path),
        # and the failure payload carries the POST-release usage, never the
        # reservation-time numbers (stale-quota regression, 2026-08-04).
        assert job.status == PhotoshootJobStatus.FAILED
        assert job.error_message and "No images were generated (0 of 2)" in job.error_message
        assert job.usage == post_release_usage.model_dump(mode="json")

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_usage_reread_failure_falls_back_to_reservation_snapshot(self):
        """A failed POST-release usage re-read must not kill the terminal
        event: fall back to the reservation-time snapshot (the client refetches
        usage itself), instead of hitting the generic pipeline except, which
        would surface the usage error AND double-release the reservation on
        top of the partial release already done."""
        from app.services.photoshoot_service import PhotoshootStreamingService
        from app.models.photoshoot import PhotoshootUsage

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        reservation_usage = PhotoshootUsage(
            used_today=0,
            limit_today=10,
            remaining=10,
            plan_type="free",
            resets_at=datetime.now(timezone.utc),
        )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, reservation_usage),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                side_effect=RuntimeError("usage endpoint down"),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
            ),
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service.run_pipeline(job)

            # The zero-image FAILED branch ran (not the generic except):
            # the payload carries the reservation snapshot, and only the
            # single partial release (2 of 2) happened - no double release.
            assert job.status == PhotoshootJobStatus.FAILED
            assert job.error_message and "No images were generated (0 of 2)" in job.error_message
            assert job.usage == reservation_usage.model_dump(mode="json")
            release.assert_awaited_once()
            release.assert_awaited_with("user-123", 2, service.db)

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_zero_image_run_broadcasts_job_failed_with_first_error(self):
        """The job_failed event must carry the first retained provider error so
        the client dialog (and operator logs) show why every slot failed."""
        from app.services.photoshoot_service import PhotoshootStreamingService

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        async def _fail_all_slots(job, prompts):
            await PhotoshootJobService.mark_image_failed(
                job.job_id, 1, "AI image request failed (400): bad size"
            )
            await PhotoshootJobService.mark_image_failed(
                job.job_id, 0, "AI image request failed (400): bad size"
            )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ),
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                return_value=Mock(),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
                side_effect=_fail_all_slots,
            ),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new_callable=AsyncMock,
            ) as broadcast,
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service.run_pipeline(job)

        failed_events = [
            call.args[1:]
            for call in broadcast.await_args_list
            if call.args[0] == job.job_id and call.args[1] == "job_failed"
        ]
        assert len(failed_events) == 1
        event_type, payload = failed_events[0]
        assert event_type == "job_failed"
        # Lowest failed index wins as the surfaced provider error.
        assert "AI image request failed (400)" in payload["error"]
        assert payload["failed_indices"] == [0, 1]
        # No job_complete event for a total failure.
        assert not any(call.args[1] == "job_complete" for call in broadcast.await_args_list)

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_partial_run_reports_complete_with_post_release_usage(self):
        """A run with SOME images stays COMPLETE, releases only the unused
        quota, and the job_complete payload carries POST-release usage."""
        from app.services.photoshoot_service import PhotoshootStreamingService
        from app.models.photoshoot import PhotoshootUsage

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        async def _generate_one(job, prompts):
            await PhotoshootJobService.add_generated_image(
                job.job_id,
                "img_1",
                0,
                image_base64="b64",
                image_url="https://cdn.example/x.png",
            )

        post_release_usage = PhotoshootUsage(
            used_today=1,
            limit_today=10,
            remaining=9,
            plan_type="free",
            resets_at=datetime.now(timezone.utc),
        )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                return_value=post_release_usage,
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
                side_effect=_generate_one,
            ),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new_callable=AsyncMock,
            ) as broadcast,
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service.run_pipeline(job)

        assert job.status == PhotoshootJobStatus.COMPLETE
        # Only the one unused slot was handed back.
        release.assert_awaited_once()
        release.assert_awaited_with("user-123", 1, service.db)
        assert job.usage == post_release_usage.model_dump(mode="json")

        complete_events = [
            call.args[2]
            for call in broadcast.await_args_list
            if call.args[1] == "job_complete"
        ]
        assert len(complete_events) == 1
        assert complete_events[0]["generated_count"] == 1
        assert complete_events[0]["usage"] == job.usage
        assert not any(call.args[1] == "job_failed" for call in broadcast.await_args_list)

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_mark_image_failed_retains_error_detail(self):
        """mark_image_failed retains per-index provider detail; first_error
        surfaces the lowest-index failure (stable regardless of arrival order)."""
        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=4,
            batch_size=2,
        )
        await PhotoshootJobService.mark_image_failed(job.job_id, 3, "late failure")
        await PhotoshootJobService.mark_image_failed(job.job_id, 1, "first slot failure")

        assert await PhotoshootJobService.get_first_error(job.job_id) == "first slot failure"

        status = await PhotoshootJobService.get_job_status(job.job_id)
        assert status["failed_indices"] == [1, 3]
        assert status["first_error"] == "first slot failure"

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_exception_after_partial_release_releases_only_remainder(self):
        """An exception AFTER the mid-pipeline partial release must not refund
        the full reservation again. The old generic except released the full
        reservation on top of the partial one (release clamps at 0, so a 0/2
        run over-credited the user 2x); the fix nets the remainder: 1 (unused)
        + 1 (remainder) = 2 = exactly one reservation."""
        from app.services.photoshoot_service import PhotoshootStreamingService

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        async def _generate_one(job, prompts):
            await PhotoshootJobService.add_generated_image(
                job.job_id,
                "img_1",
                0,
                image_base64="b64",
                image_url="https://cdn.example/x.png",
            )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                return_value=Mock(),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
                side_effect=_generate_one,
            ),
            # The terminal block after the partial release fails, so the
            # generic except arm runs with a release already made.
            patch.object(
                PhotoshootJobService,
                "set_usage",
                new_callable=AsyncMock,
                side_effect=RuntimeError("usage store down"),
            ),
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            await service.run_pipeline(job)

        calls = release.await_args_list
        assert [c.args[1] for c in calls] == [1, 1], (
            "expected partial (1 unused) + remainder (1), not a second full release"
        )
        assert sum(c.args[1] for c in calls) == job.num_images
        assert job.status == PhotoshootJobStatus.FAILED

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_zero_image_run_terminal_raise_does_not_release_twice(self):
        """A 0-image run releases the FULL reservation mid-pipeline
        (unused == num_images); if the terminal job_failed block then raises,
        the generic except must NOT release again (released == num_images, so
        the remainder is 0) — the old code refunded the full reservation a
        second time and over-credited the user."""
        from app.services.photoshoot_service import PhotoshootStreamingService

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        async def _fail_all_slots(job, prompts):
            await PhotoshootJobService.mark_image_failed(job.job_id, 1, "provider error")
            await PhotoshootJobService.mark_image_failed(job.job_id, 0, "provider error")

        async def _fail_on_job_failed(job_id, event_type, *args, **kwargs):
            if event_type == "job_failed":
                raise RuntimeError("sse down")

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                return_value=Mock(),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
                side_effect=_fail_all_slots,
            ),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new_callable=AsyncMock,
                side_effect=_fail_on_job_failed,
            ),
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            # The except arm's own job_failed broadcast raises too, so the
            # failure escapes the pipeline.
            with pytest.raises(RuntimeError, match="sse down"):
                await service.run_pipeline(job)

        # Exactly ONE release (the full reservation, mid-pipeline): the
        # generic except found nothing left to refund.
        release.assert_awaited_once()
        release.assert_awaited_with("user-123", 2, service.db)

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)

    @pytest.mark.asyncio
    async def test_cancellation_after_partial_release_releases_only_remainder(self):
        """A cancellation landing AFTER the mid-pipeline partial release must
        hand back only the remainder (job.num_images - released). CancelledError
        derives from BaseException, so it reaches the dedicated arm, which
        previously released the FULL reservation on top of the partial one."""
        import asyncio

        from app.services.photoshoot_service import PhotoshootStreamingService

        job = await PhotoshootJobService.create_job(
            user_id="user-123",
            photos=["data:image/jpeg;base64,SGVsbG8="],
            use_case="linkedin",
            num_images=2,
            batch_size=2,
        )

        async def _generate_one(job, prompts):
            await PhotoshootJobService.add_generated_image(
                job.job_id,
                "img_1",
                0,
                image_base64="b64",
                image_url="https://cdn.example/x.png",
            )

        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, Mock()),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            # The post-release usage re-read is where the cancellation lands.
            patch.object(
                PhotoshootService,
                "get_usage",
                new_callable=AsyncMock,
                side_effect=asyncio.CancelledError,
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new_callable=AsyncMock,
                side_effect=_generate_one,
            ),
        ):
            service = PhotoshootStreamingService(user_id="user-123", db=Mock())
            with pytest.raises(asyncio.CancelledError):
                await service.run_pipeline(job)
            # The shielded release runs as its own task; give the loop a tick.
            await asyncio.sleep(0)

        calls = release.await_args_list
        assert [c.args[1] for c in calls] == [1, 1], (
            "expected partial (1 unused) + remainder (1), not a second full release"
        )
        assert sum(c.args[1] for c in calls) == job.num_images

        async with PhotoshootJobService._lock:
            PhotoshootJobService._jobs.pop(job.job_id, None)


class TestPhotoshootConcurrencyConfig:
    def test_photoshooot_concurrency_default_raised_to_4(self):
        from app.core.config import settings

        assert settings.PHOTOSHOOT_CONCURRENCY_LIMIT == 4


class TestPhotoshootCancellationReleasesQuota:
    """A cancelled run must hand the reserved daily quota back.

    The sync route wraps `generate_photoshoot` in `asyncio.wait_for(...,
    timeout=270)` (photoshoot.py) so the upstream proxy's ~300 s deadline
    returns a clean 503 instead of an opaque 400. `wait_for` CANCELS the
    coroutine, and `asyncio.CancelledError` derives from BaseException — it
    matched neither `except (ValidationError, ...)` nor `except Exception`, so
    `release_daily_usage` never ran and a free user's whole 10/day allowance was
    burned for zero images (retry: "0 images remaining today").
    """

    @pytest.mark.asyncio
    async def test_wait_for_timeout_releases_the_full_reservation(self, mock_db):
        import asyncio

        num_images = 10
        usage = Mock(remaining=num_images, resets_at=None)

        async def _never_finishes(*args, **kwargs):
            await asyncio.sleep(30)

        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, usage),
            ) as reserve,
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new=_never_finishes,
            ),
        ):
            with pytest.raises(asyncio.TimeoutError):
                await asyncio.wait_for(
                    PhotoshootService.generate_photoshoot(
                        user_id="user-123",
                        photos=["data:image/png;base64,aGk="],
                        use_case=PhotoshootUseCase.LINKEDIN,
                        num_images=num_images,
                        db=mock_db,
                    ),
                    timeout=0.05,
                )
            # The shielded release runs as its own task; give the loop a tick
            # to let it finish after the cancellation propagated.
            await asyncio.sleep(0)

        reserve.assert_awaited_once()
        release.assert_awaited_once_with("user-123", num_images, mock_db)

    @pytest.mark.asyncio
    async def test_cancellation_before_reservation_releases_nothing(self, mock_db):
        """No reservation was made, so there is nothing to hand back."""
        import asyncio

        async def _never_finishes(*args, **kwargs):
            await asyncio.sleep(30)

        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new=_never_finishes,
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
        ):
            with pytest.raises(asyncio.TimeoutError):
                await asyncio.wait_for(
                    PhotoshootService.generate_photoshoot(
                        user_id="user-123",
                        photos=["data:image/png;base64,aGk="],
                        use_case=PhotoshootUseCase.LINKEDIN,
                        num_images=4,
                        db=mock_db,
                    ),
                    timeout=0.05,
                )
            await asyncio.sleep(0)

        release.assert_not_awaited()

    @pytest.mark.asyncio
    async def test_sync_exception_after_partial_release_releases_only_remainder(self, mock_db):
        """generate_photoshoot's generic except must refund only what the
        mid-pipeline partial release did not cover. An exception in the
        response construction after releasing 1 of 2 images used to trigger a
        second FULL release (over-credit); the fix nets to exactly one
        reservation."""
        usage = Mock(remaining=2, resets_at=None)

        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new_callable=AsyncMock,
                return_value=(True, usage),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new_callable=AsyncMock,
            ) as release,
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new_callable=AsyncMock,
                return_value=[],
            ),
            patch.object(
                PhotoshootService,
                "generate_images",
                new_callable=AsyncMock,
                return_value=([Mock()], []),
            ),
            patch(
                "app.services.photoshoot_service.PhotoshootResultResponse",
                side_effect=RuntimeError("serialization boom"),
            ),
        ):
            with pytest.raises(ServiceError):
                await PhotoshootService.generate_photoshoot(
                    user_id="user-123",
                    photos=["data:image/png;base64,aGk="],
                    use_case=PhotoshootUseCase.LINKEDIN,
                    num_images=2,
                    db=mock_db,
                )

        calls = release.await_args_list
        assert [c.args[1] for c in calls] == [1, 1], (
            "expected partial (1 unused) + remainder (1), not a second full release"
        )
        assert sum(c.args[1] for c in calls) == 2
