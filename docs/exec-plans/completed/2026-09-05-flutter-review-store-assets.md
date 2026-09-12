# Plan: Flutter review and store listing images

Status: review and assets complete; release gates recorded  
Started: 2026-09-05

## Goal

Review the completed mobile redesign for concrete defects and create premium
English listing images for iPhone, iPad, Android phone and Android tablets.
Preserve the approved muted editorial design, current features and workspace edits.

## Work

1. Independently review implementation and verify current store asset rules (complete).
2. Fix confirmed defects and render listing artwork from real Flutter UI (complete).
3. Inspect exports, run regression checks and package editable sources (complete).

## Acceptance

- Record review findings with fixes or specific remaining gates.
- Export six images per device group, with phone and real tablet layouts.
- Include light and dark UI, image-only Closet, Outfits and both Studio tools.
- Keep marketing copy factual. Use synthetic account/wardrobe data and identify
  fixture renders in the asset documentation. Do not invent generated results.
- Use opaque PNG/JPEG exports at verified store dimensions. Include a Google Play
  feature graphic, an image manifest, sources and a local review gallery.
- Run full Flutter tests, strict analyzer and relevant repository checks.

## Boundaries

No store upload, publication, purchase, account mutation or stored-photo backfill.
Store images describe this implementation; release/native-device gates remain
separate. Use Flutter/code-native rendering to preserve exact UI and editable type.

## Verification sources

- [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [Google Play preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en)

Checked 2026-09-05. iPhone 6.9-inch: 1320×2868; iPad 13-inch: 2064×2752.
Google Play phone: 1080×1920; tablet groups: 1440×2560 and 1800×3200.
All screenshot exports will be opaque. App Store accepts up to ten screenshots;
Google Play up to eight per supported device type. Six covers both limits.
Google tablet exports show the app UI without added marketing text, using the
recommended 9:16 ratio. Phone taglines stay under 20% of the canvas. The Play
feature graphic is 1024×500. No store badges or device-brand imagery are added.

## Review and evidence

Baseline: 442 tests passed and strict analyzer was clean. Fourteen approved
Flutter visual goldens exist.

| Finding | Resolution and evidence |
|---|---|
| A failed outfit filter refresh left the previous page cursor active | Cursor now belongs to the last successful criteria; scrolling retries new criteria from page 1. A regression reproduced the incorrect page 3 request before the fix. |
| Collections and statistics states overflowed with large text; captions covered Options | Existing natural-height lazy grid and non-scroll-body slivers fix the layout. Secondary surface tests exercise 320px and 200% text. |
| Outfit sheets lacked the correct Material ancestor; collection forms overflowed with keyboards or disposed controllers too early | Native scrollable sheets/dialogs, route-completion disposal, and mounted checks. Ten new secondary regression cases pass in the focused suite. |
| Home called favourite outfits “saved outfits” | Label now matches the favourite count and the filtered destination. Store sample statistics are derived from the sample item/outfit lists. |
| GoTrue removed sessions for HTTP 429 and could clear a newer login after a stale refresh rejection | Pinned Supabase Flutter 2.15.1 / GoTrue 2.23.0, a narrowly scoped refresh HTTP hook and an interceptor session guard. Real SDK tests verify rate-limit retention/retry, rejection of invalid credentials and preservation of a newer login. No native plugin was added. |

## Asset evidence

[The listing pack](../../store/premium-refresh/README.md) contains six screenshots
for each of five device groups plus one feature graphic. All use actual Flutter
pages and synthetic fixture data. The 30 raw PNGs passed native pixel-dimension
checks; the 31 composed JPEGs passed filename, dimension, RGB/no-alpha, size and
alt-text checks. The HTML renderer also verifies headline/caption separation.
All five contact sheets and the feature graphic have been inspected, with full
size checks for phone Closet, iPad Try-on, all five Home variants and the feature
graphic. An independent second review found no blank images, clipped headlines
or mismatched sample counts. The ZIP contains the exact 31 final JPEGs, manifest
and standalone notes; its entries and CRC integrity were verified.

Store copy now describes single-garment Try-on and current shell navigation.
Removed unsupported accuracy, instant-generation and preference-learning claims.
Google Play short description is within its 80-character limit. Account, privacy,
pricing and review credential records were preserved.

## Final verification

| Check | Result |
|---|---|
| Full Flutter suite | **458 tests pass**, including all 14 goldens; 34 seconds. |
| Strict analyzer | **No issues**, fatal warnings and infos enabled. |
| Store capture suite | All 30 presets pass; five Home captures rerun after final sample activity/count changes. |
| Export and archive checks | **31 JPEGs pass**; exact dimensions, RGB/no alpha, file sizes, alt text, filenames and ZIP contents. |
| Repository checks | Architecture, documentation structure, theme tokens and iOS minimum target pass. Whitespace diff check passes. |
| Android native build | **Pass**, ARM64 debug APK, 35.5 seconds, with final UI/assets/dependencies. |
| iOS native build | **Pass**, simulator Runner.app, 56.3 seconds, with final UI/assets/dependencies. |
| iOS startup | **Pass**, installed and launched on the booted iPhone 17 Pro simulator, iOS 26.5. Welcome typography, image, system bars and both actions render correctly in the default Light mode. |

The ordered golden update changed only `home_1024.png` for the corrected favourite
outfit label; hashes of the other 13 goldens stayed identical. Filtered capture
order produced different rail-label rasterization, so the baseline was regenerated
in the normal full-file order and passed again in the full suite.

The earlier disk-capacity block no longer prevents local native compilation.
Android still reports upcoming Gradle/AGP/Kotlin support deprecations and Java 8
plugin warnings. iOS still uses CocoaPods fallback for four plugins without
Swift Package Manager support. These are build-toolchain follow-ups, not a clean
native-warning claim. The builds are local debug verification, not signed
Shorebird store releases.

Native startup evidence is
[`native-ios-welcome-light.png`](../../store/premium-refresh/review/native-ios-welcome-light.png).
The app defaults to Light until the user selects another theme; changing the
simulator appearance alone therefore leaves this welcome screen light. The
simulator's original light appearance was restored. Dark/System selection and
persistence have widget/service coverage; authenticated native Settings journeys
remain in the release checklist. No account was created or signed in for this check.

## Release gates

Native signed-build comparison, authenticated journeys, physical-device scrolling,
VoiceOver/TalkBack and sandbox purchase/restore remain separate release gates.
The widget capture pack is not evidence that these journeys passed. Manual and
legacy opaque photo backgrounds still need processing before every stored item
can appear as a cutout. See TD-105/TD-106/TD-107 and the [main mobile plan](../active/flutter-premium-refresh.md).
No stored photos, backend contracts or live accounts were changed; nothing was
uploaded to either store.
