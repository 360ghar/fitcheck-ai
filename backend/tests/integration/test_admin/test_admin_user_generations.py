"""Admin per-user generations / billing / referrals / body-profile service tests.

Direct service-layer tests (no routes) against ``tests.utils.fake_db.FakeDB``,
per the house convention in this directory. ``StorageService.get_public_url``
is faked so URL re-minting is asserted without a storage backend; stripe is
faked via ``sys.modules`` like the refund tests in
``test_admin_service_coverage.py``.

Pinned contracts:

- ``*_base64`` payloads never survive into any response payload.
- Media URLs are re-minted from durable keys at read time; foreign URLs pass
  through untouched.
- ``kind="all"`` merges kinds sorted by ``created_at`` desc and reports exact
  per-kind counts.
- A missing ``photoshoot_jobs.image_failures`` column degrades to the older
  column set instead of blanking the section.
- ``body_profiles.encrypted_data`` is never returned.
"""

import sys
from types import SimpleNamespace

import pytest

from app.core.config import settings
from app.core.exceptions import NotFoundError, ValidationError
from app.services.admin_user_generations_service import (
    _fresh_url,
    get_user_billing,
    get_user_body_profile,
    get_user_generation,
    get_user_referrals,
    list_user_generations,
)
from app.services.storage_service import StorageService
from tests.utils.fake_db import FakeBuilder, FakeDB, FakeResult

USER = "11111111-1111-1111-1111-111111111111"

# A hex-32 object name so derived keys match the storage grammar (parse_key).
HEX32 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
TMP_KEY = f"users/{USER}/tmp/photoshoot/{HEX32}.png"


@pytest.fixture(autouse=True)
def _fake_presign(monkeypatch):
    """Re-mint deterministically: presigned::<key> proves key derivation."""

    async def fake_presign(storage_path: str, bucket=None):
        return f"https://presigned.test/{storage_path}"

    monkeypatch.setattr(StorageService, "get_public_url", fake_presign)


# =============================================================================
# items (extraction runs)
# =============================================================================


@pytest.mark.asyncio
async def test_item_generation_maps_media_and_strips_base64():
    db = FakeDB(
        rows={
            "extraction_jobs": [
                {
                    "id": "job_1",
                    "user_id": USER,
                    "status": "completed",
                    "job_type": "batch",
                    "total_images": 2,
                    "total_items": 2,
                    "extractions_completed": 2,
                    "extractions_failed": 0,
                    "generations_completed": 2,
                    "generations_failed": 0,
                    "auto_generate": True,
                    "error_message": None,
                    "created_at": "2026-09-01T10:00:00Z",
                    "completed_at": "2026-09-01T10:02:00Z",
                    "items": [
                        {
                            "name": "Linen Shirt",
                            "category": "tops",
                            "generated_image_base64": "QUJD",
                            "generated_image_url": f"https://cdn.example.com/{TMP_KEY}",
                            "generated_image_storage_path": TMP_KEY,
                        },
                        {
                            "name": "Jeans",
                            "category": "bottoms",
                            "generated_image_base64": "REVG",
                            "generated_image_url": "https://cdn.example.com/external.jpg",
                        },
                    ],
                    "images": [
                        {
                            "image_url": "https://cdn.example.com/upload.jpg",
                            "storage_path": f"users/{USER}/tmp/upload/{HEX32}.png",
                        }
                    ],
                }
            ]
        }
    )

    page = await list_user_generations(db, USER, kind="item")

    (generation,) = page["items"]
    assert generation["kind"] == "item"
    assert generation["title"] == "batch"
    assert generation["duration_ms"] == 120000
    # Re-minted from the durable preview key; external URL passes through.
    assert generation["media"][0]["url"] == f"https://presigned.test/{TMP_KEY}"
    assert generation["media"][1]["url"] == "https://cdn.example.com/external.jpg"
    # Source photo is appended after generated media.
    assert generation["media"][2]["label"] == "source"
    assert generation["meta"]["source_images"] == [f"https://presigned.test/users/{USER}/tmp/upload/{HEX32}.png"]
    assert generation["meta"]["generations_completed"] == 2
    # No base64 anywhere in the payload.
    import json

    assert "QUJD" not in json.dumps(page)
    assert "REVG" not in json.dumps(page)
    assert page["counts"]["item_generations"] == 1


