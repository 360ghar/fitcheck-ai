"""
Coverage companion for app/services/photoshoot_service.py.

Covers the branches the sibling photoshoot tests miss: session creation
(validation, limits, quota RPCs), prompt generation retry/fallback paths,
image generation fan-out, sync/streaming pipeline error arms, and
cancellation quota refunds. All DB work runs against FakeDB or mocked
collaborators; AI providers are async fakes injected through
``app.services.ai_provider_service.get_ai_service`` /
``AISettingsService.get_ai_service_for_user``.
"""

import asyncio
import json
from datetime import date, timedelta
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, Mock, patch

import pytest

from app.core.exceptions import (
    DatabaseError,
    RateLimitError,
    ServiceError,
    ValidationError,
)
from app.models.photoshoot import (
    GeneratedImage,
    ImageGenerationFailure,
    PhotoshootPrompt,
    PhotoshootStatus,
    PhotoshootUsage,
)
from app.models.subscription import PlanType
from app.services.photoshoot_job_service import PhotoshootJobService, PhotoshootJobStatus
from app.services.photoshoot_service import (
    PhotoshootService,
    PhotoshootStreamingService,
    PhotoshootUseCase,
    _release_reservation_on_cancel,
    _scene_label,
)
from app.services.subscription_service import SubscriptionService
from app.utils.datetime_util import utc_today, utcnow


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #


def _prompt(index: int, **overrides) -> PhotoshootPrompt:
    fields = dict(
        index=index,
        setting=f"Setting {index}",
        outfit=f"Outfit {index}",
        pose=f"Pose {index}",
        lighting=f"Lighting {index}",
        style=f"Style {index}",
        mood=f"Mood {index}",
        full_prompt=f"Full prompt {index}",
    )
    fields.update(overrides)
    return PhotoshootPrompt(**fields)


def _usage() -> PhotoshootUsage:
    return PhotoshootUsage(
        used_today=2,
        limit_today=10,
        remaining=8,
        plan_type="free",
        resets_at=utcnow() + timedelta(hours=12),
    )


def _pro_daily_limit() -> int:
    from app.core.config import settings

    return settings.PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES


def _valid_prompts_json(num_prompts: int = 2) -> str:
    return json.dumps(
        {
            "subject_lock": "Adult person with short dark hair",
            "subject_description": "Adult person with short dark hair",
            "prompts": [
                {
                    "index": i,
                    "setting": f"Setting {i}",
                    "outfit": f"Outfit {i}",
                    "pose": f"Pose {i}",
                    "lighting": f"Lighting {i}",
                    "style": f"Style {i}",
                    "mood": f"Mood {i}",
                    "scene_body": f"Scene body {i}",
                }
                for i in range(num_prompts)
            ],
        }
    )


class _PromptAI:
    """Fake multimodal AI service: returns canned response texts per call."""

    def __init__(self, *texts):
        self.texts = list(texts)
        self.closed = False
        self.chat_kwargs = []

    async def chat(self, **kwargs):
        self.chat_kwargs.append(kwargs)
        return SimpleNamespace(text=self.texts.pop(0))

    async def close(self):
        self.closed = True


class _ImageAI:
    """Fake image AI service: returns canned image lists per call.

    An ``Exception`` argument is raised from ``chat`` so the service's
    per-image exception branch can be exercised deterministically.
    """

    def __init__(self, *image_lists):
        self.image_lists = list(image_lists)
        self.closed = False
        self.chat_kwargs = []

    async def chat(self, **kwargs):
        self.chat_kwargs.append(kwargs)
        item = self.image_lists.pop(0)
        if isinstance(item, Exception):
            raise item
        return SimpleNamespace(images=item, model="fake-model", provider="fake-provider")

    def get_image_gen_model(self):
        return "img-model"

    async def close(self):
        self.closed = True


async def _cleanup_job(job_id: str) -> None:
    async with PhotoshootJobService._lock:
        PhotoshootJobService._jobs.pop(job_id, None)


# --------------------------------------------------------------------------- #
# _release_reservation_on_cancel
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_release_reservation_on_cancel_swallows_release_failure():
    with patch.object(
        PhotoshootService,
        "release_daily_usage",
        new=AsyncMock(side_effect=RuntimeError("release boom")),
    ):
        await _release_reservation_on_cancel("u1", 3, Mock(), session_id="ps_x")
    # A failed release must never replace the in-flight cancellation.


@pytest.mark.asyncio
async def test_release_reservation_on_cancel_swallows_cancelled_error():
    with patch.object(
        PhotoshootService,
        "release_daily_usage",
        new=AsyncMock(side_effect=asyncio.CancelledError()),
    ):
        await _release_reservation_on_cancel("u1", 3, Mock(), job_id="job_x")


# --------------------------------------------------------------------------- #
# Use case info / daily usage tracking
# --------------------------------------------------------------------------- #


def test_get_use_cases_returns_all_templates():
    use_cases = PhotoshootService.get_use_cases()
    assert {u.id for u in use_cases} == {
        "linkedin",
        "dating_app",
        "model_portfolio",
        "instagram",
        "aesthetic",
        "custom",
    }


def test_get_today_returns_utc_date():
    assert PhotoshootService._get_today() == utc_today()


