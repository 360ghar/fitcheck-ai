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
``blog.py``): a user whose ``is_admin`` column is True is treated as role
``admin`` unless they already carry an explicit admin role. The previous
email-domain bootstrap (any ``@fitcheckaiapp.com`` email treated as admin)
was removed on 2026-08-08: registration is not domain-verified, so a
self-registered address must not grant admin. Admin access now requires an
explicit ``role`` (or the ``is_admin`` flag).
"""

from __future__ import annotations

from typing import Any, Dict, List

ADMIN_ROLES = frozenset({"super_admin", "admin", "ops", "support", "content_editor"})

# The plain end-user role; the only non-admin role the system stores.
USER_ROLE = "user"

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
    ``is_admin`` flag is treated as ``admin`` (the email-domain bootstrap
    was removed 2026-08-08 — self-registered addresses must not grant
    admin). Everything else is the plain ``user`` role.
    """
    role = user.get("role")
    if role in ADMIN_ROLES:
        return role
    if user.get("is_admin") is True:
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
