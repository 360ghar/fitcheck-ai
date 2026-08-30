"""Unit tests for the ChatGPT widget resource provider."""

from __future__ import annotations

import pytest

from app.mcp import widgets
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
    assert "connect_domains" in csp
    assert "resource_domains" in csp
    assert "connectDomains" not in csp
    assert "resourceDomains" not in csp


@pytest.mark.unit
def test_csp_includes_configured_image_origins(monkeypatch):
    monkeypatch.setattr(widgets.settings, "PUBLIC_API_BASE_URL", "https://api.example.com/v1")
    monkeypatch.setattr(
        widgets.settings,
        "OBJECT_STORAGE_ENDPOINT",
        "https://account.r2.cloudflarestorage.com",
    )
    monkeypatch.setattr(
        widgets.settings,
        "IMAGE_CDN_BASE_URL",
        "https://images.example.com/assets",
    )

    csp = widgets._widget_csp()["openai/widgetCSP"]
    assert csp["connect_domains"] == ["https://api.example.com"]
    assert csp["resource_domains"] == [
        "https://api.example.com",
        "https://account.r2.cloudflarestorage.com",
        "https://images.example.com",
        "https://*.r2.dev",
        "https://fitcheckaiapp.com",
    ]


@pytest.mark.unit
def test_csp_ignores_malformed_configured_origins(monkeypatch):
    monkeypatch.setattr(widgets.settings, "PUBLIC_API_BASE_URL", "https://[bad")
    monkeypatch.setattr(widgets.settings, "OBJECT_STORAGE_ENDPOINT", "https://[bad")
    monkeypatch.setattr(widgets.settings, "IMAGE_CDN_BASE_URL", "https://[bad")

    resolved = WidgetProvider().read("ui://fitcheck/wardrobe-grid.html")

    assert resolved is not None
    _, meta = resolved
    csp = meta["openai/widgetCSP"]
    assert csp["connect_domains"] == ["https://fitcheckaiapp.com"]
    assert csp["resource_domains"] == ["https://fitcheckaiapp.com", "https://*.r2.dev"]


@pytest.mark.unit
def test_read_rejects_unknown_and_unsafe_uris():
    provider = WidgetProvider()
    assert provider.read("ui://fitcheck/nope.html") is None
    assert provider.read("ui://fitcheck/../secrets.html") is None
    assert provider.read("ui://fitcheck/sub/dir.html") is None
    assert provider.read("https://other/host.html") is None
