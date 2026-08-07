"""Route-level coverage for app/api/v1/recommendations.py.

Extends the sibling files (astrology / item images / wardrobe gaps) with the
routes and branches they do not touch: match/complete-look/personalized,
weather heuristics, similar-items vector + fallback paths, style analysis,
wardrobe gaps/shopping/capsule routes, rating, the shared error-handling
decorator, and the birth-profile schema-migration fallbacks.

Follows the house convention: call route functions directly with a fake
Supabase client (bypasses auth), assert the ``result["data"]`` envelope, and
patch services with AsyncMock / monkeypatch. The shared FakeDB's ``not_`` is a
method rather than a property, so the routes that chain ``.not_.in_(...)`` use
the small ``_NotAwareDB`` subclass below.
"""
from datetime import date, datetime, time as dt_time
from types import SimpleNamespace
from typing import Any, Dict, List, Optional
from unittest.mock import AsyncMock, Mock, patch

import pytest
from pydantic import ValidationError as PydanticValidationError

from app.api.v1 import recommendations as recs_module
from app.api.v1.recommendations import (
    CompleteLookRequest,
    MatchRequest,
    RateRecommendationRequest,
    _coerce_date,
    _coerce_time,
    _extract_missing_users_column,
    _get_auth_birth_profile,
    _get_user_birth_profile,
    _normalize_item_images_local,
    _prepare_item_for_response,
    _score_match,
)
from app.core.exceptions import DatabaseError, ItemNotFoundError, ValidationError
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from tests.utils.fake_db import FakeBuilder, FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"


class _NotAwareBuilder(FakeBuilder):
    """FakeBuilder whose ``not_`` is a property (postgrest-py exposes ``.not_``
    as a property chaining into a negation builder)."""

    @property
    def not_(self):  # noqa: A003 - mirrors the real client attribute name
        return self._not


class _NotAwareDB(FakeDB):
    def table(self, name: str) -> _NotAwareBuilder:
        return _NotAwareBuilder(self, name)


class _MissingColumnError(RuntimeError):
    """PostgREST-style missing-column error (PGRST204)."""

    def __init__(self, message: str):
        super().__init__(message)
        self.code = "PGRST204"


class _FlakyQuery:
    """Chainable fake for the birth-profile fallback tests.

    The ``users`` combined select raises a missing-column error; per-column
    selects raise only for columns listed in ``missing`` and otherwise echo the
    seeded user row. Other tables return their seeded rows.
    """

    def __init__(self, db: "_FlakyDB", table: str):
        self._db = db
        self._table = table
        self._columns: Optional[str] = None
        self._single = False

    def select(self, columns: str = "*", **_kwargs) -> "_FlakyQuery":
        self._columns = columns
        return self

    def eq(self, *_a, **_k) -> "_FlakyQuery":
        return self

    def single(self) -> "_FlakyQuery":
        self._single = True
        return self

    def limit(self, _n: int) -> "_FlakyQuery":
        return self

    @property
    def not_(self) -> "_FlakyQuery":
        return self

    def in_(self, *_a, **_k) -> "_FlakyQuery":
        return self

    def execute(self):
        if self._table == "users":
            self._db.users_calls.append(self._columns)
            if self._columns == "birth_date, birth_time, birth_place":
                raise self._db.combined_error
            if self._columns in self._db.column_errors:
                raise self._db.column_errors[self._columns]
            if self._columns in self._db.missing_columns:
                raise _MissingColumnError(f"column users.{self._columns} does not exist")
            if self._db.users:
                return SimpleNamespace(data={self._columns: self._db.users.get(self._columns)})
            return SimpleNamespace(data=None)
        rows = self._db.other_tables.get(self._table, [])
        if self._single:
            return SimpleNamespace(data=rows[0] if rows else None)
        return SimpleNamespace(data=rows)


class _FlakyDB:
    """DB whose ``users`` birth selects can fail column-by-column."""

    def __init__(
        self,
        users: Optional[Dict[str, Any]] = None,
        missing_columns=(),
        combined_error: Optional[BaseException] = None,
        auth_admin: Any = None,
        other_tables: Optional[Dict[str, List[Dict[str, Any]]]] = None,
        column_errors: Optional[Dict[str, BaseException]] = None,
    ):
        self.users = users
        self.missing_columns = set(missing_columns)
        self.combined_error = combined_error or _MissingColumnError(
            "column users.birth_date does not exist"
        )
        self.column_errors = column_errors or {}
        self.auth = SimpleNamespace(admin=auth_admin)
        self.other_tables = other_tables or {}
        self.users_calls: List[Optional[str]] = []

    def table(self, name: str) -> _FlakyQuery:
        return _FlakyQuery(self, name)


class _RaisingTableDB:
    """FakeDB wrapper that makes one table's queries raise RuntimeError."""

    def __init__(self, inner: FakeDB, raise_on: str):
        self._inner = inner
        self._raise_on = raise_on

    def table(self, name: str):
        if name == self._raise_on:
            raise RuntimeError(f"{name} unavailable")
        return self._inner.table(name)