# =============================================================================
# photoshoot jobs
# =============================================================================


def _photoshoot_row(**overrides) -> dict:
    row = {
        "id": "ps_1",
        "user_id": USER,
        "status": "complete",
        "use_case": "aesthetic",
        "custom_prompt": "golden hour",
        "num_images": 2,
        "batch_size": 2,
        "aspect_ratio": "1:1",
        "total_batches": 1,
        "current_batch": 1,
        "generated_images": [
            {
                "id": "img_1",
                "index": 0,
                "image_base64": "R09ORw==",
                "image_url": f"https://cdn.example.com/{TMP_KEY}",
            }
        ],
        "failed_indices": [1],
        "image_failures": [{"index": 1, "error": "provider timeout"}],
        "reference_photo_count": 3,
        "error_message": None,
        "created_at": "2026-09-02T10:00:00Z",
        "completed_at": "2026-09-02T10:05:00Z",
    }
    row.update(overrides)
    return row


@pytest.mark.asyncio
async def test_photoshoot_maps_images_prompt_and_failures():
    db = FakeDB(rows={"photoshoot_jobs": [_photoshoot_row()]})

    page = await list_user_generations(db, USER, kind="photoshoot")

    (generation,) = page["items"]
    assert generation["kind"] == "photoshoot"
    assert generation["title"] == "aesthetic"
    assert generation["media"][0]["url"] == f"https://presigned.test/{TMP_KEY}"
    assert generation["media"][0]["label"] == "#0"
    # failed_indices [1] + image_failures [{index: 1}] describe the SAME
    # image: failed_count dedupes on index instead of summing both lists.
    assert generation["failed_count"] == 1
    assert generation["meta"]["custom_prompt"] == "golden hour"
    assert generation["meta"]["aspect_ratio"] == "1:1"
    assert generation["meta"]["image_failures"][0]["error"] == "provider timeout"
    import json

    assert "R09ORw==" not in json.dumps(page)


class _FilteredBuilder(FakeBuilder):
    """FakeBuilder that models a deployment without ``image_failures``.

    Raises on any select naming the column (like the real client's
    "column does not exist" APIError) and shapes returned rows down to the
    selected top-level columns, like real PostgREST — so the fallback read
    genuinely cannot see ``image_failures``.
    """

    def __init__(self, db, table):
        super().__init__(db, table)
        self._selected_columns = None

    def select(self, *args, **kwargs):
        if any("image_failures" in str(arg) for arg in args):
            raise RuntimeError('column "image_failures" does not exist')
        self._selected_columns = [
            part.strip()
            for arg in args
            if isinstance(arg, str) and arg != "*"
            for part in arg.split(",")
            if part.strip() and "(" not in part
        ]
        self._db.selects.append((self._table, args))
        return self

    def execute(self) -> FakeResult:
        result = super().execute()
        if self._selected_columns and isinstance(result.data, list):
            rows = [
                {k: v for k, v in row.items() if k in self._selected_columns}
                for row in result.data
            ]
            return FakeResult(data=rows, count=result.count)
        return result


class _MissingColumnDB(FakeDB):
    def table(self, name: str):
        return _FilteredBuilder(self, name)


@pytest.mark.asyncio
async def test_photoshoot_falls_back_when_image_failures_column_missing():
    db = _MissingColumnDB(rows={"photoshoot_jobs": [_photoshoot_row()]})

    page = await list_user_generations(db, USER, kind="photoshoot")

    (generation,) = page["items"]
    assert generation["id"] == "ps_1"
    assert len(generation["media"]) == 1
    # Column absent -> no failure records, but the section is NOT blanked.
    assert generation["meta"]["image_failures"] == []
    assert generation["media_count"] == 2


# =============================================================================
# outfits + render runs
# =============================================================================


