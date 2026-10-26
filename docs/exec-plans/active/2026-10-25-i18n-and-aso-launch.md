# Plan: 50-language launch and App Store growth

Status: active
Started: 2026-10-25
Owner: agent

## Goal

Ship FitCheck AI in every App Store Connect locale — UI, AI-generated prose, store
metadata, and creative — with a store page that converts. The offer being sold is one
month of Pro free (so a user can upload the entire closet at once) followed by a
permanent free tier (50 AI uploads/month, 50 outfits/month, 10 photoshoot images/day).

Success at 90 days is a measurable lift in product page view rate and conversion rate
across the tier-1 storefronts, driven by four changes: a correct age rating, localized
metadata and screenshots, a visible free month, and coverage in local-language search.

## Why the listing underperforms today

Measured against the live listing (App Store id `6794689012`) and the App Store Connect
API, not inferred:

| Finding | Evidence | Effect |
|---|---|---|
| Rated 17+ for "Unrestricted Web Access" | `advisories: ["Unrestricted Web Access"]` in the public lookup; no WebView exists anywhere in `flutter/lib`, every `launchUrl` uses `LaunchMode.externalApplication` to a fixed developer URL | Ages 13–16 are filtered out of the listing for a capability the app does not have |
| English only | `languageCodesISO2A: ["EN"]`; 1 localization live of 50 shipped | Invisible in 49 storefronts' searches |
| Zero ratings | `userRatingCount: 0`, five weeks live | The strongest single conversion suppressor on the page |
| Raw simulator screenshots | asset filenames are `Simulator_Screenshot_-_iPhone_13_Pro_Max_-_…`; 8 frames, no framing, no captions | Nothing communicates the product in the two seconds a browse impression gets |
| No 6.9" screenshot set | uploads are iPhone 13 Pro Max (6.5" class) only | Renders scaled on current hardware |
| Empty promotional text | live `promotionalText` is 0 characters | The one field editable without review is unused |
| No introductory offer | subscription group `22286350` has four approved products, none with an offer | "Free month" cannot be claimed truthfully |
| Malformed Vietnamese keywords | `vi.keywords` is split into syllables (`trang,tủ,đồ`) instead of words (`trang phục,tủ đồ`) | Those fragments match nothing |

## Non-goals

- Translating `detailedDescription` on wardrobe items. It drives image generation and
  stays English; only display labels localize.
- A human review pass over all 50 locales' marketing copy. Machine translation with a
  structural validator ships now; native review is a follow-up per locale.
- Localizing the web app (`frontend/`) or the admin console.
- Migrating stored taxonomy values. Canonical values stay English so switching language
  never duplicates a user's wardrobe.

## Acceptance criteria

- [ ] `flutter gen-l10n` succeeds and `flutter analyze lib` is clean
- [ ] Every one of the 50 locales has an ARB file with no missing or orphan keys
- [ ] `python3 scripts/i18n/check_locales.py --strict` passes: the five locale
      inventories agree
- [ ] AI prose generation returns the user's language; extraction prompts contain no
      language instruction
- [ ] Age rating corrected; "Unrestricted Web Access" removed
- [ ] One-month free introductory offer exists on the Pro Monthly product
- [ ] Paywall states the trial only to eligible users, using StoreKit 2 eligibility
- [ ] 50 localized listings validated by `scripts/asc/check-listings.mjs` with 0 errors
- [ ] Keyword fields rebuilt in every locale: no term the subtitle already indexes, no
      syllables, no "app"/"free"
- [ ] Six framed screenshots per locale at 6.9" and 6.5", a 21:9 header, and a 3:2
      search creative, all in `store/creative/` with a manifest that passes `check.mjs`
- [ ] 9 custom product pages, 3 PPO experiments, 3 in-app events defined and reviewed
- [ ] Nothing is submitted to App Review from this plan; submission is a separate,
      explicitly approved step

## Context / links

- Related docs: `docs/FLUTTER.md`, `docs/BACKEND.md`, `docs/store/README.md`,
  `docs/store/growth-plan.md`, `docs/store/creative.md`
- Related code: `scripts/asc/`, `scripts/i18n/`, `scripts/creative/`,
  `flutter/lib/core/i18n/`, `backend/app/core/i18n.py`
- Store source of truth: `store/asc/app.json`, `locales.json`, `listings.json`,
  `keywords.json`

## Progress log

