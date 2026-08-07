"""Tests for app.utils.process_metrics: current-RSS reporting.

The 2026-08-03 memory-budget work switched get_rss_mb() from ru_maxrss (the
ALL-TIME PEAK, which never decreases) to current RSS from /proc/self/status
so /health and log_memory actually reflect whether memory returns to baseline
after AI bursts. These tests pin the parsing and the fallback.
"""

import pytest

from app.utils import process_metrics
from app.utils.process_metrics import get_rss_mb


class _FakeStatus:
    """Stand-in for /proc/self/status with a fixed VmRSS line."""

    def __init__(self, text: str):
        self._lines = text.splitlines()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def __iter__(self):
        return iter(self._lines)


def _no_proc(monkeypatch):
    """Make /proc/self/status unreadable, like macOS local dev."""
    monkeypatch.setattr(
        "builtins.open",
        lambda *a, **k: (_ for _ in ()).throw(FileNotFoundError()),
    )


def test_reads_vmrss_from_proc(monkeypatch):
    monkeypatch.setattr(
        "builtins.open",
        lambda *a, **k: _FakeStatus(
            "Name:\tpython\nVmRSS:\t  262144 kB\nVmSize:\t1048576 kB\n"
        ),
    )
    # 262144 kB / 1024 = 256 MB
    assert get_rss_mb() == 256.0


def test_proc_line_with_tabs_and_spaces(monkeypatch):
    monkeypatch.setattr(
        "builtins.open",
        lambda *a, **k: _FakeStatus("VmRSS:\t12345 kB\n"),
    )
    assert get_rss_mb() == pytest.approx(12.1, abs=0.1)


def test_missing_proc_falls_back_to_getrusage(monkeypatch):
    _no_proc(monkeypatch)

    class _Usage:
        ru_maxrss = 4096  # kB on Linux

    monkeypatch.setattr(
        process_metrics.resource,
        "getrusage",
        lambda who: _Usage(),
    )
    assert get_rss_mb() == pytest.approx(4.0, abs=0.1)


def test_macos_byte_units_fallback(monkeypatch):
    """macOS reports ru_maxrss in BYTES; the heuristic must convert them."""
    _no_proc(monkeypatch)

    class _Usage:
        ru_maxrss = 300 * 1024 * 1024  # 300 MB in bytes

    monkeypatch.setattr(
        process_metrics.resource,
        "getrusage",
        lambda who: _Usage(),
    )
    assert get_rss_mb() == pytest.approx(300.0, abs=0.1)


def test_total_failure_returns_none(monkeypatch):
    _no_proc(monkeypatch)
    monkeypatch.setattr(
        process_metrics.resource,
        "getrusage",
        lambda who: (_ for _ in ()).throw(RuntimeError("no resource")),
    )
    assert get_rss_mb() is None