def test_get_daily_limit_plus_plan():
    from app.core.config import settings

    assert PhotoshootService._get_daily_limit(PlanType.PLUS_MONTHLY) == settings.PLAN_PLUS_DAILY_PHOTOSHOOT_IMAGES
    assert PhotoshootService._get_daily_limit(PlanType.PLUS_YEARLY) == settings.PLAN_PLUS_DAILY_PHOTOSHOOT_IMAGES


@pytest.mark.asyncio
async def test_get_or_create_daily_usage_returns_existing_record(fake_db):
    period_start = SubscriptionService._get_current_period_start().isoformat()
    fake_db.rows["subscription_usage"] = [
        {
            "user_id": "u1",
            "period_start": period_start,
            "daily_photoshoot_images": 5,
            "last_photoshoot_reset": "2026-01-01",
        }
    ]
    result = await PhotoshootService.get_or_create_daily_usage("u1", fake_db)
    assert result["daily_photoshoot_images"] == 5
    # The DB-side reset RPC was attempted before the read.
    assert fake_db.rpc_calls[0][0] == "reset_daily_photoshoot_if_needed"


@pytest.mark.asyncio
async def test_get_or_create_daily_usage_tolerates_missing_reset_rpc(fake_db):
    import app.services.photoshoot_service as photoshoot_module
    from app.utils import db as db_utils

    period_start = SubscriptionService._get_current_period_start().isoformat()
    fake_db.rows["subscription_usage"] = [
        {"user_id": "u1", "period_start": period_start, "daily_photoshoot_images": 1}
    ]
    real_execute = db_utils.execute_with_reconnect

    async def _fake_execute(builder, db, **kwargs):
        if kwargs.get("extra", {}).get("operation") == "reset_daily_photoshoot_if_needed":
            raise RuntimeError("PGRST202: could not find the function")
        return await real_execute(builder, db, **kwargs)

    with patch.object(photoshoot_module, "execute_with_reconnect", new=_fake_execute):
        result = await PhotoshootService.get_or_create_daily_usage("u1", fake_db)
    assert result["daily_photoshoot_images"] == 1


@pytest.mark.asyncio
async def test_get_or_create_daily_usage_raises_database_error():
    with patch.object(
        SubscriptionService,
        "get_or_create_usage_record",
        new=AsyncMock(side_effect=RuntimeError("usage table down")),
    ):
        with pytest.raises(DatabaseError, match="Failed to get daily usage"):
            await PhotoshootService.get_or_create_daily_usage("u1", Mock())


@pytest.mark.asyncio
async def test_get_usage_computes_remaining_without_reset(fake_db):
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(return_value={"daily_photoshoot_images": 3}),
        ),
    ):
        usage = await PhotoshootService.get_usage("u1", fake_db)

    assert usage.used_today == 3
    assert usage.remaining == usage.limit_today - 3
    assert usage.plan_type == "free"
    assert usage.resets_at is not None and usage.resets_at > utcnow()
    # No stale daily counter, so no app-side reset write.
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_get_usage_resets_stale_string_last_reset(fake_db):
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(
                return_value={
                    "daily_photoshoot_images": 7,
                    "last_photoshoot_reset": "2000-01-01",
                }
            ),
        ),
    ):
        usage = await PhotoshootService.get_usage("u1", fake_db)

    assert usage.used_today == 0
    assert fake_db.updates == [("subscription_usage", {"daily_photoshoot_images": 0, "last_photoshoot_reset": utc_today().isoformat()})]


@pytest.mark.asyncio
async def test_get_usage_resets_stale_date_last_reset(fake_db):
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(
                return_value={
                    "daily_photoshoot_images": 7,
                    "last_photoshoot_reset": date(2000, 1, 1),
                }
            ),
        ),
    ):
        usage = await PhotoshootService.get_usage("u1", fake_db)
    assert usage.used_today == 0


@pytest.mark.asyncio
async def test_get_usage_tolerates_unparseable_last_reset(fake_db):
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(
                return_value={
                    "daily_photoshoot_images": 4,
                    "last_photoshoot_reset": "not-a-date",
                }
            ),
        ),
    ):
        usage = await PhotoshootService.get_usage("u1", fake_db)
    assert usage.used_today == 4
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_get_usage_skips_reset_when_last_reset_is_today(fake_db):
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(
                return_value={
                    "daily_photoshoot_images": 6,
                    "last_photoshoot_reset": utc_today().isoformat(),
                }
            ),
        ),
    ):
        usage = await PhotoshootService.get_usage("u1", fake_db)
    assert usage.used_today == 6
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_get_usage_raises_database_error():
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(side_effect=RuntimeError("subs down")),
    ):
        with pytest.raises(DatabaseError, match="Failed to get photoshoot usage"):
            await PhotoshootService.get_usage("u1", Mock())


# --------------------------------------------------------------------------- #
# reserve / release / increment
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_reserve_daily_usage_rejects_non_positive():
    with pytest.raises(ValueError, match="num_images must be positive"):
        await PhotoshootService.reserve_daily_usage("u1", 0, Mock())