| Date | Note |
|------|------|
| 2026-10-25 | Started. Store source of truth and ASC client ported; listings translated to 50/50. |
| 2026-10-26 | Listing validator rewritten to check the offer structurally rather than by an English word list; 50/50 with 0 errors. Keyword planner added. |
| 2026-10-26 | Three false marketing claims corrected in the English source: Pro was described as unlimited (it is 400 items / 1,000 generations), the app was described as 50 languages (it is 50 storefronts across 43 languages), and the photoshoot styles listed did not exist. |
| 2026-10-26 | Offer copy changed from "upload your entire wardrobe in one go" to a batch description, after finding `BatchExtractionNotifier.maxImages = 50` — a batch is capped at 50 photos, so the original claim was false above that. |
| 2026-10-26 | `keywords` removed from the prose translation hash. A keyword field is planned per locale, not translated; including it in `source_hash` meant an eight-word keyword edit forced 49 full re-translations of 3,000-character descriptions. |
| 2026-10-26 | Keyword planner: added a ruleset hash after three locales planned before the forbidden-term filter kept `تطبيق` ("app") in the shipped field. A cached entry written under older rules is now re-planned. |
| 2026-10-26 | Both Gemini translators fixed for a workspace with one live key and one dead one: the dead key's instant `400` was overwriting a real `429`, so a quota problem surfaced as an authentication problem and the quota backoff never ran. |
| 2026-10-26 | Cross-surface keyword gate added: custom product page keywords are now checked against the main listing's indexed tokens and the same forbidden-term list. Caught `free` on the free-month page. |
| 2026-10-26 | Backend language transport built and tested (4,381 passing, 94.6% coverage). Its finding: **there is no model-written user-facing prose in the backend** — every AI call returns canonical data or an image prompt. The prose set the plan assumed is empty. |
| 2026-10-26 | Migration `065_language_explicit.sql` written, not applied. `user_settings.language` is `DEFAULT 'en'`, so a deliberate English choice and an untouched row are indistinguishable. |
| 2026-10-26 | TD-120 recorded: a free user cannot batch-upload more than 16 photos. Batch reserves `images × 3` generations against a 50/month free cap and rejects the whole batch, and the client hardcodes `autoGenerate: true` with no toggle. |
| 2026-10-26 | Four more false claims found by auditing the copy against the code rather than reading it: cost-per-wear has a database column but no UI; "fully translated" was untrue at ~1,000 remaining English literals; "AI outfit names and descriptions match your language" described model prose that does not exist (outfit names are user input or the literal `'Outfit'`); and "localized dates, sizes and currency" was true only for dates, because `LocaleFormat` is defined and never called. All four rewritten. |
| 2026-10-26 | **The largest gap of the project surfaced here:** the app did not ship 43 languages. Only 19 ARB catalogs existed, 11 locales had all 481 keys, 8 had only the original 144, and 32 had none. `flutter gen-l10n` accepted 19 catalogs without complaint, so every missing locale silently rendered English. The gate that catches it (`check_locales.py`) already existed and was already wired into `check_all.sh`; it had simply never been run against the full inventory. |
| 2026-10-26 | RTL work completed: 29 physical-direction call sites across 16 files converted to directional APIs, and a second class the lint cannot see — 8 direction-bearing icon glyphs, which Flutter draws as authored — handled by a new `DirectionalIcon`. `scripts/i18n/check_rtl.py` is a ratchet with an empty baseline, so any new physical direction fails the build. |
| 2026-10-26 | Gemini transport rebuilt for a free tier that is capped per **day** (500 requests) rather than per minute, which the code assumed. The daily marker sits past character 460 of a 1,663-character error body, so a 400-character prefix could not distinguish it from a rate limit; the run slept through four backoffs and died twice. Now classifies on the whole body and rotates across three models, each with its own daily quota. Verified at 7 seconds versus 7.5 minutes. |
| 2026-10-26 | All four Gemini-backed scripts fixed for a repeated-JSON reply. Slicing from the first `{` to the last `}` turns `{...}\n{...}` into two adjacent objects and fails with `Extra data: line 9 column 1`; seven locales died that way in one pass. Replaced with `json.JSONDecoder().raw_decode`, verified against repeated, fenced and prose-wrapped replies. |
| 2026-10-26 | Keyword plan staleness extended to cover its inputs, not just its rules. Apple indexes name and subtitle alongside the keyword field, so the plan spends its 100 characters avoiding terms those two already contain — but only the ruleset was hashed. A retranslation moved 35 of 49 subtitles, leaving entries that read as current while checking redundancy against text that no longer existed. |
| 2026-10-26 | `recommendations.py` was appending an operator instruction to `notes`, which the app renders verbatim: a paying user was told to run `002_astrology_profile.sql` in Supabase. Moved to a server log, and the test that asserted the leak inverted to assert it cannot return. |
| 2026-10-26 | Orchestration error worth recording: the ARB migration was assigned to a parallel agent and then driven by hand at the same time. The agent's command begins with `pkill -9 -f "scripts/i18n/translate_arb.py"`, so each run destroyed the other's; two of mine were killed before the cause was found. One resource, one owner. |
| 2026-10-26 | Backend verification green: 4,400 passed, 4 skipped, 94.62% coverage. `docs/generated/db-schema.md` regenerated so `check_docs_structure.py` passes against migration 065. |
| 2026-10-26 | **The listing is live in 50 locales.** `publish.mjs prepare --apply` created version 1.3.0 and 50 version + 50 app-info localizations; `details --apply` wrote name, subtitle, promo, description, keywords, and both URLs into all 50. `verify.mjs` reports 50/50, 0 errors. Nothing is submitted: the submission gate is "wait for all 43 languages". |
| 2026-10-26 | Age rating corrected: `unrestrictedWebAccess` false. Apple recomputed `FOUR_PLUS`, not the 13+ expected — worth a second look, because a wardrobe app that accepts user photos and publishes shareable outfit pages is declaring nothing at all. Every other field stayed as verified against source. |
| 2026-10-26 | One-month free trial live on Pro Monthly in **175/175 territories**. Three agent assumptions died against the real API, each costing a round trip: `territory` is REQUIRED (offers are per-territory, so "everywhere" is 175 POSTs, not one); `appInfoLocalizations` requires `name`; and CPP creation is a *compound* create. |
| 2026-10-26 | Three ASC script bugs fixed, all the same shape — acting on an assumption a dry run cannot test. (1) `appInfo()` picked whichever record came first, so app-info work targeted the live record and answered `ENTITY_ERROR.RELATIONSHIP.INVALID`; it now prefers `PREPARE_FOR_SUBMISSION`. (2) `age-rating.mjs` did the same, so its PATCH could only ever hit an immutable declaration; the draft appInfo has its own declaration. (3) `appStoreVersionTemplate` is not a relationship on `appCustomProductPages` at all. |
| 2026-10-26 | Custom product pages: 9 created, each with a version, 7 localizations and its deep link. Two blockers found, both real constraints rather than bugs: CPP `searchKeywords` must already exist in that locale's released `appStoreVersionLocalizations` keywords (`Keyword 'ideas' does not exist for ...`), so a CPP cannot introduce new search terms; and CPP screenshots must first be in the asset library, which means `media.mjs upload --apply` is a prerequisite, not an optimization. |
| 2026-10-26 | `it-IT` was not a locale App Store Connect accepts. `store/asc/locales.json` used it and every write for Italian failed — the version row with "The language specified is not listed for localization", the app-info row with `'it-IT' is not a valid 'locale'`. The valid code is `it`. Renamed across the registry, the plan, the listings, the keyword plan and the rendered creative paths; all five inventories are back in sync at 50. |
| 2026-10-26 | Backend would have broken authentication on deploy. `_select_user_row` falls back to a plain query only for PostgREST `PGRST200/201/202`, but a missing *column* on the embedded table answers Postgres `42703` — verified against the live project, which returns `HTTP 400 {"code":"42703","message":"column user_settings_1.language_explicit does not exist"}`. Since the embed sits on the auth dependency, every authenticated route would have raised until migration 065 was applied. The fallback now recognises `42703`, degrades in two steps (drop the column, keep the stored language; drop the embed only if that also fails), and has three tests, one of which caught my own over-broad "does not exist" match swallowing a missing table. |
| 2026-10-26 | **Self-review found that the language picker offered 24 languages the binary cannot render.** `flutter gen-l10n` does not error on a missing `app_<lang>.arb`; it drops the locale from `AppLocalizations.supportedLocales` and Flutter resolves it to English, so picking Arabic from a picker that listed it produced an English app silently. The picker now filters through `LocaleRegistry.shipsCatalog`, `LocaleRegistry.supportedLocales` intersects with the generated catalogs (it was built from all 50 and would have thrown "failed to load unsupported locale" if ever wired into `MaterialApp`), and `flutter/test/core/i18n/locale_registry_test.dart` locks both. TD-126. |
| 2026-10-26 | The UGC report sheet was fully hardcoded English. `report_content_sheet.dart` is the Guideline 1.2 compliance control — the one flow an App Review reviewer is most likely to open in a 50-locale app — and every string in it lived in the widget. Moved into 16 new ARB keys with `ReportContentType` and `_ReportReason` enums that keep a stable English token for the support ticket while the user reads their own language. Note the ARB invariant this exposes: adding a key to `app_en.arb` breaks `flutter analyze` for every catalog that lacks it, so all 27 catalogs must be seeded in the same commit. |
| 2026-10-26 | Reporting exists; blocking does not. `showReportContentSheet` is wired to the shared-outfit page, the try-on result and the photoshoot result and files a real ticket. But there is no block/mute endpoint or UI anywhere, no moderation queue, and a reported public outfit stays reachable at its URL. Guideline 1.2 asks for both. TD-125, and it is a submission blocker alongside the missing catalogs. |
| 2026-10-26 | Custom product pages are 9 shells, not 9 pages. Each has a version and 7 localizations (de-DE, en-GB, en-US, es-ES, fr-FR, ja, pt-BR — the tier-1 subset, not the 50), zero keywords and zero screenshots, all `PREPARE_FOR_SUBMISSION`. Product page optimization is 0 experiments and in-app events is 0 events. Reported as partial rather than done: a CPP with no screenshots cannot be approved, so none of the nine is usable yet. |
| 2026-10-26 | Age-rating doc corrected against reality. The doc predicted Apple would compute ~13+ once `unrestrictedWebAccess` was false; it computes `FOUR_PLUS`, because `userGeneratedContent` is a descriptor and not a floor and every mature-content answer is `NONE`. The prediction is replaced with the observed value and the reasoning, and the note now says the real risk in this area is Guideline 1.2 moderation, not the number. |
| 2026-10-26 | Keyword fields are underfilled in 39 of 50 locales. 19 locales leave 30+ characters of Apple's 100 unused (zh-Hans uses 25, ar-SA and or-IN use 34), and `ko` spends one slot on `오피셜` ("official"), which is not a closet or outfit term. Underfilling wastes the only field Apple indexes besides name and subtitle, so this is the largest remaining ASO gap; filling it needs locale-native term generation, not translation. Recorded in the growth plan rather than patched by hand. |
| 2026-10-26 | Translation throughput is now the critical path, and the two jobs must run in sequence. Remaining work after this pass: 11,798 ARB strings across 49 locales (of which 24 have no catalog at all) plus 19,721 web strings across 34 locales, about 31,500 total. Both scripts spend the same Gemini key, so running them together makes them rate-limit each other — the free tier is 500 requests per day per model, and the model chain rotates three, so the real ceiling is ~1,500 requests/day against roughly 1,400 needed. That is one to two days of wall clock, not one run, and it is the reason the release gate says "wait for all 43 languages" instead of shipping now. |
| 2026-10-26 | The report sheet is now the only Guideline 1.2 control with tests. `buildReportTicket` was extracted as a pure function so the triage invariant — English tokens on the ticket, the user's language on the screen — can be asserted without a widget pump or a network. Writing those tests immediately caught two real defects: `RadioListTile` inside a decorated `Container` never shows its ink splash (Flutter asserts on it), and an empty details field produced four newlines instead of two. Both fixed. |
| 2026-10-26 | **The largest finding of the whole self-review: the ARB migration was measuring the wrong thing.** Scanning `flutter/lib` for user-facing literals passed to `Text(`, `tooltip:`, `labelText:`/`hintText:`/`errorText:` and `title:`/`message:` shows **413 distinct English strings across 69 files** that never entered the localization system at all. The catalogs hold 512 keys, so roughly half the UI text cannot be translated by any catalog. The worst files are the ones that matter most: `batch_image_selector_page.dart` (36 — the first-run upload flow), `calendar_page.dart` (20), `gift_vouchers_page.dart` (20), `app_exceptions.dart` (19 — every error the user ever sees), `subscription_page.dart` (16). Generating the 19 missing catalogs without extracting these would produce 43 languages of half-English app, and "A translated interface across all 43 languages" in `whatsNew` would be false in the most visible possible place. TD-129. |
| 2026-10-26 | Added `scripts/i18n/check_claims.py` so that claim can never silently ship. It parses the largest "N languages" figure and any "translated interface" phrase out of `store/asc/listings.json`, then compares them against the catalogs on disk and the hardcoded-literal count. `--gate` exits 1 on a mismatch and is now step 5 of Phase 0 in `docs/store/release-runbook.md`. It is deliberately not in `check_all.sh`: during a migration the build is expected to be behind its own copy, and a check that fails on every commit trains people to ignore it. |
| 2026-10-26 | Localized the public shared-outfit page. It is the one screen an App Review reviewer reaches from a link rather than by navigating, and all 15 strings on it were hardcoded English — `'Shared outfit'`, both tooltips, the entire hide dialog, three empty states and the sign-up prompt. Reused `actionCancel` rather than adding a duplicate. Note what the hide dialog says: "It stays hidden on this device", which is honest but is *not* the block control Guideline 1.2 asks for (TD-125). |
| 2026-10-26 | **Repeated the orchestration mistake from earlier in the same session.** `translate_arb.py` snapshots `app_en.arb` when it starts and writes whole catalog files from its cache. I added 15 keys to `app_en.arb` while the job was mid-run, so the catalogs it created afterwards (`ar`, `he`, `ur`, `hi`, …) carried the older 497-key set. Nothing was lost, but the lesson did not generalize: last time the collision was two processes writing the same file, this time one process snapshotting a file another process extended. Added `scripts/i18n/sync_arb_keys.py` to fill any missing key with the English source so `check_locales.py` is green and the catalogs are uniform. |
| 2026-10-26 | **Corrected a wrong claim I had just written down.** I recorded that a key missing from an ARB catalog is "a hard compile error". It is not: `flutter gen-l10n` falls back to the English template for a missing key and lists it in `build/untranslated.json`, so the build compiles and that one string renders English. What actually produces `non_abstract_class_inherits_abstract_member` is a stale `app_localizations_<lang>.dart` whose `app_<lang>.arb` was deleted or renamed — gen-l10n never removes old output. The two look identical in the error message, which is why I conflated them. Verified both ways in the tree: 9 catalogs currently missing 15 keys compile clean, and `rm -rf lib/l10n/generated && flutter gen-l10n` fixed the original failures instantly. TD-132, and the runbook now says `rm -rf` before generating. |
| 2026-10-26 | `check_locales.py` was demanding `@description` metadata in all 30 catalogs, which no tool can produce: `gen-l10n` reads metadata from `app_en.arb` alone, and `translate_arb.py` skips every `@` key when it writes a catalog. That was ~30 lines of noise per run. The check now reports template coverage once, and doing so surfaced real debt: **128 of 512 template keys have no description**, and those are the ones a translator is most likely to mistranslate without a note (TD-133). My own 31 new keys all carry one. |
| 2026-10-26 | `pt` and `pt_BR` had diverged on 16 values — exactly the 16 `report*` keys I added, which `pt_BR` had translated and `pt` had not. `pt` is the language fallback for `pt_BR` and must be byte-identical, so `gen-l10n` was one edit away from serving English report copy to Portugal. Mirrored from `pt_BR`. This is the class of bug that only a cross-inventory check finds; nothing about either file looks wrong on its own. |
| 2026-10-26 | **The keyword optimization had never been published.** `keywords.json` and `listings.json` both held the tuned 4,882 characters (mean 71 → 98 per locale, zero locales under 90), and `check-listings.mjs` read that file and reported "No errors", so the work looked done. App Store Connect was still serving the old short fields: `ar-SA` had 34 characters live against 91 on disk, `ja` 46 against 100. The plan was written by `keyword_planner.py`, which publishes nothing; the push lives in `publish.mjs details`, and nobody had run it after the plan landed. Pushing it fixed 48 of 50 localizations in one pass. The lesson repeats the day's theme — a validator reading the intended state says nothing about the deployed state — and the reason it was invisible is that no check ever compared the two. |
| 2026-10-26 | **836 characters were written in the wrong alphabet, and every check passed.** `app_kn.arb` held 667 Georgian characters across 29 keys, so the billing and share block in the Kannada app was Georgian; the rest were homoglyphs (`galерии` with Cyrillic `е`, `Роζ` with Cyrillic `Ро`, `事件` inside a Greek sentence, `ರಿ` inside Bengali `সরিসি`). Keys exist, values are non-empty, braces balance, values differ from English, so `check_locales.py`, `check_claims.py` and `flutter analyze` were all green. Fourth instance of validating form while meaning is wrong, so the fix is a guard rather than an edit: `check_scripts.py` compares each character against the scripts the locale may use, and `repair_scripts.py` re-translates only the flagged keys with the script named, rejecting any answer that still carries a foreign character or changes the ICU placeholder shape. 113 strings across 16 locales. TD-141. |
| 2026-10-26 | Found 17 more RTL bugs that the ratchet could not see. `check_rtl.py` matched per-line labels (`EdgeInsets.only(left:`), but `EdgeInsets.fromLTRB(l, t, r, b)` takes four positional arguments, so it never matched, and 63 of the 83 sites are symmetric and harmless anyway. Added a whole-file pass that compares argument 1 to argument 3: **17 sites had unequal left and right**, every one a real mirroring bug in Arabic/Hebrew/Urdu (batch upload, calendar, dashboard, subscription, wardrobe, profile, recommendations). All 17 converted to `EdgeInsetsDirectional.only(start:, top:, end:, bottom:)`. Full suite still 606 passing, goldens included, because the flip only shows under RTL. |
| 2026-10-26 | `verify.mjs` was reporting the wrong version and looked like a blocker when there was none. It printed localizations for the live 1.2.1 — "1 present of 50 … missing locales (49)" — while the draft 1.3.0 it exists to check was complete at 50/50. It now reports both, labels the draft as the next submission and the live set as "expected until the localized version ships". A report that reads like a blocker when there is none trains you to ignore the one time it is right. |
| 2026-10-26 | `flutter/lib/l10n/generated/` is neither committed nor gitignored, and `check_all.sh` never ran `gen-l10n`. On any clean checkout the `AppLocalizations` class does not exist, so `flutter analyze` and `flutter test` fail to compile across the 200+ files that import it — the harness only worked on a machine that had already run the app once. Added `flutter gen-l10n` before analyze in `check_all.sh`. Committing the generated classes would be the other fix and matches how `.g.dart`/`.freezed.dart` are handled (22 of them are tracked), but generating in the harness is the durable one because it cannot drift from the catalogs. |
| 2026-10-27 | **The gate everyone trusted was the third silent failure.** `check_claims.py --gate` printed `OK — the published copy matches what the build delivers` while 34 of 48 catalogs sat at 37-68% translated and rendered English on the device, because it counted catalog *files*, not translated *values*. A catalog that exists but falls back to the template is invisible in a file count. It now measures per-catalog coverage against `app_en.arb`, exempts the three English storefront variants, and fails below 90% (`--min-coverage`). Mean coverage when the fix landed: 67.7%. |
| 2026-10-27 | **Fixed the age rating to 12+, which the product decision required.** Apple computed `FOUR_PLUS` from honest content answers, and that is not the right audience for an app whose own product requirement is 12+/13+. It also understates the risk: shared-outfit pages render another user's photos with no block control (TD-125). Set `ageRatingOverrideV2: THIRTEEN_PLUS`; the draft `appInfo` now reads `TWELVE_PLUS`. Raising a rating is permitted, lowering is not, so this is the allowed direction. |
| 2026-10-27 | **Reclaimed 1,322 keyword characters across 50 storefronts.** `keyword_planner.py` reported 1,440 unused characters out of 5,000 and 165 spent on terms the subtitle already indexes. `zh-Hans` used 25 of 100 — in the largest App Store market by downloads. Ran the planner on Agnes and applied: unused is down to 118, redundant to 0, and `zh-Hans` now carries `衣橱,智能衣橱,穿搭建议,每日穿搭,衣橱整理,虚拟试穿,数字衣橱` at 98/100. |
| 2026-10-27 | **The keyword planner could not see duplicates in Thai, and the cause was two bugs in one fold.** `normalize` stripped every combining mark (right for `Café`→`cafe`, fatal for Thai where the vowel sign *is* the letter), and `words` split on `[^\w]`, which classifies marks as non-word, so `ตู้เสื้อผ้า` fragmented into `ต`, `เส`, `า`. A Thai keyword repeating its own subtitle was therefore paid for twice. Marks now stay attached, and a script with no spaces is checked by substring. `rules_version()` gained a `tokenizer` marker: the cache fingerprint ignored the folding rules, so the fix would have been invisible to every cached plan — the same class of bug as the one it fixes. |
| 2026-10-27 | **Confirmed the store screenshots are not localized, the largest remaining honesty gap in the ASO set.** All 600 frames embed one of six English captures of the 1.2 app, so `ar-SA` shows an Arabic headline above a phone screen reading "Wardrobe", "Tops", "Home", "Outfits". I viewed the PNG rather than trusting the manifest. No policy is broken, but it undercuts the "43 languages" claim on the product page. `render.mjs` now resolves `source/screens/<locale>/<name>.png` with a fallback, records which capture went into each frame, and `check.mjs` warns for every non-English frame still on the fallback. What remains is the capture job itself. |
| 2026-10-27 | **The `grow.mjs` PPO path had never been run against the real API, and could not have worked.** It posts to `/v1/appStoreVersionExperimentsV2`, which answers `404 "The path provided does not match a defined resource type"` — the resource is `appStoreVersionExperiments`. It also listed experiments through `/v1/apps/{id}/appStoreVersionExperiments`, which answers `404 "the relationship does not exist"` because experiments hang off a **version**, and it created them with an `app` relationship and a `platform` attribute that the real resource does not take. Four separate defects, all invisible in a dry run that only prints its own assumptions. Fixed: the real type, version-scoped listing, `appStoreVersion` relationship against the READY_FOR_SALE version, no `platform`. Also found that Apple **permits only one experiment in `PREPARE_FOR_SUBMISSION` at a time** ("another experiment is in draft state"), so `--experiment` now filters creation and not just `--start`. |
| 2026-10-27 | **Two more API reality checks that the plan files had wrong.** Experiment traffic is capped at **75%**, not 100 ("Control cannot receive less traffic than treatment"); `trafficProportion: 100` was rejected outright. And an AppEvent accepts neither `priority: LOW` (only `HIGH`/`NORMAL`) nor a `purchaseRequirement` attribute at all, and rejects the entire create over an unsupported storefront (`Invalid territories: [BGD]` — in-app events are not offered in every country). All four are now correct in `store/asc/ppo.json` and `store/asc/events.json`. **The PPO icon experiment is not creatable through the API at all**: its treatments name `AppIcon_Hanger`/`AppIcon_Stack`/`AppIcon_Mirror`, Apple exposes no endpoint to upload an app icon, so the experiment was created with zero treatments, and was deleted as an empty draft. |
| 2026-10-27 | **In-app events cannot be submitted through the App Store Connect API.** All three are created and sitting in `DRAFT`. `eventState` is rejected on create ("can not be included in a CREATE operation") *and* on update ("can not be included in an UPDATE operation"), and there is no submit endpoint on `appEvents`. Submission is a web-UI action. The user asked to create them and start them; creating is done, starting is not possible over the API and is not something I should pretend to have done. It also needs the event card (16:9) and details (9:16) media, which are in the 734 assets not yet uploaded. |
| 2026-10-27 | **The App Review demo account was already configured, and the doc said otherwise.** `appStoreReviewDetail` already holds `demoAccountName: info@360ghar.com` with a password set, a contact and phone, so the `REPLACE with the real seeded account` placeholder in `docs/store/app-store-listing.md` was stale and actively misleading — it invited someone to overwrite working credentials. The notes were only 229 characters and covered nothing but the IAP sandbox flow, which is a Guideline 2.1 risk for an app whose features all sit behind sign-in. Rewrote them to 2,048 characters: app overview, how to reach each AI feature, the free-tier limits, the upgrade path, and the in-app deletion route Apple requires under 5.1.1(v). Passwords stay in the ASC fields, never in the repo. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-10-25 | Free month is an Apple introductory offer on Pro Monthly, not an in-app grant | Survives reinstalls, is visible on the listing, and is the only version Apple's own UI states credibly |
| 2026-10-25 | All 50 locales in one release rather than tier-by-tier | One review cycle; a partial set reads as abandoned in the missing storefronts |
| 2026-10-25 | Canonical data (categories, conditions, seasons, styles) stays English; only display labels localize | A user who switches language must not accumulate duplicate items |
| 2026-10-25 | Only generated prose is localized server-side | The client cannot translate free text the model wrote |
| 2026-10-26 | Keyword fields are planned by asking for local search terms, not by translating English ones | "Closet organizer" translated literally is rarely what a local user types |
| 2026-10-26 | Keyword validator checks the offer's structure, not its wording | Bengali ৫০ and Odia ୫୦ are correct and an ASCII digit match reads them as missing |

