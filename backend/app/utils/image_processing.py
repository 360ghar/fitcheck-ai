"""Best-effort image downscaling and cropping for the vision/generation pipeline.

Full-resolution phone photos blow up the payload sent inline to the vision
model (token cost + latency). Shrinking the longest edge to ~1568px and
re-encoding as JPEG keeps far more detail than the model tiles on while
cutting bytes ~10x.

CONTRACT, and it is deliberately the INVERSE of
`app/utils/background_removal.py`: everything in this module produces opaque
JPEG bytes destined for an AI MODEL, never for a user's screen. Alpha is
flattened onto white on the way in (see `downscale_base64_image`). Do not
"unify" the two modules and do not teach these functions to preserve
transparency - see the long note on `downscale_base64_image` for why.

Also home to the shared image format/MIME sniffers (`sniff_image_mime`,
`to_data_url`), which are pure format detection and belong to neither
direction of the pipeline.
"""

import base64
import io
import os
from typing import Any, Dict, Optional, Tuple

from PIL import Image, ImageOps

# Register the HEIC/HEIF decoder so PIL can open iPhone/modern-camera photos.
# Required before any Image.open()/verify() on HEIF bytes; a missing wheel
# must not crash import (the upload allowlist + verify still gate the bytes).
try:
    from pillow_heif import register_heif_opener

    register_heif_opener()
except ImportError:  # pragma: no cover - wheel absent only in a broken env
    pass

# Matches the mobile client's existing 1920/q85 upload; above vision tiling
# thresholds. One knob if extraction accuracy ever regresses.
DEFAULT_MAX_EDGE = 1568
DEFAULT_QUALITY = 85

# Padding added around a bounding box before cropping, as a fraction of the
# box's own width/height. Bounding boxes from the vision model are known to
# drift a few percentage points off the true garment edges - generous padding
# absorbs that without clipping the item.
DEFAULT_CROP_PADDING_RATIO = 0.20
# Floor padding in percentage points of the full image, applied even to tiny
# boxes (a pure ratio of a 2%-wide accessory box would pad almost nothing).
DEFAULT_CROP_PADDING_FLOOR = 4.0


# =============================================================================
# FORMAT / MIME DETECTION
# =============================================================================
# Two independent bugs made this shared: (1) every storage3 `upload()` call
# without explicit `file_options` inherits DEFAULT_FILE_OPTIONS'
# `content-type: text/plain;charset=UTF-8`, so images were served as text;
# (2) every data URL in the codebase hardcoded `data:image/jpeg;base64,` even
# for PNG/WebP bytes, and GeminiProvider._decode_image_part parses that header
# straight into `Part.from_bytes(mime_type=...)`, so the lie reached the model.
# Filenames are NOT trusted: the batch client names its upload
# `${tempId}.png` regardless of what the bytes actually are.

FALLBACK_MIME = "application/octet-stream"

# Formats accepted at user-upload boundaries. Provider-only formats such as
# AVIF/HEIF remain detectable for downstream use, but are not accepted here
# until every client and image pipeline can decode them consistently.
SUPPORTED_UPLOAD_MIME_TYPES = frozenset({
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/gif",
    # iOS Safari 16+/modern cameras upload AVIF; it decodes fine (Pillow
    # AVIF plugin, sniffed via ftypavif) but was rejected here with a 415
    # "Unsupported decoded image format" (observed 2026-08-04 on
    # /ai/batch-extract-multipart). Downstream AI reference paths re-encode
    # to JPEG (downscale_image_bytes_to_base64), so AVIF never reaches
    # providers that cannot consume it.
    "image/avif",
    # HEIC/HEIF (iPhone default), BMP, TIFF: accepted but NEVER stored as-is.
    # StorageService._normalize_upload_bytes re-encodes these to WebP before
    # the object key/content-type are minted, because browsers cannot render
    # HEIC/TIFF. `image/heic` is included alongside `image/heif` for the rare
    # caller that resolves a MIME from a multipart content-type rather than
    # magic bytes (the magic-byte sniffer always yields `image/heif`).
    "image/heif",
    "image/heic",
    "image/bmp",
    "image/tiff",
})

