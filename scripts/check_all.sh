#!/usr/bin/env bash
# Agent-friendly aggregate checks for the FitCheck harness.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== architecture =="
python3 scripts/check_architecture.py

echo "== docs structure =="
python3 scripts/check_docs_structure.py

if [[ -x "$ROOT/backend/.venv/bin/pytest" ]]; then
  echo "== backend pytest =="
  (
    cd backend
    # shellcheck disable=SC1091
    source .venv/bin/activate
    PYTHONPATH=. pytest -q
  )
else
  echo "== backend pytest skipped (no backend/.venv) =="
fi

echo "All requested checks finished."
