# Verification harness

Last reviewed: 2026-07-31

The repository-wide entry point is `scripts/check_all.sh`. It is deliberately
non-Docker and non-Supabase: hosted Supabase remains the only supported
database, and no dependency installation is performed by the harness.

## Commands

```bash
./scripts/check_all.sh
```

The default run executes:

- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_architecture.py`
- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_docs_structure.py`
- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/check_theme_tokens.py`
- backend `ruff check .` and `PYTHONPATH=. pytest -q` when the existing venv tools are present
- web `npm run lint` and `npm test -- --run` when installed local binaries are present
- Flutter `flutter analyze --no-fatal-infos --no-fatal-warnings` and `flutter test` when the SDK is available

The web build is opt-in:

```bash
RUN_FRONTEND_BUILD=1 ./scripts/check_all.sh
```

The frontend prebuild writes tracked `frontend/public/sitemap.xml`; therefore
the default harness omits it to preserve a read-only discovery workflow. Missing
optional toolchains are reported and can be made fatal with
`ALLOW_MISSING_CHECKS=1`. `ALLOW_NO_PYTEST=1` preserves the legacy behavior for
an absent backend virtualenv.

## Evidence boundary

A passing harness result proves static checks and the available local test
suites. It does not prove hosted Supabase RLS, external AI providers, Stripe,
proxy behavior, production load, authenticated browser E2E, Flutter integration
flows, or private-object URL revocation. Those boundaries are recorded in the
[user-story ledger](./product-specs/user-story-ledger.md).