# Magic-byte prefixes, so a MIME can be resolved from ~32 bytes with no
# decode and no Pillow call. Order matters only in that ISO-BMFF (`ftyp`)
# checks look at bytes 4-12 rather than 0.
MIME_BY_PIL_FORMAT = {
    "JPEG": "image/jpeg",
    "PNG": "image/png",
    "WEBP": "image/webp",
    "GIF": "image/gif",
    "BMP": "image/bmp",
    "TIFF": "image/tiff",
    "AVIF": "image/avif",
    "HEIF": "image/heif",
}

MIME_BY_EXTENSION = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
    ".gif": "image/gif",
    ".bmp": "image/bmp",
    ".tif": "image/tiff",
    ".tiff": "image/tiff",
    ".avif": "image/avif",
    ".heic": "image/heif",
    ".heif": "image/heif",
}

EXTENSION_BY_MIME = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "image/gif": ".gif",
    "image/bmp": ".bmp",
    "image/tiff": ".tiff",
    "image/avif": ".avif",
    "image/heif": ".heic",
}


def sniff_image_mime_from_magic(head: bytes) -> Optional[str]:
    """MIME from a file's leading bytes, or None if unrecognised.

    Needs only the first ~32 bytes, does no decoding, and never raises.
    """
    if not head:
        return None
    if head.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if head[:4] == b"RIFF" and head[8:12] == b"WEBP":
        return "image/webp"
    if head[:6] in (b"GIF87a", b"GIF89a"):
        return "image/gif"
    if head[:2] == b"BM":
        return "image/bmp"
    if head[:4] in (b"II*\x00", b"MM\x00*"):
        return "image/tiff"
    brand = head[4:12]
    if brand == b"ftypavif":
        return "image/avif"
    if brand in (b"ftypheic", b"ftypheix", b"ftypmif1", b"ftypmsf1"):
        return "image/heif"
    return None


def sniff_image_mime(file_data: bytes, filename: Optional[str] = None) -> str:
    """Best-effort content type for raw image bytes. Never raises.

    Resolution order: magic bytes -> Pillow's decoded format -> the filename's
    extension -> `application/octet-stream`. The filename is the LAST resort on
    purpose; callers routinely supply a made-up name (`${tempId}.png`).
    """
    magic = sniff_image_mime_from_magic(file_data[:32])
    if magic:
        return magic

    try:
        with Image.open(io.BytesIO(file_data)) as img:
            fmt = (img.format or "").upper()
        if fmt:
            return MIME_BY_PIL_FORMAT.get(fmt) or f"image/{fmt.lower()}"
    except Exception:
        pass

    if filename:
        # `os.path.splitext(".png")` yields ('.png', '') - a bare extension is a
        # hidden filename to posixpath - so fall back to the whole string, since
        # callers legitimately pass just ".png".
        ext = os.path.splitext(filename)[1].lower() or filename.strip().lower()
        mime = MIME_BY_EXTENSION.get(ext)
        if mime:
            return mime

    return FALLBACK_MIME


def validate_image_bytes(
    file_data: bytes,
    *,
    max_bytes: int,
    allowed_mimes: Optional[set[str] | frozenset[str]] = None,
) -> str:
    """Decode and validate an image payload at an upload boundary.

    Multipart content types, filenames, and base64 strings are all
    caller-controlled. This helper verifies the actual bytes with Pillow and
    returns the decoded MIME type so callers can reject spoofed payloads before
    they enter a job or storage bucket.

    Raises ``ValueError`` so Pydantic validators can surface a normal 422;
    HTTP routes should translate it to ``UnsupportedMediaTypeError``.
    """
    if not file_data:
        raise ValueError("Image payload is empty")
    if len(file_data) > max_bytes:
        raise ValueError(f"Image payload exceeds the {max_bytes // (1024 * 1024)}MB limit")

    try:
        with Image.open(io.BytesIO(file_data)) as image:
            image.verify()
    except Exception as error:
        raise ValueError("Image payload is not a valid decodable image") from error

    mime = sniff_image_mime(file_data, "")
    accepted = allowed_mimes or SUPPORTED_UPLOAD_MIME_TYPES
    if mime not in accepted:
        raise ValueError(f"Unsupported decoded image format: {mime}")
    return mime


