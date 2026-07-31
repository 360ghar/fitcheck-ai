#!/usr/bin/env bash
# Agent-friendly aggregate checks for the FitCheck harness.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== architecture =="
python3 scripts/check_architecture.py

echo "== docs structure =="
python3 scripts/check_docs_structure.py

echo "== theme tokens =="
python3 scripts/check_theme_tokens.py

if [[ -x "$ROOT/backend/.venv/bin/pytest" ]]; then
  echo "== backend pytest =="
  (
    cd backend
    # shellcheck disable=SC1091
    source .venv/bin/activate
    PYTHONPATH=. pytest -q
  )
else
  if [[ "${ALLOW_NO_PYTEST:-0}" == "1" || "${1:-}" == "--allow-no-pytest" ]]; then
    echo "== backend pytest skipped (--allow-no-pytest; no backend/.venv) =="
  else
    echo "== backend pytest failed: backend/.venv/bin/pytest not found. Install backend dependencies or pass --allow-no-pytest. ==" >&2
    exit 1
  fi
fi

echo "All requested checks finished."
