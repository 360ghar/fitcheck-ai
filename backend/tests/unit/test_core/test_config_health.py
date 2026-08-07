"""
Tests for app/core/config_health.py startup checks.

These cover the three real production mis-configurations the module exists
to catch: empty AI_ENCRYPTION_KEY, non-https FRONTEND_URL, and per-leg
AI URLs pointed at a non-OpenAI-compatible host (e.g. native Google).
"""

from unittest.mock import patch

from app.core import config_health
from app.core.config_health import ConfigIssue, validate_production_config


def _force_prod():
    """Make _is_production_like() return True regardless of host env."""
    return patch.object(
        config_health,
        "_is_production_like",
        return_value=True,
    )


def _settings(**overrides):
    """Build a fake settings namespace with prod-defaults + caller overrides."""
    from types import SimpleNamespace

    base = dict(
        DEBUG=False,
        AI_ENCRYPTION_KEY="some-key",
        FRONTEND_URL="https://www.fitcheckaiapp.com",
        AI_DEFAULT_PROVIDER="custom",
        AI_OPENAI_API_KEY=None,
        AI_GEMINI_API_KEY=None,
        AI_VISION_PROVIDER="custom",
        AI_CHAT_API_URL="https://apihub.agnes-ai.com/v1",
        AI_VISION_API_URL=None,
        AI_VISION_FALLBACK_API_URL=None,
        AI_IMAGE_API_URL=None,
        AI_IMAGE_FALLBACK_API_URL=None,
        # Keys consumed by the Gemini-fallback (check #7) probe.
        AI_CHAT_API_KEY=None,
        AI_VISION_API_KEY=None,
        AI_VISION_FALLBACK_API_KEY=None,
        # Apple IAP (checks #8/#9): healthy by default so the base config
        # stays issue-free.
        APPLE_BUNDLE_ID="com.fitcheckaiapp.fitcheckai",
        APPLE_ISSUER_ID="issuer-123",
        APPLE_KEY_ID="key-123",
        APPLE_PRIVATE_KEY=(
            "-----BEGIN PRIVATE KEY-----\nMOCKAPPLEKEY\n-----END PRIVATE KEY-----"
        ),
        APPLE_ENV="production",
        # The real shipped defaults: check #9 asserts each ID sits inside the
        # app's own bundle/package namespace.
        APPLE_PLUS_MONTHLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.plus.monthly",
        APPLE_PLUS_YEARLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.plus.yearly",
        APPLE_PRO_MONTHLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.pro.monthly",
        APPLE_PRO_YEARLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.pro.yearly",
        GOOGLE_PACKAGE_NAME="com.fitcheckaiapp.fitcheckai",
        GOOGLE_PLUS_MONTHLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.plus.monthly",
        GOOGLE_PLUS_YEARLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.plus.yearly",
        GOOGLE_PRO_MONTHLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.pro.monthly",
        GOOGLE_PRO_YEARLY_PRODUCT_ID="com.fitcheckaiapp.fitcheckai.pro.yearly",
        # Stripe web billing (check #10): healthy by default so the base
        # config stays issue-free.
        STRIPE_SECRET_KEY="sk_test_123",
        STRIPE_PLUS_MONTHLY_PRICE_ID="price_plus_monthly",
        STRIPE_PLUS_YEARLY_PRICE_ID="price_plus_yearly",
        STRIPE_PRO_MONTHLY_PRICE_ID="price_pro_monthly",
        STRIPE_PRO_YEARLY_PRICE_ID="price_pro_yearly",
        # Object storage (check #11) + image serving (check #12): healthy by
        # default so the base config stays issue-free.
        OBJECT_STORAGE_ENDPOINT="https://acct.r2.cloudflarestorage.com",
        OBJECT_STORAGE_ACCESS_KEY_ID="ak",
        OBJECT_STORAGE_SECRET_ACCESS_KEY="sk",
        OBJECT_STORAGE_BUCKET="fitcheck-images",
        IMAGE_SERVING_MODE="presigned",
        IMAGE_CDN_BASE_URL="",
        # Thumbnail serving (check #13): off by default so the base config
        # stays issue-free.
        THUMBNAIL_SERVING=False,
        THUMBNAILS_BACKFILLED=False,
    )
    base.update(overrides)
    return SimpleNamespace(**base)


def test_dev_mode_returns_no_issues():
    """In DEBUG=True (and not Railway), checks are skipped to avoid noise."""
    with patch.object(config_health, "_is_production_like", return_value=False):
        assert validate_production_config() == []


