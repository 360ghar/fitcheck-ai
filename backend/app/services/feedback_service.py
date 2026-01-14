"""
Feedback service for managing support tickets.
"""
import logging
from typing import Optional, List

from supabase import Client

from app.models.feedback import (
    CreateFeedbackRequest,
    FeedbackResponse,
    TicketListItem,
    TicketListResponse,
    TicketStatus,
)

logger = logging.getLogger(__name__)


class FeedbackService:
    """Service for managing feedback/support tickets."""

    @staticmethod
    async def create_ticket(
        request: CreateFeedbackRequest,
        user_id: Optional[str],
        attachment_urls: List[str],
        db: Client,
    ) -> FeedbackResponse:
        """
        Create a new support ticket.

        Args:
            request: Ticket creation request
            user_id: User ID (None for anonymous)
            attachment_urls: List of uploaded attachment URLs
            db: Supabase client

        Returns:
            Created ticket response
        """
        ticket_data = {
            "user_id": user_id,
            "category": request.category.value,
            "subject": request.subject,
            "description": request.description,
            "attachment_urls": attachment_urls,
            "contact_email": request.contact_email if not user_id else None,
            "device_info": request.device_info.model_dump() if request.device_info else None,
            "app_version": request.app_version,
            "app_platform": request.app_platform,
            "status": TicketStatus.OPEN.value,
        }

        result = db.table("support_tickets").insert(ticket_data).execute()

        if not result.data:
            raise Exception("Failed to create support ticket")

        ticket = result.data[0]

        logger.info(
            f"Created support ticket {ticket['id']} - "
            f"category={request.category.value}, user_id={user_id or 'anonymous'}"
        )

        return FeedbackResponse(
            id=ticket["id"],
            category=request.category,
            subject=request.subject,
            status=TicketStatus.OPEN,
            created_at=ticket["created_at"],
            message="Thank you for your feedback! We'll review it shortly.",
        )

    @staticmethod
    async def get_user_tickets(
        user_id: str,
        db: Client,
        limit: int = 20,
        offset: int = 0,
    ) -> TicketListResponse:
        """
        Get a user's support tickets.

        Args:
            user_id: User ID
            db: Supabase client
            limit: Max tickets to return
            offset: Pagination offset

        Returns:
            List of tickets with total count
        """
        # Get total count
        count_result = db.table("support_tickets").select(
            "id", count="exact"
        ).eq("user_id", user_id).execute()

        total = count_result.count or 0

        # Get paginated tickets
        result = db.table("support_tickets").select(
            "id, category, subject, status, created_at"
        ).eq("user_id", user_id).order(
            "created_at", desc=True
        ).range(offset, offset + limit - 1).execute()

        tickets = [
            TicketListItem(
                id=t["id"],
                category=t["category"],
                subject=t["subject"],
                status=t["status"],
                created_at=t["created_at"],
            )
            for t in (result.data or [])
        ]

        return TicketListResponse(tickets=tickets, total=total)
