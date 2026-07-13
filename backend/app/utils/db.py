"""
Helpers for working with postgrest-py query results.
"""

from typing import Any, Dict, Optional


def maybe_single_data(result: Any) -> Optional[Dict[str, Any]]:
    """
    Safely extract `.data` from a `.maybe_single().execute()` result.

    postgrest-py returns a bare `None` (not a response object) when the query
    matches zero rows, so `result.data` raises `AttributeError` unless `result`
    itself is checked first.
    """
    return result.data if result else None