@pytest.mark.asyncio
async def test_outfit_render_resolves_outfit_name():
    db = FakeDB(
        rows={
            "outfit_generations": [
                {
                    "id": "11111111-2222-3333-4444-555555555555",
                    "user_id": USER,
                    "outfit_id": "99999999-8888-7777-6666-555555555555",
                    "status": "completed",
                    "progress": 100,
                    "pose": "front",
                    "lighting": "studio",
                    "variations": 2,
                    "image_urls": [
                        f"https://cdn.example.com/users/{USER}/generated/outfit/{HEX32}.png",
                        "https://cdn.example.com/generated-two.png",
                    ],
                    "error": None,
                    "created_at": "2026-09-03T10:00:00Z",
                    "completed_at": "2026-09-03T10:01:00Z",
                }
            ],
            "outfits": [
                {
                    "id": "99999999-8888-7777-6666-555555555555",
                    "user_id": USER,
                    "name": "Date Night",
                }
            ],
        }
    )

    page = await list_user_generations(db, USER, kind="outfit_render")

    (generation,) = page["items"]
    assert generation["title"] == "Date Night"
    assert generation["meta"]["outfit_name"] == "Date Night"
    assert [m["label"] for m in generation["media"]] == ["render 1", "render 2"]
    assert generation["media"][0]["url"].startswith("https://presigned.test/users/")


# =============================================================================
# merged "all" view + filters + pagination
# =============================================================================


@pytest.mark.asyncio
async def test_kind_all_merges_sorted_with_exact_counts():
    db = FakeDB(
        rows={
            "extraction_jobs": [
                {"id": "job_old", "user_id": USER, "status": "completed", "created_at": "2026-09-01T00:00:00Z"}
            ],
            "photoshoot_jobs": [
                {"id": "ps_new", "user_id": USER, "status": "complete", "created_at": "2026-09-05T00:00:00Z"}
            ],
            "social_import_jobs": [
                {"id": "imp_mid", "user_id": USER, "status": "completed", "created_at": "2026-09-03T00:00:00Z"}
            ],
            "outfits": [],
            "outfit_generations": [],
        }
    )

    page = await list_user_generations(db, USER, kind="all")

    assert [item["kind"] for item in page["items"]] == ["photoshoot", "social_import", "item"]
    assert page["total"] == 3
    assert page["counts"] == {
        "item_generations": 1,
        "outfits": 0,
        "outfit_renders": 0,
        "photoshoot_jobs": 1,
        "social_import_jobs": 1,
    }


@pytest.mark.asyncio
async def test_all_view_total_counts_only_reachable_window_rows():
    """One kind x 100 rows must report 50 (the per-kind window), not 100:
    pages past the merged set would otherwise come back empty."""
    db = FakeDB(
        rows={
            "extraction_jobs": [
                {
                    "id": f"job_{i:03d}",
                    "user_id": USER,
                    "status": "completed",
                    "created_at": f"2026-09-{(i % 28) + 1:02d}T00:00:00Z",
                }
                for i in range(100)
            ],
            "outfits": [],
            "outfit_generations": [],
            "photoshoot_jobs": [],
            "social_import_jobs": [],
        }
    )
    page = await list_user_generations(db, USER, kind="all")
    assert page["counts"]["item_generations"] == 100
    assert page["total"] == 50


@pytest.mark.asyncio
async def test_fresh_url_passes_through_another_users_key_unminted():
    """The admin view must not mint presigned URLs for another user's objects
    (copied URLs, shared references); public keys stay exempt."""
    other_key = f"users/22222222-2222-2222-2222-222222222222/items/{HEX32}.png"
    assert await _fresh_url(other_key, user_id=USER, operation="test") == other_key
    own_key = f"users/{USER}/items/{HEX32}.png"
    assert await _fresh_url(own_key, user_id=USER, operation="test") == (
        f"https://presigned.test/{own_key}"
    )


@pytest.mark.asyncio
async def test_status_filter_and_pagination():
    db = FakeDB(
        rows={
            "extraction_jobs": [
                {"id": f"job_{i}", "user_id": USER, "status": "completed" if i % 2 else "failed",
                 "created_at": f"2026-09-0{i + 1}T00:00:00Z"}
                for i in range(4)
            ]
        }
    )

    page = await list_user_generations(
        db, USER, kind="item", status="completed", page=1, page_size=2
    )

    assert page["total"] == 2
    assert [item["id"] for item in page["items"]] == ["job_3", "job_1"]


