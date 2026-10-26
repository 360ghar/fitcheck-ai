# store/ and the App Store publishing pipeline

Last updated: 2026-10-26

Index of everything that decides what the App Store listing says, shows and
measures. Read this before running anything; then read
[growth-plan.md](growth-plan.md) for why each surface exists.

---

## The shape of it

```text
store/asc/*.json        declarative intent — what the listing should say
store/creative/         rendered pixels + a manifest that describes them
        │
        ▼
scripts/asc/*.mjs       the only things that talk to App Store Connect
        │
        ▼
App Store Connect       the live record
```

The JSON is the system of record. Tools are replaceable; the files are not.
Nothing under `store/` is generated from the live account — if a value is not in
the repo, the pipeline does not know it.

---

## Files under `store/asc/`

| File | What it holds | Consumed by |
|---|---|---|
| `app.json` | Numeric app id, bundle id, primary locale, target version, subscription group, trial config, URLs, categories, deep-link scheme | every script in `scripts/asc/` |
| `locales.json` | The 50 App Store locales with their Flutter code, native name, review tier and RTL flag | `plan.mjs`, `media.mjs`, `grow.mjs` |
| `listings.json` | The 50 translated listings: name, subtitle, promo text, description, keywords, what's new | `plan.mjs` → `publish.mjs details`, `check-listings.mjs` |
| `cpp.json` | 9 custom product pages: reference name, search intent, keyword set, assigned frames, locales, deeplink, per-locale promo copy | `grow.mjs cpp` (and `publish.mjs cpp`, which reads only name/locales/promotionalText) |
| `ppo.json` | 3 product page optimization experiments: one variable each, hypothesis, metric, minimum sample, treatments with their frame order | `grow.mjs ppo` |
| `events.json` | 3 in-app events: badge, purpose, window, territory schedule, deeplink, per-locale copy | `grow.mjs events` |
| `.translation-cache.json` | Machine-translation cache. Gitignored intent is not: it is committed so a re-run does not re-pay for translations. | the i18n pipeline |

`store/creative/manifest.json` is written by the creative pipeline, not by hand.
Its contract is:

```json
{
  "generatedAt": "<iso8601>",
  "entries": [
    {
      "locale": "hi",
      "kind": "frame" | "header" | "search" | "previewPoster",
      "frame": 1,
      "displayType": "APP_IPHONE_69",
      "path": "store/creative/frames/hi/69/1.png",
      "width": 1320, "height": 2868, "bytes": 123456, "sha256": "…"
    }
  ]
}
```

`media.mjs` validates every entry against the file on disk (dimensions, alpha
channel, extension, size cap) and against Apple's live placement catalog before
it reserves anything.

---

## Scripts under `scripts/asc/`

All of them are dry by default. `--apply` is the only thing that writes, and
every command is idempotent — a second run after a successful apply reports
"already present" and sends nothing.

| Command | Reads | Writes | Purpose |
|---|---|---|---|
| `verify.mjs` | live account | nothing | Baseline report: credentials, versions, localizations, subscriptions, which growth surfaces exist. |
| `check-listings.mjs` | `listings.json` | nothing | ASO validator. Fails on over-limit fields, missing locales, duplicate keywords, drifted offer text. |
| `publish.mjs prepare` | `app.json` | version + 50 localizations | Creates the editable version. Nothing else works without it. |
| `publish.mjs details` | `listings.json` | listing copy | Writes name, subtitle, promo text, description, keywords, URLs per locale. |
| `publish.mjs cpp` | `cpp.json` | custom product pages | Legacy entry point; `grow.mjs cpp` supersedes it and does the same work with keywords and frames. |
| `publish.mjs submit` | — | review submission | Version only. `grow.mjs submit` supersedes it by including CPPs and events. |
| `media.mjs status` | live library + manifest | nothing | Library inventory, placement catalog, manifest diff. |
| `media.mjs upload` | `store/creative/manifest.json` | asset library + placements | Reserve → upload parts → commit, then place onto the editable version. |
| `media.mjs sync` | manifest vs library | nothing | Reconciles by content hash. Reports orphans; never deletes (deletion is a human decision). |
| `grow.mjs status` | live + all three JSON files | nothing | The growth dashboard: what exists live, what exists locally, what differs. |
| `grow.mjs cpp` | `cpp.json` + manifest | 9 custom product pages + keywords + frames | Each page gets its own locales, promo text, search keywords and frame set. |
| `grow.mjs ppo` | `ppo.json` | 3 experiments + treatments + placements | Creating is free and invisible; `--start --experiment=<slug>` spends live traffic. |
| `grow.mjs events` | `events.json` | 3 in-app events + localizations | Expired events are skipped and reported, never an error. |
| `grow.mjs submit` | everything | review submission | Assembles version + every CPP version + every event into one submission. Refuses and names every gap. |

