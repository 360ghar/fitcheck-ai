"""
Lightweight process memory breadcrumbs for production diagnostics.

Used to correlate Railway restarts with memory spikes (OOM) without a
full metrics stack. Logs RSS/job counts at low frequency; safe if /proc
is unavailable (macOS local dev).
"""

from __future__ import annotations

import logging
import resource
import time
from typing import Any, Dict, Optional

logger = logging.getLogger(__name__)

# Minimum interval between automatic RSS logs (seconds)
_MIN_LOG_INTERVAL_S = 120.0
_last_log_at: float = 0.0


def get_rss_mb() -> Optional[float]:
    """Return resident set size in megabytes, or None if unavailable."""
    try:
        # ru_maxrss is kilobytes on Linux, bytes on macOS.
        usage = resource.getrusage(resource.RUSAGE_SELF)
        rss = float(usage.ru_maxrss)
        # Heuristic: values > 10_000_000 are almost certainly bytes (macOS).
        if rss > 10_000_000:
            return round(rss / (1024 * 1024), 1)
        return round(rss / 1024, 1)
    except Exception:
        return None


def estimate_base64_mb(payloads: list[str]) -> float:
    """Rough decoded size estimate for base64 strings (MB)."""
    total = sum(len(p) for p in payloads if p)
    # base64 expands ~4/3; string length is encoded size.
    return round(total / (1024 * 1024), 2)


def log_memory(
    reason: str,
    *,
    force: bool = False,
    extra: Optional[Dict[str, Any]] = None,
) -> None:
    """Log process RSS with optional context. Rate-limited unless force=True."""
    global _last_log_at
    now = time.monotonic()
    if not force and (now - _last_log_at) < _MIN_LOG_INTERVAL_S:
        return
    _last_log_at = now

    payload: Dict[str, Any] = {
        "reason": reason,
        "rss_mb": get_rss_mb(),
    }
    if extra:
        payload.update(extra)
    logger.info("process_memory %s", payload)