@pytest.mark.asyncio
async def test_outfit_kind_ignores_status_filter_without_querying():
    # outfits has no status column — a status predicate matches nothing, and
    # must not send a bogus ``status`` filter to the DB (which errors on
    # real PostgREST and only "works" via the swallowed-exception path).
    db = FakeDB(
        rows={
            "outfits": [
                {"id": "outfit_1", "user_id": USER, "name": "Look 1"},
            ]
        }
    )

    page = await list_user_generations(db, USER, kind="outfit", status="failed")

    assert page["items"] == []
    assert page["total"] == 0


@pytest.mark.asyncio
async def test_all_view_total_honors_status_filter():
    db = FakeDB(
        rows={
            "extraction_jobs": [
                {"id": "job_1", "user_id": USER, "status": "completed",
                 "created_at": "2026-09-03T00:00:00Z"},
                {"id": "job_2", "user_id": USER, "status": "failed",
                 "created_at": "2026-09-02T00:00:00Z"},
            ],
            "photoshoot_jobs": [
                {"id": "ps_1", "user_id": USER, "status": "failed",
                 "use_case": "linkedin", "created_at": "2026-09-01T00:00:00Z"},
            ],
            "outfits": [
                {"id": "outfit_1", "user_id": USER, "name": "Look 1",
                 "created_at": "2026-09-04T00:00:00Z"},
            ],
        }
    )

    page = await list_user_generations(db, USER, kind="all", status="failed")

    # Only the failed jobs surface; the timeless outfit and the
    # differently-stated jobs are excluded from items AND total (no dead
    # pages from an unfiltered total).
    assert [item["id"] for item in page["items"]] == ["job_2", "ps_1"]
    assert page["total"] == 2
    assert page["counts"]["outfits"] == 0


@pytest.mark.asyncio
async def test_photoshoot_detail_reaches_job_beyond_list_window():
    # The viewer fetches by id — a job older than the recent-activity
    # window (50) must still open (the old window-scan 404'd it).
    rows = [
        {
            "id": f"ps_{i:02d}",
            "user_id": USER,
            "status": "complete",
            "use_case": "linkedin",
            "created_at": f"2026-01-{1 + i // 24:02d}T{i % 24:02d}:00:00Z",
        }
        for i in range(55)
    ]
    db = FakeDB(rows={"photoshoot_jobs": rows})

    detail = await get_user_generation(db, USER, "photoshoot", "ps_00")

    assert detail["id"] == "ps_00"
    assert detail["kind"] == "photoshoot"


@pytest.mark.asyncio
async def test_unknown_kind_raises_validation_error():
    db = FakeDB()
    with pytest.raises(ValidationError):
        await list_user_generations(db, USER, kind="nope")
    with pytest.raises(ValidationError):
        await get_user_generation(db, USER, "nope", "x")


@pytest.mark.asyncio
async def test_get_user_generation_ownership_guard():
    db = FakeDB(
        rows={
            "photoshoot_jobs": [_photoshoot_row()],
            "social_import_jobs": [],
            "outfits": [],
            "outfit_generations": [],
            "extraction_jobs": [],
        }
    )

    detail = await get_user_generation(db, USER, "photoshoot", "ps_1")
    assert detail["id"] == "ps_1"

    with pytest.raises(NotFoundError):
        await get_user_generation(db, "22222222-2222-2222-2222-222222222222", "photoshoot", "ps_1")


@pytest.mark.asyncio
async def test_social_import_includes_per_photo_status():
    db = FakeDB(
        rows={
            "social_import_jobs": [
                {
                    "id": "imp_1",
                    "user_id": USER,
                    "platform": "instagram",
                    "source_url": "https://instagram.com/p/x",
                    "status": "completed",
                    "total_photos": 2,
                    "discovered_photos": 2,
                    "processed_photos": 2,
                    "approved_photos": 1,
                    "rejected_photos": 1,
                    "failed_photos": 0,
                    "auth_required": False,
                    "error_message": None,
                    "created_at": "2026-09-04T00:00:00Z",
                    "completed_at": "2026-09-04T01:00:00Z",
                }
            ],
            "social_import_photos": [
                {
                    "id": "ph_1",
                    "job_id": "imp_1",
                    "user_id": USER,
                    "ordinal": 0,
                    "status": "approved",
                    "source_photo_url": "https://cdn.instagram.com/a.jpg",
                    "source_thumb_url": "https://cdn.instagram.com/a_thumb.jpg",
                },
                {
                    "id": "ph_2",
                    "job_id": "imp_1",
                    "user_id": USER,
                    "ordinal": 1,
                    "status": "rejected",
                    "source_photo_url": "https://cdn.instagram.com/b.jpg",
                    "source_thumb_url": "https://cdn.instagram.com/b_thumb.jpg",
                },
            ],
        }
    )

    detail = await get_user_generation(db, USER, "social_import", "imp_1")

    # External CDN URLs pass through untouched (never reshaped into keys).
    assert detail["media"][0]["url"] == "https://cdn.instagram.com/a_thumb.jpg"
    assert [p["status"] for p in detail["meta"]["photos"]] == ["approved", "rejected"]
    assert detail["meta"]["approved_photos"] == 1


