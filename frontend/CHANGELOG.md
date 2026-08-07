# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **SEO / GEO / AEO growth pass**:
  - Six new SEO pages: FitCheck vs Stylebook / Indyx / Cladwell / Open
    Wardrobe comparisons, plus "What is a capsule wardrobe" and "What is
    wardrobe utilization" guides (with stats blocks and cited sources).
  - Ten "What to wear in <city>" pages under `/wear/` (Mumbai, Delhi,
    Bengaluru, Chennai, London, New York, Dubai, Singapore, Toronto, Sydney)
    with season-by-season, city-specific content.
  - Interactive cost-per-wear calculator at `/tools/cost-per-wear-calculator`.
  - Shared build-time route registry (`scripts/seo-content.mjs`) now drives
    sitemap, prerendered meta, llms files, and the IndexNow ping.
  - `llms-full.txt` + per-page `.md` mirrors generated at build; `llms.txt`
    bumped to v2.2.
  - Entity/structured data upgrades: `sameAs`, `SearchAction`, `VideoObject`
    (site-hosted promo), `Person` authors + `speakable` on blog articles.
  - Crawler soft-404 guard edge function (`not-found`) + real 404s for
    missing blog posts; `X-Robots-Tag: noindex` headers on app routes.
  - IndexNow key + build-time ping for Bing/Copilot/Seznam/Naver.
  - Hero/landing images converted to WebP (~80% smaller).

### Changed

- **Saving an outfit no longer fires an AI generation you did not approve.**
  Creating an outfit moved from a dialog to its own page (`/outfits/new`), and
  the order is now draft → render → review → save. Previously `createOutfit`
  persisted the outfit and then fire-and-forgot a render, so every save spent a
  generation whether or not the result was wanted. Approving a preview attaches
  the bytes already rendered, so it costs nothing further, and "Save without a
  preview" creates the outfit with no look at all. An outfit saved without a
  look shows the existing "No AI look yet" state and its Generate action.
  `?action=create` still works and redirects to the new page.
- Recommendations → "Save as outfit" now carries the suggested pieces through to
  the create page. It previously opened an empty draft and lost the selection.

### Performance

- **`/blog` is now prerendered with real content.** The build fetches the
  first page of posts + categories and bakes them (plus serialized React Query
  state) into `dist/blog/index.html`, so first paint no longer waits for
  ~700 KB of JS. The baked state is stamped stale so the client refetches in
  the background; if the API is unreachable at build time the route ships the
  empty shell as before (PSI 2026-08-07: FCP 1.9s / LCP 5.2s / SI 5.1s lab →
  FCP+LCP land at first CSS paint).
- **Stylesheet inlined into every prerendered page** (all routes + the SPA
  app shell) — removes the render-blocking `/assets/index-*.css` request
  (~400 ms on slow 4G) from the critical path of every pageview.
- **Per-route modulepreloads** for the blog chunk graph via the Vite build
  manifest, so hydration JS downloads in parallel with the baked paint.
- **Blog images served as right-sized AVIF/WebP.** New `lib/images.ts` +
  `components/blog/BlogImage.tsx` rewrite stored Unsplash URLs
  (`?w=800&q=80` JPEG) to `auto=format&w=…&q=70` with a responsive `srcset`;
  measured ~55–65% fewer bytes per image. Featured post images get
  `fetchpriority="high"`.
- Blog images fall back to the post's emoji on load error, and the six
  dead Unsplash photo IDs behind 21 posts were replaced with verified
  working photos (`backend/scripts/fix_broken_blog_images.py`) — the PSI
  console 404 is gone.
- Category-pill row reserves height so the posts grid no longer shifts down
  when categories finish loading (field CLS contributor).
- **`/blog` no longer 301-redirects to `/blog/`** — a Netlify rewrite
  (`/blog` → `/blog/`, status 200, force) keeps the canonical URL and drops
  the redirect hop (~0.6 s of mobile LCP in the PSI run).
- **Preconnects** for `images.unsplash.com`, `api.fitcheckaiapp.com` and the
  two PostHog origins, so first-paint connections start during HTML parse.
- **Blog API is cached + half the round trips**: `Cache-Control: public,
  max-age=300, stale-while-revalidate=600` on `/blog/posts`,
  `/blog/posts/{slug}` and `/blog/categories`, and `list_posts` now fetches
  count + page in one Supabase request instead of two (the endpoint measured
  3.4 s on the mobile critical path).

### Fixed

- Blog category/“Blog” badges now meet 4.5:1 contrast in both themes
  (was ~3.9:1 light / ~4.0:1 dark).

## [1.0.0] - 2026-01-19

### Added

- **AI Photoshoot Generator**: Create AI-powered photoshoots with your wardrobe items
- **Subscription Billing**: Integrated billing system for premium features
- **Referral System**: User referral program with rewards
- **Support Tickets**: In-app support ticket system for user assistance
- **Expanded Wardrobe Flows**: Enhanced wardrobe management and organization
- **Expanded Outfit Flows**: Improved outfit creation and styling workflows
- **Flutter Mobile App**: Cross-platform mobile application support

### Fixed

- Standardized logging parameters across the application
- Updated freezed models for improved type safety
