# Plan: Docs, harness, and backend-test-coverage refresh (PRs #12/#13)

Status: completed  
Started: 2026-08-07  
Completed: 2026-08-08  
Owner: agent

## Goal

Land the review-hardened documentation and coverage refresh: close every
review comment on the docs-updates and test-coverage-v2 branches, keep the
knowledge base the system of record, and make the harness/CI checks honest,
deterministic, and pinned.

## Non-goals

- No product/behavior changes beyond what the reviewed PRs already shipped.
- No new toolchains (markdownlint-cli2 is run via `npx` as before; the
  coverage gate stays on the combined total, not a new branch gate).

## Acceptance criteria

- [x] Every review comment on PRs #12 and #13 validated; still-valid ones fixed in the tree.
- [x] Backend coverage campaign retained at 99.98% combined total (3618 tests) with no per-file pragmas added in this pass.
- [x] Docs/CI harness deterministic: `check_docs_structure.py` anchored freshness regex + future-date rejection + shallow-clone guard; `generate_api_spec_doc.py` byte-stable under dummy env (drift gate validated).
- [x] Workflows pinned to commit SHAs with `permissions: contents: read` and `persist-credentials: false`; lychee scans root docs and the ignore list itself.
- [x] `.lycheeignore` anchored regexes (no bare `https://*` catch-alls); markdownlint MD024/034/040/047 re-enabled (109 files, 0 issues).
- [x] Docs reconciled with the recorded live state (migration checklist, campaign metrics, test counts, E2E-in-CI, version metadata, RBAC, image-URL contract).
- [x] Full verification green: `pytest -q` (3618), `ruff check`, docs structure + architecture checks, markdownlint, api-spec drift regen.

## Context / links

- Related docs: `docs/PLANS.md`, `docs/QUALITY_SCORE.md`, `docs/exec-plans/tech-debt-tracker.md`
- Related code: `backend/tests/`, `backend/.coveragerc`, `scripts/check_docs_structure.py`, `scripts/generate_api_spec_doc.py`, `.github/workflows/{backend-ci,docs-ci,lychee}.yml`, `.lycheeignore`, `.markdownlint.json`

## Progress log

| Date | Note |
|------|------|
| 2026-08-07 | Coverage campaign (PR #13): 70% → 99.98% combined total, 1764 → 3618 tests; docs-updates branch (PR #12) with docs/lint CI added. |
| 2026-08-07 | Fetched authoritative review comment sets (40 on #13, 33 on #12); classified each against the working tree. |
| 2026-08-08 | Backend test fixes: shared pinecone stub + network guard in conftest, FakeDB `.order()`/update persistence, item-reference tests on shared FakeDB + real semaphore concurrency test, shared social-import helpers module, stripe.api_key isolation fixture, deterministic AI-settings stub, genuine PIL-fallback (PPM) sniff test, unused factories module deleted, requirements pruned (pytest-xdist, polyfactory). |
| 2026-08-08 | Harness/CI: CORS empty-regex guard in config, anchored freshness regex + future-date + shallow-repo guard in check_docs_structure.py, 500/501/503 status notes in the API-spec generator (+ regenerated doc), action SHAs pinned + permissions tightened on three workflows, `.lycheeignore` rewritten as anchored regexes, markdownlint MD024/034/040/047 re-enabled, `.coveragerc` contract wording corrected. |
| 2026-08-08 | Docs: RBAC email-domain fallback removed from auth-flow, image-URL response-only contract in data-models, ARCHITECTURE.md consolidated to one system diagram (incl. `IMG --> Mobile`), E2E-in-CI status in admin/README + QUALITY_SCORE, TD-040 duplicate-plans GC (4 active copies deleted), campaign metrics + revert window, railway migration contract (ad-hoc scripts note, template removed, bucket-count reconciliation), revenue-trends vitest count, app-store 1.0.4 metadata, prod-log-rca migration checklist labeled applied/re-apply/pending, admin test counts refreshed (113 → 172). |
| 2026-08-08 | Full verification battery run (subset runs 113 passed; full `pytest -q` 3618 green; ruff clean; docs + architecture checks; markdownlint 109 files 0 issues; api-spec regen byte-stable). PRs #12 + #13 merged to main; `git checkout main && git pull`. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-08 | Fix review comments in the working tree before merge rather than replying "won't fix" | Every comment that was still valid against the merged state had a small, safe fix; the invalid ones (pre-restructure test paths) were verified against the current layout and only the stale counts changed. |
| 2026-08-08 | Revert the guessed CORS site-specific regex; keep the broad `.netlify.app` default with an empty-by-default env override | The Netlify site name is not verifiable from the repo; an empty override disables the regex in CORSMiddleware via a validator instead of matching all origins. |
| 2026-08-08 | Label prod-log-rca migrations applied/re-apply/pending from in-repo records only | The doc is the ops reference; inventing a uniform "all pending" would contradict the admin plans' applied records, and inventing "applied" without a record would be worse. |
| 2026-08-08 | Completed plan created directly under `completed/` instead of `active/` | The refresh is finished and merged; per `docs/PLANS.md` lifecycle, a finished plan belongs in `completed/` (no mid-flight GC needed). |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest -q          # 3618 passed, 99.98% combined total
ruff check .                                                  # clean
cd .. && python scripts/check_docs_structure.py               # clean
python scripts/check_architecture.py                          # clean
npx --yes markdownlint-cli2 --config .markdownlint.json "docs/**/*.md" "AGENTS.md" "ARCHITECTURE.md" "README.md"  # 0 issues / 109 files
# api-spec drift gate: dummy-env regen of docs/references/api-spec.md produced only the intended status-note diff
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-040 plan-lifecycle drift (resolved; duplicates deleted).
- No new debt introduced by this refresh; remaining items are pre-existing rows.