@pytest.mark.asyncio
async def test_reserve_daily_usage_success(fake_db):
    fake_db.rpc_results["reserve_daily_photoshoot_usage"] = [
        {"reserve_daily_photoshoot_usage": True}
    ]
    usage = _usage()
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.PRO_MONTHLY)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(return_value={}),
        ),
        patch.object(PhotoshootService, "get_usage", new=AsyncMock(return_value=usage)),
    ):
        allowed, returned_usage = await PhotoshootService.reserve_daily_usage("u1", 3, fake_db)

    assert allowed is True
    assert returned_usage is usage
    name, params = fake_db.rpc_calls[0]
    assert name == "reserve_daily_photoshoot_usage"
    assert params["p_user_id"] == "u1"
    assert params["p_count"] == 3
    assert params["p_limit"] == _pro_daily_limit()


@pytest.mark.asyncio
async def test_reserve_daily_usage_returns_false_when_rejected(fake_db):
    fake_db.rpc_results["reserve_daily_photoshoot_usage"] = [
        {"reserve_daily_photoshoot_usage": False}
    ]
    usage = _usage()
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(return_value={}),
        ),
        patch.object(PhotoshootService, "get_usage", new=AsyncMock(return_value=usage)),
    ):
        allowed, _ = await PhotoshootService.reserve_daily_usage("u1", 3, fake_db)
    assert allowed is False


@pytest.mark.asyncio
async def test_reserve_daily_usage_accepts_reserved_key(fake_db):
    fake_db.rpc_results["reserve_daily_photoshoot_usage"] = [{"reserved": True}]
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(return_value={}),
        ),
        patch.object(PhotoshootService, "get_usage", new=AsyncMock(return_value=_usage())),
    ):
        allowed, _ = await PhotoshootService.reserve_daily_usage("u1", 1, fake_db)
    assert allowed is True


@pytest.mark.asyncio
async def test_reserve_daily_usage_raises_database_error_on_rpc_failure():
    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError("rpc boom")
    with (
        patch.object(
            SubscriptionService,
            "get_subscription",
            new=AsyncMock(return_value=SimpleNamespace(plan_type=PlanType.FREE)),
        ),
        patch.object(
            PhotoshootService,
            "get_or_create_daily_usage",
            new=AsyncMock(return_value={}),
        ),
    ):
        with pytest.raises(DatabaseError, match="Failed to reserve photoshoot usage"):
            await PhotoshootService.reserve_daily_usage("u1", 3, db)


@pytest.mark.asyncio
async def test_release_daily_usage_skips_non_positive(fake_db):
    await PhotoshootService.release_daily_usage("u1", 0, fake_db)
    assert fake_db.rpc_calls == []


@pytest.mark.asyncio
async def test_release_daily_usage_calls_release_rpc(fake_db):
    await PhotoshootService.release_daily_usage("u1", 2, fake_db)
    name, params = fake_db.rpc_calls[0]
    assert name == "release_daily_photoshoot_usage"
    assert params == {
        "p_user_id": "u1",
        "p_period_start": SubscriptionService._get_current_period_start().isoformat(),
        "p_count": 2,
    }


@pytest.mark.asyncio
async def test_release_daily_usage_tolerates_rpc_failure():
    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError("rpc boom")
    # Best-effort by contract: the failure is logged, never raised.
    await PhotoshootService.release_daily_usage("u1", 2, db)


@pytest.mark.asyncio
async def test_increment_usage_raises_rate_limit_when_not_reserved():
    with patch.object(
        PhotoshootService,
        "reserve_daily_usage",
        new=AsyncMock(return_value=(False, _usage())),
    ):
        with pytest.raises(RateLimitError, match="Daily photoshoot limit exceeded"):
            await PhotoshootService.increment_usage("u1", 3, Mock())


@pytest.mark.asyncio
async def test_increment_usage_wraps_reservation_failure():
    with patch.object(
        PhotoshootService,
        "reserve_daily_usage",
        new=AsyncMock(side_effect=DatabaseError("reserve down")),
    ):
        with pytest.raises(DatabaseError):
            await PhotoshootService.increment_usage("u1", 3, Mock())


# --------------------------------------------------------------------------- #
# generate_prompts
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_generate_prompts_returns_object_format_prompts():
    ai = _PromptAI(_valid_prompts_json(2))
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=2
        )

    assert len(prompts) == 2
    assert prompts[0].full_prompt and "Adult person with short dark hair" in prompts[0].full_prompt
    assert prompts[0].full_prompt and "Scene body 0" in prompts[0].full_prompt
    assert prompts[1].index == 1
    assert ai.closed is True
    # First attempt, non-strict, text-only user content (no reference photo).
    user_content = ai.chat_kwargs[0]["messages"][1].content
    assert isinstance(user_content, str)


@pytest.mark.asyncio
async def test_generate_prompts_with_reference_photo_sends_image_content():
    ai = _PromptAI(_valid_prompts_json(1))
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.INSTAGRAM,
            num_prompts=1,
            reference_photo="data:image/jpeg;base64,aGVsbG8=",
        )

    assert len(prompts) == 1
    user_content = ai.chat_kwargs[0]["messages"][1].content
    assert isinstance(user_content, list)
    assert user_content[0]["type"] == "image_url"
    assert user_content[0]["image_url"]["url"].startswith("data:image/jpeg;base64,")
    assert user_content[1]["type"] == "text"