def test_vision_provider_defaults_to_gemini():
    """The config.py default must be 'gemini' (Gemini-primary, Agnes-fallback)
    so an unset var in production can't silently regress to Agnes-primary,
    which caused the original double-401 vision outage (see exec-plan
    2026-07-27-hybrid-vision-leg.md). Local dev without a Gemini key overrides
    explicitly via env."""
    from app.core.config import Settings

    # Read the field default directly; instantiating Settings requires
    # Supabase env vars that aren't relevant to this contract.
    default = Settings.model_fields["AI_VISION_PROVIDER"].default
    assert default == "gemini"


def test_healthy_prod_config_returns_no_issues():
    with _force_prod(), patch.object(config_health, "settings", _settings()):
        assert validate_production_config() == []


def test_empty_encryption_key_flagged_as_error():
    with _force_prod(), patch.object(
        config_health, "settings", _settings(AI_ENCRYPTION_KEY="")
    ):
        issues = validate_production_config()
    enc = [i for i in issues if i.key == "AI_ENCRYPTION_KEY"]
    assert len(enc) == 1
    assert enc[0].severity == "error"
    assert "openssl rand" in enc[0].message


def test_whitespace_only_encryption_key_flagged():
    with _force_prod(), patch.object(
        config_health, "settings", _settings(AI_ENCRYPTION_KEY="   ")
    ):
        issues = validate_production_config()
    assert any(i.key == "AI_ENCRYPTION_KEY" for i in issues)


def test_http_frontend_url_flagged_as_warning():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(FRONTEND_URL="http://localhost:3000"),
    ):
        issues = validate_production_config()
    fe = [i for i in issues if i.key == "FRONTEND_URL"]
    assert len(fe) == 1
    assert fe[0].severity == "warning"
    assert "https://" in fe[0].message


def test_vision_url_pointed_at_google_flagged_as_error():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            AI_VISION_API_URL="https://generativelanguage.googleapis.com/v1beta"
        ),
    ):
        issues = validate_production_config()
    vis = [i for i in issues if i.key == "AI_VISION_API_URL"]
    assert len(vis) == 1
    assert vis[0].severity == "error"
    assert "404" in vis[0].message


def test_chat_url_pointed_at_google_flagged():
    """Chat is the root - if it points at Google, every leg breaks."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_CHAT_API_URL="https://generativelanguage.googleapis.com/v1beta"),
    ):
        issues = validate_production_config()
    assert any(i.key == "AI_CHAT_API_URL" for i in issues)


def test_blank_vision_url_not_flagged():
    """Blank per-leg URL is fine - it inherits chat."""
    with _force_prod(), patch.object(
        config_health, "settings", _settings(AI_VISION_API_URL=None)
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_VISION_API_URL" for i in issues)


def test_agnes_url_not_flagged():
    """Agnes gateway IS OpenAI-compatible - should not trip the check."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_CHAT_API_URL="https://apihub.agnes-ai.com/v1"),
    ):
        issues = validate_production_config()
    assert not any(i.key.endswith("_API_URL") for i in issues)


def test_openai_default_without_key_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_DEFAULT_PROVIDER="openai", AI_OPENAI_API_KEY=None),
    ):
        issues = validate_production_config()
    oi = [i for i in issues if i.key == "AI_OPENAI_API_KEY"]
    assert len(oi) == 1
    assert oi[0].severity == "error"


def test_openai_default_with_key_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_DEFAULT_PROVIDER="openai", AI_OPENAI_API_KEY="sk-real-key"),
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_OPENAI_API_KEY" for i in issues)


def test_default_provider_gemini_without_key_flagged():
    """Backfills coverage for the pre-existing AI_DEFAULT_PROVIDER=gemini
    check, which had no dedicated test before this pass touched the same
    merged condition."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_DEFAULT_PROVIDER="gemini", AI_GEMINI_API_KEY=None),
    ):
        issues = validate_production_config()
    gem = [i for i in issues if i.key == "AI_GEMINI_API_KEY"]
    assert len(gem) == 1
    assert gem[0].severity == "error"
    assert "AI_DEFAULT_PROVIDER=gemini" in gem[0].message


def test_default_provider_and_hybrid_vision_both_gemini_without_key_flagged_once():
    """AI_DEFAULT_PROVIDER=gemini and AI_VISION_PROVIDER=gemini both set with
    a blank key must produce exactly ONE AI_GEMINI_API_KEY issue, not two -
    both conditions share the same root cause and the same key."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_DEFAULT_PROVIDER="gemini", AI_VISION_PROVIDER="gemini", AI_GEMINI_API_KEY=None),
    ):
        issues = validate_production_config()
    gem = [i for i in issues if i.key == "AI_GEMINI_API_KEY"]
    assert len(gem) == 1
    assert "AI_DEFAULT_PROVIDER=gemini" in gem[0].message
    assert "AI_VISION_PROVIDER=gemini" in gem[0].message


