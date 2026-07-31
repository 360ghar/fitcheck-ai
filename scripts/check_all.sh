#!/usr/bin/env bash
# Agent-friendly aggregate checks for the FitCheck harness.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ALLOW_NO_PYTEST="${ALLOW_NO_PYTEST:-0}"
ALLOW_MISSING_CHECKS="${ALLOW_MISSING_CHECKS:-0}"
RUN_FRONTEND_BUILD="${RUN_FRONTEND_BUILD:-0}"

for arg in "$@"; do
  case "$arg" in
    --allow-no-pytest) ALLOW_NO_PYTEST=1 ;;
    --allow-missing-checks) ALLOW_MISSING_CHECKS=1 ;;
    --include-frontend-build) RUN_FRONTEND_BUILD=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

missing_check() {
  if [[ "$ALLOW_MISSING_CHECKS" == "1" ]]; then
    echo "== $1 skipped: $2 =="
  else
    echo "== $1 unavailable: $2; pass --allow-missing-checks to skip ==" >&2
    exit 1
  fi
}

echo "== architecture =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_architecture.py

echo "== docs structure =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_docs_structure.py

echo "== theme tokens =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_theme_tokens.py

if [[ -x "$ROOT/backend/.venv/bin/ruff" ]]; then
  echo "== backend ruff =="
  (cd backend && .venv/bin/ruff check .)
elif command -v ruff >/dev/null 2>&1; then
  echo "== backend ruff (system) =="
  (cd backend && ruff check .)
else
  missing_check "backend ruff" "backend/.venv/bin/ruff not found"
fi

if [[ -x "$ROOT/backend/.venv/bin/pytest" ]]; then
  echo "== backend pytest =="
  (
    cd backend
    # shellcheck disable=SC1091
    source .venv/bin/activate
    PYTHONPATH=. pytest -q
  )
else
  if [[ "$ALLOW_NO_PYTEST" == "1" ]]; then
    echo "== backend pytest skipped (--allow-no-pytest; no backend/.venv) =="
  else
    echo "== backend pytest failed: backend/.venv/bin/pytest not found. Install backend dependencies or pass --allow-no-pytest. ==" >&2
    exit 1
  fi
fi

if [[ -x "$ROOT/frontend/node_modules/.bin/eslint" && -x "$ROOT/frontend/node_modules/.bin/vitest" ]]; then
  echo "== frontend lint =="
  (cd frontend && npm run lint)
  echo "== frontend vitest =="
  (cd frontend && npm test -- --run)
else
  missing_check "frontend lint/vitest" "frontend local node_modules binaries not found"
fi

if [[ "$RUN_FRONTEND_BUILD" == "1" ]]; then
  echo "== frontend build (opt-in; writes frontend/public/sitemap.xml) =="
  (cd frontend && npm run build)
else
  echo "== frontend build skipped (use --include-frontend-build or RUN_FRONTEND_BUILD=1; prebuild writes tracked sitemap) =="
fi

if command -v flutter >/dev/null 2>&1; then
  echo "== flutter analyze =="
  (cd flutter && flutter analyze --no-fatal-infos --no-fatal-warnings)
  echo "== flutter test =="
  (cd flutter && flutter test)
else
  missing_check "flutter analyze/test" "flutter command not found"
fi

echo "All requested checks finished."
