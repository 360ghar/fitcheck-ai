"""Regression tests for app.utils.json_utils JSON block extraction.

Covers the 2026-08-04 item-extraction parsing regression: delimiters inside
JSON strings (braces/escaped quotes) used to terminate the block scan early,
and stray braces in prose could poison the extraction.
"""

import json

import pytest

from app.utils.json_utils import (
    extract_json_block,
    safe_extract_json_array,
    safe_extract_json_object,
)


def test_braces_inside_strings_do_not_close_block():
    text = '{"items": [{"name": "a } b", "desc": "x {y} z"}]}'
    assert json.loads(extract_json_block(text)) == json.loads(text)


def test_brackets_inside_strings_do_not_close_array():
    text = '["a [b] c", "d]e"]'
    assert json.loads(extract_json_block(text)) == ["a [b] c", "d]e"]


def test_escaped_quotes_and_braces_inside_strings():
    text = '{"desc": "he said \\"hi{1}\\" and left", "n": 1}'
    out = extract_json_block(text)
    assert json.loads(out)["desc"] == 'he said "hi{1}" and left'


def test_open_delimiter_inside_string_does_not_reopen():
    # The '{' inside the string must not extend the block past the real close.
    text = '{"desc": "brace { here", "n": 1}'
    out = extract_json_block(text)
    assert json.loads(out) == {"desc": "brace { here", "n": 1}


def test_stray_braces_in_prose_are_skipped():
    text = 'Here is {not json} the payload: {"ok": true} trailing }'
    assert json.loads(extract_json_block(text)) == {"ok": True}


def test_unterminated_first_candidate_falls_through_to_valid_block():
    text = '{"broken": never closed then a good one: {"ok": 1}'
    assert json.loads(extract_json_block(text)) == {"ok": 1}


def test_entirely_unterminated_raises():
    with pytest.raises(ValueError, match="did not contain JSON"):
        extract_json_block('{"broken": ')


def test_no_json_raises():
    with pytest.raises(ValueError, match="did not contain JSON"):
        extract_json_block("no structured data here")


def test_prose_wrapped_fenced_still_works():
    text = 'Sure:\n```json\n{"a": [1, 2]}\n```\nThanks'
    assert json.loads(extract_json_block(text)) == {"a": [1, 2]}


def test_prose_with_braces_inside_quoted_text_keeps_first_valid_object():
    text = 'The item "shirt {red}" is here: {"category": "tops"}'
    assert json.loads(extract_json_block(text)) == {"category": "tops"}


def test_safe_extract_object_returns_none_for_array():
    assert safe_extract_json_object('[{"a": 1}]') is None


def test_safe_extract_array_recovers_braces_inside_strings():
    text = 'prefix ["red {dark}", "blue"] suffix {"extra": "{}"}'
    assert safe_extract_json_array(text) == ["red {dark}", "blue"]


def test_safe_extract_object_recovers_string_braces():
    text = 'wrapper {"desc": "tee with {pocket}", "n": 1} end'
    assert safe_extract_json_object(text) == {"desc": "tee with {pocket}", "n": 1}
