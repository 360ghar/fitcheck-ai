"""Shared helpers for pulling JSON out of AI model responses.

Model providers often wrap JSON in markdown fences or surrounding prose.
These helpers strip the fences and locate the first top-level JSON value
(object or array) via bracket matching — more robust than a greedy regex
scan, which over-captures trailing prose that happens to contain a closing
brace or bracket.
"""

import json
import re
from typing import Any, Dict, List, Optional


def extract_json_block(text: str) -> str:
    """
    Extract the first top-level JSON object or array from a model response.

    Handles responses wrapped in markdown fences or with extra prose.
    Raises ValueError when no JSON is found or the block is unterminated.
    """
    if not text:
        raise ValueError("Empty model response")

    # Remove markdown code fences if present
    fenced = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text, re.IGNORECASE)
    if fenced:
        text = fenced.group(1)

    # Try to find JSON object first, then array
    obj_start = text.find("{")
    arr_start = text.find("[")

    if obj_start < 0 and arr_start < 0:
        raise ValueError("Model response did not contain JSON")

    # Use whichever comes first (object or array)
    if obj_start >= 0 and (arr_start < 0 or obj_start < arr_start):
        start = obj_start
        open_char, close_char = "{", "}"
    else:
        start = arr_start
        open_char, close_char = "[", "]"

    depth = 0
    for i in range(start, len(text)):
        ch = text[i]
        if ch == open_char:
            depth += 1
        elif ch == close_char:
            depth -= 1
            if depth == 0:
                return text[start : i + 1]

    raise ValueError("Unterminated JSON in model response")


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
