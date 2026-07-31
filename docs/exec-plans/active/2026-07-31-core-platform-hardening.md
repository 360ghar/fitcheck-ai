# Plan: core platform hardening

Status: active  
Started: 2026-07-31  
Owner: Codex orchestrator

## Goal

Harden the implemented FitCheck core across FastAPI, React web, and Flutter; remove confirmed authorization, reliability, UX, accessibility, and parity defects; and verify each implemented user story with a reproducible test or documented external blocker.

## Non-goals

- Do not build absent aspirational features such as community, stylist marketplace, retailer integrations, household sharing, or trend data.
- Do not change public Supabase bucket visibility in this cycle; document the residual exposure and prepare a later signed-URL migration.
- Do not use Docker or local Supabase.
- Do not touch the unrelated untracked `video.mp4`.

## Acceptance criteria

- [x] No confirmed P0/P1 core-flow, authorization, billing, or data-integrity defects remain in the repository-tested scope.
- [x] Core web and Flutter flows have matching behavior, error states, and recovery semantics for the hardened flows.
- [x] Backend tests, frontend lint/test/build, Flutter analyze/test, architecture/docs/theme checks, and public browser/mobile smoke checks pass.
- [x] User-story ledger records expected behavior, evidence, verification, and remaining blockers.
- [x] Implementation-status, reliability, security, quality, API, and tech-debt docs match the code.
- [ ] Authenticated browser journeys and hosted-provider contracts remain externally blocked until credentials and a deployable hosted environment are supplied.

## Context / links

- `AGENTS.md`, `ARCHITECTURE.md`, `docs/PLANS.md`
- `docs/FRONTEND.md`, `docs/FLUTTER.md`, `docs/BACKEND.md`
- `docs/PRODUCT_SENSE.md`, `docs/RELIABILITY.md`, `docs/SECURITY.md`
- `docs/product-specs/user-stories.md`, `docs/product-specs/implementation-status.md`
- `frontend/src/App.tsx`, `backend/app/main.py`, `flutter/lib/app/routes/app_pages.dart`

## Progress log

| Date | Note |
|------|------|
| 2026-07-31 | Started from passing baseline: backend 598 tests, frontend 50 tests/lint, architecture/docs/theme checks. Flutter SDK cache write permission blocked local test execution. |
| 2026-07-31 | Parallel agents completed backend auth/storage, jobs/quotas/billing/SSRF, web flow/UX, Flutter parity, and documentation/story-ledger work. Each workstream added focused regression evidence before implementation. |
| 2026-07-31 | Durable batch/photoshoot job metadata, progress, terminal state, and final storage URLs now persist through hosted-Supabase migrations; reconnect/restart recovery is polling-oriented and does not resume an in-flight provider call. |
| 2026-07-31 | Final repository checks passed: architecture/docs/theme, backend Ruff plus 638 tests, frontend lint/77 Vitest tests/build, Flutter analyze, and 106 Flutter tests. Public homepage/auth browser smoke had zero console errors. |
| 2026-07-31 | Second-pass review found and fixed missing decoded-byte validation for several inline image models, daily AI/photoshoot quota races with admission compensation, incomplete calendar/collection contracts, Pinecone cross-user deletion, webhook retry state, SSRF-prone image fetches, and stale accessibility/documentation claims. |
| 2026-07-31 | Adversarial final review caught a Stripe webhook claim regression where the Supabase update method was referenced but not invoked; fixed it, added claim/attempt regression coverage, and reran the full harness successfully. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-31 | Harden implemented core before expanding product scope. | The repository overstates several absent or disabled features. |
| 2026-07-31 | Require core web/Flutter parity. | Divergent payloads and failure states are current sources of user confusion. |
| 2026-07-31 | Keep public buckets temporarily. | Avoid breaking existing raw URLs while ownership/deletion paths are repaired and migration debt is documented. |
| 2026-07-31 | Treat hosted integration proof as a release gate outside this local pass. | Authenticated browser E2E, hosted RLS/migration execution, Stripe, AI providers, and real SSE proxy behavior require credentials or a deployed environment not present in the workspace. |

## Verification

```bash
python scripts/check_architecture.py
python scripts/check_docs_structure.py
python scripts/check_theme_tokens.py
cd backend && .venv/bin/pytest
cd frontend && npm run lint && npm test -- --run && npm run build
cd flutter && flutter analyze && flutter test
```

## Deferred debt

- Public image buckets and raw asset URLs require a later private-bucket/signed-URL migration.
- Batch/photoshoot state is durable, but an active provider pipeline is not automatically resumed after process restart; clients receive recovery state and can poll/retry. Social-import workers remain process-local.
- Authenticated browser E2E, emulator/integration journeys, hosted Supabase RLS/migration verification, Stripe webhooks, and real AI/provider probes remain external release checks.
- External calendar synchronization, retailer shopping, community, stylist, household, trend, sustainability, and other absent features remain out of scope.
