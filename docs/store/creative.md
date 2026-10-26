# App Store creative

Status: working
Last updated: 2026-10-26

The localized store creative pipeline: six framed screenshots per locale, the
21:9 product-page header, the 3:2 search card, and the app-preview poster. It
replaces the eight raw simulator captures still live in App Store Connect.

Source of truth for the words is `store/asc/listings.json`; source of truth for
the locales is `store/asc/locales.json`. This pipeline **reads** both and never
writes them. Everything it produces lands under `store/creative/`.

Run it from the repo root:

```bash
node scripts/creative/fonts.mjs                     # once, and after new scripts/copy
node scripts/creative/render.mjs --locale en-US --device 69
node scripts/creative/render.mjs --all --concurrency 8
node scripts/creative/check.mjs                     # must pass before upload
```

---

## 1. What is rendered

| Surface | Size | Locales | Manifest `kind` | Uploadable |
|---|---|---|---|---|
| Frames 1–6, 6.9" | 1320 × 2868 | all 50 | `screenshot` / `APP_IPHONE_67` | yes |
| Frames 1–6, 6.5" | 1284 × 2778 | all 50 | `screenshot` / `APP_IPHONE_65` | yes |
| Header | 3840 × 1646 | all 50 | `header` | no — marketing surface |
| Search card | 2400 × 1600 | all 50 | `search` | no — marketing surface |
| Poster | 1290 × 2796 | all 50 | `poster` | app-preview first frame |

**750 files, 891.1 MiB (934 MB).** The 600 screenshots are per device family; the 150
surfaces are not. A surface's pixel size comes from its own table, so it is built
once per locale — building it inside the device loop wrote the same path twice and
made the manifest count 900 files and double the byte total. Surface entries carry
`device: null` for that reason; a duplicate `path` in the manifest is now a bug,
not a convention.

## 2. Accepted dimensions, verified

Do not trust a remembered number here. Two things were checked on 2026-10-26.

**Live account, via the App Store Connect API:**

```http
GET /v1/apps/{appId}/appStoreVersions
GET /v1/appStoreVersions/{versionId}/appStoreVersionLocalizations
GET /v1/appStoreVersionLocalizations/{locId}/appScreenshotSets
GET /v1/appScreenshotSets/{setId}/appScreenshots      → imageAsset.width/height
```

The live 1.2.1 record carries exactly two sets: `APP_IPHONE_65` (8 shots at
1284 × 2778) and `APP_IPAD_PRO_3GEN_129` (8 shots at 2064 × 2752). There is **no
`APP_IPHONE_69`** display type. The 6.9-inch Dynamic Island display is graded on
the long-standing `APP_IPHONE_67` row. A set created against a guessed
`APP_IPHONE_69` fails to upload, which is why the manifest names the real enum.

**Apple's screenshot specification reference** (linked from the App Store Connect
help index) gives the accepted pixel sizes:

| Row | Accepted (portrait) |
|---|---|
| `APP_IPHONE_67` — iPhone with Dynamic Island, large display (16/17 Pro Max, Air, Plus) | 1320 × 2868, 1290 × 2796, 1260 × 2736 |
| `APP_IPHONE_65` — iPhone with Face ID, large display (13/12/11 Pro Max) | 1284 × 2778, 1242 × 2688 |

Also enforced, and by `check.mjs`: no alpha channel, one exact accepted size per
file, and under Apple's 500 MB cap. `render.mjs` flattens to `colorType 2`
(opaque RGB) because a Chromium PNG is RGBA and App Store Connect rejects it.

## 3. The six frames

Design language is the app's own paper studio: five paper stocks from
`flutter/lib/core/theme/paper_tokens.dart`, Basteleur for display type, a mat of
card paper with a hard offset slab (never a blur), a strip of tape, and paper
grain at 5.5% multiply. A frame's stock is the stock of the tab whose screen it
shows, which is the app's own rule applied to the store.

Every frame is the same composition — headline, one supporting line, one device
— so the set reads as one object when swiped. Frame 4 breaks it deliberately
with a second paper object; frame 6 breaks it for the offer card.

