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

from app.core.logging_config import get_context_logger

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
            base_url: Provider base URL (e.g., "http://localhost:8317/v1")
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

            async with httpx.AsyncClient(
                timeout=httpx.Timeout(timeout_seconds),
                follow_redirects=False,
            ) as client:
                response = await client.get(
                    health_url,
                    headers={"Authorization": f"Bearer {api_key}"},
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

    def get_cache_stats(self) -> Dict[str, int]:
        """
        Get cache statistics for monitoring.

        Returns:
            Dict with cache_size and circuit_breaker_count
        """
        circuit_breaker_count = sum(
            1
            for status in self._health_cache.values()
            if status.consecutive_failures >= CIRCUIT_BREAKER_THRESHOLD
        )

        return {
            "cache_size": len(self._health_cache),
            "circuit_breaker_count": circuit_breaker_count,
        }


# Global singleton
_health_service = AIProviderHealthService()


def get_health_service() -> AIProviderHealthService:
    """Get the global health service singleton."""
    return _health_service