## Verification

```bash
python3 scripts/i18n/check_locales.py              # five inventories agree + no missing catalog
python3 scripts/i18n/check_claims.py --gate        # copy does not promise more than the build does
python3 scripts/i18n/sync_arb_keys.py              # every catalog carries every key
python3 scripts/i18n/check_rtl.py                   # no physical-direction layout
node scripts/asc/check-listings.mjs --strict        # 50/50, structural parity with English
python3 scripts/asc/keyword_planner.py
node scripts/asc/verify.mjs                         # draft and live, separately
node scripts/creative/check.mjs
cd flutter && flutter gen-l10n && flutter analyze && flutter test
cd backend && source .venv/bin/activate && pytest
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
python3 scripts/check_architecture.py
python3 scripts/check_docs_structure.py
```

`check_claims.py --gate` is the one that decides whether the release can proceed,
because it is the only check that reads the marketing copy as a claim about the
binary rather than as text. It now passes: 43 base languages on disk match the
43 the listing advertises, and the widget tree has zero hardcoded user-facing
English literals (TD-129 closed, was 413).

### State as of 2026-10-27 (mid-flight)

| Gate | State |
|------|-------|
| `check_claims.py --gate` | **fails, correctly** — 4,678 untranslated prose strings across 48 locales, so the copy still promises more than the build delivers |
| `check_rtl.py` | **passes** — 0 sites |
| `check_locales.py` | passes for structure (all 51 catalogs × 1,346 keys) and warns where values equal English |
| `sync_arb_keys.py` | **clean** — all 51 catalogs carry all 1,346 keys |
| `check-listings.mjs` | **0 errors** — 50/50 locales, 0 redundant keywords, 0 over a cap |
| `creative/check.mjs` | **0 errors**, 14 warnings, all of them the two documented Tamil-review categories |
| Media upload to ASC | **done** — 750 assets in the library, 700 placements created and ordered (300 + 300 screenshots, 50 headers, 50 search cards) |
| Custom product pages | **done** — 9 pages, 7 locales each, 364 frame placements, all `visible=true`; keywords still refused (see below) |
| Translation coverage | **4,678 prose strings outstanding**, 4,470 of them in the 8 locales the quota blocked (`zh` `vi` `th` `ko` `ja` `id` `ca` `pt`); resets 17:00 UTC |

