# Frontend

Last updated: 2026-10-01

React + TypeScript web app under `frontend/`. Package-local agent entry: `frontend/AGENTS.md` (thin pointer here). UI direction: `docs/DESIGN.md`.

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

The four stages run inside npm lifecycle hooks: `prebuild`
(`node scripts/generate-sitemap.mjs`) runs first and writes the **tracked**
`public/sitemap.xml` (plus `dist/sitemap.xml`), and `postbuild`
(`node scripts/generate-llms.mjs && node scripts/ping-indexnow.mjs`) runs last.

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

- Public: `/`, `/about`, `/terms`, `/privacy`, `/support`, `/faq`
- Blog: `/blog`, `/blog/:slug` (plus `/blog/category/:category`); the index is
  prerendered with baked first-page content, post/category pages stay dynamic
- Auth: `/auth/login`, `/auth/register`, forgot/reset password
- First-run setup: protected `/welcome` (outside the app shell). `ProtectedRoute` redirects accounts aged 0 to less than 7 days with missing gender and no completion flag in this browser (`shouldShowSetup` in `src/lib/activation.ts`), before any app page mounts. It preserves the requested path, query, and fragment in `returnTo`; Skip setup and Later resume that destination. Add clothes explicitly opens the wardrobe upload. Style choices made during preference loading take precedence over the late response.
- Protected: dashboard, wardrobe, outfits (incl. the `/outfits/new` create page), calendar, recommendations, try-on, photoshoot, profile
- Protected + flag-gated: `/gamification` (only registered when `FEATURES.gamification` is true — see Feature flags below; with the flag off a bookmarked `/gamification` falls through to the catch-all redirect to `/dashboard`)
- Gift vouchers: protected `/gifts` studio is flag-gated; public
  `/gift/:publicId` always stays mounted so issued gifts survive a creation
  rollback
- Share: `/shared/outfits/:id`
- SEO intent pages (one path-driven component, all in `publicRoutes.ts` +
  `scripts/seo-content.mjs`): `/features/*`, `/best/*`, `/compare/*`,
  `/alternatives/*`, `/for/*`, `/guides/*`, `/wear/:citySlug`, and
  `/tools/cost-per-wear-calculator` — not enumerated here

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

The paper studio landing adds four more: **Paper Studio** (Basteleur Bold,
display / the H1) and **Paper Studio Moonlight** (section heads), each with a
Georgia-based metric-override Fallback face so `font-display: swap` does not
shift the layout. The Basteleur subsets were made with `pyftsubset` and renamed
"Paper Studio" because the SIL OFL reserves the "Basteleur" name for unmodified
versions. All six `@font-face` rules live at the top of `src/index.css`; the
landing type is applied through the `.paper-display` / `.paper-head` classes,
and Paper Studio Bold carries `.paper-display` on the hero H1 — the mobile LCP
element — preloaded from the prerendered HTML.

Do not reintroduce `@fontsource-variable/*`: those packages register the
families as `"Inter Variable"` / `"Manrope Variable"`, which never matched the
Tailwind stack. The result was 284 KB of fonts deployed that the browser never
requested, and every surface silently rendering in system-ui. Latin subsets
only, `font-display: swap` throughout.

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

- **Presigned mode (default):** URLs are **short-lived presigned GET URLs** (~7 days, `OBJECT_STORAGE_PRESIGN_TTL=604800`) that **rotate on every read** (the signature is in the query string) — they defeat browser HTTP caching, so treat them as ephemeral: re-fetch from the backend as needed. This is why the egress RCA added worker mode.
- **Worker mode (`IMAGE_SERVING_MODE=worker`):** URLs are **stable and path-only** (`https://<IMAGE_CDN_BASE_URL>/{storage_path}`) with `Cache-Control: public, max-age=86400, immutable`, so the browser HTTP cache and the Cloudflare edge cache both hit. Fetching an image with the app's bearer token in the `Authorization` header is safe here (presigned S3 URLs must NOT carry one — only one auth mechanism is allowed; `authHeadersForUrl` in `flutter/lib/core/widgets/app_network_image.dart` handles this).

The DB stores a bucket key, not a URL, so the backend materializes a fresh URL at read time. Grid/list tiles should use `thumbnail_url` when the backend returns one (`THUMBNAIL_SERVING=true` serves `_thumb` siblings). `<img>` tiles use `loading="lazy" decoding="async"` (done across wardrobe/calendar/dashboard/photoshoot surfaces 2026-08-05).

