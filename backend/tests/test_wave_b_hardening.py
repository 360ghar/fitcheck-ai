"""Focused regressions for implementation wave B backend hardening."""

from unittest.mock import AsyncMock, Mock, patch

import pytest
import stripe
from fastapi import HTTPException

from app.core.config import settings
from app.core.exceptions import RateLimitError, ServiceError, SocialImportError
from app.models.photoshoot import PhotoshootJobStatus
from app.models.subscription import OperationType, PlanType
from app.services.batch_job_service import BatchJobService, BatchJobStatus
from app.services.photoshoot_job_service import PhotoshootJobService
from app.services.referral_service import ReferralService
from app.services.social_scraper_service import SocialScraperService
from app.services.subscription_service import SubscriptionService
from app.services.photoshoot_service import PhotoshootService
from app.services.ai_settings_service import AISettingsService
import app.api.v1.social_import as social_import_api
from app.models.social_import import SocialImportStartRequest
from app.services.social_import_job_store import SocialImportJobStore
from app.api.v1.subscription import cancel_subscription
from app.api.v1 import batch_processing as batch_processing_api


@pytest.fixture(autouse=True)
def clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


@pytest.mark.asyncio
async def test_batch_terminal_job_rejects_late_result_mutations():
    job = await BatchJobService.create_job(
        user_id="user-1",
        images=[{"image_id": "img-1", "image_base64": "abc"}],
    )
    await BatchJobService.cancel_job(job.job_id, "user-1")

    await BatchJobService.add_detected_items(
        job.job_id,
        "img-1",
        [{"temp_id": "item-1", "category": "tops"}],
    )
    await BatchJobService.update_item_generation(
        job.job_id,
        "item-1",
        generated_image_base64="late-result",
    )
    await BatchJobService.set_error(job.job_id, "late-error")

    stored = BatchJobService._jobs[job.job_id]
    assert stored.status == BatchJobStatus.CANCELLED
    assert stored.detected_items == []
    assert stored.error_message is None


@pytest.mark.asyncio
async def test_photoshoot_terminal_job_rejects_late_result_mutations():
    job = await PhotoshootJobService.create_job(
        user_id="user-1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    await PhotoshootJobService.cancel_job(job.job_id, "user-1")

    await PhotoshootJobService.add_generated_image(
        job.job_id,
        image_id="image-1",
        index=0,
        image_base64="late-result",
    )
    await PhotoshootJobService.mark_image_failed(job.job_id, 0, "late-error")
    await PhotoshootJobService.set_error(job.job_id, "late-error")

    stored = PhotoshootJobService._jobs[job.job_id]
    assert stored.status == PhotoshootJobStatus.CANCELLED
    assert stored.generated_images == []
    assert stored.failed_indices == set()
    assert stored.error_message is None


@pytest.mark.asyncio
async def test_increment_usage_reserves_quota_atomically():
    db = Mock()
    # Scalar-returning RPCs are keyed by the function name in PostgREST.
    db.rpc.return_value.execute.return_value = Mock(data=[{"reserve_usage": True}])

    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setattr(
            SubscriptionService,
            "get_subscription",
            AsyncMock(return_value=Mock(plan_type=PlanType.FREE)),
        )
        monkeypatch.setattr(
            SubscriptionService,
            "get_plan_limits",
            Mock(return_value={"monthly_extractions": 10}),
        )
        monkeypatch.setattr(
            SubscriptionService,
            "get_or_create_usage_record",
            AsyncMock(return_value={"monthly_extractions": 9}),
        )
        await SubscriptionService.increment_usage("user-1", "extraction", db, count=1)

    db.rpc.assert_called_once()
    assert db.rpc.call_args.args[0] == "reserve_usage"


@pytest.mark.asyncio
async def test_daily_ai_reservation_uses_hosted_atomic_rpc():
    db = Mock()
    # Scalar-returning RPCs are keyed by the function name in PostgREST.
    db.rpc.return_value.execute.return_value = Mock(data=[{"reserve_ai_usage": True}])

    with patch.object(
        AISettingsService,
        "get_user_settings",
        new=AsyncMock(return_value={"user_id": "user-1"}),
    ):
        reserved = await AISettingsService.reserve_usage(
            user_id="user-1",
            operation_type="generation",
            db=db,
            count=3,
        )

    assert reserved is True
    assert db.rpc.call_args.args[0] == "reserve_ai_usage"
    assert db.rpc.call_args.args[1]["p_count"] == 3


@pytest.mark.asyncio
async def test_photoshoot_reservation_uses_hosted_atomic_rpc():
    db = Mock()
    # Scalar-returning RPCs are keyed by the function name in PostgREST.
    db.rpc.return_value.execute.return_value = Mock(data=[{"reserve_daily_photoshoot_usage": True}])
    subscription = Mock(plan_type=PlanType.FREE)
    usage = Mock(used_today=2, limit_today=10, remaining=8, plan_type="free")

    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(return_value=subscription),
    ), patch.object(
        PhotoshootService,
        "get_or_create_daily_usage",
        new=AsyncMock(return_value={}),
    ), patch.object(
        PhotoshootService,
        "get_usage",
        new=AsyncMock(return_value=usage),
    ):
        reserved, returned_usage = await PhotoshootService.reserve_daily_usage(
            user_id="user-1",
            num_images=3,
            db=db,
        )

    assert reserved is True
    assert returned_usage is usage
    assert db.rpc.call_args.args[0] == "reserve_daily_photoshoot_usage"
    assert db.rpc.call_args.args[1]["p_count"] == 3


