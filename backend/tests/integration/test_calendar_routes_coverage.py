"""Route-level coverage for app/api/v1/calendar.py.

Covers every handler: root probe, connect (create/update/error paths),
connections list, disconnect, date-range event fetches with has_more and
date-normalization, event CRUD, and outfit assignment/removal.

Follows the house convention: call route functions directly with a fake
Supabase client (bypasses auth), pass ``user_email`` explicitly where the
handler depends on it, and assert the ``result["data"]`` envelope.
"""
from types import SimpleNamespace
from typing import Any, Dict, List
from unittest.mock import Mock

import pytest

from app.api.v1 import calendar as calendar_module
from app.api.v1.calendar import (
    AssignOutfitRequest,
    CalendarConnectRequest,
    CreateEventRequest,
    UpdateEventRequest,
    _parse_date_only,
)
from app.core.exceptions import (
    CalendarEventNotFoundError,
    DatabaseError,
    NotFoundError,
    ValidationError,
)
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"


class _NoRowDB:
    """Minimal DB fake returning canned results per executed query.

    ``results`` is consumed in order: the first ``execute()`` answers the
    existence check, the second answers the write. Used to force the
    "write returned no row" branches that FakeDB can never produce.
    """

    def __init__(self, results: List[Any]):
        self._results = list(results)
        self._op = "select"

    def table(self, _name: str) -> "_NoRowDB":
        return self

    def select(self, *_a, **_k) -> "_NoRowDB":
        self._op = "select"
        return self

    def eq(self, *_a, **_k) -> "_NoRowDB":
        return self

    def maybe_single(self) -> "_NoRowDB":
        return self

    def single(self) -> "_NoRowDB":
        return self

    def insert(self, _payload) -> "_NoRowDB":
        self._op = "insert"
        return self

    def update(self, _payload) -> "_NoRowDB":
        self._op = "update"
        return self

    def delete(self) -> "_NoRowDB":
        self._op = "delete"
        return self

    def execute(self):
        if not self._results:
            raise AssertionError("more queries than canned results")
        return self._results.pop(0)


def _connection(connection_id: str, provider: str = "google", **overrides) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": connection_id,
        "user_id": USER_ID,
        "provider": provider,
        "email": "wardrobe@example.com",
        "connected_at": "2026-01-01T00:00:00+00:00",
        "created_at": "2026-01-01T00:00:00+00:00",
        "is_active": True,
    }
    row.update(overrides)
    return row


def _event(event_id: str, start_time: str = "2026-01-03T10:00:00", **overrides) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": event_id,
        "user_id": USER_ID,
        "calendar_id": None,
        "title": "Date night",
        "description": None,
        "start_time": start_time,
        "end_time": "2026-01-03T12:00:00",
        "location": None,
        "is_all_day": False,
        "outfit_id": None,
        "event_type": "other",
    }
    row.update(overrides)
    return row


# ---------------------------------------------------------------------------
# Root probe + connect
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_calendar_root_lists_endpoints():
    result = await calendar_module.calendar_root()

    assert result["service"] == "calendar"
    assert result["endpoints"] == ["/connect", "/connections", "/events"]


@pytest.mark.asyncio
async def test_connect_creates_a_new_connection():
    db = FakeDB(rows={"calendar_connections": []})

    result = await calendar_module.connect_calendar(
        CalendarConnectRequest(provider="Google", auth_code="abc123"),
        user_id=USER_ID,
        user_email="wardrobe@example.com",
        db=db,
    )

    assert result["message"] == "Connected"
    assert result["data"]["provider"] == "google"
    assert result["data"]["email"] == "wardrobe@example.com"
    assert result["data"]["id"]
    ops = db.ops_on("calendar_connections")
    assert [op for op, _ in ops] == ["insert"]
    payload = ops[0][1]
    assert payload["user_id"] == USER_ID
    assert payload["auth_code"] == "abc123"
    assert payload["is_active"] is True


@pytest.mark.asyncio
async def test_connect_updates_an_existing_connection():
    db = FakeDB(rows={"calendar_connections": [_connection("conn-1")]})

    result = await calendar_module.connect_calendar(
        CalendarConnectRequest(provider="google", auth_code="new-code"),
        user_id=USER_ID,
        user_email="new@example.com",
        db=db,
    )

    assert result["data"]["id"] == "conn-1"
    ops = db.ops_on("calendar_connections")
    assert [op for op, _ in ops] == ["update"]
    payload = ops[0][1]
    assert payload["email"] == "new@example.com"
    assert payload["auth_code"] == "new-code"
    assert payload["is_active"] is True


