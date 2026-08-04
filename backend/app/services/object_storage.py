"""S3-compatible object storage backend (Railway Bucket).

Primary storage path for the app. All file uploads / downloads / copies /
deletes go through this backend; the DB (Postgres) + Auth stay on Supabase.
The ``STORAGE_BACKEND == "supabase"`` fallback is a cutover flag only — the S3
backend is the primary path and the only one implemented here.

Ownership: ``core-storage`` agent. Do not add callers' concerns (public URL
materialization, temp-image policy) here — that stays in ``storage_service``.
"""

from __future__ import annotations

import asyncio
from typing import List, Optional

import aioboto3

from app.core.config import settings
from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# Module-level storage-backend selection flag. The rest of the code can check
# this to branch on the cutover state (e.g. a read path that must fall back to
# Supabase public URLs while the migration is in flight). The S3 backend is
# always the primary path.
STORAGE_BACKEND = settings.STORAGE_BACKEND
IS_SUPABASE_FALLBACK = STORAGE_BACKEND == "supabase"

_backend: Optional["S3StorageBackend"] = None


def get_storage_backend() -> "S3StorageBackend":
    """Return the process-wide S3 backend singleton (created lazily)."""
    global _backend
    if _backend is None:
        _backend = S3StorageBackend()
    return _backend


async def close_storage_backend() -> None:
    """Close the S3 backend session at shutdown (idempotent)."""
    global _backend
    backend = _backend
    _backend = None
    if backend is not None:
        await backend.close()


class S3StorageBackend:
    """Thin ``aioboto3`` wrapper around the private Railway S3-compatible bucket.

    The ``aioboto3`` session/client is created lazily on first use (it binds to
    the running event loop) and cached for the process lifetime. All I/O
    operations use aioboto3's async client methods (which internally offload
    to a thread pool), so there is no blocking botocore call to offload
    manually — ``generate_presigned_url`` is async in aioboto3 and is awaited
    directly.
    """

    def __init__(self) -> None:
        self.bucket = settings.OBJECT_STORAGE_BUCKET
        self.endpoint_url = settings.OBJECT_STORAGE_ENDPOINT
        self.region_name = settings.OBJECT_STORAGE_REGION
        self.aws_access_key_id = settings.OBJECT_STORAGE_ACCESS_KEY_ID
        self.aws_secret_access_key = settings.OBJECT_STORAGE_SECRET_ACCESS_KEY
        self._session: Optional[aioboto3.Session] = None
        self._client = None
        self._lock = asyncio.Lock()

    async def _get_client(self):
        """Return the cached aioboto3 S3 client, creating it on first use."""
        if self._client is not None:
            return self._client
        async with self._lock:
            if self._client is None:
                self._session = aioboto3.Session()
                # aioboto3's `session.client(...)` returns an async context
                # manager (ClientCreatorContext); enter it to obtain the
                # persistent client. The client is closed via `close()`.
                ctx = self._session.client(
                    "s3",
                    endpoint_url=self.endpoint_url,
                    region_name=self.region_name,
                    aws_access_key_id=self.aws_access_key_id,
                    aws_secret_access_key=self.aws_secret_access_key,
                )
                self._client = await ctx.__aenter__()
        return self._client

    async def upload(
        self, key: str, data: bytes, content_type: str, cache_control: str
    ) -> None:
        """Upload ``data`` to ``key`` with Content-Type + Cache-Control."""
        client = await self._get_client()
        params = {"Bucket": self.bucket, "Key": key, "Body": data}
        if content_type:
            params["ContentType"] = content_type
        if cache_control:
            # A bare seconds value is encoded as `max-age=<v>`.
            params["CacheControl"] = f"max-age={cache_control}"
        await client.put_object(**params)

    async def download(self, key: str) -> bytes:
        """Download and return the raw bytes of ``key``."""
        client = await self._get_client()
        response = await client.get_object(Bucket=self.bucket, Key=key)
        return await response["Body"].read()

    async def copy(self, src_key: str, dst_key: str) -> None:
        """Server-side copy ``src_key`` -> ``dst_key`` (used by move)."""
        client = await self._get_client()
        await client.copy_object(
            Bucket=self.bucket,
            CopySource={"Bucket": self.bucket, "Key": src_key},
            Key=dst_key,
        )

    async def delete(self, key: str) -> None:
        """Delete a single object."""
        client = await self._get_client()
        await client.delete_object(Bucket=self.bucket, Key=key)

    async def delete_many(self, keys: List[str]) -> int:
        """Delete many objects (batched at S3's 1000-object limit).

        Returns the number of keys requested for deletion.
        """
        if not keys:
            return 0
        client = await self._get_client()
        deleted = 0
        for start in range(0, len(keys), 1000):
            chunk = keys[start : start + 1000]
            await client.delete_objects(
                Bucket=self.bucket,
                Delete={"Objects": [{"Key": k} for k in chunk], "Quiet": True},
            )
            deleted += len(chunk)
        return deleted

    async def presign_get(self, key: str, expires: int = 900) -> str:
        """Return a short-lived presigned GET URL for ``key``."""
        client = await self._get_client()
        # aioboto3's generate_presigned_url is async (verified); await it
        # directly — it is not a blocking sync call to wrap in to_thread.
        return await client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket, "Key": key},
            ExpiresIn=expires,
        )

    async def list_keys(self, prefix: str = "") -> List[str]:
        """List all object keys under ``prefix`` (paginated)."""
        client = await self._get_client()
        keys: List[str] = []
        paginator = client.get_paginator("list_objects_v2")
        async for page in paginator.paginate(Bucket=self.bucket, Prefix=prefix):
            for obj in page.get("Contents", []):
                keys.append(obj["Key"])
        return keys

    async def close(self) -> None:
        """Release the aioboto3 client at app shutdown (idempotent)."""
        if self._client is not None:
            try:
                await self._client.close()
            except Exception:  # pragma: no cover - defensive teardown
                pass
            self._client = None
        self._session = None
