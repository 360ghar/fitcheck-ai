# Changelog

All notable changes to the FitCheck AI Flutter app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.4+9] - 2026-08-06

Note: builds 6, 7 and 8 never got their own entries (build 7 was rejected by
App Store Connect and build 8 was never submitted) - this entry covers
everything since 1.0.3+5, backfilled from commit history.

### Added

- **Over-the-air updates (Shorebird code push)**: Dart-only fixes now reach
  devices without a store release. The running patch number appears under
  Settings > About and is attached to Sentry crash reports
- **Mobile in-app purchases**: subscription plans purchasable on iOS and Android
  via StoreKit / Play Billing
- Shareable promo codes redeeming free Plus/Pro grants
- Replayable photoshoot previews
- Source-image tracking for extracted wardrobe items

### Changed

- The More tab is folded into the profile hub, so account actions live on one
  screen instead of two
- Photoshoot generation is materially faster, with batch generation overlapped
  against extraction
- Every error snackbar now travels a single path, so a message shown to the user
  always reaches telemetry
- Uploads are compressed harder, cutting failures on slow connections
- Cleared all 568 analyzer lints and deleted verified-dead services, pages,
  controllers and widgets

### Fixed

- Photoshoot runs that produce zero images now fail loudly and report an
  accurate quota instead of silently consuming credits
- Processing status is honest across the app - screens no longer claim work is
  finished while it is still running
- Wardrobe Stats and Outfit Collections are reachable again
- Weather and astrology recommendation tabs no longer render blank
- Two shadowed routes now resolve to the intended screens
- Batch extraction recovers from partial failures, and its poll loops are capped
  so they can no longer spin forever
- Restored recommendation images, calendar events, and referral sharing
- Password reset links open the web frontend instead of the API server
- Restored AI and upload timeouts; guarded every Sentry capture

## [1.0.3+5] - 2026-07-15

Note: the version jumped from 1.0.1+3 directly to 1.0.3+5 in a single
commit (no 1.0.2 was ever tagged/shipped) - this entry covers everything
since 1.0.1+3, backfilled from commit history.

### Added

- Expanded outfits and wardrobe flows
- Async SSE streaming and job-based processing for photoshoot generation
- Social profile import (Instagram/Facebook) with AI-powered wardrobe extraction
- Astrology-based outfit recommendations
- Blog system with admin panel, category filtering, and pagination
- App Store launch preparation (accessibility labels, Sentry crash reporting,
  dynamic theme mode, free v1 paywall gating)
- UGC hide-on-device for shared outfits (Guideline 1.2)
- App Store metadata sync under `metadata/`; reviewer seed script
  (`backend/scripts/seed_app_store_reviewer.py`)

## [1.0.1+3] - 2026-01-19

### Added

- **AI Photoshoot Generator**: Create AI-powered photoshoots with wardrobe items
- Photoshoot configuration with customizable settings
- Photoshoot results view with generated images

### Changed

- Updated API constants for photoshoot endpoints
- Improved photoshoot controller state management
- Enhanced photoshoot models with freezed code generation

### Fixed

- Standardized logging parameters across the app
- Updated freezed models for improved type safety

## [1.0.0+2] - Initial Release

### Added

- Wardrobe management with item categorization
- Outfit creation and styling
- AI-powered outfit recommendations
- User authentication with Supabase
- Profile management
- Subscription billing integration
- Referral system
- Support tickets
- Cross-platform support (iOS & Android)
