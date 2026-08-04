"""Shared helpers for pulling JSON out of AI model responses.

Model providers often wrap JSON in markdown fences or surrounding prose.
These helpers strip the fences and locate the first top-level JSON value
(object or array) via a quote- and escape-aware bracket scan — more robust
than a greedy regex scan, which over-captures trailing prose that happens
to contain a closing brace or bracket, and immune to delimiters that appear
inside JSON string values (e.g. a garment description containing "{}").
"""

import json
import re
from typing import Any, Dict, List, Optional


def extract_json_block(text: str) -> str:
    """
    Extract the first complete top-level JSON object or array from a model
    response.

    Handles responses wrapped in markdown fences or with extra prose. The
    scan is quote- and escape-aware: object/array delimiters inside JSON
    strings (e.g. a description containing "{}" or escaped quotes) do not
    terminate the block early. Candidates that fail to parse as JSON are
    skipped, so stray braces in prose cannot poison the extraction.

    Raises ValueError when no JSON is found or every candidate is
    unterminated/malformed.
    """
    if not text:
        raise ValueError("Empty model response")

    # Remove markdown code fences if present
    fenced = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text, re.IGNORECASE)
    if fenced:
        text = fenced.group(1)

    # Walk every '{' or '[' in order, scanning a quote-aware balanced block
    # from it and keeping the first one that actually parses as JSON.
    for start, ch in enumerate(text):
        if ch not in "{[":
            continue
        block = _scan_balanced_block(text, start, ch, "}" if ch == "{" else "]")
        if block is None:
            continue
        try:
            json.loads(block)
        except json.JSONDecodeError:
            continue
        return block

    raise ValueError("Model response did not contain JSON")


def _scan_balanced_block(
    text: str,
    start: int,
    open_char: str,
    close_char: str,
) -> Optional[str]:
    """Scan a quote- and escape-aware balanced block beginning at `start`.

    Returns the matched block text, or None when no balanced close exists.
    Delimiters inside JSON strings (including escaped quotes) are ignored,
    so a `}` or `]` inside a string value cannot close the block early and
    a `{`/`[` inside a string cannot re-open it.
    """
    depth = 0
    in_string = False
    escaped = False
    for i in range(start, len(text)):
        ch = text[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
        elif ch == open_char:
            depth += 1
        elif ch == close_char:
            depth -= 1
            if depth == 0:
                return text[start : i + 1]
    return None


def safe_extract_json_object(text: str) -> Optional[Dict[str, Any]]:
    """Extract and parse the first JSON object in a model response, or None.

    Returns None when the extracted value is not an object (e.g. the model
    returned an array) so callers can fall back to their array path.
    """
    try:
        parsed = json.loads(extract_json_block(text))
        return parsed if isinstance(parsed, dict) else None
    except (ValueError, json.JSONDecodeError):
        return None


def safe_extract_json_array(text: str) -> Optional[List[Any]]:
    """Extract and parse the first JSON array in a model response, or None."""
    try:
        parsed = json.loads(extract_json_block(text))
        return parsed if isinstance(parsed, list) else None
    except (ValueError, json.JSONDecodeError):
        return None
