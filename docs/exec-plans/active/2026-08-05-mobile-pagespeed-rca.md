# Plan: mobile PageSpeed RCA and fixes (fitcheckaiapp.com)

Status: active
Started: 2026-08-05
Owner: Claude

## Goal

Fix poor mobile PageSpeed on `https://fitcheckaiapp.com/` — the page every ad
click, Play Store referral and organic result lands on.

The linked PSI report had no CrUX field data and the PSI API was over its shared
daily quota, so the RCA was built from direct measurement of the live site plus
the shipped bundle.

## Measured before state (live production, 2026-08-05)

| Resource | Transfer (br) | Decoded |
|---|---|---|
| `assets/index-*.js` (entry) | 184.6 KB | **679.7 KB** |
| `react-vendor` | 58.0 KB | 177.9 KB |
| `ui-vendor` | 33.9 KB | 124.8 KB |
| `query-vendor` | 28.5 KB | 82.7 KB |
| `index-*.css` | 19.8 KB | 106.2 KB |
| `landing/wardrobe.webp` | 60.5 KB | — |
| **Total** | **~493 KB** | **~1.34 MB** |

~305 KB of JS transferred → ~1.07 MB to parse and execute before anything
painted. Runtime probe: **`FCP === LCP` to the millisecond**, zero project font
faces loaded, PostHog on the critical path, `/landing/*` served
`max-age=0, must-revalidate`, and `assets/index-*.js.map` returning HTTP 200.

## Root causes

1. **RC1 — no rendered HTML.** `#root` shipped empty; `prerender-meta.mjs`
   injected only meta tags and a `<noscript>` teaser. FCP could not happen until
   the whole SPA booted, which is exactly why FCP and LCP coincided.
2. **RC2 — entry chunk carried three libraries first paint never needs.**
   `posthog-js` (~370 KB raw alone), `@sentry/react` (imported regardless of
   whether a DSN was set — the `if` only guarded `init`), and
   `@supabase/supabase-js` (pulled in by `Navbar` → `authStore`, for two call
   sites in async auth actions).
3. **RC3 — 284 KB of fonts that nothing could use.** `@fontsource-variable/*`
   registers `"Inter Variable"`/`"Manrope Variable"`; `tailwind.config.ts` asked
   for `"Inter"`/`"Manrope"`. Nothing matched, so no font was ever requested and
   the whole site silently rendered in system-ui.
4. **RC4 — `fetchpriority="high"` on a below-the-fold mobile image.** The hero
   grid is `lg:grid-cols-12`, so under 1024px the image stacks below the h1, stat
   row and buttons. LCP on mobile is the h1; the hint made a 60 KB off-screen
   image race the render-critical CSS and JS.
5. **RC5 — cache and build hygiene.** No cache header for `/landing/*`,
   `sourcemap: true` in production with maps publicly fetchable, no CSP.

## Fix

### W1 — prerender the public routes (RC1)
- `src/routes/publicRoutes.ts` — new shared manifest, single source of truth for
  the public route table (`App.tsx` and the prerender both read it).
- `src/entry-prerender.tsx` — build-only entry; `renderToString` of
  `StaticRouter` + `PublicLayout` + the matched page. `matchPath` so
  `/wear/:citySlug` resolves the concrete city paths. No new dependency —
  `StaticRouter` ships in react-router 7.11.
- `scripts/prerender-html.mjs` — builds the SSR bundle, injects markup into each
  `dist/<route>/index.html`, **exits non-zero** if any route renders empty or
  none render.
- `src/main.tsx` — awaits `preloadRoute()` before `createRoot().render()`. This
  is the non-obvious part: without it React clears the prerendered markup and
  paints the Suspense spinner over already-visible content, which would undo the
  win and push LCP back out. Kept `createRoot` (not `hydrateRoot`) to avoid
  hydration-mismatch bugs; measured CLS for the swap is 0.
- `vite.config.ts` — `ssr.noExternal` and `manualChunks: undefined` for the SSR
  build. Both are gated on `isSsrBuild`: Vitest reads the same config, and an
  unconditional `noExternal: true` inlines the runner's own modules and every
  test file collects as "No test suite found" (hit and fixed during this work).

### W2 — defer posthog, Sentry, supabase (RC2)
- `src/lib/analytics.ts` — PostHog now dynamic-imported and init'd on idle;
  init options moved here from `main.tsx`. Reused the module's existing
  "no-ops if PostHog is not ready" contract, so callers were unaffected.
  `whenPostHogReady()` replaces the `usePostHog()` context hook.
