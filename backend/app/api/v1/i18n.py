"""Public language metadata.

The client ships its own locale table, so it does not need this endpoint to
render. It exists so that:

* the supported set is discoverable without reading the app binary,
* a client newer or older than the backend can detect the mismatch instead of
  silently sending a header the server ignores, and
* the store-listing tooling has one HTTP source of truth to cross-check against
  `store/asc/locales.json`.

Unauthenticated on purpose: it is static, non-sensitive, and useful before
sign-in (the language picker is on the first-run screen).
"""

from __future__ import annotations

from typing import Any, Dict, Optional

from fastapi import APIRouter, Request

from app.core.i18n import (
    DEFAULT_LANGUAGE,
    SUPPORTED_LANGUAGES,
    is_rtl,
    normalize_language,
    supported_languages,
)
from app.core.middleware import get_request_language

router = APIRouter()


@router.get("/languages")
async def list_languages() -> Dict[str, Any]:
    """Every language the app and store listing support."""
    return {
        "data": {
            "default": DEFAULT_LANGUAGE,
            "count": len(SUPPORTED_LANGUAGES),
            "languages": supported_languages(),
        },
        "message": "OK",
    }


@router.get("/resolve")
async def resolve_language(request: Request, tag: Optional[str] = None) -> Dict[str, Any]:
    """Normalize an arbitrary tag, or report what this request resolved to.

    Used by the client when it needs to know which of its locales the server
    will actually answer in — for example, to show "AI answers in {language}"
    in the picker. With no `tag` this reports the request's *effective*
    language (the `Content-Language` the response carries), not just the
    header, so an authenticated caller that saved a choice in settings sees
    that choice here too.
    """
    requested = tag or request.headers.get("Accept-Language")

    def describe(value: Optional[str]) -> Dict[str, Any]:
        code = normalize_language(value)
        name = dict(SUPPORTED_LANGUAGES).get(code, "English")
        return {"code": code, "name": name, "rtl": is_rtl(code)}

    return {
        "data": {
            "requested": requested,
            "resolved": describe(tag) if tag else describe(get_request_language()),
            "default": describe(DEFAULT_LANGUAGE),
        },
        "message": "OK",
    }