The session-cached user's `avatar_url` is the one image URL the client persists across reads (auth store), so it goes dead after ~1h. Since 2026-08-09 the authenticated shell (`AppLayout` → `hooks/useUserRefresh.ts`) re-reads `/users/me` on mount, every route change, tab refocus, and a 50-min-guard poll — `/users/me` re-materializes the avatar URL server-side, so the Try On thumbnail (and sidebar/dashboard/profile avatars) heal before expiry. Mobile equivalent still tracked as TD-090.

### AI generation responses are URL-first (since 2026-08-09)

`/ai/try-on`, `/ai/generate-outfit` and `/ai/generate-product-image` persist the render by default (`save_to_storage` defaults to `true` on the backend and in `api/ai.ts`) and return `image_url` + `storage_path` with `image_base64` empty — the multi-MB inline base64 payload no longer rides API responses (egress + memory). The legacy inline path stays available (`save_to_storage: false`) and is also the automatic fallback when the storage write fails (`image_url` comes back empty, so `image_url || data:image/png;base64,...` still renders). The returned URL is a presigned URL (~1h) — fine for the one-shot result screen; saved renders are not DB-referenced (TD-070).

### Error copy — never render raw backend bodies

- Backends log the diagnostic detail (which DB RPC / migration is missing,
  provider internals); the web UI must show **friendly copy only**.
- `lib/batch-extraction-errors.ts` — `getBatchExtractionErrorMessage(error)`
  maps the error's machine fields (`code` / `status` / `errorKind`) to stable
  friendly messages (network / service / fallback) for the batch upload flow.
