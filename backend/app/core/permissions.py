"""
RBAC role -> permission model for the admin surface.

Pure functions only (no ``app.api`` imports — architecture rule): the role
resolution and permission checks are shared by ``app.api.v1.deps`` and the
admin routers, and must stay importable from any layer.

Roles (from the 2026-08-06 admin panel spec, §4):

- ``super_admin`` — everything (``["*"]``)
- ``admin``       — everything (``["*"]``)
- ``ops``         — dashboards, subscriptions (+ refund), IAP, ops/storage,
                    audit, users (read), search
- ``support``     — dashboards, users (read), subscriptions (read), IAP,
                    quotas, feedback (+ write), audit, search
- ``content_editor`` — dashboards, blog content (+ write), promo codes (read),
                    search

Legacy fallback (kept for compatibility with the pre-RBAC admin gate in
``blog.py``): a user whose ``is_admin`` column is True OR whose email ends
with ``@fitcheckaiapp.com`` is treated as role ``admin`` unless they already
carry an explicit admin role. This preserves today's behavior verbatim while
letting the new ``role`` column take precedence.
"""

from __future__ import annotations

from typing import Any, Dict, List

ADMIN_ROLES = frozenset({"super_admin", "admin", "ops", "support", "content_editor"})

# The plain end-user role; the only non-admin role the system stores.
USER_ROLE = "user"

# Legacy bootstrap domain: any email ending with this domain is treated as
# admin when no explicit admin role is set (keeps blog.py's verify_admin
# semantics and the pre-admin-panel bootstrap path).
ADMIN_EMAIL_DOMAIN = "@fitcheckaiapp.com"

# Grant-all marker.
_ALL_PERMISSION = "*"

ROLE_PERMISSIONS: Dict[str, List[str]] = {
    "super_admin": [_ALL_PERMISSION],
    "admin": [_ALL_PERMISSION],
    "ops": [
        "dashboards.read",
        "subscriptions.read",
        "subscriptions.refund",
        "iap.read",
        "ops.read",
        "storage.cleanup",
        "audit.read",
        "users.read",
        "users.write",
        "search",
    ],
    "support": [
        "dashboards.read",
        "users.read",
        "users.write",
        "subscriptions.read",
        "iap.read",
        "quotas.read",
        "feedback.read",
        "feedback.write",
        "audit.read",
        "search",
    ],
    "content_editor": [
        "dashboards.read",
        "content.read",
        "content.write",
        "promo.read",
        "search",
    ],
}


def get_user_role(user: Dict[str, Any]) -> str:
    """Resolve a user dict to its effective role.

    Explicit admin roles win. Otherwise the legacy fallback applies: a True
    ``is_admin`` flag or an ``@fitcheckaiapp.com`` email is treated as
    ``admin``. Everything else is the plain ``user`` role.
    """
    role = user.get("role")
    if role in ADMIN_ROLES:
        return role
    if user.get("is_admin") is True:
        return "admin"
    email = str(user.get("email") or "")
    if email.endswith(ADMIN_EMAIL_DOMAIN):
        return "admin"
    return USER_ROLE


def permissions_for_role(role: str) -> List[str]:
    """Return the permission list for a role (empty for unknown roles)."""
    permissions = ROLE_PERMISSIONS.get(role)
    return list(permissions) if permissions else []


def has_permission(user: Dict[str, Any], permission: str) -> bool:
    """True when the user's effective role grants ``permission``.

    The ``*`` marker grants everything.
    """
    role = get_user_role(user)
    permissions = ROLE_PERMISSIONS.get(role, [])
    return _ALL_PERMISSION in permissions or permission in permissions


def is_admin_role(role: str) -> bool:
    """True when ``role`` is one of the admin roles (not the plain user)."""
    return role in ADMIN_ROLES
