# Architecture

Last updated: 2026-07-22

FitCheck AI is a monorepo: React web + Flutter mobile clients call a FastAPI backend. Supabase is the system of record (Postgres, Auth, Storage). AI runs behind backend provider abstractions. Optional vector retrieval uses Pinecone.

This file is the top-level map of domains and **allowed dependency edges**. Deeper runtime detail lives in `docs/BACKEND.md`, `docs/FRONTEND.md`, `docs/FLUTTER.md`, and `docs/references/`.

## System diagram

```text
[React web] ──┐
              ├──► FastAPI /api/v1 ──► services ──► Supabase
[Flutter]  ───┘         │                 ├──► AI providers
                        │                 └──► Pinecone (optional)
                        └── health / OpenAPI
```

## Repository domains

| Path | Role |
|------|------|
| `backend/` | API, business logic, AI orchestration, tests |
| `frontend/` | Web client (Vite + React + TypeScript) |
| `flutter/` | Mobile client (GetX) |
| `remotion/` | Marketing video compositions |
| `docs/` | System of record for product/design/plans/quality |
| `scripts/` | Repo harness checks (docs structure, architecture) |

## Backend layers (enforced)

Dependency direction is **strictly forward**. Violations fail `scripts/check_architecture.py`.

```text
api/v1 (routes)  →  services  →  { models, db, core, agents }
                                      ↑
                    main.py wires routers + middleware only
```

| Layer | Path | May import | Must not import |
|-------|------|------------|-----------------|
| Routes | `app/api/v1/` | services, models, core, db, deps | nothing outside app patterns; keep thin |
| Services | `app/services/` | models, db, core, agents, other services | `app.api` |
| Agents | `app/agents/` | models, core, services (sparingly) | `app.api` |
| Models | `app/models/` | core (rarely), stdlib/pydantic | services, api, db clients as business logic |
| Core | `app/core/` | stdlib, settings libs | services, api |
| DB | `app/db/` | core | services, api |
| Utils | `app/utils/` | core, stdlib | `app.api`, `app.services` (infrastructure helpers only) |

### Backend principles

1. **Thin routes.** Handlers parse input, call services, map errors. Business logic stays in services.
2. **Parse at the boundary.** Request/response shapes are Pydantic models; do not YOLO unstructured dicts across layers.
3. **Provider abstraction.** AI vendor specifics live in `ai_provider_service` / config, not scattered in routes.
4. **Shared exceptions.** Raise types from `app.core.exceptions`; handlers in `main.py` format JSON errors with `correlation_id`.
5. **Hosted Supabase only.** No local Supabase runtime; migrations live under `backend/db/supabase/migrations/`.

### Key runtime flows (pointers)

Full step lists: `docs/BACKEND.md` (batch SSE extract, outfit gen, recommendations, rate limits).

- Batch wardrobe extract: `batch_processing.py` / `batch_extraction_service.py` (parallel extract, overlapped product gen, SSE).
- Auth: `docs/references/auth-flow.md`.
- Live OpenAPI: `http://localhost:8000/api/v1/docs` when backend is running.

## Frontend layers (enforced lightly)

```text
pages  →  components  →  { hooks, stores, api, lib, types }
api must not import pages or components
stores must not import pages
```

| Area | Path |
|------|------|
| Routes / guards | `frontend/src/App.tsx` |
| Pages | `frontend/src/pages/` |
| Feature UI | `frontend/src/components/` |
| Primitives | `frontend/src/components/ui/` |
| API client | `frontend/src/api/` (via `client.ts`) |
| Client state | `frontend/src/stores/` |
| Server state | TanStack Query |
| Utils | `frontend/src/lib/`, `hooks/` |

Details: `docs/FRONTEND.md`.

## Flutter layers (convention)

```text
features/*  →  core/*  →  external packages
app/ owns routes, bindings, theme
```

Details: `docs/FLUTTER.md`.

## Cross-cutting concerns

| Concern | Where |
|---------|--------|
| Config / env | `backend/app/core/config.py`, `*.env.example` |
| AuthN | Supabase JWT; `core/security.py`, `api/v1/deps.py` |
| Logging | `core/logging_config.py`, correlation middleware |
| Errors | `core/exceptions.py` + handlers in `main.py` |
| Storage | `services/storage_service.py` + Supabase buckets |
| Jobs / SSE | batch, photoshoot, social import job services |
| Security notes | `docs/SECURITY.md` |
| Reliability notes | `docs/RELIABILITY.md` |

## What agents must not do

- Import `app.api` from services, models, core, db, or agents.
- Import `app.services` from models, core, db, or utils.
- Import `app.api` or `app.services` from `app/utils/` (utils are pure infrastructure helpers: crypto, retry, image processing, parallel work — no reverse deps into domain layers).
- Put multi-step business workflows only in route handlers.
- Run Docker or local Supabase for development.
- Bypass service abstractions for one-off AI/vendor calls in routes.
- Leave architecture-breaking “temporary” shortcuts without an entry in `docs/exec-plans/tech-debt-tracker.md`.

## Verification

```bash
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd backend && pytest
cd frontend && npm run lint && npm run build
```
