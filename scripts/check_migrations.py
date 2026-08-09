#!/usr/bin/env python3
"""Static checks for Supabase migrations.

Catches the RLS policy bug class fixed in migration 043 (and previously 039):
a CREATE POLICY without an explicit TO clause applies to PUBLIC, so a
"Service role can manage ..." FOR ALL policy with USING (TRUE)/WITH CHECK (TRUE)
and no TO clause exposes the table to anon/authenticated PostgREST access.

Rules:
  1. Every CREATE POLICY whose statement contains "FOR ALL" must carry an
     explicit ``TO <role>`` clause. A PUBLIC FOR ALL policy is effectively
     never intended (the intentional PUBLIC read policies in 007/031 use
     FOR SELECT, which is allowed without TO).
  2. Any policy whose name starts with "Service role" must be scoped either
     with ``TO service_role`` or a guard such as ``auth.role() = 'service_role'``.
  3. Migration numeric prefixes must be unique. Documented exception: two
     files intentionally share prefix 002 (docs/references/local-setup.md).

Usage (from repo root): python3 scripts/check_migrations.py
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MIGRATIONS_DIR = ROOT / "backend" / "db" / "supabase" / "migrations"

# Documented intentional duplicate prefix (002_astrology_profile.sql and
# 002_user_profile_trigger.sql - see docs/references/local-setup.md).
KNOWN_DUPLICATE_PREFIXES = {"002"}

POLICY_RE = re.compile(r'CREATE\s+POLICY\s+"([^"]+)"(.*?);', re.DOTALL | re.IGNORECASE)


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
            has_for_all = re.search(r"\bFOR\s+ALL\b", body, re.IGNORECASE) is not None
            has_to = re.search(r"\bTO\s+\w+", body, re.IGNORECASE) is not None
            is_service_role_policy = name.lower().startswith("service role")

            if has_for_all and not has_to and "auth.role()" not in body:
                errors.append(
                    f"{path.name}: policy \"{name}\" is FOR ALL without an explicit "
                    f"TO clause or auth.role() guard - it applies to PUBLIC"
                )
            if is_service_role_policy:
                scoped = "service_role" in body or "auth.role()" in body
                if not scoped:
                    errors.append(
                        f"{path.name}: policy \"{name}\" claims service-role-only "
                        f"access but is not scoped (no TO service_role / auth.role() guard)"
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