def test_hybrid_vision_provider_gemini_without_key_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_VISION_PROVIDER="gemini", AI_GEMINI_API_KEY=None),
    ):
        issues = validate_production_config()
    gem = [i for i in issues if i.key == "AI_GEMINI_API_KEY"]
    assert len(gem) == 1
    assert gem[0].severity == "error"


def test_hybrid_vision_provider_gemini_with_key_not_flagged_for_key_check():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_VISION_PROVIDER="gemini", AI_GEMINI_API_KEY="real-key"),
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_GEMINI_API_KEY" for i in issues)


def test_hybrid_vision_provider_gemini_with_nonblank_vision_url_flagged_as_ambiguous():
    """AI_VISION_API_URL becomes dead config once the leg is redirected to
    native Gemini - uses an Agnes (OpenAI-compatible) URL so this assertion
    isolates the new ambiguity check from the pre-existing non-OpenAI-host
    check (#3), which would otherwise also fire on a Google URL."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            AI_VISION_PROVIDER="gemini",
            AI_GEMINI_API_KEY="real-key",
            AI_VISION_API_URL="https://apihub.agnes-ai.com/v1",
        ),
    ):
        issues = validate_production_config()
    url_issues = [i for i in issues if i.key == "AI_VISION_API_URL"]
    assert len(url_issues) == 1
    assert url_issues[0].severity == "error"
    assert "dead config" in url_issues[0].message


def test_hybrid_vision_provider_gemini_with_blank_vision_url_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(AI_VISION_PROVIDER="gemini", AI_GEMINI_API_KEY="real-key", AI_VISION_API_URL=None),
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_VISION_API_URL" for i in issues)


def test_config_issue_is_frozen():
    """Issues must be hashable/immutable so loggers can't accidentally mutate."""
    issue = ConfigIssue(severity="error", key="X", message="m")
    try:
        issue.severity = "warning"
        assert False, "should have raised FrozenInstanceError"
    except AttributeError:
        pass


def test_gemini_primary_without_agnes_fallback_key_flagged():
    """Gemini-primary relies on the Agnes fallback to absorb free-tier quota
    exhaustion; a missing fallback key is the difference between a transparent
    failover and every Gemini 429 failing the extraction."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            AI_VISION_PROVIDER="gemini",
            AI_GEMINI_API_KEY="real-key",
            AI_CHAT_API_KEY=None,
            AI_VISION_API_KEY=None,
            AI_VISION_FALLBACK_API_KEY=None,
        ),
    ):
        issues = validate_production_config()
    fb = [i for i in issues if i.key == "AI_CHAT_API_KEY"]
    assert len(fb) == 1
    assert fb[0].severity == "warning"
    assert "fallback" in fb[0].message.lower()


def test_gemini_primary_with_chat_key_not_flagged_for_fallback():
    """AI_CHAT_API_KEY (Agnes) resolves as the fallback key -> no warning."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            AI_VISION_PROVIDER="gemini",
            AI_GEMINI_API_KEY="real-key",
            AI_CHAT_API_KEY="agnes-key",
        ),
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_CHAT_API_KEY" for i in issues)


def test_gemini_primary_with_vision_fallback_key_not_flagged():
    """An explicit AI_VISION_FALLBACK_API_KEY also satisfies the fallback."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            AI_VISION_PROVIDER="gemini",
            AI_GEMINI_API_KEY="real-key",
            AI_CHAT_API_KEY=None,
            AI_VISION_FALLBACK_API_KEY="dedicated-fallback-key",
        ),
    ):
        issues = validate_production_config()
    assert not any(i.key == "AI_CHAT_API_KEY" for i in issues)


# ---------------------------------------------------------------------------
# Apple IAP config checks (#8 credentials, #9 product map)
# ---------------------------------------------------------------------------


def test_apple_iap_missing_credentials_flagged_as_error():
    """No APPLE_ISSUER_ID/KEY_ID/PRIVATE_KEY -> every iOS purchase
    registration fails closed at request time; startup must flag it."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(APPLE_ISSUER_ID=None, APPLE_KEY_ID=None, APPLE_PRIVATE_KEY=None),
    ):
        issues = validate_production_config()
    apple = [i for i in issues if i.key == "APPLE_ISSUER_ID"]
    assert len(apple) == 1
    assert apple[0].severity == "error"
    assert "Apple IAP verification is not configured" in apple[0].message
    assert "APPLE_ISSUER_ID" in apple[0].message


