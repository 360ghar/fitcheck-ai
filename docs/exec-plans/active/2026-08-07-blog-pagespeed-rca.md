# Plan: Blog PageSpeed RCA & fixes (prerender, inline CSS, images)

Status: active
Started: 2026-08-07
Owner: agent

## Goal

Fix the PageSpeed Insights failure for `https://fitcheckaiapp.com/blog` (mobile
score 75, Core Web Vitals failed: field LCP 4.4s / INP 268ms / CLS 0.32; lab
FCP 1.9s / LCP 5.2s / SI 5.1s) and lift the page into the green for LCP/FCP.
Also remove the Unsplash 404 console error and fix the a11y contrast failure.

## Non-goals

- Rewriting the navbar `Sheet` / `ThemeToggle` to drop the `ui-vendor` chunk
  (tracked TD-086) — all-or-nothing chunk removal, deferred.
- Prerendering `/blog/:slug` post pages (tracked TD-087).
- Proxying PostHog assets for cache TTL (tracked TD-088, ~1 KiB).
- Field TTFB 1.6s: verified network-bound CrUX data (HTML is an edge-cached
  static file; HSTS/CSP/COOP headers all present live). No server-side issue.

## RCA (root causes)

1. `/blog` was in `PRERENDER_SKIP` → served `app-shell.html` with an empty
   `#root`. Nothing painted until ~700 KB JS (entry 147 KB + react-vendor
   178 KB + ui-vendor 125 KB + query-vendor 81 KB + module-B 170 KB raw)
   fetched, parsed, executed. FCP/LCP = JS render time.
2. Render-blocking `/assets/index-*.css` (~17.7 KiB gz, ~400 ms on slow 4G)
   delayed first paint on every page.
3. Blog images stored as Unsplash `?w=800&q=80` JPEGs, downloaded at 800px
   regardless of display size; measured 115 KB → 44 KB AVIF (`w=640&auto=format&q=70`)
   → 21 KB (`w=400`). Six photo IDs 404 (photos removed from Unsplash) → PSI
   console error; 21 DB rows affected.
4. Field CLS 0.32 vs lab 0.042: category pills render after the categories
   fetch and push the posts grid down; fonts swap; third-party loads.
5. Blog badge `bg-secondary text-primary` ≈ 3.9:1 light / ~4.0:1 dark
   (WCAG AA needs 4.5:1).

## Changes

Frontend (`frontend/`):

- `src/routes/publicRoutes.ts` — `/blog` removed from `PRERENDER_SKIP`.
- `src/entry-prerender.tsx` — blog prefetch: build-time fetch of posts
  page 1 (12) + categories from `api.fitcheckaiapp.com` (10s timeout), render
  real grid via a `QueryClientProvider`, `dehydrate` state into a
  `<script id="__FITCHECK_QUERY_STATE__">`; queries stamped `dataUpdatedAt = 0`
  (stale → client refetches on mount); `skip: true` when the API is down
  (ships the empty shell, never fails the build). Query keys must match the
  hooks exactly — `search: ''`, not `undefined` (react-query stringifies keys).
- `src/main.tsx` — `hydrate()` the baked query state before mount.
- `scripts/prerender-html.mjs` — (a) inline the stylesheet into every
  `dist/**/*.html` (all 42 routes + app-shell), (b) per-route modulepreloads
  for the blog chunk graph from `dist/.vite/manifest.json`
  (`build.manifest: true` in `vite.config.ts`), (c) handle `render()`'s
  `skip` signal.
- `src/lib/images.ts` + `src/components/blog/BlogImage.tsx` (new) — rewrite
  Unsplash URLs to `auto=format&w=…&q=70`, responsive `srcset`, `decoding="async"`,
  `fetchpriority="high"` on the featured image, emoji fallback on load error.
  Used in `BlogIndexPage.tsx` (cards) and `BlogPostPage.tsx` (featured + related).
- `BlogIndexPage.tsx` — BlogImage; category-pills row rendered
  unconditionally with reserved `min-h-[124px] md:min-h-[44px]` + skeleton
  pills (CLS); badge contrast fix (`text-secondary-foreground`).
- `BlogPostPage.tsx` — BlogImage; badge contrast fix.
- `pages/public/FAQPage.tsx`, `pages/public/AboutPage.tsx` — same
  badge-contrast fix as the blog pages (identical pattern).
- `components/blog/__tests__/BlogImage.test.tsx` (new) — srcset rewrite,
  passthrough, lazy/priority, onError + missing-src fallbacks.

Data (`backend/`):

- `scripts/fix_broken_blog_images.py` (new, idempotent, DRY_RUN default) —
  six broken Unsplash photo IDs remapped to verified-working replacements
  (all HEAD-checked 200); applied to 21 `blog_posts` rows in production
  (old URLs captured in the dry-run output above / in this file's decision
  log). The `?w=800&q=80` params are preserved; the frontend now re-serves
  them as AVIF/WebP regardless.

Docs:

- `docs/FRONTEND.md` — prerender section updated (blog bake, query-state
  hydration, key-matching rule, CSS inlining, modulepreloads, image helper).
- `frontend/CHANGELOG.md` — Performance + Fixed sections under Unreleased.
- `docs/exec-plans/tech-debt-tracker.md` — TD-086 (ui-vendor on public
  critical path), TD-087 (post-page prerender), TD-088 (PostHog cache TTL).

### Second pass — gap completion (same day, same tree)

