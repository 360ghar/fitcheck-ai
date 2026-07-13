# Changelog

All notable changes to the FitCheck AI Flutter app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3+5] - Unreleased

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