def _item(item_id: str, category: str = "tops", colors: Optional[List[str]] = None, **overrides) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": item_id,
        "user_id": USER_ID,
        "name": f"Item {item_id}",
        "category": category,
        "colors": colors or [],
        "item_images": [],
        "condition": "clean",
        "is_deleted": False,
        "is_favorite": False,
    }
    row.update(overrides)
    return row


def _fake_astrology_service(**recommendation):
    service = Mock()
    service.resolve_birth_timezone = AsyncMock(return_value="Asia/Kolkata")
    service.user_local_today = Mock(return_value=date(2026, 2, 6))
    service.generate_recommendation = AsyncMock(
        return_value=recommendation
        or {
            "astrology_mode": "vedic_lite",
            "lucky_colors": [],
            "avoid_colors": [],
            "wardrobe_picks": [],
            "suggested_outfits": [],
        }
    )
    return service


# ---------------------------------------------------------------------------
# Request models + error-handling decorator
# ---------------------------------------------------------------------------


def test_match_request_requires_item_ids():
    with pytest.raises(PydanticValidationError):
        MatchRequest(item_ids=None, item_id=None)


def test_complete_look_request_requires_seed():
    with pytest.raises(PydanticValidationError):
        CompleteLookRequest(start_item_id=None, item_ids=None)


@pytest.mark.asyncio
async def test_match_route_wraps_unexpected_errors_as_database_error():
    db = Mock()
    db.table.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError) as exc:
        await recs_module.match_items(
            MatchRequest(item_ids=["src-1"]),
            category=None,
            limit=10,
            min_score=0,
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "match_items"
    assert exc.value.message == "Failed to generate matches"


# ---------------------------------------------------------------------------
# POST /match
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_match_items_scores_and_builds_complete_looks():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-1", "bottoms", ["black"]),  # complementary + color match
                _item("cand-2", "shoes", ["white"]),  # complementary + neutral
                _item("cand-3", "tops", ["black"]),  # same category + color match
            ]
        }
    )

    result = await recs_module.match_items(
        MatchRequest(item_ids=["src-1"]),
        category=None,
        limit=10,
        min_score=0,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    scores = [m["score"] for m in result["data"]["matches"]]
    assert scores == [85, 75, 70], "matches must be sorted by score descending"
    assert result["data"]["matches"][0]["item"]["id"] == "cand-1"
    reasons = result["data"]["matches"][0]["reasons"]
    assert "Complements your tops" in reasons
    assert "Matches your colors" in reasons
    # A look that stacks tops + bottoms + shoes from the same candidate pool.
    looks = result["data"]["complete_looks"]
    assert looks and looks[0]["items"][0]["category"] == "tops"


@pytest.mark.asyncio
async def test_match_items_filters_candidates_by_category():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-1", "bottoms", ["black"]),
                _item("cand-3", "tops", ["black"]),
            ]
        }
    )

    result = await recs_module.match_items(
        MatchRequest(item_ids=["src-1"]),
        category="tops",
        limit=10,
        min_score=0,
        user_id=USER_ID,
        db=db,
    )

    ids = [m["item"]["id"] for m in result["data"]["matches"]]
    assert ids == ["cand-3"]


@pytest.mark.asyncio
async def test_match_items_respects_min_score():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-1", "bottoms", ["black"]),  # 85
                _item("cand-2", "shoes", ["white"]),  # 75
            ]
        }
    )

    result = await recs_module.match_items(
        MatchRequest(item_ids=["src-1"]),
        category=None,
        limit=10,
        min_score=80,
        user_id=USER_ID,
        db=db,
    )

    ids = [m["item"]["id"] for m in result["data"]["matches"]]
    assert ids == ["cand-1"]


@pytest.mark.asyncio
async def test_match_items_accepts_legacy_item_id_and_request_limit():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-1", "bottoms", ["black"]),
                _item("cand-2", "shoes", ["white"]),
                _item("cand-3", "tops", ["black"]),
            ]
        }
    )

    result = await recs_module.match_items(
        MatchRequest(item_id="src-1", limit=2),
        category=None,
        limit=10,
        min_score=0,
        user_id=USER_ID,
        db=db,
    )

    assert len(result["data"]["matches"]) == 2
    assert result["data"]["matches"][0]["item"]["id"] == "cand-1"


@pytest.mark.asyncio
async def test_match_items_raises_when_no_sources_found():
    db = _NotAwareDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await recs_module.match_items(
            MatchRequest(item_ids=["ghost"]),
            category=None,
            limit=10,
            min_score=0,
            user_id=USER_ID,
            db=db,
        )


