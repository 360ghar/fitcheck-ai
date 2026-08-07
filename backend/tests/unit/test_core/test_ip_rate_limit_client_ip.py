"""
Regression test: get_client_ip must not trust a client-supplied
X-Forwarded-For header directly - a single caller could set a different
value on every request to get a fresh IP-based rate-limit bucket and bypass
the demo per-IP daily limits entirely. Real client-IP resolution now happens
in uvicorn's ProxyHeadersMiddleware (see Dockerfile --proxy-headers), which
populates request.client.host itself.
"""
from unittest.mock import Mock

from app.core.ip_rate_limit import get_client_ip


def test_get_client_ip_ignores_spoofed_forwarded_header():
    request = Mock()
    request.client.host = "10.0.0.1"
    request.headers = {"X-Forwarded-For": "1.2.3.4", "X-Real-IP": "5.6.7.8"}

    assert get_client_ip(request) == "10.0.0.1"


def test_get_client_ip_handles_missing_client():
    request = Mock()
    request.client = None
    request.headers = {}

    assert get_client_ip(request) == "unknown"
