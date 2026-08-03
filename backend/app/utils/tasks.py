"""Strong-reference helpers for one-shot background tasks.

asyncio only keeps weak references to tasks, so a discarded
``create_task()`` result can be GC'd mid-run and the job silently stalls.
Any fire-and-forget task must be strongly referenced until it finishes.
This module owns the pattern so the route and service copies cannot drift
(batch_processing / photoshoot / social_import_pipeline previously each
hand-rolled the same add + done-callback-discard sequence).
"""

import asyncio
from typing import Any, Set


def spawn_background_task(coro: "Any", tasks: "Set[asyncio.Task]") -> asyncio.Task:
    """Kick off ``coro`` while holding a strong reference in ``tasks``.

    ``tasks`` is typically a module- or class-level set (the caller keeps it
    alive for the process lifetime); the task is removed by a done callback
    as soon as it finishes, so the set never grows unbounded.
    """
    task = asyncio.create_task(coro)
    tasks.add(task)
    task.add_done_callback(tasks.discard)
    return task
