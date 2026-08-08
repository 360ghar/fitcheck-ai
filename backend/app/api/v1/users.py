"""
User API routes.

Implements:
- GET/PUT /api/v1/users/me
- DELETE /api/v1/users/me (account deletion)
- POST /api/v1/users/export (data export archive)
- GET/PUT /api/v1/users/preferences
- GET/PUT /api/v1/users/settings
- GET/PUT /api/v1/users/body-profile
- POST /api/v1/users/me/avatar (upload)
- GET /api/v1/users/dashboard (MVP aggregate)
"""

import asyncio
import json
import uuid
import re
from app.utils.datetime_util import utcnow, utcnow_iso
from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID

from fastapi import APIRouter, Depends, File, UploadFile, status
from supabase import Client

from app.core.exceptions import (
    BodyProfileNotFoundError,
    DatabaseError,
    StorageServiceError,
    UnsupportedMediaTypeError,
    UserNotFoundError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.api.v1.deps import get_active_user_id
from app.core.uploads import read_upload_capped
from app.db.connection import get_db
from app.utils import maybe_single_data
from app.utils.db import execute_with_reconnect, run_sync_with_reconnect
from app.models.user import (
    BodyProfile,
    BodyProfileCreate,
    BodyProfileUpdate,
    UserPreferences,
    UserPreferencesUpdate,
    UserResponse,
    UserSettings,
    UserSettingsUpdate,
    UserUpdate,
)
from app.services.storage_service import MAX_FILE_SIZE, StorageService
from app.services.vector_service import get_vector_service
from app.services.weather_service import get_weather_service
from app.api.v1.images import materialize_avatar_url, materialize_image_urls

logger = get_context_logger(__name__)

router = APIRouter()


def _now() -> str:
    return utcnow_iso()


def _extract_missing_users_column(err: Exception) -> Optional[str]:
    """Return missing users.<column> name when Postgres reports undefined column."""
    code = getattr(err, "code", None)
    text = str(err).lower()
    has_missing_column_signal = (
        code in {"42703", "PGRST204"}
        or "42703" in text
        or "could not find the" in text
        or "column users." in text
    )
    if not has_missing_column_signal:
        return None

    match = re.search(r"column\s+users\.([a-z0-9_]+)\s+does\s+not\s+exist", text)
    if match:
        return match.group(1)
    match = re.search(r"could\s+not\s+find\s+the\s+'([a-z0-9_]+)'\s+column\s+of\s+'users'", text)
    if match:
        return match.group(1)
    return None


def _extract_birth_patch(payload: Dict[str, Any]) -> Dict[str, Any]:
    return {field: payload[field] for field in ("birth_date", "birth_time", "birth_place") if field in payload}


def _normalize_user_birth_fields(row: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize user row for response. birth_date is the canonical field."""
    return dict(row or {})


def _get_auth_user_metadata(db: Client, user_id: str) -> Dict[str, Any]:
    try:
        admin = getattr(db.auth, "admin", None)
        if not admin or not hasattr(admin, "get_user_by_id"):
            return {}
        auth_user = admin.get_user_by_id(user_id)
        if auth_user and getattr(auth_user, "user", None):
            return dict(getattr(auth_user.user, "user_metadata", {}) or {})
    except Exception:
        return {}
    return {}


def _update_auth_user_metadata(db: Client, user_id: str, patch: Dict[str, Any]) -> None:
    if not patch:
        return
    admin = getattr(db.auth, "admin", None)
    if not admin or not hasattr(admin, "update_user_by_id"):
        return
    merged = _get_auth_user_metadata(db, user_id)
    merged.update(patch)
    admin.update_user_by_id(user_id, {"user_metadata": merged})


def _handle_db_error(
    operation: str,
    user_id: str,
    error: Exception,
    extra_context: Optional[Dict[str, Any]] = None,
) -> None:
    """Log error and raise standardized DatabaseError."""
    context = {"user_id": user_id, "error": str(error)}
    if extra_context:
        context.update(extra_context)
    logger.error(f"Failed to {operation}", **context)
    raise DatabaseError(f"Failed to {operation}")


def _first_row(result_data: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """Extract first row from query result."""
    return (result_data or [None])[0] if result_data else None


T = Dict[str, Any]


def _get_or_create_record(
    db: Client,
    table: str,
    user_id: str,
    defaults: Dict[str, Any],
    model_class: Any,
) -> Tuple[Dict[str, Any], bool]:
    """
    Get existing record or create with defaults.
    Returns (record_data, was_created).
    """
    # Read side rebuilds + retries once on a dead pooled Supabase connection
    # (ConnectionTerminated 500s on GET /users/settings 2026-08-03). The
    # insert goes through the same wrapper: `user_id` is the PK (migration
    # 001), so the upsert is exact-once — a lost response after a committed
    # insert collapses onto the existing row instead of duplicating or 500ing
    # on the stale dead client.
    result = run_sync_with_reconnect(
        lambda d: d.table(table).select("*").eq("user_id", user_id).execute(),
        db,
        extra={"operation": f"get_or_create_{table}", "user_id": user_id},
    )
    if result.data:
        return model_class.model_validate(result.data[0]).model_dump(mode="json"), False

    insert_defaults = {**defaults, "user_id": user_id}
    run_sync_with_reconnect(
        lambda d: d.table(table)
        .upsert(insert_defaults, on_conflict="user_id", ignore_duplicates=True)
        .execute(),
        db,
        extra={"operation": f"create_{table}", "user_id": user_id},
    )
    # Re-read so the returned row reflects the actual stored record (a
    # concurrent create could have won the upsert with different values).
    result = run_sync_with_reconnect(
        lambda d: d.table(table).select("*").eq("user_id", user_id).execute(),
        db,
        extra={"operation": f"get_or_create_{table}_reload", "user_id": user_id},
    )
    row = _first_row(result.data or [])
    if not row:
        raise DatabaseError(f"Failed to create {table}")
    return model_class.model_validate(row).model_dump(mode="json"), True


def _upsert_record(
    db: Client,
    table: str,
    user_id: str,
    update_data: Any,
    model_class: Any,
    defaults: Optional[Dict[str, Any]] = None,
    *,
    updated_field: Optional[str] = "updated_at",
    created_field: Optional[str] = "created_at",
) -> Dict[str, Any]:
    """
    Upsert a record for user: update if exists, insert if not.
    Returns validated record data.
    """
    update_dict = update_data.model_dump(exclude_unset=True)
    if updated_field:
        update_dict[updated_field] = _now()

    existing = run_sync_with_reconnect(
        lambda d: d.table(table).select("user_id").eq("user_id", user_id).execute(),
        db,
        extra={"operation": f"upsert_{table}_lookup", "user_id": user_id},
    )

    if existing.data:
        result = run_sync_with_reconnect(
            lambda d: d.table(table).update(update_dict).eq("user_id", user_id).execute(),
            db,
            extra={"operation": f"upsert_{table}_update", "user_id": user_id},
        )
    else:
        insert = {
            "user_id": user_id,
            **(defaults or {}),
            **update_dict,
        }
        if created_field:
            insert[created_field] = _now()
        if updated_field:
            insert[updated_field] = _now()
        # Same reconnect treatment as the update branch: the insert is an
        # upsert on the user_id PK, so a retry after a lost response
        # collapses onto the existing row (exact-once) instead of running on
        # the stale dead client.
        result = run_sync_with_reconnect(
            lambda d: d.table(table)
            .upsert(insert, on_conflict="user_id")
            .execute(),
            db,
            extra={"operation": f"upsert_{table}_insert", "user_id": user_id},
        )

    row = _first_row(result.data or [])
    if not row:
        raise DatabaseError(f"Failed to update {table}")
    return model_class.model_validate(row).model_dump(mode="json")


def _sync_birth_fields_to_auth(
    db: Client,
    user_id: str,
    birth_patch: Dict[str, Any],
) -> None:
    """Sync birth fields to auth metadata with error logging."""
    if not birth_patch:
        return
    try:
        _update_auth_user_metadata(db, user_id, birth_patch)
    except Exception as metadata_error:
        logger.warning(
            "Failed to sync birth fields to auth metadata",
            user_id=user_id,
            error=str(metadata_error),
        )


# ============================================================================
# PROFILE
# ============================================================================


@router.get("/me", response_model=Dict[str, Any])
async def get_current_user(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", user_id).execute(),
            db,
            extra={"operation": "get_current_user", "user_id": user_id},
            max_retries=2,
        )
        if not result.data:
            raise UserNotFoundError(user_id=user_id)

        user = UserResponse.model_validate(_normalize_user_birth_fields(result.data[0]))
        user_data = user.model_dump(mode="json")

        # Fallback for projects that haven't applied astrology profile migration yet.
        if not all(user_data.get(field) for field in ("birth_date", "birth_time", "birth_place")):
            meta = _get_auth_user_metadata(db, user_id)
            for field in ("birth_date", "birth_time", "birth_place"):
                if not user_data.get(field):
                    user_data[field] = meta.get(field)

        # Regenerate a fresh avatar URL at read time. The DB stores a bucket
        # key, a presigned URL (expires after OBJECT_STORAGE_PRESIGN_TTL), a
        # legacy Supabase public URL — or an EXTERNAL https URL (OAuth
        # provider picture). Only our own objects are re-materialized; an
        # external URL must pass through untouched, never be reduced to a
        # bucket key and presigned/minted (key_from_path would mangle
        # e.g. https://lh3.googleusercontent.com/a/... into a bogus key).
        # The UUID first-segment guard lives in materialize_avatar_url (images.py)
        # so this, ai.py and the leaderboard share one implementation.
        avatar_url = user_data.get("avatar_url")
        if avatar_url:
            try:
                fresh = await materialize_avatar_url(avatar_url)
                if fresh:
                    user_data["avatar_url"] = fresh
            except Exception as e:
                logger.warning("Failed to materialize avatar URL", user_id=user_id, error=str(e))

        return {"data": user_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch user", user_id, e)


@router.put("/me", response_model=Dict[str, Any])
async def update_current_user(
    update_data: UserUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        update_dict = update_data.model_dump(mode="json", exclude_unset=True)
        if not update_dict:
            return await get_current_user(user_id=user_id, db=db)

        birth_patch = _extract_birth_patch(update_dict)
        update_payload = dict(update_dict)
        skipped_fields: List[str] = []

        # Admin-only fields are never client-settable: a user must not be
        # able to (un)suspend themselves, change their own role, or set an
        # admin flag / quota override through the self-service profile route
        # (the admin panel owns those via /api/v1/admin/users). They are
        # stripped from the payload — not errors — so a stale client sending
        # them degrades gracefully.
        for admin_only in ("is_active", "role", "is_admin", "custom_daily_quota"):
            update_payload.pop(admin_only, None)

        while True:
            update_payload["updated_at"] = _now()
            try:
                result = await asyncio.to_thread(db.table("users").update(update_payload).eq("id", user_id).execute)
                break
            except Exception as e:
                missing_col = _extract_missing_users_column(e)
                if not missing_col or missing_col not in update_payload:
                    raise
                if missing_col == "birth_date":
                    # Support legacy schema that still uses users.date_of_birth.
                    update_payload["date_of_birth"] = update_payload.get("birth_date")
                    update_payload.pop("birth_date", None)
                    logger.warning(
                        "users.birth_date missing, retrying update using users.date_of_birth",
                        user_id=user_id,
                    )
                    continue
                skipped_fields.append(missing_col)
                update_payload.pop(missing_col, None)
                logger.warning(
                    "Skipping update for missing users column",
                    user_id=user_id,
                    skipped_column=missing_col,
                )
                # Avoid empty update (only updated_at left).
                if set(update_payload.keys()) <= {"updated_at"}:
                    _sync_birth_fields_to_auth(db, user_id, birth_patch)
                    return {
                        "data": (await get_current_user(user_id=user_id, db=db))["data"],
                        "message": "No schema-compatible profile fields to update",
                        "meta": {"skipped_fields": skipped_fields},
                    }

        row = _first_row(result.data or [])
        if not row:
            raise DatabaseError("Failed to update user")

        _sync_birth_fields_to_auth(db, user_id, birth_patch)

        user = UserResponse.model_validate(_normalize_user_birth_fields(row))
        response: Dict[str, Any] = {"data": user.model_dump(mode="json"), "message": "Updated"}
        if skipped_fields:
            response["meta"] = {"skipped_fields": skipped_fields}
        return response

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update user", user_id, e)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_current_user(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete the current user's account and data.

    External vectors/storage are cleaned before the public user row is removed.
    The public row is deleted before Auth so an Auth outage cannot leave a live
    user profile and wardrobe behind. Auth and Postgres still cannot share a
    transaction; every boundary fails loudly and the operation is safe to
    retry with the same authenticated session.
    """
    try:
        # Resolve owned storage paths through the parent rows. Child image
        # tables do not carry user_id and the backend uses a service client.
        owned = await StorageService.resolve_owned_storage_paths(db, user_id)
        storage_paths = owned["storage_paths"]

        # Feedback/service-ticket attachments are tracked by their durable
        # bucket keys (support_tickets.attachment_storage_paths) so their
        # objects are not orphaned on account deletion. attachment_urls holds
        # only short-lived presigned URLs and must not be used as the durable
        # reference. Read-only; routed through execute_with_reconnect so a
        # dead pooled connection (observed 2026-08-04: "Failed to delete
        # account" 500s) heals instead of failing the whole deletion.
        tickets_result = await execute_with_reconnect(
            lambda d: d.table("support_tickets")
            .select("attachment_storage_paths")
            .eq("user_id", user_id)
            .execute(),
            db,
            extra={"operation": "delete_account.tickets", "user_id": user_id},
        )
        for ticket_row in (tickets_result.data or []):
            for path in (ticket_row.get("attachment_storage_paths") or []):
                if path:
                    storage_paths.append(str(path))

        # The avatar is referenced only by URL on the user row; resolve it to
        # its storage object so deletion does not orphan it in Storage.
        # `key_from_path` reduces the stored (presigned) URL to its bucket key
        # (replaces the removed `url_to_storage_path`); the S3 backend uses a
        # single configured bucket, so the key is appended to the shared list.
        avatar_result = await execute_with_reconnect(
            lambda d: d.table("users")
            .select("avatar_url")
            .eq("id", user_id)
            .maybe_single()
            .execute(),
            db,
            extra={"operation": "delete_account.avatar", "user_id": user_id},
        )
        avatar_row = maybe_single_data(avatar_result)
        avatar_key = StorageService.key_from_path(
            (avatar_row or {}).get("avatar_url")
        )
        if avatar_key:
            storage_paths.append(avatar_key)

        # The data-export archive is a single deterministic key per user
        # (POST /users/export overwrites it), so its object is known without a
        # bucket listing; delete it with the rest of the owned storage. A
        # missing object is a no-op delete on the S3 side.
        storage_paths.append(f"{user_id}/export/data.json")

        async def _delete_storage() -> None:
            if storage_paths:  # pragma: no cover - export path always appended above
                await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)

        async def _delete_vectors() -> None:
            if hasattr(db.table("items"), "select"):  # pragma: no cover - real clients always have select
                try:
                    await get_vector_service().delete_user_items(user_id)
                except Exception as error:
                    raise DatabaseError("Failed to delete wardrobe embeddings", operation="delete_vectors") from error

        # Storage and vector cleanup are independent of each other; the user
        # row delete stays last so an Auth outage cannot leave a live profile.
        await asyncio.gather(_delete_storage(), _delete_vectors())

        # ANONYMIZE, do not delete. support_tickets.user_id is ON DELETE SET
        # NULL because 009_support_tickets supports anonymous tickets, and the
        # table also holds in-app CONTENT REPORTS about other users plus open
        # support/billing threads. Hard-deleting the requester's rows destroys
        # the only record of a third party's violation (the reported user is
        # never actioned and the content stays up) and any unresolved dispute
        # support still needs.
        #
        # Erasure applies to the requester's personal data, not to the ticket
        # itself: clearing user_id and contact_email severs every link back to
        # them while the body/category/status survive for moderation. Their
        # attachment objects were already deleted above.
        await execute_with_reconnect(
            lambda d: d.table("support_tickets")
            .update({"user_id": None, "contact_email": None})
            .eq("user_id", user_id)
            .execute(),
            db,
            extra={"operation": "delete_account.support_tickets", "user_id": user_id},
        )

        # The user-row delete is idempotent (a replayed delete is a no-op), so
        # it is safe through the reconnect retry: a dead pooled connection
        # mid-delete rebuilds the client and completes (2026-08-04 RCA).
        await execute_with_reconnect(
            lambda d: d.table("users").delete().eq("id", user_id).execute(),
            db,
            extra={"operation": "delete_account.user_row", "user_id": user_id},
        )

        admin = getattr(getattr(db, "auth", None), "admin", None)
        if not admin or not hasattr(admin, "delete_user"):
            raise DatabaseError("Auth account deletion is unavailable", operation="delete_auth_user")
        await asyncio.to_thread(admin.delete_user, user_id)

        return None

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("delete account", user_id, e)


# ============================================================================
# DATA EXPORT
# ============================================================================


@router.post("/export", response_model=Dict[str, Any])
async def export_user_data(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Generate a JSON archive of the current user's data and return a
    short-lived presigned download URL.

    Metadata only: rows carry their storage keys (``storage_path``); image
    bytes are never included. The archive is written to a single
    deterministic key per user (``{user_id}/export/data.json``, overwritten on
    each call - the same key account deletion cleans up), and served as a
    short-lived presigned GET URL (the repo's ~15-minute pattern). Every call
    returns a fresh URL, so repeat requests never hand out a stale link.
    """
    try:
        user_result = await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", user_id).execute(),
            db,
            extra={"operation": "export_user_data.user", "user_id": user_id},
            max_retries=2,
        )
        if not user_result.data:
            raise UserNotFoundError(user_id=user_id)

        async def _rows(table: str) -> List[Dict[str, Any]]:
            result = await execute_with_reconnect(
                lambda d: d.table(table).select("*").eq("user_id", user_id).execute(),
                db,
                extra={"operation": f"export_user_data.{table}", "user_id": user_id},
                max_retries=2,
            )
            return result.data or []

        # Sections are independent; read them concurrently (same pattern as
        # the dashboard aggregate and the deletion cascade).
        preferences, settings, body_profiles, items, outfits, calendar_events, subscriptions = await asyncio.gather(
            _rows("user_preferences"),
            _rows("user_settings"),
            _rows("body_profiles"),
            _rows("items"),
            _rows("outfits"),
            _rows("calendar_events"),
            _rows("subscriptions"),
        )

        payload = {
            "generated_at": _now(),
            "note": "Metadata export: image files are not included; rows carry their storage keys.",
            "user": user_result.data[0],
            "preferences": (preferences or [None])[0],
            "settings": (settings or [None])[0],
            "body_profiles": body_profiles,
            "items": items,
            "outfits": outfits,
            "calendar_events": calendar_events,
            # Billing summary only - provider-side identifiers are the user's
            # own data but add nothing to a wardrobe export.
            "subscriptions": [
                {
                    "id": row.get("id"),
                    "plan_type": row.get("plan_type"),
                    "status": row.get("status"),
                    "current_period_start": row.get("current_period_start"),
                    "current_period_end": row.get("current_period_end"),
                    "cancel_at_period_end": row.get("cancel_at_period_end"),
                }
                for row in subscriptions
            ],
        }

        export_bytes = json.dumps(payload, default=str, indent=2).encode("utf-8")
        upload = await StorageService.upload_file(
            db=db,
            file_data=export_bytes,
            file_path=f"{user_id}/export/data.json",
            content_type="application/json",
            # Short cache TTL: the archive is personal data, so a CDN edge
            # must never keep serving a previous export for long (upload_file
            # docstring: pass a short value when overwriting an existing key).
            cache_control="60",
        )
        return {"data": {"export_url": upload["public_url"]}, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError, StorageServiceError):
        raise
    except Exception as e:
        _handle_db_error("export user data", user_id, e)


@router.post("/me/avatar", response_model=Dict[str, Any])
async def upload_avatar(
    file: UploadFile = File(...),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError(message="Avatar must be an image file")

        # Capture the CURRENT avatar before it is overwritten: replacing it
        # without removing the old object leaks the previous avatar forever
        # (measured: 47 orphan avatar objects / 53MB in the bucket).
        old_avatar_url = None
        try:
            row = await asyncio.to_thread(
                db.table("users").select("avatar_url").eq("id", user_id).maybe_single().execute
            )
            old_avatar_url = (row.data or {}).get("avatar_url") if row.data else None
        except Exception as e:
            logger.warning("Failed to read current avatar before replace", user_id=user_id, error=str(e))

        file_bytes = await read_upload_capped(file, MAX_FILE_SIZE)
        avatar_url = await StorageService.upload_avatar(
            db=db, user_id=user_id, filename=file.filename or "avatar.png", file_data=file_bytes
        )

        await asyncio.to_thread(db.table("users").update({"avatar_url": avatar_url, "updated_at": _now()}).eq("id", user_id).execute)

        # Best-effort removal of the replaced avatar object. Only our own
        # bucket key is deleted: an external OAuth picture URL must pass
        # through untouched (key_from_path would mangle it), and a key from
        # another user is never touched. Never fails the request.
        if old_avatar_url:
            try:
                old_key = StorageService.key_from_path(old_avatar_url)
                if old_key and old_key.startswith(f"{user_id}/avatars/") and old_key != StorageService.key_from_path(avatar_url):
                    await StorageService.delete_image(db=db, storage_path=old_key)
            except Exception as e:
                logger.warning(
                    "Failed to delete replaced avatar",
                    user_id=user_id,
                    error=str(e),
                )

        return {"data": {"avatar_url": avatar_url}, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError, UnsupportedMediaTypeError, StorageServiceError):
        raise
    except Exception as e:
        _handle_db_error("upload avatar", user_id, e, {"file_name": file.filename})


# ============================================================================
# PREFERENCES
# ============================================================================


_PREFERENCES_DEFAULTS = {
    "favorite_colors": [],
    "preferred_styles": [],
    "liked_brands": [],
    "disliked_patterns": [],
    "preferred_occasions": [],
    "color_temperature": None,
    "style_personality": None,
    "data_points_collected": 0,
    "last_updated": None,  # Set by _get_or_create_record
}


@router.get("/preferences", response_model=Dict[str, Any])
async def get_user_preferences(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        prefs_data, _ = _get_or_create_record(
            db, "user_preferences", user_id, _PREFERENCES_DEFAULTS, UserPreferences
        )
        prefs_data["last_updated"] = _now()
        return {"data": prefs_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch preferences", user_id, e)


@router.put("/preferences", response_model=Dict[str, Any])
async def update_user_preferences(
    update_data: UserPreferencesUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        prefs_data = _upsert_record(
            db,
            "user_preferences",
            user_id,
            update_data,
            UserPreferences,
            _PREFERENCES_DEFAULTS,
            updated_field="last_updated",
            created_field=None,
        )
        return {"data": prefs_data, "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update preferences", user_id, e)


# ============================================================================
# SETTINGS
# ============================================================================


_SETTINGS_DEFAULTS = {
    "default_location": None,
    "timezone": None,
    "language": "en",
    "measurement_units": "imperial",
    "notifications_enabled": True,
    "email_marketing": False,
    "dark_mode": False,
}


@router.get("/settings", response_model=Dict[str, Any])
async def get_user_settings(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        settings_data, _ = _get_or_create_record(
            db, "user_settings", user_id, _SETTINGS_DEFAULTS, UserSettings
        )
        return {"data": settings_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch settings", user_id, e)


@router.put("/settings", response_model=Dict[str, Any])
async def update_user_settings(
    update_data: UserSettingsUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        settings_data = _upsert_record(
            db, "user_settings", user_id, update_data, UserSettings, _SETTINGS_DEFAULTS
        )
        return {"data": settings_data, "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update settings", user_id, e)


# ============================================================================
# BODY PROFILE
# ============================================================================


@router.get("/body-profiles", response_model=Dict[str, Any])
async def list_body_profiles(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """List all body profiles for the user."""
    try:
        res = await asyncio.to_thread(
            db.table("body_profiles")
            .select("*")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .execute
        )
        profiles = [BodyProfile.model_validate(r).model_dump(mode="json") for r in (res.data or [])]
        return {"data": {"body_profiles": profiles}, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("fetch body profiles", user_id, e)


@router.post("/body-profiles", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_body_profile(
    request: BodyProfileCreate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Create a new body profile."""
    try:
        now = _now()
        existing_count = await asyncio.to_thread(db.table("body_profiles").select("id", count="exact").eq("user_id", user_id).execute)
        count = getattr(existing_count, "count", len(existing_count.data or []))

        payload = request.model_dump()
        if count == 0:
            payload["is_default"] = True

        if payload.get("is_default"):
            await asyncio.to_thread(db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute)

        profile_id = str(uuid.uuid4())
        insert = {"id": profile_id, "user_id": user_id, **payload, "created_at": now, "updated_at": now}
        res = await asyncio.to_thread(db.table("body_profiles").insert(insert).execute)
        row = _first_row(res.data or [])
        if not row:
            raise DatabaseError("Failed to create body profile")

        if payload.get("is_default"):
            await asyncio.to_thread(db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute)

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Created"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("create body profile", user_id, e)


@router.put("/body-profiles/{profile_id}", response_model=Dict[str, Any])
async def update_body_profile(
    profile_id: UUID,
    update_data: BodyProfileUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Update an existing body profile."""
    try:
        profile_id_str = str(profile_id)
        existing = await asyncio.to_thread(db.table("body_profiles").select("*").eq("id", profile_id_str).eq("user_id", user_id).execute)
        if not existing.data:
            raise BodyProfileNotFoundError(profile_id=profile_id_str)

        update = update_data.model_dump(exclude_unset=True)
        update["updated_at"] = _now()

        if update.get("is_default") is True:
            await asyncio.to_thread(db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute)

        res = await asyncio.to_thread(db.table("body_profiles").update(update).eq("id", profile_id_str).eq("user_id", user_id).execute)
        row = _first_row(res.data or [])
        if not row:
            raise DatabaseError("Failed to update body profile")

        if update.get("is_default") is True:
            await asyncio.to_thread(db.table("users").update({"body_profile_id": profile_id_str}).eq("id", user_id).execute)

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("update body profile", user_id, e, {"profile_id": profile_id_str})


@router.delete("/body-profiles/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_body_profile(
    profile_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete a body profile."""
    try:
        profile_id_str = str(profile_id)
        existing = await asyncio.to_thread(db.table("body_profiles").select("id,is_default").eq("id", profile_id_str).eq("user_id", user_id).execute)
        if not existing.data:
            raise BodyProfileNotFoundError(profile_id=profile_id_str)

        was_default = existing.data[0].get("is_default") if existing.data else False

        await asyncio.to_thread(db.table("body_profiles").delete().eq("id", profile_id_str).eq("user_id", user_id).execute)

        # If deleting the default profile, promote the newest remaining profile (if any)
        if was_default:
            remaining = await asyncio.to_thread(
                db.table("body_profiles")
                .select("id")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(1)
                .execute
            )
            if remaining.data:
                new_default_id = remaining.data[0]["id"]
                await asyncio.to_thread(db.table("body_profiles").update({"is_default": True, "updated_at": _now()}).eq("id", new_default_id).execute)
                await asyncio.to_thread(db.table("users").update({"body_profile_id": new_default_id}).eq("id", user_id).execute)
            else:
                await asyncio.to_thread(db.table("users").update({"body_profile_id": None}).eq("id", user_id).execute)

        return None

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("delete body profile", user_id, e, {"profile_id": profile_id_str})


@router.get("/body-profile", response_model=Dict[str, Any])
async def get_body_profile(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = await asyncio.to_thread(
            db.table("body_profiles")
            .select("*")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .limit(1)
            .single()
            .execute
        )
        if not result.data:
            raise BodyProfileNotFoundError()

        profile = BodyProfile.model_validate(result.data)
        return {"data": profile.model_dump(mode="json"), "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("fetch body profile", user_id, e)


@router.put("/body-profile", response_model=Dict[str, Any])
async def upsert_body_profile(
    update_data: BodyProfileUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        existing = await asyncio.to_thread(
            db.table("body_profiles")
            .select("id, is_default")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .limit(1)
            .single()
            .execute
        )

        now = _now()
        if not existing.data:
            # Creating requires full payload; validate via BodyProfileCreate
            create = BodyProfileCreate(**update_data.model_dump(exclude_unset=True))
            insert = {
                "user_id": user_id,
                **create.model_dump(),
                "is_default": True,
                "created_at": now,
                "updated_at": now,
            }
            result = await asyncio.to_thread(db.table("body_profiles").insert(insert).execute)
            row = _first_row(result.data or [])
            if not row:
                raise DatabaseError("Failed to create body profile")
            profile_id = row["id"]
            # Link default profile
            await asyncio.to_thread(db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute)
            profile = BodyProfile.model_validate(row)
            return {"data": profile.model_dump(mode="json"), "message": "Created"}

        profile_id = existing.data["id"]
        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = now

        if update_dict.get("is_default") is True:
            await asyncio.to_thread(db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute)

        result = await asyncio.to_thread(db.table("body_profiles").update(update_dict).eq("id", profile_id).execute)
        row = _first_row(result.data or [])
        if not row:
            raise DatabaseError("Failed to update body profile")

        # If user toggles is_default, keep users.body_profile_id updated
        if update_dict.get("is_default") is True:
            await asyncio.to_thread(db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute)

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("save body profile", user_id, e)


# ============================================================================
# DASHBOARD (MVP)
# ============================================================================


def _get_count_from_result(result: Any) -> int:
    """Extract count from Supabase result, handling different response formats."""
    return getattr(result, "count", len(result.data or []))


def _primary_image_url(images: List[Dict]) -> Optional[str]:
    """Pick the primary (else first) image URL, preferring the thumbnail.

    Mirrors the items/outfits list endpoints: ``thumbnail_url`` is sized for
    grid tiles while ``image_url`` is the full-res asset. The caller must have
    already materialized fresh presigned URLs (private buckets store durable
    ``storage_path`` keys, never URLs).
    """
    if not images:
        return None
    primary = next((i for i in images if i.get("is_primary")), images[0])
    return (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url")


def _primary_storage_path(images: List[Dict]) -> Optional[str]:
    """Pick the durable storage key of the primary (else first) image.

    Siblings the URL picker above so clients can re-mint a fresh short-lived
    URL when the one they hold expires while a screen stays open.
    """
    if not images:
        return None
    primary = next((i for i in images if i.get("is_primary")), images[0])
    return (primary or {}).get("storage_path")


async def _build_recent_activity(items: List[Dict], outfits: List[Dict]) -> List[Dict[str, Any]]:
    """Build combined recent activity list from items and outfits.

    Rows carry nested ``item_images`` / ``outfit_images``; their ``storage_path``
    is materialized into a fresh short-lived presigned URL here so activity
    thumbnails never render an expired URL. Rows without ``storage_path``
    (legacy) keep their stored URL.
    """
    activity: List[Dict[str, Any]] = []

    for it in items:
        images = it.get("item_images") or []
        await materialize_image_urls(images)
        activity.append({
            "type": "item_created",
            "description": f"Added {it.get('name')}",
            "timestamp": it.get("created_at"),
            "image_url": _primary_image_url(images),
            "storage_path": _primary_storage_path(images),
        })

    for o in outfits:
        images = o.get("outfit_images") or []
        await materialize_image_urls(images)
        activity.append({
            "type": "outfit_created",
            "description": f"Created {o.get('name')}",
            "timestamp": o.get("created_at"),
            "image_url": _primary_image_url(images),
            "storage_path": _primary_storage_path(images),
        })

    return sorted(activity, key=lambda a: a.get("timestamp") or "", reverse=True)[:10]


async def _get_weather_suggestion(user_id: str, db: Client) -> Optional[Dict[str, Any]]:
    """Get weather-based suggestion for user."""
    try:
        settings_row = await asyncio.to_thread(db.table("user_settings").select("default_location").eq("user_id", user_id).execute)
        location = settings_row.data[0].get("default_location") if (settings_row.data and len(settings_row.data) > 0) else None
        if not location:
            return None

        service = get_weather_service()
        weather = await service.get_weather(location=str(location), units="imperial")
        if not weather:
            return None

        temp_f = float(weather.get("temperature", 0))
        temp_c = round((temp_f - 32.0) * 5.0 / 9.0, 1)

        if temp_c < 5:
            recommendation = "Wear a warm coat and layered outfit."
        elif temp_c > 27:
            recommendation = "Choose breathable fabrics and lighter colors."
        else:
            recommendation = "Consider light layers."

        return {"temperature": temp_c, "recommendation": recommendation}
    except Exception:
        return None


async def _get_outfit_of_the_day(user_id: str, db: Client) -> Optional[Dict[str, Any]]:
    """Get the most recently updated outfit for the user."""
    try:
        outfit = (await asyncio.to_thread(
            db.table("outfits")
            .select("id,name,outfit_images(storage_path,image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .order("updated_at", desc=True)
            .limit(1)
            .execute
        )).data or []

        if not outfit:
            return None

        o = outfit[0]
        images = o.get("outfit_images") or []
        # Private buckets: the DB stores durable storage_path keys, so a fresh
        # short-lived presigned URL is regenerated at read time (same contract
        # as the items/outfits list endpoints) — the stored image_url would be
        # stale/expired and render a broken card image.
        await materialize_image_urls(images)
        primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
        return {
            "id": o.get("id"),
            "name": o.get("name"),
            "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
            # Durable key so clients can re-mint a fresh URL if this one
            # expires while the dashboard stays open.
            "storage_path": (primary or {}).get("storage_path"),
        }
    except Exception:
        return None


@router.get("/dashboard", response_model=Dict[str, Any])
async def get_dashboard(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Aggregate endpoint for the dashboard UI."""
    async def _dashboard_data(d: Any) -> Dict[str, Any]:
        now_dt = utcnow()
        month_start = now_dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0).isoformat()

        # All count/recent queries are independent reads; run them concurrently
        # so the home-screen endpoint waits on the slowest query, not their sum
        # (the export path above uses the same pattern on the same client).
        (
            user_row,
            items_count,
            outfits_count,
            items_added_month,
            outfits_created_month,
            most_worn_item,
            fav_items,
            fav_outfits,
            recent_items,
            recent_outfits,
        ) = await asyncio.gather(
            asyncio.to_thread(d.table("users").select("*").eq("id", user_id).execute),
            asyncio.to_thread(d.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_deleted", False).execute),
            asyncio.to_thread(d.table("outfits").select("id", count="exact").eq("user_id", user_id).execute),
            asyncio.to_thread(
                d.table("items")
                .select("id", count="exact")
                .eq("user_id", user_id)
                .eq("is_deleted", False)
                .gte("created_at", month_start)
                .execute
            ),
            asyncio.to_thread(
                d.table("outfits")
                .select("id", count="exact")
                .eq("user_id", user_id)
                .gte("created_at", month_start)
                .execute
            ),
            asyncio.to_thread(
                d.table("items")
                .select("name,usage_times_worn")
                .eq("user_id", user_id)
                .eq("is_deleted", False)
                # nullslast: NULL wear count must not outrank every real count
                # (Postgres sorts NULLs first under DESC by default).
                .order("usage_times_worn", desc=True, nullsfirst=False)
                .limit(1)
                .execute
            ),
            asyncio.to_thread(d.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_favorite", True).eq("is_deleted", False).execute),
            asyncio.to_thread(d.table("outfits").select("id", count="exact").eq("user_id", user_id).eq("is_favorite", True).execute),
            # Recent activity (images are needed so the activity feed can render
            # thumbnails; storage_path is materialized to a fresh presigned URL in
            # _build_recent_activity).
            asyncio.to_thread(
                d.table("items")
                .select("id,name,created_at,item_images(storage_path,image_url,thumbnail_url,is_primary)")
                .eq("user_id", user_id)
                .eq("is_deleted", False)
                .order("created_at", desc=True)
                .limit(5)
                .execute
            ),
            asyncio.to_thread(
                d.table("outfits")
                .select("id,name,created_at,outfit_images(storage_path,image_url,thumbnail_url,is_primary)")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(5)
                .execute
            ),
        )
        if not user_row.data:
            raise UserNotFoundError(user_id=user_id)

        most_worn_item = most_worn_item.data or []

        # Activity materialization, weather and outfit-of-the-day are
        # independent of each other; run them concurrently.
        recent_activity, weather_based, outfit_of_the_day = await asyncio.gather(
            _build_recent_activity(recent_items.data or [], recent_outfits.data or []),
            _get_weather_suggestion(user_id, d),
            _get_outfit_of_the_day(user_id, d),
        )

        return {
            "user": user_row.data,
            "statistics": {
                "total_items": _get_count_from_result(items_count),
                "total_outfits": _get_count_from_result(outfits_count),
                "items_added_this_month": _get_count_from_result(items_added_month),
                "outfits_created_this_month": _get_count_from_result(outfits_created_month),
                "most_worn_item": (
                    {"name": most_worn_item[0].get("name"), "times_worn": int(most_worn_item[0].get("usage_times_worn") or 0)}
                    if most_worn_item
                    else None
                ),
                "favorite_items_count": _get_count_from_result(fav_items),
                "favorite_outfits_count": _get_count_from_result(fav_outfits),
            },
            "recent_activity": recent_activity,
            "suggestions": {
                "weather_based": weather_based,
                "outfit_of_the_day": outfit_of_the_day,
            },
        }

    try:
        payload = await execute_with_reconnect(
            lambda d: _dashboard_data(d),
            db,
            extra={"operation": "get_dashboard", "user_id": user_id},
            max_retries=2,
        )
        return {"data": payload, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch dashboard", user_id, e)