@pytest.mark.asyncio
async def test_connect_rejects_an_unknown_provider():
    with pytest.raises(ValidationError) as exc:
        await calendar_module.connect_calendar(
            CalendarConnectRequest(provider="yahoo"),
            user_id=USER_ID,
            user_email=None,
            db=FakeDB(),
        )

    assert exc.value.details["allowed"] == ["google", "apple", "outlook", "local"]


@pytest.mark.asyncio
async def test_connect_raises_when_the_write_returns_no_row():
    db = _NoRowDB(results=[None, SimpleNamespace(data=None)])

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.connect_calendar(
            CalendarConnectRequest(provider="local"),
            user_id=USER_ID,
            user_email=None,
            db=db,
        )

    assert exc.value.details["operation"] == "calendar_connection_upsert"


@pytest.mark.asyncio
async def test_connect_wraps_unexpected_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.connect_calendar(
            CalendarConnectRequest(provider="google"),
            user_id=USER_ID,
            user_email=None,
            db=db,
        )

    assert exc.value.details["operation"] == "calendar_connection"


# ---------------------------------------------------------------------------
# Connections list + disconnect
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_list_connections_returns_every_connection():
    db = FakeDB(
        rows={
            "calendar_connections": [
                _connection("conn-1", "google"),
                _connection("conn-2", "outlook"),
            ]
        }
    )

    result = await calendar_module.list_calendar_connections(user_id=USER_ID, db=db)

    providers = [c["provider"] for c in result["data"]["connections"]]
    assert providers == ["google", "outlook"]
    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_list_connections_returns_empty_list():
    db = FakeDB(rows={"calendar_connections": []})

    result = await calendar_module.list_calendar_connections(user_id=USER_ID, db=db)

    assert result["data"]["connections"] == []


@pytest.mark.asyncio
async def test_list_connections_falls_back_to_created_at():
    db = FakeDB(
        rows={
            "calendar_connections": [
                _connection("conn-1", "google", connected_at=None)
            ]
        }
    )

    result = await calendar_module.list_calendar_connections(user_id=USER_ID, db=db)

    connection = result["data"]["connections"][0]
    assert connection["connected_at"] == "2026-01-01T00:00:00+00:00"  # created_at


@pytest.mark.asyncio
async def test_list_connections_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.list_calendar_connections(user_id=USER_ID, db=db)

    assert exc.value.details["operation"] == "list_calendar_connections"


@pytest.mark.asyncio
async def test_disconnect_soft_disables_the_connection():
    db = FakeDB(rows={"calendar_connections": [_connection("conn-1")]})

    result = await calendar_module.disconnect_calendar("conn-1", user_id=USER_ID, db=db)

    assert result["data"] == {"id": "conn-1", "is_active": False, "updated_at": result["data"]["updated_at"]}
    assert result["message"] == "OK"
    payload = db.ops_on("calendar_connections")[0][1]
    assert payload["is_active"] is False


@pytest.mark.asyncio
async def test_disconnect_raises_not_found():
    db = FakeDB(rows={"calendar_connections": []})

    with pytest.raises(NotFoundError) as exc:
        await calendar_module.disconnect_calendar("conn-1", user_id=USER_ID, db=db)

    assert exc.value.details["resource_type"] == "calendar_connection"


@pytest.mark.asyncio
async def test_disconnect_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.disconnect_calendar("conn-1", user_id=USER_ID, db=db)

    assert exc.value.details["operation"] == "disconnect_calendar"


# ---------------------------------------------------------------------------
# Date normalization helper
# ---------------------------------------------------------------------------


def test_parse_date_only_accepts_bare_and_iso_datetime_inputs():
    assert _parse_date_only("2026-01-15", "start_date") == "2026-01-15"
    assert _parse_date_only("2026-01-15T10:30:00.000Z", "start_date") == "2026-01-15"
    assert _parse_date_only("2026-01-15T10:30:00+05:30", "end_date") == "2026-01-15"


def test_parse_date_only_rejects_garbage():
    with pytest.raises(ValidationError):
        _parse_date_only("not-a-date", "start_date")