def test_apple_iap_partial_credentials_flagged_as_error():
    """A single missing credential must still fail closed (e.g. the .p8)."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(APPLE_PRIVATE_KEY=""),
    ):
        issues = validate_production_config()
    apple = [i for i in issues if i.key == "APPLE_ISSUER_ID"]
    assert len(apple) == 1
    assert apple[0].severity == "error"
    assert "APPLE_PRIVATE_KEY" in apple[0].message


def test_apple_iap_product_ids_not_matching_the_bundle_flagged_as_warning():
    """A product ID outside the app's bundle namespace resolves to nothing in
    StoreKit: the paywall renders with no prices and no error to explain it."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            APPLE_BUNDLE_ID="com.fitcheckaiapp.fitcheckai",
            APPLE_PLUS_MONTHLY_PRODUCT_ID="com.someoneelse.plus.monthly",
            APPLE_PRO_YEARLY_PRODUCT_ID="",
        ),
    ):
        issues = validate_production_config()
    prod = [i for i in issues if i.key == "APPLE_PLUS_MONTHLY_PRODUCT_ID"]
    assert len(prod) == 1
    assert prod[0].severity == "warning"
    assert "APPLE_PLUS_MONTHLY_PRODUCT_ID" in prod[0].message
    assert "APPLE_PRO_YEARLY_PRODUCT_ID" in prod[0].message


def test_apple_iap_default_product_ids_are_clean():
    """The shipped defaults belong to the bundle, so a deploy that never sets
    the APPLE_*_PRODUCT_ID vars raises nothing."""
    with _force_prod(), patch.object(config_health, "settings", _settings()):
        issues = validate_production_config()
    assert [i for i in issues if i.key == "APPLE_PLUS_MONTHLY_PRODUCT_ID"] == []
    assert [i for i in issues if i.key == "GOOGLE_PLUS_MONTHLY_PRODUCT_ID"] == []


def test_apple_iap_fully_configured_not_flagged():
    """Credentials + all four product IDs -> no Apple issues."""
    with _force_prod(), patch.object(config_health, "settings", _settings()):
        issues = validate_production_config()
    assert not any(i.key.startswith("APPLE_") for i in issues)


# =============================================================================
# Stripe web billing (check #10) - observed 2026-08-01: dozens of
# /subscription/checkout 503s because STRIPE_SECRET_KEY was unset in prod.
# =============================================================================


def test_stripe_config_healthy_by_default():
    with _force_prod(), patch.object(config_health, "settings", _settings()):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "STRIPE_SECRET_KEY"]


def test_missing_stripe_secret_key_reported():
    with _force_prod(), patch.object(
        config_health, "settings", _settings(STRIPE_SECRET_KEY="")
    ):
        issues = validate_production_config()
    stripe_issues = [i for i in issues if i.key == "STRIPE_SECRET_KEY"]
    assert len(stripe_issues) == 1
    assert stripe_issues[0].severity == "error"
    assert "STRIPE_SECRET_KEY missing" in stripe_issues[0].message


def test_missing_stripe_price_ids_reported():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(STRIPE_PRO_YEARLY_PRICE_ID="", STRIPE_PLUS_MONTHLY_PRICE_ID=""),
    ):
        issues = validate_production_config()
    stripe_issues = [i for i in issues if i.key == "STRIPE_SECRET_KEY"]
    assert len(stripe_issues) == 1
    assert "STRIPE_PRO_YEARLY_PRICE_ID" in stripe_issues[0].message
    assert "STRIPE_PLUS_MONTHLY_PRICE_ID" in stripe_issues[0].message