Measured honestly, which took three attempts: an untranslated string is one whose
value is **empty or equal to the English source**, and the count must be taken
over prose only. Two wrong numbers came before this one. Counting `value !=
english` reports 97% coverage on a catalog that is half empty, because `""` is
not equal to anything (the TD-136 trap, re-introduced). Counting every identical
value reports 42 "missing" strings in Danish when 39 of them are words Danish
spells the same way — `Business`, `Vintage`, `Filter`, `System`, `Support` — plus
`LinkedIn`, `Instagram`, `FitCheck AI`. The number above only counts values whose
English contains at least two words of three or more letters once placeholders
are stripped, which is the closest mechanical proxy for "a translator had
something to do".

### Earlier state, 2026-10-26 session

| Gate | State |
|------|-------|
| `check_claims.py --gate` | **fails, correctly** — 0 hardcoded literals and 43 base languages, but 34 of 48 catalogs below 90% coverage while the copy claims a translated interface |
| `check_rtl.py` | **passes** — 0 sites (17 real bugs found and fixed, incl. a `fromLTRB` blind spot) |
| `check_locales.py` | fails while translation is in flight — catalogs exist for all 50 locales but some are below full coverage |
| `flutter analyze` / `flutter test` | **clean** — no issues; 606 pass, 2 skipped |
| `backend pytest` | **clean** — 4,403 passed, 4 skipped, 94.62% coverage |
| `check-listings.mjs` | **0 errors** — 50/50 locales, full structural parity |
| Translation coverage | in flight on Agnes (`--provider agnes`), 14 of 48 locales at 90%+ |