@pytest.mark.asyncio
async def test_batch_admission_compensates_extraction_when_generation_reservation_fails(monkeypatch):
    released = []

    async def reserve_usage(*, operation_type, **_kwargs):
        return operation_type == OperationType.EXTRACTION

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve_usage)
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)

    with pytest.raises(RateLimitError, match="more AI generations"):
        await batch_processing_api._check_batch_rate_limits(
            user_id="user-1",
            db=Mock(),
            total_images=3,
            auto_generate=True,
        )

    assert released == [(OperationType.EXTRACTION, 3)]


@pytest.mark.asyncio
async def test_redeem_referral_uses_atomic_idempotent_rpc():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(
        data=[
            {
                "success": True,
                "already_redeemed": True,
                "message": "Referral already applied",
                "credit_months": 1,
            }
        ]
    )

    result = await ReferralService.redeem_referral("user-2", "friend-code", db)

    assert result.success is True
    assert result.credit_months == 1
    assert db.rpc.call_args.args[0] == "redeem_referral_atomic"


@pytest.mark.asyncio
async def test_social_image_fetch_rejects_private_ip_before_network(monkeypatch):
    class UnexpectedClient:
        def __init__(self, *args, **kwargs):
            raise AssertionError("network client must not be constructed")

    monkeypatch.setattr(
        "app.services.social_scraper_service.httpx.AsyncClient",
        UnexpectedClient,
    )

    with pytest.raises(SocialImportError, match="private|blocked|unsafe"):
        await SocialScraperService.fetch_photo_as_base64("http://127.0.0.1/image.jpg")


