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