`check_claims.py` was the *third* silent failure, and the one that mattered most
because it was the gate everyone trusted. It counted catalog **files**, so 52
files and 0 hardcoded literals printed `OK — the published copy matches what the
build delivers` while 34 of 48 catalogs sat at 37-68% translated and rendered
English on the device. A catalog that exists is not a catalog that is
translated: `gen-l10n` fills missing keys from the template, so coverage is
invisible in the file count. The check now measures per-catalog coverage against
`app_en.arb`, exempts the three English storefront variants (`en_GB`, `en_AU`,
`en_CA`) whose catalogs legitimately match the source, and fails the gate below
90% (`--min-coverage`). This is what turns "we localized the app" into a
measurement instead of an assumption.

Two earlier failures worth naming, because both were silent:

- `translate_arb.py` used to **delete** any catalog below 90% coverage. When the
  template grew from 923 to 1,346 keys, every catalog fell to 68% and one run
  unlinked 46 of 50 languages. The catalogs were untracked, so only the
  translation cache brought them back. Deletion is gone; low coverage is
  reported. `check_locales.py` now also fails when a locale in
  `locale_registry.dart` has no catalog, which is the check that would have
  caught it (TD-134).
- Three store descriptions had lost most of their feature bullets, and `or-IN`
  had lost the auto-renewal disclosure that Guideline 3.1.2 requires.
  `translate_listings.py` now compares bullet and paragraph counts against
  English, repairs a truncated field line by line, and treats "still the English
  source" as a failure rather than a valid translation (TD-130 closed).