- `netlify.toml` — kill the `/blog` → `/blog/` 301. The prerendered
  `dist/blog/index.html` triggers Netlify's pretty-URL redirect (+595 ms of
  mobile LCP in the PSI run; confirmed live with `curl -I`).
  `[[redirects]] from = "/blog" to = "/blog/" status = 200 force = true`
  before the SPA catch-all keeps the `/blog` URL (its canonical + sitemap)
  and drops the hop. `force = true` is required — without it Netlify serves
  the existing file and its auto-301 first.
- `index.html` — preconnects for the four origins first paint reaches:
  `images.unsplash.com` (card images), `api.fitcheckaiapp.com` (API),
  `us.i.posthog.com` + `us-assets.i.posthog.com`. Copied into every
  prerendered route shell by prerender-meta.
- `backend/app/api/v1/blog.py` — one Supabase round trip + cache headers.
  `list_posts` ran a count query THEN the page query (the endpoint measured
  3.4 s on the mobile critical path); PostgREST returns the exact count
  alongside any page, so both now execute once.
  `Cache-Control: public, max-age=300, stale-while-revalidate=600` on
  `/posts`, `/posts/{slug}`, `/categories`. `backend/tests/test_blog_api.py`
  locks both behaviors (5 tests — including that a not-found post never
  carries the cache header, so a 404 cannot be cached for max-age).
- `scripts/prerender-html.mjs` — modulepreload hrefs lost the `assets/`
  prefix: Vite 5's manifest names `imports` as `_<name>.js` (no directory
  prefix) while `file` values are `assets/<name>.js`, so emitted links like
  `/badge-*.js` 404'd. Names normalized to `assets/<name>.js` for hrefs,
  dedupe and byFile lookups; verified 14 valid preloads in `dist/blog`.
- `BlogIndexPage.tsx` — first card is the LCP element on mobile:
  `priority={index === 0}` (`loading="eager"` + `fetchpriority="high"`) so
  the preload scanner starts the baked image before any JS.

## Verification

```bash
cd frontend && npm run lint && npm run build && npm test
# dist/blog/index.html: baked posts (12 <img>, no animate-pulse), inline
# <style> (no <link rel="stylesheet">), __FITCHECK_QUERY_STATE__ script,
# modulepreloads only for existing files.
cd backend && python3 scripts/scan_live_blog_images.py  # 0 broken images
cd backend && DRY_RUN=1 python scripts/fix_broken_blog_images.py  # "nothing to do"
```

Final merged-state re-run (both passes landed in one tree): frontend lint
clean, build green (42 routes; 14 modulepreloads all point at existing
`dist/assets/` files; first card `loading="eager"` + `fetchpriority="high"`
with `auto=format` srcset; query-state blob parses with the exact client
query keys; canonical `https://fitcheckaiapp.com/blog`), 219/219 tests across
43 files (incl. `BlogImage.test.tsx`); backend 1331 passed / 4 skipped incl.
the 5 blog API tests, `ruff` clean. Production blog rows re-checked
read-only: 86 published posts, all 20 distinct image URLs HEAD 200 (incl. the
6 replacements), fix script reports "no rows reference a broken photo ID".

Re-test PageSpeed Insights for `/blog/` after deploy (user deploys via normal
Netlify flow). Expected: FCP ~0.8s, LCP ~1.3s, performance mid-90s,
accessibility 100, no console 404. Field CrUX improves over the next 28 days.

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-07 | Prerender `/blog` with baked first page + categories; skip (empty shell) if the build-time API call fails | Empty root was the LCP/FCP root cause; a failed bake must never break a deploy; client refetches because the state is stamped stale |
| 2026-08-07 | `search: ''` (not `undefined`) in the prefetch query key | react-query hashes keys by stringified value; `undefined` properties are dropped, `''` is not — mismatch silently produced the skeleton |
| 2026-08-07 | Inline the full stylesheet (17.7 KiB gz) instead of critical-CSS splitting | `style-src 'unsafe-inline'` already allowed; HTML is revalidated (`must-revalidate`), so no repeat-visit cost |
| 2026-08-07 | `dataUpdatedAt = 0` on dehydrated queries | Baked content must not suppress fresh data for the client's 5-min staleTime |
| 2026-08-07 | `fetchpriority` passed lowercase (spread), not React 18's `fetchPriority` | React 18 warns + drops the camelCase prop |
| 2026-08-07 | Broken photo ID → replacement photo mapping (6 pairs, 21 rows) | Each replacement HEAD-verified 200 on 2026-08-07; same-subject area; params preserved |
| 2026-08-07 | Badge contrast via `text-secondary-foreground` on `bg-secondary` | ~12:1 light / ~11:1 dark, theme-token based (no hard-coded colors); `--primary` tokens fail in both modes (~3.9–4.2:1); applied to blog, FAQ and About pages (same pattern) |
| 2026-08-07 | Category-pills container rendered unconditionally (reserved `min-h-[124px] md:min-h-[44px]` + skeleton pills while loading) | Reserving height only after categories load (initial approach) prevented nothing — the shift happens exactly when the container appears; the skeleton also fills the band visually |
| 2026-08-07 | First blog card image rendered eager + `fetchpriority="high"` | On short mobile viewports the first card image is the largest first-paint element (larger than the hero H1); keeps it out of the lazy queue |

## Deferred debt

- TD-086 `ui-vendor` chunk on the public critical path (navbar Sheet +
  ThemeToggle rewrite; ~25 KB unused JS per PSI).
- TD-087 blog post pages still empty-shell to users; top-N prerender option.
- TD-088 PostHog config.js 5m TTL (~1 KiB).