@pytest.mark.asyncio
async def test_generate_prompts_with_plain_string_reference_photo():
    """A bare base64 reference (no data: prefix) is downscaled as-is."""
    ai = _PromptAI(_valid_prompts_json(1))
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN,
            num_prompts=1,
            reference_photo="aGVsbG8=",
        )
    assert len(prompts) == 1
    assert ai.chat_kwargs[0]["messages"][1].content[0]["image_url"]["url"].startswith(
        "data:image/jpeg;base64,"
    )


@pytest.mark.asyncio
async def test_generate_prompts_custom_use_case_uses_custom_guidance():
    ai = _PromptAI("no json here", "no json here")
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.CUSTOM,
            num_prompts=2,
            custom_prompt="beach party",
        )

    # Both attempts failed to parse -> template fallback carrying the theme.
    assert len(prompts) == 2
    assert "Theme: beach party." in prompts[0].full_prompt
    assert ai.closed is True


@pytest.mark.asyncio
async def test_generate_prompts_retries_after_empty_response():
    ai = _PromptAI("", _valid_prompts_json(1))
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=1
        )
    assert len(prompts) == 1
    assert len(ai.chat_kwargs) == 2
    # The retry nudge appends the strict "JSON only" instruction.
    assert "Return ONLY a JSON object" in ai.chat_kwargs[1]["messages"][1].content


@pytest.mark.asyncio
async def test_generate_prompts_retries_after_parse_failure():
    ai = _PromptAI("Here is your output: nothing parseable", _valid_prompts_json(1))
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.DATING_APP, num_prompts=1
        )
    assert len(prompts) == 1
    assert len(ai.chat_kwargs) == 2


@pytest.mark.asyncio
async def test_generate_prompts_falls_back_when_both_attempts_empty():
    ai = _PromptAI("", "")
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.AESTHETIC, num_prompts=3
        )
    assert len(prompts) == 3
    assert all(p.full_prompt for p in prompts)


@pytest.mark.asyncio
async def test_generate_prompts_falls_back_when_both_attempts_unparseable():
    ai = _PromptAI("prose only", "prose only")
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.MODEL_PORTFOLIO, num_prompts=2
        )
    assert len(prompts) == 2


@pytest.mark.asyncio
async def test_generate_prompts_falls_back_when_response_is_null():
    ai = _PromptAI("null")
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=1
        )
    assert len(prompts) == 1


@pytest.mark.asyncio
async def test_generate_prompts_handles_legacy_list_format():
    payload = json.dumps(
        [{"index": 0, "setting": "S", "outfit": "O", "pose": "P", "lighting": "L", "style": "ST", "mood": "M", "full_prompt": "legacy list prompt"}]
    )
    ai = _PromptAI(payload)
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=1
        )
    assert len(prompts) == 1
    assert prompts[0].full_prompt == "legacy list prompt"


@pytest.mark.asyncio
async def test_generate_prompts_list_format_without_full_prompt():
    """List-format prompts with no full_prompt and no subject lock still get a
    composed scene body via the sandwich fallback."""
    payload = json.dumps(
        [{"index": 0, "setting": "S", "outfit": "O", "pose": "P", "lighting": "L", "style": "ST", "mood": "M"}]
    )
    ai = _PromptAI(payload)
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=1
        )
    assert len(prompts) == 1
    assert "Setting: S" in prompts[0].full_prompt


@pytest.mark.asyncio
async def test_generate_prompts_composes_scene_body_and_legacy_fallbacks():
    payload = json.dumps(
        {
            "subject_lock": "LOCK",
            "prompts": [
                # No scene_body -> composed from fields.
                {"index": 0, "setting": "A", "outfit": "B", "pose": "C", "lighting": "D", "style": "E", "mood": "F"},
                # No scene_body and no fields -> legacy full_prompt gets sandwched.
                {"index": 1, "full_prompt": "legacy without lock"},
                # Legacy full_prompt already carries the lock -> unchanged.
                {"index": 2, "full_prompt": "LOCK already included"},
            ],
        }
    )
    ai = _PromptAI(payload)
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=3
        )
    assert len(prompts) == 3
    composed = prompts[0].full_prompt
    assert "Setting: A" in composed and "Mood: F" in composed
    assert "LOCK" in prompts[1].full_prompt
    assert prompts[2].full_prompt == "LOCK already included"


@pytest.mark.asyncio
async def test_generate_prompts_skips_invalid_entries():
    payload = json.dumps(
        {
            "subject_lock": "LOCK",
            "prompts": [
                "not a dict",
                {"index": 1, "setting": "S", "outfit": "O", "pose": "P", "lighting": "L", "style": "ST", "mood": "M"},
                {"index": 2, "full_prompt": "legacy fp"},
                {"index": 3, "setting": "S3", "outfit": "O3", "pose": "P3", "lighting": "L3", "style": "ST3", "mood": "M3"},
            ],
        }
    )
    ai = _PromptAI(payload)
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=3
        )
    # The non-dict entry consumes one of the three sliced slots, so only 2 of
    # the requested 3 prompts are produced -> template fallback (seeded with
    # the response's subject lock).
    assert len(prompts) == 3
    assert "LOCK" in prompts[0].full_prompt


@pytest.mark.asyncio
async def test_generate_prompts_falls_back_on_under_generation():
    payload = json.dumps(
        {
            "subject_lock": "LOCKHINT",
            "prompts": [
                {"index": 0, "setting": "S", "outfit": "O", "pose": "P", "lighting": "L", "style": "ST", "mood": "M"},
                {},  # skipped entirely
            ],
        }
    )
    ai = _PromptAI(payload)
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=2
        )
    # Under-generated -> template fallback seeded with the subject hint.
    assert len(prompts) == 2
    assert "LOCKHINT" in prompts[0].full_prompt


