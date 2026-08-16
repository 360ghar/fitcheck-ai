"""
Regression tests: get_client_ip must resolve the client from the LAST
X-Forwarded-For entry — the hop only the trusted edge proxy can append
(A5-01). uvicorn's ProxyHeadersMiddleware resolves request.client.host from
the FIRST entry, which any peer that can reach uvicorn directly can forge;
rotating that header on every request defeats the per-IP limits entirely.
The deployment topology (container reachable only via Railway's edge proxy,
which APPENDS the real client IP) makes the last entry the trusted hop.
"""
from unittest.mock import Mock

from starlette.datastructures import Headers

from app.core.ip_rate_limit import get_client_ip


def test_get_client_ip_uses_last_forwarded_hop():
    """Client-supplied leading hops are ignored; the proxy-appended hop wins."""
    request = Mock()
    request.client.host = "10.0.0.1"
    # Real starlette Headers (case-insensitive): the impl reads the lowercase
    # key, exactly as the framework would serve it.
    request.headers = Headers({"X-Forwarded-For": "1.2.3.4, 5.6.7.8"})

    assert get_client_ip(request) == "5.6.7.8"


def test_get_client_ip_single_forwarded_hop():
    request = Mock()
    request.client.host = "10.0.0.1"
    request.headers = Headers({"X-Forwarded-For": "1.2.3.4"})

    assert get_client_ip(request) == "1.2.3.4"


def test_get_client_ip_rejects_malformed_last_hop():
    """A non-IP last hop cannot be trusted — fall back to the resolved peer."""
    request = Mock()
    request.client.host = "10.0.0.1"
    request.headers = Headers({"X-Forwarded-For": "1.2.3.4, not-an-ip"})

    assert get_client_ip(request) == "10.0.0.1"


def test_get_client_ip_without_header_uses_resolved_peer():
    request = Mock()
    request.client.host = "10.0.0.1"
    request.headers = Headers()

    assert get_client_ip(request) == "10.0.0.1"


def test_get_client_ip_handles_missing_client():
    request = Mock()
    request.client = None
    request.headers = Headers()

    assert get_client_ip(request) == "unknown"
