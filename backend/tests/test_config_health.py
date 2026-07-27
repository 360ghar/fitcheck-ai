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
    )
    base.update(overrides)
    return SimpleNamespace(**base)


def test_dev_mode_returns_no_issues():
    """In DEBUG=True (and not Railway), checks are skipped to avoid noise."""
    with patch.object(config_health, "_is_production_like", return_value=False):
        assert validate_production_config() == []


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
