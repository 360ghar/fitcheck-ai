"""
Calendar API routes.

Implements the endpoints described in docs/2-technical/api-spec.md:
- POST /api/v1/calendar/connect
- GET /api/v1/calendar/events
- POST /api/v1/calendar/events/{id}/outfit

For MVP, external provider sync is not implemented. We store the connection and
events in Supabase tables so the user can plan outfits against events.
"""

import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.exceptions import (
    CalendarEventNotFoundError,
    DatabaseError,
    NotFoundError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_email, get_current_user_id
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
    outfit_id: Optional[str] = None


class AssignOutfitRequest(BaseModel):
    outfit_id: str


class CreateEventRequest(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: str
    end_time: str
    location: Optional[str] = None
    calendar_id: Optional[str] = None


# ============================================================================
# ENDPOINTS
# ============================================================================


@router.post("/connect", response_model=Dict[str, Any])
async def connect_calendar(
    request: CalendarConnectRequest,
    user_id: str = Depends(get_current_user_id),
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
        # Upsert-like behavior: one connection per provider per user
        existing = (
            db.table("calendar_connections")
            .select("id")
            .eq("user_id", user_id)
            .eq("provider", provider)
            .single()
            .execute()
        )

        now = datetime.utcnow().isoformat()
        if existing.data:
            update = {
                "email": user_email,
                "auth_code": request.auth_code,
                "connected_at": now,
                "updated_at": now,
                "is_active": True,
            }
            result = (
                db.table("calendar_connections")
                .update(update)
                .eq("id", existing.data["id"])
                .execute()
            )
            row = (result.data or [None])[0]
            logger.info(
                "Calendar connection updated",
                user_id=user_id,
                provider=provider,
                connection_id=existing.data["id"]
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
            result = db.table("calendar_connections").insert(insert).execute()
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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """List connected calendar providers for the user."""
    try:
        res = (
            db.table("calendar_connections")
            .select("*")
            .eq("user_id", user_id)
            .order("connected_at", desc=True)
            .execute()
        )
        connections: List[CalendarConnectionData] = []
        for row in res.data or []:
            connections.append(
                CalendarConnectionData(
                    id=row["id"],
                    provider=row.get("provider") or "",
                    email=row.get("email"),
                    connected_at=row.get("connected_at") or row.get("created_at") or datetime.utcnow().isoformat(),
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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Disconnect a calendar provider (soft disable)."""
    try:
        existing = (
            db.table("calendar_connections")
            .select("id")
            .eq("id", connection_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise NotFoundError(
                message="Calendar connection not found",
                resource_type="calendar_connection",
                resource_id=connection_id
            )

        now = datetime.utcnow().isoformat()
        db.table("calendar_connections").update({"is_active": False, "updated_at": now}).eq("id", connection_id).execute()
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


@router.get("/events", response_model=Dict[str, Any])
async def get_calendar_events(
    start_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Get calendar events in a date range."""
    try:
        query = db.table("calendar_events").select("*").eq("user_id", user_id)

        if start_date:
            query = query.gte("start_time", f"{start_date}T00:00:00")
        if end_date:
            query = query.lte("start_time", f"{end_date}T23:59:59")

        result = query.order("start_time", desc=False).execute()
        events: List[CalendarEventData] = []
        for row in result.data or []:
            events.append(
                CalendarEventData(
                    id=row["id"],
                    calendar_id=row.get("calendar_id"),
                    title=row.get("title") or "",
                    description=row.get("description"),
                    start_time=row.get("start_time"),
                    end_time=row.get("end_time"),
                    location=row.get("location"),
                    outfit_id=row.get("outfit_id"),
                )
            )

        logger.debug(
            "Calendar events retrieved",
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            count=len(events)
        )
        return {"data": {"events": [e.model_dump() for e in events]}, "message": "OK"}

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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Create an in-app calendar event (local planning)."""
    try:
        event_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat()
        insert = {
            "id": event_id,
            "user_id": user_id,
            "calendar_id": request.calendar_id,
            "title": request.title,
            "description": request.description,
            "start_time": request.start_time,
            "end_time": request.end_time,
            "location": request.location,
            "outfit_id": None,
            "created_at": now,
            "updated_at": now,
        }
        result = db.table("calendar_events").insert(insert).execute()
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
    except DatabaseError:
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


@router.post("/events/{event_id}/outfit", response_model=Dict[str, Any])
async def assign_outfit_to_event(
    event_id: str,
    request: AssignOutfitRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Assign an outfit to a calendar event."""
    try:
        # Verify event exists and belongs to user
        existing = (
            db.table("calendar_events")
            .select("id")
            .eq("id", event_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise CalendarEventNotFoundError(event_id=event_id)

        now = datetime.utcnow().isoformat()
        result = (
            db.table("calendar_events")
            .update({"outfit_id": request.outfit_id, "updated_at": now})
            .eq("id", event_id)
            .execute()
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

    except (CalendarEventNotFoundError, DatabaseError):
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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Remove outfit assignment from an event."""
    try:
        now = datetime.utcnow().isoformat()
        result = (
            db.table("calendar_events")
            .update({"outfit_id": None, "updated_at": now})
            .eq("id", event_id)
            .eq("user_id", user_id)
            .execute()
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
