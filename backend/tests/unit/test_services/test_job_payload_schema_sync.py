"""Pins the durable-row payload contract to the migration SQL.

`_build_persisted_payload` upserts into `photoshoot_jobs` through PostgREST,
which rejects payload keys that are not columns of the table (PGRST204). A
payload key added without a matching migration therefore breaks EVERY job
create and terminal transition on the hosted DB — which is exactly what a
missing `image_failures` column would have done to the 2026-08-05
photoshooot 0-images fix (caught in self-review; migration 035 adds it).

This test parses the migration files and fails on any drift between the
payload the service writes and the columns the migrations declare.
"""

import re
from datetime import datetime, timezone
from pathlib import Path

import app

from app.models.photoshoot import PhotoshootJobStatus
from app.services.photoshoot_job_service import (
    PhotoshootJob,
    _build_persisted_payload,
)

MIGRATIONS_DIR = (
    Path(app.__file__).resolve().parents[1] / "db" / "supabase" / "migrations"
)

USER_ID = "11111111-1111-1111-1111-111111111111"

# Line prefixes inside a CREATE TABLE block that are not column declarations.
_NON_COLUMN_PREFIXES = (
    "--",
    "CONSTRAINT",
    "CHECK",
    "PRIMARY",
    "UNIQUE",
    "FOREIGN",
    "REFERENCES",
)


def _photoshoot_jobs_columns() -> set:
    """All columns declared for `photoshoot_jobs` across every migration."""
    columns = set()
    for path in sorted(MIGRATIONS_DIR.glob("*.sql")):
        sql = path.read_text()
        create = re.search(
            r"CREATE TABLE IF NOT EXISTS public\.photoshoot_jobs\s*\((.*?)\);",
            sql,
            re.DOTALL,
        )
        if create:
            for line in create.group(1).splitlines():
                stripped = line.strip().rstrip(",")
                if stripped and not stripped.startswith(_NON_COLUMN_PREFIXES):
                    columns.add(stripped.split()[0])
        for add in re.finditer(
            r"ALTER TABLE (?:IF EXISTS )?public\.photoshoot_jobs\s+"
            r"ADD COLUMN (?:IF NOT EXISTS )?(\w+)",
            sql,
        ):
            columns.add(add.group(1))
    return columns


def test_photoshoot_persisted_payload_keys_have_columns_in_migrations():
    job = PhotoshootJob(
        job_id="job-1",
        user_id=USER_ID,
        status=PhotoshootJobStatus.PROCESSING,
        created_at=datetime.now(timezone.utc),
        photos=["base64"],
        use_case="linkedin",
        num_images=2,
        batch_size=2,
        session_id="sess-1",
        # failed_indices is derived from image_failures, not constructed.
        image_failures={0: "provider error"},
    )
    assert job.failed_indices == {0}
    payload = _build_persisted_payload(job)
    columns = _photoshoot_jobs_columns()

    assert columns, "migrations parse produced no photoshoot_jobs columns"
    missing = sorted(set(payload) - columns)
    assert not missing, (
        f"Persisted payload keys with no photoshoot_jobs column in migrations: "
        f"{missing}. PostgREST rejects unknown columns on upsert/update, so "
        f"every job create and terminal transition would fail on the hosted "
        f"DB. Add an idempotent migration (ALTER TABLE ... ADD COLUMN) "
        f"alongside the payload change."
    )