# --------------------------------------------------------------------------- #
# #11 object storage must be fully configured
# --------------------------------------------------------------------------- #
# Without this check, a deploy that forgot the bucket variables boots clean and
# then fails EVERY image read and write at request time. The R2 cutover made a
# fresh set of storage variables a real step, so the failure mode is live.
def test_object_storage_config_healthy_by_default():
    with _force_prod(), patch.object(config_health, "settings", _settings()):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "OBJECT_STORAGE_BUCKET"]


def test_missing_object_storage_bucket_reported():
    with _force_prod(), patch.object(
        config_health, "settings", _settings(OBJECT_STORAGE_BUCKET="")
    ):
        issues = validate_production_config()
    storage_issues = [i for i in issues if i.key == "OBJECT_STORAGE_BUCKET"]
    assert len(storage_issues) == 1
    assert storage_issues[0].severity == "error"
    assert "OBJECT_STORAGE_BUCKET missing" in storage_issues[0].message


def test_missing_object_storage_credentials_reported_as_one_issue():
    """The four are useless apart, so they are reported together, not as four."""
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            OBJECT_STORAGE_ENDPOINT="",
            OBJECT_STORAGE_ACCESS_KEY_ID="",
            OBJECT_STORAGE_SECRET_ACCESS_KEY="",
            OBJECT_STORAGE_BUCKET="",
        ),
    ):
        issues = validate_production_config()
    storage_issues = [i for i in issues if i.key == "OBJECT_STORAGE_BUCKET"]
    assert len(storage_issues) == 1
    for name in (
        "OBJECT_STORAGE_ENDPOINT",
        "OBJECT_STORAGE_ACCESS_KEY_ID",
        "OBJECT_STORAGE_SECRET_ACCESS_KEY",
        "OBJECT_STORAGE_BUCKET",
    ):
        assert name in storage_issues[0].message


# --------------------------------------------------------------------------- #
# #12 worker serving mode needs its CDN base URL
# --------------------------------------------------------------------------- #
# `images.serve_url` falls back to presigned URLs when IMAGE_CDN_BASE_URL is
# blank. That fallback is a working config, so nothing else would ever report it
# — the Worker rollout would just silently not take effect.
def test_presigned_mode_without_cdn_base_is_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(IMAGE_SERVING_MODE="presigned", IMAGE_CDN_BASE_URL=""),
    ):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "IMAGE_CDN_BASE_URL"]


def test_worker_mode_without_cdn_base_is_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(IMAGE_SERVING_MODE="worker", IMAGE_CDN_BASE_URL="   "),
    ):
        issues = validate_production_config()
    cdn_issues = [i for i in issues if i.key == "IMAGE_CDN_BASE_URL"]
    assert len(cdn_issues) == 1
    assert cdn_issues[0].severity == "error"


def test_worker_mode_with_cdn_base_is_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(
            IMAGE_SERVING_MODE="worker",
            IMAGE_CDN_BASE_URL="https://images.fitcheckaiapp.com",
        ),
    ):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "IMAGE_CDN_BASE_URL"]


# --------------------------------------------------------------------------- #
# #13 thumbnail serving requires the backfill to have run
# --------------------------------------------------------------------------- #
# THUMBNAIL_SERVING alone makes every read emit a `_thumb` URL, but objects
# predating scripts/generate_thumbnails.py have no sibling and 404 on their
# tile (the read path gates on THUMBNAILS_BACKFILLED too; this check catches
# the operator-side half of the pair at boot).
def test_thumbnail_serving_off_is_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(THUMBNAIL_SERVING=False, THUMBNAILS_BACKFILLED=False),
    ):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "THUMBNAILS_BACKFILLED"]


def test_thumbnail_serving_without_backfill_flagged_as_warning():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(THUMBNAIL_SERVING=True, THUMBNAILS_BACKFILLED=False),
    ):
        issues = validate_production_config()
    backfill_issues = [i for i in issues if i.key == "THUMBNAILS_BACKFILLED"]
    assert len(backfill_issues) == 1
    assert backfill_issues[0].severity == "warning"
    assert "THUMBNAILS_BACKFILLED" in backfill_issues[0].message
    assert "generate_thumbnails.py" in backfill_issues[0].message


def test_thumbnail_serving_with_backfill_not_flagged():
    with _force_prod(), patch.object(
        config_health,
        "settings",
        _settings(THUMBNAIL_SERVING=True, THUMBNAILS_BACKFILLED=True),
    ):
        issues = validate_production_config()
    assert not [i for i in issues if i.key == "THUMBNAILS_BACKFILLED"]
