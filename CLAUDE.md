# FitCheck AI — Agent map

This file is a **table of contents**, not an encyclopedia. Keep it short. Put durable knowledge under `docs/` or `ARCHITECTURE.md`. If you need a new standing rule, update the linked doc—do not grow this file.

FitCheck AI is a monorepo for AI-assisted wardrobe management, outfit generation, planning, photoshoot, and related social/subscription workflows.

## Non-negotiables

- Never use Docker for local development.
- Use hosted Supabase only (no local Supabase).
- Treat workspace `.env` values as already provisioned unless told otherwise.
- Keep modular boundaries: routes thin, logic in services, schemas in models.
- Repository markdown is the system of record. If it is not in the repo, agents cannot see it.

## Monorepo map

| Path | Role |
|------|------|
| `backend/` | FastAPI API, services, AI, tests |
| `frontend/` | React + TypeScript (Vite) web app |
| `flutter/` | Flutter mobile (GetX) |
| `remotion/` | Marketing video compositions |
| `docs/` | Knowledge base (product, design, plans, quality) |
| `scripts/` | Harness checks (docs + architecture) |
| `ARCHITECTURE.md` | Domains and allowed dependency edges |
| `run-dev.sh` | Backend `:8000` + frontend `:3000` |

Package-local notes: `backend/CLAUDE.md`, `frontend/CLAUDE.md` (thin; deep content in `docs/`).

## Progressive disclosure (read in order)

1. This map (`AGENTS.md` / `CLAUDE.md` — identical).
2. `ARCHITECTURE.md` — layers and forbidden imports.
3. Domain doc for the change:
   - Backend / API / AI: `docs/BACKEND.md`
   - Web UI: `docs/FRONTEND.md`
   - Mobile: `docs/FLUTTER.md`
   - Product intent: `docs/PRODUCT_SENSE.md` + `docs/product-specs/`
   - Security / reliability: `docs/SECURITY.md`, `docs/RELIABILITY.md`
4. Design & process: `docs/design-docs/core-beliefs.md`, `docs/PLANS.md`
5. Live contracts when running: OpenAPI at `/api/v1/docs`; schema notes in `docs/generated/db-schema.md` and `docs/references/data-models.md`

## Knowledge base index

| Area | Location |
|------|----------|
| Hub | `docs/README.md` |
| Design docs + beliefs | `docs/design-docs/` |
| Product specs | `docs/product-specs/` |
| Exec plans (active/completed/debt) | `docs/exec-plans/` |
| Quality grades | `docs/QUALITY_SCORE.md` |
| UI / visual direction | `docs/DESIGN.md` |
| Setup & stack references | `docs/references/` |
| Store listing / ASO | `docs/store/` |

## Agent-first workflow

1. **Trivial change:** implement, verify, skip a plan file.
2. **Non-trivial / multi-file / multi-app:** create or update `docs/exec-plans/active/<name>.md` (see `docs/PLANS.md` and `_TEMPLATE.md`).
3. **Implement → self-review → run verification → fix** until green. Escalate only for product judgment or missing capability in the harness.
4. **Same change set:** update docs when behavior/env/API changes; update `QUALITY_SCORE.md` or `tech-debt-tracker.md` when you discover debt.
5. **Do not** dump long new policy into this file.

## Commands

```bash
./run-dev.sh                          # API :8000 + web :3000
cd backend && source .venv/bin/activate && pytest
cd frontend && npm run lint && npm run build
cd flutter && flutter test
python scripts/check_architecture.py
python scripts/check_docs_structure.py
./scripts/check_all.sh                # architecture + docs (+ pytest if venv present)
```

Backend Swagger: `http://localhost:8000/api/v1/docs`  
Health: `http://localhost:8000/health`  
Logs: `backend/logs/` (correlation IDs on requests)

## Env templates (details in docs)

- `backend/.env.example`, `frontend/.env.example`, `flutter/.env.example`
- Schema: apply `backend/db/supabase/migrations/` on hosted Supabase (start with `001_full_schema.sql`)

## Commit style

Imperative subjects, preferably `type: summary` (e.g. `feat: …`, `fix: …`, `docs: …`).