- Do **not** render `getApiError(error).message` (or Axios's `error.message`)
  directly: it can leak SQL function names, migration numbers, and provider
  internals. Map to friendly copy instead.

## Internationalization (43 languages)

The authenticated app UI ships in the same 43 base languages as the Flutter
client. Source of truth and tooling:

| Piece | Path |
|-------|------|
| Language registry (code, endonym, English name, `rtl`) | `frontend/src/i18n/localeMeta.ts` |
| English source catalog (flat `id → ICU message`) | `frontend/src/i18n/locales/en.json` |
| Generated catalogs, one per language | `frontend/src/i18n/locales/<code>.json` |
| Translation cache keyed by locale then id, each row carrying `_src` | `frontend/src/i18n/cache` → `frontend/src/i18n/.translations.json` |
| Translator | `scripts/i18n/translate_web.py` |
| CI gate | `scripts/i18n/check_web_locales.py` |

### Library: react-intl (FormatJS)

Chosen for ICU MessageFormat. A wardrobe app is full of counts —
`{count, plural, one {# item} other {# items}}` — and English has 2 plural
categories, Polish 4, Arabic 6, Welsh 4; Russian "1 файл / 2 файла / 5 файлов"
cannot be expressed as string concatenation at all. FormatJS implements ICU
natively, so plural selection comes from `Intl.PluralRules` for every language
with no per-language code, and the message text a translator edits is the text
that ships. i18next reaches the same place only with an ICU plugin plus a custom
formatter. The cost is ~11 kB gzip of runtime in the entry chunk.

### Rules

1. **Canonical data stays English.** `category: "tops"`, `style: "casual"`,
   stored outfit composition, occasions — all English. Localization happens at
   display time through `i18n/taxonomy.ts` (`categoryLabel(t, item.category)`),
   which translates a *known* enum value and passes anything else through
   unchanged (a user-typed brand must not render a message id). Writing a
   translated value to the database would fork a wardrobe per language and break
   outfit matching.
2. **One sentence is one message id.** Never concatenate a sentence from JSX
   fragments — word order differs in every language. Use ICU placeholders
   (`common.copyright` → `© {year} FitCheck AI. …`) and `tRich()` when the
   message must embed a `<Link>` (`auth.agreeToTerms`).
3. **Reuse ids.** `common.save`, `common.cancel`, `common.loading` exist so 40
   panels do not ship 40 near-duplicates.
4. **No locale-blind casing.** `toUpperCase()` and CSS `capitalize` are wrong for
   display: Turkish `i` uppercases to `İ`. Use
   `str.toLocaleUpperCase(useFormattingLocale())` or let the message carry its
   own capitalization.
5. **No hardcoded `en-US`, no string concatenation for numbers/dates/currency.**
   Use `i18n/runtime.ts` (`formatDate`, `formatNumber`, `formatCurrency`,
   `formatList`, `formatRelativeTime`, `pluralCategory`) or the `useTranslation()`
   equivalents. `lib/utils.ts`'s `formatDate`/`formatUsd` delegate to the runtime
   so existing call sites became locale-aware for free. Prices stay **USD** — the
   card is charged in USD; only the format is localized.

### Resolution order

`i18n/resolveLocale.ts`, pure and unit-tested:

1. **Explicit choice** (persisted in `fitcheck.locale`). Wins forever, over
   everything, including the account.
2. **The account's language** (`user_settings.language`), adopted only when the
   user has never chosen on this browser.
3. **`navigator.languages`**, walked in the user's stated priority order — not
   just `[0]`, so `[ta-IN, en-US]` gets Tamil.
4. **English.**

### Phone ↔ web agreement

The Flutter client persists `app_locale_asc` locally and mirrors it with
`PUT /api/v1/users/settings` `{"language": "<base>"}`. The web does both halves:

- **Web → backend.** Changing the language calls `updateUserSettings({ language })`
  with the **base** code (`hi`, never `hi-IN`) — `backend/app/core/i18n.py`
  normalizes anything with a region back to `en`, so sending the full tag would
  silently reset the account to English. The local choice is persisted *before*
  the request, and a failure never rolls the UI back.
- **Backend → web.** `i18n/accountLanguage.ts` reads `GET /users/settings` once
  per session and, when the user has no local choice, adopts it.

**When they disagree:** an explicit local web choice wins (this browser is the
user's current intent) and is pushed to the backend on the next language change.
No local choice means the phone's stored language wins over the browser's
default. The user is never shown a picker that disagrees with what they see.

### Lazy loading and bundle size

`i18n/loadLocale.ts` statically imports only English and gives each of the other
42 catalogs its own `import()` so Vite emits one chunk per language. A template
string (`import(\`./locales/${code}.json\`)`) would defeat this — Rollup can only
code-split on static specifiers. `i18n/preload.ts` warms the active catalog inside
the same `Promise.race` in `main.tsx` that already waits for the public route
chunk before mounting, so a non-English visitor's first React render is already
in their language (and `<html dir>` is set before paint) without blanking the
prerendered HTML. A stalled chunk cannot block mount: the race is capped at
`PRELOAD_BUDGET_MS`.

**Measured cost** (`npm run build`, initial JS = entry + its five
`modulepreload`ed vendor chunks):

| | before i18n | after | delta |
|---|---|---|---|
| raw | 574.6 kB | 682.1 kB | **+107.5 kB** |
| gzip | 180.4 kB | 212.6 kB | **+32.3 kB (+17.9 %)** |

Of that increase, `i18n-vendor` (react-intl + ICU parser) is 59.0 kB raw /
16.9 kB gzip and the English source catalog is 40.9 kB raw / 11.7 kB gzip — the
latter is imported statically because it is the fallback for every missing
translation and for the unit-test `Intl` instance. The other 42 catalogs are
separate chunks (7–15 kB each) that **no page references**: `dist/index.html`
lists zero locale chunks, so a French visitor downloads `fr-*.js` and a Japanese
visitor never does.

The entry chunk is therefore **not** flat — it carries the ICU runtime plus the
English catalog, and no amount of code-splitting removes that, because English
must be available synchronously for the first paint and for the fallback path.
The alternative (fetch English too) trades 11.7 kB of initial JS for a waterfall
before any text renders.

### Direction (RTL)

`dir="rtl"` is set on `<html>` for Arabic, Hebrew and Urdu before first paint
(`i18n/preload.ts`), then kept in step by `I18nProvider`. Layout is mirrored by
using **logical** utilities at the source — `ps-*`/`pe-*`, `ms-*`/`me-*`,
`start-*`/`end-*`, `border-s`/`border-e`, `text-start`/`text-end`, and
`inset-inline` in raw CSS — not by a `[dir='rtl']` override block, which would be
a second layout to keep in sync forever. The two deliberate exceptions are
documented in `index.css`: the `.sig-*` marketing collage is pinned LTR, and
`.font-mono`/`code` are isolated LTR inside RTL text.

Audit result: **279** physical Tailwind utilities across **84** files were
rewritten to their logical equivalents (`ml-`→`ms-`, `mr-`→`me-`, `pl-`→`ps-`,
`pr-`→`pe-`, `text-left`→`text-start`, `text-right`→`text-end`,
`border-l`→`border-s`, `rounded-l*`→`rounded-s*`, `left-*`→`start-*`,
`right-*`→`end-*`), plus `left-4` in `.skip-link` and four `.paper-tear*`
`left`/`right` pairs → `inset-inline: 0`. Remaining physical declarations: **13**
`left:`/`right:` in `src/index.css`, all inside the LTR-pinned `.sig-*` block,
and **3** animation names (`slide-in-from-left-1/2`, `slide-out-to-right-full` in
`ui/dialog.tsx` and `ui/toast.tsx`) which Tailwind has no logical form for —
those keyframes still travel left-to-right in RTL and are the known gap.

### Adding or changing a string

```bash
# 1. edit frontend/src/i18n/locales/en.json (add/change the id)
# 2. translate only what changed (the cache re-translates one key, not a locale)
python3 scripts/i18n/translate_web.py
# 3. gate it
python3 scripts/i18n/check_web_locales.py
```

`translate_web.py` is resumable (the cache is the resume point), rotates across
the workspace's Gemini keys, backs off on 429/503, validates ICU placeholder and
plural parity per message, retries a failing message alone once, and **refuses to
write a locale that still fails** rather than shipping a literal `{count}`.
Flags: `--locale hi,ja`, `--force`, `--dry-run`, `--sleep`, `--batch`.

`check_web_locales.py` (stdlib only, `--strict`, `--json`) fails on: a language
present in one of {backend, `store/asc/locales.json`, `localeMeta.ts`, the
catalog directory} but not the others; a missing or orphan key; ICU
placeholder/plural drift; unbalanced braces; a `t('…')` id used in the source but
absent from `en.json`; a catalog that is a copy of English; and a wrong `rtl`
flag. Warnings cover unreferenced keys, native-name drift from the store table,
and a stale translation cache. When a catalog is more than
`WIDE_GAP_MAX_KEYS` short it reports the locale's coverage as a single error with
the resume command instead of one line per key.

### Translation state

`en.json` holds 844 messages. Coverage today:

| Locale group | Codes | Keys translated |
|---|---|---|
| English (source) | `en` | 844 / 844 |
| Partially translated | `ar de fi fr gu he hi hu it kn mr no pa pl pt ru sl sv ta te uk ur` (22) | 296 / 844 (35 %) |
| Not yet translated | `bn ca cs da el es hr id ja ko ml ms nl or ro sk th tr vi zh` (20) | 0 / 844 |

Nothing renders a raw message id: `loadLocale.ts` merges each catalog over
`SOURCE_MESSAGES`, so an untranslated key shows its English text. The gap is
Gemini quota (all models returned `daily quota exhausted`, retry ~6 h), not a
pipeline defect — the ICU validator in `translate_web.py` refuses to write a key
whose placeholders or plural branches drift, which is why the 22 partial catalogs
are structurally clean and only *incomplete*.

Resume: `python3 scripts/i18n/translate_web.py` (resumable from
`.translations.json`; `--locale` to take one language, `--batch` to tune chunk
size). `check_web_locales.py` exits non-zero until every locale reaches 844.

### Not localized in this pass

Still English, ordered by what to do next:

1. `pages/gifts/GiftsPage.tsx` — the gift builder (~50 strings, mostly dynamic
   sentences built from `formatUsd` and voucher state).
2. `components/wardrobe/BatchExtractionFlow.tsx`,
   `SocialImportQueueReview.tsx`, `BatchGenerationProgress.tsx` — the
   extraction pipeline's progress copy.
3. `components/outfits/create/OutfitMetaBar.tsx` and
   `components/calendar/CalendarView.tsx` remainder.
4. Marketing surfaces: `pages/public/*` (except what `SharedOutfitPage` needs),
   `pages/seo/IntentSeoPage.tsx`, `pages/tools`, `pages/blog`, `pages/features`,
   `components/landing/*`.

**SEO localization was deliberately not done here.** It is a routing change, not
a translation change: it needs `frontend/src/routes/publicRoutes.ts` to carry a
`/:locale?` segment or a per-language path prefix, `components/seo/SEO.tsx` and
`components/seo/seo-config.ts` to emit reciprocal `hreflang` plus `x-default`,
`frontend/scripts/prerender-meta.mjs` to write one `<html lang>` per built page
(it currently inherits the single `lang="en"` in `index.html`),
`frontend/scripts/generate-sitemap.mjs` to emit 128 URLs × 43 languages with
alternates, and `frontend/public/sitemap.xml` (tracked, build-written) to grow
from 128 to ~5 500 `<url>` entries before any of it can be crawled correctly.
Shipping the translation half without the routing half produces 43 copies of the
same English page at one URL — worse than not shipping it.

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
- `VITE_SUPABASE_PUBLISHABLE_KEY` — the only Supabase key the client reads
  (`src/lib/supabase.ts`); there is no `VITE_SUPABASE_ANON_KEY` in the web app
- `VITE_PUBLIC_POSTHOG_KEY` / `VITE_PUBLIC_POSTHOG_HOST` — PostHog analytics
  (`posthog-js`); host defaults to `https://us.i.posthog.com`
- `VITE_SENTRY_DSN` — Sentry error tracking (optional; empty disables)

### Feature flags

Read flags through `frontend/src/lib/feature-flags.ts` (`FEATURES`), never with an
inline `import.meta.env` check. Vite inlines these at build time, so a disabled
feature can be dropped from the bundle as well as the UI. Declare new vars in
`frontend/src/vite-env.d.ts`.

| Var | Default | Gates | Backend counterpart |
|-----|---------|-------|---------------------|
| `VITE_ENABLE_SOCIAL_IMPORT` | `true` | Instagram import panes in `BatchExtractionFlow` | `ENABLE_SOCIAL_IMPORT` (router unmounted when off) |
| `VITE_ENABLE_GAMIFICATION` | `false` | `/gamification` route, sidebar nav entry, and the lazy import of `GamificationPage` | `ENABLE_GAMIFICATION` (router stays **mounted**, handlers return zeroed 200s) |
| `VITE_ENABLE_GIFT_VOUCHERS` | `true` | `/gifts` studio, dashboard gift priority, sidebar entry, and lazy import; set `false` only for a UI rollback. The public claim page remains mounted | `ENABLE_GIFT_VOUCHER_CREATION` (new issuance only) |

There is no `/config` endpoint, so each pair must be kept in step by hand.
Gamification defaults off because nothing on the backend writes `user_streaks`
or `user_achievements`, so the page can only ever render zeros.

Gating the `<Route>` alone is not enough to remove the code: the
`lazy(() => import(...))` binding must be gated too, or Rollup still emits the
page chunk. `App.tsx` does both.

### Gift voucher sharing

The protected gifts studio supports paid and free issue, recipient name and
email, optional occasion, live premium preview, Checkout return, incoming
named claims, sent/received history, edit, rotation, copy, native Web Share,
and portrait download. No occasion is the default. Birthday and anniversary
show fixed greetings; Other requires a 1–80 character greeting. The private
note is optional for every choice. New vouchers require recipient email. The
email is not rendered in the sent list, public claim page, artwork, or
analytics. The secure link is shared separately; portrait artwork contains no
claim credential.

DashboardPage requests the gift summary only for a verified signed-in account.
It shows one non-dismissible card in this order: incoming gift, free
invitation, then the existing referral banner. A summary failure restores the
referral banner. The card links to a selected incoming claim or the selected
complimentary term in the gifts studio.

GiftClaimPage serves public private-link claims. Named vouchers also require
the recipient's verified email; legacy link-only vouchers continue to work.

The claim credential is stored in `location.hash`, never the path or query.
`captureCredential` removes the fragment with `history.replaceState` before
route analytics effects run, then keeps it in localStorage for at most seven
days so login, registration, OAuth, and email verification can return to the
gift. Public states do not reveal the claimant. The Netlify edge metadata path
uses the versioned 1200x630 artwork and adds `noindex, nofollow`.

## References

- Components notes: `docs/references/frontend-components.md`
- Workflows: `docs/references/workflows.md`
- File structure: `docs/references/file-structure.md`
- Validation: `docs/references/validation.md`

## Testing

Vitest (config in `vite.config.ts` `test` block: jsdom, globals,
`setupFiles: ./src/test/setup.ts`), with ~44 test files under
`src/**/*.test.{ts,tsx}`. `npm test` runs `vitest run` (non-watch);
`npm run test:watch` is the watch mode. A full frontend check is
`npm run lint && npm test && npm run build` (build's prebuild rewrites the
tracked `public/sitemap.xml` — see the verification matrix in `docs/README.md`).

## UI QA path

When fixing a visual or interaction bug in the web app:

1. **Reproduce** — open the page in the browser and confirm the issue (viewport, route, auth state).
2. **Capture** — use browser tools, DOM inspection, and/or a screenshot so the failure is concrete (not a guess from code alone).
3. **Fix** — change the component/styles/logic that caused it.
4. **Re-verify** — reload and confirm the fix in the browser at the same state.

**Content visibility:** content and controls must stay visible by default. Never gate text or interactive UI on an entrance animation completing (no `opacity: 0` until JS/scroll reveal). Prefer animating elements that are already on screen (hover, layout, scroll-linked transforms on visible content). A static, fully readable page beats an animated one that renders empty when motion does not run.
