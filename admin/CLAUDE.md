# Admin console — agent notes

Internal admin panel (React 19 + Vite 7 + Tailwind 4 SPA at `admin.fitcheckaiapp.com`). Deep system-of-record: **`admin/README.md`** + the admin-panel plan (`docs/exec-plans/active/2026-08-07-admin-panel.md`). (The standalone `2026-08-06-fitcheckai-admin-panel-enterprise-architecture-spec.md` never landed in the repo — `admin/README.md` is the spec.) Layers: **`ARCHITECTURE.md`**. Repo map: root **`AGENTS.md`** (root `CLAUDE.md` imports it). UI tokens: **`DESIGN.md`** (Brand Red on warm neutrals).

## Commands

```bash
cd admin
npm install
npm run dev          # http://localhost:5173, proxies /api → backend :8000
npm run lint         # ESLint 9 flat config, zero warnings allowed
npm run typecheck    # tsc --noEmit (app + node configs)
npm test             # Vitest (jsdom + MSW)
npm run build        # typecheck + production build
npm run generate:api # regenerate src/shared/api/schema.d.ts from contracts/openapi.json
npm run check:schema # fail if the contract drifted since the last codegen
npm run e2e          # Playwright critical journeys (chromium, vite preview :4173)
npm run check:bundle # fail if the production bundle exceeds the size budget
```

## Structure (sketch)

```text
src/app/          providers, route manifest, guards, layout shell
src/features/     per-domain modules (auth, users, subscriptions, quotas,
                  content, promo, feedback, ops, audit, dashboard, search, settings)
src/shared/       ui/ (shadcn-style primitives + DataTable), api/ (openapi-fetch
                  client + generated schema), hooks/, lib/, stores/, i18n/
src/test/         MSW handlers + fixtures, setup, render utils
```

## Rules

- **Feature isolation is enforced**: ESLint `import-x/no-restricted-paths` — a feature may import itself, `shared/`, `config/`, `app/`, `test/` — never another feature. Promote shared logic to `shared/` first.
- **The backend is authoritative for permissions.** `src/shared/lib/permissions.ts` only shapes UI; every endpoint re-checks `require_admin` / `require_permission` server-side. Never treat UI gating as security.
- **Query-key factory** per feature (single invalidation source); mutations invalidate exactly the right keys.
- **URL is table state**: sorting/filtering/pagination live in `searchParams` via `useTableState` — keep it that way (deep-linkable, refresh-stable).
- **i18n keys are mandatory**: no inline user-facing literals; tests assert on rendered translations.
- **MSW fixtures must match `schema.d.ts`** (generated from `contracts/openapi.json`). If the backend contract changed, regenerate (`npm run generate:api`) and commit before touching fixtures.
- Do not hand-extend the API client feature-side; extend the schema → codegen instead.

## Read next

| Topic | Doc |
|-------|-----|
| Admin-panel plan (backend contract + decisions) | `docs/exec-plans/active/2026-08-07-admin-panel.md` |
| Quickstart, env, deployment, RBAC | `admin/README.md` |
| Admin API + RBAC on the backend | `docs/BACKEND.md` ("Admin API & RBAC") |
| Roles → permissions (authoritative) | `backend/app/core/permissions.py` |
| Design tokens | `DESIGN.md` (monorepo design language) |

Do not expand this file into a second encyclopedia—edit `admin/README.md` instead.
