# FitCheck Admin

Internal admin panel for the FitCheck AI platform — a React 19 SPA, separate
from the public web app in `frontend/`, deployed to `admin.fitcheckaiapp.com`.
It talks to the FitCheck backend's admin API (`/api/v1/admin/*`) with the same
Supabase-backed auth as the other clients. All authorization is
**backend-enforced** (server-side RBAC); the UI only shapes UX.

> Status: implemented. App shell, login + RBAC, i18n, shared component
> library, server-driven data tables, OpenAPI codegen contract, and all
> feature modules (users, dashboard + revenue/trends, subscriptions + IAP,
> quotas, content, promo, feedback, ops/storage, audit, search, settings)
> are in place, with 27 Vitest files / 194 tests. Playwright e2e +
> token-refresh verification are pending the hardening wave (see "Known
> advisories / limitations").

## Quickstart

```bash
cd admin
npm install
npm run dev            # http://localhost:5173
```

Dev runs on `:5173` and proxies `/api` → `http://localhost:8000` (the backend;
`cd ../backend && uvicorn app.main:app --reload --port 8000`). No env file is
needed locally — all vars are optional. Open `http://localhost:5173` and log
in with an admin account (`@fitcheckaiapp.com` emails resolve to `admin` via
the legacy fallback, or set the `role` column via migration 037).

## Environment variables

All optional (see `.env.example`); env access is zod-validated in
`src/config/env.ts` — never read `import.meta.env` inline.

| Var | Default / when needed | Purpose |
|-----|----------------------|---------|
| `VITE_API_BASE_URL` | empty → same-origin (`/api` proxied/redirected) | API base. Empty is correct for both the dev proxy and the Netlify `/api/*` redirect |
| `VITE_SENTRY_DSN` | empty disables Sentry | Error monitoring via `@sentry/react` |

## Scripts

| Command | What |
|---------|------|
| `npm run dev` | Vite dev server on `:5173` (proxies `/api` → `:8000`) |
| `npm run build` | `typecheck` + production build to `dist/` |
| `npm run preview` | Serve the production build locally |
| `npm run lint` | ESLint 9 flat config, `--max-warnings 0` |
| `npm run typecheck` | `tsc --noEmit` for app + node configs |
| `npm test` / `npm run test:watch` | Vitest (jsdom + MSW) |
| `npm run generate:api` | Regenerate `src/shared/api/schema.d.ts` from `contracts/openapi.json` |
| `npm run check:schema` | Fail if the checked-in types drifted from the contract (CI) |

## Stack

| Concern | Choice |
| --- | --- |
| Framework | React 19 + TypeScript 5.9 (strict, `noUncheckedIndexedAccess`) + Vite 7 |
| Styling | Tailwind 4 (CSS-first, `@tailwindcss/vite`), hand-written shadcn-style components on Radix primitives |
| Data | TanStack Query 5, TanStack Table 8, TanStack Virtual |
| State | zustand 5 (session, UI prefs) |
| Forms | react-hook-form 7 + zod 4 + @hookform/resolvers |
| Charts | recharts 3 (lazy-loaded) |
| Routing | react-router-dom 7 (library mode) |
| i18n | i18next + react-i18next (`src/shared/i18n/en/*.json`) |
| Error reporting | @sentry/react (only when `VITE_SENTRY_DSN` is set) |
| Tests | Vitest 3 + Testing Library + MSW + jest-dom + vitest-axe |
| API types | openapi-typescript + openapi-fetch (codegen from `contracts/openapi.json`) |

Version parity note: the main `frontend/` is on React 18 / Vite 5 / Tailwind 3
— deliberately not matched. Only visual tokens and API contracts must stay in
sync (via the monorepo design language and OpenAPI codegen, never shared code).

## Architecture (one-pager)

```
pages (route components, no logic)
  → features/<feature>/{components,hooks,api}   (feature logic lives here)
    → shared/{ui,lib,hooks,api,stores}          (cross-cutting)
      → openapi-fetch client                    (only import point of the network)
```

### Patterns

- **Thin UI, testable logic.** Pages never call `fetch`; they call feature-level
  query/mutation hooks (`useUsersQuery`) wrapping the typed client. Pure logic
  (formatters, filters, permission checks) lives in `shared/lib` as pure
  functions.
- **Query-key factory** per feature (`users.all()`, `users.detail(id)`…) —
  centralized, typed, the single source for invalidation.
- **URL as table state.** Sorting/filtering/pagination/tabs live in
  `searchParams` via the `useTableState` hook: deep-linkable, back-button-safe,
  refresh-stable.
- **Permission gating (backend authoritative).** `RequirePermission
  perm="users.write"` wraps UI; `usePermission()` for buttons/actions; the
  registry in `src/shared/lib/permissions.ts` mirrors the backend's
  role→permission map. UI hiding is UX, **never security** — every endpoint
  re-checks `require_admin` / `require_permission` server-side, and the
  `/api/v1/admin/me` response drives what the app trusts.
- **Error normalization.** Transport/HTTP/zod failures map to a typed
  `ApiError { code, status, message, fieldErrors? }`; features map
  `ApiError.code` → i18n keys → toast/inline/empty state.
- **Optimistic mutations with rollback** for low-risk flips (status, role
  toggles); confirm-gated pessimistic mutations for destructive actions
  (refund, suspend, storage cleanup).
- **Feature isolation** enforced by ESLint (`import-x/no-restricted-paths`):
  a feature may import itself, `shared/`, `config/`, `app/`, `test/` — never
  another feature. Promote to `shared/` first.

### Conventions

- **No inline literals** — user-facing strings live in i18n namespaces; tests
  assert on rendered translations.
- **Server-driven tables** — `useTableState` + TanStack Query + `DataTable`;
  see `src/features/users/api/users.ts` as the reference pattern.
- **Errors** — the backend envelope `{ error, code, details, correlation_id }`
  is normalized into `ApiError` (correlation id surfaces as a support
  reference on server-side login failures); 401s fire a `session:unauthorized`
  window event (auth paths excluded); 422s parse into field-level details.
- **MSW fixtures must match `schema.d.ts`** — fixtures are typed against the
  generated contract; regenerate + commit before touching them.

## OpenAPI codegen workflow

The API contract is code, not hand-rolled types:

1. **Export** — backend publishes `admin/contracts/openapi.json` (snapshot of
   the live OpenAPI, including `/api/v1/admin/*`).
2. **Generate** — `npm run generate:api` runs openapi-typescript →
   `src/shared/api/schema.d.ts`; `src/shared/api/schemaTypes.ts` re-exports the
   admin models as flat, stable aliases that follow automatically.
3. **Drift check** — `npm run check:schema` regenerates into a temp dir and
   diffs against the checked-in copy; CI fails when the backend contract moved
   and the app has not been regenerated.

Rule: never hand-extend the API client feature-side — extend the schema →
codegen instead.

## RBAC summary

Roles (`backend/app/core/permissions.py` is authoritative): `super_admin`,
`admin`, `ops`, `support`, `content_editor`, plus the legacy fallback (a
`True` `is_admin` flag or an `@fitcheckaiapp.com` email resolves to `admin`
unless an explicit role is set).

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

Keep `src/shared/lib/permissions.ts` in step with the backend map by hand;
drift can only hide/show UI, never grant access.

## Design

Tokens come from the monorepo design language (Pinterest-red brand accent,
warm neutrals, editorial purple for AI badges) — see `flutter/DESIGN.md` and
`docs/DESIGN.md`. Everything is defined once in `src/index.css` under
`@theme` / `@theme inline` and consumed as Tailwind utilities (`bg-primary`,
`text-muted-foreground`, `rounded-16`…). Plus Jakarta Sans is self-hosted in
`public/fonts/` (woff2 variable font, preloaded, no-FOUC inline theme script
in `index.html`).

## Layout

```
src/
  config/            env (zod-validated) + feature flags (build-time)
  shared/
    api/             client (fetch wrapper, error envelope, auth events), generated schema + aliases
    hooks/           usePermission, useTableState (URL-synced), useDebounce, useCsvExport
    i18n/            en namespaces (19 files)
    lib/             cn, constants, formatters, permissions registry, csv, correlation
    stores/          sessionStore (bootstrap/login/logout/idle), uiStore, commandStore
    ui/              primitives + composites + DataTable + ErrorBoundary
  app/               providers, routes manifest, guards, layout (Sidebar/Topbar/UserMenu), 403/404
  features/          auth, dashboard, users, subscriptions, quotas, content, promo,
                     feedback, ops, audit, search, settings
  test/              MSW handlers, setup, render utils
```

## Testing

| Layer | Tool | Status |
|-------|------|--------|
| Unit / integration | Vitest + RTL + MSW | 27 files / 194 tests passing; tests never hit the real network |
| A11y | vitest-axe | wired into unit tests (axe on shared components + pages) |
| Contract | `npm run check:schema` | wired (CI drift check) |
| E2E | Playwright (Chromium) | planned — 6–8 critical journeys; pending the hardening wave |

`src/test/utils.tsx` renders with all providers (Query, Theme, Router,
Toaster); MSW handlers live in `src/test/msw/handlers/` and fixtures mirror
backend response shapes typed against `schema.d.ts`.

## Deployment (Netlify)

- Site: `admin.fitcheckaiapp.com`; build command `npm run build`, publish
  directory `dist` (`admin/netlify.toml`).
- **API proxy**: `[[redirects]] from = "/api/*"` → `https://api.fitcheckaiapp.com/api/:splat`
  (status 200, force) — must precede the SPA fallback.
- **CORS**: `https://admin.fitcheckaiapp.com` and `http://localhost:5173` are
  already in the backend's `BACKEND_CORS_ORIGINS` defaults
  (`backend/app/core/config.py`) and `backend/.env.example` — no wildcard.
- **Security headers** in `netlify.toml`: active CSP (`default-src 'self'`;
  the only inline script is the pre-paint theme initializer, pinned by a
  static sha256 hash — recompute with `node scripts/csp-hash.mjs` if you edit
  `index.html`), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`,
  `Referrer-Policy: strict-origin-when-cross-origin`, `X-Robots-Tag: noindex`,
  immutable caching for `/assets/*` and `/fonts/*`.
- **Backend migrations** 037 (roles/quota override) + 038 (audit_events) must
  be applied to hosted Supabase; regenerate + commit `admin/contracts/openapi.json`
  whenever the backend admin API changes.

## Known advisories / limitations

- **react-router CSRF advisory (GHSA-qwww-vcr4-c8h2)** — applies to RSC-mode
  action handling and is patched only in 8.x. **Not exploitable here**: this
  app is a client-only library-mode SPA (no RSC, no server-rendered actions);
  all mutations go to the FastAPI backend with bearer auth. Revisit when a 7.x
  patch or an 8.x migration lands.
- **Token refresh** — the session store follows the public app's pattern
  (bearer JWT from Supabase, 401 → silent refresh → retry once → logout with
  `returnTo`); end-to-end refresh verification is pending the hardening wave.
- **Page titles** — most route titles still use the `placeholder` i18n
  namespace; feature pages should move to their own namespaces as copy is
  finalized (see `docs/exec-plans/tech-debt-tracker.md` TD-079).
- **Hand-written types** — `src/shared/api/types.ts` predates the codegen
  contract and is partially superseded by `schema.d.ts`; migrate remaining
  consumers (TD-078).
- **Field-level permissions** — RBAC is role-level only by design (TD-081).