@pytest.mark.asyncio
async def test_social_image_fetch_rejects_private_redirect_and_oversize(monkeypatch):
    def resolve(host, *args, **kwargs):
        ip = "127.0.0.1" if host == "127.0.0.1" else "93.184.216.34"
        return [(None, None, None, None, (ip, 80))]

    monkeypatch.setattr("app.services.social_scraper_service.socket.getaddrinfo", resolve)

    class Response:
        def __init__(self, status_code, headers, chunks=()):
            self.status_code = status_code
            self.headers = headers
            self._chunks = chunks

        def raise_for_status(self):
            return None

        async def aiter_bytes(self):
            for chunk in self._chunks:
                yield chunk

    class Stream:
        def __init__(self, response):
            self.response = response

        async def __aenter__(self):
            return self.response

        async def __aexit__(self, exc_type, exc, tb):
            return None

    class Client:
        def __init__(self, *args, **kwargs):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb):
            return None

        def stream(self, method, url):
            return Stream(
                Response(
                    302,
                    {"location": "http://127.0.0.1/private.jpg"},
                )
            )

    monkeypatch.setattr("app.services.social_scraper_service.httpx.AsyncClient", Client)
    with pytest.raises(SocialImportError, match="private|blocked"):
        await SocialScraperService.fetch_photo_as_base64("https://example.com/image.jpg")

    class OversizeClient(Client):
        def stream(self, method, url):
            return Stream(
                Response(
                    200,
                    {
                        "content-type": "image/jpeg",
                        "content-length": str(SocialScraperService._MAX_IMPORTED_IMAGE_BYTES + 1),
                    },
                )
            )

    monkeypatch.setattr("app.services.social_scraper_service.httpx.AsyncClient", OversizeClient)
    with pytest.raises(SocialImportError, match="maximum size"):
        await SocialScraperService.fetch_photo_as_base64("https://example.com/image.jpg")


@pytest.mark.asyncio
async def test_cancel_does_not_change_local_billing_state_when_stripe_fails():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data={"stripe_subscription_id": "sub-1"}
    )
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(return_value=Mock(plan_type=PlanType.PRO_MONTHLY)),
    ), patch("app.api.v1.subscription.settings.STRIPE_SECRET_KEY", "sk_test"), patch(
        "app.api.v1.subscription.stripe.Subscription.modify",
        side_effect=stripe.error.StripeError("stripe unavailable"),
    ):
        with pytest.raises(ServiceError, match="local subscription was not changed"):
            await cancel_subscription(user={"id": "user-1"}, db=db)

    db.table.return_value.update.assert_not_called()


@pytest.mark.asyncio
async def test_stripe_webhook_duplicate_event_is_acknowledged_without_reprocessing():
    db = Mock()
    duplicate = Exception("duplicate key value violates unique constraint")
    db.table.return_value.insert.return_value.execute.side_effect = [Mock(), duplicate]
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None
    event = {
        "id": "evt_wave_b_1",
        "type": "invoice.payment_failed",
        "data": {"object": {"subscription": "sub_missing"}},
    }

    class Request:
        headers = {"stripe-signature": "sig"}

        async def body(self):
            return b"{}"

    from app.api.v1.subscription import stripe_webhook

    with patch("app.api.v1.subscription.settings.STRIPE_SECRET_KEY", "sk_test"), patch(
        "app.api.v1.subscription.settings.STRIPE_WEBHOOK_SECRET", "whsec_test"
    ), patch("app.api.v1.subscription.stripe.Webhook.construct_event", return_value=event):
        first = await stripe_webhook(Request(), db)
        second = await stripe_webhook(Request(), db)

    assert first == {"received": True}
    assert second == {"received": True, "duplicate": True}


