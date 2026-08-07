"""Residual coverage for the small util modules.

Targets the remaining missed lines/branches in app/utils/retry.py,
app/utils/process_metrics.py, app/utils/background_removal.py, and
app/utils/image_processing.py (full-suite coverage report).
"""

import io

import pytest
from PIL import Image

from app.utils import background_removal
from app.utils import process_metrics
from app.utils.background_removal import remove_white_background_base64
from app.utils.image_processing import decode_and_validate_base64_image
from app.utils.retry import with_retry


# ---------------------------------------------------------------------------
# app/utils/retry.py
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_with_retry_negative_max_retries_hits_defensive_tail():
    async def _fail():
        raise RuntimeError("never called")

    with pytest.raises(RuntimeError, match="Unexpected state"):
        await with_retry(_fail, max_retries=-1)


# ---------------------------------------------------------------------------
# app/utils/process_metrics.py
# ---------------------------------------------------------------------------


def test_get_rss_mb_reads_proc_status(monkeypatch):
    class _FakeStatus:
        def __enter__(self):
            return self

        def __exit__(self, *exc):
            return False

        def __iter__(self):
            return iter(["Name:\tpython", "VmRSS:\t  123456 kB"])

    monkeypatch.setattr("builtins.open", lambda *a, **k: _FakeStatus())
    assert process_metrics.get_rss_mb() == round(123456 / 1024.0, 1)


def test_get_rss_mb_proc_file_without_vmrss_falls_back(monkeypatch):
    class _NoVmRSS:
        def __enter__(self):
            return self

        def __exit__(self, *exc):
            return False

        def __iter__(self):
            return iter(["Name:\tpython", "VmSize:\t1 kB"])

    monkeypatch.setattr("builtins.open", lambda *a, **k: _NoVmRSS())

    class _FakeUsage:
        ru_maxrss = 256 * 1024

    monkeypatch.setattr(process_metrics.resource, "getrusage", lambda who: _FakeUsage())
    assert process_metrics.get_rss_mb() == 256.0


def test_get_rss_mb_falls_back_to_getrusage(monkeypatch):
    class _NoProc:
        def __enter__(self):
            raise FileNotFoundError()

        def __exit__(self, *exc):
            return False

        def __iter__(self):
            return iter([])

    monkeypatch.setattr("builtins.open", lambda *a, **k: _NoProc())

    class _FakeUsage:
        ru_maxrss = 512 * 1024  # kB on Linux

    monkeypatch.setattr(process_metrics.resource, "getrusage", lambda who: _FakeUsage())
    assert process_metrics.get_rss_mb() == 512.0


def test_get_rss_mb_getrusage_bytes_heuristic(monkeypatch):
    class _NoProc:
        def __enter__(self):
            raise FileNotFoundError()

        def __exit__(self, *exc):
            return False

        def __iter__(self):
            return iter([])

    monkeypatch.setattr("builtins.open", lambda *a, **k: _NoProc())

    class _FakeUsage:
        ru_maxrss = 536870912  # 512 MiB as bytes (macOS)

    monkeypatch.setattr(process_metrics.resource, "getrusage", lambda who: _FakeUsage())
    assert process_metrics.get_rss_mb() == 512.0


def test_get_rss_mb_getrusage_failure_returns_none(monkeypatch):
    class _NoProc:
        def __enter__(self):
            raise FileNotFoundError()

        def __exit__(self, *exc):
            return False

        def __iter__(self):
            return iter([])

    monkeypatch.setattr("builtins.open", lambda *a, **k: _NoProc())
    monkeypatch.setattr(
        process_metrics.resource, "getrusage", lambda who: (_ for _ in ()).throw(RuntimeError())
    )
    assert process_metrics.get_rss_mb() is None


def test_log_memory_rate_limit_early_return(monkeypatch):
    import time

    calls = []

    def _fake_info(msg, *args, **kwargs):
        calls.append(msg)

    monkeypatch.setattr(process_metrics.logger, "info", _fake_info)
    monkeypatch.setattr(process_metrics, "_last_log_at", time.monotonic())
    monkeypatch.setattr(process_metrics, "_MIN_LOG_INTERVAL_S", 120.0)

    # force=False within the window -> early return, nothing logged.
    process_metrics.log_memory("probe")
    assert calls == []

    # force=True bypasses the rate limit.
    process_metrics.log_memory("probe", force=True)
    assert len(calls) == 1


# ---------------------------------------------------------------------------
# app/utils/background_removal.py
# ---------------------------------------------------------------------------


def test_matte_extension_maps_webp():
    assert background_removal.matte_extension() == ".webp"


def test_base64_wrapper_decode_failure_echoes_input():
    raw, status = remove_white_background_base64("!!!not-base64!!!")
    assert raw == "!!!not-base64!!!"
    assert status == background_removal.STATUS_ERROR


def test_mask_fraction_counts_set_pixels():
    mask = Image.new("L", (10, 10), 0)
    assert background_removal._mask_fraction(mask) == 0.0
    for x in range(5):
        for y in range(10):
            mask.putpixel((x, y), 255)
    assert background_removal._mask_fraction(mask) == 0.5


def test_existing_alpha_fraction_fully_opaque():
    img = Image.new("RGBA", (8, 8), (255, 255, 255, 255))
    assert background_removal._existing_alpha_fraction(img) == 0.0


def test_center_opacity_with_fully_opaque_center():
    # In this module 255 marks the removed background, so an all-white mask
    # has zero center opacity and an all-black mask is fully opaque.
    img = Image.new("L", (100, 100), 255)
    assert background_removal._center_opacity(img) == 0.0
    img2 = Image.new("L", (100, 100), 0)
    assert background_removal._center_opacity(img2) == 1.0


# ---------------------------------------------------------------------------
# app/utils/image_processing.py
# ---------------------------------------------------------------------------


def test_decode_and_validate_rejects_data_url_without_base64():
    with pytest.raises(ValueError, match="must contain base64-encoded data"):
        decode_and_validate_base64_image("data:image/png,AAAA", max_bytes=1000)


def test_decode_and_validate_accepts_base64_data_url():
    tiny_png = (
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk"
        "+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    decoded = decode_and_validate_base64_image(
        f"data:image/png;base64,{tiny_png}", max_bytes=1000
    )
    assert decoded.startswith(b"\x89PNG")


def test_sniff_image_mime_pillow_format_fallback():
    from app.utils.image_processing import sniff_image_mime

    buf = io.BytesIO()
    Image.new("RGB", (4, 4), (10, 20, 30)).save(buf, format="PNG")
    assert sniff_image_mime(buf.getvalue()) == "image/png"
