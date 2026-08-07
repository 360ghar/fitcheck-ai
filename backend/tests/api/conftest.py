"""Fixtures for the ASGI contract-test layer (``tests/api/``).

Every test here talks to the REAL app (``app.main:app``) through httpx's
ASGITransport or starlette's TestClient, with dependency overrides for the
Supabase clients. This is the layer that exercises routing, middleware,
exception handlers, response models, and dependency wiring — the pieces the
direct-call tests (``tests/integration/``) bypass by design.

Isolation rules enforced here:

- ``app.dependency_overrides`` is global mutable state on the app object;
  an autouse fixture restores it after every test, so no test can leak an
  override into the next.
- The in-memory IP rate-limit store is wiped before and after every test
  (it is keyed by the test client's fixed IP).
- The lifespan never runs (ASGITransport/TestClient outside a context
  manager), so no background Supabase/Pinecone startup tasks fire.
"""

from __future__ import annotations

from unittest.mock import Mock

import httpx
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user
from app.db.connection import get_anon_db, get_db
from tests.utils.auth_helpers import make_admin_user, make_user
from tests.utils.fake_db import FakeDB

app = main_module.app


@pytest.fixture
def api_app():
    """The real FastAPI app object under test."""
    return app


@pytest.fixture
def client(api_app):
    """Sync ASGI client. Not used as a context manager, so the lifespan
    (and its background startup task) never runs."""
    return TestClient(api_app)


@pytest_asyncio.fixture
async def async_client(api_app):
    """Async ASGI client via httpx's ASGITransport (no lifespan)."""
    transport = httpx.ASGITransport(app=api_app)
    async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as c:
        yield c


@pytest.fixture(autouse=True)
def _restore_dependency_overrides():
    """Never let a test leak dependency overrides into the next."""
    yield
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def _reset_ip_rate_limit_store():
    """Wipe the in-memory IP rate-limit store around every api test.

    The store is keyed by the test client's fixed IP, so without a reset one
    test's attempts would count against the next (and against the auth unit
    tests that share the process).
    """
    from app.core import ip_rate_limit

    ip_rate_limit._ip_usage.clear()
    yield
    ip_rate_limit._ip_usage.clear()


# ---------------------------------------------------------------------------
# Dependency overrides
# ---------------------------------------------------------------------------


@pytest.fixture
def db():
    """A fresh FakeDB wired into the app through the ``get_db`` override.

    Seed it with ``FakeDB(rows={...})``/row factories before issuing requests,
    then assert on ``db.inserts`` / ``db.updates`` / ``db.filters``.
    """
    fake = FakeDB()
    app.dependency_overrides[get_db] = lambda: fake
    return fake


@pytest.fixture
def anon_db():
    """A fresh mock of the anon Supabase client wired through ``get_anon_db``."""
    fake = Mock()
    app.dependency_overrides[get_anon_db] = lambda: fake
    return fake


@pytest.fixture
def user(db):
    """An authenticated plain-user override (bypasses token verification)."""
    current = make_user()
    app.dependency_overrides[get_current_user] = lambda: current
    return current


@pytest.fixture
def admin_user(db):
    """An authenticated admin override (passes ``require_admin``)."""
    current = make_admin_user()
    app.dependency_overrides[get_current_user] = lambda: current
    return current
