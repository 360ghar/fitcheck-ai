# Frontend

Last updated: 2026-07-22

React + TypeScript web app under `frontend/`. Package-local agent entry: `frontend/CLAUDE.md` (thin pointer here). UI direction: `docs/DESIGN.md`.

## Commands

```bash
cd frontend
npm install
npm run dev       # :3000
npm run build     # tsc + vite build
npm run lint
npm run preview
```

Vite proxies `/api` to the backend (`:8000`) in development.

## Architecture

### State

- **Zustand** (`src/stores/`) for client state (often `persist` to localStorage)
- **TanStack Query** for server state
- **React Hook Form + Zod** for forms

### API layer

All HTTP goes through `src/api/client.ts`:

- Auth token injection
- Refresh on 401 with request queue
- Global error toasts (`skipToast` to opt out)
- `getApiError()` for consistent messages

Domain modules: `src/api/*.ts` (auth, items, outfits, ai, batch, etc.).

### Auth

- `useAuthStore` with `hasHydrated` to avoid auth flash
- `ProtectedRoute` / `PublicRoute` in `App.tsx`
- Tokens in localStorage (`fitcheck_auth_tokens`)

### Routing (representative)

- Public: `/`, `/about`, `/terms`, `/privacy`
- Auth: `/auth/login`, `/auth/register`, forgot/reset password
- Protected: dashboard, wardrobe, outfits, calendar, recommendations, try-on, gamification, profile
- Share: `/shared/outfits/:id`

### Component layout

- `components/ui/` — shadcn-style primitives
- `components/layout/` — app shell / sidebar
- `components/<feature>/` — feature UI
- `pages/` — route pages

### Path aliases

`@/*` → `src/*` (and subpaths for components, api, stores, lib, hooks, types, pages).

## Layer rules

```text
pages → components → { hooks, stores, api, lib, types }
api must not import pages/components
stores must not import pages
```

## Key patterns

### New API call

1. Add function in `src/api/<domain>.ts`  
2. Use `apiClient` from `@/api/client`  
3. Align types with backend Pydantic models  

### New page

1. Page under `src/pages/`  
2. Route in `App.tsx`  
3. Nav link if needed  

### Batch wardrobe upload

- `api/batch.ts` — `startBatchExtractionMultipart`
- `hooks/useBatchExtraction.ts`
- `components/wardrobe/BatchExtractionFlow.tsx`
- Background job UI: `jobUiStore`

### Image prep for AI

- `lib/image-compress.ts` before upload when appropriate

## Environment

`frontend/.env.example` / `.env.local`:

- `VITE_API_URL` or `VITE_API_BASE_URL` (default `http://localhost:8000`)
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY` / publishable key variants
- Feature flags e.g. `VITE_ENABLE_SOCIAL_IMPORT`

## References

- Components notes: `docs/references/frontend-components.md`
- Workflows: `docs/references/workflows.md`
- File structure: `docs/references/file-structure.md`
- Validation: `docs/references/validation.md`

## Testing

No dedicated frontend unit test runner yet (see `QUALITY_SCORE.md` / tech-debt tracker). Validate with `npm run lint` and `npm run build`.

## UI QA path

When fixing a visual or interaction bug in the web app:

1. **Reproduce** — open the page in the browser and confirm the issue (viewport, route, auth state).
2. **Capture** — use browser tools, DOM inspection, and/or a screenshot so the failure is concrete (not a guess from code alone).
3. **Fix** — change the component/styles/logic that caused it.
4. **Re-verify** — reload and confirm the fix in the browser at the same state.

**Content visibility:** content and controls must stay visible by default. Never gate text or interactive UI on an entrance animation completing (no `opacity: 0` until JS/scroll reveal). Prefer animating elements that are already on screen (hover, layout, scroll-linked transforms on visible content). A static, fully readable page beats an animated one that renders empty when motion does not run.