| # | id | Screen shown | Headline source | Why it is in this slot |
|---|---|---|---|---|
| 1 | `closet` | Wardrobe grid | description block 3 header | The core promise: your closet becomes searchable data. The only frame showing dozens of real garments, so it earns the slot where most installs are decided. |
| 2 | `daily` | Home / today | block 6 header | The daily habit loop, with live weather. This is why someone opens the app tomorrow — retention in slot 2. |
| 3 | `tryon` | Outfits | block 4 header | The feature nobody else has: the same outfit on one body. The screen is a wall of AI try-ons, which is exactly the proof the claim needs. |
| 4 | `photoshoot` | AI Photoshoot upload | block 5 header | A second, different reason to pay. The app screen is the input, so the frame carries the output beside it as a taped paper photo — the promise made visible without faking app UI. |
| 5 | `wear` | More | block 7 header | Answers "why digitise anything": progress, cost per wear, calendar and rewards all live one tap in. Closes the loop slot 1 opens. |
| 6 | `offer` | Recommendations | block 1 header + block 2 rows | The money frame. Three numbers from the listing's own FREE FOREVER bullets, under the trial headline, plus the "free forever" chip. Nobody has to read a paragraph to learn the deal. |

### The offer frame, `en-US`, verbatim

- Headline: `TRY PRO FREE FOR 1 MONTH`
- Chip: `FREE FOREVER`
- Rows: `50` **AI clothing uploads** · `50` **outfit generations** ·`10` **AI
  photoshoot images per day**

The numbers are not authored. They are the first three bullets of the listing's
FREE FOREVER block, so the offer frame cannot drift from the store copy. A row
whose localized string starts with a digit *followed by a space* is split into
number and label; Japanese `1日10枚` and Chinese `每天10张` keep their whole string,
because a leading digit there is a counter, not a statistic.

## 4. Localization rules

**What the pipeline may do to a translated string**

1. Use it verbatim as a headline or a supporting line.
2. Trim a supporting line at a clause boundary, restoring the script's own
   terminator. Never a mid-word cut, never an ellipsis.
3. Set it at any size between the frame's floor and its ceiling. Type is stepped
   down to fit the line budget; below the floor the frame **fails** instead of
   shrinking.

**What it may not do**

1. Translate. Every string comes from `listings.json` or an explicit override.
2. Reorder or re-punctuate a headline.
3. Drop a headline word to make it fit. Shorter copy is an override, decided by
   a human, recorded with `reviewed`.

**Where a headline comes from**, in precedence order:

| Source | Meaning |
|---|---|
| `description[N].header` | The listing's own translated section header. Default and preferred. |
| `description[N].sentence[k]` | A translated body sentence, for a frame whose story the listing covers under a header another frame already uses. |
| `override-section-missing` | The locale's description never wrote this section, and `copy.json` carries a hand-authored line for the frame. |
| `override-untranslated` | The section is still English in that locale, and `copy.json` carries a hand-authored line. |
| `override-fallback` | The listing's line needs more lines than the frame allows, so the authored shorter line is used instead. |
| `subtitle-section-missing` | The section is absent and there is no authored line. Warned by `check.mjs`. |
| `subtitle-fallback` | The section is still English and there is no authored line. Warned by `check.mjs`. |
| `subtitle` | The 30-character store subtitle. Used for the header and search surfaces. |

**An override is a fallback, never a replacement.** `render.mjs` tries the
listing first, every time, and only reaches for `copy.json` when the listing
cannot carry the frame. This is deliberate: `store/asc/listings.json` was being
translated by another workstream while this pipeline was being built, and a hard
override shadows finished translation forever. Odia's six authored headlines were
written when its description was entirely English; by the end of the build those
sections had been translated, and the listing copy now wins on its own with no
edit to `copy.json`. The rendered provenance is recorded per file in
`manifest.json` under `copy.source`, so the set is auditable.

