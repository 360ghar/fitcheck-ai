"""Bounded thread-pool executor for CPU-bound image work.

`asyncio.to_thread` uses Python's default executor, sized to
`min(32, os.cpu_count() + 4)` workers. Railway exposes the HOST's core count
to the container, so a 32-core host gives this 512 MB process up to 32
concurrent full-res Pillow decodes — each buffering tens of MB — with no
memory bound (the 2026-08-03 OOM class of failure).

This module owns ONE dedicated executor with a small fixed width
(`IMAGE_PROCESS_WORKERS`, default 4) so concurrent image decodes are bounded
regardless of host cores, while preserving the existing off-the-event-loop
behavior of every call site.

Use `run_image_op()` for:
- `downscale_base64_image` / `crop_base64_image_to_box`
  (app/utils/image_processing.py)
- `remove_white_background` (app/utils/background_removal.py)
- `StorageService._validate_image` (app/services/storage_service.py)

Everything else keeps `asyncio.to_thread`.
"""

import asyncio
import threading
from concurrent.futures import ThreadPoolExecutor
from typing import Awaitable, Callable, Optional, TypeVar

from app.core.config import settings

T = TypeVar("T")

_lock = threading.Lock()
_executor: Optional[ThreadPoolExecutor] = None


def _get_executor() -> ThreadPoolExecutor:
    """Return the shared executor, re-creating it if it was shut down.

    ``shutdown()`` is called from the app lifespan teardown. In a real deploy
    the process exits right after, but tests (and any future in-process
    reload) reuse the module afterward — a one-shot executor would leave
    every later ``run_image_op`` failing with "cannot schedule new futures
    after shutdown".
    """
    global _executor
    if _executor is None:
        with _lock:
            if _executor is None:
                _executor = ThreadPoolExecutor(
                    max_workers=max(1, settings.IMAGE_PROCESS_WORKERS),
                    thread_name_prefix="image-proc",
                )
    return _executor


def run_image_op(fn: Callable[..., T], *args, **kwargs) -> Awaitable[T]:
    """Run a CPU-bound image operation on the bounded executor.

    Must be called from a running event loop (like asyncio.to_thread).
    """
    loop = asyncio.get_running_loop()
    return loop.run_in_executor(_get_executor(), lambda: fn(*args, **kwargs))


def shutdown() -> None:
    """Best-effort executor shutdown for app lifespan teardown.

    In-flight image ops are cancelled; the process is exiting anyway, and a
    hung decode must not delay SIGTERM handling. A later ``run_image_op``
    re-creates the executor (see ``_get_executor``).
    """
    global _executor
    with _lock:
        if _executor is not None:
            try:
                _executor.shutdown(wait=False, cancel_futures=True)
            except Exception:  # pragma: no cover - defensive teardown
                pass
            _executor = None