# =============================================================================
# billing
# =============================================================================


@pytest.mark.asyncio
async def test_billing_without_stripe_configured_returns_subscription_only():
    db = FakeDB(
        rows={
            "subscriptions": [
                {
                    "user_id": USER,
                    "plan_type": "pro_monthly",
                    "status": "active",
                    "billing_provider": "stripe",
                }
            ]
        }
    )
    monkeypatch_key = pytest.MonkeyPatch()
    monkeypatch_key.setattr(settings, "STRIPE_SECRET_KEY", None)
    try:
        result = await get_user_billing(db, USER, include_iap=True)
    finally:
        monkeypatch_key.undo()

    assert result["stripe_configured"] is False
    assert result["stripe_invoices"] == []
    assert result["subscription"]["plan_type"] == "pro_monthly"
    assert result["subscription"]["amount"] == settings.PLAN_PRO_MONTHLY_PRICE


@pytest.mark.asyncio
async def test_billing_lists_stripe_invoices_when_configured(monkeypatch):
    class _FakeStripe(SimpleNamespace):
        pass

    invoice = SimpleNamespace(
        id="in_1",
        number="ABCD-0001",
        created=1727000000,
        period_start=1726000000,
        period_end=1727000000,
        amount_paid=2900,
        currency="usd",
        status="paid",
        hosted_invoice_url="https://invoice.test/in_1",
        invoice_pdf="https://invoice.test/in_1/pdf",
    )
    fake = _FakeStripe(
        api_key=None,
        Invoice=SimpleNamespace(list=lambda **kwargs: SimpleNamespace(data=[invoice])),
    )
    monkeypatch.setitem(sys.modules, "stripe", fake)
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test")

    db = FakeDB(
        rows={
            "subscriptions": [
                {
                    "user_id": USER,
                    "plan_type": "pro_monthly",
                    "status": "active",
                    "billing_provider": "stripe",
                    "stripe_customer_id": "cus_1",
                }
            ]
        }
    )

    result = await get_user_billing(db, USER, include_iap=False)

    assert result["stripe_configured"] is True
    assert result["stripe_invoices"][0]["id"] == "in_1"
    assert result["stripe_invoices"][0]["amount_paid"] == 2900
    # Stripe unix-seconds arrive as ISO-8601 UTC (like every other datetime).
    assert result["stripe_invoices"][0]["created"] == "2024-09-22T10:13:20Z"
    assert result["stripe_invoices"][0]["period_start"] == "2024-09-10T20:26:40Z"
    assert result["iap_transactions"] == []