**Sections are resolved by anchor, not by index.** The template is fixed at 12
blocks, but two locales do not have 12: `ta-IN` has 10 and `pa-IN` has 11, because
neither listing ever wrote the "KNOW WHAT YOU ACTUALLY WEAR" section. A positional
lookup slides after the gap and Tamil's block 7 is literally `SUBSCRIPTIONS` — so
frame 5 was rendering a subscriptions header on a frame about know-your-wear, in
Latin script, and it looked like a deliberate typographic choice. `sectionsFor()`
in `scripts/creative/lib/copy.mjs` now anchors instead:

- blocks 0–6 by position (stable across all 50 locales),
- blocks 9–11 from the end (the closing note is last, the legal block is the one
  carrying a URL or `EULA`, `SUBSCRIPTIONS` sits directly above it),
- blocks 7–8 by shape inside the middle window (section 7 is a header plus one
  paragraph, section 8 is a header plus bullets, so a lone middle block can be
  told apart),
- and a middle window that cannot be assigned stays `null` rather than borrowing
  its neighbour's text.

**Untranslated detection** runs two independent tests, because either alone lets
bad copy through:

1. **Identical to `en-US`.** Not a Latin-character test, because Spanish, German
   and Indonesian are legitimately Latin.
2. **Wrong script.** For a locale that does not write in Latin, a string with no
   character from its own script has not been translated. This is what caught
   `SUBSCRIPTIONS` in the Tamil listing: it differs from the English header, so
   test 1 passed it, and it rendered in the display face looking intentional.
   `SCRIPT_PROBE` in `scripts/creative/lib/scripts.mjs` holds one character class
   per script; Latin and Vietnamese have no probe by design.

Odia's six headlines are authored in `copy.json` from that locale's own
vocabulary and marked `reviewed: false` until a native speaker signs off, as is
one Tamil line. `check.mjs` warns on every unreviewed authored line, and on every
frame that fell back to the subtitle.

**RTL is mirrored, not just flipped.** `<html dir="rtl">` plus logical CSS
properties (`inset-inline-start`, `margin-inline-end`, `border-inline-start`)
moves the headline, the device mat, the tape, the offer card and the art card to
the opposite side. The tilt angle changes sign so the mat still leans "into" the
frame. The device cutout stays centred, because a real island does.

The three RTL locales in the table are Arabic, Hebrew and Urdu. **Urdu is
Nastaliq**, not Naskh: its line box is 2.05× and it slopes, so it gets its own
font and its own headroom.

## 5. Font stack per script

`Basteleur` — the app's display face — covers Latin, Latin Extended and Greek,
and nothing else. Every other script gets the matching Noto Serif at the same
optical size, with a script-specific line box and headroom.

| Script | Locales | Display | Line box | Headroom |
|---|---|---|---|---|
| Latin | en-*, es-*, pt-*, fr-*, de, it, nl, sv, no, da, fi, pl, cs, sk, sl-SI, hr, ro, hu, tr, id, ms, ca | Basteleur | 1.04 | 0.10em |
| Vietnamese | vi | Noto Serif | 1.12 | 0.16em |
| Greek | el | Basteleur | 1.08 | 0.12em |
| Cyrillic | ru, uk | Noto Serif | 1.10 | 0.12em |
| Arabic | ar-SA | Noto Naskh Arabic | 1.42 | 0.20em |
| Hebrew | he | Noto Serif Hebrew | 1.16 | 0.18em |
| Urdu (Nastaliq) | ur-PK | Noto Nastaliq Urdu | 2.05 | 0.34em |
| Devanagari | hi, mr-IN | Noto Serif Devanagari | 1.34 | 0.24em |
| Bengali | bn-BD | Noto Serif Bengali | 1.36 | 0.24em |
| Gurmukhi | pa-IN | Noto Serif Gurmukhi | 1.32 | 0.22em |
| Gujarati | gu-IN | Noto Serif Gujarati | 1.32 | 0.22em |
| Oriya | or-IN | Noto Serif Oriya | 1.34 | 0.24em |
| Tamil | ta-IN | Noto Serif Tamil | 1.30 | 0.20em |
| Telugu | te-IN | Noto Serif Telugu | 1.30 | 0.22em |
| Kannada | kn-IN | Noto Serif Kannada | 1.34 | 0.22em |
| Malayalam | ml-IN | Noto Serif Malayalam | 1.32 | 0.22em |
| Thai | th | Noto Serif Thai | 1.45 | 0.26em |
| Chinese (Simplified) | zh-Hans | Noto Serif SC | 1.22 | 0.08em |
| Chinese (Traditional) | zh-Hant | Noto Serif TC | 1.22 | 0.08em |
| Japanese | ja | Noto Serif JP | 1.26 | 0.08em |
| Korean | ko | Noto Serif KR | 1.26 | 0.08em |