# ---------------------------------------------------------------------------
# POST /complete-look
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_complete_look_requires_a_seed():
    db = _NotAwareDB(rows={"items": []})

    with pytest.raises(ValidationError) as exc:
        await recs_module.complete_look(
            CompleteLookRequest(item_ids=[""]),
            style=None,
            occasion=None,
            limit=5,
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["field"] == "item_ids or start_item_id"


@pytest.mark.asyncio
async def test_complete_look_raises_when_seed_item_missing():
    db = _NotAwareDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await recs_module.complete_look(
            CompleteLookRequest(start_item_id="ghost"),
            style=None,
            occasion=None,
            limit=5,
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_complete_look_returns_looks_with_occasion_and_style():
    """NOTE: documents current behaviour, not intent.

    The internal ``match_items(...)`` call passes no ``category``/``limit``/
    ``min_score``, so the FastAPI ``Query()`` default objects are used. A
    ``Query`` object is truthy, so ``if category:`` applies a bogus
    ``eq("category", ...)`` filter and every candidate is dropped. The
    endpoint therefore returns an empty ``complete_looks`` list even when the
    wardrobe holds matching items.
    """
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-1", "bottoms", ["black"]),
            ]
        }
    )

    result = await recs_module.complete_look(
        CompleteLookRequest(item_ids=["src-1"], occasion="date night"),
        style="minimal",
        occasion=None,
        limit=5,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["complete_looks"] == []


# ---------------------------------------------------------------------------
# GET /personalized
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_personalized_returns_favorites_and_least_worn():
    db = FakeDB(
        rows={
            "items": [
                _item("fav-1", "tops", is_favorite=True, usage_times_worn=3),
                _item("fav-2", "bottoms", is_favorite=True, usage_times_worn=1),
                _item("plain-1", "shoes", usage_times_worn=0),
            ]
        }
    )

    result = await recs_module.personalized(type="outfits", limit=10, user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert [i["item"]["id"] for i in result["data"]["items"]] == ["fav-1", "fav-2"]
    assert result["data"]["items"][0]["why_recommended"] == "Favorite item"
    assert {i["id"] for i in result["data"]["least_worn"]} == {"fav-1", "fav-2", "plain-1"}
    assert result["data"]["outfits"] == []


# ---------------------------------------------------------------------------
# GET /weather
# ---------------------------------------------------------------------------


def test_parse_coordinates_accepts_valid_and_rejects_bad_input():
    assert recs_module._parse_coordinates("40.7128, -74.0060") == (40.7128, -74.006)
    assert recs_module._parse_coordinates("  12.3 , 45.6 ") == (12.3, 45.6)
    assert recs_module._parse_coordinates("New York") is None
    assert recs_module._parse_coordinates("a,b,c") is None
    assert recs_module._parse_coordinates("91.0,0.0") is None
    assert recs_module._parse_coordinates("0.0,181.0") is None
    assert recs_module._parse_coordinates("abc,def") is None


@pytest.mark.asyncio
async def test_weather_uses_default_location_and_hot_rainy_rules(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(
        return_value={"temperature": 95.0, "weather_state": "rainy", "temp_category": "hot"}
    )
    service.get_weather_by_coordinates = AsyncMock(return_value={})
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)
    db = FakeDB(rows={"user_settings": [{"user_id": USER_ID, "default_location": "Pune"}]})

    result = await recs_module.weather_recommendations(location=None, user_id=USER_ID, db=db)

    service.get_weather.assert_awaited_once_with(location="Pune", units="imperial")
    data = result["data"]
    assert data["temperature"] == 35.0
    assert data["temp_category"] == "hot"
    assert "outerwear" in data["avoid_categories"]
    assert "accessories" in data["preferred_categories"]
    assert "sunglasses" in data["additional_items"]
    assert "umbrella" in data["additional_items"]
    assert "waterproof" in data["preferred_materials"]
    assert any("Rain expected" in note for note in data["notes"])


@pytest.mark.asyncio
async def test_weather_uses_coordinates_and_cold_rules(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(return_value={})
    service.get_weather_by_coordinates = AsyncMock(return_value={"temperature": 30.0})
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)

    result = await recs_module.weather_recommendations(
        location="40.7128,-74.0060", user_id=USER_ID, db=FakeDB()
    )

    service.get_weather_by_coordinates.assert_awaited_once_with(
        lat=40.7128, lon=-74.006, units="imperial"
    )
    data = result["data"]
    assert data["temperature"] == -1.1
    assert data["preferred_categories"][0] == "outerwear"
    assert data["suggested_layers"] == 3
    assert data["additional_items"] == ["coat", "scarf", "gloves"]
    assert data["color_suggestions"] == ["navy", "black", "burgundy"]


@pytest.mark.asyncio
async def test_weather_mild_branch_and_stormy_state(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(
        return_value={"temperature": 50.0, "condition": "stormy", "temp_category": "cool"}
    )
    service.get_weather_by_coordinates = AsyncMock(return_value={})
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)

    result = await recs_module.weather_recommendations(
        location="New York", user_id=USER_ID, db=FakeDB()
    )

    data = result["data"]
    assert data["temperature"] == 10.0
    assert data["suggested_layers"] == 2
    assert "light jacket" in data["additional_items"]
    assert "rain jacket" in data["additional_items"]
    assert data["preferred_materials"] == ["denim", "cotton", "knit", "waterproof"]


@pytest.mark.asyncio
async def test_weather_falls_back_to_new_york_when_settings_query_fails(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(return_value={})
    service.get_weather_by_coordinates = AsyncMock(return_value={})
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)
    db = _RaisingTableDB(FakeDB(), "user_settings")

    result = await recs_module.weather_recommendations(location=None, user_id=USER_ID, db=db)

    service.get_weather.assert_awaited_once_with(location="New York", units="imperial")
    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_weather_treats_unparseable_coordinates_as_city_name(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(return_value={"temperature": 70.0})
    service.get_weather_by_coordinates = AsyncMock(return_value={})
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)

    result = await recs_module.weather_recommendations(
        location="abc,def", user_id=USER_ID, db=FakeDB()
    )

    service.get_weather.assert_awaited_once_with(location="abc,def", units="imperial")
    assert result["data"]["temperature"] == 21.1


@pytest.mark.asyncio
async def test_weather_wraps_unexpected_errors(monkeypatch):
    service = Mock()
    service.get_weather = AsyncMock(side_effect=RuntimeError("provider down"))
    service.get_weather_by_coordinates = AsyncMock()
    monkeypatch.setattr(recs_module, "get_weather_service", lambda: service)
    db = FakeDB(rows={"user_settings": [{"user_id": USER_ID, "default_location": "Pune"}]})

    with pytest.raises(DatabaseError) as exc:
        await recs_module.weather_recommendations(location=None, user_id=USER_ID, db=db)

    assert exc.value.details["operation"] == "weather_recommendations"


# ---------------------------------------------------------------------------
# GET /astrology — branches the sibling file does not touch
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_astrology_rejects_unknown_mode():
    db = FakeDB(rows={"users": [], "user_settings": [], "items": []})

    with pytest.raises(ValidationError) as exc:
        await recs_module.astrology_recommendations(
            target_date=date(2026, 2, 6),
            mode="weekly",
            limit_per_category=4,
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["allowed"] == ["daily", "important_meeting"]


@pytest.mark.asyncio
async def test_astrology_ready_path_resolves_timezone_from_birth_place(monkeypatch):
    service = _fake_astrology_service(
        astrology_mode="vedic_lite",
        lucky_colors=[{"name": "navy", "hex": "#000080", "reason": "ruling planet"}],
        avoid_colors=[],
        wardrobe_picks=[],
        suggested_outfits=[],
    )
    monkeypatch.setattr(recs_module, "get_astrology_service", lambda: service)
    db = FakeDB(
        rows={
            "users": [
                {
                    "id": USER_ID,
                    "birth_date": "1995-01-14",
                    "birth_time": "12:34:56",
                    "birth_place": "New Delhi",
                }
            ],
            "user_settings": [{"user_id": USER_ID, "timezone": None}],
            "items": [_item("tops-1", "tops", ["navy"])],
        }
    )

    result = await recs_module.astrology_recommendations(
        target_date=None,
        mode="daily",
        limit_per_category=4,
        user_id=USER_ID,
        db=db,
    )

    service.resolve_birth_timezone.assert_awaited_once_with("New Delhi")
    service.user_local_today.assert_called_once_with("Asia/Kolkata")
    service.generate_recommendation.assert_awaited_once()
    kwargs = service.generate_recommendation.await_args.kwargs
    assert kwargs["birth_date"] == date(1995, 1, 14)
    assert kwargs["birth_time"] == dt_time(12, 34, 56)
    assert kwargs["birth_place"] == "New Delhi"
    assert kwargs["user_timezone"] == "Asia/Kolkata"
    assert kwargs["limit_per_category"] == 4
    data = result["data"]
    assert data["status"] == "ready"
    assert data["lucky_colors"][0]["name"] == "navy"


@pytest.mark.asyncio
async def test_astrology_survives_settings_query_failure(monkeypatch):
    service = _fake_astrology_service()
    monkeypatch.setattr(recs_module, "get_astrology_service", lambda: service)
    db = _RaisingTableDB(
        FakeDB(
            rows={
                "users": [
                    {
                        "id": USER_ID,
                        "birth_date": "1995-01-14",
                        "birth_time": "12:34:56",
                        "birth_place": "New Delhi",
                    }
                ],
                "items": [],
            }
        ),
        "user_settings",
    )

    result = await recs_module.astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["status"] == "ready"
    assert service.generate_recommendation.await_args.kwargs["user_timezone"] == "Asia/Kolkata"


@pytest.mark.asyncio
async def test_astrology_continues_when_items_query_fails(monkeypatch):
    service = _fake_astrology_service()
    monkeypatch.setattr(recs_module, "get_astrology_service", lambda: service)
    db = _RaisingTableDB(
        FakeDB(
            rows={
                "users": [
                    {
                        "id": USER_ID,
                        "birth_date": "1995-01-14",
                        "birth_time": "12:34:56",
                        "birth_place": "New Delhi",
                    }
                ],
                "user_settings": [{"user_id": USER_ID, "timezone": "UTC"}],
            }
        ),
        "items",
    )

    result = await recs_module.astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["status"] == "ready"
    assert service.generate_recommendation.await_args.kwargs["items"] == []


@pytest.mark.asyncio
async def test_astrology_uses_auth_metadata_fallback_for_missing_columns(monkeypatch):
    """When the users table lacks the astrology columns, the route fills the
    profile from auth metadata; a birth_date found there unlocks the ready
    path even though birth_time/birth_place stay null."""
    auth_user = SimpleNamespace(
        user=SimpleNamespace(user_metadata={"birth_date": "1990-06-15", "birth_place": "Mumbai"})
    )
    admin = Mock()
    admin.get_user_by_id = Mock(return_value=auth_user)
    service = _fake_astrology_service()
    monkeypatch.setattr(recs_module, "get_astrology_service", lambda: service)
    db = _FlakyDB(
        users={"birth_date": None, "birth_time": None, "birth_place": None},
        missing_columns=("birth_date", "birth_time", "birth_place"),
        auth_admin=admin,
        other_tables={
            "user_settings": [{"user_id": USER_ID, "timezone": "UTC"}],
            "items": [
                {
                    "id": "tops-1",
                    "name": "Navy tee",
                    "category": "tops",
                    "colors": ["navy"],
                    "item_images": [],
                    "is_deleted": False,
                }
            ],
        },
    )

    result = await recs_module.astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id=USER_ID,
        db=db,
    )

    assert db.users_calls == ["birth_date, birth_time, birth_place", "birth_date", "birth_time", "birth_place"]
    assert result["data"]["status"] == "ready"
    assert service.generate_recommendation.await_args.kwargs["birth_date"] == date(1990, 6, 15)
    assert service.generate_recommendation.await_args.kwargs["items"][0]["id"] == "tops-1"


@pytest.mark.asyncio
async def test_astrology_profile_required_notes_missing_migration():
    """No auth metadata either: profile_required with the migration hint."""
    db = _FlakyDB(
        users={"birth_date": None, "birth_time": None, "birth_place": None},
        missing_columns=("birth_date", "birth_time", "birth_place"),
        auth_admin=None,
        other_tables={"user_settings": [{"user_id": USER_ID, "timezone": "UTC"}], "items": []},
    )

    result = await recs_module.astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id=USER_ID,
        db=db,
    )

    data = result["data"]
    assert data["status"] == "profile_required"
    assert data["missing_fields"] == ["birth_date"]
    assert data["context"]["weekday"] == "Friday"
    assert data["context"]["ruling_planet"] == "Venus"
    assert any("Run migration 002_astrology_profile.sql" in note for note in data["notes"])


# ---------------------------------------------------------------------------
# Birth-profile helpers (schema-migration fallbacks)
# ---------------------------------------------------------------------------


def test_get_user_birth_profile_happy_path_reads_all_three_columns():
    db = FakeDB(
        rows={
            "users": [
                {"id": USER_ID, "birth_date": "1995-01-14", "birth_time": "12:34:56", "birth_place": "Delhi"}
            ]
        }
    )

    profile, missing = _get_user_birth_profile(db, USER_ID)

    assert missing is False
    assert profile == {"birth_date": "1995-01-14", "birth_time": "12:34:56", "birth_place": "Delhi"}


def test_get_user_birth_profile_re_raises_unrelated_errors():
    db = _FlakyDB(
        users={"birth_date": "1995-01-14"},
        combined_error=RuntimeError("connection reset"),
    )

    with pytest.raises(RuntimeError):
        _get_user_birth_profile(db, USER_ID)


def test_get_user_birth_profile_falls_back_to_per_column_selects():
    db = _FlakyDB(
        users={"birth_date": "1995-01-14", "birth_time": "12:34:56", "birth_place": "Delhi"},
        missing_columns=("birth_time", "birth_place"),
    )

    profile, missing = _get_user_birth_profile(db, USER_ID)

    assert missing is True
    assert profile == {"birth_date": "1995-01-14"}


def test_get_user_birth_profile_empty_users_returns_empty_profile():
    """A successful combined select with no row falls through to the
    per-column loop, which also finds nothing."""
    db = FakeDB(rows={"users": []})

    profile, missing = _get_user_birth_profile(db, USER_ID)

    assert profile == {}
    assert missing is False


def test_get_user_birth_profile_re_raises_unexpected_per_column_errors():
    """A per-column select failing with a non-migration error must propagate,
    not be treated as a missing column."""
    db = _FlakyDB(
        users={"birth_date": "1995-01-14"},
        column_errors={"birth_time": RuntimeError("connection reset")},
    )

    with pytest.raises(RuntimeError):
        _get_user_birth_profile(db, USER_ID)


def test_get_auth_birth_profile_returns_empty_without_admin_api():
    assert _get_auth_birth_profile(SimpleNamespace(auth=SimpleNamespace(admin=None)), USER_ID) == {}


def test_get_auth_birth_profile_returns_empty_without_get_user_by_id():
    admin = Mock(spec=[])
    db = SimpleNamespace(auth=SimpleNamespace(admin=admin))
    assert _get_auth_birth_profile(db, USER_ID) == {}


def test_get_auth_birth_profile_returns_empty_when_user_missing():
    admin = Mock()
    admin.get_user_by_id = Mock(return_value=None)
    db = SimpleNamespace(auth=SimpleNamespace(admin=admin))
    assert _get_auth_birth_profile(db, USER_ID) == {}


def test_get_auth_birth_profile_reads_user_metadata():
    auth_user = SimpleNamespace(
        user=SimpleNamespace(user_metadata={"birth_date": "1990-06-15", "birth_time": "08:00:00", "birth_place": "Mumbai"})
    )
    admin = Mock()
    admin.get_user_by_id = Mock(return_value=auth_user)
    db = SimpleNamespace(auth=SimpleNamespace(admin=admin))

    assert _get_auth_birth_profile(db, USER_ID) == {
        "birth_date": "1990-06-15",
        "birth_time": "08:00:00",
        "birth_place": "Mumbai",
    }


def test_get_auth_birth_profile_swallows_admin_errors():
    admin = Mock()
    admin.get_user_by_id = Mock(side_effect=RuntimeError("auth down"))
    db = SimpleNamespace(auth=SimpleNamespace(admin=admin))

    assert _get_auth_birth_profile(db, USER_ID) == {}


def test_extract_missing_users_column_recognizes_42703_and_pgrst_codes():
    err = RuntimeError("column users.birth_time does not exist")
    err.code = "42703"
    assert _extract_missing_users_column(err) == "birth_time"

    err2 = RuntimeError("could not find the 'birth_place' column of 'users'")
    err2.code = "PGRST204"
    assert _extract_missing_users_column(err2) == "birth_place"

    err3 = RuntimeError("no rows")
    err3.code = "PGRST205"
    assert _extract_missing_users_column(err3) == "__table__"

    err4 = RuntimeError("SQLSTATE 42703: column users.birth_date does not exist")
    assert _extract_missing_users_column(err4) == "birth_date"


def test_extract_missing_users_column_ignores_unrelated_errors():
    err = RuntimeError("relation users does not exist")
    err.code = "42P01"
    assert _extract_missing_users_column(err) is None

    err2 = RuntimeError("column users.birth_date does not exist")
    err2.code = "23505"
    assert _extract_missing_users_column(err2) is None


def test_extract_missing_users_column_pgrst204_without_column_match_is_none():
    err = RuntimeError("no rows")
    err.code = "PGRST204"
    assert _extract_missing_users_column(err) is None


# ---------------------------------------------------------------------------
# GET /similar
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_similar_items_raises_when_source_missing():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await recs_module.similar_items(
            item_id="ghost", category=None, limit=10, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_similar_items_uses_vector_search_results():
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),
                _item("cand-b", "bottoms", ["black"]),
            ]
        }
    )
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(
        return_value=[
            {"item_id": "cand-a", "score": 0.9},
            {"item_id": "ghost", "score": 0.8},  # no matching DB row -> dropped
        ]
    )
    reserve_mock = AsyncMock(return_value=True)
    release_mock = AsyncMock()
    embed_mock = AsyncMock(return_value=[0.1, 0.2])
    with (
        patch.object(AISettingsService, "reserve_usage", new=reserve_mock),
        patch.object(AISettingsService, "release_usage", new=release_mock),
        patch.object(AIService, "generate_item_embedding", new=embed_mock),
        patch.object(recs_module, "get_vector_service", return_value=vector_service),
    ):
        result = await recs_module.similar_items(
            item_id="src-1", category=None, limit=10, user_id=USER_ID, db=db
        )

    reserve_mock.assert_awaited_once_with(user_id=USER_ID, operation_type="embedding", db=db)
    vector_service.find_similar.assert_awaited_once_with(
        embedding=[0.1, 0.2],
        user_id=USER_ID,
        category=None,
        exclude_item_ids=["src-1"],
        top_k=10,
        min_score=0.2,
    )
    assert len(result["data"]) == 1
    assert result["data"][0]["item_id"] == "cand-a"
    assert result["data"][0]["similarity"] == 90.0
    # A successful vector result must NOT release the reserved slot.
    release_mock.assert_not_awaited()


