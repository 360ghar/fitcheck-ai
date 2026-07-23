# Frontend — agent notes

Deep system-of-record: **`docs/FRONTEND.md`**. Layers: **`ARCHITECTURE.md`**. Repo map: root **`AGENTS.md`** / **`CLAUDE.md`** (identical). UI: **`docs/DESIGN.md`**.

## Commands

```bash
cd frontend
npm install
npm run dev      # :3000
npm run build    # typecheck + build
npm run lint
```

Vite proxies `/api` → backend `:8000`.

## Structure (sketch)

```text
src/pages/        routes
src/components/   feature UI + ui/ primitives
src/api/          HTTP (via client.ts)
src/stores/       Zustand
src/hooks/ lib/   shared logic
```

**Rule:** `api/` must not import pages/components; stores must not import pages.

## Read next

| Topic | Doc |
|-------|-----|
| Auth, API, batch upload | `docs/FRONTEND.md` |
| Workflows / components | `docs/references/workflows.md`, `docs/references/frontend-components.md` |
| Setup | `docs/references/local-setup.md` |

Do not expand this file into a second encyclopedia—edit `docs/FRONTEND.md` instead.
