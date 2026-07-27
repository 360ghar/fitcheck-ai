"""
AI Provider Health Check Service

Monitors availability of AI providers and enables smart fallback with circuit breaker pattern.
Prevents cascading failures by detecting unavailable providers early and failing fast.

Key features:
- Health check with 5-second timeout before requests
- Cache health status for 60 seconds (avoid checking on every request)
- Circuit breaker: After 3 consecutive failures, mark provider unavailable for 2 minutes
- Fail fast with clear error messages instead of retrying unavailable providers
"""

import asyncio
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

logger = get_context_logger(__name__)

# Configuration
HEALTH_CHECK_TTL_SECONDS = 60  # Cache health status for 60 seconds
CIRCUIT_BREAKER_THRESHOLD = 3  # Open circuit after 3 consecutive failures
CIRCUIT_BREAKER_RESET_TIMEOUT = 120  # Try again after 2 minutes
HEALTH_CHECK_TIMEOUT = 5.0  # 5-second timeout for health checks


@dataclass
class HealthStatus:
    """Health status of an AI provider."""
    available: bool
    last_check: float
    consecutive_failures: int
    latency_ms: Optional[float] = None
    error: Optional[str] = None


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
    ) -> HealthStatus:
        """
        Check if provider is healthy with minimal timeout.
        Uses cached result if within TTL.

        Args:
            base_url: Provider base URL (e.g., "https://apihub.agnes-ai.com/v1")
            api_key: API key for authentication
            timeout_seconds: Timeout for health check (default: 5s)

        Returns:
            HealthStatus with availability, latency, and error information
        """
        cache_key = base_url

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
                    if age < CIRCUIT_BREAKER_RESET_TIMEOUT:
                        logger.warning(
                            f"Circuit breaker OPEN for {base_url}",
                            extra={
                                "consecutive_failures": cached.consecutive_failures,
                                "retry_in_seconds": CIRCUIT_BREAKER_RESET_TIMEOUT - age,
                            },
                        )
                        return cached  # Return cached failure status

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
                # Non-OpenAI hosts (e.g. Google Generative Language API) do not
                # accept Bearer auth tokens. Sending Bearer auth always fails with
                # 401, which marks the provider unavailable and forces a fallback
                # to the Agnes gateway on every vision call, adding ~5s latency.
                # For these hosts we skip the Authorization header and rely on
                # the actual request error handling instead.
                if not is_non_openai:
                    headers["Authorization"] = f"Bearer {api_key}"

                response = await client.get(
                    health_url,
                    headers=headers,
                )

                latency = (time.time() - start_time) * 1000

                # Accept 2xx or 404 (404 means API is up but endpoint may vary)
                is_healthy = response.status_code in (200, 404)

                status = HealthStatus(
                    available=is_healthy,
                    last_check=time.time(),
                    consecutive_failures=0 if is_healthy else 1,
                    latency_ms=latency,
                    error=None if is_healthy else f"Status {response.status_code}",
                )

                if is_healthy:
                    logger.info(
                        f"Provider {base_url} is healthy",
                        extra={"latency_ms": round(latency, 2)},
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

    def clear_cache(self, base_url: Optional[str] = None) -> None:
        """
        Clear health cache for specific provider or all providers.

        Args:
            base_url: Provider URL to clear. If None, clears all.
        """
        if base_url:
            self._health_cache.pop(base_url, None)
        else:
            self._health_cache.clear()


# Global singleton
_health_service = AIProviderHealthService()


def get_health_service() -> AIProviderHealthService:
    """Get the global health service singleton."""
    return _health_service
