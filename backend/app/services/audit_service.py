"""
Append-only admin audit service.

Every admin mutation writes one row to ``audit_events`` (migration 038) via
the service client. ``record_audit`` never raises: audit logging must not be
able to fail the admin action it documents, so failures are logged and
swallowed (the audit trail is best-effort by contract, matching the repo's
"never let a non-critical write take down a critical path" pattern used by
the referral/webhook ledgers).
"""

from __future__ import annotations

import logging
from typing import Any, Dict, Optional

from app.utils.db import execute_with_reconnect

logger = logging.getLogger(__name__)


async def record_audit(
    db: Any,
    *,
    actor_id: Optional[str],
    action: str,
    entity_type: str,
    entity_id: Optional[str] = None,
    payload: Optional[Dict[str, Any]] = None,
    ip: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> None:
    """Insert one audit row. Never raises (logs + swallows failures).

    Args:
        db: Supabase client (service role).
        actor_id: Admin user id who performed the action.
        action: Machine-readable action name (e.g. ``user.role_changed``).
        entity_type: Entity kind (``user``, ``subscription``, ``promo_code``,
            ``support_ticket``, ``storage``, ...).
        entity_id: Entity primary key as text (optional).
        payload: Structured before/after or metadata (optional).
        ip / user_agent: Request context captured by the route.
    """
    row = {
        "actor_id": actor_id,
        "action": action,
        "entity_type": entity_type,
        "entity_id": str(entity_id) if entity_id is not None else None,
        "payload": payload or {},
        "ip": ip,
        "user_agent": user_agent,
    }
    try:
        await execute_with_reconnect(
            lambda d: d.table("audit_events").insert(row).execute(),
            db,
            extra={
                "operation": "audit.record",
                "action": action,
                "entity_type": entity_type,
                "entity_id": row["entity_id"],
            },
        )
    except Exception as exc:  # noqa: BLE001 - audit must never raise
        logger.warning(
            "Failed to record audit event (swallowed)",
            extra={
                "action": action,
                "entity_type": entity_type,
                "entity_id": row["entity_id"],
                "error": str(exc)[:300],
            },
        )
