"""
Admin feedback: support-ticket list + status/notes workflow.
"""

from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import AdminFeedbackListItem, AdminFeedbackUpdate, PageResponse
from app.services.admin_service import list_feedback, update_feedback
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/feedback", response_model=PageResponse[AdminFeedbackListItem])
async def list_admin_feedback(
    status: Optional[str] = Query(None, min_length=1, max_length=20),
    category: Optional[str] = Query(None, min_length=1, max_length=30),
    q: Optional[str] = Query(None, min_length=1, max_length=200),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_dir: str = Query("desc", pattern="^(asc|desc)$"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("feedback.read")),
) -> PageResponse[AdminFeedbackListItem]:
    """Paginated support tickets with filters (status, category, search)."""
    result = await list_feedback(
        db,
        status=status,
        category=category,
        q=q,
        page=page,
        page_size=page_size,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminFeedbackListItem](
        items=[AdminFeedbackListItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.patch("/feedback/{ticket_id}", response_model=Dict[str, Any])
async def update_admin_feedback(
    ticket_id: str,
    body: AdminFeedbackUpdate,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("feedback.write")),
) -> Dict[str, Any]:
    """Update a ticket's status and/or internal notes. Audit: feedback.updated."""
    data = body.model_dump(exclude_unset=True)
    result = await update_feedback(db, ticket_id, data)
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="feedback.updated",
        entity_type="support_ticket",
        entity_id=ticket_id,
        payload={"before": result["before"], "after": result["after"]},
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result["after"]
