# App Store Screenshots — Capture Plan & Spec (FitCheck AI iOS)

**Work stream:** WS6
**Last updated:** 2026-06-03
**Companion:** `flutter/scripts/capture_ios_screenshots.sh` (boots simulators + captures frames).

---

## 1. Required dimensions (App Store Connect, 2026)

Apple's 2026 model: you only need to upload **one screenshot set per device family at the largest
size**, and ASC down-scales it to every smaller shelf in that family. You **cannot** reuse iPhone
screenshots for iPad (separate families). So you need exactly **two** sets:

| Device family | Class to capture | Required pixel size (portrait) | Reference device |
|---|---|---|---|
| iPhone | **6.9-inch** | **1320 × 2868** | iPhone 17 Pro Max / 16 Pro Max class |
| iPad | **13-inch** | **2064 × 2752** | iPad Pro 13" (M4) |

(If you ever capture landscape instead, swap the dimensions: iPhone 2868 × 1320, iPad 2752 × 2064.
Stay consistent — all screenshots in a set should share one orientation.)

### Count
- Minimum **1**, maximum **10** per device family.
- **Recommend 8–10** — fill the slots; the first 2–3 dominate conversion on the product page.

### Format rules (hard requirements — a 1-pixel mismatch is rejected)
- **PNG or JPEG.**
- **RGB color space** (sRGB). **NO alpha channel** — flatten transparency before upload.
- **Exact** pixel dimensions per the table above (no off-by-one tolerance).
- No transparency, no rounded corners added by you.

> Note: raw simulator captures via `xcrun simctl io ... screenshot` are PNGs that may include an alpha
> channel and the device's native (non-spec) resolution. You must **resize to the exact spec and strip
> alpha** before upload. The helper script and §4 below cover this with `sips`.

---

## 2. Why existing assets are unusable

Inventory taken with `sips`/`file` on 2026-06-03:

| Asset | Dimensions | Verdict |
|---|---|---|
| `Fitcheck Media/Phone_ScreenShot/*.jpeg` (10 files) | **540 × 1204** | **Unusable.** Far below the 1320 × 2868 requirement (~16% of the required pixel area). Upscaling would be blurry and still wrong-ratio. Re-capture required. |
| `Fitcheck Media/App_Icon/Fitcheck_Icon.jpeg` | 1600 × 1600 (JPEG) | Marketing/source only — not a screenshot. |
| `flutter/assets/icons/app_icon.png` | 1024 × 1024, RGB, no alpha | This is the **app icon** (correct for ASC marketing icon), not a screenshot. |
| `public/assets/` | empty | Nothing usable. |

**Conclusion:** there are no usable iOS screenshots in the repo. All 8–10 frames for each of the two
device families must be captured fresh from a running build at the correct resolution.

---

## 3. Screens to capture (prioritized 8–10)

Based on the actual feature set (`flutter/lib/features/*`). Order = product-page order; slots 1–3 are
the highest-converting, so lead with the differentiated AI features.

| # | Screen | Source view (flutter/lib/features) | Caption idea |
|---|---|---|---|
| 1 | **Wardrobe / virtual closet** | `wardrobe/views/wardrobe_page.dart` | "Your whole closet, organized" |
| 2 | **AI wardrobe extraction** | `wardrobe/views/batch_item_review_page.dart` (or item add → extraction) | "Snap a photo, AI does the tagging" |
| 3 | **Virtual try-on** | `tryon/views/tryon_page.dart` | "See the outfit before you wear it" |
| 4 | **AI photoshoot results** | `photoshoot/views/photoshoot_results_step.dart` | "Studio headshots from your selfies" |
| 5 | **Outfit recommendations** | `recommendations/views/recommendations_page.dart` | "Smart picks for today's weather" |
| 6 | **Calendar / outfit planner** | `calendar/views/calendar_page.dart` | "Plan your looks ahead" |
| 7 | **Wardrobe analytics / stats** | `wardrobe/views/wardrobe_stats_page.dart` | "Know your cost-per-wear" |
| 8 | **Outfit detail / builder** | `outfits/views/outfit_detail_page.dart` or `outfit_builder_page.dart` | "Build and save outfits" |
| 9 | **Dashboard / home** | `dashboard/views/dashboard_page.dart` | "Everything in one place" |
| 10 | **Gamification (streaks/achievements)** | `gamification/views/gamification_page.dart` | "Style streaks & rewards" |

If you only ship 8, drop #9 and #10. Keep #1–#5 always (the core value props). Use the **seeded demo
account** (see `docs/store/app-store-listing.md` §5) so each screen has realistic content.

---

## 4. Capture approach

### Option A — iOS Simulator + manual capture (RECOMMENDED)

Simplest reliable path; no test harness to maintain.

1. Build/run the app on the required simulator:
   ```bash
   # 6.9" iPhone
   flutter run -d "iPhone 16 Pro Max" \
     --dart-define=API_BASE_URL=https://api.fitcheckaiapp.com \
     --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
   ```
2. Sign in with the seeded demo account and navigate to each screen in the §3 list.
3. Capture each screen with the helper script (`flutter/scripts/capture_ios_screenshots.sh`) or
   directly: `xcrun simctl io booted screenshot ~/Desktop/shot.png`.
4. Repeat on the iPad Pro 13" (M4) simulator.
5. **Post-process to spec** (strip alpha + force exact size). Example with `sips`:
   ```bash
   # iPhone 6.9": force 1320x2868, flatten to RGB (no alpha) by re-encoding
   sips -s format png -s formatOptions default \
        --resampleHeightWidth 2868 1320 shot.png --out final_iphone.png
   # Verify: no alpha, exact size
   sips -g pixelWidth -g pixelHeight -g hasAlpha final_iphone.png
   ```
   (Capture at the device's native portrait size first; if the simulator's native size already equals
   the spec, you only need to strip alpha. Always verify with the `sips -g` line above before upload.)

> Why recommended: zero extra dependencies, works the moment the app builds, and you control exactly
> what content is on screen (important for the demo data and for hero shots).

### Option B — automated via `integration_test` + `flutter drive`

Repeatable and scriptable, but more setup and more brittle while the app is mid-development.

- Add an integration test under `flutter/integration_test/` that drives the app to each screen and
  calls `binding.takeScreenshot('name')` (using `IntegrationTestWidgetsFlutterBinding`).
- Run with `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshots_test.dart -d <simulator>`.
- Still requires the post-processing in §4 Option A step 5 to hit exact pixel sizes and strip alpha.

> Defer Option B until the UI stabilizes. For the initial 1.0 submission, Option A is faster and
> safer. (Note: adding integration tests touches `flutter/` source/test files, which is outside WS6's
> file ownership — coordinate before adding them.)

---

## 5. Pre-upload checklist
- [ ] 8–10 iPhone screenshots, each exactly **1320 × 2868**, PNG/JPEG, RGB, **no alpha**.
- [ ] 8–10 iPad screenshots, each exactly **2064 × 2752**, PNG/JPEG, RGB, **no alpha**.
- [ ] Consistent orientation within each set (portrait recommended).
- [ ] Content captured against the seeded demo account (no empty states, no placeholder/lorem text).
- [ ] No sensitive/real user data, no status-bar clutter that looks broken.
- [ ] Verified each file with `sips -g pixelWidth -g pixelHeight -g hasAlpha <file>`.
