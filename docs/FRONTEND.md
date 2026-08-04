# Frontend

Last updated: 2026-08-04

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
- Protected: dashboard, wardrobe, outfits, calendar, recommendations, try-on, photoshoot, profile
- Protected + flag-gated: `/gamification` (only registered when `FEATURES.gamification` is true — see Feature flags below; with the flag off a bookmarked `/gamification` falls through to the catch-all redirect to `/dashboard`)
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

### AI Photoshoot (async job + SSE, since 2026-08-03)

- `api/photoshoot.ts` — `startPhotoshootJob` (POST `/generate`, returns
  `job_id`), `getPhotoshootJobStatus` (poll fallback / retries),
  `cancelPhotoshootJob`, `subscribeToPhotoshootEvents` (SSE via the shared
  `createAuthenticatedSSEConnection` from `api/batch.ts`). The legacy
  `generatePhotoshoot` (`sync=true`) still exists but the web app no longer
  uses it (TD-019 closed).
- `stores/photoshootStore.ts` — `generate()` drives the run from SSE events:
  live `generatedImages` (thumbnail gallery), real `progress` (10% + 90% ·
  completed/total), `currentSceneLabel` (next pending slot from
  `batch_started.scene_labels`), rolling `etaSeconds`, `cancelGeneration()`,
  and a bounded poll fallback when the stream dies silently.
- `components/landing/PhotoshootDemo.tsx` — anonymous demo polls
  `GET /photoshoot/demo/{job_id}/status` every 2.5s and shows partial images.

### Image prep for AI

- `lib/image-compress.ts` before upload when appropriate

### Replayable previews (PostHog session recordings)

- `lib/replayable-preview.ts` — `fileToReplayablePreview(file)` builds a
  downscaled **data URL** (JPEG, ≤512px longest edge; small files pass through)
  for any preview that will be visible during a recorded session.
- Do **not** feed `URL.createObjectURL(file)` (`blob:`) directly into `<img>`
  previews: rrweb serializes the DOM `src`, and blob URLs only exist in the
  originating browser session, so recordings replay as blank images.
- Uploads always use the `File` object (never the preview URL), so downscaling
  previews never affects upload fidelity. Landing-page demos are still
  blob-based (out of scope).

### Image URLs are short-lived (presigned)

Image URLs returned by the backend are **short-lived presigned GET URLs** (default
~15 min) served from the private Railway Bucket. Treat them as ephemeral: do not
cache them long-term, and re-fetch from the backend as needed (e.g. on re-render or
when a URL has expired). The DB stores a bucket key, not a URL, so the backend
materializes a fresh URL at read time.

### Error copy — never render raw backend bodies

- Backends log the diagnostic detail (which DB RPC / migration is missing,
  provider internals); the web UI must show **friendly copy only**.
- `lib/batch-extraction-errors.ts` — `getBatchExtractionErrorMessage(error)`
  maps the error's machine fields (`code` / `status` / `errorKind`) to stable
  friendly messages (network / service / fallback) for the batch upload flow.
- Do **not** render `getApiError(error).message` (or Axios's `error.message`)
  directly: it can leak SQL function names, migration numbers, and provider
  internals. Map to friendly copy instead.

## Environment

`frontend/.env.example` / `.env.local`:

- `VITE_API_URL` or `VITE_API_BASE_URL` — **leave empty (or omit) for the web
  app**. The client then uses same-origin `/api/v1/...` paths, which the Vite
  proxy (dev) and the Netlify redirect (prod) route to the backend. Same-origin
  means no CORS preflights (`Authorization` is not a safelisted header), so the
  API never sees the extra OPTIONS round-trip per endpoint that made requests
  look duplicated. Set a full origin (e.g. `https://api.fitcheckaiapp.com`)
  only for standalone builds NOT served behind a same-origin proxy.
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY` / publishable key variants

### Feature flags

Read flags through `frontend/src/lib/feature-flags.ts` (`FEATURES`), never with an
inline `import.meta.env` check. Vite inlines these at build time, so a disabled
feature can be dropped from the bundle as well as the UI. Declare new vars in
`frontend/src/vite-env.d.ts`.

| Var | Default | Gates | Backend counterpart |
|-----|---------|-------|---------------------|
| `VITE_ENABLE_SOCIAL_IMPORT` | `true` | Instagram import panes in `BatchExtractionFlow` | `ENABLE_SOCIAL_IMPORT` (router unmounted when off) |
| `VITE_ENABLE_GAMIFICATION` | `false` | `/gamification` route, sidebar nav entry, and the lazy import of `GamificationPage` | `ENABLE_GAMIFICATION` (router stays **mounted**, handlers return zeroed 200s) |

There is no `/config` endpoint, so each pair must be kept in step by hand.
Gamification defaults off because nothing on the backend writes `user_streaks`
or `user_achievements`, so the page can only ever render zeros.

Gating the `<Route>` alone is not enough to remove the code: the
`lazy(() => import(...))` binding must be gated too, or Rollup still emits the
page chunk. `App.tsx` does both.

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