@pytest.mark.asyncio
async def test_generate_prompts_falls_back_on_invalid_response_type():
    ai = _PromptAI('"just a string"')
    with patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)):
        prompts = await PhotoshootService.generate_prompts(
            use_case=PhotoshootUseCase.LINKEDIN, num_prompts=2
        )
    assert len(prompts) == 2


# --------------------------------------------------------------------------- #
# generate_images
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_generate_images_requires_reference_photo():
    with pytest.raises(ServiceError, match="At least one reference photo is required"):
        await PhotoshootService.generate_images(reference_photos=[], prompts=[_prompt(0)])


@pytest.mark.asyncio
async def test_generate_images_success_with_user_ai_settings():
    ai = _ImageAI(["img-b64-0"], ["img-b64-1"])
    prompts = [_prompt(0), _prompt(1)]
    with (
        patch(
            "app.services.ai_settings_service.AISettingsService.get_ai_service_for_user",
            new=AsyncMock(return_value=ai),
        ),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        images, failures = await PhotoshootService.generate_images(
            reference_photos=["data:image/jpeg;base64,aGVsbG8=", "data:image/jpeg;base64,aGVsbG8="],
            prompts=prompts,
            user_id="u1",
            db=Mock(),
        )

    assert len(images) == 2
    assert [img.index for img in images] == [0, 1]
    assert images[0].image_base64 == "img-b64-0"
    assert failures == []
    assert ai.closed is True
    # The image-generation model is passed through.
    assert ai.chat_kwargs[0]["model"] == "img-model"
    assert ai.chat_kwargs[0]["response_modalities"] == ["TEXT", "IMAGE"]


@pytest.mark.asyncio
async def test_generate_images_success_with_default_ai_service():
    ai = _ImageAI(["img-b64"])
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        images, failures = await PhotoshootService.generate_images(
            reference_photos=["plain-ref-without-prefix"],
            prompts=[_prompt(0)],
        )
    assert len(images) == 1
    assert failures == []


@pytest.mark.asyncio
async def test_generate_images_skips_empty_reference_photos():
    ai = _ImageAI(["img-b64"])
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        images, _failures = await PhotoshootService.generate_images(
            reference_photos=["", "data:image/jpeg;base64,aGVsbG8="],
            prompts=[_prompt(0)],
        )
    # The empty entry is dropped; the data-URL one still generates.
    assert len(images) == 1


@pytest.mark.asyncio
async def test_generate_images_all_silent_refusals_raise():
    ai = _ImageAI([])
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        with pytest.raises(ServiceError, match="All image generations failed"):
            await PhotoshootService.generate_images(
                reference_photos=["data:image/jpeg;base64,aGVsbG8="],
                prompts=[_prompt(0)],
            )


@pytest.mark.asyncio
async def test_generate_images_records_exceptions_and_partial_success():
    ai = _ImageAI(RuntimeError("provider exploded"), ["img-b64"])
    with (
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        images, failures = await PhotoshootService.generate_images(
            reference_photos=["data:image/jpeg;base64,aGVsbG8="],
            prompts=[_prompt(0), _prompt(1)],
        )

    assert len(images) == 1
    assert images[0].index == 1
    assert len(failures) == 1
    assert failures[0].index == 0
    # A provider exception is caught inside the semaphore wrapper and surfaces
    # as a generic "no result" failure (the detail stays in server logs).
    assert failures[0].error == "Image generation returned no result"


class _BoomSlot:
    """image_gen_slot stand-in whose acquisition raises: the exception escapes
    generate_with_semaphore (the try wraps only generate_single) and surfaces
    as an Exception result in the gather."""

    async def __aenter__(self):
        raise RuntimeError("slot acquisition failed")

    async def __aexit__(self, exc_type, exc, tb):
        return False


@pytest.mark.asyncio
async def test_generate_images_records_slot_acquisition_failures():
    """A failure outside generate_single (semaphore acquisition) is NOT
    swallowed by the per-image handler: the gather surfaces it as an Exception
    result and it is recorded as an exception failure."""
    ai = _ImageAI(["img-b64"])
    with (
        patch("app.services.photoshoot_service.image_gen_slot", return_value=_BoomSlot()),
        patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
        patch(
            "app.core.image_executor.run_image_op",
            new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
        ),
        patch(
            "app.utils.image_processing.downscale_base64_image",
            side_effect=lambda raw: raw,
        ),
    ):
        with pytest.raises(ServiceError, match="All image generations failed"):
            await PhotoshootService.generate_images(
                reference_photos=["data:image/jpeg;base64,aGVsbG8="],
                prompts=[_prompt(0), _prompt(1)],
            )


# --------------------------------------------------------------------------- #
# generate_photoshoot (sync flow)
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_generate_photoshoot_requires_custom_prompt():
    with pytest.raises(ValidationError, match="Custom prompt is required"):
        await PhotoshootService.generate_photoshoot(
            user_id="u1",
            photos=["data:image/jpeg;base64,aGVsbG8="],
            use_case=PhotoshootUseCase.CUSTOM,
            num_images=2,
            db=Mock(),
        )


@pytest.mark.asyncio
async def test_generate_photoshoot_rate_limit_exceeded():
    usage = SimpleNamespace(remaining=0, resets_at=utcnow() + timedelta(hours=1))
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(False, usage)),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
    ):
        with pytest.raises(RateLimitError, match="Daily limit exceeded"):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=Mock(),
            )
    # Nothing was reserved, so nothing is handed back.
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_generate_photoshoot_success():
    usage = _usage()
    images = [
        GeneratedImage(id="img_0", index=0, image_base64="b64"),
        GeneratedImage(id="img_1", index=1, image_base64="b64"),
    ]
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, usage)),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(return_value=[_prompt(0), _prompt(1)]),
        ),
        patch.object(
            PhotoshootService,
            "generate_images",
            new=AsyncMock(return_value=(images, [])),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
    ):
        result = await PhotoshootService.generate_photoshoot(
            user_id="u1",
            photos=["data:image/jpeg;base64,aGVsbG8="],
            use_case=PhotoshootUseCase.LINKEDIN,
            num_images=2,
            db=Mock(),
        )

    assert result.session_id.startswith("ps_")
    assert result.status == PhotoshootStatus.COMPLETE
    assert result.images == images
    assert result.usage is usage
    assert result.generated_count == 2
    assert result.failed_count == 0
    assert result.partial_success is False
    assert result.generation_time_seconds is not None
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_generate_photoshoot_releases_unused_quota():
    db = Mock()
    image = GeneratedImage(id="img_1", index=0, image_base64="b64")
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, _usage())),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(return_value=[_prompt(0), _prompt(1)]),
        ),
        patch.object(
            PhotoshootService,
            "generate_images",
            new=AsyncMock(
                return_value=([image], [ImageGenerationFailure(index=1, error="nope")])
            ),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
    ):
        result = await PhotoshootService.generate_photoshoot(
            user_id="u1",
            photos=["data:image/jpeg;base64,aGVsbG8="],
            use_case=PhotoshootUseCase.LINKEDIN,
            num_images=2,
            db=db,
        )

    # One of the two reserved images never produced output: it is handed back.
    release.assert_awaited_once_with("u1", 1, db)
    assert result.partial_success is True
    assert result.failed_count == 1


