"""ChatGPT widget resources (``ui://fitcheck/<name>.html``).

Apps-SDK widgets are HTML bundles rendered in an iframe inside ChatGPT. The
``widgets/`` Vite app builds single-file bundles (vite-plugin-singlefile) into
``backend/app/mcp/static/``; this provider exposes them as MCP resources so
tools can reference them via ``_meta["openai/outputTemplate"]``.

Widget runtime contract (see widgets/src/lib/openai.ts):
- initial data arrives via ``window.openai.toolOutput`` (= the tool's
  structuredContent),
- follow-up calls go through ``window.openai.callTool`` (no direct API/CORS),
- theming via ``window.openai.theme``.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

from app.core.config import settings

logger = logging.getLogger(__name__)

STATIC_DIR = Path(__file__).resolve().parent / "static"
WIDGET_URI_PREFIX = "ui://fitcheck/"
WIDGET_MIME = "text/html"


def _widget_csp() -> dict[str, Any]:
    """Apps-SDK CSP declaration attached to every widget resource."""
    def origin(value: str) -> str | None:
        parsed = urlsplit((value or "").strip())
        if not parsed.scheme or not parsed.netloc:
            return None
        return f"{parsed.scheme}://{parsed.netloc}"

    base = origin(settings.PUBLIC_API_BASE_URL) or "https://fitcheckaiapp.com"
    resource_domains = list(
        dict.fromkeys(
            domain
            for domain in (
                base,
                origin(settings.OBJECT_STORAGE_ENDPOINT),
                origin(settings.IMAGE_CDN_BASE_URL),
                "https://*.r2.dev",
                "https://fitcheckaiapp.com",
            )
            if domain
        )
    )
    return {
        "openai/widgetCSP": {
            # Widgets talk to the API through window.openai.callTool, not
            # fetch(); the API origin is whitelisted for outbound images
            # (R2/Cloudflare Worker photo URLs live on their own domain).
            "connect_domains": [base],
            "resource_domains": resource_domains,
        }
    }


class WidgetProvider:
    """Serves built widget bundles as ui:// MCP resources."""

    def __init__(self, directory: Path = STATIC_DIR) -> None:
        self._directory = directory

    def list(self) -> list[dict[str, Any]]:
        if not self._directory.exists():
            return []
        widgets = sorted(self._directory.glob("*.html"))
        return [
            {
                "uri": f"{WIDGET_URI_PREFIX}{path.name}",
                "name": path.name,
                "description": f"FitCheck ChatGPT widget: {path.stem}",
                "mimeType": WIDGET_MIME,
            }
            for path in widgets
        ]

    def read(self, uri: str) -> tuple[str, dict[str, Any]] | None:
        """Return (html, resource_meta) for a ui:// URI, or None if unknown."""
        if not uri.startswith(WIDGET_URI_PREFIX):
            return None
        filename = uri[len(WIDGET_URI_PREFIX):]
        # Prevent path traversal: only bare .html filenames in the static dir.
        if "/" in filename or ".." in filename or not filename.endswith(".html"):
            return None
        path = self._directory / filename
        if not path.is_file():
            return None
        try:
            html = path.read_text(encoding="utf-8")
        except OSError:
            logger.exception("Failed reading widget bundle %s", path)
            return None
        return html, _widget_csp()