def decode_and_validate_base64_image(value: str, *, max_bytes: int) -> bytes:
    """Decode a raw base64/data-URL image and validate its actual bytes."""
    if not isinstance(value, str) or not value.strip():
        raise ValueError("Image payload is required")

    payload = value.strip()
    if payload.lower().startswith("data:"):
        header, separator, payload = payload.partition(",")
        if not separator or ";base64" not in header.lower():
            raise ValueError("Image data URL must contain base64-encoded data")

    try:
        decoded = base64.b64decode(payload, validate=True)
    except (ValueError, TypeError, base64.binascii.Error) as error:
        raise ValueError("Image payload is not valid base64") from error

    validate_image_bytes(decoded, max_bytes=max_bytes)
    return decoded


def make_base64_image_validator(max_bytes: int):
    """Build a ``field_validator``-compatible base64 image validator.

    Four request models across the API duplicated the same
    decode-and-validate wrapper (``models/ai.py``, ``models/demo.py``,
    ``api/v1/batch_processing.py``) with identical error wording. This factory
    keeps the decode + byte verification + MIME allowlist in one place.
    """

    def validate(value: str) -> str:
        try:
            decode_and_validate_base64_image(value, max_bytes=max_bytes)
        except ValueError as error:
            raise ValueError(f"Image is invalid: {error}") from error
        return value

    return validate


def to_data_url(image_base64: str) -> str:
    """Wrap bare base64 image bytes in a data URL carrying the REAL mime type.

    Pass-through when the input is already a data URL. Only the first 96 base64
    characters are decoded (72 bytes - plenty for any magic signature), so this
    is cheap enough to call per reference image. Falls back to `image/jpeg`
    when the bytes are unrecognisable: that is the historical value every
    caller hardcoded, so an unknown blob behaves exactly as it did before
    rather than newly breaking a provider that dislikes octet-stream.

    Provider-bound images pass through ``ensure_provider_safe_base64`` first,
    so an AVIF/HEIF upload is re-encoded to JPEG before any provider sees it.
    """
    image_base64 = ensure_provider_safe_base64(image_base64)
    if image_base64.startswith("data:"):
        return image_base64
    mime = None
    try:
        head = base64.b64decode(image_base64[:96], validate=False)
        mime = sniff_image_mime_from_magic(head)
    except Exception:
        mime = None
    return f"data:{mime or 'image/jpeg'};base64,{image_base64}"


# Formats whose decoders support reduced-size draft decode (Pillow
# ``Image.draft``). Everything else decodes fully — draft() is a no-op there.
_DRAFTABLE_FORMATS = frozenset({"JPEG", "MPO"})


def _decode_and_fit(
    raw: bytes,
    max_edge: int,
    *,
    flatten_alpha: bool,
) -> Tuple[Image.Image, Optional[str], Tuple[int, int], bool]:
    """Decode ``raw``, orient it, normalize its mode and fit it to ``max_edge``.

    Returns ``(img, src_format, src_size, had_alpha)`` where ``src_size`` is the
    ORIGINAL size as first reported by the decoder — captured before the draft
    decode on purpose, so a caller comparing ``img.size == src_size`` is asking
    "were these pixels left untouched by BOTH the draft and the thumbnail", which
    is the only safe basis for returning the source bytes unchanged. ``had_alpha``
    records whether the SOURCE carried transparency — callers branch on it for
    passthrough decisions and, in the JPEG case, to know a flatten happened.

    MEMORY (the reason this exists as a shared step): a 12-48 MP phone photo
    decodes to 36-144 MB of RGB before it is shrunk, and a naive version adds a
    second full-size copy for EXIF transpose and alpha handling. For JPEG
    sources we request a reduced-size DCT decode (`Image.draft`) up front and
    materialize it with `load()`, so the full-size pixel buffer never exists.
    EXIF transpose and mode conversion then run on the already-reduced image.
    Both downscale entry points must keep that property, which is exactly why
    the preamble lives here once instead of being copied per output format.

    ``flatten_alpha`` picks the one genuine behavioural difference between the
    callers: JPEG output must composite transparency onto white (it has no alpha
    channel), WebP thumbnails must preserve it (garment cutouts would otherwise
    render on a white block). Raises on undecodable input; callers convert that
    to their own failure value.
    """
    with Image.open(io.BytesIO(raw)) as src:
        src_format = src.format
        src_size = src.size
        if src_format in _DRAFTABLE_FORMATS:
            try:
                # Reduced-size decode; .size then reflects the loaded (reduced)
                # dimensions, so all downstream geometry (transpose, thumbnail)
                # is consistent — while src_size above still holds the original,
                # so the passthrough checks stay honest.
                src.draft("RGB", (max_edge, max_edge))
                src.load()
            except Exception:
                pass
        # exif_transpose returns a new (detached) image, so the file handle can
        # close when this block exits.
        img = ImageOps.exif_transpose(src)  # honour phone orientation

    # had_alpha (not a mode whitelist): a palette+alpha (PA) image or a P-mode
    # image with a transparency key must also be handled, or transparent pixels
    # render with their source palette/L values instead of white.
    had_alpha = img.mode in ("RGBA", "LA", "PA") or "transparency" in img.info
    if flatten_alpha:
        # Flatten transparency onto white so JPEG has no alpha channel.
        if had_alpha:
            background = Image.new("RGB", img.size, (255, 255, 255))
            rgba = img.convert("RGBA")
            background.paste(rgba, mask=rgba.getchannel("A"))
            img = background
        elif img.mode != "RGB":
            img = img.convert("RGB")
    else:
        # Keep alpha; only normalize the modes WebP cannot encode directly.
        if had_alpha:
            if img.mode != "RGBA":
                img = img.convert("RGBA")
        elif img.mode not in ("RGB", "L"):
            img = img.convert("RGB")

    # thumbnail() is a no-op when already smaller (never upscales).
    img.thumbnail((max_edge, max_edge))
    return img, src_format, src_size, had_alpha


