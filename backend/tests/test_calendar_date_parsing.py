"""
Regression test for the calendar events date-parsing helper.

The Flutter app sends DateTime.toIso8601String() (e.g. "2026-07-01T00:00:00.000"),
while the web frontend sends a bare date ("2026-07-01"). The endpoint used to
blindly concatenate "T00:00:00", which mangled the Flutter format into
"2026-07-01T00:00:00.000T00:00:00" and made Postgres reject the query.
"""
import pytest

from app.api.v1.calendar import _parse_date_only
from app.core.exceptions import ValidationError


def test_parse_date_only_accepts_bare_date():
    assert _parse_date_only("2026-07-01", "start_date") == "2026-07-01"


def test_parse_date_only_accepts_flutter_iso_datetime():
    assert _parse_date_only("2026-07-01T00:00:00.000", "start_date") == "2026-07-01"


def test_parse_date_only_rejects_garbage_input():
    with pytest.raises(ValidationError):
        _parse_date_only("notadate", "start_date")
