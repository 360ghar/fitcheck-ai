"""Unit tests for the ChatGPT widget resource provider."""

from __future__ import annotations

import pytest

from app.mcp.widgets import WidgetProvider


@pytest.mark.unit
def test_lists_built_widget_bundles():
    provider = WidgetProvider()
    widgets = provider.list()
    names = {w["name"] for w in widgets}
    # Built by `cd widgets && npm run build` (see widgets/README.md).
    assert "wardrobe-grid.html" in names
    assert "outfit-cards.html" in names
    assert all(w["uri"].startswith("ui://fitcheck/") for w in widgets)
    assert all(w["mimeType"] == "text/html" for w in widgets)


@pytest.mark.unit
def test_read_returns_html_with_csp_meta():
    provider = WidgetProvider()
    resolved = provider.read("ui://fitcheck/wardrobe-grid.html")
    assert resolved is not None
    html, meta = resolved
    assert html.lstrip().lower().startswith("<!doctype html")
    csp = meta["openai/widgetCSP"]
    assert "connectDomains" in csp
    assert "resourceDomains" in csp


@pytest.mark.unit
def test_read_rejects_unknown_and_unsafe_uris():
    provider = WidgetProvider()
    assert provider.read("ui://fitcheck/nope.html") is None
    assert provider.read("ui://fitcheck/../secrets.html") is None
    assert provider.read("ui://fitcheck/sub/dir.html") is None
    assert provider.read("https://other/host.html") is None
