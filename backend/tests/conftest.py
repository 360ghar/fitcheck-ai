"""Shared fixtures, fakes, and environment guards for the whole backend suite.

Conventions (see docs/BACKEND.md → "Testing"):

- **Fresh database per test.** The backend has no ORM and talks to hosted
  Supabase only (project non-negotiable), so the suite's "database" is the
  in-memory :class:`tests.utils.fake_db.FakeDB`. The ``fake_db`` fixture
  returns a brand-new instance per test; no database state is ever shared.
- **Never touch the real network.** An autouse fixture refuses outbound TCP
  connects; a test that genuinely needs the network opts out with
  ``@pytest.mark.network`` (none should).
- **Strict isolation.** ``app.dependency_overrides`` is only ever mutated by
  fixtures that restore it in teardown (see ``tests/api/conftest.py``).
- **Function-scoped async.** ``asyncio_default_fixture_loop_scope = function``
  in ``pytest.ini``; async fixtures are function-scoped by default.
"""

from __future__ import annotations

import socket
import sys
from unittest.mock import Mock

import pytest

from tests.utils.fake_db import FakeDB


# ---------------------------------------------------------------------------
# Shared pinecone stub
# ---------------------------------------------------------------------------

# The pinecone client package is not a dev dependency; the vector service
# imports it lazily, and several test modules import that service directly.
# One shared stub in the root conftest (pytest imports it before any test
# module) keeps every copy honest — duplicated per-file stubs drifted.
if "pinecone" not in sys.modules:
    import types as _types

    class _StubServerlessSpec:
        """Minimal stand-in: the vector service instantiates
        ServerlessSpec(cloud=..., region=...) when creating an index, and
        tests assert on spec.cloud/spec.region."""

        def __init__(self, *args, **kwargs):
            self.__dict__.update(kwargs)

    _pinecone_stub = _types.ModuleType("pinecone")
    _pinecone_stub.Pinecone = object
    _pinecone_stub.ServerlessSpec = _StubServerlessSpec
    sys.modules["pinecone"] = _pinecone_stub


# ---------------------------------------------------------------------------
# Environment guard: never hit the real network
# ---------------------------------------------------------------------------


def _refuse_connect(self, address):
    raise OSError(
        "Network access blocked by tests/conftest.py: the backend test suite "
        "must never touch real external services. Patch the client (httpx, "
        "supabase-py, boto3, ...) instead; opt a deliberate exception out "
        "with @pytest.mark.network."
    )


def _refuse_getaddrinfo(*args, **kwargs):
    raise OSError(
        "DNS resolution blocked by tests/conftest.py: the backend test suite "
        "must never touch real external services (socket.getaddrinfo was "
        "called). Patch the client instead; opt a deliberate exception out "
        "with @pytest.mark.network."
    )


@pytest.fixture(autouse=True)
def _block_network(monkeypatch, request):
    """Refuse all outbound TCP connects and DNS resolution unless the test opts out.

    This is the enforcement arm of "never hit real external services in
    tests": a missing mock used to mean a real (slow, credential-leaking,
    CI-flaky) call to the hosted Supabase/Stripe/OpenWeather. With the guard,
    it means an instant, loud failure pointing at the missing patch.
    """
    if request.node.get_closest_marker("network"):
        yield
        return
    monkeypatch.setattr(socket.socket, "connect", _refuse_connect)
    monkeypatch.setattr(socket.socket, "connect_ex", lambda self, address: 1)
    # DNS and UDP are separate sockets paths; patch them too so a missed mock
    # cannot silently perform real lookups/datagrams.
    monkeypatch.setattr(socket, "getaddrinfo", _refuse_getaddrinfo)
    monkeypatch.setattr(socket.socket, "sendto", _refuse_connect)
    yield


# ---------------------------------------------------------------------------
# Database doubles — the suite's "fresh database"
# ---------------------------------------------------------------------------


@pytest.fixture
def fake_db() -> FakeDB:
    """A brand-new in-memory Supabase fake per test.

    Use this wherever a route handler or service takes the ``db`` argument:
    seed it via ``FakeDB(rows={...})`` construction or the row factories in
    ``tests/factories/row_factories.py``, then assert on
    ``db.inserts``/``db.updates``/``db.deletes``/``db.filters``.
    """
    return FakeDB()


@pytest.fixture
def db(fake_db: FakeDB) -> FakeDB:
    """Alias for ``fake_db`` under the name handlers use in signatures."""
    return fake_db


@pytest.fixture
def anon_db() -> Mock:
    """Fresh mock of the anon (publishable-key) Supabase client.

    Auth flows call ``anon_db.auth.sign_in_with_password`` / ``sign_up`` /
    ``sign_out``; configure the mock per test (see
    ``tests/utils/auth_helpers.py`` for ready-made session/user doubles).
    """
    return Mock()


@pytest.fixture
def service_db() -> Mock:
    """Fresh mock of the service-role Supabase client (admin auth lookups)."""
    return Mock()