@pytest.mark.asyncio
async def test_generate_photoshoot_releases_reservation_on_service_error():
    db = Mock()
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, _usage())),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(side_effect=ServiceError("prompt gen down")),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
    ):
        with pytest.raises(ServiceError, match="prompt gen down"):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=db,
            )
    release.assert_awaited_once_with("u1", 2, db)


@pytest.mark.asyncio
async def test_generate_photoshoot_generic_error_before_reservation():
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(side_effect=RuntimeError("admission crash")),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
    ):
        with pytest.raises(ServiceError, match="Photoshoot generation failed"):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=Mock(),
            )
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_generate_photoshoot_generic_error_after_full_release():
    db = Mock()
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, _usage())),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(return_value=[_prompt(0), _prompt(1)]),
        ),
        patch.object(
            PhotoshootService,
            "generate_images",
            new=AsyncMock(return_value=([], [])),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
        patch(
            "app.services.photoshoot_service.PhotoshootResultResponse",
            side_effect=RuntimeError("serialization boom"),
        ),
    ):
        with pytest.raises(ServiceError, match="Photoshoot generation failed"):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=db,
            )
    # The mid-pipeline release already handed back the FULL reservation (2 of 2
    # images failed), so the error arm must not release again.
    release.assert_awaited_once_with("u1", 2, db)


@pytest.mark.asyncio
async def test_generate_photoshoot_cancelled_after_full_release():
    """A cancellation landing AFTER the mid-pipeline release (released ==
    num_images) must not hand the reservation back a second time."""
    db = Mock()
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, _usage())),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(return_value=[_prompt(0), _prompt(1)]),
        ),
        patch.object(
            PhotoshootService,
            "generate_images",
            new=AsyncMock(return_value=([], [])),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
        patch(
            "app.services.photoshoot_service.PhotoshootResultResponse",
            side_effect=asyncio.CancelledError(),
        ),
    ):
        with pytest.raises(asyncio.CancelledError):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=db,
            )
    # Exactly ONE release: the mid-pipeline one. The cancellation arm found
    # nothing left to refund (remaining == 0).
    release.assert_awaited_once_with("u1", 2, db)


@pytest.mark.asyncio
async def test_generate_photoshoot_database_error_after_full_release():
    """The DatabaseError arm also nets against the mid-pipeline release."""
    db = Mock()
    with (
        patch.object(
            PhotoshootService,
            "reserve_daily_usage",
            new=AsyncMock(return_value=(True, _usage())),
        ),
        patch.object(
            PhotoshootService,
            "generate_prompts",
            new=AsyncMock(return_value=[_prompt(0), _prompt(1)]),
        ),
        patch.object(
            PhotoshootService,
            "generate_images",
            new=AsyncMock(return_value=([], [])),
        ),
        patch.object(PhotoshootService, "release_daily_usage", new=AsyncMock()) as release,
        patch(
            "app.services.photoshoot_service.PhotoshootResultResponse",
            side_effect=DatabaseError("usage read failed"),
        ),
    ):
        with pytest.raises(DatabaseError, match="usage read failed"):
            await PhotoshootService.generate_photoshoot(
                user_id="u1",
                photos=["data:image/jpeg;base64,aGVsbG8="],
                use_case=PhotoshootUseCase.LINKEDIN,
                num_images=2,
                db=db,
            )
    release.assert_awaited_once_with("u1", 2, db)


