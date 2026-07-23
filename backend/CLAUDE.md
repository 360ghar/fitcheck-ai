# Backend — agent notes

Deep system-of-record: **`docs/BACKEND.md`**. Layers: **`ARCHITECTURE.md`**. Repo map: root **`AGENTS.md`** / **`CLAUDE.md`** (identical).

## Commands

```bash
cd backend
source .venv/bin/activate   # or: python -m venv .venv && pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
pytest
ruff check .
```

OpenAPI: `http://localhost:8000/api/v1/docs` · Health: `/health`

## Structure (sketch)

```text
app/api/v1/   routes + deps
app/services/ domain logic
app/models/   Pydantic schemas
app/core/     config, security, exceptions, middleware
app/db/       Supabase clients
app/agents/   extraction / image agents
```

**Rule:** services/models/core must not import `app.api`. Enforce from **repo root** (not after `cd backend`): `python scripts/check_architecture.py`.

## Read next

| Topic | Doc |
|-------|-----|
| AI providers, batch SSE, env | `docs/BACKEND.md` |
| Auth flow | `docs/references/auth-flow.md` |
| Schema | `docs/generated/db-schema.md`, migrations under `db/supabase/migrations/` |
| Security / reliability | `docs/SECURITY.md`, `docs/RELIABILITY.md` |
| Setup | `docs/references/local-setup.md` |

Do not expand this file into a second encyclopedia—edit `docs/BACKEND.md` instead.
