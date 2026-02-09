from datetime import date
from types import SimpleNamespace
from typing import Any, Dict, List
import sys
import types

import pytest

if "pinecone" not in sys.modules:
    pinecone_stub = types.ModuleType("pinecone")
    pinecone_stub.Pinecone = object
    pinecone_stub.ServerlessSpec = object
    sys.modules["pinecone"] = pinecone_stub

from app.api.v1.recommendations import astrology_recommendations


class _FakeNotQuery:
    def __init__(self, query: "_FakeQuery"):
        self._query = query

    def in_(self, field: str, values: List[Any]) -> "_FakeQuery":
        self._query._filters.append(("not_in", field, list(values)))
        return self._query


class _FakeQuery:
    def __init__(self, rows: List[Dict[str, Any]]):
        self._rows = [dict(row) for row in rows]
        self._filters: List[Any] = []
        self._single = False
        self._limit: int | None = None
        self.not_ = _FakeNotQuery(self)

    def select(self, *_args, **_kwargs) -> "_FakeQuery":
        return self

    def eq(self, field: str, value: Any) -> "_FakeQuery":
        self._filters.append(("eq", field, value))
        return self

    def in_(self, field: str, values: List[Any]) -> "_FakeQuery":
        self._filters.append(("in", field, list(values)))
        return self

    def single(self) -> "_FakeQuery":
        self._single = True
        return self

    def limit(self, value: int) -> "_FakeQuery":
        self._limit = value
        return self

    def execute(self):
        rows = list(self._rows)
        for filter_type, field, value in self._filters:
            if filter_type == "eq":
                rows = [row for row in rows if row.get(field) == value]
            elif filter_type == "in":
                allowed = set(value)
                rows = [row for row in rows if row.get(field) in allowed]
            elif filter_type == "not_in":
                denied = set(value)
                rows = [row for row in rows if row.get(field) not in denied]

        if self._limit is not None:
            rows = rows[: self._limit]

        if self._single:
            return SimpleNamespace(data=rows[0] if rows else None)
        return SimpleNamespace(data=rows)


class _FakeDB:
    def __init__(self, tables: Dict[str, List[Dict[str, Any]]]):
        self._tables = tables

    def table(self, name: str) -> _FakeQuery:
        return _FakeQuery(self._tables.get(name, []))


@pytest.mark.asyncio
async def test_astrology_endpoint_returns_profile_required_when_dob_missing():
    db = _FakeDB(
        {
            "users": [
                {
                    "id": "user-1",
                    "birth_date": None,
                    "birth_time": None,
                    "birth_place": None,
                }
            ],
            "user_settings": [{"user_id": "user-1", "timezone": "America/New_York"}],
            "items": [],
        }
    )

    response = await astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id="user-1",
        db=db,
    )

    data = response["data"]
    assert data["status"] == "profile_required"
    assert data["missing_fields"] == ["birth_date"]
    assert data["target_date"] == "2026-02-06"


@pytest.mark.asyncio
async def test_astrology_endpoint_returns_ready_and_excludes_unusable_items():
    db = _FakeDB(
        {
            "users": [
                {
                    "id": "user-1",
                    "birth_date": "1995-01-14",
                    "birth_time": None,
                    "birth_place": "New Delhi",
                }
            ],
            "user_settings": [{"user_id": "user-1", "timezone": "America/New_York"}],
            "items": [
                {
                    "id": "tops-1",
                    "user_id": "user-1",
                    "name": "Navy Shirt",
                    "category": "tops",
                    "condition": "clean",
                    "is_deleted": False,
                    "colors": ["navy"],
                    "item_images": [],
                },
                {
                    "id": "bottoms-laundry",
                    "user_id": "user-1",
                    "name": "Laundry Trouser",
                    "category": "bottoms",
                    "condition": "laundry",
                    "is_deleted": False,
                    "colors": ["white"],
                    "item_images": [],
                },
            ],
        }
    )

    response = await astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="important_meeting",
        limit_per_category=4,
        user_id="user-1",
        db=db,
    )

    data = response["data"]
    assert data["status"] == "ready"
    assert data["mode"] == "important_meeting"
    assert data["astrology_mode"] == "vedic_lite"
    assert len(data["lucky_colors"]) > 0

    picked_ids = {
        item["id"]
        for group in data["wardrobe_picks"]
        for item in group["items"]
    }
    assert "tops-1" in picked_ids
    assert "bottoms-laundry" not in picked_ids


@pytest.mark.asyncio
async def test_astrology_endpoint_meeting_mode_changes_color_weighting():
    db = _FakeDB(
        {
            "users": [
                {
                    "id": "user-1",
                    "birth_date": "1995-01-14",
                    "birth_time": None,
                    "birth_place": None,
                }
            ],
            "user_settings": [{"user_id": "user-1", "timezone": "America/New_York"}],
            "items": [],
        }
    )

    daily = await astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="daily",
        limit_per_category=4,
        user_id="user-1",
        db=db,
    )
    meeting = await astrology_recommendations(
        target_date=date(2026, 2, 6),
        mode="important_meeting",
        limit_per_category=4,
        user_id="user-1",
        db=db,
    )

    daily_lucky = [c["name"] for c in daily["data"]["lucky_colors"]]
    meeting_lucky = [c["name"] for c in meeting["data"]["lucky_colors"]]
    assert daily_lucky != meeting_lucky