Body text (the supporting line, the offer labels) pairs each display face with the
matching Noto Sans; Latin and Greek pair with Inter.

**Why a font kit and not a system fallback.** A store screenshot is the one place
a missing glyph actually ships. `scripts/creative/fonts.mjs` asks Google Fonts for
a subset containing exactly the characters the copy needs (`text=`), stores the
woff2 in `store/creative/fonts/`, and records a content hash in
`fonts/index.json`. Rendering then needs no network and cannot silently fall back
to a face that lacks the script. `check.mjs` fails when the kit is missing a
script, and `fonts.mjs` rebuilds only the subsets whose character set changed.

**No tofu** is proven four ways: the subset is built from the literal copy (a
missing glyph makes Google return a face without it, which the subset hash
records), `check.mjs` rejects replacement and box characters in the recorded copy,
`SCRIPT_PROBE` fails a non-Latin locale whose headline carries no character from
its own script (so a frame cannot fall back to a Latin face by accident), and the
17-band script contact sheet in §9 was opened and read.

## 6. Adding a locale

1. Add the locale to `store/asc/locales.json` (owned by the publishing stream) and
   give it a listing in `store/asc/listings.json`.
2. Add it to `LOCALE_SCRIPT` in `scripts/creative/lib/scripts.mjs`. An unmapped
   locale is a hard error, never a silent Latin render.
3. If its script is new, add an entry to `SCRIPT_FONTS`, `HEADROOM`,
   `SCRIPT_PROBE` and the `TERMINATOR_BY_SCRIPT` table in `copy.mjs`.
4. `node scripts/creative/fonts.mjs` — fetches only the new script's subsets.
5. `cd flutter && ./scripts/capture_localized_screens.sh <code>` — captures the
   localized app UI (see §7a). Skip it and the frame ships an English phone
   screen; `check.mjs` warns for every one.
6. `node scripts/creative/render.mjs --locale <code>` then `node scripts/creative/check.mjs`.

If the new listing does not follow the 12-block template exactly, `sectionsFor()`
degrades to `null` for the sections it cannot anchor rather than reading a
neighbour's text, and `check.mjs` names the frames that fell back. Nothing is
silently mis-sourced.

## 7. Running and re-running

`render.mjs` is content-hashed end to end: the cache key is a hash of the
generated HTML **and** of every input file (screen, fonts, art). A re-run with no
change renders nothing:

```bash
node scripts/creative/render.mjs --locale en-US --device 69      # second run: "cached 12"
```

A frame whose listing headline overflows its line budget is rendered twice: once
with the listing copy, once with the authored fallback. The second render records
the rejected listing hash, so the next run knows the answer and does not re-probe —
but any edit to `listings.json` changes that hash and forces a fresh attempt, which
is how a newly translated line takes over without a manual step.

Each finished file is written to `store/creative/.cache/render.json` the moment it
lands, so a run killed at file 400 of 750 loses nothing and leaves the manifest
honest. The manifest is rebuilt from that ledger at the end and only lists entries
whose file is on disk with the recorded hash.

| Flag | Effect |
|---|---|
| `--locale hi,ja` | Render a subset |
| `--all` | Every locale × both devices × all four surfaces |
| `--frame 6` | One frame across the selected locales, for iterating on a design |
| `--device 69` / `65` | One device family |
| `--kind frames,header` | Skip surfaces while iterating |
| `--concurrency N` | Browser pages in parallel (default 4; 8 is comfortable) |
| `--force` | Ignore the cache |
| `--dry-run` | Print the task list, write nothing |
| `--verbose` | Per-task progress |

