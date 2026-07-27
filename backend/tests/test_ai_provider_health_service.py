"""Tests for app/services/ai_provider_health_service.py.

Covers the non-OpenAI host detection used to skip Bearer auth on native
Google (Gemini) endpoints, which otherwise 401 and force a needless fallback.
"""

import pytest

from app.services.ai_provider_health_service import _is_non_openai_host


@pytest.mark.parametrize(
    "url,expected",
    [
        ("https://generativelanguage.googleapis.com/v1", True),
        ("https://generativelanguage.googleapis.com/", True),
        ("https://sub.generativelanguage.googleapis.com/v1", True),
        ("https://apihub.agnes-ai.com/v1", False),
        ("https://api.openai.com/v1", False),
        ("https://llm.example.com/v1", False),
        (None, False),
        ("", False),
    ],
)
def test_is_non_openai_host(url, expected):
    assert _is_non_openai_host(url) is expected
