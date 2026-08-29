"""Concurrency regressions for the MCP OAuth token exchange service."""

from __future__ import annotations

import asyncio
import threading
import uuid
from typing import Any

import pytest

from app.core.exceptions import AuthenticationError
from app.services import mcp_oauth_service as oauth_service


CHATGPT_REDIRECT = "https://chatgpt.com/connector_platform_oauth_redirect"


@pytest.fixture
def oauth_enabled(monkeypatch):
    monkeypatch.setattr(oauth_service.settings, "MCP_OAUTH_ISSUER", "https://api.test/api/v1/oauth")
    monkeypatch.setattr(oauth_service.settings, "PUBLIC_API_BASE_URL", "https://api.test")
    monkeypatch.setattr(
        oauth_service.settings,
        "MCP_REDIRECT_URI_ALLOWLIST",
        "https://chatgpt.com/connector_platform_oauth_redirect",
    )


class _Result:
    def __init__(self, data: Any):
        self.data = data


class _ConcurrentQuery:
    """Small PostgREST fake that makes the old read-then-write race deterministic."""

    def __init__(self, db: "_ConcurrentOAuthDB", table: str):
        self._db = db
        self._table = table
        self._filters: list[tuple[str, str, Any]] = []
        self._mode = "select"
        self._payload: dict[str, Any] | None = None
        self._single = False

    def select(self, *_args, **_kwargs):
        return self

    def eq(self, column: str, value: Any):
        self._filters.append(("eq", column, value))
        return self

    def is_(self, column: str, value: Any):
        self._filters.append(("is", column, value))
        return self

    def maybe_single(self):
        self._single = True
        return self

    def update(self, payload: dict[str, Any]):
        self._mode = "update"
        self._payload = payload
        return self

    def insert(self, payload: dict[str, Any]):
        self._mode = "insert"
        self._payload = payload
        return self

    def execute(self):
        if self._mode == "select":
            with self._db._lock:
                rows = [dict(row) for row in self._matching_rows()]
            if self._table == self._db._barrier_table:
                self._db._barrier.wait(timeout=5)
            if self._single:
                return _Result(rows[0] if rows else None)
            return _Result(rows)

        with self._db._lock:
            if self._mode == "insert":
                row = dict(self._payload or {})
                self._db.rows.setdefault(self._table, []).append(row)
                return _Result([row])

            updated = []
            for row in self._matching_rows():
                row.update(self._payload or {})
                updated.append(dict(row))
            return _Result(updated)

    def _matching_rows(self) -> list[dict[str, Any]]:
        matches = []
        for row in self._db.rows.setdefault(self._table, []):
            if all(self._matches(row, op, column, value) for op, column, value in self._filters):
                matches.append(row)
        return matches

    @staticmethod
    def _matches(row: dict[str, Any], op: str, column: str, value: Any) -> bool:
        if op == "eq":
            return row.get(column) == value
        if op == "is":
            wants_null = value is None or str(value).lower() == "null"
            return (row.get(column) is None) == wants_null
        raise AssertionError(f"unsupported filter: {op}")


class _ConcurrentRpc:
    def __init__(self, db: "_ConcurrentOAuthDB", name: str, params: dict[str, Any]):
        self._db = db
        self._name = name
        self._params = params

    def execute(self):
        return self._db._execute_rpc(self._name, self._params)