---

## Order to run things

First time, in this order. Steps 1 and 2 are hard gates for everything after.

```bash
# 0. Look before touching
node scripts/asc/verify.mjs
node scripts/asc/grow.mjs status
node scripts/asc/grow.mjs submit --audit      # what the live page is missing

# 1. The version. Nothing can be attached until this exists.
node scripts/asc/publish.mjs prepare --apply

# 2. The copy, all 50 locales.
node scripts/asc/check-listings.mjs
node scripts/asc/publish.mjs details --apply

# 3. The pixels. en-US first; more locales as the creative lands.
node scripts/asc/media.mjs upload --manifest store/creative/manifest.json   # dry run
node scripts/asc/media.mjs upload --manifest store/creative/manifest.json --apply

# 4. The growth surfaces.
node scripts/asc/grow.mjs cpp --apply
node scripts/asc/grow.mjs events --apply
node scripts/asc/grow.mjs ppo                    # create; do not start yet

# 5. One submission carrying all of it.
node scripts/asc/grow.mjs submit --build=<buildId>

# 6. Later, once there is traffic to split.
node scripts/asc/grow.mjs ppo --start --experiment=lead-frame --apply
```

Re-running any of these is safe. `media.mjs` reconciles by SHA-256, `grow.mjs`
reconciles by name/reference name, and `publish.mjs` diffs before patching.

---

## Other documents in this directory

| Doc | Contents |
|---|---|
| [growth-plan.md](growth-plan.md) | The plan: the four surfaces, which locales get effort first, the week-1 launch sequence, what to measure, the 0-ratings problem, and what to cut. |
| [creative.md](creative.md) | The `store/creative/manifest.json` contract: what each kind maps to, why dimensions and not labels decide the placement group, and what the uploader refuses. |
| [app-store-listing.md](app-store-listing.md) | The listing itself: name, subtitle, description, keywords, and the ASO reasoning behind them. |
| [app-store-screenshots.md](app-store-screenshots.md) | Capture spec: required pixel sizes per device family, the screen order, and how to capture and post-process. |
| [aso-keywords.md](aso-keywords.md) | Keyword research per locale. |
| [release-runbook.md](release-runbook.md) | Shipping a version. |
| [play-store-aso.md](play-store-aso.md) | Google Play counterpart. Not read by any script here. |
| [ios-sandbox-testing-runbook.md](ios-sandbox-testing-runbook.md) | How to test subscription and trial behaviour against the App Store sandbox. |

---

## Hard rules

1. **No live write without `--apply`.** Every command is dry by default and
   prints the exact method, path and body it would send.
2. **`app.json` must agree with the account.** `findApp()` refuses to continue
   when `appId` and `bundleId` resolve to different apps. Writing to the wrong
   app is unrecoverable in the obvious way.
3. **The listing and the offer must not drift.** `check-listings.mjs` enforces
   that the free-month and free-forever limits appear in every locale, because
   they are what the ads and the paywall promise.
4. **Delete nothing automatically.** `media.mjs sync` reports orphaned assets;
   deleting one blanks a live page.
5. **One PPO experiment at a time.** Concurrent experiments split the same
   traffic and neither result is readable.