**The manifest** (`store/creative/manifest.json`) is generated, never edited. Each
entry carries locale, kind, display type, device, path, width, height, bytes,
sha256, RTL flag, the localized copy baked into the image, the type metrics that
were measured, and the source screen. An uploader needs nothing else.

## 7a. Localized app screenshots

The device screen inside a frame is a bitmap, so a translated headline sits above
whatever UI language the bitmap contains. `screenPath()` in `render.mjs` looks
for `source/screens/<locale>/<name>.png` first and falls back to the shared
English capture, so each locale can carry its own app UI.

Capture a locale set:

```bash
cd flutter
./scripts/capture_localized_screens.sh ja ar-SA hi      # any list of codes
./scripts/capture_localized_screens.sh --all-latin      # the 25 Latin-script codes
```

Non-interactive, ~11–20 s per locale on an M-series laptop. Each run writes
`store/creative/source/screens/<locale>/{closet,today,more,tryon,photoshoot,matches}.png`
at 760 × 1643, matching the hand-captured English set so the bezel composites it
unchanged. Re-running one locale replaces only that locale's six files.

**How it works.** The `flutter/test/visual/*_golden_test.dart` suite already
renders every screen through fake repositories with a fixed demo wardrobe —
deterministic, offline, no account, no simulator. `--dart-define=STORE_CAPTURE_LOCALE=<asc>`
makes those same fixtures render in the requested locale, swaps in a font that
covers the script, and redirects every golden write to
`flutter/build/store_capture/<asc>/` instead of the committed English goldens.
`flutter/scripts/store_capture_post.py` then maps the six screens we ship onto
760 × 1643. Nothing in `flutter/lib/**` changes.

**Tablet sources.** App Store Connect requires an iPad screenshot set while
`TARGETED_DEVICE_FAMILY` includes `2`, and a phone capture cannot be reused: the
aspect is 0.46 against a tablet's 0.75, so the frame would crop the app's sides.
Run the same capture with a tablet surface and a separate output tree:

```bash
cd flutter
flutter test --dart-define=STORE_CAPTURE_LOCALE=en-US \
  --dart-define=STORE_CAPTURE_SIZE=1032x1376 \
  test/visual/wardrobe_golden_test.dart test/visual/dashboard_golden_test.dart \
  test/visual/more_golden_test.dart test/visual/photoshoot_golden_test.dart \
  test/visual/plan_golden_test.dart
python3 scripts/store_capture_post.py en-US --size 2064x2752 \
  --out ../store/creative/source/screens-ipad
node scripts/creative/render.mjs --locale en-US --device 129
```

2064 × 2752 is deliberate: it is the 13-inch profile, and that is the slot Apple
checks. Placing a 12.9-inch set instead is not enough — the submission comes back
`STATE_ERROR.SCREENSHOT_REQUIRED.IPAD_13_PROFILE` even though a 12.9-inch set is
full. Only `en-US` is captured today, so other storefronts show the English iPad
gallery while their iPhone gallery stays localized (TD-143).

**One face, not a font stack.** The Flutter test shell has no platform font
fallback, and it does not fall back between faces registered under one family —
the family's first face wins. A non-Latin capture therefore registers
`Arial Unicode.ttf` as the *whole* `Roboto` and `Basteleur` family, so Latin demo
strings and the script both render. The `.ttc` collections beside it
(`Hiragino`, `Kohinoor`) load silently as nothing and must not be used. Locales
whose script Roboto already covers (all of Europe, Greek, Cyrillic, Vietnamese)
load nothing extra and keep the shipped Basteleur headlines.

**Known limits of this route.** Garment names in the demo wardrobe (`Ecru oxford
shirt`, `Linen tote`) come from the test fixtures, not the ARB files, so they
stay English in every locale — which matches a real account, where the user typed
them. Editing the fixture lists in the golden tests is what would localize them.
The screens are the *paper* UI with silhouette garment tiles, not photographed
garments, because no garment photography is vendored in the repo.

