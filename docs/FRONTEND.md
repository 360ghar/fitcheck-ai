# Frontend

Last updated: 2026-08-04

React + TypeScript web app under `frontend/`. Package-local agent entry: `frontend/CLAUDE.md` (thin pointer here). UI direction: `docs/DESIGN.md`.

## Commands

```bash
cd frontend
npm install
npm run dev       # :3000
npm run build     # tsc + vite build + prerender-meta + prerender-html
npm run lint
npm run preview
```

Vite proxies `/api` to the backend (`:8000`) in development.

### Build pipeline

`npm run build` runs four stages; each depends on the previous one:

1. `tsc` — typecheck only.
2. `vite build` — client bundle. Production sourcemaps are **off**
   (`sourcemap: false`): they were previously published and fetchable, which
   exposed the whole frontend source.
3. `scripts/prerender-meta.mjs` — writes `dist/<route>/index.html` per public
   route with unique title/description/canonical plus a `<noscript>` teaser.
4. `scripts/prerender-html.mjs` — renders **real HTML into `<div id="root">`**
   for those routes. See "Prerendered public routes" below.

Stage 4 exits non-zero if a route renders empty or if no route renders at all —
shipping an empty `#root` is the failure it exists to prevent, so it must never
degrade silently.

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

### Prerendered public routes

The marketing pages are prerendered at build time, so first paint no longer
waits for the SPA to boot. Before this, `#root` shipped empty and production
measured `FCP === LCP` to the millisecond — there was no earlier paint to have.

- **`src/routes/publicRoutes.ts` is the single source of truth.** Adding a
  public route means adding it here, not to `App.tsx`. `App.tsx` maps the
  manifest to `<Route>`s; `src/entry-prerender.tsx` renders the same components
  at build time. Two hand-maintained lists would drift.
- Also add the path to `scripts/seo-content.mjs` `SEO_ROUTES` — that registry is
  what the prerender (and the sitemap, and the meta step) iterates.
- **Avoiding the Suspense flash:** `main.tsx` awaits `preloadRoute()` before the
  first `createRoot().render()`. Without it React would clear the prerendered
  markup and paint the Suspense spinner over content that was already visible,
  which both looks broken and pushes LCP back out. `componentFor()` returns the
  resolved component synchronously for the preloaded route.
- The client uses `createRoot`, **not** `hydrateRoot`. React discards the
  prerendered DOM and re-renders it; the early paint is the point, and this
  sidesteps hydration-mismatch bugs entirely. Measured CLS for the swap is 0.
- Data-driven routes were listed in `PRERENDER_SKIP` because baking a loading
  skeleton into HTML is worse than an empty root. The blog **index** now breaks
  that rule on purpose: `src/entry-prerender.tsx` prefetches the first page of
  posts + categories at build time, renders the real grid, and embeds the
  serialized React Query state in a `<script id="__FITCHECK_QUERY_STATE__">`
  tag. `main.tsx` hydrates that state before mount (queries are stamped stale,
  so they refetch in the background right away — baked content is a paint
  shortcut, not a freshness ceiling). If the API is unreachable at build time,
  `render()` returns `skip: true` and the route ships the empty shell as
  before. The prefetch query keys must match the page hooks **exactly**
  (including `search: ''` — react-query hashes keys by their stringified
  value, so `undefined` misses the cache).
- The stylesheet is **inlined into every prerendered page** (all routes +
  `app-shell.html`) by `scripts/prerender-html.mjs` — `style-src
  'unsafe-inline'` is already in the CSP, and the CSS is small enough that
  re-shipping it with each page costs less than the render-blocking request
  it removes.
- `scripts/prerender-html.mjs` injects **per-route modulepreloads** from the
  Vite build manifest (`build.manifest: true`) — currently only the blog
  chunk graph on `/blog`; the entry's own static preloads are deduped.
- Blog imagery is optimized at render time: `lib/images.ts` rewrites stored
  Unsplash URLs (`?w=800&q=80` JPEG) to `auto=format&w=…&q=70` AVIF/WebP and
  `components/blog/BlogImage.tsx` applies a responsive `srcset` + emoji
  fallback on load error. Non-Unsplash URLs pass through untouched.
- The prerender needs `ssr.noExternal` in `vite.config.ts` (gated on
  `isSsrBuild`, because Vitest reads the same config and an unconditional value
  breaks test collection), and shims `localStorage` in the build script for
  zustand's `persist`. It deliberately does **not** shim `window` —
  `src/lib/theme.ts` guards on `typeof window === 'undefined'`, so leaving it
  undefined keeps Node on the safe path.

### Fonts

Inter and Manrope are **self-hosted from `public/fonts/`** with two hand-written
`@font-face` rules at the top of `src/index.css`, named to match
`tailwind.config.ts` (`Inter`, `Manrope`).

Do not reintroduce `@fontsource-variable/*`: those packages register the
families as `"Inter Variable"` / `"Manrope Variable"`, which never matched the
Tailwind stack. The result was 284 KB of fonts deployed that the browser never
requested, and every surface silently rendering in system-ui. Latin subsets
only, `font-display: swap`, both preloaded from `index.html` (Manrope carries
`.landing-display`, the mobile LCP element).

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

Image URLs are served from the private S3-compatible bucket (R2 since the 2026-08-05 egress RCA) in one of two modes, driven by backend config:

- **Presigned mode (default):** URLs are **short-lived presigned GET URLs** (~1h, `OBJECT_STORAGE_PRESIGN_TTL=3600`) that **rotate on every read** (the signature is in the query string) — they defeat browser HTTP caching, so treat them as ephemeral: re-fetch from the backend as needed. This is why the egress RCA added worker mode.
- **Worker mode (`IMAGE_SERVING_MODE=worker`):** URLs are **stable and path-only** (`https://<IMAGE_CDN_BASE_URL>/{storage_path}`) with `Cache-Control: public, max-age=86400, immutable`, so the browser HTTP cache and the Cloudflare edge cache both hit. Fetching an image with the app's bearer token in the `Authorization` header is safe here (presigned S3 URLs must NOT carry one — only one auth mechanism is allowed; `authHeadersForUrl` in `flutter/lib/core/widgets/app_network_image.dart` handles this).

The DB stores a bucket key, not a URL, so the backend materializes a fresh URL at read time. Grid/list tiles should use `thumbnail_url` when the backend returns one (`THUMBNAIL_SERVING=true` serves `_thumb` siblings). `<img>` tiles use `loading="lazy" decoding="async"` (done across wardrobe/calendar/dashboard/photoshoot surfaces 2026-08-05).

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
