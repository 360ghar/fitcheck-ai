"""
AI Provider Health Check Service

Monitors availability of AI providers and enables smart fallback with circuit breaker pattern.
Prevents cascading failures by detecting unavailable providers early and failing fast.

Key features:
- Health check with 5-second timeout before requests
- Cache health status for 60 seconds (avoid checking on every request)
- Circuit breaker: after 3 consecutive failures the provider is marked
  unavailable, and the cooldown grows from 20s (doubling, capped at 5min,
  jittered) instead of a flat 2 minutes. Provider-side concurrency rejections
  take a separate short cooldown and never advance the failure streak.
- Fail fast with clear error messages instead of retrying unavailable providers
"""

import asyncio
import hashlib
import random
import time
from typing import Dict, Optional
from dataclasses import dataclass
import httpx
from urllib.parse import urlparse

from app.core.logging_config import get_context_logger

# Hosts that are not OpenAI-compatible. The provider service POSTs to
# `<host>/v1/chat/completions`, which 404s on these native Google endpoints.
# Agnes already proxies the same Gemini models through an OpenAI-shaped API,
# so leaving the per-leg URL blank (inherit chat) is the correct setup.
_NON_OPENAI_HOSTS = (
    "generativelanguage.googleapis.com",
)


def _is_non_openai_host(base_url: str) -> bool:
    if not base_url:
        return False
    host = (urlparse(base_url).hostname or "").lower()
    return any(host == bad or host.endswith("." + bad) for bad in _NON_OPENAI_HOSTS)


def _cache_key(base_url: str, api_key: Optional[str]) -> str:
    """Health/breaker cache key.

    A3-10: keyed per (host, api key) — one user's bad BYOK key failing real
    calls must never open the breaker for every other user on the same host.
    No key (system-default legs) degrades to the host key, preserving the
    shared default-provider breaker.
    """
    if not api_key:
        return base_url
    return f"{base_url}|{hashlib.sha256(api_key.encode()).hexdigest()[:16]}"

logger = get_context_logger(__name__)

# Configuration
HEALTH_CHECK_TTL_SECONDS = 60  # Cache health status for 60 seconds
CIRCUIT_BREAKER_THRESHOLD = 3  # Open circuit after 3 consecutive failures
CIRCUIT_BREAKER_RESET_TIMEOUT = 120  # Legacy flat window, used by probe-written
# entries that carry no cooldown of their own. Real-call outcomes use the
# adaptive window below instead.
CIRCUIT_BREAKER_BASE_COOLDOWN = 20.0  # First open: retry after ~20s
CIRCUIT_BREAKER_MAX_COOLDOWN = 300.0  # Doubling ceiling: never wait > 5min
# A concurrency rejection is not a provider fault (see record_result overload
# below): it earns a short, single-purpose cooldown so a busy minute does not
# escalate into a multi-minute fail-fast window.
OVERLOAD_COOLDOWN_SECONDS = 10.0
HEALTH_CHECK_TIMEOUT = 5.0  # 5-second timeout for health checks


def _breaker_cooldown(consecutive_failures: int) -> float:
    """How long the breaker stays open for a failure streak.

    Flat 120s was wrong in both directions (2026-09-17 RCA): a provider that
    blipped once stayed blocked for two full minutes, and a provider that was
    genuinely down got retried every two minutes forever. The window now grows
    geometrically from the point the breaker opens (20s, 40s, 80s, 160s, capped
    at 300s) and is jittered by +/-25% so a fleet of workers does not retry in
    lockstep and re-create the same pile-up that opened the breaker.

    The EFFECTIVE window is ``max(HEALTH_CHECK_TTL_SECONDS, cooldown)``: a cache
    entry younger than its 60s TTL is returned before the breaker is consulted,
    so a short streak (3-4 failures = 20s/40s) waits out the TTL and only longer
    streaks (5+ = 80s+) extend past it. That floor is intended - the first
    minute of fail-fast is unchanged, and a blip no longer costs the second
    minute the flat window charged.
    """
    steps_over_threshold = max(0, consecutive_failures - CIRCUIT_BREAKER_THRESHOLD)
    cooldown = min(
        CIRCUIT_BREAKER_BASE_COOLDOWN * (2 ** steps_over_threshold),
        CIRCUIT_BREAKER_MAX_COOLDOWN,
    )
    return cooldown * (0.75 + random.random() * 0.5)