def _downscale_bytes(
    raw: bytes,
    max_edge: int,
    quality: int,
) -> Tuple[Optional[bytes], bool]:
    """Return (jpeg_bytes, had_alpha) for raw image bytes, or (None, False)
    on passthrough/failure.

    Passthrough (returns None) when the input is already a small JPEG — the
    caller keeps its original bytes and skips the re-encode entirely.
    """
    try:
        img, src_format, src_size, had_alpha = _decode_and_fit(
            raw, max_edge, flatten_alpha=True
        )

        # Already within bounds and already a JPEG - nothing to gain, and
        # skipping the re-encode keeps CPU off images that are fine as-is.
        # Only when no alpha was flattened: a transparent source MUST be
        # re-encoded (flattening is load-bearing, see downscale_base64_image).
        if not had_alpha and img.size == src_size and src_format == "JPEG":
            return None, False

        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=quality, optimize=True)
        return buf.getvalue(), had_alpha
    except Exception:
        return None, False


# MIME types vision/image providers reject as INPUT (Gemini's supported set is
# JPEG/PNG/WebP/HEIC/HEIF; the OpenAI-compatible image APIs accept
# JPEG/PNG/WebP). AVIF became an uploadable format on 2026-08-04 (iOS Safari
# 16+/modern cameras); HEIC/HEIF are the same family from iOS cameras.
_PROVIDER_REJECTED_MIME_TYPES = frozenset({"image/avif", "image/heif", "image/heic"})


