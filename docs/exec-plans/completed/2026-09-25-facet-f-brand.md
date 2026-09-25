# Plan: Facet F brand assets

Status: complete
Started: 2026-09-25
Owner: agent

## Goal

Use the selected jade Facet F across the website, admin, and native app.
Prepare version 1.2.0 build 14 and commit the local changes. The user's final
instruction limits this work to changes and a commit; deployment and upload
are outside the final scope.

## Acceptance criteria

- [x] Preserve the selected reference and create a shared vector master.
- [x] Regenerate favicons, PWA, touch, launcher, themed, desktop and launch assets.
- [x] Verify web/admin checks, Flutter tests, icon sizes and masks.
- [x] Prepare version 1.2.0+14 and release notes.
- [x] Stop release and sign-in processes after the user narrowed the scope.

## Decisions

- Keep 1.2.0; increment build 13 to 14. A native icon change requires a new binary.
- Use a dark ink app-icon background and transparent in-app marks.
- Preserve existing paper UI colours and light native launch backgrounds.
- Update favicon URLs to invalidate browser cache. Keep public component APIs.
- Do not push, deploy, upload a build, or submit for review in this change.

## Progress

2026-09-25: Inspected source, release scripts, remote branch and existing App Store
Connect draft. Confirmed existing Shorebird token works. Created Facet F masters,
regenerated icon sources, and bumped the build number.

## Verification

Frontend lint/tests/build and admin lint/typecheck/tests/build passed. Flutter
analysis found no issues; all 383 non-golden tests passed. Architecture, docs,
and iOS deployment-target checks passed. Rendered icons and browser branding
were inspected. Export dimensions, opacity, and mask-safe areas passed checks.

## Related

- docs/brand/README.md
- docs/exec-plans/active/2026-09-25-ios-1-2-release.md
- docs/exec-plans/completed/2026-09-25-ten-icon-concepts.md

2026-09-25: The 1024 App Store source has no alpha. IndexNow postbuild ping
returned 422; recorded separately as TD-119. The iOS release build was stopped
during Xcode compilation after the user requested only changes and a commit.
No new IPA was completed or uploaded. Website deployment did not run.