@pytest.mark.asyncio
async def test_billing_includes_iap_row_when_permitted(monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", None)
    db = FakeDB(
        rows={
            "subscriptions": [
                {
                    "user_id": USER,
                    "plan_type": "plus_monthly",
                    "status": "active",
                    "billing_provider": "apple",
                    "apple_original_transaction_id": "1000000123",
                }
            ]
        }
    )

    result = await get_user_billing(db, USER, include_iap=True)

    (txn,) = result["iap_transactions"]
    assert txn["platform"] == "apple"
    assert txn["transaction_id"] == "1000000123"


# =============================================================================
# referrals
# =============================================================================


@pytest.mark.asyncio
async def test_referrals_maps_code_redeemers_and_promos():
    db = FakeDB(
        rows={
            "referral_codes": [
                {"id": "rc_1", "user_id": USER, "code": "alice-abc123", "times_used": 2}
            ],
            "referral_redemptions": [
                {
                    "id": "rr_1",
                    "referrer_user_id": USER,
                    "referred_user_id": "33333333-3333-3333-3333-333333333333",
                    "referral_code_id": "rc_1",
                    "referrer_credit_applied": True,
                    "referred_credit_applied": True,
                    "credit_months": 1,
                    "redeemed_at": "2026-09-02T00:00:00Z",
                }
            ],
            "users": [
                {
                    "id": "33333333-3333-3333-3333-333333333333",
                    "email": "bob@example.com",
                    "full_name": "Bob",
                }
            ],
            "promo_redemptions": [
                {
                    "id": "pr_1",
                    "user_id": USER,
                    "promo_code_id": "pc_1",
                    "plan_type": "plus_monthly",
                    "months": 2,
                    "created_at": "2026-09-01T00:00:00Z",
                }
            ],
            "promo_codes": [
                {"id": "pc_1", "code": "WELCOME", "plan_type": "plus_monthly", "months": 2}
            ],
        }
    )

    result = await get_user_referrals(db, USER)

    assert result["code"] == "alice-abc123"
    assert result["times_used"] == 2
    (redemption,) = result["redemptions"]
    assert redemption["referred_email"] == "bob@example.com"
    assert redemption["credit_months"] == 1
    (promo,) = result["promo_redemptions"]
    assert promo["code"] == "WELCOME"
    assert promo["months"] == 2


# =============================================================================
# body profile
# =============================================================================


@pytest.mark.asyncio
async def test_body_profile_never_returns_encrypted_data():
    db = FakeDB(
        rows={
            "body_profiles": [
                {
                    "id": "bp_1",
                    "user_id": USER,
                    "name": "Default",
                    "height_cm": 178,
                    "weight_kg": 72,
                    "body_shape": "rectangle",
                    "skin_tone": "medium",
                    "is_default": True,
                    "encrypted_data": b"cipherbytes",
                    "created_at": "2026-09-01T00:00:00Z",
                }
            ],
            "users": [{"id": USER, "gender": "female"}],
        }
    )

    result = await get_user_body_profile(db, USER)

    assert result["gender"] == "female"
    (profile,) = result["profiles"]
    assert profile["height_cm"] == 178
    assert "encrypted_data" not in profile


# =============================================================================
# user detail counts
# =============================================================================


@pytest.mark.asyncio
async def test_user_detail_counts_include_generation_kinds():
    from app.services.admin_service import get_user_detail

    db = FakeDB(
        rows={
            "users": [
                {
                    "id": USER,
                    "email": "u@example.com",
                    "full_name": "U",
                    "is_active": True,
                }
            ],
            "extraction_jobs": [{"id": "j1", "user_id": USER}],
            "photoshoot_jobs": [{"id": "p1", "user_id": USER}],
            "outfit_generations": [{"id": "o1", "user_id": USER, "outfit_id": "of1"}],
            "social_import_jobs": [{"id": "s1", "user_id": USER}],
        }
    )

    detail = await get_user_detail(db, USER)

    assert detail["counts"]["item_generations"] == 1
    assert detail["counts"]["photoshoot_jobs"] == 1
    assert detail["counts"]["outfit_renders"] == 1
    assert detail["counts"]["social_import_jobs"] == 1


@pytest.mark.asyncio
async def test_user_detail_items_surface_all_images_and_source():
    from app.services.admin_service import get_user_detail

    db = FakeDB(
        rows={
            "users": [
                {"id": USER, "email": "u@example.com", "full_name": "U", "is_active": True}
            ],
            "items": [
                {
                    "id": "item_1",
                    "user_id": USER,
                    "name": "Linen Shirt",
                    "category": "tops",
                    "created_at": "2026-09-01T00:00:00Z",
                    "source_image_url": f"users/{USER}/sources/{HEX32}.png",
                }
            ],
        }
    )

    detail = await get_user_detail(db, USER)

    (item,) = detail["items"]
    # FakeDB ignores embeds, so no item_images rows exist: the cover stays
    # unset and the source photo is still re-minted from its durable key.
    assert item["source_image_url"] == f"https://presigned.test/users/{USER}/sources/{HEX32}.png"
    assert "image_url" not in item
