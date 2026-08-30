"""Administrative reporting and explicit controls for gift vouchers."""

from __future__ import annotations

import asyncio
import csv
import io
from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import UUID, uuid4

from supabase import Client

from app.core.config import settings
from app.core.exceptions import NotFoundError, PermissionDeniedError, ValidationError
from app.models.gift import AdminGiftCreate, GiftUpdate
from app.services.gift_service import CATALOG, GiftService, _rows
from app.utils.datetime_util import parse_utc_datetime, utcnow, utcnow_iso


def _safe_search(value: str) -> str:
    return "".join(character for character in value if character not in {",", "(", ")"})[:100]


def _safe_csv_cell(value: Any) -> Any:
    """Prevent user-provided text from becoming a spreadsheet formula."""
    if not isinstance(value, str):
        return value
    candidate = value.lstrip(" \t\r\n")
    if candidate.startswith(("=", "+", "-", "@")) or value.startswith(("\t", "\r", "\n")):
        return f"'{value}"
    return value


class AdminGiftService:
    """Admin-only gift voucher operations.

    Paid value has no manual mutation path. Only the Stripe event handler can
    revoke it after an external refund or a lost dispute.
    """

    @staticmethod
    async def _expire_overdue(db: Client) -> None:
        """Persist time-based expiry before status reporting and filtering."""
        await asyncio.to_thread(
            db.table("gift_vouchers")
            .update({"status": "expired", "updated_at": utcnow_iso()})
            .eq("status", "issued")
            .lt("expires_at", utcnow_iso())
            .execute
        )

    @staticmethod
    async def summary(db: Client) -> dict[str, Any]:
        await AdminGiftService._expire_overdue(db)
        vouchers_result, grants_result = await asyncio.gather(
            asyncio.to_thread(
                db.table("gift_vouchers")
                .select(
                    "source,status,payment_status,retail_value_cents,"
                    "amount_paid_cents,amount_refunded_cents,issued_at,expires_at"
                )
                .execute
            ),
            asyncio.to_thread(
                db.table("gift_entitlement_grants")
                .select("status,duration_months,remaining_seconds")
                .execute
            ),
        )
        vouchers = _rows(vouchers_result)
        grants = _rows(grants_result)
        now = utcnow()
        issued = [row for row in vouchers if row.get("issued_at")]
        claimed_count = sum(row.get("status") in {"claimed", "revoked"} for row in vouchers)
        queued_months = sum(
            int(row.get("duration_months") or 0)
            for row in grants
            if row.get("status") == "queued"
        )
        expiring_30_days = sum(
            bool(
                row.get("status") == "issued"
                and (expires := parse_utc_datetime(row.get("expires_at")))
                and now < expires <= now + timedelta(days=30)
            )
            for row in vouchers
        )
        return {
            "total_issued": len(issued),
            "paid_revenue_cents": sum(
                max(
                    0,
                    int(row.get("amount_paid_cents") or 0)
                    - int(row.get("amount_refunded_cents") or 0),
                )
                for row in vouchers
                if row.get("source") == "paid"
                and row.get("payment_status") in {"paid", "partially_refunded"}
            ),
            "complimentary_count": sum(row.get("source") == "complimentary" for row in issued),
            "claimed_count": claimed_count,
            "redemption_rate": round((claimed_count / len(issued) * 100), 1) if issued else 0.0,
            "queued_months": queued_months,
            "expired_count": sum(
                row.get("status") == "expired"
                or bool(
                    row.get("status") == "issued"
                    and (expires := parse_utc_datetime(row.get("expires_at")))
                    and expires <= now
                )
                for row in vouchers
            ),
            "expiring_30_days": expiring_30_days,
        }

    @staticmethod
    def _list_query(
        db: Client,
        *,
        q: Optional[str],
        source: Optional[str],
        duration_months: Optional[int],
        status: Optional[str],
        created_from: Optional[datetime],
        created_to: Optional[datetime],
        count: bool,
    ):
        table = db.table("gift_vouchers")
        query = table.select("*", count="exact") if count else table.select("*")
        if q:
            term = _safe_search(q)
            query = query.or_(
                f"from_name.ilike.%{term}%,to_name.ilike.%{term}%,client_request_id.ilike.%{term}%"
            )
        if source:
            query = query.eq("source", source)
        if duration_months:
            query = query.eq("duration_months", duration_months)
        if status:
            query = query.eq("status", status)
        if created_from:
            query = query.gte("created_at", created_from.isoformat())
        if created_to:
            query = query.lte("created_at", created_to.isoformat())
        return query

    @classmethod
    async def list(
        cls,
        db: Client,
        *,
        q: Optional[str] = None,
        source: Optional[str] = None,
        duration_months: Optional[int] = None,
        status: Optional[str] = None,
        created_from: Optional[datetime] = None,
        created_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> dict[str, Any]:
        await cls._expire_overdue(db)
        offset = (page - 1) * page_size
        query = cls._list_query(
            db,
            q=q,
            source=source,
            duration_months=duration_months,
            status=status,
            created_from=created_from,
            created_to=created_to,
            count=True,
        )
        result = await asyncio.to_thread(
            query.order("created_at", desc=True).range(offset, offset + page_size - 1).execute
        )
        items = [
            GiftService.serialize(row, audience="admin").model_dump(mode="json")
            | {
                "amount_paid_cents": row.get("amount_paid_cents"),
                "amount_refunded_cents": row.get("amount_refunded_cents"),
                "stripe_checkout_session_id": row.get("stripe_checkout_session_id"),
            }
            for row in _rows(result)
        ]
        return {
            "items": items,
            "total": int(getattr(result, "count", None) or len(items)),
            "page": page,
            "page_size": page_size,
        }

    @classmethod
    async def export_csv(cls, db: Client, **filters: Any) -> bytes:
        await cls._expire_overdue(db)
        batch_size = 1_000
        rows: list[dict[str, Any]] = []
        total: Optional[int] = None
        while total is None or len(rows) < total:
            query = cls._list_query(db, count=total is None, **filters)
            result = await asyncio.to_thread(
                query.order("created_at", desc=True)
                .range(len(rows), len(rows) + batch_size - 1)
                .execute
            )
            batch = _rows(result)
            if total is None:
                reported_count = getattr(result, "count", None)
                total = int(reported_count) if reported_count is not None else len(batch)
            rows.extend(batch)
            if not batch:
                break

        output = io.StringIO()
        fields = [
            "id",
            "public_id",
            "source",
            "duration_months",
            "retail_value_cents",
            "from_name",
            "to_name",
            "status",
            "payment_status",
            "amount_paid_cents",
            "amount_refunded_cents",
            "issued_at",
            "claimed_at",
            "expires_at",
        ]
        writer = csv.DictWriter(output, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(
            {
                field: _safe_csv_cell(row.get(field))
                for field in fields
            }
            for row in rows
        )
        return output.getvalue().encode("utf-8")

    @staticmethod
    async def get(voucher_id: str, db: Client) -> dict[str, Any]:
        result = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("id", voucher_id).maybe_single().execute
        )
        rows = _rows(result)
        if not rows:
            raise NotFoundError("Gift voucher not found", "gift_voucher", voucher_id)
        voucher = rows[0]
        grant_result = await asyncio.to_thread(
            db.table("gift_entitlement_grants")
            .select("*")
            .eq("voucher_id", voucher_id)
            .maybe_single()
            .execute
        )
        grant_rows = _rows(grant_result)
        response = GiftService.serialize(
            voucher,
            audience="admin",
            entitlement=grant_rows[0] if grant_rows else None,
        ).model_dump(mode="json")
        response.update(
            {
                "purchaser_user_id": voucher.get("purchaser_user_id"),
                "claimed_by_user_id": voucher.get("claimed_by_user_id"),
                "stripe_checkout_session_id": voucher.get("stripe_checkout_session_id"),
                "stripe_payment_intent_id": voucher.get("stripe_payment_intent_id"),
                "amount_paid_cents": voucher.get("amount_paid_cents"),
                "amount_refunded_cents": voucher.get("amount_refunded_cents"),
                "payment_completed_at": voucher.get("payment_completed_at"),
                "admin_note": voucher.get("admin_note"),
                "token_version": voucher.get("token_version"),
                "entitlement": grant_rows[0] if grant_rows else None,
            }
        )
        return response

    @classmethod
    async def create(
        cls,
        actor_id: str,
        body: AdminGiftCreate,
        db: Client,
    ) -> dict[str, Any]:
        if not settings.ENABLE_GIFT_VOUCHER_CREATION:
            raise PermissionDeniedError("Gift voucher creation is not enabled")
        row = {
            "id": str(uuid4()),
            "public_id": str(uuid4()),
            "purchaser_user_id": actor_id,
            "source": "admin",
            "duration_months": body.duration_months,
            "retail_value_cents": CATALOG[body.duration_months],
            "currency": "USD",
            "from_name": body.from_name,
            "to_name": body.to_name,
            "message": body.message,
            "status": "issued",
            "payment_status": "not_applicable",
            "client_request_id": f"admin:{uuid4()}",
            "issued_at": utcnow_iso(),
            "expires_at": body.expires_at.isoformat() if body.expires_at else None,
            "admin_note": body.note,
        }
        result = await asyncio.to_thread(db.table("gift_vouchers").insert(row).execute)
        rows = _rows(result)
        if not rows:
            raise ValidationError("The admin gift could not be created")
        return GiftService.serialize(rows[0], audience="admin").model_dump(mode="json")

    @classmethod
    async def update(
        cls, voucher_id: str, body: GiftUpdate, db: Client
    ) -> dict[str, Any]:
        voucher = await cls.get(voucher_id, db)
        if voucher.get("status") != "issued":
            raise ValidationError("Only an unclaimed gift can be edited")
        payload = body.model_dump(exclude_unset=True)
        payload["artwork_version"] = int(voucher.get("artwork_version") or 1) + 1
        payload["updated_at"] = utcnow_iso()
        result = await asyncio.to_thread(
            db.table("gift_vouchers")
            .update(payload)
            .eq("id", voucher_id)
            .eq("status", "issued")
            .execute
        )
        rows = _rows(result)
        if not rows:
            raise ValidationError("The gift changed before the edit completed")
        return GiftService.serialize(rows[0], audience="admin").model_dump(mode="json")

    @classmethod
    async def rotate(cls, voucher_id: str, db: Client) -> dict[str, Any]:
        voucher = await cls.get(voucher_id, db)
        if voucher.get("status") != "issued":
            raise ValidationError("Only an unclaimed gift link can be rotated")
        result = await asyncio.to_thread(
            db.table("gift_vouchers")
            .update(
                {
                    "token_version": int(voucher.get("token_version") or 1) + 1,
                    "artwork_version": int(voucher.get("artwork_version") or 1) + 1,
                    "updated_at": utcnow_iso(),
                }
            )
            .eq("id", voucher_id)
            .eq("status", "issued")
            .execute
        )
        rows = _rows(result)
        if not rows:
            raise ValidationError("The gift changed before rotation completed")
        return GiftService.serialize(rows[0], audience="admin").model_dump(mode="json")

    @classmethod
    async def assign(cls, voucher_id: str, user_id: str, db: Client) -> dict[str, Any]:
        voucher = await cls.get(voucher_id, db)
        user_result = await asyncio.to_thread(
            db.table("users").select("*").eq("id", user_id).maybe_single().execute
        )
        users = _rows(user_result)
        if not users:
            raise NotFoundError("Recipient account not found", "user", user_id)
        result = await GiftService.claim(
            users[0],
            UUID(str(voucher["public_id"])),
            GiftService.claim_secret(voucher),
            db,
        )
        return result.model_dump(mode="json")

    @classmethod
    async def void_or_revoke(cls, voucher_id: str, reason: str, db: Client) -> dict[str, Any]:
        voucher = await cls.get(voucher_id, db)
        if voucher.get("source") == "paid":
            raise PermissionDeniedError(
                "Paid gift value can only be changed by a confirmed Stripe refund or lost dispute"
            )
        if voucher.get("status") not in {"issued", "claimed"}:
            raise ValidationError("This gift cannot be voided or revoked")
        expected_status = str(voucher["status"])
        result = await asyncio.to_thread(
            db.rpc(
                "void_or_revoke_gift_voucher",
                {
                    "p_voucher_id": voucher_id,
                    "p_expected_status": expected_status,
                    "p_reason": reason,
                    "p_now": utcnow_iso(),
                },
            ).execute
        )
        rows = _rows(result)
        if not rows:
            raise ValidationError("The gift changed before the action completed")
        return GiftService.serialize(rows[0], audience="admin").model_dump(mode="json")

    @staticmethod
    async def adjust_allowance(
        user_id: str,
        duration_months: int,
        add_count: int,
        db: Client,
    ) -> dict[str, Any]:
        user_result = await asyncio.to_thread(
            db.table("users").select("id").eq("id", user_id).maybe_single().execute
        )
        if not _rows(user_result):
            raise NotFoundError("Account not found", "user", user_id)
        await asyncio.to_thread(
            db.rpc("initialize_gift_allowances", {"user_uuid": user_id}).execute
        )
        # PostgREST cannot express ``granted_count = granted_count + n``.
        # Re-read and use an optimistic compare-and-swap so concurrent admin
        # adjustments cannot overwrite each other.
        for _ in range(3):
            current_result = await asyncio.to_thread(
                db.table("gift_voucher_allowances")
                .select("*")
                .eq("user_id", user_id)
                .eq("duration_months", duration_months)
                .single()
                .execute
            )
            current = _rows(current_result)[0]
            old_value = int(current["granted_count"])
            update = await asyncio.to_thread(
                db.table("gift_voucher_allowances")
                .update({"granted_count": old_value + add_count, "updated_at": utcnow_iso()})
                .eq("user_id", user_id)
                .eq("duration_months", duration_months)
                .eq("granted_count", old_value)
                .execute
            )
            rows = _rows(update)
            if rows:
                row = rows[0]
                row["remaining_count"] = max(
                    0, int(row["granted_count"]) - int(row["used_count"])
                )
                return row
        raise ValidationError("The allowance changed concurrently. Try again.")