@pytest.mark.asyncio
async def test_similar_items_falls_back_when_rate_limited():
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),  # same category + color
                _item("cand-b", "bottoms", ["black"]),  # different category, color only
                _item("cand-c", "tops"),  # same category, no colors
            ]
        }
    )

    reserve_mock = AsyncMock(return_value=False)
    embed_mock = AsyncMock()
    with (
        patch.object(AISettingsService, "reserve_usage", new=reserve_mock),
        patch.object(AIService, "generate_item_embedding", new=embed_mock),
    ):
        result = await recs_module.similar_items(
            item_id="src-1", category=None, limit=10, user_id=USER_ID, db=db
        )

    ids = [r["item_id"] for r in result["data"]]
    assert ids == ["cand-a", "cand-b", "cand-c"]  # 0.8, then 0.4 + 0.4 stable
    assert result["data"][0]["similarity"] == 80  # 0.4 category + 0.4 color
    embed_mock.assert_not_awaited()


@pytest.mark.asyncio
async def test_similar_items_releases_reservation_and_falls_back_on_vector_error():
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),
            ]
        }
    )
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(side_effect=RuntimeError("pinecone down"))
    reserve_mock = AsyncMock(return_value=True)
    release_mock = AsyncMock()
    embed_mock = AsyncMock(return_value=[0.1])

    with (
        patch.object(AISettingsService, "reserve_usage", new=reserve_mock),
        patch.object(AISettingsService, "release_usage", new=release_mock),
        patch.object(AIService, "generate_item_embedding", new=embed_mock),
        patch.object(recs_module, "get_vector_service", return_value=vector_service),
    ):
        result = await recs_module.similar_items(
            item_id="src-1", category=None, limit=10, user_id=USER_ID, db=db
        )

    release_mock.assert_awaited_once()
    assert len(result["data"]) == 1  # rule-based fallback still answers


