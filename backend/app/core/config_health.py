"""
Startup config health checks.

Pure read of `settings`: returns a list of issues found so the caller
(lifespan) can log them on every boot. Never raises, never does I/O, so
a check itself cannot delay uvicorn from binding the port.

Why this exists: AI_ENCRYPTION_KEY, FRONTEND_URL, and AI_VISION_API_URL
have all been observed mis-set in production Railway env. Each one fails
silently at request time and is hard to diagnose from logs alone.
"""

from dataclasses import dataclass
from typing import List
from urllib.parse import urlparse

from app.core.config import settings


# Hosts that are NOT OpenAI-compatible. The provider service POSTs to
# `<host>/v1/chat/completions`, which 404s on these native Google endpoints.
# Agnes already proxies the same Gemini models through an OpenAI-shaped API,
# so leaving the per-leg URL blank (inherit chat) is the correct setup.
_NON_OPENAI_HOSTS = (
    "generativelanguage.googleapis.com",
)


@dataclass(frozen=True)
class ConfigIssue:
    severity: str  # "error" | "warning"
    key: str
    message: str


def _is_production_like() -> bool:
    # Railway sets RAILWAY_ENVIRONMENT on every deploy; DEBUG=False is the
    # other signal. Either means we should enforce prod-required keys.
    import os

    return bool(os.environ.get("RAILWAY_ENVIRONMENT")) or not settings.DEBUG


def _is_non_openai_host(url: str) -> bool:
    if not url:
        return False
    host = (urlparse(url).hostname or "").lower()
    return any(host == bad or host.endswith("." + bad) for bad in _NON_OPENAI_HOSTS)


def validate_production_config() -> List[ConfigIssue]:
    """Return config issues found in the current settings.

    Empty list == healthy. Caller logs each entry; this function does
    not log itself so it stays trivially testable.
    """
    issues: List[ConfigIssue] = []

    if not _is_production_like():
        # Dev/localhost: most of these checks would fire on purpose
        # (no key, localhost URL, etc.) and just generate noise.
        return issues

    # 1. AI_ENCRYPTION_KEY required in production
    if not (settings.AI_ENCRYPTION_KEY or "").strip():
        issues.append(ConfigIssue(
            severity="error",
            key="AI_ENCRYPTION_KEY",
            message=(
                "Empty in production. Saving a user AI-provider key will raise "
                "AIServiceError at request time. Generate with: openssl rand -hex 32"
            ),
        ))

    # 2. FRONTEND_URL must be a real https origin in production
    frontend = (settings.FRONTEND_URL or "").strip()
    if frontend and not frontend.startswith("https://"):
        issues.append(ConfigIssue(
            severity="warning",
            key="FRONTEND_URL",
            message=(
                f"Not an https URL (got {frontend!r}). Password-reset email "
                "links and any absolute frontend redirects will point users "
                "at the wrong host. Set to https://www.fitcheckaiapp.com."
            ),
        ))

    # 3. Per-leg AI URLs must be OpenAI-compatible (not native Google)
    # Chat is the root: if it points at a native Google endpoint, every leg
    # inherits the breakage.
    leg_checks = (
        ("AI_CHAT_API_URL", settings.AI_CHAT_API_URL),
        ("AI_VISION_API_URL", settings.AI_VISION_API_URL),
        ("AI_VISION_FALLBACK_API_URL", settings.AI_VISION_FALLBACK_API_URL),
        ("AI_IMAGE_API_URL", settings.AI_IMAGE_API_URL),
        ("AI_IMAGE_FALLBACK_API_URL", settings.AI_IMAGE_FALLBACK_API_URL),
    )
    for key, url in leg_checks:
        if _is_non_openai_host(url):
            issues.append(ConfigIssue(
                severity="error",
                key=key,
                message=(
                    f"Set to non-OpenAI-compatible host {url!r}. The provider "
                    "service POSTs to /v1/chat/completions, which 404s on this "
                    "host. Leave blank to inherit AI_CHAT_API_URL (Agnes proxies "
                    "the same Gemini models)."
                ),
            ))

    # 4. Default provider must have its key configured
    if settings.AI_DEFAULT_PROVIDER.lower() == "openai" and not settings.AI_OPENAI_API_KEY:
        issues.append(ConfigIssue(
            severity="error",
            key="AI_OPENAI_API_KEY",
            message=(
                "AI_DEFAULT_PROVIDER=openai but the key is empty. Every AI "
                "request will fail with 'provider not configured'. Either set "
                "the key or switch AI_DEFAULT_PROVIDER to custom."
            ),
        ))

    return issues
