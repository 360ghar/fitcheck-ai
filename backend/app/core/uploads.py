"""Shared multipart upload helpers.

`await file.read()` commits the whole body to RAM before any size check runs,
so a size cap enforced afterwards (e.g. StorageService._validate_image) never
prevents the allocation it is meant to prevent. Read through
`read_upload_capped` instead: it rejects as soon as the cap is crossed.

Lifted verbatim from app/api/v1/batch_processing.py::_read_upload_capped so
non-batch routes can reuse it without importing across api modules. The batch
route keeps its private copy for now (see the note in the tech-debt tracker);
this is the canonical version and the only difference is that the error
reports the caller's own cap rather than a hardcoded one.
"""

from typing import List

from fastapi import UploadFile

from app.core.exceptions import FileTooLargeError

# Chunk size for capped reads (reject before buffering past the cap).
_READ_CHUNK_BYTES = 1024 * 1024

# Max files accepted by one multipart endpoint. The batch route imports this
# constant (previously its own private copy) so the cap lives in one place.
MAX_UPLOAD_FILES = 50


async def read_upload_capped(upload: UploadFile, max_bytes: int) -> bytes:
    """Read an upload in chunks, rejecting once max_bytes is crossed."""
    chunks: List[bytes] = []
    total = 0
    while True:
        chunk = await upload.read(_READ_CHUNK_BYTES)
        if not chunk:
            break
        total += len(chunk)
        if total > max_bytes:
            raise FileTooLargeError(max_size_mb=max_bytes // (1024 * 1024))
        chunks.append(chunk)
    return b"".join(chunks)
