# App Store Screenshot Guide — FitCheck AI

## Required Screenshot Sizes

| Device Class | Resolution (px) | Aspect Ratio | Notes |
|---|---|---|---|
| iPhone 6.9" (Pro Max) | 1320 × 2868 | Portrait | Primary set — required for all iPhone listings |
| iPhone 6.5" | 1284 × 2778 | Portrait | Optional; 6.9" set auto-scales down |
| iPhone 5.5" | 1242 × 2208 | Portrait | Legacy; optional but recommended for wider reach |
| iPad 12.9" (M4) | 2064 × 2752 | Portrait | Required if iPad is supported |

- **Max 10 screenshots** per device family; aim for **8–10**.
- **No alpha channel** — App Store rejects screenshots with transparency.
- **PNG or JPEG** format only.
- **Exact pixel dimensions** required — even 1px off will cause rejection.

## Recommended Screens to Capture (in order)

1. **Wardrobe / Virtual Closet** — show a well-stocked closet grid with varied categories (tops, bottoms, shoes, accessories).
2. **AI Item Extraction** — capture the moment a photo is scanned and items are being auto-detected and added.
3. **AI Outfit Generation** — show a generated outfit with the AI suggestion card and individual pieces displayed.
4. **Virtual Try-On** — the AI try-on screen with an outfit rendered on a digital avatar.
5. **AI Photoshoot** — a generated photoshoot image, ideally a visually striking result.
6. **Weather Recommendations** — outfit suggestion card paired with current weather data.
7. **Outfit Calendar / Planner** — calendar view with outfits scheduled on upcoming dates.
8. **Style Recommendations** — the recommendations feed (astrology, complete-the-look, or shopping suggestions).
9. **Sustainability / Analytics** — stats dashboard showing wears, cost-per-wear, or sustainability score.
10. **Gamification** — badges, streaks, or rewards screen.

### Tips for Each Screen
- Use the **seeded demo account** with a pre-populated wardrobe for consistent, attractive data.
- Avoid blank states — every screen should look rich and complete.
- Use bright, clean screenshots; avoid dark mode unless it's the app's primary theme.
- Add minimal, punchy text overlays (e.g., "AI-Powered Outfits") if your design tool supports it, but keep it subtle.

## Using the Screenshot Capture Script

The repo includes a helper script at `scripts/capture_ios_screenshots.sh`.

### Prerequisites
- macOS with Xcode and command-line tools installed
- Flutter app builds and runs successfully
- Seeded demo account set up with sample wardrobe data

### Workflow

```bash
# 1. Make the script executable (first time only)
chmod +x flutter/scripts/capture_ios_screenshots.sh

# 2. List available simulators to confirm device names
./flutter/scripts/capture_ios_screenshots.sh list

# 3. Run the app on the target simulator (in a separate terminal)
flutter run -d "iPhone 16 Pro Max" \
  --dart-define=API_BASE_URL=... \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# 4. Start capturing — iPhone set
./flutter/scripts/capture_ios_screenshots.sh iphone

# 5. Start capturing — iPad set
./flutter/scripts/capture_ios_screenshots.sh ipad

# Or capture both families in sequence:
./flutter/scripts/capture_ios_screenshots.sh all
```

The script will:
1. Boot the appropriate simulator.
2. Pause and wait for you to navigate to each screen.
3. On pressing **ENTER**, capture the current screen and normalize it to the exact required pixel size (stripping alpha).

### Environment Overrides

| Variable | Default | Purpose |
|---|---|---|
| `IPHONE_DEVICE_NAME` | `iPhone 16 Pro Max` | Simulator name for iPhone captures |
| `IPAD_DEVICE_NAME` | `iPad Pro 13-inch (M4)` | Simulator name for iPad captures |
| `OUT_ROOT` | `fitcheck_appstore_screenshots` | Output directory |
| `SHOT_COUNT` | `10` | Number of screenshots per family |

Screenshots are saved to `OUT_ROOT/iphone_6.9/` and `OUT_ROOT/ipad_13/`.

## General Screenshot Tips

- **First screenshot matters most** — it's the one visible in search results. Use your most impressive screen (AI outfit generation or virtual try-on).
- **Tell a story** — order screenshots to walk the reviewer through the app's value proposition.
- **No status bar clutter** — use a clean time (9:41) and full battery/signal if possible.
- **Consistency** — same visual style across all shots in a family.
- **Localization** — if targeting multiple languages, capture screenshots with the app set to each locale.
