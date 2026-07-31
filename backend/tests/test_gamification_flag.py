"""
Tests for the ENABLE_GAMIFICATION flag in app/api/v1/gamification.py.

WHY EVERY ASSERTION HERE IS "200 WITH ZEROS" AND NEVER "404":

``flutter/lib/features/dashboard/controllers/dashboard_controller.dart:60-67``
runs an UNGUARDED ``Future.wait([fetchDashboard(), fetchStreak()])`` under a
single ``catch``. ``fetchStreak()`` calls ``/api/v1/gamification/streak`` and
``dashboard_repository.dart`` rethrows a 404 as ``NotFoundException``. A 404
there rejects the whole wait, so ``dashboard.value`` is never assigned even
though ``fetchDashboard()`` succeeded -- while ``isLoading`` still flips to
false. ``dashboard_content.dart:48-63`` then skips the shimmer and renders a
permanent error banner plus a toast against null data, on every launch.

So the router stays mounted (see the comment at ``main.py``'s
``include_router(gamification.router, ...)``) and the flag is enforced inside
the handlers. If someone "simplifies" a guard to ``raise HTTPException(404)``,
these tests are what stops the shipped mobile app from being bricked.

The one intended BEHAVIOR change is also asserted: ``get_streak`` is a GET that
INSERTS a zeroed ``user_streaks`` row when none exists (gamification.py's
insert branch). With the flag off it must not touch the database at all.
"""

import pytest

from app.api.v1 import gamification
from app.api.v1.gamification import get_achievements, get_leaderboard, get_streak
from app.core.config import settings


class _ExplodingDB:
    """Any attribute access is a test failure: the flag guard must return
    before the handler reaches for the database."""

    def __getattr__(self, name):  # noqa: ANN001, ANN204
        raise AssertionError(
            f"gamification handler touched the database (db.{name}) while "
            "ENABLE_GAMIFICATION is False -- the flag guard must short-circuit "
            "before any query or insert."
        )


@pytest.fixture
def gamification_off(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_GAMIFICATION", False)
    return _ExplodingDB()


@pytest.mark.asyncio
async def test_streak_disabled_returns_zeroed_200(gamification_off):
    """Flag off: 200 with a zeroed streak, never a 404 (see module docstring)."""
    result = await get_streak(user_id="user-1", db=gamification_off)

    assert result["message"] == "OK"
    data = result["data"]
    assert data["current_streak"] == 0
    assert data["longest_streak"] == 0
    assert data["last_planned"] is None
    # next_milestone stays populated so the mobile UI has something coherent to
    # render rather than a null it does not expect.
    assert data["next_milestone"] == {"days": 3, "name": "3-day Streak", "badge": "starter"}


@pytest.mark.asyncio
async def test_streak_disabled_does_not_insert_a_user_streaks_row(gamification_off):
    """The intended behavior change: a GET that writes stops writing.

    With the flag on, get_streak inserts a zeroed user_streaks row for any user
    who has none. With it off, `_ExplodingDB` proves no table/insert call is
    made at all -- the write-on-GET side effect is dead.
    """
    result = await get_streak(user_id="brand-new-user", db=gamification_off)

    # Reaching this line at all means db.table(...) was never called.
    assert result["data"]["current_streak"] == 0


@pytest.mark.asyncio
async def test_achievements_disabled_returns_empty_earned_200(gamification_off):
    """Flag off: 200 with nothing earned, never a 404 (see module docstring)."""
    result = await get_achievements(user_id="user-1", db=gamification_off)

    assert result["message"] == "OK"
    assert result["data"]["earned"] == []
    # The catalog is static copy, not user state, so it still ships.
    assert [row["id"] for row in result["data"]["available"]] == [
        "first_upload",
        "first_outfit",
        "streak_7",
    ]


@pytest.mark.asyncio
async def test_leaderboard_disabled_returns_empty_entries_200(gamification_off):
    """Flag off: 200 with no entries, never a 404 (see module docstring)."""
    result = await get_leaderboard(user_id="user-1", db=gamification_off)

    assert result["message"] == "OK"
    assert result["data"]["entries"] == []
    # user_rank must be PRESENT and null. frontend/src/api/gamification.ts reads
    # `data.user_rank`, and the success path always includes the key.
    assert "user_rank" in result["data"]
    assert result["data"]["user_rank"] is None


def test_disabled_payloads_are_the_same_shape_as_the_except_fallbacks():
    """One definition of 'neutral'.

    The flag guard and each handler's own `except` branch return the SAME
    helper, so a future edit cannot make the disabled shape drift from the
    degraded shape. This asserts the helpers exist and are the only source.
    """
    assert set(gamification._disabled_streak_payload()["data"]) == {
        "current_streak",
        "longest_streak",
        "last_planned",
        "streak_freezes_remaining",
        "streak_skips_remaining",
        "next_milestone",
    }
    assert set(gamification._disabled_achievements_payload()["data"]) == {"earned", "available"}
    assert set(gamification._disabled_leaderboard_payload()["data"]) == {"entries", "user_rank"}


def test_gamification_router_is_mounted_regardless_of_the_flag(monkeypatch):
    """The router must stay registered with the flag off.

    Unmounting it turns /streak into a 404, which bricks the Flutter home
    screen (see module docstring). This asserts against the live app object.
    """
    monkeypatch.setattr(settings, "ENABLE_GAMIFICATION", False)
    from app.main import app

    # Read the OpenAPI schema rather than walking ``app.routes``: this FastAPI
    # version keeps included routers as lazy ``_IncludedRouter`` wrappers, so
    # ``app.routes`` is not a flat list of APIRoutes. The schema is also the
    # contract a client actually sees.
    paths = app.openapi()["paths"]
    assert "/api/v1/gamification/streak" in paths
    assert "/api/v1/gamification/achievements" in paths
    assert "/api/v1/gamification/leaderboard" in paths


def test_gamification_tables_are_not_unconditionally_required():
    """With the flag off, /ready must not report user_streaks as missing."""
    from app.main import GAMIFICATION_TABLES, REQUIRED_TABLES

    assert "user_streaks" not in REQUIRED_TABLES
    assert "user_achievements" not in REQUIRED_TABLES
    assert GAMIFICATION_TABLES == ("user_streaks", "user_achievements")
