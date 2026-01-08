"""
Calendar models for database and Pydantic validation.

Stores calendar connections and events for outfit planning.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, Boolean, Integer, Text, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class CalendarConnection(Base):
    """Represents a connected calendar account (Google Calendar, etc.)."""

    __tablename__ = "calendar_connections"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)

    # Provider info
    provider = Column(String(50), nullable=False)  # 'google', 'outlook', etc.
    email = Column(String(255), nullable=True)
    calendar_name = Column(String(255), nullable=True)
    calendar_id = Column(String(255), nullable=True)  # External calendar ID

    # Connection status
    is_active = Column(Boolean, default=True, nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    sync_enabled = Column(Boolean, default=True, nullable=False)

    # OAuth tokens (encrypted in production)
    access_token = Column(Text, nullable=True)
    refresh_token = Column(Text, nullable=True)
    token_expires_at = Column(DateTime(timezone=True), nullable=True)

    # Sync metadata
    last_synced_at = Column(DateTime(timezone=True), nullable=True)
    sync_frequency = Column(Integer, default=60)  # Minutes between syncs

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    events = relationship("CalendarEvent", back_populates="calendar_connection", cascade="all, delete-orphan")


class CalendarEvent(Base):
    """Represents a calendar event that can have an outfit assigned."""

    __tablename__ = "calendar_events"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    calendar_connection_id = Column(PGUUID(as_uuid=True), ForeignKey("calendar_connections.id"), nullable=True)

    # External event reference
    external_event_id = Column(String(255), nullable=True)  # ID from external calendar
    external_calendar_id = Column(String(255), nullable=True)

    # Event details
    title = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)
    location = Column(String(500), nullable=True)
    start_time = Column(DateTime(timezone=True), nullable=False, index=True)
    end_time = Column(DateTime(timezone=True), nullable=False)
    is_all_day = Column(Boolean, default=False, nullable=False)

    # Event classification
    event_type = Column(String(50), nullable=True)  # 'work', 'social', 'casual', 'formal', etc.
    event_category = Column(String(50), nullable=True)  # 'meeting', 'party', 'dinner', etc.

    # Outfit assignment
    outfit_id = Column(PGUUID(as_uuid=True), ForeignKey("outfits.id"), nullable=True)
    outfit_notes = Column(Text, nullable=True)

    # Denormalized outfit data for quick display
    outfit_name = Column(String(255), nullable=True)
    outfit_image_url = Column(String(1000), nullable=True)

    # Weather context (cached for display)
    weather_condition = Column(String(50), nullable=True)
    temperature = Column(Integer, nullable=True)

    # Sync metadata
    last_synced_at = Column(DateTime(timezone=True), nullable=True)
    is_recurring = Column(Boolean, default=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    calendar_connection = relationship("CalendarConnection", back_populates="events")
