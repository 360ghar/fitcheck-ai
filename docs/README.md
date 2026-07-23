# FitCheck AI knowledge base

Last updated: 2026-07-22

This directory is the **system of record** for product intent, design decisions, execution plans, quality grades, and deep technical notes. Agents should start at root `AGENTS.md` / `CLAUDE.md` (identical maps), then `ARCHITECTURE.md`, then the files below.

## Start here

| Need | Read |
|------|------|
| How to work in this repo | `../AGENTS.md` |
| Layers and imports | `../ARCHITECTURE.md` |
| Agent operating principles | `design-docs/core-beliefs.md` |
| Local setup | `references/local-setup.md` |
| Backend depth | `BACKEND.md` |
| Web depth | `FRONTEND.md` |
| Mobile depth | `FLUTTER.md` |
| Product intent | `PRODUCT_SENSE.md` + `product-specs/` |
| Quality / debt | `QUALITY_SCORE.md`, `exec-plans/tech-debt-tracker.md` |

## Layout

```text
docs/
├── design-docs/       # beliefs, design decisions (indexed)
├── exec-plans/        # active/, completed/, tech-debt-tracker
├── generated/         # regenerable artifacts (e.g. db-schema)
├── product-specs/     # product overview, stories, feature PRDs
├── references/        # API, auth, setup, stack, implementation notes
├── store/             # app store / play store listing copy
├── BACKEND.md
├── FRONTEND.md
├── FLUTTER.md
├── DESIGN.md
├── PLANS.md
├── PRODUCT_SENSE.md
├── QUALITY_SCORE.md
├── RELIABILITY.md
└── SECURITY.md
```

## Maintenance rules

1. Prefer linking to a canonical file over duplicating large blocks.
2. When behavior, env, or API contracts change, update the matching doc in the **same change**.
3. Non-trivial work uses an exec plan (`PLANS.md`).
4. Do not grow root `AGENTS.md` / `CLAUDE.md`—update this tree instead.
5. Mechanical structure is checked by `scripts/check_docs_structure.py`.

## Reading paths

**New agent / engineer**

1. `../AGENTS.md` → `../ARCHITECTURE.md` → `design-docs/core-beliefs.md`
2. `PRODUCT_SENSE.md` → `product-specs/overview.md`
3. `references/local-setup.md`

**Backend change**

1. `BACKEND.md` → `references/api-spec.md` / live OpenAPI
2. `references/data-models.md` + `generated/db-schema.md`
3. Relevant service under `backend/app/services/`

**Frontend change**

1. `FRONTEND.md` → `DESIGN.md`
2. `references/frontend-components.md`, `references/workflows.md`

**Planning a feature**

1. `product-specs/` for the feature
2. `PLANS.md` + new file under `exec-plans/active/`
3. `QUALITY_SCORE.md` for known gaps in that domain

## Verification matrix

| Change type | How to verify |
|-------------|---------------|
| Backend logic | `cd backend && source .venv/bin/activate && pytest` + `ruff check .` |
| Architecture / docs layout | From **repo root**: `python scripts/check_architecture.py` + `python scripts/check_docs_structure.py` |
| Web UI code | `cd frontend && npm run lint && npm run build` |
| Mobile | `cd flutter && flutter test` |
| UI bug fix | Browser: reproduce → screenshot/DOM → fix → re-verify in browser |

Full harness (architecture + docs + pytest if venv present): `./scripts/check_all.sh` from repo root.