# --------------------------------------------------------------------------- #
# Streaming pipeline (run_pipeline)
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_streaming_pipeline_rate_limit_broadcasts_failed():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=2,
        batch_size=2,
    )
    try:
        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new=AsyncMock(return_value=(False, SimpleNamespace(remaining=0, resets_at=None))),
            ),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new=AsyncMock(),
            ) as broadcast,
        ):
            service = PhotoshootStreamingService(user_id="u1", db=Mock())
            await service.run_pipeline(job)

        assert job.error_message and "Daily limit exceeded" in job.error_message
        failed_payloads = [
            call.args[2] for call in broadcast.await_args_list if call.args[1] == "job_failed"
        ]
        assert len(failed_payloads) == 1
        assert "Daily limit exceeded" in failed_payloads[0]["error"]
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_streaming_pipeline_demo_cancelled_releases_nothing():
    job = await PhotoshootJobService.create_job(
        user_id="demo_1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="aesthetic",
        num_images=2,
        batch_size=2,
    )
    try:
        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new=AsyncMock(return_value=[]),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new=AsyncMock(),
            ) as release,
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new=AsyncMock(side_effect=asyncio.CancelledError()),
            ),
        ):
            service = PhotoshootStreamingService(user_id="demo_1", db=None, is_demo=True)
            with pytest.raises(asyncio.CancelledError):
                await service.run_pipeline(job)
        release.assert_not_awaited()
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_streaming_pipeline_demo_generic_error_broadcasts_failed():
    job = await PhotoshootJobService.create_job(
        user_id="demo_1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="aesthetic",
        num_images=2,
        batch_size=2,
    )
    try:
        with (
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new=AsyncMock(return_value=[]),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new=AsyncMock(side_effect=RuntimeError("pipeline boom")),
            ),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new=AsyncMock(),
            ) as broadcast,
        ):
            service = PhotoshootStreamingService(user_id="demo_1", db=None, is_demo=True)
            await service.run_pipeline(job)

        assert job.error_message == "pipeline boom"
        assert any(call.args[1] == "job_failed" for call in broadcast.await_args_list)
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_streaming_pipeline_returns_early_when_job_cancelled_after_streaming():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=2,
        batch_size=2,
    )

    async def _cancel_then_return(job, prompts):
        await PhotoshootJobService.cancel_job(job.job_id, job.user_id)

    try:
        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new=AsyncMock(return_value=(True, _usage())),
            ),
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new=AsyncMock(return_value=[]),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new=AsyncMock(),
            ) as release,
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new=AsyncMock(side_effect=_cancel_then_return),
            ),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=Mock())
            result = await service.run_pipeline(job)

        assert result is None
        assert job.status == PhotoshootJobStatus.CANCELLED
        # Nothing was generated, so the full reservation is handed back even
        # though the run stops early on the cancellation check.
        release.assert_awaited_once_with("u1", 2, service.db)
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_streaming_pipeline_cancelled_after_full_release():
    """A cancellation after the FULL mid-pipeline release (released ==
    num_images) must not hand the reservation back a second time."""
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=2,
        batch_size=2,
    )
    try:
        with (
            patch.object(
                PhotoshootService,
                "reserve_daily_usage",
                new=AsyncMock(return_value=(True, _usage())),
            ),
            patch.object(
                PhotoshootService,
                "generate_prompts",
                new=AsyncMock(return_value=[]),
            ),
            patch.object(
                PhotoshootService,
                "release_daily_usage",
                new=AsyncMock(),
            ) as release,
            # 0 images -> the FULL reservation is released mid-pipeline; the
            # cancellation lands on the post-release usage re-read.
            patch.object(
                PhotoshootService,
                "get_usage",
                new=AsyncMock(side_effect=asyncio.CancelledError()),
            ),
            patch.object(
                PhotoshootStreamingService,
                "_generate_images_streaming",
                new=AsyncMock(),
            ),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=Mock())
            with pytest.raises(asyncio.CancelledError):
                await service.run_pipeline(job)
            await asyncio.sleep(0)

        release.assert_awaited_once()
        release.assert_awaited_with("u1", 2, service.db)
    finally:
        await _cleanup_job(job.job_id)


