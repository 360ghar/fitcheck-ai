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

echo "== migrations =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_migrations.py

echo "== theme tokens =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_theme_tokens.py

echo "== ios deployment target =="
PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_ios_deployment_target.py

# The store listing and the in-app catalogs are two halves of the same shipping
# surface: Apple rejects a listing whose metadata drifts from the app's declared
# localizations, and a locale present in one inventory but not the others renders
# English to a user who asked for their own language. Both gates are additive, so
# a checkout that predates them still runs the rest.
if [[ -f "$ROOT/scripts/i18n/check_locales.py" ]]; then
  echo "== locale coverage =="
  PYTHONDONTWRITEBYTECODE=1 python3 scripts/i18n/check_locales.py
else
  missing_check "locale coverage" "scripts/i18n/check_locales.py not found"
fi

# The listing promises right-to-left layouts for Arabic, Hebrew and Urdu, so the
# app has to mirror. Flutter only mirrors directional APIs; a ratchet keeps new
# `EdgeInsets.only(left:)` / `Alignment.centerRight` / asymmetric
# `EdgeInsets.fromLTRB` out of the tree.
if [[ -f "$ROOT/scripts/i18n/check_rtl.py" ]]; then
  echo "== rtl layout =="
  PYTHONDONTWRITEBYTECODE=1 python3 scripts/i18n/check_rtl.py
else
  missing_check "rtl layout" "scripts/i18n/check_rtl.py not found"
fi

# A string can be complete, non-empty, key-aligned and still wrong: a Malayalam
# paragraph carrying three Bengali letters reads as broken to a native speaker
# and passes every other check in this repo. This one compares each character
# against the scripts the locale actually uses.
if [[ -f "$ROOT/scripts/i18n/check_scripts.py" ]]; then
  echo "== locale scripts =="
  PYTHONDONTWRITEBYTECODE=1 python3 scripts/i18n/check_scripts.py
else
  missing_check "locale scripts" "scripts/i18n/check_scripts.py not found"
fi

if [[ -f "$ROOT/scripts/asc/check-listings.mjs" ]]; then
  echo "== app store listing =="
  # Errors only, matching `docs/store/release-runbook.md`. Most of the current
  # warnings are one per locale saying the machine translation has not had a
  # native review — real debt, tracked in tech-debt-tracker.md, and not
  # something a code change can clear. Failing every run on it would train
  # people to skip this harness. `--strict` remains the release-readiness
  # signal, and the runbook's submission step is where it belongs.
  node scripts/asc/check-listings.mjs
else
  missing_check "app store listing" "scripts/asc/check-listings.mjs not found"
fi

# Report-only on purpose. This compares the published copy against the build and
# prints the gap — how many languages the listing claims versus how many have a
# catalog, and how many user-facing English literals are still hardcoded outside
# the ARB system. It exits 0 here so a mid-migration tree stays usable; the
# `--gate` form is what the release runbook runs before submission.
if [[ -f "$ROOT/scripts/i18n/check_claims.py" ]]; then
  echo "== localization claims =="
  PYTHONDONTWRITEBYTECODE=1 python3 scripts/i18n/check_claims.py
fi

if [[ -f "$ROOT/scripts/creative/check.mjs" ]]; then
  echo "== store creative =="
  node scripts/creative/check.mjs
else
  # Rendering 600 store images needs a browser and is not part of a source
  # checkout's default verification, so this one is genuinely optional.
  echo "== store creative skipped: no rendered manifest (run scripts/creative/render.mjs) =="
fi

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

# The images Worker is the authorization boundary in front of the private R2
# bucket, so its tests are not optional. They use the Node built-in test runner
# (no node_modules, no install step) and stub the Cloudflare-only globals.
if command -v node >/dev/null 2>&1; then
  echo "== images worker tests =="
  (cd infra/images-worker && node --test)
else
  missing_check "images worker tests" "node command not found"
fi

if [[ "$RUN_FRONTEND_BUILD" == "1" ]]; then
  echo "== frontend build (opt-in; writes frontend/public/sitemap.xml) =="
  (cd frontend && npm run build)
else
  echo "== frontend build skipped (use --include-frontend-build or RUN_FRONTEND_BUILD=1; prebuild writes tracked sitemap) =="
fi

if command -v flutter >/dev/null 2>&1; then
  # `flutter/lib/l10n/generated/` is produced by gen-l10n and is not committed, so
  # a clean checkout has no AppLocalizations class at all and every one of the 200+
  # files that import it fails to compile. Generating first makes this harness
  # work on a fresh clone instead of only on a machine that already ran the app.
  # It also keeps the generated classes in step with the ARB catalogs, which is
  # the failure a developer would otherwise only see inside the app.
  echo "== flutter gen-l10n =="
  (cd flutter && flutter gen-l10n >/dev/null)
  echo "== flutter analyze =="
  (cd flutter && flutter analyze --no-fatal-infos --no-fatal-warnings)
  echo "== flutter test =="
  (cd flutter && flutter test --exclude-tags golden)
else
  missing_check "flutter analyze/test" "flutter command not found"
fi

echo "All requested checks finished."
