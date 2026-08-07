# Admin console

Last updated: 2026-08-08

Internal admin console for FitCheck AI founder + ops/content/support staff,
under `admin/`. A React 19 SPA deployed to `admin.fitcheckaiapp.com`, separate
from the public web app in `frontend/` (a deliberately different stack line —
see Stack). It talks to the backend's `/api/v1/admin/*` API with the same
Supabase-backed auth as the other clients. **All authorization is
backend-enforced (server-side RBAC); the UI only shapes UX and is never a
security boundary.**

Operational detail (quickstart, env vars, known advisories, deploy steps)
lives in `../admin/README.md` — read it for anything not covered here. This
file is the docs/-level entry point and intentionally does not duplicate
`admin/README.md`.

## What it is

- Internal console replacing the legacy blog admin that used to live in
  `frontend/` (`/admin/blog/*` routes removed; blog editing is now the admin
  app's content feature).
- A pure HTTP client of the backend: no direct DB access, no backend code
  imports; the only network entry point is the typed openapi-fetch client.
- RBAC is server-authoritative: roles → permissions live in
  `backend/app/core/permissions.py`; the app mirrors the map only to shape UI
  (`admin/src/shared/lib/permissions.ts`). A non-admin Google account gets 403
  from `/api/v1/admin/me` and is bounced.

## Stack

| Concern | Choice |
| --- | --- |
| Framework | React 19 + TypeScript 5.9 (strict, `noUncheckedIndexedAccess`) + Vite 7 |
| Styling | Tailwind 4 (CSS-first via `@tailwindcss/vite`), shadcn-style components on Radix primitives |
| Data | TanStack Query 5, TanStack Table 8, TanStack Virtual |
| State | zustand 5 (session, UI prefs) |
| Forms | react-hook-form 7 + zod 4 |
| Routing | react-router-dom 7 (library mode) |
| i18n | i18next (`src/shared/i18n/en/*.json`, 19 namespaces) |
| API types | openapi-typescript + openapi-fetch (codegen from `contracts/openapi.json`) |
| Unit tests | Vitest 3 + Testing Library + MSW + vitest-axe |
| E2E | Playwright (chromium) |

The public `frontend/` is React 18 / Vite 5 / Tailwind 3 — deliberately not
matched. Only visual tokens and API contracts stay in sync (monorepo design
language + OpenAPI codegen, never shared code).

## Structure

```text
src/
├── app/          providers, route manifest + guards, layout (Sidebar/Topbar/UserMenu), 403/404
├── config/       env.ts (zod-validated), feature flags (build-time)
├── features/     auth, dashboard, users, subscriptions, quotas, content, promo,
│                 feedback, ops, audit, search, settings
├── shared/       api/ (typed client + generated schema), hooks/, i18n/, lib/,
│                 stores/, ui/ (primitives + DataTable)
└── test/         MSW handlers + fixtures, setup, render utils
```

- Layer rule: `pages → features/<feature>/{components,hooks,api} →
  shared/{ui,lib,hooks,api,stores} → openapi-fetch client`.
- **Feature isolation is enforced by ESLint** (`admin/eslint.config.js`,
  `import-x/no-restricted-paths`): a feature may import itself, `shared/`,
  `config/`, `app/`, `test/` — never another feature; promote to `shared/`
  first.
- Pages never call `fetch`; they call feature-level query/mutation hooks
  wrapping the typed client. Pure logic (formatters, permission checks) lives
  in `shared/lib`. Sorting/filtering/pagination live in `searchParams` via
  `useTableState` (deep-linkable, refresh-stable).

## Auth

Google OAuth via Supabase (same project as the main app), with an
email/password fallback. Flow: login page → `signInWithGoogle` → Supabase
redirects to `/auth/callback` → `POST /api/v1/auth/oauth/sync` → bootstrap
from `GET /api/v1/admin/me`.

- `src/config/env.ts` zod-validates every `import.meta.env` read once at
  boot; all vars are optional, so the app runs with zero env against the
  same-origin `/api` proxy.
- `isGoogleAuthConfigured()` is true when both `VITE_SUPABASE_URL` and
  `VITE_SUPABASE_PUBLISHABLE_KEY` are set; it shows/hides the Google button
  (read at render time so tests can flip it). Without both, the panel stays
  email/password-only.
- Supabase Auth → URL Configuration → Redirect URLs must allowlist
  `https://admin.fitcheckaiapp.com/auth/callback` and
  `http://localhost:5173/auth/callback`.
- `returnTo` survives the OAuth round-trip via `oauthReturnTo.ts` (localStorage
  stash; only safe same-origin app paths are accepted — no open redirects).
- Tokens: bearer JWT from Supabase; 401 → silent refresh → retry once →
  logout with `returnTo` (session store). End-to-end refresh verification is
  still pending the hardening wave (see `../admin/README.md`).
- CORS: `https://admin.fitcheckaiapp.com` + `http://localhost:5173` are in the
  backend's `BACKEND_CORS_ORIGINS` defaults (`backend/app/core/config.py`);
  no wildcard.

## RBAC contract

Roles (`backend/app/core/permissions.py` is authoritative; the registry in
`admin/src/shared/lib/permissions.ts` mirrors it for UI shaping only):

| Permission | super_admin | admin | ops | support | content_editor |
|------------|:-----------:|:-----:|:---:|:-------:|:--------------:|
| `*` (all) | x | x | | | |
| `dashboards.read` | x | x | x | x | x |
| `users.read` | x | x | x | x | |
| `users.write` | x | x | x | x | |
| `subscriptions.read` | x | x | x | x | |
| `subscriptions.refund` | x | x | x | | |
| `iap.read` | x | x | x | x | |
| `quotas.read` | x | x | | x | |
| `ops.read` | x | x | x | | |
| `storage.cleanup` | x | x | x | | |
| `audit.read` | x | x | x | x | |
| `content.read` / `content.write` | x | x | | | x |
| `promo.read` | x | x | | | x |
| `feedback.read` / `feedback.write` | x | x | | x | |
| `search` | x | x | x | x | x |

- Legacy fallback (`get_user_role`): an explicit admin `role` wins; otherwise
  `is_admin = True` OR an `@fitcheckaiapp.com` email resolves to `admin`.
- **Enforcement**: every `/api/v1/admin/*` endpoint sits behind `require_admin`
  or `require_permission("…")` from `backend/app/api/v1/deps.py`; suspended
  accounts (`is_active = false`) are rejected in `get_current_user` before any
  handler runs. UI gating is cosmetic; `GET /api/v1/admin/me` drives what the
  app trusts.
- **Audit trail**: every admin mutation writes an append-only `audit_events`
  row (actor, action, entity, payload, ip, user-agent) via
  `backend/app/services/audit_service.py` — best-effort writes that never fail
  the action they document, RLS service-role only (migration 038).
- Self-demotion / last-admin guards, refund idempotency, and quota-override
  logic are enforced server-side in `backend/app/services/admin_service.py`.

## API contract / codegen

The API contract is code, not hand-rolled types:

1. **Export** — `backend/scripts/export_openapi.py` dumps the live OpenAPI
   (`GET /api/v1/openapi.json` via TestClient, no network) to
   `admin/contracts/openapi.json`.
2. **Generate** — `npm run generate:api` runs openapi-typescript →
   `src/shared/api/schema.d.ts`; `schemaTypes.ts` re-exports the admin models
   as flat, stable aliases.
3. **Drift check** — `npm run check:schema` regenerates into a temp dir and
   diffs against the checked-in copy; CI fails when the backend contract moved
   and the app was not regenerated.

The backend is the source of truth for API types: never hand-extend the client
feature-side; extend the schema → codegen. Regenerate + commit
`admin/contracts/openapi.json` whenever the backend admin API changes
(MSW fixtures must match `schema.d.ts`).

## Verification

```bash
cd admin
npm run lint && npm run typecheck && npm test && npm run check:schema && npm run check:bundle
npm run e2e   # Playwright: 8 critical journeys across 6 spec files, chromium
```

- `lint`: ESLint 9 flat config, `--max-warnings 0`; `typecheck`: `tsc --noEmit`
  (app + node configs); `test`: Vitest (jsdom + MSW, 28 files / 215 tests,
  never hits the network); `check:schema`: contract drift; `check:bundle`:
  bundle-size budget.
- E2E (`admin/e2e/*.e2e.ts`): the 8 critical journeys from spec §10 — login
  success/failure/sign-out, role-based 403, users list/detail/suspend, refund,
  storage cleanup, command palette, theme persistence. `/api/**` is stubbed by
  Playwright route interception (no MSW) against a production build served by
  `vite preview` on :4173.
- CI (`.github/workflows/admin-ci.yml`, triggered on `admin/**`): typecheck →
  lint → test → build → `check:schema` → `check:bundle`, then a Playwright E2E
  job with report artifacts on failure.

## Deployment

- Netlify site `admin.fitcheckaiapp.com`; `admin/netlify.toml`: build command
  `npm run build`, publish directory `dist/`.
- `[[redirects]]`: `/api/*` → `https://api.fitcheckaiapp.com/api/:splat`
  (status 200, force) — must precede the SPA fallback to `/index.html`.
- Security headers: active CSP (`default-src 'self'`; the only inline script
  is the pre-paint theme initializer, pinned by a static sha256 hash —
  recompute with `node scripts/csp-hash.mjs` if `index.html`'s inline script
  changes), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`,
  `Referrer-Policy: strict-origin-when-cross-origin`, `X-Robots-Tag: noindex`;
  immutable caching for `/assets/*` and `/fonts/*`.
- Backend migrations 037 (roles/quota override) + 038 (audit_events) must be
  applied to hosted Supabase before deploy.

## Pointers

| Topic | Where |
|-------|-------|
| Operational detail: quickstart, env vars, advisories, deploy steps | `../admin/README.md` |
| Admin panel plan, decisions, endpoint inventory | `./exec-plans/active/2026-08-07-admin-panel.md` |
| Admin app layers + forbidden edges | `../ARCHITECTURE.md` ("Admin app layers") |
| Admin API + RBAC on the backend | `./BACKEND.md` ("Admin API & RBAC") |
| Roles → permissions (authoritative) | `../backend/app/core/permissions.py` |
| Enforcement deps | `../backend/app/api/v1/deps.py` |
| Known debt | `./exec-plans/tech-debt-tracker.md` (TD-078 … TD-082) |
