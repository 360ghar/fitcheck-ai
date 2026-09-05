"""Issue, fulfill, claim, and resolve FitCheck Pro gift vouchers."""

from __future__ import annotations

import asyncio
import base64
import hashlib
import hmac
from typing import Any, Literal, Optional
from urllib.parse import urlparse
from uuid import UUID, uuid4

import stripe
from dateutil.relativedelta import relativedelta
from supabase import Client

from app.core.config import settings
from app.core.exceptions import (
    BillingNotConfiguredError,
    DatabaseError,
    NotFoundError,
    PermissionDeniedError,
    ServiceError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.models.gift import (
    ComplimentaryGiftCreate,
    GiftAllowance,
    GiftCatalogOption,
    GiftClaimResponse,
    GiftDashboardSummary,
    GiftListResponse,
    GiftSource,
    GiftStatus,
    GiftUpdate,
    GiftVoucherResponse,
    PaidGiftCheckoutCreate,
    presentation_payload,
)
from app.models.subscription import PlanType, SubscriptionResponse, SubscriptionStatus
from app.services.gift_artwork_service import GiftArtworkService
from app.utils.datetime_util import parse_utc_datetime, utcnow, utcnow_iso

logger = get_context_logger(__name__)


CATALOG: dict[int, int] = {1: 2_000, 3: 6_000, 12: 20_000}


def _value(obj: object, key: str, default: Any = None) -> Any:
    if isinstance(obj, dict):
        return obj.get(key, default)
    return getattr(obj, key, default)


def _rows(result: object) -> list[dict[str, Any]]:
    data = getattr(result, "data", None)
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        return [data]
    return []


class GiftService:
    """Domain service for gift vouchers.

    Claim credentials are derived from an HMAC and are never stored. Rotating
    ``token_version`` invalidates every old link and legacy printed code.
    """

    @staticmethod
    def price_id_map() -> dict[int, str]:
        return {
            duration: price_id
            for duration, price_id in (
                (1, settings.STRIPE_GIFT_PRO_1M_PRICE_ID),
                (3, settings.STRIPE_GIFT_PRO_3M_PRICE_ID),
                (12, settings.STRIPE_GIFT_PRO_12M_PRICE_ID),
            )
            if price_id
        }

    @classmethod
    def catalog(cls) -> list[GiftCatalogOption]:
        prices = cls.price_id_map()
        return [
            GiftCatalogOption(
                duration_months=duration,  # type: ignore[arg-type]
                retail_value_cents=value,
                paid_available=bool(settings.ENABLE_GIFT_VOUCHER_CREATION and prices.get(duration)),
            )
            for duration, value in CATALOG.items()
        ]

    @staticmethod
    def _credential_key() -> bytes:
        raw = settings.GIFT_TOKEN_SECRET or settings.SUPABASE_JWT_SECRET
        if not raw:
            raise ServiceError("Gift credentials are not configured", service_name="gift_vouchers")
        return raw.encode("utf-8")

    @classmethod
    def _credential_digest(cls, voucher: dict[str, Any]) -> bytes:
        payload = f"{voucher['id']}:{int(voucher.get('token_version') or 1)}".encode()
        return hmac.new(cls._credential_key(), payload, hashlib.sha256).digest()

    @classmethod
    def claim_secret(cls, voucher: dict[str, Any]) -> str:
        return base64.urlsafe_b64encode(cls._credential_digest(voucher)).rstrip(b"=").decode("ascii")

    @classmethod
    def claim_code(cls, voucher: dict[str, Any]) -> str:
        encoded = base64.b32encode(cls._credential_digest(voucher)[:16]).decode("ascii").rstrip("=")
        return "-".join(encoded[index : index + 5] for index in range(0, len(encoded), 5))

    @classmethod
    def credential_matches(cls, voucher: dict[str, Any], candidate: str) -> bool:
        normalized = candidate.strip()
        # ``compare_digest`` rejects non-ASCII strings. Credentials are derived
        # with URL-safe Base64 or Base32, so reject malformed Unicode input
        # before constant-time comparisons rather than turning it into a 500.
        if not normalized.isascii():
            return False
        secret_match = hmac.compare_digest(normalized, cls.claim_secret(voucher))
        normalized_code = "".join(character for character in normalized.upper() if character.isalnum())
        expected_code = "".join(character for character in cls.claim_code(voucher).upper() if character.isalnum())
        code_match = hmac.compare_digest(
            normalized_code,
            expected_code,
        )
        return secret_match or code_match

    @staticmethod
    def _share_url(voucher: dict[str, Any], secret: str) -> str:
        base = settings.FRONTEND_URL.rstrip("/")
        return f"{base}/gift/{voucher['public_id']}#claim={secret}"

    @staticmethod
    def _artwork_urls(voucher: dict[str, Any]) -> tuple[str, str]:
        version = int(voucher.get("artwork_version") or 1)
        public_id = voucher["public_id"]
        return (
            f"/api/v1/gifts/{voucher['id']}/artwork/portrait.png?v={version}&layout={GiftArtworkService.ARTWORK_LAYOUT_VERSION}",
            f"/api/v1/gifts/public/{public_id}/artwork/og.png?v={version}&layout={GiftArtworkService.ARTWORK_LAYOUT_VERSION}",
        )

    @classmethod
    def serialize(
        cls,
        voucher: dict[str, Any],
        *,
        audience: Literal["public", "recipient", "owner", "admin"],
        entitlement: Optional[dict[str, Any]] = None,
    ) -> GiftVoucherResponse:
        include_commerce = audience in {"owner", "admin"}
        include_claim_state = audience in {"recipient", "owner", "admin"}
        include_owner_secrets = audience == "owner"
        portrait_url, og_url = cls._artwork_urls(voucher)
        effective_status = voucher.get("status", "issued")
        expiry = parse_utc_datetime(voucher.get("expires_at"))
        if effective_status == "issued" and expiry and expiry <= utcnow():
            effective_status = "expired"

        secret = cls.claim_secret(voucher) if include_owner_secrets and effective_status == "issued" else None
        return GiftVoucherResponse(
            id=voucher["id"],
            public_id=voucher["public_id"],
            source=GiftSource(voucher["source"]) if include_commerce else None,
            duration_months=int(voucher["duration_months"]),
            retail_value_cents=int(voucher["retail_value_cents"]),
            currency=voucher.get("currency", "USD"),
            from_name=voucher["from_name"],
            to_name=voucher["to_name"],
            message=voucher.get("message"),
            occasion=voucher.get("occasion"),
            occasion_greeting=voucher.get("occasion_greeting"),
            status=GiftStatus(effective_status),
            payment_status=voucher.get("payment_status") if include_commerce else None,
            issued_at=parse_utc_datetime(voucher.get("issued_at")),
            expires_at=expiry,
            claimed_at=(parse_utc_datetime(voucher.get("claimed_at")) if include_claim_state else None),
            created_at=parse_utc_datetime(voucher.get("created_at")) or utcnow(),
            artwork_version=int(voucher.get("artwork_version") or 1),
            share_url=cls._share_url(voucher, secret) if secret else None,
            claim_code=cls.claim_code(voucher) if secret else None,
            portrait_url=portrait_url if include_owner_secrets else None,
            og_image_url=og_url,
            entitlement_status=(entitlement or {}).get("status"),
            entitlement_starts_at=parse_utc_datetime((entitlement or {}).get("started_at")),
            entitlement_ends_at=parse_utc_datetime((entitlement or {}).get("ends_at")),
        )

    @staticmethod
    def _require_verified(user: dict[str, Any]) -> None:
        if user.get("email_verified") is not True:
            raise PermissionDeniedError("Verify your email before you create or claim a gift")

    @staticmethod
    def _normalized_user_email(user: dict[str, Any]) -> str:
        email = str(user.get("email") or "").strip().lower()
        if not email:
            raise PermissionDeniedError("A verified email is required for this gift")
        return email

    @classmethod
    def _require_recipient_match(cls, user: dict[str, Any], voucher: dict[str, Any]) -> None:
        """Require the named recipient while leaving legacy link gifts valid."""
        recipient_email = str(voucher.get("recipient_email") or "").strip().lower()
        if recipient_email:
            user_email = cls._normalized_user_email(user)
            if not hmac.compare_digest(
                recipient_email.encode("utf-8"),
                user_email.encode("utf-8"),
            ):
                raise ValidationError("This gift is reserved for another verified account")

    @staticmethod
    def _matches_issuance_request(
        voucher: dict[str, Any],
        request: ComplimentaryGiftCreate | PaidGiftCheckoutCreate,
        *,
        source: str,
    ) -> bool:
        stored_message = str(voucher.get("message") or "").strip() or None
        stored_occasion = str(voucher.get("occasion") or "").strip() or None
        stored_occasion_greeting = str(voucher.get("occasion_greeting") or "").strip() or None
        request_occasion = request.occasion.value if request.occasion else None
        return (
            voucher.get("source") == source
            and int(voucher.get("duration_months") or 0) == request.duration_months
            and str(voucher.get("from_name") or "").strip() == request.from_name
            and str(voucher.get("to_name") or "").strip() == request.to_name
            and str(voucher.get("recipient_email") or "").strip().lower() == request.recipient_email
            and stored_message == request.message
            and stored_occasion == request_occasion
            and stored_occasion_greeting == request.occasion_greeting
        )

    @classmethod
    async def _existing_paid_checkout_response(
        cls,
        voucher: dict[str, Any],
    ) -> Optional[dict[str, Any]]:
        session_id = voucher.get("stripe_checkout_session_id")
        if not session_id:
            return None
        stripe.api_key = settings.STRIPE_SECRET_KEY
        session = await asyncio.to_thread(stripe.checkout.Session.retrieve, session_id)
        return {
            "checkout_url": _value(session, "url"),
            "session_id": session_id,
            "voucher": cls.serialize(voucher, audience="owner").model_dump(mode="json"),
        }

    @classmethod
    async def get_allowances(cls, user: dict[str, Any], db: Client) -> list[GiftAllowance]:
        cls._require_verified(user)
        try:
            result = await asyncio.to_thread(db.rpc("initialize_gift_allowances", {"user_uuid": user["id"]}).execute)
        except Exception as exc:
            raise DatabaseError("Gift voucher allowances are unavailable. Apply migration 056.") from exc
        return [
            GiftAllowance(
                duration_months=int(row["duration_months"]),
                granted_count=int(row["granted_count"]),
                used_count=int(row["used_count"]),
                remaining_count=max(0, int(row["granted_count"]) - int(row["used_count"])),
            )
            for row in sorted(_rows(result), key=lambda item: int(item["duration_months"]))
        ]

    @classmethod
    async def create_complimentary(
        cls,
        user: dict[str, Any],
        request: ComplimentaryGiftCreate,
        db: Client,
    ) -> GiftVoucherResponse:
        cls._require_verified(user)
        if not settings.ENABLE_GIFT_VOUCHER_CREATION:
            raise PermissionDeniedError("Gift voucher creation is not enabled")
        now = utcnow()
        params = {
            "p_voucher_id": str(uuid4()),
            "p_public_id": str(uuid4()),
            "p_user_id": str(user["id"]),
            "p_duration_months": request.duration_months,
            "p_retail_value_cents": CATALOG[request.duration_months],
            "p_from_name": request.from_name,
            "p_to_name": request.to_name,
            "p_recipient_email": request.recipient_email,
            "p_message": request.message or "",
            "p_occasion": request.occasion.value if request.occasion else None,
            "p_occasion_greeting": request.occasion_greeting or "",
            "p_client_request_id": request.client_request_id,
            "p_expires_at": (now + relativedelta(months=6)).isoformat(),
        }
        try:
            result = await asyncio.to_thread(db.rpc("issue_complimentary_gift_for_recipient", params).execute)
        except Exception as exc:
            raise DatabaseError("Failed to create the complimentary gift") from exc
        rows = _rows(result)
        if not rows:
            raise ValidationError("No complimentary gift slots remain for this duration")
        voucher = rows[0]
        if not cls._matches_issuance_request(voucher, request, source="complimentary"):
            raise ValidationError("This request key was already used")
        return cls.serialize(voucher, audience="owner")

    @staticmethod
    def _absolute_frontend_url(value: str) -> str:
        base = settings.FRONTEND_URL.rstrip("/")
        if value.startswith("/"):
            return f"{base}{value}"
        candidate = urlparse(value)
        allowed = urlparse(base)
        if candidate.scheme == allowed.scheme and candidate.netloc == allowed.netloc:
            return value
        raise ValidationError("Checkout return URLs must use the FitCheck web app")

    @classmethod
    async def _find_owner_request(cls, user_id: str, client_request_id: str, db: Client) -> Optional[dict[str, Any]]:
        result = await asyncio.to_thread(
            db.table("gift_vouchers")
            .select("*")
            .eq("purchaser_user_id", user_id)
            .eq("client_request_id", client_request_id)
            .maybe_single()
            .execute
        )
        rows = _rows(result)
        return rows[0] if rows else None

    @classmethod
    async def create_paid_checkout(
        cls,
        user: dict[str, Any],
        request: PaidGiftCheckoutCreate,
        db: Client,
    ) -> dict[str, Any]:
        cls._require_verified(user)
        if not settings.ENABLE_GIFT_VOUCHER_CREATION:
            raise PermissionDeniedError("Gift voucher creation is not enabled")
        price_id = cls.price_id_map().get(request.duration_months)
        if not settings.STRIPE_SECRET_KEY or not price_id:
            raise BillingNotConfiguredError("Paid gift vouchers are not configured")

        existing = await cls._find_owner_request(str(user["id"]), request.client_request_id, db)
        if existing:
            if not cls._matches_issuance_request(existing, request, source="paid"):
                raise ValidationError("This request key was already used")
            existing_response = await cls._existing_paid_checkout_response(existing)
            if existing_response:
                return existing_response
            voucher = existing
        else:
            voucher = {
                "id": str(uuid4()),
                "public_id": str(uuid4()),
                "purchaser_user_id": str(user["id"]),
                "source": "paid",
                "duration_months": request.duration_months,
                "retail_value_cents": CATALOG[request.duration_months],
                "currency": "USD",
                "from_name": request.from_name,
                "to_name": request.to_name,
                "recipient_email": request.recipient_email,
                "message": request.message,
                "occasion": request.occasion.value if request.occasion else None,
                "occasion_greeting": request.occasion_greeting,
                "status": "pending",
                "payment_status": "pending",
                "client_request_id": request.client_request_id,
            }
            try:
                inserted = await asyncio.to_thread(db.table("gift_vouchers").insert(voucher).execute)
                voucher = _rows(inserted)[0]
            except Exception as exc:
                # A concurrent retry can win the unique owner/request key.
                existing = await cls._find_owner_request(str(user["id"]), request.client_request_id, db)
                if not existing:
                    raise DatabaseError("Failed to reserve the gift checkout") from exc
                if not cls._matches_issuance_request(existing, request, source="paid"):
                    raise ValidationError("This request key was already used") from exc
                existing_response = await cls._existing_paid_checkout_response(existing)
                if existing_response:
                    return existing_response
                voucher = existing

        stripe.api_key = settings.STRIPE_SECRET_KEY
        metadata = {
            "purchase_kind": "gift_voucher",
            "voucher_id": str(voucher["id"]),
            "purchaser_user_id": str(user["id"]),
            "duration_months": str(request.duration_months),
        }
        create_args: dict[str, Any] = {
            "payment_method_types": ["card"],
            "line_items": [{"price": price_id, "quantity": 1}],
            "mode": "payment",
            "success_url": cls._absolute_frontend_url(request.success_url),
            "cancel_url": cls._absolute_frontend_url(request.cancel_url),
            "metadata": metadata,
            "payment_intent_data": {"metadata": metadata},
            "client_reference_id": str(voucher["id"]),
        }
        subscription = await asyncio.to_thread(
            db.table("subscriptions").select("stripe_customer_id").eq("user_id", user["id"]).maybe_single().execute
        )
        subscription_rows = _rows(subscription)
        customer_id = subscription_rows[0].get("stripe_customer_id") if subscription_rows else None
        if customer_id:
            create_args["customer"] = customer_id
        else:
            create_args["customer_email"] = user.get("email")

        try:
            session = await asyncio.to_thread(
                stripe.checkout.Session.create,
                **create_args,
                idempotency_key=f"gift:{user['id']}:{request.client_request_id}",
            )
        except stripe.error.StripeError as exc:
            raise ServiceError("Payment checkout could not be created", service_name="stripe") from exc

        session_id = _value(session, "id")
        update = await asyncio.to_thread(
            db.table("gift_vouchers")
            .update({"stripe_checkout_session_id": session_id, "updated_at": utcnow_iso()})
            .eq("id", voucher["id"])
            .eq("status", "pending")
            .execute
        )
        updated = _rows(update)
        if updated:
            voucher = updated[0]
        return {
            "checkout_url": _value(session, "url"),
            "session_id": session_id,
            "voucher": cls.serialize(voucher, audience="owner").model_dump(mode="json"),
        }

    @classmethod
    async def fulfill_checkout(
        cls,
        session_or_id: object,
        db: Client,
        *,
        expected_user_id: Optional[str] = None,
    ) -> GiftVoucherResponse:
        if not settings.STRIPE_SECRET_KEY:
            raise BillingNotConfiguredError("Paid gift vouchers are not configured")
        stripe.api_key = settings.STRIPE_SECRET_KEY
        session_id = session_or_id if isinstance(session_or_id, str) else _value(session_or_id, "id")
        try:
            session = await asyncio.to_thread(
                stripe.checkout.Session.retrieve,
                session_id,
                expand=["line_items.data.price"],
            )
        except stripe.error.StripeError as exc:
            raise ServiceError("Payment confirmation is unavailable", service_name="stripe") from exc

        metadata = _value(session, "metadata", {}) or {}
        voucher_id = _value(metadata, "voucher_id")
        owner_id = _value(metadata, "purchaser_user_id")
        if _value(metadata, "purchase_kind") != "gift_voucher" or not voucher_id or not owner_id:
            raise ValidationError("This checkout does not contain a gift voucher")
        if expected_user_id and str(owner_id) != str(expected_user_id):
            raise PermissionDeniedError("This checkout belongs to another account")

        result = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("id", voucher_id).maybe_single().execute
        )
        rows = _rows(result)
        if not rows:
            raise NotFoundError("Gift voucher not found", "gift_voucher", str(voucher_id))
        voucher = rows[0]
        if str(voucher.get("purchaser_user_id")) != str(owner_id) or voucher.get("source") != "paid":
            raise ValidationError("Gift checkout ownership verification failed")
        reserved_session_id = voucher.get("stripe_checkout_session_id")
        if reserved_session_id and str(reserved_session_id) != str(session_id):
            raise ValidationError("Gift checkout session verification failed")
        if voucher.get("payment_status") == "paid" and voucher.get("status") in {"issued", "claimed"}:
            return cls.serialize(voucher, audience="owner")
        if _value(session, "payment_status") != "paid":
            raise ValidationError("The payment has not completed")

        line_items = _value(_value(session, "line_items", {}), "data", []) or []
        first_line = line_items[0] if line_items else None
        price = _value(first_line, "price", {}) if first_line else {}
        price_id = price if isinstance(price, str) else _value(price, "id")
        expected_price = cls.price_id_map().get(int(voucher["duration_months"]))
        expected_amount = CATALOG[int(voucher["duration_months"])]
        if (
            _value(session, "mode") != "payment"
            or str(_value(metadata, "duration_months", "")) != str(voucher["duration_months"])
            or len(line_items) != 1
            or int(_value(first_line, "quantity", 0)) != 1
            or not expected_price
            or price_id != expected_price
            or int(_value(session, "amount_total", -1)) != expected_amount
            or str(_value(session, "currency", "")).lower() != "usd"
            or str(_value(session, "client_reference_id", "")) != str(voucher["id"])
        ):
            raise ValidationError("Gift checkout value verification failed")

        payment_intent = _value(session, "payment_intent")
        if not isinstance(payment_intent, str):
            payment_intent = _value(payment_intent, "id")
        if not payment_intent:
            raise ValidationError("Gift checkout payment verification failed")
        payload = {
            "status": "issued",
            "payment_status": "paid",
            "issued_at": utcnow_iso(),
            "payment_completed_at": utcnow_iso(),
            "stripe_checkout_session_id": session_id,
            "stripe_payment_intent_id": payment_intent,
            "stripe_customer_id": _value(session, "customer"),
            "amount_paid_cents": expected_amount,
            "amount_refunded_cents": 0,
            "payment_failure_reason": None,
            "updated_at": utcnow_iso(),
        }
        update = await asyncio.to_thread(
            db.table("gift_vouchers")
            .update(payload)
            .eq("id", voucher["id"])
            .in_("payment_status", ["pending", "failed"])
            .execute
        )
        updated = _rows(update)
        if updated:
            voucher = updated[0]
        else:
            reread = await asyncio.to_thread(
                db.table("gift_vouchers").select("*").eq("id", voucher["id"]).single().execute
            )
            voucher = _rows(reread)[0]
        return cls.serialize(voucher, audience="owner")

    @classmethod
    async def mark_checkout_failed(cls, session: object, db: Client, *, reason: str) -> None:
        metadata = _value(session, "metadata", {}) or {}
        if _value(metadata, "purchase_kind") != "gift_voucher":
            return
        voucher_id = _value(metadata, "voucher_id")
        if not voucher_id:
            return
        await asyncio.to_thread(
            db.table("gift_vouchers")
            .update(
                {
                    "status": "payment_failed",
                    "payment_status": "failed",
                    "payment_failure_reason": reason[:500],
                    "updated_at": utcnow_iso(),
                }
            )
            .eq("id", voucher_id)
            .eq("status", "pending")
            .execute
        )

    @classmethod
    async def process_payment_event(cls, event_type: str, obj: object, db: Client) -> None:
        """Apply external refunds and final dispute outcomes to paid value."""
        metadata = _value(obj, "metadata", {}) or {}
        is_gift_payment = _value(metadata, "purchase_kind") == "gift_voucher"
        payment_intent = _value(obj, "payment_intent")
        if not isinstance(payment_intent, str):
            payment_intent = _value(payment_intent, "id")
        charge = _value(obj, "charge")
        if charge and (not payment_intent or not is_gift_payment):
            try:
                charge_obj = charge
                if isinstance(charge, str):
                    stripe.api_key = settings.STRIPE_SECRET_KEY
                    charge_obj = await asyncio.to_thread(stripe.Charge.retrieve, charge)
                if not payment_intent:
                    payment_intent = _value(charge_obj, "payment_intent")
                    if not isinstance(payment_intent, str):
                        payment_intent = _value(payment_intent, "id")
                charge_metadata = _value(charge_obj, "metadata", {}) or {}
                is_gift_payment = is_gift_payment or _value(charge_metadata, "purchase_kind") == "gift_voucher"
            except stripe.error.StripeError as exc:
                if is_gift_payment:
                    raise ServiceError(
                        "Gift payment event could not be linked to checkout",
                        service_name="stripe",
                    ) from exc
                return
        if not payment_intent:
            if is_gift_payment:
                raise ServiceError(
                    "Gift payment event arrived before checkout fulfillment",
                    service_name="stripe",
                )
            return
        lookup = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("stripe_payment_intent_id", payment_intent).maybe_single().execute
        )
        rows = _rows(lookup)
        if not rows:
            if is_gift_payment:
                # Checkout fulfillment writes the payment intent link. Do not
                # acknowledge an earlier refund or dispute, or Stripe will
                # never redeliver it after fulfillment catches up.
                raise ServiceError(
                    "Gift payment event arrived before checkout fulfillment",
                    service_name="stripe",
                )
            return
        voucher = rows[0]

        if event_type == "charge.dispute.created":
            await asyncio.to_thread(
                db.table("gift_vouchers")
                .update({"payment_status": "review", "updated_at": utcnow_iso()})
                .eq("id", voucher["id"])
                .execute
            )
            return
        dispute_status = str(_value(obj, "status", ""))
        if event_type == "charge.dispute.closed" and dispute_status in {
            "won",
            "warning_closed",
            "prevented",
        }:
            restored_state = "partially_refunded" if int(voucher.get("amount_refunded_cents") or 0) > 0 else "paid"
            await asyncio.to_thread(
                db.table("gift_vouchers")
                .update({"payment_status": restored_state, "updated_at": utcnow_iso()})
                .eq("id", voucher["id"])
                .execute
            )
            return

        is_refund = event_type == "charge.refunded"
        is_lost_dispute = event_type == "charge.dispute.closed" and dispute_status == "lost"
        if not (is_refund or is_lost_dispute):
            return

        if is_refund:
            amount = int(_value(obj, "amount", voucher.get("amount_paid_cents") or 0) or 0)
            amount_refunded = int(_value(obj, "amount_refunded", 0) or 0)
            fully_refunded = bool(_value(obj, "refunded", False)) or (amount > 0 and amount_refunded >= amount)
            if not fully_refunded:
                await asyncio.to_thread(
                    db.table("gift_vouchers")
                    .update(
                        {
                            "payment_status": "partially_refunded",
                            "amount_refunded_cents": amount_refunded,
                            "updated_at": utcnow_iso(),
                        }
                    )
                    .eq("id", voucher["id"])
                    .execute
                )
                return

        lifecycle = "revoked" if voucher.get("status") == "claimed" else "voided"
        payment_state = "refunded" if is_refund else "disputed"
        update_payload: dict[str, Any] = {
            "status": lifecycle,
            "payment_status": payment_state,
            "updated_at": utcnow_iso(),
        }
        if is_refund:
            update_payload["amount_refunded_cents"] = int(
                _value(obj, "amount_refunded", voucher.get("amount_paid_cents") or 0) or 0
            )
        await asyncio.to_thread(db.table("gift_vouchers").update(update_payload).eq("id", voucher["id"]).execute)
        await asyncio.to_thread(
            db.table("gift_entitlement_grants")
            .update(
                {
                    "status": "revoked",
                    "revoked_at": utcnow_iso(),
                    "revoke_reason": "external_refund" if is_refund else "lost_dispute",
                    "updated_at": utcnow_iso(),
                }
            )
            .eq("voucher_id", voucher["id"])
            .in_("status", ["queued", "active"])
            .execute
        )

    @classmethod
    async def get_public(cls, public_id: str, db: Client) -> GiftVoucherResponse:
        result = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("public_id", public_id).maybe_single().execute
        )
        rows = _rows(result)
        if not rows:
            raise NotFoundError("Gift voucher not found", "gift_voucher", public_id)
        return cls.serialize(rows[0], audience="public")

    @classmethod
    async def get_owned(cls, voucher_id: str, user_id: str, db: Client) -> dict[str, Any]:
        result = await asyncio.to_thread(
            db.table("gift_vouchers")
            .select("*")
            .eq("id", voucher_id)
            .eq("purchaser_user_id", user_id)
            .maybe_single()
            .execute
        )
        rows = _rows(result)
        if not rows:
            raise NotFoundError("Gift voucher not found", "gift_voucher", voucher_id)
        return rows[0]

    @classmethod
    async def list_for_user(
        cls,
        user_id: str,
        db: Client,
        *,
        received: bool,
        page: int,
        page_size: int,
    ) -> GiftListResponse:
        field = "claimed_by_user_id" if received else "purchaser_user_id"
        offset = (page - 1) * page_size
        result = await asyncio.to_thread(
            db.table("gift_vouchers")
            .select("*", count="exact")
            .eq(field, user_id)
            .order("created_at", desc=True)
            .range(offset, offset + page_size - 1)
            .execute
        )
        vouchers = _rows(result)
        entitlements: dict[str, dict[str, Any]] = {}
        if received and vouchers:
            grant_result = await asyncio.to_thread(
                db.table("gift_entitlement_grants")
                .select("voucher_id,status,started_at,ends_at")
                .in_("voucher_id", [voucher["id"] for voucher in vouchers])
                .execute
            )
            entitlements = {str(grant["voucher_id"]): grant for grant in _rows(grant_result) if grant.get("voucher_id")}

        items: list[GiftVoucherResponse] = []
        for voucher in vouchers:
            entitlement = entitlements.get(str(voucher["id"]))
            items.append(
                cls.serialize(
                    voucher,
                    audience="recipient" if received else "owner",
                    entitlement=entitlement,
                )
            )
        return GiftListResponse(
            items=items,
            total=int(getattr(result, "count", None) or len(items)),
            page=page,
            page_size=page_size,
        )

    @classmethod
    async def get_dashboard_summary(
        cls,
        user: dict[str, Any],
        db: Client,
    ) -> GiftDashboardSummary:
        """Return only private, claimable gifts assigned to the signed-in email."""
        cls._require_verified(user)
        recipient_email = cls._normalized_user_email(user)
        now = utcnow()
        allowances, incoming_result = await asyncio.gather(
            cls.get_allowances(user, db),
            asyncio.to_thread(
                db.table("gift_vouchers")
                .select("*")
                .eq("recipient_email", recipient_email)
                .eq("status", "issued")
                .or_(f"expires_at.is.null,expires_at.gt.{now.isoformat()}")
                .order("created_at", desc=True)
                .execute
            ),
        )
        incoming = [
            cls.serialize(row, audience="recipient")
            for row in _rows(incoming_result)
            # `purchaser_user_id` becomes NULL if the sender account is
            # deleted. Filtering it in SQL with `neq` would hide a gift that
            # the claim RPC still accepts, so exclude only the current user
            # after reading the recipient-indexed result.
            if str(row.get("purchaser_user_id") or "") != str(user["id"])
            and ((expires_at := parse_utc_datetime(row.get("expires_at"))) is None or expires_at > now)
        ]
        return GiftDashboardSummary(allowances=allowances, incoming=incoming)

    @classmethod
    async def update_presentation(
        cls, voucher_id: str, user_id: str, request: GiftUpdate, db: Client
    ) -> GiftVoucherResponse:
        voucher = await cls.get_owned(voucher_id, user_id, db)
        if voucher.get("status") != "issued":
            raise ValidationError("Only an unclaimed gift can be edited")
        payload = presentation_payload(voucher, request)
        payload["artwork_version"] = int(voucher.get("artwork_version") or 1) + 1
        payload["updated_at"] = utcnow_iso()
        result = await asyncio.to_thread(
            db.table("gift_vouchers").update(payload).eq("id", voucher_id).eq("status", "issued").execute
        )
        rows = _rows(result)
        if not rows:
            raise ValidationError("The gift was claimed while it was being edited")
        return cls.serialize(rows[0], audience="owner")

    @classmethod
    async def rotate_link(cls, voucher_id: str, user_id: str, db: Client) -> GiftVoucherResponse:
        voucher = await cls.get_owned(voucher_id, user_id, db)
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
            raise ValidationError("The gift was claimed while its link was being rotated")
        return cls.serialize(rows[0], audience="owner")

    @classmethod
    async def claim(
        cls,
        user: dict[str, Any],
        public_id: UUID,
        credential: str,
        db: Client,
    ) -> GiftClaimResponse:
        cls._require_verified(user)
        lookup = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("public_id", str(public_id)).maybe_single().execute
        )
        rows = _rows(lookup)
        if not rows:
            raise ValidationError("The voucher code is invalid")
        voucher = rows[0]
        if not cls.credential_matches(voucher, credential):
            raise ValidationError("The voucher code is invalid")
        cls._require_recipient_match(user, voucher)
        return await cls._claim_voucher(user, voucher, db)

    @classmethod
    async def claim_assigned(
        cls,
        user: dict[str, Any],
        voucher_id: UUID,
        db: Client,
    ) -> GiftClaimResponse:
        """Claim a named incoming gift without exposing its link credential."""
        cls._require_verified(user)
        lookup = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("id", str(voucher_id)).maybe_single().execute
        )
        rows = _rows(lookup)
        if not rows:
            raise ValidationError("No claimable gift was found")
        voucher = rows[0]
        if not voucher.get("recipient_email"):
            raise ValidationError("Use this gift's private link to claim it")
        cls._require_recipient_match(user, voucher)
        return await cls._claim_voucher(user, voucher, db)

    @classmethod
    async def _claim_voucher(
        cls,
        user: dict[str, Any],
        voucher: dict[str, Any],
        db: Client,
    ) -> GiftClaimResponse:
        if str(voucher.get("purchaser_user_id")) == str(user["id"]):
            raise ValidationError("You cannot claim a gift that you created")
        if voucher.get("status") != "issued":
            raise ValidationError(cls._claim_state_message(voucher))
        expiry = parse_utc_datetime(voucher.get("expires_at"))
        if expiry and expiry <= utcnow():
            await asyncio.to_thread(
                db.table("gift_vouchers")
                .update({"status": "expired"})
                .eq("id", voucher["id"])
                .eq("status", "issued")
                .execute
            )
            raise ValidationError("This promotional gift has expired")

        result = await asyncio.to_thread(
            db.rpc(
                "claim_gift_voucher",
                {
                    "p_voucher_id": str(voucher["id"]),
                    "p_user_id": str(user["id"]),
                    "p_now": utcnow_iso(),
                },
            ).execute
        )
        claimed = _rows(result)
        if not claimed:
            current = await asyncio.to_thread(
                db.table("gift_vouchers").select("status,expires_at").eq("id", voucher["id"]).single().execute
            )
            current_rows = _rows(current)
            raise ValidationError(cls._claim_state_message(current_rows[0] if current_rows else voucher))

        from app.services.subscription_service import SubscriptionService

        base = await SubscriptionService.get_subscription(str(user["id"]), db, include_gifts=False)
        resolved = await cls.resolve_entitlements(str(user["id"]), base, db)
        grant = await asyncio.to_thread(
            db.table("gift_entitlement_grants")
            .select("status,started_at,ends_at")
            .eq("voucher_id", voucher["id"])
            .single()
            .execute
        )
        grant_rows = _rows(grant)
        entitlement = grant_rows[0] if grant_rows else {"status": "queued"}
        status = "active" if entitlement.get("status") == "active" else "queued"
        return GiftClaimResponse(
            voucher=cls.serialize(claimed[0], audience="recipient", entitlement=entitlement),
            entitlement_status=status,
            active_ends_at=parse_utc_datetime(entitlement.get("ends_at")),
            queued_count=int(resolved.get("queued_count") or 0),
            queued_months=int(resolved.get("queued_months") or 0),
        )

    @staticmethod
    def _claim_state_message(voucher: dict[str, Any]) -> str:
        status = voucher.get("status")
        if status == "claimed":
            return "This gift has already been claimed"
        if status == "expired":
            return "This promotional gift has expired"
        if status in {"voided", "revoked"}:
            return "This gift is no longer valid"
        return "This gift is not ready to claim"

    @classmethod
    async def resolve_entitlements(cls, user_id: str, base: SubscriptionResponse, db: Client) -> dict[str, Any]:
        base_pro_active = base.plan_type in {PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY}
        try:
            result = await asyncio.to_thread(
                db.rpc(
                    "resolve_gift_entitlements",
                    {
                        "p_user_id": user_id,
                        "p_base_pro_active": base_pro_active,
                        "p_now": utcnow_iso(),
                    },
                ).execute
            )
        except Exception as exc:
            # A gift migration should fail readiness before traffic. Preserve
            # subscription reads during a staged deploy where code arrives first.
            logger.warning("Gift entitlement resolver unavailable", user_id=user_id, error=str(exc))
            return {"active_grant_id": None, "active_ends_at": None, "queued_count": 0, "queued_months": 0}
        rows = _rows(result)
        return (
            rows[0]
            if rows
            else {"active_grant_id": None, "active_ends_at": None, "queued_count": 0, "queued_months": 0}
        )

    @classmethod
    async def overlay_subscription(cls, user_id: str, base: SubscriptionResponse, db: Client) -> SubscriptionResponse:
        resolved = await cls.resolve_entitlements(user_id, base, db)
        active_end = parse_utc_datetime(resolved.get("active_ends_at"))
        queued_count = int(resolved.get("queued_count") or 0)
        queued_months = int(resolved.get("queued_months") or 0)
        updates: dict[str, Any] = {
            "entitlement_source": "subscription" if base.plan_type != PlanType.FREE else "free",
            "active_gift_ends_at": active_end,
            "queued_gift_count": queued_count,
            "queued_gift_months": queued_months,
        }
        if active_end:
            updates.update(
                {
                    "plan_type": PlanType.PRO_MONTHLY,
                    "status": SubscriptionStatus.ACTIVE,
                    "current_period_end": active_end,
                    "is_pro": True,
                    "entitlement_source": "gift",
                }
            )
        return base.model_copy(update=updates)

    @classmethod
    async def portrait_artwork(cls, voucher_id: str, user_id: str, db: Client) -> bytes:
        voucher = await cls.get_owned(voucher_id, user_id, db)
        return await GiftArtworkService.get_or_render(voucher, variant="portrait")

    @classmethod
    async def public_artwork(cls, public_id: str, db: Client) -> bytes:
        lookup = await asyncio.to_thread(
            db.table("gift_vouchers").select("*").eq("public_id", public_id).maybe_single().execute
        )
        rows = _rows(lookup)
        if not rows:
            raise NotFoundError("Gift voucher not found", "gift_voucher", public_id)
        return await GiftArtworkService.get_or_render(rows[0], variant="og")