## 8. App preview: poster + frame-safe spec

The poster is rendered (`store/creative/preview/<asc>-poster.png`, 1290 × 2796)
with a play affordance. The video itself is not produced here.

**Accepted by App Store Connect for an iPhone preview:** 1080 × 1920, 1920 × 1080,
1290 × 2796, 2796 × 1290; H.264 or ProRes 422 HQ; .mov/.m4v/.mp4; 15–30 s; under
500 MB.

**Frame-safe rules for whoever edits it** (the poster obeys them, so the cut from
poster to video is invisible):

1. Keep the paper canvas visible at the frame edges — no full-bleed app UI.
2. Top 8% and bottom 4% stay empty: that is where the store's own chrome and the
   device mask sit.
3. Type is never smaller than the poster's supporting line.
4. The device mat stays wholly inside the canvas: `x ∈ [5%, 95%]`, `y ∈ [12%, 96%]`.
5. No caption below 1.2 s or above 28 s: the preview autoplays muted, so the first
   caption must be readable before the viewer's thumb reaches the skip.

**Shot list** (30 s at 30 fps, 900 frames, four beats):

| Time | Beat | Shot | Caption (localize per locale) |
|---|---|---|---|
| 0.0–1.5 | Poster hold | The poster frame, static | frame 1 headline |
| 1.5–8.0 | Closet | Batch upload → items cut out and land in the grid, one per 0.4 s | frame 1 supporting line |
| 8.0–14.0 | Today | Home scrolls to today's outfit; weather chip animates in | frame 2 headline |
| 14.0–21.0 | Try-on | Outfit → try-on grid; four try-ons wipe in | frame 3 headline |
| 21.0–26.0 | Photoshoot | One selfie → three studio results, paper sheets slapping down | frame 4 headline |
| 26.0–30.0 | Offer | The offer card slides up over the mat; rows count in | frame 6 headline + rows |

Cut no faster than 1 shot per 2 s. The preview is muted and autoplays, so every
beat has to be legible without audio.

## 9. What was inspected, and what it fixed

Every frame below was opened at full resolution and read, not just rendered.

- **en-US frames 1–6.** Fixed: the device was undersized with a dead band under
  the headline (now solved from the measured stage height); the tape was a
  floating rectangle (now a paper strip anchored to the mat corner); frame 1 had a
  3-line ragged headline (now 2 lines at 116px); the offer card floated mid-canvas
  (now anchored directly under the trial headline).
- **en-US frame 4.** The taped art card sat over the app's tab bar, which read as a
  layout accident. It now bleeds off the outer canvas edge and overlaps only the
  bezel.
- **en-US frame 5.** The first source screen was the Profile page, which shows a
  real name, photo and email — unusable in a store listing. It was dropped and the
  frame moved to the More tab.
- **ar-SA frame 1 and frame 6, ja / hi / th frame 6.** Read at full size. `ar-SA`
  mirrors the whole composition — headline, mat, tape and art card all move to the
  opposite side and the tilt changes sign; `ja` and `zh-Hans` keep `1日10枚` and
  `每天10张` intact after the digit-split rule was corrected; `hi` and `th` hold
  their matras and tone marks inside the per-script headroom.
- **`ur-PK` (Nastaliq)** was the one script whose line box defeated the fitter: it
  wrapped to four "lines" at the floor until line counting moved from counting
  client rects to measuring range height ÷ line-height.
- **`ta-IN` frame 5 read `SUBSCRIPTIONS`.** Found by reading the contact sheet, not
  by any check: the Tamil listing has 10 blocks, not 12, so positional indexing slid
  by two and frame 5 picked up the subscriptions section. `pa-IN` has the same gap
  one block smaller. Fixed by anchoring sections to the end of the description and
  by the wrong-script probe, which now also catches a "translated" header that is
  still English words in Latin letters. Both locales now use their own subtitle for
  frame 5 and are flagged in `check.mjs`.
