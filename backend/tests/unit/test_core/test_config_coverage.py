"""Residual branch coverage for app.core.config Settings validators.

The sibling test_config_health.py validates the boot-time checks; this file
covers the Settings field validators directly: CORS origin parsing shapes,
the SUPABASE_URL trailing-slash normalization, and the CORS origin merge.
"""

from app.core.config import Settings


def test_parse_cors_origins_none_passthrough():
    assert Settings._parse_cors_origins(None) is None


def test_parse_cors_origins_empty_string_returns_empty_list():
    assert Settings._parse_cors_origins("") == []
    assert Settings._parse_cors_origins("   ") == []


def test_parse_cors_origins_json_array_string():
    assert Settings._parse_cors_origins('["https://a.com", " https://b.com ", ""]') == [
        "https://a.com",
        "https://b.com",
    ]


def test_parse_cors_origins_bad_json_falls_back_to_split():
    assert Settings._parse_cors_origins("{not json") == ["{not", "json"]


def test_parse_cors_origins_comma_and_space_separated():
    assert Settings._parse_cors_origins("https://a.com,https://b.com") == [
        "https://a.com",
        "https://b.com",
    ]
    assert Settings._parse_cors_origins("https://a.com https://b.com") == [
        "https://a.com",
        "https://b.com",
    ]


def test_parse_cors_origins_list_passthrough():
    assert Settings._parse_cors_origins(["https://a.com", " https://b.com "]) == [
        "https://a.com",
        " https://b.com ",
    ]


def test_supabase_url_trailing_slash_normalization():
    assert Settings._ensure_supabase_url_trailing_slash("https://x.supabase.co") == (
        "https://x.supabase.co/"
    )
    assert Settings._ensure_supabase_url_trailing_slash("https://x.supabase.co/") == (
        "https://x.supabase.co/"
    )
    assert Settings._ensure_supabase_url_trailing_slash("") == ""


def test_settings_merge_frontend_url_and_always_allowed_origins():
    settings = Settings(
        FRONTEND_URL="https://app.example.com/",
        BACKEND_CORS_ORIGINS=["https://custom.example.com", "https://www.fitcheckaiapp.com"],
    )
    merged = settings.BACKEND_CORS_ORIGINS
    # Frontend URL is merged in (trailing slash normalized) and deduped with
    # the always-allowed first-party origins.
    assert "https://app.example.com" in merged
    assert "https://custom.example.com" in merged
    assert "https://www.fitcheckaiapp.com" in merged
    assert merged.count("https://www.fitcheckaiapp.com") == 1
    assert len(merged) == len(set(merged))


def test_parse_cors_origins_json_parse_failure_falls_back():
    """A bracket-prefixed value that fails json.loads falls back to the
    comma/whitespace splitter (the except-pass path)."""
    assert Settings._parse_cors_origins("[abc, def]") == ["[abc", "def]"]


def test_ensure_cors_origins_without_frontend_url():
    """FRONTEND_URL empty -> the merge skips it but keeps the always-allowed
    first-party origins."""
    settings = Settings(
        FRONTEND_URL="",
        BACKEND_CORS_ORIGINS=["https://custom.example.com"],
    )
    merged = settings.BACKEND_CORS_ORIGINS
    assert "https://custom.example.com" in merged
    assert any("fitcheckaiapp.com" in o for o in merged)