### State at the end of the 2026-10-26 self-review

| Area | State | Blocking? |
|---|---|---|
| Draft listing 1.3.0 | 50/50 localizations, 0 errors, descriptions structurally complete | no |
| Live listing 1.2.1 | `en-US` only, as published | no |
| Age rating (draft) | `TWELVE_PLUS` via `ageRatingOverrideV2: THIRTEEN_PLUS`, all 30 fields verified against source | no |
| One-month trial | 175/175 territories on Pro Monthly | no |
| ARB catalogs | 14 of 48 at 90%+ translated; Agnes pass in flight | **yes** (TD-135) |
| Hardcoded UI strings | 0, and the listing claims a translated interface | no (closed) |
| Block/mute control | does not exist; Guideline 1.2 asks for it | **yes** (TD-125) |
| Custom product pages | 9 pages, 7 locales each, 364 frame placements, `visible=true`; keywords refused because Apple requires them to be a subset of the released listing's | no (needs its own submission) |
| Creative assets | 750 generated, 750 uploaded, 700 placements ordered | no (closed) |
| PPO experiments / in-app events | PPO 2 created with 3 treatments (needs placement retry); 3 events in `DRAFT`, submission is web-UI only | no |

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- ~1,000 Flutter string literals are still hardcoded English outside the ARB catalogs
  (measured, not estimated: 1,047 occurrences across 114 files, of which
  `locale_registry.dart`'s 25 are native language names that must stay untranslated).
  The listing therefore says "a translated interface", not "fully translated".
- 49 locales are machine-translated and marked unreviewed; native review per locale is
  outstanding. `check-listings.mjs` warns on every locale until someone marks it reviewed.
- No ratings prompt has ever run, so the listing has no social proof to show. TD-120 is
  the related churn risk: a free user cannot batch more than 16 photos.
- TD-121: ~46 user-visible English strings are generated server-side (`astrology_service`
  notes, `recommendations` reasons, photoshoot use-case descriptions) and printed
  untranslated. Eight of them are baked into a server-rendered gift PNG and cannot be
  reached by any ARB at all.
- The 4 ARB keys in `store/asc/pending-arb-keys.json` are deliberately not merged. Three
  are optional copy experiments and one restates the post-trial price already present in
  `paywallTrialEligibleOnly`; translating them costs 49 API calls against a quota that
  is currently the binding constraint on the larger ARB migration.
