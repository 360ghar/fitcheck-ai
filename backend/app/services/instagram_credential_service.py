"""
Instagram Credential Service - Manages encrypted Instagram credentials.

This service handles:
- Storing encrypted Instagram username/password
- Storing session data for reuse
- Retrieving and decrypting credentials
"""

import json
from datetime import datetime
from typing import Any, Dict, Optional

from app.core.logging_config import get_context_logger
from app.services.ai_settings_service import decrypt_api_key, encrypt_api_key

logger = get_context_logger(__name__)


class InstagramCredentialService:
    """Service for managing Instagram credentials."""

    @staticmethod
    async def save_credentials(
        user_id: str,
        username: str,
        password: str,
        db,
    ) -> bool:
        """
        Save encrypted Instagram credentials for a user.

        Args:
            user_id: The user's ID
            username: Instagram username
            password: Instagram password
            db: Supabase client

        Returns:
            True if saved successfully
        """
        try:
            # Encrypt credentials
            encrypted_username = encrypt_api_key(username)
            encrypted_password = encrypt_api_key(password)

            if not encrypted_username or not encrypted_password:
                logger.error("Failed to encrypt Instagram credentials")
                return False

            # Check if credentials already exist
            existing = db.table("user_instagram_credentials").select("id").eq("user_id", user_id).execute()

            data = {
                "user_id": user_id,
                "username_encrypted": encrypted_username,
                "password_encrypted": encrypted_password,
                "is_valid": True,
                "updated_at": datetime.utcnow().isoformat(),
            }

            if existing.data and len(existing.data) > 0:
                # Update existing
                db.table("user_instagram_credentials").update(data).eq("user_id", user_id).execute()
            else:
                # Insert new
                data["created_at"] = datetime.utcnow().isoformat()
                db.table("user_instagram_credentials").insert(data).execute()

            logger.info("Saved Instagram credentials", extra={"user_id": user_id})
            return True

        except Exception as e:
            logger.error("Failed to save Instagram credentials", extra={"user_id": user_id, "error": str(e)})
            return False

    @staticmethod
    async def get_credentials(user_id: str, db) -> Optional[Dict[str, str]]:
        """
        Get decrypted Instagram credentials for a user.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            Dict with username and password, or None if not found
        """
        try:
            result = db.table("user_instagram_credentials").select("*").eq("user_id", user_id).execute()

            if not result.data or len(result.data) == 0:
                return None

            row = result.data[0]

            # Decrypt credentials
            username = decrypt_api_key(row.get("username_encrypted", ""))
            password = decrypt_api_key(row.get("password_encrypted", ""))

            if not username or not password:
                logger.error("Failed to decrypt Instagram credentials")
                return None

            return {
                "username": username,
                "password": password,
                "session_data": row.get("session_data"),
                "is_valid": row.get("is_valid", False),
            }

        except Exception as e:
            logger.error("Failed to get Instagram credentials", extra={"user_id": user_id, "error": str(e)})
            return None

    @staticmethod
    async def get_credentials_status(user_id: str, db) -> Dict[str, Any]:
        """
        Get status of stored Instagram credentials.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            Status dict with has_credentials, is_valid, username
        """
        try:
            result = db.table("user_instagram_credentials").select(
                "username_encrypted", "is_valid", "last_used"
            ).eq("user_id", user_id).execute()

            if not result.data or len(result.data) == 0:
                return {
                    "has_credentials": False,
                    "is_valid": False,
                    "username": None,
                    "last_used": None,
                }

            row = result.data[0]
            username = decrypt_api_key(row.get("username_encrypted", ""))

            return {
                "has_credentials": True,
                "is_valid": row.get("is_valid", False),
                "username": username,
                "last_used": row.get("last_used"),
            }

        except Exception as e:
            logger.error("Failed to get Instagram credentials status", extra={"user_id": user_id, "error": str(e)})
            return {
                "has_credentials": False,
                "is_valid": False,
                "username": None,
                "last_used": None,
            }

    @staticmethod
    async def update_session(
        user_id: str,
        session_data: Dict[str, Any],
        db,
    ) -> bool:
        """
        Update stored session data for a user.

        Args:
            user_id: The user's ID
            session_data: Session cookies/data to store
            db: Supabase client

        Returns:
            True if updated successfully
        """
        try:
            # Encrypt session data as JSON string
            session_json = json.dumps(session_data)
            encrypted_session = encrypt_api_key(session_json)

            if not encrypted_session:
                logger.error("Failed to encrypt session data")
                return False

            db.table("user_instagram_credentials").update({
                "session_data": encrypted_session,
                "is_valid": True,
                "last_used": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat(),
            }).eq("user_id", user_id).execute()

            logger.info("Updated Instagram session", extra={"user_id": user_id})
            return True

        except Exception as e:
            logger.error("Failed to update Instagram session", extra={"user_id": user_id, "error": str(e)})
            return False

    @staticmethod
    async def get_session(user_id: str, db) -> Optional[Dict[str, Any]]:
        """
        Get decrypted session data for a user.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            Session data dict, or None if not found
        """
        try:
            result = db.table("user_instagram_credentials").select("session_data").eq("user_id", user_id).execute()

            if not result.data or len(result.data) == 0:
                return None

            encrypted_session = result.data[0].get("session_data")
            if not encrypted_session:
                return None

            session_json = decrypt_api_key(encrypted_session)
            if not session_json:
                return None

            return json.loads(session_json)

        except Exception as e:
            logger.error("Failed to get Instagram session", extra={"user_id": user_id, "error": str(e)})
            return None

    @staticmethod
    async def mark_invalid(user_id: str, db) -> bool:
        """
        Mark credentials as invalid (e.g., after login failure).

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            True if updated successfully
        """
        try:
            db.table("user_instagram_credentials").update({
                "is_valid": False,
                "session_data": None,
                "updated_at": datetime.utcnow().isoformat(),
            }).eq("user_id", user_id).execute()

            logger.info("Marked Instagram credentials as invalid", extra={"user_id": user_id})
            return True

        except Exception as e:
            logger.error("Failed to mark credentials invalid", extra={"user_id": user_id, "error": str(e)})
            return False

    @staticmethod
    async def delete_credentials(user_id: str, db) -> bool:
        """
        Delete stored Instagram credentials for a user.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            True if deleted successfully
        """
        try:
            db.table("user_instagram_credentials").delete().eq("user_id", user_id).execute()
            logger.info("Deleted Instagram credentials", extra={"user_id": user_id})
            return True

        except Exception as e:
            logger.error("Failed to delete Instagram credentials", extra={"user_id": user_id, "error": str(e)})
            return False
