"""
Startup config health checks.

Pure read of `settings`: returns a list of issues found so the caller
(lifespan) can log them on every boot. Never raises, never does I/O, so
a check itself cannot delay uvicorn from binding the port.

Why this exists: AI_ENCRYPTION_KEY, FRONTEND_URL, and AI_VISION_API_URL
have all been observed mis-set in production Railway env. Each one fails
silently at request time and is hard to diagnose from logs alone. The Apple
IAP checks (#8/#9) exist because missing APPLE_* vars make every iOS
purchase registration fail closed at request time ("Apple IAP is not
configured") - the store sale succeeds but the entitlement is never granted.
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

    # 5. Native Gemini API key must be configured whenever anything routes to
    # it - either as the system default provider, or as the Custom provider's
    # hybrid vision leg (#6 below). Not gated on the per-leg checks above
    # (#3) - those are scoped to the OpenAI-compatible Custom provider's URLs
    # only and never apply to Gemini's own (URL-less) config. Checked as one
    # combined condition, not two separate ConfigIssues, so a config with
    # both flags set (unusual but valid - AI_DEFAULT_PROVIDER=gemini and a
    # per-request AIProvider.CUSTOM caller also using the hybrid vision leg)
    # doesn't log the same missing-key problem twice under the same key.
    gemini_is_default = settings.AI_DEFAULT_PROVIDER.lower() == "gemini"
    gemini_is_vision_leg = settings.AI_VISION_PROVIDER.lower() == "gemini"
    if (gemini_is_default or gemini_is_vision_leg) and not settings.AI_GEMINI_API_KEY:
        reasons = []
        if gemini_is_default:
            reasons.append("AI_DEFAULT_PROVIDER=gemini")
        if gemini_is_vision_leg:
            reasons.append("AI_VISION_PROVIDER=gemini")
        issues.append(ConfigIssue(
            severity="error",
            key="AI_GEMINI_API_KEY",
            message=(
                f"{' and '.join(reasons)} but AI_GEMINI_API_KEY is empty. "
                "Every request routed through native Gemini will fail with "
                "'provider not configured'."
            ),
        ))

    # 6. AI_VISION_API_URL becomes dead config once the vision leg is
    # redirected to native Gemini - flag the combination instead of letting
    # an operator wonder which of the two settings actually wins.
    if settings.AI_VISION_PROVIDER.lower() == "gemini" and (settings.AI_VISION_API_URL or "").strip():
        issues.append(ConfigIssue(
            severity="error",
            key="AI_VISION_API_URL",
            message=(
                f"Set to {settings.AI_VISION_API_URL!r} but AI_VISION_PROVIDER=gemini "
                "already routes the vision leg straight to Google's native API - this "
                "URL is never read and is dead config. Clear it to avoid confusion."
            ),
        ))

    # 7. Gemini-primary needs a working Agnes fallback key. The fallback
    # (AI_VISION_FALLBACK_MODEL defaults to agnes-2.5-flash) is what absorbs
    # Gemini free-tier quota exhaustion (5/min, 20/day) so extraction keeps
    # working instead of surfacing a 429. The key resolves
    # AI_VISION_FALLBACK_API_KEY -> AI_VISION_API_KEY -> AI_CHAT_API_KEY; if all
    # are empty the fallback can't fire and every Gemini 429 fails the request.
    if (
        settings.AI_DEFAULT_PROVIDER.lower() == "custom"
        and settings.AI_VISION_PROVIDER.lower() == "gemini"
    ):
        # Native-Gemini deployments (AI_DEFAULT_PROVIDER=gemini) never consult
        # the fallback key fields, so this warning would be misleading there;
        # it applies to the Custom provider's hybrid Gemini vision leg only.
        fallback_key = (
            (settings.AI_VISION_FALLBACK_API_KEY or "")
            or (settings.AI_VISION_API_KEY or "")
            or (settings.AI_CHAT_API_KEY or "")
        ).strip()
        if not fallback_key:
            issues.append(ConfigIssue(
                severity="warning",
                key="AI_CHAT_API_KEY",
                message=(
                    "AI_VISION_PROVIDER=gemini but no Agnes fallback key resolves "
                    "(checked AI_VISION_FALLBACK_API_KEY, AI_VISION_API_KEY, "
                    "AI_CHAT_API_KEY). The Agnes fallback absorbs Gemini free-tier "
                    "quota exhaustion; without it, every Gemini 429 fails the "
                    "extraction. Set AI_CHAT_API_KEY (or move Gemini to a paid tier)."
                ),
            ))

    # 8. Apple IAP verification credentials. Without all three, every iOS
    # purchase registration fails closed at request time
    # (AppleIAPService.verify_transaction raises "Apple IAP is not
    # configured") - the app can buy via StoreKit but never receives an
    # entitlement. Surfaced here so a deploy missing the credentials is
    # caught in the startup logs, not discovered by the first paying user.
    missing_apple_creds = [
        name
        for name, value in (
            ("APPLE_ISSUER_ID", settings.APPLE_ISSUER_ID),
            ("APPLE_KEY_ID", settings.APPLE_KEY_ID),
            ("APPLE_PRIVATE_KEY", settings.APPLE_PRIVATE_KEY),
        )
        if not (value or "").strip()
    ]
    if missing_apple_creds:
        issues.append(ConfigIssue(
            severity="error",
            key="APPLE_ISSUER_ID",
            message=(
                "Apple IAP verification is not configured "
                f"({' and '.join(missing_apple_creds)} missing). Every iOS "
                "purchase registration fails closed at request time. Create an "
                "App Store Connect API key with the In-App Purchase permission "
                "(ASC > Users and Access > Integrations) and set APPLE_ISSUER_ID, "
                "APPLE_KEY_ID, APPLE_PRIVATE_KEY."
            ),
        ))

    # 9. Apple product map. The /plans endpoint publishes these IDs to the
    # mobile apps (store_products.apple); a missing ID makes that variant
    # show "not available for purchase yet" in-app and makes transaction
    # verification reject it. Warn (not error): the other variants and the
    # web/Stripe rail keep working.
    missing_apple_products = [
        name
        for name, value in (
            ("APPLE_PLUS_MONTHLY_PRODUCT_ID", settings.APPLE_PLUS_MONTHLY_PRODUCT_ID),
            ("APPLE_PLUS_YEARLY_PRODUCT_ID", settings.APPLE_PLUS_YEARLY_PRODUCT_ID),
            ("APPLE_PRO_MONTHLY_PRODUCT_ID", settings.APPLE_PRO_MONTHLY_PRODUCT_ID),
            ("APPLE_PRO_YEARLY_PRODUCT_ID", settings.APPLE_PRO_YEARLY_PRODUCT_ID),
        )
        if not (value or "").strip()
    ]
    if missing_apple_products:
        issues.append(ConfigIssue(
            severity="warning",
            key="APPLE_PLUS_MONTHLY_PRODUCT_ID",
            message=(
                "Apple product map is incomplete "
                f"({' and '.join(missing_apple_products)} missing). /plans "
                "publishes null for those variants so the iOS app shows 'not "
                "available for purchase yet'. Create the matching auto-renewable "
                "subscriptions in App Store Connect > Monetization > Subscriptions "
                "and set the APPLE_*_PRODUCT_ID vars to the exact same IDs."
            ),
        ))

    # 10. Stripe web billing. Without STRIPE_SECRET_KEY and the four price IDs,
    # every web checkout fails closed with a 503 at request time
    # ("Stripe is not configured" / "Stripe price not configured") - observed
    # 2026-08-01: dozens of /subscription/checkout 503s. Surfaced here so a
    # deploy missing the credentials is caught in the startup logs, like the
    # Apple IAP checks above.
    missing_stripe = [
        name
        for name, value in (
            ("STRIPE_SECRET_KEY", settings.STRIPE_SECRET_KEY),
            ("STRIPE_PLUS_MONTHLY_PRICE_ID", settings.STRIPE_PLUS_MONTHLY_PRICE_ID),
            ("STRIPE_PLUS_YEARLY_PRICE_ID", settings.STRIPE_PLUS_YEARLY_PRICE_ID),
            ("STRIPE_PRO_MONTHLY_PRICE_ID", settings.STRIPE_PRO_MONTHLY_PRICE_ID),
            ("STRIPE_PRO_YEARLY_PRICE_ID", settings.STRIPE_PRO_YEARLY_PRICE_ID),
        )
        if not (value or "").strip()
    ]
    if missing_stripe:
        issues.append(ConfigIssue(
            severity="error",
            key="STRIPE_SECRET_KEY",
            message=(
                "Stripe web billing is not configured "
                f"({' and '.join(missing_stripe)} missing). Every web checkout "
                "fails closed with a 503 at request time. Create subscription "
                "prices in Stripe and set STRIPE_SECRET_KEY plus the four "
                "STRIPE_*_PRICE_ID vars."
            ),
        ))

    return issues
