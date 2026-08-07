#!/usr/bin/env python3
"""Export the backend's OpenAPI schema for the admin frontend contract.

Dumps ``GET /api/v1/openapi.json`` (via TestClient, no live services touched
— Supabase clients are lazy and the schema endpoints are unauthenticated) to
``admin/contracts/openapi.json``. The admin app's ``openapi-typescript``
codegen consumes this file, and CI drift-checks it.

Usage (from the repo root or the backend dir):

    cd backend && source .venv/bin/activate
    python scripts/export_openapi.py

Env: reads the same ``backend/.env`` / root ``.env`` as the app (settings are
local env; no network is required).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = BACKEND_DIR.parents[0]
OUTPUT_PATH = REPO_ROOT / "admin" / "contracts" / "openapi.json"

# Make the backend package importable when run from either the backend dir or
# the repo root.
sys.path.insert(0, str(BACKEND_DIR))

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


def main() -> int:
    client = TestClient(app)
    response = client.get("/api/v1/openapi.json")
    if response.status_code != 200:
        print(
            f"OpenAPI export failed: GET /api/v1/openapi.json -> {response.status_code}",
            file=sys.stderr,
        )
        return 1

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(
        json.dumps(response.json(), indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"OpenAPI exported to {OUTPUT_PATH} ({len(response.content)} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
