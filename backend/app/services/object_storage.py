"""S3-compatible object storage backend (Cloudflare R2 / Railway Bucket).

Primary storage path for the app. All file uploads / downloads / copies /
deletes go through this backend; the DB (Postgres) + Auth stay on Supabase.
Provider-agnostic on purpose: the endpoint and credentials decide whether this
talks to R2, a Railway bucket, MinIO or S3 proper, so a provider migration is an
env change plus an object copy.

Ownership: ``core-storage`` agent. Do not add callers' concerns (public URL
materialization, temp-image policy) here — that stays in ``storage_service``.
"""

from __future__ import annotations

import asyncio
from typing import List, Optional

import aioboto3
from botocore.config import Config as BotoConfig

from app.core.config import settings
from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# Wire behavior pinned explicitly rather than left to botocore's defaults,
# because those defaults have broken S3-compatible providers before and the
# breakage surfaces as an opaque 400/501 on upload:
#
# * request/response checksums: botocore >= 1.36 defaults both to
#   "when_supported", which attaches `x-amz-checksum-crc32` to PutObject and
#   requires a checksum on DeleteObjects. Non-AWS endpoints have historically
#   rejected those. "when_required" sends them only where the S3 API mandates
#   them, which every S3-compatible provider handles.
# * addressing_style="path": R2 and MinIO both accept path style, and it keeps
#   the signed host stable (no per-bucket subdomain, so no wildcard-cert
#   surprises). It also matches `StorageService.build_object_url`, which
#   composes path-style URLs — client and helper agree on one shape.
# * s3v4: R2 requires SigV4; being explicit means a stray AWS_DEFAULT_* env var
#   cannot downgrade it.
_BOTO_CONFIG = BotoConfig(
    signature_version="s3v4",
    s3={"addressing_style": "path"},
    request_checksum_calculation="when_required",
    response_checksum_validation="when_required",
    retries={"max_attempts": 3, "mode": "standard"},
)

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
    """Thin ``aioboto3`` wrapper around the private Cloudflare R2 bucket.

    The ``aioboto3`` session/client is created lazily on first use (it binds to
    the running event loop) and cached for the process lifetime. All I/O
    operations use aioboto3's async client methods (which internally offload
    to a thread pool), so there is no blocking botocore call to offload
    manually — ``generate_presigned_url`` is async in aioboto3 and is awaited
    directly.
    """

    def __init__(
        self,
        *,
        endpoint_url: Optional[str] = None,
        region_name: Optional[str] = None,
        aws_access_key_id: Optional[str] = None,
        aws_secret_access_key: Optional[str] = None,
        bucket: Optional[str] = None,
    ) -> None:
        """Create a backend bound to a specific S3 endpoint.

        All parameters default to ``settings``. The explicit overrides let an
        operator point a second backend at another bucket (e.g.
        ``storage_inventory.py --endpoint/--bucket`` inspecting the old bucket
        after a provider cutover) while the process-wide singleton stays on the
        configured one.
        """
        self.bucket = bucket if bucket is not None else settings.OBJECT_STORAGE_BUCKET
        self.endpoint_url = (
            endpoint_url if endpoint_url is not None else settings.OBJECT_STORAGE_ENDPOINT
        )
        self.region_name = (
            region_name if region_name is not None else settings.OBJECT_STORAGE_REGION
        )
        self.aws_access_key_id = (
            aws_access_key_id
            if aws_access_key_id is not None
            else settings.OBJECT_STORAGE_ACCESS_KEY_ID
        )
        self.aws_secret_access_key = (
            aws_secret_access_key
            if aws_secret_access_key is not None
            else settings.OBJECT_STORAGE_SECRET_ACCESS_KEY
        )
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
                    config=_BOTO_CONFIG,
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

        Returns the number of keys the provider did NOT report an error for.

        ``Quiet: True`` suppresses the per-key success list but still returns
        ``Errors``, so subtracting those gives a real count instead of echoing
        the request size. Errors are logged rather than raised: every caller
        treats batch deletion as best-effort, and a partial failure must not
        abandon the remaining chunks. Note that S3 semantics make deleting an
        absent key a success, so an already-gone thumbnail is not an error.
        """
        if not keys:
            return 0
        client = await self._get_client()
        deleted = 0
        for start in range(0, len(keys), 1000):
            chunk = keys[start : start + 1000]
            response = await client.delete_objects(
                Bucket=self.bucket,
                Delete={"Objects": [{"Key": k} for k in chunk], "Quiet": True},
            )
            errors = response.get("Errors") or []
            if errors:
                logger.warning(
                    "Some objects failed to delete",
                    bucket=self.bucket,
                    requested=len(chunk),
                    failed=len(errors),
                    first_error_key=errors[0].get("Key"),
                    first_error_code=errors[0].get("Code"),
                )
            deleted += len(chunk) - len(errors)
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

    async def scan_keys(
        self, prefix: str = "", *, max_pages: int = 50
    ) -> List[dict]:
        """List object keys with size/last-modified metadata, bounded by pages.

        Each page yields up to ~1000 keys (``PageSize``). Scanning stops after
        ``max_pages`` pages so an admin inventory call can never walk the whole
        bucket (a bucket can hold millions of objects; admin ops endpoints use
        this to sample the ``tmp/`` previews under user folders).

        Returns a list of ``{"key", "size", "last_modified"}`` dicts.
        """
        client = await self._get_client()
        out: List[dict] = []
        paginator = client.get_paginator("list_objects_v2")
        pages = 0
        async for page in paginator.paginate(
            Bucket=self.bucket,
            Prefix=prefix,
            PaginationConfig={"PageSize": 1000},
        ):
            pages += 1
            for obj in page.get("Contents", []):
                out.append(
                    {
                        "key": obj["Key"],
                        "size": obj.get("Size", 0),
                        "last_modified": obj.get("LastModified"),
                    }
                )
            if pages >= max_pages:
                break
        return out

    async def close(self) -> None:
        """Release the aioboto3 client at app shutdown (idempotent)."""
        if self._client is not None:
            try:
                await self._client.close()
            except Exception:  # pragma: no cover - defensive teardown
                pass
            self._client = None
        self._session = None
