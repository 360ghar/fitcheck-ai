"""Route-level coverage for app/api/v1/gamification.py.

The flag-off behaviour is owned by tests/integration/test_gamification_flag.py
and the leaderboard avatar materialization by
tests/integration/test_leaderboard_avatar_materialization.py. This file drives
the flag-ON paths those miss: streak read/initialize/fallback, achievement
enrichment (matched, unknown and non-dict rows) and the leaderboard rank
summary, empty-board, display-name fallbacks and outer error branch.

Follows the house convention: call route functions directly with the shared
FakeDB and monkeypatch the feature flag on the settings singleton.
"""

from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from app.api.v1 import gamification
from app.api.v1.gamification import get_achievements, get_leaderboard, get_streak
from app.core.config import settings
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"
OTHER_USER = "22222222-2222-2222-2222-222222222222"


@pytest.fixture(autouse=True)
def _gamification_on(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_GAMIFICATION", True)


def _streak_row(**overrides):
    row = {
        "user_id": USER_ID,
        "current_streak": 3,
        "longest_streak": 5,
        "last_planned_date": "2026-01-01T00:00:00",
        "streak_freezes_remaining": 2,
        "streak_skips_remaining": 1,
        "updated_at": "2026-01-01T00:00:00",
    }
    row.update(overrides)
    return row


# ---------------------------------------------------------------------------
# GET /streak
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_streak_returns_existing_row_and_next_milestone():
    db = FakeDB(rows={"user_streaks": [_streak_row(current_streak=100)]})

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["current_streak"] == 100
    assert result["data"]["longest_streak"] == 5
    assert result["data"]["last_planned"] == "2026-01-01T00:00:00"
    # 100 is a milestone itself: the next one is 365 (loop-continue branch).
    assert result["data"]["next_milestone"] == {"days": 365, "name": "Yearly Legend", "badge": "year"}
    assert db.inserts == [], "an existing row must not be re-inserted"


@pytest.mark.asyncio
async def test_get_streak_no_next_milestone_for_very_long_streaks():
    db = FakeDB(rows={"user_streaks": [_streak_row(current_streak=400)]})

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["data"]["next_milestone"] is None


@pytest.mark.asyncio
async def test_get_streak_tolerates_non_numeric_streak_values():
    """A corrupt row (non-numeric streak) must degrade to zeros, never crash."""
    db = FakeDB(rows={"user_streaks": [_streak_row(current_streak="not-an-int", longest_streak=None)]})

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["data"]["current_streak"] == 0
    assert result["data"]["longest_streak"] == 0


@pytest.mark.asyncio
async def test_get_streak_initializes_a_missing_row():
    """The write-on-GET: a brand-new user gets a zeroed streak record."""
    db = FakeDB(rows={"user_streaks": []})

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["data"]["current_streak"] == 0
    assert result["data"]["streak_freezes_remaining"] == 3
    assert result["data"]["streak_skips_remaining"] == 1
    db.assert_insert("user_streaks", user_id=USER_ID, current_streak=0, longest_streak=0)


@pytest.mark.asyncio
async def test_get_streak_falls_back_when_insert_returns_no_row():
    """A failed streak-record insert must fall back to the zeroed payload."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(data=[])

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["data"]["current_streak"] == 0
    assert result["data"]["next_milestone"] == {"days": 3, "name": "3-day Streak", "badge": "starter"}


@pytest.mark.asyncio
async def test_get_streak_falls_back_on_query_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("db down")
    )

    result = await get_streak(user_id=USER_ID, db=db)

    assert result["data"]["current_streak"] == 0


# ---------------------------------------------------------------------------
# GET /achievements
# ---------------------------------------------------------------------------


def _achievement_row(**overrides):
    row = {"user_id": USER_ID, "achievement_id": "first_upload", "earned_at": "2026-01-02T00:00:00"}
    row.update(overrides)
    return row


@pytest.mark.asyncio
async def test_get_achievements_enriches_known_unknown_and_raw_rows():
    """Earned rows are enriched from the catalog when the achievement id
    matches; unknown ids and non-dict rows degrade to a default name."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.execute.return_value = (
        SimpleNamespace(
            data=[
                _achievement_row(),
                _achievement_row(achievement_id="mystery_badge"),
                "totally-not-a-dict",
            ]
        )
    )

    result = await get_achievements(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    earned = result["data"]["earned"]
    assert earned[0]["name"] == "First Upload"
    assert earned[0]["xp_reward"] == 50
    assert earned[1]["name"] == "Achievement unlocked"
    assert earned[1]["description"] is None
    assert earned[2]["raw"] == "totally-not-a-dict"
    # The available catalog is a fresh copy per call.
    assert [row["id"] for row in result["data"]["available"]] == [
        "first_upload",
        "first_outfit",
        "streak_7",
    ]


@pytest.mark.asyncio
async def test_get_achievements_falls_back_on_query_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.execute.side_effect = (
        RuntimeError("db down")
    )

    result = await get_achievements(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["earned"] == []


# ---------------------------------------------------------------------------
# GET /leaderboard
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_leaderboard_builds_entries_and_rank_summary(monkeypatch):
    """Entries are ranked by streak and the caller's rank summary counts users
    with strictly higher streaks."""
    db = FakeDB(
        rows={
            "user_streaks": [
                # Seeded out of order on purpose: the route must sort by
                # current_streak DESC itself, not inherit fixture order.
                _streak_row(user_id=OTHER_USER, current_streak=4),
                _streak_row(user_id=USER_ID, current_streak=9),
            ],
            "users": [
                {"id": USER_ID, "full_name": "Ada", "avatar_url": "https://cdn/a.png"},
                {"id": OTHER_USER, "full_name": "Grace", "avatar_url": None},
            ],
        }
    )

    async def fake_materialize(avatar_url, *, presigned=False):
        assert presigned is True, "cross-user keys must be presigned, never worker-mode"
        return f"https://fresh.example/{avatar_url}"

    monkeypatch.setattr(gamification, "materialize_avatar_url", fake_materialize)

    result = await get_leaderboard(user_id=USER_ID, db=db)

    assert ("user_streaks", "current_streak", True, False) in db.orders
    entries = {e["user_id"]: e for e in result["data"]["entries"]}
    assert entries[USER_ID]["rank"] == 1
    assert entries[USER_ID]["username"] == "Ada"
    assert entries[USER_ID]["current_streak"] == 9
    assert entries[USER_ID]["total_points"] == 90
    assert entries[USER_ID]["level"] == 1
    assert entries[USER_ID]["avatar_url"] == "https://fresh.example/https://cdn/a.png"
    assert entries[OTHER_USER]["username"] == "Grace"

    rank = result["data"]["user_rank"]
    assert rank["rank"] == 1
    assert rank["total_users"] == 2
    assert rank["total_points"] == 90
    assert rank["level"] == 1
    assert rank["top_percentile"] == 50


@pytest.mark.asyncio
async def test_get_leaderboard_empty_board_returns_zero_rank(monkeypatch):
    """No streaks at all: empty entries and a rank summary of 1/0 users."""
    db = FakeDB(rows={"user_streaks": []})

    result = await get_leaderboard(user_id=USER_ID, db=db)

    assert result["data"]["entries"] == []
    assert result["data"]["user_rank"] == {
        "rank": 1,
        "total_points": 0,
        "level": 1,
        "total_users": 0,
        "top_percentile": 100,
    }


@pytest.mark.asyncio
async def test_get_leaderboard_display_name_fallbacks(monkeypatch):
    """Rows without a profile or without any id must still render a name."""
    db = FakeDB(
        rows={
            "user_streaks": [
                _streak_row(user_id=OTHER_USER, current_streak=2),  # no profile row
                _streak_row(user_id=None, current_streak=1),  # no id at all
            ],
            "users": [],
        }
    )

    async def fake_materialize(avatar_url, *, presigned=False):
        return None

    monkeypatch.setattr(gamification, "materialize_avatar_url", fake_materialize)

    result = await get_leaderboard(user_id=USER_ID, db=db)

    by_rank = {e["rank"]: e for e in result["data"]["entries"]}
    assert by_rank[1]["username"] == f"User {OTHER_USER[:6]}"
    assert by_rank[2]["username"] == "User"


@pytest.mark.asyncio
async def test_get_leaderboard_rank_failure_is_best_effort(monkeypatch):
    """A failure inside the rank summary must not drop the entries."""
    db = FakeDB(rows={"user_streaks": [_streak_row()]})

    async def fake_materialize(avatar_url, *, presigned=False):
        return None

    monkeypatch.setattr(gamification, "materialize_avatar_url", fake_materialize)

    # The me-streak query is the only one that filters by user_id: break it.
    real_table = db.table

    def table(name):
        builder = real_table(name)
        if name == "user_streaks":
            builder.eq = lambda col, value: (_ for _ in ()).throw(RuntimeError("boom"))
        return builder

    db.table = table

    result = await get_leaderboard(user_id=USER_ID, db=db)

    assert len(result["data"]["entries"]) == 1
    assert result["data"]["user_rank"] is None


@pytest.mark.asyncio
async def test_get_leaderboard_falls_back_on_outer_error(monkeypatch):
    db = Mock()
    db.table.return_value.select.return_value.order.return_value.limit.return_value.execute.side_effect = (
        RuntimeError("db down")
    )

    result = await get_leaderboard(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["entries"] == []
    assert result["data"]["user_rank"] is None