- `src/lib/error-reporting.ts` — new lazy Sentry wrapper; repointed `main.tsx`
  and both error boundaries. Test updated to assert on this seam.
- `src/lib/supabase.ts` — module-scope `createClient` → memoized
  `getSupabase()`; two `await` sites in `authStore.ts`.
- `PostHogIdentify.tsx` — subscribes to the deferred load instead of context.

### W3 — make the brand type render (RC3)
Self-hosted `public/fonts/{inter,manrope}-latin-var.woff2` (+ OFL licenses), two
hand-written `@font-face` rules in `src/index.css` named to match Tailwind as it
already stood (so `tailwind.config.ts` is untouched), both preloaded from
`index.html`, `@fontsource-variable/*` removed. Manrope's real axis is
`200 800`, not `100 900`.

### W4 — hero image (RC4)
Dropped `fetchpriority="high"`, added `srcset`/`sizes` with a generated 640w
variant (20 KB vs 59 KB), kept `width`/`height`. Not lazy — at ≥lg the image *is*
the LCP. Note the 640w variant does not help the PSI run itself (Moto G4
emulation at DPR 2.625 requests ~1080px and picks the 1152w source); it is a
real saving for DPR-1 devices.

### W5 — cache and build hygiene (RC5)
`netlify.toml`: long-cache `/fonts/*` and `/landing/*` (see the rename caveat in
the comment there), plus a **report-only** CSP so a missing host cannot take the
app down. `vite.config.ts`: `sourcemap: false` — `'hidden'` would not fix it,
the maps still land in `dist/` and get published.

## Results

| | Before | After |
|---|---|---|
| Entry chunk (raw) | 663.8 KB | **187.1 KB** |
| Critical path (brotli) | ~493 KB | **~247 KB** |
| Critical path (raw) | ~1372 KB | **~830 KB** |
| FCP dependency | full SPA boot (~1.07 MB JS) | HTML + CSS (~25 KB br) |
| Fonts actually loaded | 0 | Inter + Manrope (71 KB, preloaded) |
| `@font-face` rules in blocking CSS | 13 | 2 |
| Published sourcemaps | 92 files, 9.4 MB | 0 |
| CLS on React takeover | — | 0 (measured) |

Prerendered HTML costs +6.8 KB brotli on `/` (10.8 KB vs ~4.0 KB) — a good trade
for a paint that no longer waits on any JavaScript.

39 of 40 SEO routes prerender; `/blog` is intentionally skipped (data-driven,
already fronted by the `seo-html` edge function).

## Out of scope

- Flutter and backend.
- The `/blog/*` and `/shared/outfits/*` edge functions.
- Removing PostHog session replay — a deliberate feature
  (`2026-08-01-replayable-previews-posthog.md`); only its init is deferred.
- Promoting the CSP out of report-only, and replacing `'unsafe-inline'` in
  `script-src` with build-time nonces for the inline theme script and JSON-LD
  blocks.

## Verification

```bash
cd frontend && npm run lint && npm test -- --run && npm run build
```

ESLint clean, 38 files / 166 tests passed, build clean (39 routes prerendered).
Verified in a browser against the built output: `document.fonts` now contains
Inter and Manrope, CLS 0, no Suspense spinner over the prerendered markup, no
React or hydration errors in the console, client-side navigation to a lazy route
and the back button both work.

Entry-chunk check is by SDK marker, not by name: `grep posthog` on the entry
still matches the inlined `https://us.i.posthog.com` host string, while
`rrweb`/`sessionRecording`/`__PosthogExtensions__` are all 0.

## Follow-ups

- Re-run PageSpeed mobile after deploy and confirm FCP and LCP are no longer the
  same instant.
- Confirm in PostHog that landing-page pageviews and replays still arrive (the
  first ~1s of a session is now outside the recording, by design).
- `scripts/ping-indexnow.mjs` fails with `InvalidRequestParameters` during
  `postbuild`. Pre-existing, unrelated to this change, non-fatal — worth a look.
- Two routes in `App.tsx` are missing from `SEO_ROUTES` and so are not
  prerendered: `/compare/fitcheck-vs-acloset`, `/compare/fitcheck-vs-whering`.
  Pre-existing gap; they still work via the SPA fallback.