# ---------------------------------------------------------------------------
# GET /events
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_events_returns_all_without_date_bounds():
    db = FakeDB(rows={"calendar_events": [_event("e-1"), _event("e-2", start_time="2026-02-01T09:00:00")]})

    result = await calendar_module.get_calendar_events(
        start_date=None,
        end_date=None,
        limit=500,
        offset=0,
        user_id=USER_ID,
        db=db,
    )

    data = result["data"]
    assert [e["id"] for e in data["events"]] == ["e-1", "e-2"]
    assert data["has_more"] is False
    assert data["limit"] == 500
    assert data["offset"] == 0
    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_get_events_applies_day_boundary_filters():
    db = FakeDB(
        rows={
            "calendar_events": [
                _event("e-1", start_time="2025-12-31T23:00:00"),
                _event("e-2", start_time="2026-01-03T10:00:00"),
                _event("e-3", start_time="2026-02-01T09:00:00"),
            ]
        }
    )

    result = await calendar_module.get_calendar_events(
        start_date="2026-01-01",
        end_date="2026-01-05T23:59:59.000Z",
        limit=500,
        offset=0,
        user_id=USER_ID,
        db=db,
    )

    assert [e["id"] for e in result["data"]["events"]] == ["e-2"]
    filters = [(op, col, value) for table, op, col, value in db.filters if table == "calendar_events"]
    assert ("gte", "start_time", "2026-01-01T00:00:00") in filters
    assert ("lte", "start_time", "2026-01-05T23:59:59") in filters


@pytest.mark.asyncio
async def test_get_events_reports_has_more():
    db = FakeDB(
        rows={
            "calendar_events": [
                _event("e-1"),
                _event("e-2", start_time="2026-01-04T09:00:00"),
                _event("e-3", start_time="2026-01-05T09:00:00"),
            ]
        }
    )

    result = await calendar_module.get_calendar_events(
        start_date=None,
        end_date=None,
        limit=2,
        offset=0,
        user_id=USER_ID,
        db=db,
    )

    assert len(result["data"]["events"]) == 2
    assert result["data"]["has_more"] is True