@dataclass
class HealthStatus:
    """Health status of an AI provider."""
    available: bool
    last_check: float
    consecutive_failures: int
    latency_ms: Optional[float] = None
    error: Optional[str] = None
    # How long this entry keeps the breaker open. 0 falls back to
    # CIRCUIT_BREAKER_RESET_TIMEOUT for entries written before this field
    # existed (probes, tests, restored state).
    cooldown_seconds: float = 0.0


class AIProviderHealthService:
    """Monitor and track health of AI providers with circuit breaker."""

    def __init__(self):
        self._health_cache: Dict[str, HealthStatus] = {}
        self._lock = asyncio.Lock()

    async def check_provider_health(
        self,
        base_url: str,
        api_key: str,
        timeout_seconds: float = HEALTH_CHECK_TIMEOUT,
        probe_on_cold: bool = True,
    ) -> HealthStatus:
        """
        Check if provider is healthy with minimal timeout.
        Uses cached result if within TTL.

        Args:
            base_url: Provider base URL (e.g., "https://apihub.agnes-ai.com/v1")
            api_key: API key for authentication
            timeout_seconds: Timeout for health check (default: 5s)
            probe_on_cold: When False and the cache is COLD, skip the probe and
                report available — the caller is about to make the real call
                itself, and the outcome will be recorded via ``record_result``.
                Probes stay the behavior for warm-cache reads and for callers
                that only want availability (health endpoints).

        Returns:
            HealthStatus with availability, latency, and error information
        """
        cache_key = _cache_key(base_url, api_key)

        # Check cache first
        async with self._lock:
            if cache_key in self._health_cache:
                cached = self._health_cache[cache_key]
                age = time.time() - cached.last_check

                # Return cached if within TTL
                if age < HEALTH_CHECK_TTL_SECONDS:
                    return cached

                # Circuit breaker: if too many failures, wait longer before retry
                if cached.consecutive_failures >= CIRCUIT_BREAKER_THRESHOLD:
                    cooldown = cached.cooldown_seconds or CIRCUIT_BREAKER_RESET_TIMEOUT
                    if age < cooldown:
                        logger.warning(
                            f"Circuit breaker OPEN for {base_url}",
                            extra={
                                "consecutive_failures": cached.consecutive_failures,
                                "retry_in_seconds": round(cooldown - age, 1),
                            },
                        )
                        return cached  # Return cached failure status

        if cache_key not in self._health_cache and not probe_on_cold:
            # Cold cache and the caller is about to make the call itself: a
            # probe would add a full extra round-trip before every first call
            # to a provider. Report available and let the real call outcome
            # (record_result) drive the circuit breaker.
            return HealthStatus(
                available=True,
                last_check=time.time(),
                consecutive_failures=0,
            )

        # Perform actual health check
        start_time = time.time()
        try:
            # Build health check URL - try /models endpoint (OpenAI-compatible)
            health_url = f"{base_url.rstrip('/')}/models"
            is_non_openai = _is_non_openai_host(base_url)

            async with httpx.AsyncClient(
                timeout=httpx.Timeout(timeout_seconds),
                follow_redirects=False,
            ) as client:
                headers = {}
                if is_non_openai:
                    # Google's Generative Language API authenticates via the
                    # x-goog-api-key header, not Bearer (A3b-01): a probe
                    # with NO auth header always answers 400, which would
                    # accumulate failures and latch the circuit breaker for
                    # an otherwise healthy provider.
                    headers["x-goog-api-key"] = api_key
                else:
                    # Non-OpenAI hosts (e.g. Google Generative Language API)
                    # do not accept Bearer auth tokens. Sending Bearer auth
                    # always fails with 401, which marks the provider
                    # unavailable and forces a fallback to the Agnes gateway
                    # on every vision call, adding ~5s latency. For these
                    # hosts we skip the Authorization header and rely on the
                    # actual request error handling instead.
                    headers["Authorization"] = f"Bearer {api_key}"

                response = await client.get(
                    health_url,
                    headers=headers,
                )

                latency = (time.time() - start_time) * 1000

                # Accept 2xx or 404 (404 means API is up but endpoint may vary)
                is_healthy = response.status_code in (200, 404)

                # 401/403 from the /models probe almost always means the
                # bearer key (AI_CHAT_API_KEY / AI_VISION_API_KEY / per-leg
                # override) was rejected or expired. Surface that explicitly
                # so the downstream AIServiceError message points at the key
                # instead of the generic "Status 401 / service not running".
                if not is_healthy and response.status_code in (401, 403):
                    error_msg = (
                        f"Auth rejected (HTTP {response.status_code}) at {base_url}: "
                        "API key is missing, invalid, or expired. Check the matching "
                        "AI_CHAT_API_KEY / AI_VISION_API_KEY / per-leg key."
                    )
                else:
                    error_msg = f"Status {response.status_code}"

                # A3-05: carry the previous counter forward for unhealthy
                # HTTP statuses instead of resetting to 1 every time — a
                # persistent 5xx/404 must accumulate toward the breaker
                # threshold exactly like connection errors do below.
                prev_failures = self._health_cache.get(cache_key)
                failures = (prev_failures.consecutive_failures + 1) if prev_failures else 1

                status = HealthStatus(
                    available=is_healthy,
                    last_check=time.time(),
                    consecutive_failures=0 if is_healthy else failures,
                    cooldown_seconds=0.0 if is_healthy else _breaker_cooldown(failures),
                    latency_ms=latency,
                    error=None if is_healthy else error_msg,
                )

                if is_healthy:
                    logger.info(
                        f"Provider {base_url} is healthy",
                        extra={"latency_ms": round(latency, 2)},
                    )
                elif response.status_code in (401, 403):
                    # Auth failures are operator-actionable; log at error so
                    # they stand out from routine transient gateway 5xx.
                    logger.error(
                        f"Provider {base_url} rejected auth (HTTP {response.status_code})",
                        extra={
                            "latency_ms": round(latency, 2),
                            "status_code": response.status_code,
                        },
                    )
                else:
                    logger.warning(
                        f"Provider {base_url} returned {response.status_code}",
                        extra={"latency_ms": round(latency, 2)},
                    )

        except (httpx.ConnectError, httpx.ConnectTimeout) as e:
            # Connection refused or timeout - provider is down
            prev_failures = self._health_cache.get(cache_key)
            failures = (prev_failures.consecutive_failures + 1) if prev_failures else 1

            status = HealthStatus(
                available=False,
                last_check=time.time(),
                consecutive_failures=failures,
                cooldown_seconds=_breaker_cooldown(failures),
                latency_ms=None,
                error=f"Connection error: {type(e).__name__}",
            )

            logger.warning(
                f"Provider {base_url} is UNAVAILABLE",
                extra={
                    "error": str(e),
                    "consecutive_failures": failures,
                },
            )

        except Exception as e:
            # Other errors - treat as unhealthy
            prev_failures = self._health_cache.get(cache_key)
            failures = (prev_failures.consecutive_failures + 1) if prev_failures else 1

            status = HealthStatus(
                available=False,
                last_check=time.time(),
                consecutive_failures=failures,
                cooldown_seconds=_breaker_cooldown(failures),
                latency_ms=None,
                error=str(e),
            )

            logger.error(
                f"Health check failed for {base_url}",
                extra={
                    "error": str(e),
                    "consecutive_failures": failures,
                },
            )

        # Update cache
        async with self._lock:
            self._health_cache[cache_key] = status

        return status

    async def record_result(
        self,
        base_url: str,
        ok: bool,
        api_key: Optional[str] = None,
        overload: bool = False,
    ) -> None:
        """Record the outcome of a REAL provider call (not a probe).

        The circuit breaker previously only learned from probe failures: a
        provider that only ever failed on actual requests (and never during
        the /models probe) stayed "healthy" forever, so every call burned the
        full retry budget before failing. Recording real outcomes makes the
        breaker trip after CIRCUIT_BREAKER_THRESHOLD consecutive real
        failures and reset on the first success.

        ``last_check`` is refreshed on both outcomes so a just-recorded call
        suppresses a redundant probe for the TTL window.

        ``api_key`` must match the key used for the call (A3-10): the breaker
        is keyed per (host, key), so a user-specific BYOK failure cannot open
        the breaker for other users on the same host.

        ``overload=True`` marks a failure the provider attributed to OUR own
        concurrency ("Exceeded concurrency limit."): the gateway is healthy and
        refusing work it has no slot for. Such an outcome neither advances nor
        resets the failure streak - it only installs a short cooldown, so a
        busy minute backs the caller off without turning into a multi-minute
        fail-fast outage (2026-09-17: 15 concurrency rejections opened the
        breaker for 120s on a provider that was up the whole time). If the
        breaker was already open with a longer adaptive window, this shortens
        it: a reply - even a refusal - proves the provider is reachable.
        """
        now = time.time()
        cache_key = _cache_key(base_url, api_key)
        async with self._lock:
            prev = self._health_cache.get(cache_key)
            if ok:
                self._health_cache[cache_key] = HealthStatus(
                    available=True,
                    last_check=now,
                    consecutive_failures=0,
                )
                return
            if overload:
                failures = prev.consecutive_failures if prev else 0
                self._health_cache[cache_key] = HealthStatus(
                    available=failures < CIRCUIT_BREAKER_THRESHOLD,
                    last_check=now,
                    consecutive_failures=failures,
                    cooldown_seconds=OVERLOAD_COOLDOWN_SECONDS,
                    error="Provider overloaded (concurrency limit)",
                )
                logger.warning(
                    f"Provider {base_url} rejected a call on its concurrency limit",
                    extra={
                        "base_url": base_url,
                        "consecutive_failures": failures,
                        "retry_in_seconds": OVERLOAD_COOLDOWN_SECONDS,
                    },
                )
                return
            failures = (prev.consecutive_failures + 1) if prev else 1
            cooldown = _breaker_cooldown(failures)
            self._health_cache[cache_key] = HealthStatus(
                available=failures < CIRCUIT_BREAKER_THRESHOLD,
                last_check=now,
                consecutive_failures=failures,
                cooldown_seconds=cooldown,
                error=f"Provider call failed ({failures} consecutive)",
            )
            if not self._health_cache[cache_key].available:
                logger.warning(
                    f"Circuit breaker OPEN for {base_url} after "
                    f"{failures} consecutive real call failures",
                    extra={
                        "base_url": base_url,
                        "consecutive_failures": failures,
                        "retry_in_seconds": round(cooldown, 1),
                    },
                )

    def clear_cache(self, base_url: Optional[str] = None) -> None:
        """
        Clear health cache for specific provider or all providers.

        Args:
            base_url: Provider URL to clear. If None, clears all.
        """
        if base_url:
            # A3b-02: entries live under `{base_url}` OR
            # `{base_url}|{sha256(api_key)[:16]}` (per-key breaker, A3-10) —
            # popping only the bare URL left every keyed entry in place, so
            # the ConnectError "clear on retry" recovery was a no-op and the
            # provider kept failing fast from stale state.
            self._health_cache.pop(base_url, None)
            prefix = f"{base_url}|"
            for key in [k for k in self._health_cache if k.startswith(prefix)]:
                self._health_cache.pop(key, None)
        else:
            self._health_cache.clear()


# Global singleton
_health_service = AIProviderHealthService()


def get_health_service() -> AIProviderHealthService:
    """Get the global health service singleton."""
    return _health_service
