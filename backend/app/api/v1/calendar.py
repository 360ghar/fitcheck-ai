"""
Calendar API routes.

Implements the endpoints described in docs/references/api-spec.md:
- POST /api/v1/calendar/connect
- GET /api/v1/calendar/events
- POST /api/v1/calendar/events/{id}/outfit

For MVP, external provider sync is not implemented. We store the connection and
events in Supabase tables so the user can plan outfits against events.
"""

import asyncio
import uuid
from datetime import timezone
from app.utils.datetime_util import parse_utc_datetime, utcnow_iso
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.exceptions import (
    CalendarEventNotFoundError,
    DatabaseError,
    NotFoundError,
    OutfitNotFoundError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_email
from app.api.v1.deps import get_active_user_id
from app.db.connection import get_db

logger = get_context_logger(__name__)

router = APIRouter()


# ============================================================================
# MODELS
# ============================================================================


class CalendarConnectRequest(BaseModel):
    provider: str = Field(..., description="google|apple|outlook|local")
    auth_code: Optional[str] = Field(None, description="OAuth auth code (if applicable)")


class CalendarConnectionData(BaseModel):
    id: str
    provider: str
    email: Optional[str] = None
    connected_at: str


class CalendarEventData(BaseModel):
    id: str
    calendar_id: Optional[str] = None
    title: str
    description: Optional[str] = None
    start_time: str
    end_time: str
    location: Optional[str] = None
    is_all_day: bool = False
    outfit_id: Optional[str] = None
    event_type: str = Field("other", max_length=30)


class AssignOutfitRequest(BaseModel):
    outfit_id: str


class CreateEventRequest(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: str
    end_time: str
    location: Optional[str] = None
    calendar_id: Optional[str] = None
    is_all_day: bool = False
    outfit_id: Optional[str] = None
    event_type: str = Field("other", max_length=30)


class UpdateEventRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    location: Optional[str] = None
    is_all_day: Optional[bool] = None
    outfit_id: Optional[str] = None
    event_type: Optional[str] = Field(None, max_length=30)


# ============================================================================
# ENDPOINTS
# ============================================================================


@router.get("", response_model=Dict[str, Any])
async def calendar_root():
    """Root handler for the calendar router.

    Some clients (and probes) GET the bare ``/api/v1/calendar`` path; without a
    root handler it 404s and adds log noise. The real functionality lives under
    ``/connect``, ``/connections`` and ``/events``. (RCA 2026-08-05: 404 noise.)
    """
    return {
        "service": "calendar",
        "endpoints": ["/connect", "/connections", "/events"],
    }


@router.post("/connect", response_model=Dict[str, Any])
async def connect_calendar(
    request: CalendarConnectRequest,
    user_id: str = Depends(get_active_user_id),
    user_email: Optional[str] = Depends(get_current_user_email),
    db: Client = Depends(get_db),
):
    """Connect a calendar provider.

    For MVP, we record the connection and return it.
    """
    provider = request.provider.lower().strip()
    if provider not in {"google", "apple", "outlook", "local"}:
        raise ValidationError(
            message="Invalid calendar provider",
            details={"provider": provider, "allowed": ["google", "apple", "outlook", "local"]}
        )

    try:
        # Upsert-like behavior: one connection per provider per user.
        # Use maybe_single() so a first-time connect (0 rows) does not raise PGRST116.
        existing = await asyncio.to_thread(
            db.table("calendar_connections")
            .select("id")
            .eq("user_id", user_id)
            .eq("provider", provider)
            .maybe_single()
            .execute
        )

        now = utcnow_iso()
        existing_row = existing.data if existing is not None else None
        if existing_row:
            update = {
                "email": user_email,
                "auth_code": request.auth_code,
                "connected_at": now,
                "updated_at": now,
                "is_active": True,
            }
            result = await asyncio.to_thread(
                db.table("calendar_connections")
                .update(update)
                .eq("id", existing_row["id"])
                .execute
            )
            row = (result.data or [None])[0]
            logger.info(
                "Calendar connection updated",
                user_id=user_id,
                provider=provider,
                connection_id=existing_row["id"]
            )
        else:
            connection_id = str(uuid.uuid4())
            insert = {
                "id": connection_id,
                "user_id": user_id,
                "provider": provider,
                "email": user_email,
                "auth_code": request.auth_code,
                "connected_at": now,
                "created_at": now,
                "updated_at": now,
                "is_active": True,
            }
            result = await asyncio.to_thread(db.table("calendar_connections").insert(insert).execute)
            row = (result.data or [None])[0]
            logger.info(
                "Calendar connection created",
                user_id=user_id,
                provider=provider,
                connection_id=connection_id
            )

        if not row:
            raise DatabaseError(
                message="Failed to connect calendar",
                operation="calendar_connection_upsert"
            )

        data = CalendarConnectionData(
            id=row["id"],
            provider=row["provider"],
            email=row.get("email"),
            connected_at=row.get("connected_at") or now,
        )
        return {"data": data.model_dump(), "message": "Connected"}

    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(
            "Calendar connect error",
            user_id=user_id,
            provider=provider,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to connect calendar",
            operation="calendar_connection"
        )


@router.get("/connections", response_model=Dict[str, Any])
async def list_calendar_connections(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """List connected calendar providers for the user."""
    try:
        res = await asyncio.to_thread(
            db.table("calendar_connections")
            .select("*")
            .eq("user_id", user_id)
            .order("connected_at", desc=True)
            .execute
        )
        connections: List[CalendarConnectionData] = []
        for row in res.data or []:
            connections.append(
                CalendarConnectionData(
                    id=row["id"],
                    provider=row.get("provider") or "",
                    email=row.get("email"),
                    connected_at=row.get("connected_at") or row.get("created_at") or utcnow_iso(),
                )
            )
        logger.debug(
            "Calendar connections retrieved",
            user_id=user_id,
            count=len(connections)
        )
        return {"data": {"connections": [c.model_dump() for c in connections]}, "message": "OK"}
    except Exception as e:
        logger.error(
            "Calendar connections error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to fetch calendar connections",
            operation="list_calendar_connections"
        )


@router.delete("/connections/{connection_id}", response_model=Dict[str, Any])
async def disconnect_calendar(
    connection_id: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Disconnect a calendar provider (soft disable)."""
    try:
        existing = await asyncio.to_thread(
            db.table("calendar_connections")
            .select("id")
            .eq("id", connection_id)
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        if not existing or not existing.data:
            raise NotFoundError(
                message="Calendar connection not found",
                resource_type="calendar_connection",
                resource_id=connection_id
            )

        now = utcnow_iso()
        await asyncio.to_thread(db.table("calendar_connections").update({"is_active": False, "updated_at": now}).eq("id", connection_id).execute)
        logger.info(
            "Calendar connection disconnected",
            user_id=user_id,
            connection_id=connection_id
        )
        return {"data": {"id": connection_id, "is_active": False, "updated_at": now}, "message": "OK"}
    except NotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Disconnect calendar error",
            user_id=user_id,
            connection_id=connection_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to disconnect calendar",
            operation="disconnect_calendar"
        )


def _parse_date_only(value: str, field_name: str) -> str:
    """Normalize a client-supplied date/datetime string to YYYY-MM-DD.

    Accepts both a bare date (web frontend) and a full ISO datetime with
    milliseconds (Flutter's DateTime.toIso8601String()) - either way we only
    need the date component for the day-boundary filters below.
    """
    parsed = parse_utc_datetime(value)
    if parsed is None:
        raise ValidationError(f"Invalid {field_name}: {value}")
    return parsed.date().isoformat()


def _calendar_day_bound(value: str, *, is_end: bool) -> str:
    """Turn a date-range filter value into a naive-UTC TIMESTAMP literal.

    Date-only values (``YYYY-MM-DD``, the web client) mean UTC-midnight
    boundaries. Full ISO instants (Flutter converts its local month-midnight
    to UTC before sending, e.g. ``2026-08-01T18:30:00.000Z``) keep their
    exact time — A4-02: truncating them to the UTC date shifted the window
    by the device's UTC offset, so events near local midnight were grouped
    on the wrong day in month views and dropped from week-range fetches.

    Returns a timezone-free string because the column is
    ``TIMESTAMP WITHOUT TIME ZONE`` holding UTC instants.
    """
    if "T" in value:
        parsed = parse_utc_datetime(value)
        if parsed is None:
            raise ValidationError(f"Invalid date range bound: {value}")
        return parsed.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
    day = _parse_date_only(value, "date")
    return f"{day}T23:59:59.999" if is_end else f"{day}T00:00:00"


def _validate_event_time_window(
    start_time: str,
    end_time: str,
    is_all_day: bool,
) -> None:
    """Validate an event's time window before it reaches the TIMESTAMP columns.

    Raises ValidationError (422) when:
    - either time does not parse as ISO-8601 ('Z' suffix normalized) — bare
      strings used to 500 at the DB with 22007;
    - a timed event ends before it starts;
    - an all-day event's end date precedes its start date. All-day events
      compare dates only: clients send date-only or picker-derived times
      (e.g. 9:00-10:00) for those, so a same-day all-day event must not be
      rejected on time-of-day alone.
    """
    start_dt = parse_utc_datetime(start_time)
    if start_dt is None:
        raise ValidationError(f"Invalid start_time: {start_time}")
    end_dt = parse_utc_datetime(end_time)
    if end_dt is None:
        raise ValidationError(f"Invalid end_time: {end_time}")
    if is_all_day:
        if end_dt.date() < start_dt.date():
            raise ValidationError(
                "end_time must be on or after start_time for all-day events"
            )
    elif end_dt < start_dt:
        raise ValidationError("end_time must be on or after start_time")


@router.get("/events", response_model=Dict[str, Any])
async def get_calendar_events(
    start_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    limit: int = Query(500, ge=1, le=1000, description="Max events to return"),
    offset: int = Query(0, ge=0),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Get calendar events in a date range.

    Both dates are optional, so without a bound this returned the user's
    entire event history in one response. Default limit is deliberately
    generous (500): existing clients send neither limit nor offset and expect
    a whole month/year of events back.
    """
    try:
        query = db.table("calendar_events").select("*").eq("user_id", user_id)

        if start_date:
            query = query.gte("start_time", _calendar_day_bound(start_date, is_end=False))
        if end_date:
            query = query.lte("start_time", _calendar_day_bound(end_date, is_end=True))

        # Fetch one past the limit so has_more is known without a second
        # count query (items.py pays for count="exact" because it renders
        # page numbers; the calendar only needs "is there more").
        result = await asyncio.to_thread(query.order("start_time", desc=False).range(offset, offset + limit).execute)
        rows = list(result.data or [])
        has_more = len(rows) > limit
        events: List[CalendarEventData] = []
        for row in rows[:limit]:
            events.append(
                CalendarEventData(
                    id=row["id"],
                    calendar_id=row.get("calendar_id"),
                    title=row.get("title") or "",
                    description=row.get("description"),
                    start_time=row.get("start_time"),
                    end_time=row.get("end_time"),
                    location=row.get("location"),
                    is_all_day=bool(row.get("is_all_day", False)),
                    outfit_id=row.get("outfit_id"),
                    event_type=row.get("event_type") or "other",
                )
            )

        logger.debug(
            "Calendar events retrieved",
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            count=len(events)
        )
        return {
            "data": {
                "events": [e.model_dump() for e in events],
                "limit": limit,
                "offset": offset,
                "has_more": has_more,
            },
            "message": "OK",
        }

    except ValidationError:
        raise
    except Exception as e:
        logger.error(
            "Calendar events error",
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to fetch calendar events",
            operation="get_calendar_events"
        )


@router.post("/events", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_calendar_event(
    request: CreateEventRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Create an in-app calendar event (local planning)."""
    try:
        _validate_event_time_window(request.start_time, request.end_time, request.is_all_day)
        event_id = str(uuid.uuid4())
        now = utcnow_iso()
        insert = {
            "id": event_id,
            "user_id": user_id,
            "calendar_id": request.calendar_id,
            "title": request.title,
            "description": request.description,
            "start_time": request.start_time,
            "end_time": request.end_time,
            "location": request.location,
            "is_all_day": request.is_all_day,
            "outfit_id": request.outfit_id,
            "event_type": request.event_type,
            "created_at": now,
            "updated_at": now,
        }
        result = await asyncio.to_thread(db.table("calendar_events").insert(insert).execute)
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError(
                message="Failed to create calendar event",
                operation="create_calendar_event"
            )
        logger.info(
            "Calendar event created",
            user_id=user_id,
            event_id=event_id,
            title=request.title
        )
        return {"data": row, "message": "Created"}
    except (DatabaseError, ValidationError):
        raise
    except Exception as e:
        logger.error(
            "Create calendar event error",
            user_id=user_id,
            title=request.title,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to create event",
            operation="create_calendar_event"
        )


@router.put("/events/{event_id}", response_model=Dict[str, Any])
async def update_calendar_event(
    event_id: str,
    request: UpdateEventRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Update a calendar event."""
    try:
        # Verify event exists and belongs to user
        existing = await asyncio.to_thread(
            db.table("calendar_events")
            .select("id")
            .eq("id", event_id)
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        if not existing or not existing.data:
            raise CalendarEventNotFoundError(event_id=event_id)

        # Validate any provided times against the event's effective window —
        # the row already loaded fills in for fields the client did not send,
        # so a partial update cannot sneak an inverted window past the check.
        if request.start_time is not None or request.end_time is not None:
            effective_start = (
                request.start_time
                if request.start_time is not None
                else existing.data.get("start_time")
            )
            effective_end = (
                request.end_time
                if request.end_time is not None
                else existing.data.get("end_time")
            )
            effective_all_day = (
                request.is_all_day
                if request.is_all_day is not None
                else bool(existing.data.get("is_all_day", False))
            )
            if effective_start is not None and effective_end is not None:
                _validate_event_time_window(
                    effective_start, effective_end, effective_all_day
                )

        # Build update dict from EXPLICITLY provided fields (exclude_unset
        # semantics, A4-11): a field sent as explicit null CLEARS it, an
        # absent field is left untouched. The old `is not None` checks made
        # explicit null a silent no-op, so clients could never clear
        # description/location/outfit_id once set. model_fields_set is the
        # pydantic "was this key present in the payload" set.
        provided = request.model_fields_set
        update_data: Dict[str, Any] = {}
        for field_name in (
            "title",
            "description",
            "start_time",
            "end_time",
            "location",
            "is_all_day",
            "outfit_id",
            "event_type",
        ):
            if field_name in provided:
                update_data[field_name] = getattr(request, field_name)

        if not update_data:
            # No fields to update, return existing event
            result = await asyncio.to_thread(
                db.table("calendar_events")
                .select("*")
                .eq("id", event_id)
                .maybe_single()
                .execute
            )
            event_row = result.data if result else None
            if not event_row:
                raise CalendarEventNotFoundError(event_id=event_id)
            return {"data": {"event": event_row}, "message": "No changes"}

        now = utcnow_iso()
        update_data["updated_at"] = now

        result = await asyncio.to_thread(
            db.table("calendar_events")
            .update(update_data)
            .eq("id", event_id)
            .execute
        )
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError(
                message="Failed to update calendar event",
                operation="update_calendar_event"
            )

        logger.info(
            "Calendar event updated",
            user_id=user_id,
            event_id=event_id
        )
        return {"data": {"event": row}, "message": "Updated"}

    except (CalendarEventNotFoundError, DatabaseError, ValidationError):
        raise
    except Exception as e:
        logger.error(
            "Update calendar event error",
            user_id=user_id,
            event_id=event_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to update event",
            operation="update_calendar_event"
        )


@router.delete("/events/{event_id}", response_model=Dict[str, Any])
async def delete_calendar_event(
    event_id: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete a calendar event."""
    try:
        # Verify event exists and belongs to user
        existing = await asyncio.to_thread(
            db.table("calendar_events")
            .select("id")
            .eq("id", event_id)
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        if not existing or not existing.data:
            raise CalendarEventNotFoundError(event_id=event_id)

        # Delete the event
        await asyncio.to_thread(db.table("calendar_events").delete().eq("id", event_id).execute)

        logger.info(
            "Calendar event deleted",
            user_id=user_id,
            event_id=event_id
        )
        return {"data": {"id": event_id}, "message": "Deleted"}

    except CalendarEventNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Delete calendar event error",
            user_id=user_id,
            event_id=event_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to delete event",
            operation="delete_calendar_event"
        )


@router.post("/events/{event_id}/outfit", response_model=Dict[str, Any])
async def assign_outfit_to_event(
    event_id: str,
    request: AssignOutfitRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Assign an outfit to a calendar event."""
    try:
        # Verify event exists and belongs to user
        existing = await asyncio.to_thread(
            db.table("calendar_events")
            .select("id")
            .eq("id", event_id)
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        if not existing or not existing.data:
            raise CalendarEventNotFoundError(event_id=event_id)

        # A4-05: verify the outfit exists AND belongs to the user before the
        # FK write — a bogus or foreign outfit_id used to surface as a
        # Postgres FK violation → 500 instead of a clean 404.
        outfit = await asyncio.to_thread(
            db.table("outfits")
            .select("id")
            .eq("id", str(request.outfit_id))
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        if not outfit or not outfit.data:
            raise OutfitNotFoundError(outfit_id=str(request.outfit_id))

        now = utcnow_iso()
        result = await asyncio.to_thread(
            db.table("calendar_events")
            .update({"outfit_id": request.outfit_id, "updated_at": now})
            .eq("id", event_id)
            .execute
        )
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError(
                message="Failed to assign outfit to event",
                operation="assign_outfit"
            )

        logger.info(
            "Outfit assigned to calendar event",
            user_id=user_id,
            event_id=event_id,
            outfit_id=request.outfit_id
        )
        return {"data": {"id": event_id, "outfit_id": request.outfit_id, "updated_at": now}, "message": "OK"}

    except (CalendarEventNotFoundError, DatabaseError, OutfitNotFoundError):
        raise
    except Exception as e:
        logger.error(
            "Assign outfit error",
            user_id=user_id,
            event_id=event_id,
            outfit_id=request.outfit_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to assign outfit",
            operation="assign_outfit"
        )


@router.delete("/events/{event_id}/outfit", response_model=Dict[str, Any])
async def remove_outfit_from_event(
    event_id: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Remove outfit assignment from an event."""
    try:
        now = utcnow_iso()
        result = await asyncio.to_thread(
            db.table("calendar_events")
            .update({"outfit_id": None, "updated_at": now})
            .eq("id", event_id)
            .eq("user_id", user_id)
            .execute
        )
        if not result.data:
            raise CalendarEventNotFoundError(event_id=event_id)
        logger.info(
            "Outfit removed from calendar event",
            user_id=user_id,
            event_id=event_id
        )
        return {"data": {"id": event_id, "outfit_id": None, "updated_at": now}, "message": "OK"}
    except CalendarEventNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Remove outfit error",
            user_id=user_id,
            event_id=event_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to remove outfit",
            operation="remove_outfit"
        )