# --------------------------------------------------------------------------- #
# Streaming image generation
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_generate_images_streaming_demo_batches_success():
    ai = _ImageAI(["img-b64-1"], ["img-b64-2"])
    job = await PhotoshootJobService.create_job(
        user_id="demo_1",
        photos=["data:image/jpeg;base64,aGVsbG8=", "plain-ref"],
        use_case="aesthetic",
        num_images=2,
        batch_size=1,
    )
    prompts = [_prompt(0), _prompt(1)]
    try:
        with (
            patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
            patch(
                "app.core.image_executor.run_image_op",
                new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
            ),
            patch(
                "app.utils.image_processing.downscale_base64_image",
                side_effect=lambda raw: raw,
            ),
        ):
            service = PhotoshootStreamingService(user_id="demo_1", db=None, is_demo=True)
            await service._generate_images_streaming(job, prompts)

        assert job.generated_count == 2
        assert ai.closed is True
        history = await PhotoshootJobService.get_event_history(job.job_id)
        assert len([e for e in history if e["type"] == "image_complete"]) == 2
        assert len([e for e in history if e["type"] == "batch_started"]) == 2
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_generate_images_streaming_skips_downscale_when_photos_empty():
    ai = _ImageAI(["img-b64"])
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["", "   "],
        use_case="linkedin",
        num_images=1,
        batch_size=1,
    )
    try:
        with (
            patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
            patch(
                "app.core.image_executor.run_image_op",
                new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
            ),
            patch(
                "app.utils.image_processing.downscale_base64_image",
                side_effect=lambda raw: raw,
            ),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=None, is_demo=True)
            await service._generate_images_streaming(job, [_prompt(0)])

        assert job.generated_count == 1
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_generate_images_streaming_no_image_response_marks_failed():
    ai = _ImageAI([])
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=1,
        batch_size=1,
    )
    try:
        with (
            patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
            patch(
                "app.core.image_executor.run_image_op",
                new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
            ),
            patch(
                "app.utils.image_processing.downscale_base64_image",
                side_effect=lambda raw: raw,
            ),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=None, is_demo=True)
            await service._generate_images_streaming(job, [_prompt(0)])

        assert job.failed_count == 1
        assert 0 in job.failed_indices
        history = await PhotoshootJobService.get_event_history(job.job_id)
        assert len([e for e in history if e["type"] == "image_failed"]) == 1
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_generate_single_image_persists_durable_url():
    ai = _ImageAI(["data:image/png;base64,aGVsbG8="])
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=1,
        batch_size=1,
    )
    job.persistence_db = MagicMock()
    try:
        with patch(
            "app.services.storage_service.StorageService.upload_temp_generated_image",
            new=AsyncMock(return_value={"image_url": "https://cdn.example/x.png"}),
        ) as upload:
            service = PhotoshootStreamingService(user_id="u1", db=Mock())
            image = await service._generate_single_image(job, _prompt(0), ai, ["ref"])

        assert image is not None
        upload.assert_awaited_once()
        assert upload.await_args.kwargs["source"] == "photoshoot"
        assert upload.await_args.kwargs["user_id"] == "u1"
        history = await PhotoshootJobService.get_event_history(job.job_id)
        complete = [e for e in history if e["type"] == "image_complete"]
        assert complete[0]["data"]["image_url"] == "https://cdn.example/x.png"
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_generate_single_image_tolerates_persistence_failure():
    ai = _ImageAI(["plain-b64"])
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=1,
        batch_size=1,
    )
    job.persistence_db = MagicMock()
    try:
        with patch(
            "app.services.storage_service.StorageService.upload_temp_generated_image",
            new=AsyncMock(side_effect=RuntimeError("upload down")),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=Mock())
            image = await service._generate_single_image(job, _prompt(0), ai, ["ref"])

        # Best-effort persistence: the image still succeeds base64-only.
        assert image is not None
        assert image.image_base64 == "plain-b64"
        assert job.generated_count == 1
    finally:
        await _cleanup_job(job.job_id)


@pytest.mark.asyncio
async def test_generate_images_streaming_stops_when_cancelled_mid_batch():
    ai = _ImageAI(["img-b64"])
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["data:image/jpeg;base64,aGVsbG8="],
        use_case="linkedin",
        num_images=2,
        batch_size=1,
    )

    async def _cancel_on_batch_start(job_id, event_type, *args, **kwargs):
        if event_type == "batch_started":
            await PhotoshootJobService.cancel_job(job_id, "u1")

    try:
        with (
            patch("app.services.ai_provider_service.get_ai_service", new=AsyncMock(return_value=ai)),
            patch.object(
                PhotoshootJobService,
                "broadcast_event",
                new=AsyncMock(side_effect=_cancel_on_batch_start),
            ) as broadcast,
            patch(
                "app.core.image_executor.run_image_op",
                new=AsyncMock(side_effect=lambda fn, *args, **kwargs: fn(*args, **kwargs)),
            ),
            patch(
                "app.utils.image_processing.downscale_base64_image",
                side_effect=lambda raw: raw,
            ),
        ):
            service = PhotoshootStreamingService(user_id="u1", db=None, is_demo=True)
            await service._generate_images_streaming(job, [_prompt(0), _prompt(1)])

        # Batch 1 was cancelled mid-flight (no image generated); the loop then
        # stopped at the batch boundary instead of starting batch 2.
        assert job.generated_count == 0
        assert job.status == PhotoshootJobStatus.CANCELLED
        assert len([c for c in broadcast.await_args_list if c.args[1] == "batch_started"]) == 1
    finally:
        await _cleanup_job(job.job_id)


# --------------------------------------------------------------------------- #
# _scene_label fallbacks
# --------------------------------------------------------------------------- #


def test_scene_label_falls_back_to_mood():
    prompt = _prompt(0, setting="", pose="", style="", mood="warm")
    assert _scene_label(prompt) == "warm"


def test_scene_label_falls_back_to_scene_number():
    prompt = _prompt(2, setting="", pose="", style="", mood="")
    assert _scene_label(prompt) == "Scene 3"
