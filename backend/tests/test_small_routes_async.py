"""
Regression: no synchronous Supabase ``.execute()`` inside an ``async def``.

``supabase-py``'s ``Client`` is synchronous. An un-wrapped ``.execute()`` inside
a coroutine blocks the whole event loop for a full DB round-trip, so on a
single-worker deployment one slow query stalls every other in-flight request.
The fix is mechanical -- ``await asyncio.to_thread(lambda: <chain>.execute())``
-- and this structural guard keeps it from drifting back.

Shape modelled on ``test_timeout_enforcement.py``'s
``test_no_bare_timeoutless_httpx_clients_in_app_code``, but AST-based so a
nested plain ``def`` (which FastAPI/asyncio already runs in a threadpool) and
the wrapped ``to_thread`` form are not false positives.
"""

import ast
from pathlib import Path

APP_DIR = Path(__file__).resolve().parents[1] / "app"
SCANNED_DIRS = (APP_DIR / "api" / "v1", APP_DIR / "services")

# Callables that hand work off to a worker thread; anything inside their
# argument list is already off the event loop.
OFFLOADERS = {"to_thread", "run_in_threadpool", "run_in_executor", "run_sync"}


def _is_offloader(node: ast.Call) -> bool:
    func = node.func
    name = func.attr if isinstance(func, ast.Attribute) else getattr(func, "id", None)
    return name in OFFLOADERS


def _is_execute(node: ast.Call) -> bool:
    return isinstance(node.func, ast.Attribute) and node.func.attr == "execute"


def _find_bare_executes(tree: ast.AST) -> list[tuple[int, str]]:
    """Return (lineno, enclosing async function name) for each un-offloaded
    ``.execute()`` lexically inside an ``async def`` body."""
    hits: list[tuple[int, str]] = []

    def walk(node: ast.AST, async_fn: str | None) -> None:
        for child in ast.iter_child_nodes(node):
            if isinstance(child, ast.AsyncFunctionDef):
                walk(child, child.name)
            elif isinstance(child, ast.FunctionDef):
                # A plain def already runs in a threadpool (FastAPI) or is
                # passed to to_thread; its body is not on the event loop.
                walk(child, None)
            elif isinstance(child, ast.Call):
                if _is_offloader(child):
                    continue  # everything inside is offloaded
                if async_fn and _is_execute(child):
                    hits.append((child.lineno, async_fn))
                walk(child, async_fn)
            else:
                walk(child, async_fn)

    walk(tree, None)
    return hits


def test_no_blocking_supabase_execute_in_async_code():
    offenders = []
    for directory in SCANNED_DIRS:
        for path in sorted(directory.glob("*.py")):
            tree = ast.parse(path.read_text(), filename=str(path))
            for lineno, fn_name in _find_bare_executes(tree):
                rel = path.relative_to(APP_DIR.parent)
                offenders.append(f"  {rel}:{lineno} in async def {fn_name}()")

    assert not offenders, (
        f"{len(offenders)} blocking Supabase .execute() call(s) inside async def "
        "found in app/api/v1/ or app/services/. Wrap each in "
        "`await asyncio.to_thread(lambda: <chain>.execute())` so the sync "
        "supabase-py client does not block the event loop:\n" + "\n".join(offenders)
    )
