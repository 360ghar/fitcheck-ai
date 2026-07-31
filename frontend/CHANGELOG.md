# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