@pytest.mark.asyncio
async def test_get_events_rejects_invalid_start_date():
    db = FakeDB(rows={"calendar_events": []})

    with pytest.raises(ValidationError):
        await calendar_module.get_calendar_events(
            start_date="not-a-date",
            end_date=None,
            limit=500,
            offset=0,
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_get_events_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.get_calendar_events(
            start_date=None,
            end_date=None,
            limit=500,
            offset=0,
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "get_calendar_events"


# ---------------------------------------------------------------------------
# POST /events (create)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_event_returns_the_created_row():
    db = FakeDB(rows={"calendar_events": []})

    result = await calendar_module.create_calendar_event(
        CreateEventRequest(
            title="Team sync",
            start_time="2026-01-10T09:00:00",
            end_time="2026-01-10T10:00:00",
            event_type="work",
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    row = result["data"]
    assert row["title"] == "Team sync"
    assert row["user_id"] == USER_ID
    assert row["event_type"] == "work"
    payload = db.ops_on("calendar_events")[0][1]
    assert payload["is_all_day"] is False
    assert payload["outfit_id"] is None


@pytest.mark.asyncio
async def test_create_event_raises_when_the_write_returns_no_row():
    db = _NoRowDB(results=[SimpleNamespace(data=None)])

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.create_calendar_event(
            CreateEventRequest(title="X", start_time="2026-01-10T09:00:00", end_time="2026-01-10T10:00:00"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "create_calendar_event"


@pytest.mark.asyncio
async def test_create_event_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.create_calendar_event(
            CreateEventRequest(title="X", start_time="2026-01-10T09:00:00", end_time="2026-01-10T10:00:00"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "create_calendar_event"


# ---------------------------------------------------------------------------
# PUT /events/{event_id} (update)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_update_event_applies_only_provided_fields():
    db = FakeDB(rows={"calendar_events": [_event("e-1")]})

    result = await calendar_module.update_calendar_event(
        "e-1",
        UpdateEventRequest(title="Dinner", is_all_day=True),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["event"]["title"] == "Dinner"
    assert result["data"]["event"]["is_all_day"] is True
    payload = db.ops_on("calendar_events")[0][1]
    assert payload["title"] == "Dinner"
    assert "start_time" not in payload, "untouched fields must not be written"


@pytest.mark.asyncio
async def test_update_event_persists_every_supported_field():
    db = FakeDB(rows={"calendar_events": [_event("e-1")]})

    result = await calendar_module.update_calendar_event(
        "e-1",
        UpdateEventRequest(
            title="Dinner",
            description="With the team",
            start_time="2026-01-03T19:00:00",
            end_time="2026-01-03T21:00:00",
            location="Bistro",
            is_all_day=False,
            outfit_id="outfit-7",
            event_type="social",
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    event = result["data"]["event"]
    assert event["title"] == "Dinner"
    assert event["description"] == "With the team"
    assert event["start_time"] == "2026-01-03T19:00:00"
    assert event["end_time"] == "2026-01-03T21:00:00"
    assert event["location"] == "Bistro"
    assert event["outfit_id"] == "outfit-7"
    assert event["event_type"] == "social"
    payload = db.ops_on("calendar_events")[0][1]
    assert payload["event_type"] == "social"


@pytest.mark.asyncio
async def test_update_event_with_no_changes_reads_instead_of_writing():
    db = FakeDB(rows={"calendar_events": [_event("e-1")]})

    result = await calendar_module.update_calendar_event(
        "e-1",
        UpdateEventRequest(),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "No changes"
    assert result["data"]["event"]["id"] == "e-1"
    assert db.ops_on("calendar_events") == [], "an empty patch must not write"


@pytest.mark.asyncio
async def test_update_event_raises_when_event_missing():
    db = FakeDB(rows={"calendar_events": []})

    with pytest.raises(CalendarEventNotFoundError):
        await calendar_module.update_calendar_event(
            "e-1",
            UpdateEventRequest(title="Dinner"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_event_raises_when_the_write_returns_no_row():
    db = _NoRowDB(results=[SimpleNamespace(data={"id": "e-1"}), SimpleNamespace(data=None)])

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.update_calendar_event(
            "e-1",
            UpdateEventRequest(title="Dinner"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "update_calendar_event"


@pytest.mark.asyncio
async def test_update_event_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.update_calendar_event(
            "e-1",
            UpdateEventRequest(title="Dinner"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "update_calendar_event"


# ---------------------------------------------------------------------------
# DELETE /events/{event_id}
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_delete_event_deletes_the_row():
    db = FakeDB(rows={"calendar_events": [_event("e-1")]})

    result = await calendar_module.delete_calendar_event("e-1", user_id=USER_ID, db=db)

    assert result["data"] == {"id": "e-1"}
    assert result["message"] == "Deleted"
    assert db.ops_on("calendar_events") == [("delete", None)]
    assert db.rows["calendar_events"] == []


@pytest.mark.asyncio
async def test_delete_event_raises_when_event_missing():
    db = FakeDB(rows={"calendar_events": []})

    with pytest.raises(CalendarEventNotFoundError):
        await calendar_module.delete_calendar_event("e-1", user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_event_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.delete_calendar_event("e-1", user_id=USER_ID, db=db)

    assert exc.value.details["operation"] == "delete_calendar_event"


# ---------------------------------------------------------------------------
# POST /events/{event_id}/outfit (assign)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_assign_outfit_to_event():
    db = FakeDB(rows={"calendar_events": [_event("e-1")]})

    result = await calendar_module.assign_outfit_to_event(
        "e-1",
        AssignOutfitRequest(outfit_id="outfit-9"),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["outfit_id"] == "outfit-9"
    payload = db.ops_on("calendar_events")[0][1]
    assert payload["outfit_id"] == "outfit-9"


@pytest.mark.asyncio
async def test_assign_outfit_raises_when_event_missing():
    db = FakeDB(rows={"calendar_events": []})

    with pytest.raises(CalendarEventNotFoundError):
        await calendar_module.assign_outfit_to_event(
            "e-1",
            AssignOutfitRequest(outfit_id="outfit-9"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_assign_outfit_raises_when_the_write_returns_no_row():
    db = _NoRowDB(results=[SimpleNamespace(data={"id": "e-1"}), SimpleNamespace(data=None)])

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.assign_outfit_to_event(
            "e-1",
            AssignOutfitRequest(outfit_id="outfit-9"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "assign_outfit"


@pytest.mark.asyncio
async def test_assign_outfit_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.assign_outfit_to_event(
            "e-1",
            AssignOutfitRequest(outfit_id="outfit-9"),
            user_id=USER_ID,
            db=db,
        )

    assert exc.value.details["operation"] == "assign_outfit"


# ---------------------------------------------------------------------------
# DELETE /events/{event_id}/outfit (remove)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_remove_outfit_from_event():
    db = FakeDB(rows={"calendar_events": [_event("e-1", outfit_id="outfit-9")]})

    result = await calendar_module.remove_outfit_from_event("e-1", user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["outfit_id"] is None
    payload = db.ops_on("calendar_events")[0][1]
    assert payload["outfit_id"] is None


@pytest.mark.asyncio
async def test_remove_outfit_raises_when_event_missing():
    # The row exists but belongs to another user: the scoped update matches
    # nothing, so the handler treats it as not found.
    db = FakeDB(rows={"calendar_events": [_event("e-1", user_id="someone-else")]})

    with pytest.raises(CalendarEventNotFoundError):
        await calendar_module.remove_outfit_from_event("e-1", user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_remove_outfit_wraps_errors():
    db = Mock()
    db.table.side_effect = RuntimeError("db down")

    with pytest.raises(DatabaseError) as exc:
        await calendar_module.remove_outfit_from_event("e-1", user_id=USER_ID, db=db)

    assert exc.value.details["operation"] == "remove_outfit"
