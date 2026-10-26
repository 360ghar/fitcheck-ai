# Release runbook: 1.3.0

The ordered sequence for taking FitCheck AI 1.3.0 live. Every step before "Phase 3"
writes to the live App Store Connect account, so each is gated on explicit approval and
each prints its mutation before sending it.

Read this whole file before running anything. The order is not arbitrary: several steps
depend on state that an earlier step creates, and two of them are effectively
irreversible in the sense that a mistake is visible to customers for a review cycle.

## Current live state

| Thing | State |
|---|---|
| App | `6794689012`, `com.fitcheckaiapp.fitcheckai`, primary locale `en-US` |
| Versions | 1.0, 1.2.0, 1.2.1 all `READY_FOR_SALE` — **no editable version** |
| Listing localizations | 1 of 50 (`en-US`) |
| Subscription group | `22286350`, four approved products |
| Intro offers | none |
| Age rating | 17+ due to "Unrestricted Web Access" advisory |
| Custom product pages | 0 |
| In-app events | 0 |
| PPO experiments | 0 |
| Ratings | 0 |

## Phase 0 — verify the plan is what you think it is

```bash
node scripts/asc/verify.mjs                        # live account vs local plan
node scripts/asc/check-listings.mjs --strict       # 50/50, 0 errors, 0 warnings
python3 scripts/asc/keyword_planner.py             # no fragmented or redundant fields
python3 scripts/i18n/check_locales.py              # five locale inventories agree
python3 scripts/i18n/check_claims.py --gate        # the copy does not overpromise
node scripts/creative/check.mjs                    # every rendered asset is legal
```

Nothing below is safe until all six exit 0. `verify.mjs` is the only one that reads the
live account, so it is the one that catches "someone already changed this".

`check_claims.py --gate` is the one to read carefully, because it is the only check that
compares marketing prose against compiled reality. It fails while the listing promises
"N languages" and fewer than N catalogs exist, and while the listing claims a
"translated interface" and user-facing English literals still sit in widget code. As of
2026-10-26 it fails on both: 19 base languages have no catalog, and 413 distinct
user-facing literals are hardcoded outside the ARB system (TD-129). Generating the
missing catalogs alone does not clear it — the hardcoded strings have to be extracted
first, or the app ships 43 languages of half-English UI. That is why the release gate is
"wait for all 43 languages" and not "wait for the catalog job".

`--strict` here means what it says for a submission: warnings fail too. As of
2026-10-26 it still exits 1, for one reason — 49 locales carry the warning
`not marked reviewed`, because their copy is machine-translated. That is the
native-review debt in `tech-debt-tracker.md`, and clearing it is a human task.
Everyday `check_all.sh` runs the same gate without `--strict` so that this one
known, tracked warning does not hide a new error among 49 lines of noise.

## Phase 1 — create the editable version

```bash
node scripts/asc/publish.mjs prepare            # dry run: prints what it would create
node scripts/asc/publish.mjs prepare --apply
```

This creates version 1.3.0 in `PREPARE_FOR_SUBMISSION`. It is the first live mutation and
the only one that cannot be undone by re-running a script — Apple allows one open version
at a time, so a mistake here means deleting it through the UI.

**Why first:** every other metadata write (localizations, screenshots, the build) hangs
off a version. Nothing else can be attached until this exists.

## Phase 2 — the three changes that do not need a build

These three are independent of the app binary and can be verified before any build is
uploaded. Doing them first means the riskiest, slowest step (Upload + Processing +
Review) starts with everything else already correct.

```bash
node scripts/asc/age-rating.mjs                 # report: current vs proposed
node scripts/asc/age-rating.mjs --apply         # removes "Unrestricted Web Access"

node scripts/asc/offers.mjs --verify            # is the trial already there?
node scripts/asc/offers.mjs --apply             # create the 1-month free intro offer

node scripts/asc/publish.mjs details            # 50 locales, prints the diff
node scripts/asc/publish.mjs details --apply
```

**Age rating.** The app has no browser: `flutter/lib` contains no WebView, and every
`launchUrl` call uses `LaunchMode.externalApplication` against a fixed developer URL. The
"Unrestricted Web Access" advisory is wrong and is filtering 13–16 year olds out of the
listing. A wrong-but-lower rating is an App Review rejection, so the declaration is set
field by field, not by flipping one boolean.

**The offer.** `FREE_TRIAL` / `ONE_MONTH` / `numberOfPeriods: 1` on
`com.fitcheckaiapp.fitcheckai.pro.monthly` (`6797997225`). The script refuses to overwrite
a different existing offer and is a no-op when the intended one is already present.

**Metadata.** 50 localizations in one call sequence, ordered primary-first then by tier,
so a failure part-way leaves the most valuable storefronts done.

## Phase 3 — creative

```bash
node scripts/asc/media.mjs upload --manifest store/creative/manifest.json     # dry run
node scripts/asc/media.mjs upload --manifest store/creative/manifest.json --apply
node scripts/asc/media.mjs sync                                               # report drift
```

Uploads go to the App Asset Library. The set-based `appScreenshotSets` API is deprecated.
`sync` reports what it would delete and deletes nothing — deletion is a human decision.

## Phase 4 — growth surfaces

```bash
node scripts/asc/grow.mjs cpp --apply
node scripts/asc/grow.mjs ppo --apply
node scripts/asc/grow.mjs events --apply
node scripts/asc/grow.mjs status
```

