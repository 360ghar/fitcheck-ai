"""Pins the service-only policy scoping to the migration SQL.

Migrations 030 (webhook dedupe ledgers apple_iap_events / google_rtdn_events)
and 038 (admin audit trail audit_events) created FOR ALL policies named
"Service role ..." WITHOUT a TO clause. A CREATE POLICY without TO applies to
PUBLIC, so any anon/authenticated JWT could read, forge, or delete the webhook
ledgers and the audit trail through PostgREST — the opposite of what the
policy names claim. 038 carries the fix and 039 re-scopes the 030 ledgers
(and 038 for belt-and-braces); these tests fail on any drift back to an
unscoped policy for the service-only tables.

Follows the house convention of reading the migration files directly (same as
test_job_payload_schema_sync.py).
"""

import re
from pathlib import Path

import app

MIGRATIONS_DIR = Path(app.__file__).resolve().parents[1] / "db" / "supabase" / "migrations"

# Backend/service-only tables: webhook ledgers (030) + admin audit trail (038).
SERVICE_ONLY_TABLES = {
    "public.apple_iap_events": "Service role manages apple iap events",
    "public.google_rtdn_events": "Service role manages google rtdn events",
    "public.audit_events": "Service role manages audit events",
}

_POLICY_RE = re.compile(
    r'CREATE POLICY\s+"([^"]+)"\s+ON\s+(\S+)\s+FOR\s+(\w+)'
    r"(?:\s+TO\s+([\w\s,]+?))?\s+USING",
    re.DOTALL,
)


def _policies(sql: str):
    for match in _POLICY_RE.finditer(sql):
        yield match.group(2), match.group(1), match.group(3), (match.group(4) or "").strip()


def test_038_scopes_audit_events_policy_to_service_role():
    sql = (MIGRATIONS_DIR / "038_audit_events.sql").read_text()
    found = False
    for table, name, action, to in _policies(sql):
        if table == "public.audit_events":
            found = True
            assert "service_role" in to, (
                "038 audit_events policy must be TO service_role, not PUBLIC"
            )
    assert found, "038 must define the audit_events policy"


def test_038_revokes_browser_roles_from_audit_events():
    sql = (MIGRATIONS_DIR / "038_audit_events.sql").read_text()
    assert re.search(
        r"REVOKE ALL ON public\.audit_events FROM anon,\s*authenticated", sql
    ), "038 must REVOKE audit_events from anon/authenticated (belt and braces)"


def test_039_rescopes_service_only_policies_to_service_role():
    sql = (MIGRATIONS_DIR / "039_scope_service_policies.sql").read_text()
    for table, name, action, to in _policies(sql):
        assert table in SERVICE_ONLY_TABLES, (
            f"039 must only touch backend/service-only tables, got {table}"
        )
        assert "service_role" in to, f"{table} policy must be TO service_role"


def test_039_revokes_browser_roles_from_ledgers():
    sql = (MIGRATIONS_DIR / "039_scope_service_policies.sql").read_text()
    for table in SERVICE_ONLY_TABLES:
        assert re.search(
            rf"REVOKE ALL ON {table} FROM anon,\s*authenticated", sql
        ), f"039 must REVOKE {table} from anon/authenticated"


def test_service_only_for_all_policies_are_rescoped_by_039():
    """Final applied state must be service-role-only: every unscoped FOR ALL
    policy on a service-only table (030's originals) must be re-created with
    TO service_role in 039, and no later migration may reintroduce one."""
    latest = (MIGRATIONS_DIR / "039_scope_service_policies.sql").read_text()
    latest_scoped = {
        table
        for table, name, action, to in _policies(latest)
        if "service_role" in to
    }
    assert latest_scoped >= set(SERVICE_ONLY_TABLES), (
        f"039 must scope every service-only table; missing: "
        f"{sorted(set(SERVICE_ONLY_TABLES) - latest_scoped)}"
    )
    for path in sorted(MIGRATIONS_DIR.glob("*.sql")):
        sql = path.read_text()
        for table, name, action, to in _policies(sql):
            if table in SERVICE_ONLY_TABLES and action == "ALL" and not to:
                assert table in latest_scoped, (
                    f"{path.name}: unscoped FOR ALL policy '{name}' on {table} "
                    f"applies to PUBLIC; it must be re-scoped to service_role "
                    f"in 039"
                )