class _ConcurrentOAuthDB:
    """Concurrency-aware OAuth storage fake.

    Table calls intentionally expose the stale-read window. The RPC paths
    model the transaction that production uses after this regression is fixed.
    """

    def __init__(self, rows: dict[str, list[dict[str, Any]]], barrier_table: str):
        self.rows = {table: [dict(row) for row in table_rows] for table, table_rows in rows.items()}
        self._barrier_table = barrier_table
        self._barrier = threading.Barrier(2)
        self._lock = threading.Lock()

    def table(self, name: str) -> _ConcurrentQuery:
        return _ConcurrentQuery(self, name)

    def rpc(self, name: str, params: dict[str, Any]) -> _ConcurrentRpc:
        return _ConcurrentRpc(self, name, params)

    def _execute_rpc(self, name: str, params: dict[str, Any]) -> _Result:
        with self._lock:
            if name == "consume_mcp_oauth_authorization_code":
                return self._consume_code(params)
            if name == "rotate_mcp_oauth_refresh_token":
                return self._rotate_refresh_token(params)
        raise AssertionError(f"unexpected RPC: {name}")

    def _consume_code(self, params: dict[str, Any]) -> _Result:
        record = next(
            (
                row
                for row in self.rows.get("mcp_oauth_auth_codes", [])
                if row.get("code_hash") == params["p_code_hash"]
            ),
            None,
        )
        if not record or record.get("used_at"):
            return _Result([{"outcome": "invalid"}])
        if record.get("expires_at") and oauth_service._is_expired(record["expires_at"]):
            return _Result([{"outcome": "expired"}])
        if record.get("client_id") != params["p_client_id"] or record.get("redirect_uri") != params["p_redirect_uri"]:
            return _Result([{"outcome": "client_mismatch"}])
        if record.get("code_challenge") != params["p_code_challenge"]:
            return _Result([{"outcome": "pkce_failed"}])
        if not record.get("user_id"):
            return _Result([{"outcome": "unbound"}])

        record["used_at"] = oauth_service.utcnow().isoformat()
        return _Result(
            [
                {
                    "outcome": "consumed",
                    "user_id": record["user_id"],
                    "scope": record.get("scope") or oauth_service.MCP_SCOPE,
                }
            ]
        )

    def _rotate_refresh_token(self, params: dict[str, Any]) -> _Result:
        record = next(
            (
                row
                for row in self.rows.get("mcp_oauth_refresh_tokens", [])
                if row.get("token_hash") == params["p_token_hash"]
            ),
            None,
        )
        if not record:
            return _Result([{"outcome": "invalid"}])

        if record.get("revoked_at"):
            now = oauth_service.utcnow().isoformat()
            for token in self.rows["mcp_oauth_refresh_tokens"]:
                if token.get("family") == record["family"]:
                    token["revoked_at"] = now
            return _Result([{"outcome": "reused"}])

        if record.get("expires_at") and oauth_service._is_expired(record["expires_at"]):
            return _Result([{"outcome": "expired"}])

        now = oauth_service.utcnow().isoformat()
        record["revoked_at"] = now
        record["replaced_by"] = params["p_replacement_id"]
        self.rows["mcp_oauth_refresh_tokens"].append(
            {
                "id": params["p_replacement_id"],
                "token_hash": params["p_replacement_token_hash"],
                "user_id": record["user_id"],
                "client_id": record["client_id"],
                "scope": record.get("scope") or oauth_service.MCP_SCOPE,
                "family": record["family"],
                "expires_at": params["p_replacement_expires_at"],
                "revoked_at": None,
                "replaced_by": None,
            }
        )
        return _Result(
            [
                {
                    "outcome": "rotated",
                    "user_id": record["user_id"],
                    "client_id": record["client_id"],
                    "scope": record.get("scope") or oauth_service.MCP_SCOPE,
                    "family": record["family"],
                }
            ]
        )


def _code_row(code: str, verifier: str) -> dict[str, Any]:
    return {
        "id": str(uuid.uuid4()),
        "code_hash": oauth_service._hash(code),
        "user_id": str(uuid.uuid4()),
        "client_id": "mcp_test_client",
        "redirect_uri": CHATGPT_REDIRECT,
        "scope": oauth_service.MCP_SCOPE,
        "code_challenge": oauth_service.pkce_challenge(verifier),
        "expires_at": oauth_service._seconds_from_now(60),
        "used_at": None,
    }


@pytest.mark.asyncio
async def test_concurrent_code_exchanges_issue_only_one_token_pair(oauth_enabled):
    code = "one-time-code"
    verifier = "verifier-with-at-least-43-characters-01234567890"
    db = _ConcurrentOAuthDB(
        {"mcp_oauth_auth_codes": [_code_row(code, verifier)]},
        barrier_table="mcp_oauth_auth_codes",
    )

    results = await asyncio.gather(
        *[
            asyncio.to_thread(
                oauth_service.exchange_code_for_tokens,
                db,
                code=code,
                client_id="mcp_test_client",
                redirect_uri=CHATGPT_REDIRECT,
                code_verifier=verifier,
            )
            for _ in range(2)
        ],
        return_exceptions=True,
    )

    assert sum(isinstance(result, dict) for result in results) == 1
    assert sum(isinstance(result, AuthenticationError) for result in results) == 1


@pytest.mark.asyncio
async def test_concurrent_refresh_rotation_mints_one_child_and_revokes_the_family(oauth_enabled):
    refresh_token = "original-refresh-token"
    old_token_id = str(uuid.uuid4())
    db = _ConcurrentOAuthDB(
        {
            "mcp_oauth_refresh_tokens": [
                {
                    "id": old_token_id,
                    "token_hash": oauth_service._hash(refresh_token),
                    "user_id": str(uuid.uuid4()),
                    "client_id": "mcp_test_client",
                    "scope": oauth_service.MCP_SCOPE,
                    "family": str(uuid.uuid4()),
                    "expires_at": oauth_service._seconds_from_now(3600),
                    "revoked_at": None,
                    "replaced_by": None,
                }
            ]
        },
        barrier_table="mcp_oauth_refresh_tokens",
    )

    results = await asyncio.gather(
        *[asyncio.to_thread(oauth_service.rotate_refresh_token, db, refresh_token) for _ in range(2)],
        return_exceptions=True,
    )

    assert sum(isinstance(result, dict) for result in results) == 1
    assert sum(isinstance(result, AuthenticationError) for result in results) == 1
    replacement_tokens = [
        token for token in db.rows["mcp_oauth_refresh_tokens"] if token["id"] != old_token_id
    ]
    assert len(replacement_tokens) == 1
    assert replacement_tokens[0]["revoked_at"] is not None