Custom product pages and PPO experiments attach to the version, so they come after it
exists. In-app events are independent of the version and can be created any time.

CPPs need somewhere to send a tap. Deep links are `fitcheck.ai://<route>`; the supported
routes are documented in `docs/store/README.md`. A CPP whose link 404s wastes the spend it
was created to capture.

## Phase 5 — the build, then submission

### The ARB catalogs have to be finished first

The app renders English in any locale whose `app_<lang>.arb` is missing, and
`flutter gen-l10n` will not warn you: the locale just disappears from
`AppLocalizations.supportedLocales`. So the catalogs are a hard prerequisite, not
a nice-to-have. The order matters and only one of these commands may run at a
time — they share a single Gemini key and the free tier is per-model per-day:

```bash
python3 scripts/i18n/translate_arb.py --dry-run   # what is left to translate
python3 scripts/i18n/translate_arb.py             # translate (may need several days)
python3 scripts/i18n/sync_arb_keys.py             # fill any key a catalog lacks, with English
python3 scripts/i18n/check_locales.py             # must exit 0
python3 scripts/i18n/check_claims.py --gate       # copy must not overpromise
(cd flutter && flutter gen-l10n)                  # regenerate the Dart classes
```

`sync_arb_keys.py` is a convenience, not a prerequisite. A catalog that is present
but missing a key is fine — `flutter gen-l10n` falls back to the English template
for it and records the key in `build/untranslated.json`, so the build still
compiles and the app renders English for that one string. Running
`sync_arb_keys.py` makes the gap explicit and uniform, and turns
`check_locales.py` green; skipping it just leaves the gap reported there instead.

The real hazard is a **missing catalog file**, not a missing key: `gen-l10n` does
not delete stale output, so if `app_<lang>.arb` was removed or renamed, the old
`app_localizations_<lang>.dart` stays behind and `flutter analyze` fails with
`non_abstract_class_inherits_abstract_member` naming a key rather than the cause.
Clear it before generating:

```bash
rm -rf flutter/lib/l10n/generated && (cd flutter && flutter gen-l10n)
```

Then the build itself:

Not scriptable from here: the 1.3.0 build must be produced and uploaded by Xcode or
Transporter, then processed by Apple. After it appears on the version:

```bash
node scripts/asc/grow.mjs submit              # prints what would be submitted
```

The submit step refuses when anything required is missing and names it.

### When submission reports a reason that is not true

Two failures cost two hours on 1.3.0 because the error names the wrong thing.

**`STATE_ERROR.ASSET_UPLOAD_IN_PROGRESS.APP_SCREENSHOT`, forever.** The message
says an upload is in flight. In practice it means one screenshot was reserved and
never given bytes: an `appAssetLibraryImage` sitting in `AWAITING_UPLOAD` at 0x0.
Every `appScreenshot` in the set can report `COMPLETE` while this is true, and the
stuck asset can be in any of the 50 locales. Find it by scanning all of them:

```bash
node scripts/asc/scan-assets.mjs      # lists every screenshot whose state is not COMPLETE
```

An asset that still has a placement cannot be deleted, so the order is: delete the
placement, delete the image, then re-run `node scripts/asc/media.mjs upload --apply`
to upload the bytes again and re-place it.

**`STATE_ERROR.SCREENSHOT_REQUIRED.IPAD_13_PROFILE` on a custom product page.**
The version can pass every gallery check while a CPP localization still fails:
each CPP localization needs its own 13-inch placement, and the main listing's
iPad gallery does not count for it. Place one on all of them (nine pages × seven
locales) before submitting.

## Rollback

| Step | How to undo |
|---|---|
| Age rating | Re-run with the previous declaration; record it from the dry run before applying |
| Intro offer | Remove through the ASC UI; the API has no delete for offers |
| Metadata | Re-run `publish.mjs details` from `git checkout` of `store/asc/listings.json` |
| Creative | Re-upload the previous set; keep the 1.2.1 assets before overwriting |
| Version | Delete the 1.3.0 version in the UI (only possible before submission) |

Before Phase 2, capture the current state:

```bash
node scripts/asc/age-rating.mjs > /tmp/age-rating-before.txt
node scripts/asc/offers.mjs --verify > /tmp/offers-before.txt
node scripts/asc/verify.mjs > /tmp/verify-before.txt
```

## Known risks

**The trial's Pro limits may not cover an all-at-once closet upload.** Pro grants 400
extractions and 1,000 generations per month. Batch upload with auto-generate reserves
`images × 3` generations (`backend/app/api/v1/batch_processing.py`), so a single batch
above ~333 items exhausts the generation budget and the reservation fails the whole batch.
Prose in the listing says "room for 400 items" — true for extraction, false for a single
batch with auto-generate. Either the copy says "upload in batches of up to 300" or
`PLAN_PRO_MONTHLY_GENERATIONS` rises. Decide before submitting.

**Free tier friction.** A free user batch-uploading 17 items with auto-generate needs 51
generations and hits the 50/month cap. The listing promises "50 outfit generations" and
"upload your whole closet in one go" — the second is only true for Pro. The copy currently
attributes the whole-closet promise to the trial month, which is correct; do not let it
drift into the free-tier paragraph.

**Nothing can be submitted without a build.** Phases 1–4 can all be done and verified
while the 1.3.0 binary is being produced, but App Review will not see any of it until a
build is attached.