@pytest.mark.asyncio
async def test_similar_items_logs_release_failure_when_embedding_missing(caplog):
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),
            ]
        }
    )

    with (
        patch.object(AISettingsService, "reserve_usage", new=AsyncMock(return_value=True)),
        patch.object(AISettingsService, "release_usage", new=AsyncMock(side_effect=RuntimeError("rpc down"))),
        patch.object(AIService, "generate_item_embedding", new=AsyncMock(return_value=None)),
    ):
        result = await recs_module.similar_items(
            item_id="src-1", category=None, limit=10, user_id=USER_ID, db=db
        )

    assert result["message"] == "OK"
    assert any(
        "Failed to release embedding reservation" in record.message for record in caplog.records
    )


@pytest.mark.asyncio
async def test_similar_items_releases_reservation_when_no_match_ids():
    """A vector match list without item_ids yields no results, so the reserved
    embedding slot must be returned before the fallback runs."""
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),
            ]
        }
    )
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(return_value=[{"score": 0.9}])
    reserve_mock = AsyncMock(return_value=True)
    release_mock = AsyncMock()
    embed_mock = AsyncMock(return_value=[0.1])

    with (
        patch.object(AISettingsService, "reserve_usage", new=reserve_mock),
        patch.object(AISettingsService, "release_usage", new=release_mock),
        patch.object(AIService, "generate_item_embedding", new=embed_mock),
        patch.object(recs_module, "get_vector_service", return_value=vector_service),
    ):
        result = await recs_module.similar_items(
            item_id="src-1", category=None, limit=10, user_id=USER_ID, db=db
        )

    release_mock.assert_awaited_once()
    assert [r["item_id"] for r in result["data"]] == ["cand-a"]  # fallback answer