- **Odia went from fallback to listing copy mid-build.** An earlier run had six
  authored Odia headlines in use because the Odia description was English; the
  listings workstream translated it while this pipeline was running, and because an
  override is only a fallback, the next render switched all six to real store copy
  with no edit to `copy.json`. This is why the override semantics are documented in
  §4 rather than being an implementation detail.
- **Header, search card and poster, en-US and ar-SA.** Fixed: the hero phone was a
  small contained sticker (now larger, bleeding off the bottom edge); the search
  card clipped its device at the crop (now sized from the stage height); the poster
  play button covered the garments it exists to show and its label shipped an
  English word into Arabic (now a glyph in the paper margin).
- **Contact sheets of all 50 locales** for the header and the search card, plus
  every frame in the six representative locales and a 17-band script sheet (ru, el,
  hi, bn, gu, pa, or, ta, te, kn, ml, th, vi, he, ur, ko, zh-Hant) for tofu,
  clipping and collision. No tofu box appeared in any script.

## 10. Known gaps

1. **`ta-IN` and `pa-IN` are missing a whole listing section.** Neither App Store
   description contains the "KNOW WHAT YOU ACTUALLY WEAR" section, so frames 1–4
   come from their listings and frame 5 falls back to the 30-character subtitle.
   The fix is in the listing, not this pipeline: add the missing section and the
   next render picks it up. `check.mjs` warns on the affected frames.
2. **No calendar screen.** The brief asks frame 5 to show the weekly planner. The
   live capture set has no calendar screenshot, and the only calendar image in the
   repo is a Flutter golden from the *new* paper UI, which would mix two UI
   generations in one set. Frame 5 therefore uses the More screen (where Calendar,
   Progress and Rewards live) and keeps the "know what you actually wear" story.
   A fresh simulator capture of the calendar screen would let this frame match the
   brief with a one-line change in `store/creative/copy.json`.
3. **The app UI inside every phone is English in 44 of 50 locales.** `ja` and
   `ar-SA` are now captured and carry a genuinely localized, RTL-mirrored app UI
   (§7a); the other 44 are still on the shared English fallback, so e.g. `de-DE`
   shows a German headline above an English "Wardrobe". The mechanism is a
   per-locale capture directory and a batch script, so closing the rest is
   `./scripts/capture_localized_screens.sh --all-latin` plus the non-Latin list,
   not a code change. `check.mjs` names every locale still on the fallback.
4. **The localized captures show silhouette garment tiles, not photographs.** The
   only captures with real garments are the shipping 1.2 (purple UI) set at
   1284 × 2778. §7a renders the current paper UI through the golden-test
   fixtures, and those fixtures have no garment imagery, so the tiles are the
   paper silhouettes. That is the honest trade: correct UI generation and correct
   language, but a less persuasive product shot than photographed clothing. A
   photographed localized set needs garment images vendored in the repo (or an
   authenticated capture against a seeded account with real uploads) dropped into
   `source/screens/<locale>/`; no code change.
4. **Six `or-IN` and one `ta-IN` line are unreviewed.** They are now only fallbacks,
   and the Odia listing translation means they are no longer in use — but they stay
   in `copy.json` for the locales where the listing could not carry a frame, so
   they still need a native read before they can ever ship. `check.mjs` warns on
   each.
5. **An RTL frame still shows the status bar's clock on the left.** The device
   cutout is physical and is now pinned with `left` so it no longer mirrors and no
   longer covers the clock. The localized captures do not carry a status bar at
   all (§7a renders the screen content, not the OS chrome), so nothing renders a
   misplaced clock today — but if a future capture includes one, pinning is what
   keeps the cutout off it.
6. **Preview video is a spec, not a render.** See §8.

Total output is 750 PNGs / 891.1 MiB (934 MB): 600 screenshots (2 device families) plus 150
surfaces (3 per locale). The byte total moves by a few megabytes between runs as
translations change.

## 11. Related

- `docs/store/app-store-listing.md` — the store copy this pipeline reads
- `docs/store/app-store-screenshots.md` — the original capture plan
- `docs/DESIGN.md` — the paper/clay design language
- `store/asc/locales.json`, `store/asc/listings.json` — read-only inputs