@pytest.mark.asyncio
async def test_social_import_admission_converts_unique_active_job_race_to_429(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", True)
    monkeypatch.setattr(settings, "SOCIAL_IMPORT_MAX_CONCURRENT_JOBS", 1)

    async def no_active_jobs(db, *, user_id):  # noqa: ANN001
        return 0

    async def duplicate_insert(*args, **kwargs):  # noqa: ANN001
        raise Exception("duplicate key value violates unique constraint")

    monkeypatch.setattr(SocialImportJobStore, "count_active_jobs", staticmethod(no_active_jobs))
    monkeypatch.setattr(SocialImportJobStore, "create_job", staticmethod(duplicate_insert))

    with pytest.raises(HTTPException) as exc_info:
        await social_import_api.create_social_import_job(
            SocialImportStartRequest(source_url="https://www.instagram.com/example/"),
            user_id="user-1",
            db=object(),
        )

    assert exc_info.value.status_code == 429


# =============================================================================
# Missing-RPC (migration gap) quota admission failures - observed 2026-07-31
#
# Every batch-extract admission returned 500 ("Failed to reserve AI usage")
# because the hosted Supabase DB had never received migrations 022/024/026:
# PostgREST answers rpc() with PGRST202 ("Could not find the function ... in
# the schema cache") and the service failed closed with a bare DatabaseError.
# These tests pin the fix: the failure must surface as a friendly 503 to the
# client (never raw DB text), while the actionable detail (which function,
# which migrations) is logged for operators.
# =============================================================================


class _PGRST202(Exception):
    """Simulates postgrest-py's error when an RPC is missing from the schema cache."""

    def __init__(self, function_name: str):
        super().__init__(
            f'PGRST202: Could not find the function public.{function_name} '
            "(character varying, text, integer, integer) in the schema cache"
        )


FRIENDLY_QUOTA_503 = (
    "AI services are temporarily unavailable. Please try again in a few moments."
)


@pytest.mark.asyncio
async def test_daily_ai_reservation_missing_rpc_returns_friendly_503_and_logs_detail(caplog):
    """Missing-RPC must be a friendly 503 to the client; the migration-gap
    hint (function + migrations) must be in the server log, not the message."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.rpc.return_value.execute.side_effect = _PGRST202("reserve_ai_usage")

    with pytest.raises(AIServiceError) as exc_info:
        await AISettingsService.reserve_usage(
            user_id="user-1",
            operation_type="extraction",
            db=db,
            count=1,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503
    assert "reserve_ai_usage" not in exc_info.value.message
    assert "022/024/026" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "reserve_ai_usage" in logged
    assert "022/024/026" in logged
    assert "022_wave_b_hardening.sql" in logged


@pytest.mark.asyncio
async def test_daily_ai_release_missing_rpc_returns_friendly_503_and_logs_detail(caplog):
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.rpc.return_value.execute.side_effect = _PGRST202("release_ai_usage")

    with pytest.raises(AIServiceError) as exc_info:
        await AISettingsService.release_usage(
            user_id="user-1",
            operation_type="extraction",
            db=db,
            count=1,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503
    assert "release_ai_usage" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "release_ai_usage" in logged
    assert "022/024/026" in logged


@pytest.mark.asyncio
async def test_monthly_reservation_missing_rpc_returns_friendly_503_and_logs_detail(caplog):
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.rpc.return_value.execute.side_effect = _PGRST202("reserve_usage")

    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setattr(
            SubscriptionService,
            "get_subscription",
            AsyncMock(return_value=Mock(plan_type=PlanType.FREE)),
        )
        monkeypatch.setattr(
            SubscriptionService,
            "get_plan_limits",
            Mock(return_value={"monthly_extractions": 10}),
        )
        monkeypatch.setattr(
            SubscriptionService,
            "get_or_create_usage_record",
            AsyncMock(return_value={"monthly_extractions": 0}),
        )
        with pytest.raises(AIServiceError) as exc_info:
            await SubscriptionService.increment_usage("user-1", "extraction", db, count=1)

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503
    assert "reserve_usage" not in exc_info.value.message
    assert "022/024/026" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "reserve_usage" in logged
    assert "022/024/026" in logged


@pytest.mark.asyncio
async def test_ensure_ai_settings_row_fk_race_returns_friendly_503_and_logs_detail(caplog):
    """A brand-new auth user whose public.users row has not propagated yet hits
    a 23503 FK race on user_ai_settings.user_id. The client must get a friendly
    'account still being set up' 503, never the raw FK constraint text."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None
    db.table.return_value.upsert.side_effect = Exception(
        'insert or update on table "user_ai_settings" violates foreign key '
        'constraint "users_id_fkey" (SQLSTATE 23503)'
    )

    with pytest.raises(AIServiceError) as exc_info:
        await AISettingsService.ensure_ai_settings_row("user-1", db)

    assert exc_info.value.status_code == 503
    assert "account is still being set up" in exc_info.value.message
    assert "Retry in a few seconds" not in exc_info.value.message
    assert "23503" not in exc_info.value.message
    assert "users_id_fkey" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "23503" in logged


# =============================================================================
# Durable-job persistence (migration gap) tests
# =============================================================================


class _PGRST205(Exception):
    """Simulates postgrest-py's error when a table is absent from the schema."""

    def __init__(self, table: str):
        super().__init__(
            f'PGRST205: Could not find the "{table}" relation in the schema cache'
        )


class _PostgresCheckViolation(Exception):
    """Simulates a 23514 CHECK violation (e.g. stale valid_batch_size bound)."""

    def __init__(self):
        super().__init__(
            'ERROR: 23514: new row for relation "extraction_jobs" violates check '
            'constraint "valid_batch_size"'
        )


@pytest.mark.asyncio
async def test_batch_job_create_missing_table_returns_friendly_503_and_logs_hint(caplog):
    """Missing extraction_jobs table (migration 016/023 not applied) must surface
    as a friendly retryable 503, never the raw PGRST205 text. The in-memory job
    must be removed to free the concurrency slot."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.table.return_value.upsert.side_effect = _PGRST205("extraction_jobs")

    with pytest.raises(AIServiceError) as exc_info:
        await BatchJobService.create_job(
            user_id="user-1",
            images=[{"image_id": "img-1", "image_base64": "abc"}],
            db=db,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503

    # The raw DB text (PGRST205, table names, migration names) must never
    # reach the client.
    assert "PGRST205" not in exc_info.value.message
    assert "extraction_jobs" not in exc_info.value.message
    assert "016" not in exc_info.value.message
    assert "023" not in exc_info.value.message

    # The in-memory job must be removed.
    assert BatchJobService._jobs == {}

    # The operator hint must be in the server logs (LOGS ONLY).
    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "extraction_jobs" in logged
    assert "016_extraction_jobs.sql" in logged


@pytest.mark.asyncio
async def test_batch_job_create_check_violation_returns_friendly_503_and_logs_hint(caplog):
    """Stale valid_batch_size CHECK (<=10 pre-023) on extraction_jobs must
    surface as a friendly retryable 503, never the raw 23514 text."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.table.return_value.upsert.side_effect = _PostgresCheckViolation()

    with pytest.raises(AIServiceError) as exc_info:
        await BatchJobService.create_job(
            user_id="user-1",
            images=[{"image_id": "img-1", "image_base64": "abc"}],
            db=db,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503

    assert "23514" not in exc_info.value.message
    assert "valid_batch_size" not in exc_info.value.message

    assert BatchJobService._jobs == {}

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "valid_batch_size" in logged
    assert "023" in logged


@pytest.mark.asyncio
async def test_photoshoot_job_create_missing_table_returns_friendly_503_and_logs_hint(caplog):
    """Missing photoshoot_jobs table (migration 023 not applied) must surface
    as a friendly retryable 503, never the raw PGRST205 text."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.table.return_value.upsert.side_effect = _PGRST205("photoshoot_jobs")

    with pytest.raises(AIServiceError) as exc_info:
        await PhotoshootJobService.create_job(
            user_id="user-1",
            photos=["abc"],
            use_case="aesthetic",
            num_images=1,
            db=db,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.retryable is True
    assert exc_info.value.message == FRIENDLY_QUOTA_503

    assert "PGRST205" not in exc_info.value.message
    assert "photoshoot_jobs" not in exc_info.value.message

    assert PhotoshootJobService._jobs == {}

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "photoshoot_jobs" in logged


@pytest.mark.asyncio
async def test_batch_job_create_non_migration_error_logs_type_in_message_and_returns_503(caplog):
    """A non-migration error (e.g. network timeout) during persistence also
    raises AIServiceError 503, and the exception type appears in the log
    message text (because Railway's plain-text drain does not render
    structured `extra` fields)."""
    from app.core.exceptions import AIServiceError

    db = Mock()
    db.table.return_value.upsert.side_effect = TimeoutError("connection timed out")

    with pytest.raises(AIServiceError) as exc_info:
        await BatchJobService.create_job(
            user_id="user-1",
            images=[{"image_id": "img-1", "image_base64": "abc"}],
            db=db,
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.message == FRIENDLY_QUOTA_503

    assert BatchJobService._jobs == {}

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "TimeoutError" in logged
    # The hint should not fire for non-migration errors.
    assert "016" not in logged


# =============================================================================
# Non-mutating quota-RPC presence probe tests
# =============================================================================


@pytest.mark.asyncio
async def test_missing_quota_rpcs_detects_missing_functions():
    """missing_quota_rpcs should return only the functions that raise PGRST202."""
    from app.utils.db import missing_quota_rpcs

    db = Mock()

    # Two present, two missing (PGRST202)
    results = {
        "reserve_ai_usage": Mock(),
        "release_ai_usage": Mock(),
        "reserve_usage": _PGRST202("reserve_usage"),
        "reserve_daily_photoshoot_usage": _PGRST202("reserve_daily_photoshoot_usage"),
    }

    def rpc_side_effect(name, args=None, **kwargs):
        value = results.get(name, Mock())
        if isinstance(value, BaseException):
            raise value
        return value

    db.rpc.side_effect = rpc_side_effect

    missing = missing_quota_rpcs(db)
    assert sorted(missing) == ["reserve_daily_photoshoot_usage", "reserve_usage"]


@pytest.mark.asyncio
async def test_missing_quota_rpcs_non_pgrst202_error_counts_as_present():
    """A function that errors for non-schema reasons (permissions, connectivity)
    is counted as present — it is not a migration gap."""
    from app.utils.db import missing_quota_rpcs

    db = Mock()
    db.rpc.side_effect = RuntimeError("connection refused")  # not PGRST202

    missing = missing_quota_rpcs(db)
    assert missing == []


# =============================================================================
# Referral RPC presence probe (RCA 2026-08-04)
# =============================================================================
# A missing redeem_referral_atomic / apply_referral_credit_atomic (migrations
# 022/026 never applied) made every referral redemption fail silently - the
# register/oauth_sync callers swallow the error and the user + referrer stay
# on free. The boot probe closes the blind spot.


@pytest.mark.asyncio
async def test_missing_referral_rpcs_detects_missing_functions():
    """missing_referral_rpcs should return only functions that raise PGRST202."""
    from app.utils.db import missing_referral_rpcs

    db = Mock()

    # redeem_referral_atomic present, apply_referral_credit_atomic missing.
    def rpc_side_effect(name, args=None, **kwargs):
        if name == "apply_referral_credit_atomic":
            raise _PGRST202("apply_referral_credit_atomic")
        return Mock()

    db.rpc.side_effect = rpc_side_effect

    missing = missing_referral_rpcs(db)
    assert missing == ["apply_referral_credit_atomic"]


@pytest.mark.asyncio
async def test_missing_referral_rpcs_non_pgrst202_error_counts_as_present():
    """A non-schema error (permissions, FK rejection on the nil-UUID probe)
    means the function exists - not a migration gap."""
    from app.utils.db import missing_referral_rpcs

    db = Mock()
    db.rpc.side_effect = RuntimeError("connection refused")  # not PGRST202

    missing = missing_referral_rpcs(db)
    assert missing == []


@pytest.mark.asyncio
async def test_referral_rpc_probes_are_non_mutating():
    """Both probes must use the nil UUID / a nonexistent code so nothing is
    ever granted or written during the boot check."""
    from app.utils.db import (
        REFERRAL_RPC_PROBES,
        _BOOT_PROBE_NONEXISTENT_CODE,
        _NIL_USER_UUID,
    )

    assert set(REFERRAL_RPC_PROBES) == {
        "redeem_referral_atomic",
        "apply_referral_credit_atomic",
    }
    redeem_args = REFERRAL_RPC_PROBES["redeem_referral_atomic"]
    assert redeem_args["p_referred_user_id"] == _NIL_USER_UUID
    assert redeem_args["p_code"] == _BOOT_PROBE_NONEXISTENT_CODE
    assert redeem_args["p_credit_months"] == 1
    apply_args = REFERRAL_RPC_PROBES["apply_referral_credit_atomic"]
    assert apply_args["p_user_id"] == _NIL_USER_UUID
    assert apply_args["p_months"] == 1
