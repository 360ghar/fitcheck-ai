"""Shared fake S3 backend for storage tests.

The refactored StorageService talks to ``S3StorageBackend`` (see
``app/services/object_storage.py``) via ``get_storage_backend()``. Tests mock
``app.services.storage_service.get_storage_backend`` to return this fake so no
real S3 client is ever constructed. The fake mirrors the backend's async
interface: ``upload``, ``download``, ``copy``, ``delete``, ``delete_many``,
``presign_get``, ``list_keys``, ``close``.
"""

from typing import Dict, List, Optional


class FakeS3Backend:
    """In-memory stand-in for ``S3StorageBackend`` that records every call."""

    def __init__(self, download_bytes: Optional[bytes] = None):
        self.download_bytes = download_bytes
        self.download_keys: List[str] = []
        self.upload_calls: List[Dict[str, object]] = []
        self.copy_calls: List[tuple] = []
        self.delete_calls: List[str] = []
        self.presign_calls: List[str] = []
        self.list_calls: List[str] = []
        self.closed = False

    async def upload(self, key: str, data: bytes, content_type: str, cache_control: str) -> None:
        self.upload_calls.append(
            dict(
                key=key,
                data=data,
                content_type=content_type,
                cache_control=cache_control,
            )
        )

    async def download(self, key: str) -> bytes:
        self.download_keys.append(key)
        if self.download_bytes is None:
            raise Exception("NoSuchKey")
        return self.download_bytes

    async def copy(self, src_key: str, dst_key: str) -> None:
        self.copy_calls.append((src_key, dst_key))

    async def delete(self, key: str) -> None:
        self.delete_calls.append(key)

    async def delete_many(self, keys: List[str]) -> int:
        return len(keys)

    async def presign_get(self, key: str, expires: int = 900) -> str:
        self.presign_calls.append(key)
        return f"https://presigned.example/{key}"

    async def list_keys(self, prefix: str = "") -> List[str]:
        self.list_calls.append(prefix)
        return []

    async def close(self) -> None:
        self.closed = True