@pytest.mark.asyncio
async def test_similar_items_fallback_respects_category_filter():
    db = FakeDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"]),
                _item("cand-a", "tops", ["black"]),
                _item("cand-b", "bottoms", ["black"]),  # wrong category -> skipped
            ]
        }
    )

    with patch.object(AISettingsService, "reserve_usage", new=AsyncMock(return_value=False)):
        result = await recs_module.similar_items(
            item_id="src-1", category="tops", limit=10, user_id=USER_ID, db=db
        )

    assert [r["item_id"] for r in result["data"]] == ["cand-a"]


# ---------------------------------------------------------------------------
# GET /style/{item_id}
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_style_analysis_returns_style_occasions_and_companions():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", ["black"], style="business", tags=["workout"]),
                _item("cand-1", "bottoms", ["black"], style="business"),
            ]
        }
    )

    result = await recs_module.style_analysis(item_id="src-1", user_id=USER_ID, db=db)

    data = result["data"]
    assert data["style"] == "business"
    assert data["suggested_occasions"] == ["work", "formal", "workout"]
    assert data["color_palette"] == ["black"]
    # The internal match call hits the Query-default bug (see complete-look
    # test): no candidates survive, so companions come back empty.
    assert data["suggested_companions"] == []


@pytest.mark.asyncio
async def test_style_analysis_derives_style_from_tags():
    db = _NotAwareDB(
        rows={
            "items": [
                _item("src-1", "tops", tags=["sporty"]),
                _item("cand-1", "bottoms", tags=["sporty"]),
            ]
        }
    )

    result = await recs_module.style_analysis(item_id="src-1", user_id=USER_ID, db=db)

    data = result["data"]
    assert data["style"] == "sporty"
    assert data["suggested_occasions"] == ["casual"]
    assert {"casual", "business", "formal"} <= {s["style"] for s in data["alternative_styles"]}
    assert data["confidence"] == 0.7


