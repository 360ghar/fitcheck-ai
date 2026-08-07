"""Leaderboard avatars must be re-materialized, not served from the DB column.

THE BUG THIS PINS (live on production before 2026-08-05):
``users.avatar_url`` is written at upload time with the LIVE presigned URL
(``users.py`` stores whatever ``StorageService.upload_avatar`` returned), so the
stored string is dead once ``OBJECT_STORAGE_PRESIGN_TTL`` (1h) elapses.
``/users/me`` re-materializes it; ``/gamification/leaderboard`` returned
``profile.get("avatar_url")`` RAW. Every leaderboard face whose avatar was
uploaded more than an hour earlier was therefore a broken image.

WHY presigned=True AND NOT worker-mode URLs:
these are OTHER users' object keys. The Worker's authorization rule is "first
path segment == the token's `sub`" (mirrored from ``images._is_owned_by_user``),
so a cross-user key is an indistinguishable 404 there. A worker-mode leaderboard
would render zero avatars. The presigned URL carries its own authorization in
the signature and works for any viewer, which is what this surface needs.
"""

import pytest

from app.api.v1 import gamification
from app.api.v1.gamification import get_leaderboard
from app.core.config import settings

USER_A = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
USER_B = "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb"

# What the column actually holds: a presigned URL frozen at upload time.
STALE_PRESIGNED = (
    f"https://t3.storageapi.dev/bucket/{USER_B}/avatars/"
    "deadbeefdeadbeefdeadbeefdeadbeef.png"
    "?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20260101T000000Z"
    "&X-Amz-Expires=3600&X-Amz-Signature=stale"
)
EXTERNAL_OAUTH = "https://lh3.googleusercontent.com/a/ACw8oPics97qXtDAbcD=w96-h96"


class _Chain:
    """Minimal stand-in for the supabase-py query builder."""

    def __init__(self, rows):
        self._rows = rows

    def select(self, *_a, **_k):
        return self

    def order(self, *_a, **_k):
        return self

    def limit(self, *_a, **_k):
        return self

    def in_(self, *_a, **_k):
        return self

    def eq(self, *_a, **_k):
        return self

    def execute(self):
        return type("Result", (), {"data": self._rows})()


class _FakeDB:
    def __init__(self, tables):
        self._tables = tables

    def table(self, name):
        return _Chain(self._tables.get(name, []))


@pytest.fixture
def leaderboard_db():
    return _FakeDB(
        {
            "user_streaks": [
                {"user_id": USER_A, "current_streak": 9},
                {"user_id": USER_B, "current_streak": 4},
            ],
            "users": [
                {"id": USER_A, "full_name": "Ada", "avatar_url": EXTERNAL_OAUTH},
                {"id": USER_B, "full_name": "Grace", "avatar_url": STALE_PRESIGNED},
            ],
        }
    )


@pytest.fixture(autouse=True)
def _gamification_on(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_GAMIFICATION", True)


@pytest.mark.asyncio
async def test_leaderboard_refreshes_a_stale_presigned_avatar(
    monkeypatch, leaderboard_db
):
    calls = []

    async def _fake_materialize(avatar_url, *, presigned=False):
        calls.append((avatar_url, presigned))
        if "storageapi.dev" not in (avatar_url or ""):
            return None  # not one of our objects
        return f"https://fresh.example/{USER_B}/avatars/x.png"

    monkeypatch.setattr(gamification, "materialize_avatar_url", _fake_materialize)

    result = await get_leaderboard(user_id=USER_A, db=leaderboard_db)
    entries = {e["user_id"]: e for e in result["data"]["entries"]}

    # The stale URL is replaced, NOT passed through.
    assert entries[USER_B]["avatar_url"] == f"https://fresh.example/{USER_B}/avatars/x.png"
    assert "X-Amz-Signature=stale" not in entries[USER_B]["avatar_url"]

    # Cross-user keys must be signed, never worker-mode URLs (see module docstring).
    assert all(presigned is True for _url, presigned in calls)


@pytest.mark.asyncio
async def test_leaderboard_passes_external_oauth_avatar_through(
    monkeypatch, leaderboard_db
):
    """An OAuth provider `picture` is not ours; mangling it into a bucket key
    would serve a 404 for every social-login user on the board."""

    async def _fake_materialize(avatar_url, *, presigned=False):
        return None if "googleusercontent" in (avatar_url or "") else "https://x/y"

    monkeypatch.setattr(gamification, "materialize_avatar_url", _fake_materialize)

    result = await get_leaderboard(user_id=USER_A, db=leaderboard_db)
    entries = {e["user_id"]: e for e in result["data"]["entries"]}
    assert entries[USER_A]["avatar_url"] == EXTERNAL_OAUTH


@pytest.mark.asyncio
async def test_leaderboard_tolerates_a_missing_avatar(monkeypatch):
    """No avatar at all must stay None rather than becoming a broken URL."""

    async def _fake_materialize(avatar_url, *, presigned=False):
        return None

    monkeypatch.setattr(gamification, "materialize_avatar_url", _fake_materialize)
    db = _FakeDB(
        {
            "user_streaks": [{"user_id": USER_A, "current_streak": 3}],
            "users": [{"id": USER_A, "full_name": "Ada", "avatar_url": None}],
        }
    )

    result = await get_leaderboard(user_id=USER_A, db=db)
    assert result["data"]["entries"][0]["avatar_url"] is None