def ensure_provider_safe_base64(
    image_base64: str,
    *,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> str:
    """Re-encode AI-bound image bytes that vision providers cannot ingest
    (AVIF/HEIF) to an opaque JPEG base64; pass every other format through with
    no decode and no copy.

    AVIF uploads are accepted since 2026-08-04, but neither Gemini nor the
    OpenAI-compatible image APIs can read the format, so an accepted upload
    would otherwise 400 at extraction time instead of 415 at upload. Callers
    run provider-bound bytes through this helper at their wire boundary
    (``to_data_url``, ``GeminiProvider._decode_image_part``).

    Unlike ``downscale_base64_image`` this ALWAYS re-encodes the rejected
    formats: avif is usually SMALLER than its JPEG re-encode, so the
    size-comparison ponytail there would hand the model back the exact bytes
    it cannot read. Best-effort: a decode failure (e.g. a deployment without
    an AVIF decoder) returns the input unchanged, preserving today's behavior.
    """
    if image_base64.startswith("data:"):
        header, _, b64_data = image_base64.partition(",")
        mime = header[5:].split(";")[0] or "image/jpeg"
        if mime not in _PROVIDER_REJECTED_MIME_TYPES:
            return image_base64
        raw = base64.b64decode(b64_data, validate=True)
        jpeg, _had_alpha = _downscale_bytes(raw, max_edge, quality)
        if jpeg is None:
            return image_base64
        return f"data:image/jpeg;base64,{base64.b64encode(jpeg).decode('utf-8')}"

    try:
        head = base64.b64decode(image_base64[:96], validate=False)
        mime = sniff_image_mime_from_magic(head)
    except Exception:
        return image_base64
    if mime not in _PROVIDER_REJECTED_MIME_TYPES:
        return image_base64
    try:
        raw = base64.b64decode(image_base64, validate=True)
    except Exception:
        return image_base64
    jpeg, _had_alpha = _downscale_bytes(raw, max_edge, quality)
    if jpeg is None:
        return image_base64
    return base64.b64encode(jpeg).decode("utf-8")


def downscale_image_bytes_to_base64(
    raw: bytes,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> str:
    """Downscale raw image bytes to an opaque JPEG base64. Never raises.

    Core used by ``downscale_base64_image`` AND by
    ``StorageService.download_and_downscale_to_base64`` so a downloaded
    reference image never round-trips through full-size base64. On failure or
    passthrough, returns the raw bytes as base64 so callers still have a
    usable (if large) image.
    """
    jpeg, had_alpha = _downscale_bytes(raw, max_edge, quality)
    if jpeg is None:
        return base64.b64encode(raw).decode("utf-8")
    result = base64.b64encode(jpeg).decode("utf-8")
    if had_alpha:
        return result
    raw_b64 = base64.b64encode(raw).decode("utf-8")
    # ponytail: if re-encoding somehow made it bigger, keep the original -
    # UNLESS the source carried alpha. A lossy WebP cutout from
    # background_removal.py is routinely SMALLER than its flattened JPEG
    # (measured 10KB vs 27KB), so without this exemption the size check
    # would hand the model back the transparent original and quietly undo
    # the flatten this function exists to guarantee.
    return result if len(result) < len(raw_b64) else raw_b64


def downscale_image_bytes_to_webp(
    raw: bytes,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> Optional[bytes]:
    """Downscale raw image bytes to a WebP thumbnail, PRESERVING transparency.

    For storage thumbnail variants (uploaded as objects, served straight to the
    UI) — as opposed to ``downscale_image_bytes_to_base64``, whose alpha flatten
    onto white is load-bearing because AI providers need opaque JPEG.

    Alpha must survive here: item images are frequently background-removed
    cutouts (``background_removal.py`` emits transparent WebP/PNG), and a
    flattened thumbnail renders every garment tile on a white block — glaringly
    wrong on a dark theme, and inconsistent with the full-size image the same
    card opens.

    WebP unconditionally, rather than "JPEG unless alpha": the read path derives
    a thumbnail's key from its parent's key with no per-object lookup, so the
    thumb's format has to be predictable from the key alone. One format keeps the
    key, the stored bytes and the Content-Type in agreement. WebP also encodes
    both alpha and photographic content well, so nothing is given up for it.

    Returns WebP bytes, or None when they could not be produced at all (undecodable
    input, or an encode failure). ``None`` means EXACTLY "no thumbnail" — a source
    that is already a within-bound WebP returns its own bytes unchanged, because
    it is already the best possible thumbnail. Keeping those two cases distinct
    matters: when None also meant "use the original", an encode failure on a large
    image silently stored the FULL-SIZE object as its own thumbnail, which is the
    exact egress cost thumbnails exist to avoid.
    """
    try:
        img, src_format, src_size, _ = _decode_and_fit(
            raw, max_edge, flatten_alpha=False
        )

        # Already a WebP within bounds: the original IS the best thumbnail and
        # re-encoding would be a pure quality loss. Return it as-is (not None,
        # which is reserved for "no thumbnail could be made").
        if src_format == "WEBP" and img.size == src_size:
            return raw

        buf = io.BytesIO()
        img.save(buf, format="WEBP", quality=quality, method=4)
        return buf.getvalue()
    except Exception:
        return None


def transcode_to_webp(
    raw: bytes,
    *,
    quality: int = 92,
) -> Optional[bytes]:
    """Full-resolution re-encode of a non-web-native image to WebP.

    The mirror of ``downscale_image_bytes_to_webp`` for the UPLOAD path: HEIC/
    HEIF (iPhone photos), BMP and TIFF decode in PIL but browsers cannot render
    HEIC/TIFF, so ``StorageService._normalize_upload_bytes`` runs accepted
    uploads of those formats through this before the storage key/content-type
    are minted. The stored object is always a browser-safe ``.webp``.

    Resolution is PRESERVED (no downscale): ``max_edge`` is set so large that
    ``thumbnail()`` is a no-op, matching the store-originals-as-is behavior every
    other format already gets. Alpha survives (``flatten_alpha=False``) so a
    transparent source stays transparent. Returns None on any decode/encode
    failure, in which case the caller keeps the original bytes (and the request
    still surfaces a clear error via the prior ``validate_image_bytes`` decode).
    """
    try:
        img, _src_format, _src_size, _ = _decode_and_fit(
            raw, max_edge=10**9, flatten_alpha=False
        )
        buf = io.BytesIO()
        img.save(buf, format="WEBP", quality=quality, method=4)
        return buf.getvalue()
    except Exception:
        return None


def downscale_base64_image(
    image_base64: str,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> str:
    """Return a downsized, OPAQUE JPEG (base64) for a base64 image.

    Best-effort: on ANY failure (not an image, unsupported format, decode
    error) the input is returned unchanged so the vision call still works.
    Never upscales - images already <= max_edge pass through re-encoded only
    if that actually shrinks them.

    THE ALPHA FLATTEN BELOW IS LOAD-BEARING - DO NOT "FIX" IT.
    This function's output goes to an AI model, never to a user's screen:
      - JPEG cannot carry an alpha channel at all, and the providers we use
        cannot consume one meaningfully (`_generate_image_via_images_api` sends
        a fixed payload with no output_format; GeminiProvider discards it).
      - Since `app/utils/background_removal.py` landed, item images in storage
        are transparent WebP cutouts. `item_reference_service` downloads those
        as garment references and they arrive here - flattening them onto white
        produces exactly the "clean isolated garment on white" that
        GARMENT_REFERENCE_LOCK and PRODUCT_REFERENCE_LOCK ask for. That is a
        feature, not a leak.
    `background_removal.py` is the inverse operation and the only place alpha
    is ever created. Keep the two apart.
    """
    # Data URLs were never processed historically (b64decode would fail) and
    # were returned unchanged; preserve that contract exactly.
    if image_base64.startswith("data:"):
        return image_base64
    try:
        raw = base64.b64decode(image_base64)
    except Exception:
        # Not valid base64 - best-effort: return the input unchanged.
        return image_base64
    jpeg, had_alpha = _downscale_bytes(raw, max_edge, quality)
    if jpeg is None:
        return image_base64
    result = base64.b64encode(jpeg).decode("utf-8")
    if had_alpha:
        return result
    return result if len(result) < len(image_base64) else image_base64


def crop_base64_image_to_box(
    image_base64: str,
    box: Dict[str, Any],
    padding_ratio: float = DEFAULT_CROP_PADDING_RATIO,
    padding_floor: float = DEFAULT_CROP_PADDING_FLOOR,
) -> str:
    """Crop a base64 image to a percentage bounding box, with padding.

    `box` is `{x, y, width, height}` as 0-100 percentages of the full image,
    top-left origin (the shape produced by `_normalize_bounding_box` in
    item_extraction_agent.py). Padding is added around the box (a fraction of
    the box's own size, floored at `padding_floor` percentage points) to
    absorb ordinary bbox imprecision without clipping the garment.

    Whether cropping is even a good idea (confidence, area-ratio gating) is
    the caller's decision - this function only does the pixel math. It is
    best-effort like `downscale_base64_image`: on ANY failure (bad image,
    degenerate box, decode error) the input is returned unchanged rather than
    raising, so a caller can always safely pass its reference image through
    this function.

    Applies `ImageOps.exif_transpose` before computing crop coordinates,
    since the vision model's bounding-box percentages were computed against
    an EXIF-corrected image (see `downscale_base64_image` above) while a
    freshly re-downloaded source photo may still carry raw rotation
    metadata - skipping this would misalign the crop on rotated phone photos.
    """
    try:
        x = float(box["x"])
        y = float(box["y"])
        w = float(box["width"])
        h = float(box["height"])
        if w <= 0 or h <= 0:
            return image_base64

        raw = base64.b64decode(image_base64)
        with Image.open(io.BytesIO(raw)) as img:
            # Memory: reduced-size decode for JPEG sources (see
            # _downscale_bytes). The bbox percentages are scale-invariant, so
            # cropping on the reduced image yields the same region; a
            # full-size phone photo never materializes as a full-res buffer.
            # The 2048 cap keeps generous detail for the model (which tiles at
            # ~1024-1568) while bounding decode memory.
            if img.format in _DRAFTABLE_FORMATS:
                try:
                    img.draft("RGB", (2048, 2048))
                    img.load()
                except Exception:
                    pass
            img = ImageOps.exif_transpose(img)
            if img.mode != "RGB":
                img = img.convert("RGB")
            width_px, height_px = img.size

            pad_x = max(w * padding_ratio, padding_floor)
            pad_y = max(h * padding_ratio, padding_floor)

            x0 = max(0.0, x - pad_x)
            y0 = max(0.0, y - pad_y)
            x1 = min(100.0, x + w + pad_x)
            y1 = min(100.0, y + h + pad_y)

            left = int(x0 / 100.0 * width_px)
            top = int(y0 / 100.0 * height_px)
            right = int(x1 / 100.0 * width_px)
            bottom = int(y1 / 100.0 * height_px)

            if right <= left or bottom <= top:
                return image_base64

            cropped = img.crop((left, top, right, bottom))
            buf = io.BytesIO()
            cropped.save(buf, format="JPEG", quality=90)
            return base64.b64encode(buf.getvalue()).decode("utf-8")
    except Exception:
        # ponytail: best-effort - caller's generation call works with the
        # uncropped reference image.
        return image_base64


# Trust thresholds for using a bounding box to crop the reference image for
# single-item product generation. Conservative on purpose: a wrong-region
# crop is worse than no crop at all (the model then has zero chance of
# finding the right item), so bboxes are only trusted when reasonably
# confident.
MIN_BBOX_CONFIDENCE = 0.6
# Set high on purpose: a source photo can legitimately BE a single large
# garment shot close-up (a dress/jumpsuit filling most of the frame even with
# other small items detected elsewhere, e.g. shoes in a corner). Only
# near-total-frame boxes, which really do indicate the model gave up and
# boxed the whole photo instead of localizing the item, are distrusted.
MAX_BBOX_AREA_RATIO = 0.90


def resolve_product_reference_image(
    reference_image_base64: Optional[str],
    bounding_box: Optional[Dict[str, Any]],
    confidence: float,
    sibling_count: int,
) -> Tuple[Optional[str], str]:
    """Decide what reference image (if any) to send for single-item generation.

    Never sends the full, uncropped, multi-item source photo when other
    items share the same photo - that's what causes the generator to bleed
    in other garments or pass the photo through unchanged (it asks the model
    to visually search a busy photo and self-select the right region from
    prose alone). Instead:
    - A photo with only one detected item has nothing else in frame to
      confuse the model, so the full photo is safe as-is.
    - A photo with multiple items and a trustworthy bbox gets cropped (via
      `crop_base64_image_to_box`, with generous padding to absorb bbox
      imprecision) so the model only sees the target garment.
    - A photo with multiple items and an untrustworthy/missing bbox drops
      the reference image entirely, falling back to pure text-to-image from
      the dense item description - the same mode the web app's "Regenerate"
      button already uses and reliably isolates a single item with.

    Returns (reference_image_to_use, strategy) where strategy is one of
    "none" (no source photo was ever available), "full", "crop", or
    "text_only" - callers should log this for tuning the thresholds above.
    """
    if reference_image_base64 is None:
        return None, "none"

    if sibling_count <= 1:
        return reference_image_base64, "full"

    if bounding_box:
        area_ratio = (
            float(bounding_box.get("width", 0.0)) * float(bounding_box.get("height", 0.0))
        ) / 10000.0
        if confidence >= MIN_BBOX_CONFIDENCE and area_ratio <= MAX_BBOX_AREA_RATIO:
            return crop_base64_image_to_box(reference_image_base64, bounding_box), "crop"

    return None, "text_only"