@pytest.mark.asyncio
async def test_style_analysis_raises_when_item_missing():
    db = _NotAwareDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await recs_module.style_analysis(item_id="ghost", user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Wardrobe gaps / shopping / capsule / rating routes
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_wardrobe_gaps_route_returns_analysis():
    db = FakeDB(
        rows={"items": [{"id": "i1", "category": "tops", "user_id": USER_ID, "is_deleted": False}]}
    )

    result = await recs_module.wardrobe_gaps(user_id=USER_ID, db=db)

    analysis = result["data"]["analysis"]
    assert analysis["category_breakdown"][0]["category"] == "tops"
    # A single top is still under the ideal of 8, so every category is missing.
    assert analysis["wardrobe_completeness_score"] == 40
    assert {m["category"] for m in analysis["missing_essentials"]} == {
        "tops",
        "bottoms",
        "shoes",
        "outerwear",
        "accessories",
    }


@pytest.mark.asyncio
async def test_shopping_recommendations_filters_by_category():
    db = FakeDB(rows={"items": []})

    result = await recs_module.shopping_recommendations(
        category="shoes", budget=None, style=None, user_id=USER_ID, db=db
    )

    assert [m["category"] for m in result["data"]] == ["shoes"]

    all_result = await recs_module.shopping_recommendations(
        category=None, budget=None, style=None, user_id=USER_ID, db=db
    )
    assert len(all_result["data"]) == 5


@pytest.mark.asyncio
async def test_capsule_wardrobe_builds_items_and_statistics():
    db = FakeDB(
        rows={
            "items": [
                _item("c-1", "tops", ["white"]),
                _item("c-2", "bottoms", ["navy"]),
            ]
        }
    )

    result = await recs_module.capsule_wardrobe(
        season="Winter", style=None, item_count=20, user_id=USER_ID, db=db
    )

    data = result["data"]
    assert data["name"] == "Winter capsule"
    assert len(data["items"]) == 2
    assert data["items"][0]["item_id"] == "c-1"
    assert data["statistics"]["total_outfits_possible"] == 10


@pytest.mark.asyncio
async def test_rate_recommendation_stores_rating():
    db = FakeDB(rows={})

    result = await recs_module.rate_recommendation(
        recommendation_id="9f8c1a2b-0000-4000-8000-000000000001",
        request=RateRecommendationRequest(rating="thumbs_up"),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"] == {"saved": True}
    assert result["message"] == "OK"
    assert db.ops_on("recommendation_logs")[0][0] == "insert"
    payload = db.ops_on("recommendation_logs")[0][1]
    assert payload["user_id"] == USER_ID
    assert payload["feedback"] == {"rating": "thumbs_up"}


# ---------------------------------------------------------------------------
# Pure helpers: coercion, scoring, normalization
# ---------------------------------------------------------------------------


def test_coerce_date_handles_all_input_shapes():
    assert _coerce_date(None) is None
    assert _coerce_date(datetime(2026, 1, 1, 12, 0)) == date(2026, 1, 1)
    assert _coerce_date(date(2026, 1, 1)) == date(2026, 1, 1)
    assert _coerce_date("2026-01-01") == date(2026, 1, 1)
    assert _coerce_date("2026-01-01T10:00:00+00:00") == date(2026, 1, 1)
    assert _coerce_date("   ") is None
    assert _coerce_date("not-a-date") is None


def test_coerce_time_handles_all_input_shapes():
    assert _coerce_time(None) is None
    assert _coerce_time(datetime(2026, 1, 1, 12, 34, 56)) == dt_time(12, 34, 56)
    assert _coerce_time(dt_time(7, 8, 9)) == dt_time(7, 8, 9)
    assert _coerce_time("12:34") == dt_time(12, 34)
    assert _coerce_time("12:34:56Z") == dt_time(12, 34, 56)
    assert _coerce_time("12:34:56-05:00") == dt_time(12, 34, 56)
    # Double offset: fromisoformat rejects it, the "+" strip recovers the time.
    assert _coerce_time("12:34:56+05:30Z") == dt_time(12, 34, 56)
    # Invalid calendar day with a valid time part: the "T" split recovers it.
    assert _coerce_time("2026-02-30T12:34:56") == dt_time(12, 34, 56)
    assert _coerce_time("   ") is None
    assert _coerce_time("25:99") is None
    assert _coerce_time("oops") is None


def test_score_match_awards_bonuses():
    source = {"category": "tops", "colors": ["black"]}

    complementary = {"category": "bottoms", "colors": ["navy"]}
    score, reasons = _score_match(source, complementary)
    assert score == 0.75  # 0.5 + 0.15 complementary + 0.1 neutral coordinate
    assert "complements your tops" in reasons
    assert "coordinates with neutrals" in reasons


def test_score_match_same_colors_and_no_colors():
    source = {"category": "tops", "colors": ["black"]}

    same = {"category": "tops", "colors": ["black"]}
    score, reasons = _score_match(source, same)
    assert score == 0.7  # 0.5 + 0.2 color match
    assert "matches your colors" in reasons

    colorless = {"category": "tops", "colors": []}
    score, reasons = _score_match(source, colorless)
    assert score == 0.5
    assert reasons == []


def test_score_match_no_color_overlap_and_no_neutral():
    source = {"category": "tops", "colors": ["red"]}

    score, reasons = _score_match(source, {"category": "tops", "colors": ["blue"]})

    assert score == 0.5
    assert reasons == []


def test_normalize_and_prepare_helpers_pass_non_dicts_through():
    assert _normalize_item_images_local("not-a-dict") == "not-a-dict"
    assert _prepare_item_for_response(None) is None


def test_prepare_item_sets_image_url_when_primary_has_thumbnail():
    raw = {
        "id": "i-1",
        "name": "Tee",
        "category": "tops",
        "item_images": [
            {"image_url": "https://cdn/full.jpg", "thumbnail_url": "https://cdn/thumb.jpg", "is_primary": True}
        ],
    }
    out = _prepare_item_for_response(raw)
    assert out["image_url"] == "https://cdn/thumb.jpg"
    assert out["images"][0]["image_url"] == "https://cdn/full.jpg"
