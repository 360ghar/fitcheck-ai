"""In-memory sample media for upload/image tests.

All images are generated with Pillow at test time — no binary fixtures in
the repo, no network fetches.
"""

from __future__ import annotations

import base64
import io
from typing import Dict, Tuple

from PIL import Image


def image_bytes(
    size: Tuple[int, int] = (64, 64),
    fmt: str = "PNG",
    color: Tuple[int, int, int] = (120, 30, 40),
) -> bytes:
    """Real encoded image bytes (default: small PNG)."""
    buf = io.BytesIO()
    Image.new("RGB", size, color).save(buf, format=fmt)
    return buf.getvalue()


def image_base64(size: Tuple[int, int] = (64, 64), fmt: str = "PNG") -> str:
    """Base64-encoded image for JSON payloads (extraction, try-on, demo)."""
    return base64.b64encode(image_bytes(size=size, fmt=fmt)).decode("utf-8")


def multipart_files(
    field: str = "file",
    filename: str = "photo.png",
    content_type: str = "image/png",
    data: bytes | None = None,
) -> Dict[str, Tuple[str, bytes, str]]:
    """``files=`` dict for httpx/TestClient multipart uploads."""
    return {field: (filename, data if data is not None else image_bytes(), content_type)}
