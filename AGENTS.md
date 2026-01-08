# Repository Guidelines

## Project Structure

- `frontend/`: React + TypeScript (Vite). App code lives in `frontend/src/` (pages in `frontend/src/pages/`, shared UI in `frontend/src/components/` and `frontend/src/components/ui/`). Production builds output to `frontend/dist/`.
- `backend/`: FastAPI service. Entry point is `backend/app/main.py`; routes are under `backend/app/api/v1/`; business logic lives in `backend/app/services/`; data models are in `backend/app/models/`.
- `backend/db/supabase/migrations/`: Supabase schema SQL (start with `001_full_schema.sql`).
- `docs/`: Product/technical specs and setup notes.
- `docker-compose.yml`: Runs frontend + backend with hot reload.

## Build, Test, and Development Commands

- `./run-dev.sh`: Runs backend (`uvicorn`) and frontend (`vite`) together on `:8000` and `:3000`.
- `docker compose up --build`: Dev environment in containers (uses root `.env`).
- `cd backend && pip install -r requirements.txt && uvicorn app.main:app --reload`: Run API locally.
- `cd frontend && npm install && npm run dev`: Run web app locally.
- `cd frontend && npm run build`: Type-check + production build.
- `cd frontend && npm run lint`: Lint the frontend (ESLint).
- `cd backend && pytest`: Run backend tests (when present).

## Coding Style & Naming Conventions

- **Backend (Python):** 4-space indentation, type hints where practical, `snake_case` for modules/functions, `PascalCase` for classes. Keep API logic in `backend/app/api/v1/` and push reusable logic into `backend/app/services/`.
- **Frontend (TypeScript/React):** follow existing formatting (2-space indentation, single quotes, no semicolons). Use `PascalCase` for components and `camelCase` for hooks/utilities.

## Testing Guidelines

- **Backend:** use `pytest`/`pytest-asyncio`. Place tests under `backend/tests/` and name files `test_*.py`.
- **Frontend:** no automated test runner is configured yet; prefer adding tests alongside introducing a framework, or validate via `npm run build` + manual QA.

## Commit & Pull Request Guidelines

- Git history is minimal (initial import). Use clear, imperative subjects; prefer `type: summary` (e.g., `feat: add outfit sharing toggle`).
- PRs should include: a short description, how to test, screenshots for UI changes, and any config/env updates (also update `.env.example` files when adding new variables).

Instructions:
- Never run the project using Docker. 
- Use the Supabase server for backend support, i.e. don't run supabase locally or in docker. 
- All env keys are already set in the `.env` file.
- Always follow the abstractions and modular design principles.
