"""Residual branch coverage for app.utils.json_utils.

The sibling test_json_utils.py covers the extraction-scan regressions; this
file covers the remaining guards: empty input, and the type-mismatch returns
in the safe_* wrappers (array where an object was requested and vice versa).
"""

import pytest

from app.utils.json_utils import (
    extract_json_block,
    safe_extract_json_array,
    safe_extract_json_object,
)


def test_empty_text_raises_value_error():
    with pytest.raises(ValueError, match="Empty model response"):
        extract_json_block("")


def test_safe_extract_json_object_returns_none_for_array():
    assert safe_extract_json_object('["a", "b"]') is None


def test_safe_extract_json_object_returns_none_for_unparseable():
    assert safe_extract_json_object("not json at all") is None


def test_safe_extract_json_object_parses_object():
    assert safe_extract_json_object('{"ok": true}') == {"ok": True}


def test_safe_extract_json_array_returns_none_for_object():
    assert safe_extract_json_array('{"ok": true}') is None


def test_safe_extract_json_array_returns_none_for_unparseable():
    assert safe_extract_json_array("no structured data") is None


def test_safe_extract_json_array_parses_array():
    assert safe_extract_json_array('["x", 1]') == ["x", 1]
