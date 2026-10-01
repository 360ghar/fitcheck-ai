# Plan: upload iOS build 14

Status: complete
Started: 2026-09-25
Owner: agent

## Goal

Build the committed Facet F app as version 1.2.0 (14) and upload it to App Store
Connect. The user will select the build for version 1.2.0. Build selection and
App Review submission are outside the final scope.

## Acceptance

- [x] Build a signed Shorebird IPA from commit 4026861.
- [x] Verify version 1.2.0, build 14, signing, and the packaged icon.
- [x] Confirm App Store Connect accepts and lists the upload.
- [x] Record the upload result and leave version selection to the user.

## Verification

The same source passed Flutter analysis and 383 non-golden tests during the
icon change. Use the pinned release script, inspect the IPA metadata and
signature, and verify the uploaded build in App Store Connect.

## Progress

2026-09-25: Confirmed the tracked worktree is clean at 4026861. Build 13 is
the prior archive. Starting a new signed build with the provisioned token.

2026-09-25: Shorebird release 1.2.0+14 completed with Flutter 3.47.5. The IPA
has the expected bundle ID, version, build number, and Facet F mark. The
Apple Distribution signature passed verification with macOS trust access.
The packaged launcher icon was inspected. App Store Connect upload started.
The user clarified that they will select build 14 for version 1.2.0 themselves.

2026-09-25 17:12 IST: Xcode reported upload success. App Store Connect lists
version 1.2.0, build 14, as Processing. Upload ID:
`5d09e785-0382-4c5c-9ae5-665193e85ef0`. Version selection was not changed.

## Artifact

- IPA: `flutter/build/ios/ipa/FitCheck AI.ipa` (15,503,484 bytes).
- SHA-256: `77a0f15b8e924c660d5319c82c4859fd3402944c308a5419c7ced6dc89599e9c`.
- Signing: Apple Distribution, team `HMWGCVU4SV`.
- Store: <https://appstoreconnect.apple.com/apps/6794689012/testflight/ios>
