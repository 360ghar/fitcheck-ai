#!/usr/bin/env python3
"""Static checks for Supabase migrations.

Catches the RLS policy bug class fixed in migration 043 (and previously 039):
a CREATE POLICY without an explicit TO clause applies to PUBLIC, so a
"Service role can manage ..." FOR ALL policy with USING (TRUE)/WITH CHECK (TRUE)
and no TO clause exposes the table to anon/authenticated PostgREST access.

Rules:
  1. Every CREATE POLICY whose statement contains "FOR ALL" must carry an
     explicit ``TO <role>`` clause AND that clause must not grant PUBLIC,
     anon, or authenticated (a PUBLIC FOR ALL policy is effectively never
     intended - the intentional PUBLIC read policies in 007/031 use
     FOR SELECT, which is allowed without TO).
  2. Any policy whose name starts with "Service role" must be scoped either
     with exactly ``TO service_role`` (no anon/authenticated/PUBLIC mixed
     in the role list) or a guard such as ``auth.role() = 'service_role'``.
  3. Migration numeric prefixes must be unique. Documented exception: two
     files intentionally share prefix 002 (docs/references/local-setup.md).

Usage (from repo root): python3 scripts/check_migrations.py
"""

import re
import sys
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parent.parent
MIGRATIONS_DIR = ROOT / "backend" / "db" / "supabase" / "migrations"

# Documented intentional duplicate prefix (002_astrology_profile.sql and
# 002_user_profile_trigger.sql - see docs/references/local-setup.md).
KNOWN_DUPLICATE_PREFIXES = {"002"}

POLICY_RE = re.compile(r'CREATE\s+POLICY\s+"([^"]+)"(.*?);', re.DOTALL | re.IGNORECASE)

# Roles that must never receive unrestricted access from a FOR ALL policy or a
# "Service role" policy. The backend calls RPCs/reads with the service-role
# client; anon/authenticated are the browser PostgREST roles.
_PUBLIC_ROLES = {"public", "anon", "authenticated"}


def _policy_to_roles(body: str) -> Optional[list[str]]:
    """Parse the role list of a policy's ``TO <roles>`` clause.

    Returns the list of role names, or None when the policy has no TO clause
    (which means PUBLIC). ``TO`` may be followed by an optional ``GROUP``/
    ``ROLE`` keyword, e.g. ``TO ROLE service_role, anon``.
    """
    # The role list runs up to the next clause keyword (USING/WITH/FOR) or the
    # end of the body. The body has already had its trailing ``;`` stripped by
    # POLICY_RE, so a policy whose TO clause ends the body
    # (``... FOR ALL TO public``) must terminate the list WITHOUT requiring
    # preceding whitespace: the ``\s+(?:USING|WITH|FOR)`` branch needs the gap,
    # but the ``$`` (end-of-body) branch matches on its own.
    to_match = re.search(
        r"\bTO\s+(?:GROUP\s+|ROLE\s+)?([^;]+?)(?:\s+(?:USING|WITH|FOR)\b|$)",
        body,
        re.IGNORECASE | re.DOTALL,
    )
    if not to_match:
        return None
    roles = [r.strip().strip('"').lower() for r in to_match.group(1).split(",")]
    return [r for r in roles if r]


def _is_exactly_service_role(roles: Optional[list[str]]) -> bool:
    """True when the TO role list is exactly [service_role]."""
    return roles is not None and len(roles) == 1 and roles[0] == "service_role"


def _strip_sql_comments(body: str) -> str:
    """Remove SQL comments from a policy body before the role-list parser runs.

    The role-list parser runs ``\\bTO\\s+`` over the body, so a trailing
    ``-- scoped to public`` style comment (common after ``USING (true)``) would
    otherwise be misread as a real ``TO public`` grant and fail the check on a
    policy that is actually safe. Both comment forms are stripped: ``--`` line
    comments and ``/* ... */`` block comments — a ``TO`` role name inside a
    block comment is still a comment, not a grant.
    """
    body = re.sub(r"--[^\n]*", "", body)
    return re.sub(r"/\*.*?\*/", "", body, flags=re.DOTALL)


def check_migrations() -> int:
    if not MIGRATIONS_DIR.is_dir():
        print(f"error: migrations directory not found: {MIGRATIONS_DIR}")
        return 1

    errors: list[str] = []
    seen_prefixes: dict[str, str] = {}

    for path in sorted(MIGRATIONS_DIR.glob("*.sql")):
        match = re.match(r"^(\d{3})_", path.name)
        if match:
            prefix = match.group(1)
            if prefix in seen_prefixes and prefix not in KNOWN_DUPLICATE_PREFIXES:
                errors.append(
                    f"{path.name}: duplicate migration prefix {prefix} "
                    f"(also used by {seen_prefixes[prefix]})"
                )
            seen_prefixes[prefix] = path.name

        text = path.read_text(encoding="utf-8")
        for policy_match in POLICY_RE.finditer(text):
            name = policy_match.group(1).strip()
            body = policy_match.group(2)
            # Strip `--` comments first so a trailing "TO ... -- note" comment
            # cannot be misread as a real role grant (see _strip_sql_comments).
            body = _strip_sql_comments(body)
            has_for_all = re.search(r"\bFOR\s+ALL\b", body, re.IGNORECASE) is not None
            has_to = re.search(r"\bTO\s+\w+", body, re.IGNORECASE) is not None
            is_service_role_policy = name.lower().startswith("service role")
            roles = _policy_to_roles(body)

            if has_for_all and not has_to and "auth.role()" not in body:
                errors.append(
                    f"{path.name}: policy \"{name}\" is FOR ALL without an explicit "
                    f"TO clause or auth.role() guard - it applies to PUBLIC"
                )
            if has_for_all and roles is not None and not _is_exactly_service_role(roles):
                # A FOR ALL policy scoped to PUBLIC (or anon/authenticated) is
                # the same unrestricted grant the docstring forbids - the
                # TO PUBLIC syntax passes a naive `TO <word>` check.
                if any(r in _PUBLIC_ROLES for r in roles):
                    errors.append(
                        f"{path.name}: policy \"{name}\" is FOR ALL and grants "
                        f"unrestricted access to {', '.join(sorted(roles))} - "
                        f"reject public roles on FOR ALL policies"
                    )
            if is_service_role_policy:
                if "auth.role()" in body:
                    continue
                scoped = _is_exactly_service_role(roles)
                if not scoped:
                    detail = ""
                    if roles is not None:
                        detail = f" (TO {', '.join(sorted(roles))})"
                    errors.append(
                        f"{path.name}: policy \"{name}\" claims service-role-only "
                        f"access but is not scoped to exactly TO service_role "
                        f"(or an auth.role() guard){detail}"
                    )

    if errors:
        print("Migration checks FAILED:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print(
        f"Migration checks OK ({len(list(MIGRATIONS_DIR.glob('*.sql')))} files, "
        f"no unscoped FOR ALL policies, no duplicate prefixes)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(check_migrations())
