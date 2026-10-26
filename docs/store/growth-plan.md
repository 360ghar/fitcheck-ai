# App Store growth plan — FitCheck AI iOS

Last updated: 2026-10-26
App: `6794689012`, bundle `com.fitcheckaiapp.fitcheckai`, live at
`https://apps.apple.com/app/id6794689012`

This is the plan for the four growth surfaces that sit on top of the plain store
listing: localized creative, custom product pages, product page optimization, and
in-app events. It is written to be executed, not admired. Where something will
not work, it says so.

---

## 1. Where the app actually is

Read from App Store Connect, not from memory:

| Fact | Value | Why it matters |
|---|---|---|
| Versions | 1.0, 1.2.0, 1.2.1 all `READY_FOR_SALE` | No editable version. Nothing can be attached until 1.3.0 is created. |
| Listing localizations live | **1** (`en-US`) | 50 are translated on disk. 49 storefronts currently show English. |
| Screenshots live | 8 iPhone **6.5"** (`IPHONE_FACE_ID_LARGE_PROFILE`), 8 iPad 13" | No 6.9" set. Apple's featured shelf is the 6.9-inch set. |
| Custom product pages | 0 | 9 planned in `store/asc/cpp.json`. |
| In-app events | 0 | 3 planned in `store/asc/events.json`. |
| PPO experiments | 0 | 3 planned in `store/asc/ppo.json`. |
| Ratings | **0** | The single largest conversion suppressor on this page. See §7. |
| Asset library | 16 images, all `APPROVED`, all named by original file name | Nothing from `media.mjs` yet; the 16 are web-UI uploads. |

The install funnel has exactly three steps and each growth surface moves exactly
one of them. Getting this mapping wrong is how teams spend a quarter optimizing
the wrong number.

```
impressions  →  product page views  →  installs
   (1)                 (2)                 (3)
```

1. **Impressions** — how often the app appears in search results, charts, or an
   event surface. Moved by: search keyword coverage, custom product page keyword
   assignment, in-app event badges, ratings (which feed ranking).
2. **Product page view rate** — views ÷ impressions. Moved by: the icon, the
   first screenshot, the title and subtitle, and the review stars under the
   title. A custom product page moves this *for the query it targets*.
3. **Conversion rate** — installs ÷ views. Moved by: screenshots 2–10, the
   description, the promo text, ratings, and the price/subscription signal.

---

## 2. The four surfaces, and how they compound

| Surface | What it actually is | Number it moves | Reviewed? | Maintained? |
|---|---|---|---|---|
| **Localized creative** | Screenshots, header, search creative per locale | (3) conversion, per storefront | With the version | Re-cut when the UI changes |
| **Custom product page (CPP)** | A second product page at its own URL, own screenshots, own search keywords | (2) for a targeted query, (3) for a matched promise | Separately, per page version | Static once built |
| **Product page optimization (PPO)** | A closed experiment on one variable of the main page | (3), or (2) for an icon test | Once, at experiment creation | Ends when you adopt a winner |
| **In-app event** | A dated card on the page and in search | (1) and (2), briefly | Separately, per event | Expires in ≤31 days |

They compound in one direction only:

1. A **CPP** gives you a page whose first screenshot matches the promise of a
   specific query or ad. That is a landing page. It does not create traffic.
2. **PPO** tells you which of your frames actually converts, with a number
   attached instead of an opinion.
3. The winning frame belongs on the control page *and* at the top of every CPP
   whose promise it matches. That is the compounding: PPO output is CPP input,
   and the CPP is what you point paid traffic at.
4. **Events** are the only surface that can say "now". They convert people
   already looking at the app. They do not create demand.

If you do these out of order — events before creative, CPPs before you know
which frame wins — you get four surfaces making the same unproven argument.

---

## 3. Locales: where the effort goes first

The repo ships 50 locales. **23 are tier 1** (native review). Those get creative
first, in this order:

| # | Locale | Why here |
|---|---|---|
| 1 | `en-US` | Every experiment is read here. Everything else is a copy of what wins here. |
| 2 | `en-GB` | Same creative, zero extra cost. |
| 3 | `ja` | Highest iOS ARPU outside the US; App Store screenshots are read closely. |
| 4 | `ko` | Same, smaller. |
| 5 | `de-DE` | Largest non-English European storefront. |
| 6 | `fr-FR` | Second largest. |
| 7 | `es-ES` | Third; also seeds LatAm. |
| 8 | `pt-BR` | Largest single Latin American storefront. |
| 9 | `zh-Hans` | Large, but ranking competition is brutal; text-only until it earns creative. |
| 10 | `zh-Hant` | Same. |
| 11 | `it` | Tier 1 by volume. |
| 12 | `hi` | Large iOS base, low ASO competition — the cheapest ranking win available. |
| 13 | `ar-SA` | RTL; needs mirrored creative, so it is the one locale where screenshots cannot be reused. |
| 14 | `tr` | Tier 1 by review effort. |
| 15 | `bn-BD` | Tier 1 in `locales.json`; low competition. |
| 16 | `ta-IN` | Same. |
| 17 | `te-IN` | Same. |
| 18 | `mr-IN` | Same. |
| 19 | `gu-IN` | Same. |
| 20 | `kn-IN` | Same. |
| 21 | `ml-IN` | Same. |
| 22 | `pa-IN` | Same. |
| 23 | `es-MX` | Tier 1; shares copy with `es-ES`. |

**Caveat that most locale plans ignore:** a listing in a locale does not produce
impressions in that locale. Apple shows the app where it ranks. Writing 50
listings is a prerequisite for ranking, not a guarantee. The seven locales in
`store/asc/cpp.json` are the ones with hand-written promotional copy; the other
43 have listing copy but no bespoke creative, and that is the correct order.

---

## 4. What to measure, and which surface moves it

All four numbers come from **App Store Connect → Analytics**, not from a guess
at what "feels" better.

| Metric | Definition | Moved by | Reporting surface |
|---|---|---|---|
| **Impressions** | Times the app appeared in search, charts, or an event card | Keyword coverage, CPP keyword assignment, event badges | Analytics → App Store → Impressions |
| **Product page view rate** | Views ÷ impressions | Icon, title, subtitle, star rating, and a CPP that matches the query | Analytics → Acquisition; **PPO reports it per treatment** |
| **Conversion rate** | Installs ÷ views | Screenshots 2–10, description, promo text, ratings, price signal | Analytics → Conversion; **CPP and PPO both report it** |
| **Retention of a channel** | Installs from a CPP that open the app twice in 7 days | The deeplink landing screen, not the page | Analytics → Custom Product Pages + your own deeplink analytics |

The distinctions that matter when reading results:

- A **CPP moves its own traffic, not the app's.** Its numbers appear under
  Analytics → Custom Product Pages, keyed by the page's token. If a CPP shows
  0 views, it was never linked — not "it failed".
- **PPO moves the number it was designed to move and nothing else.** An icon
  experiment's result is a tap-through delta; reading installs from it dilutes
  a real 10% lift into nothing. `store/asc/ppo.json` declares the metric per
  experiment for exactly this reason.
- **Events inflate impressions for their window and then stop.** Do not compare
  a month with an event to a month without one.

**Minimum sample before believing anything:** 800 product page views per cell
for a conversion test, 1200 impressions per cell for a tap-through test. Below
that the result is a coin flip with a story attached. This is enforced as
`minimumPerCell` in `store/asc/ppo.json`.

---

## 5. Week-1 launch sequence

Five steps. Each one leaves the account in a consistent state, so a failure
mid-way is resumable rather than catastrophic.

1. **Create the version and the 50 localizations** (~1 hour, mostly waiting)
   ```bash
   node scripts/asc/publish.mjs prepare --apply
   node scripts/asc/publish.mjs details --apply
   ```
   This is the gate: nothing else can be attached to a version until 1.3.0
   exists in `PREPARE_FOR_SUBMISSION`.

2. **Upload the 6.9-inch and iPad 13-inch creative for `en-US` only** (~20 min)
   ```bash
   node scripts/asc/media.mjs upload --manifest store/creative/manifest.json --apply
   ```
   One locale first. The 6.9" set is what Apple features; the current page has
   only 6.5", which is a real gap, not a preference.

3. **Create the 9 custom product pages and assign their search keywords** (~15 min)
   ```bash
   node scripts/asc/grow.mjs cpp --apply
   ```
   Frames are placed only for locales whose creative exists. A page whose frames
   are missing stays with the template's screenshots and is reported, not
   silently shipped.

4. **Create the in-app events** (~10 min)
   ```bash
   node scripts/asc/grow.mjs events --apply
   ```
   `closet-refresh-2026-11` is the one that is live now. The other two are
   scheduled. An expired event in the file is skipped and reported, not an error.

5. **Submit the version, every CPP version and every event in one submission** (~5 min)
   ```bash
   node scripts/asc/grow.mjs submit --build=<buildId> --apply
   ```
   A review submission carries `appStoreVersion`, `appCustomProductPageVersion`,
   `appEvent` and `appStoreVersionExperimentV2` items together. Apple reviews
   them as one. `submit` refuses and names every gap rather than submitting a
   partial set.

After approval: point every ad, creator video and landing page at a **CPP URL**,
not the main App Store link. A CPP only earns its keep when a link points at it.

Then, and only then, start PPO 2 (lead frame) once the main page is doing ≥800
views per week:

```bash
node scripts/asc/grow.mjs ppo --start --experiment=lead-frame --apply
```

---

## 6. What the creative has to do

The offer being marketed is **one month of Pro free** (upload the entire closet
at once), then **free forever** with 50 AI uploads/month, 50 outfits/month, 10
photoshoot images/day.

The render pipeline defines **six** frames (`store/creative/copy.json`), not ten:

| id | Shows | Position |
|---|---|---|
| `closet` | The wardrobe grid — dozens of real garments | 1 |
| `daily` | Home, today's outfit from live weather | 2 |
| `tryon` | The outfit rendered on your own body | 3 |
| `photoshoot` | Studio photos from your selfies | 4 |
| `wear` | Cost per wear — what you actually use | 5 |
| `offer` | One month Pro free, then free forever | 6 |

Apple accepts up to ten screenshots. Four slots are therefore unused, and that
is a concrete cost: `store/asc/ppo.json` can only test gallery depth up to six,
and there is **no calendar frame**, so the "wardrobe planner" custom product
page cannot show planning. It leads with `daily` instead, which is the closest
available promise, and it will under-perform until a calendar frame exists.

The rule every page follows:

> The lead frame must depict the promise in the page's name.

A "virtual try on" page whose first screenshot is a wardrobe grid pays for the
click and loses the install. `store/asc/cpp.json` assigns frames per page and
states why for each one; `grow.mjs` resolves each id against the render
manifest and refuses to place a frame that was never rendered.

**Creative coverage is the real bottleneck.** Frames are rendered per locale,
one locale at a time. A page can exist in seven locales while only one of them
has artwork; the other six keep the template's screenshots, which is correct but
not the point of the page. `grow.mjs cpp` prints coverage per frame id at the top
of every run — read it before assuming a page is ready.

---

## 7. The ratings problem

**Zero ratings is the biggest conversion suppressor on this listing, larger than
any screenshot.** It is also the one thing on this list that no amount of
App Store Connect metadata can fix, because ratings come from users, not from
the console.

What 0 ratings actually does:

- The product page shows no star row and no rating count. A user comparing two
  apps sees "New" against a competitor's 4.7 with 12k ratings, and moves on.
- Apple's search ranking uses ratings and rating velocity as signals. An app
  with no ratings ranks below an equivalent app with a hundred mediocre ones.
- Every PPO experiment you run before ratings exist is measuring a page that
  converts badly for a reason none of the treatments address. You will pick the
  least-bad screenshot of a page nobody trusts.

What fixes it, in order of effect:

1. **Ask at the moment of success, not at launch.** After the user has generated
   a finished outfit or a photoshoot result — something they can see and would
   miss. Not after login, not on first open, not after an error.
2. **Use `SKStoreReviewController.requestReview`,** which shows Apple's own
   prompt. A custom "rate us 5 stars" screen that gates the system prompt is a
   review rejection, and a custom screen that *replaces* it earns nothing
   because only the system prompt writes to the rating table.
3. **Trigger on earned state, not on a count of launches.** A reasonable rule:
   three completed outfits **and** seven days since install **and** no prompt in
   the last 120 days. Apple's own cap is three prompts per 365 days per user;
   the system prompt honours it, so the risk is annoying users, not violating
   policy.
4. **Never incentivise.** No unlock, no Pro day, no entry into a draw in
   exchange for a rating. App Review guideline 5.6.4, and it is checked.
5. **Reset the rating when you ship the version.** In App Store Connect, keep
   "Reset Rating When New Version is Released" **off** while the app is under
   50 ratings. Resetting a 4.2 with 8 ratings to zero to "get a fresh start" is
   the most common self-inflicted wound on a new app.
6. **Reply to every review,** including the bad ones, in App Store Connect.
   Reply rate is visible and it changes what the next reader concludes.

Target: **50 ratings within 30 days of the 1.3.0 release.** At 50 the star row
appears and the conversion baseline moves enough that PPO becomes worth running.
Until then, treat every conversion number as provisional.

---

## 8. What will not work, and what to cut

Blunt, in order of how much time it saves:

- **Custom product pages will not bring anyone.** A CPP has no organic
  discovery of its own. It is a landing page. With no ads, no creator links and
  no landing-page traffic, nine CPPs generate approximately zero installs and
  cost nine reviews. Build them because you are about to buy traffic, not
  because you hope they rank.
- **PPO cannot resolve at current traffic.** At a few installs a day, 800 views
  per cell takes months. Running it anyway produces a "winner" that is noise,
  and shipping that winner makes the page worse. Wait for traffic, or buy it.
- **Localized screenshots do not create localized demand.** Bengali, Tamil and
  Marathi creative is only worth rendering once those storefronts show
  impressions. Check Analytics → Impressions by territory before spending a
  rendering pass on a locale.
- **In-app events do not create demand.** They give an existing visitor a reason
  to tap today. An app nobody is looking at does not benefit.
- **Three concurrent PPO experiments destroy each other.** Splitting the same
  small traffic three ways gives three unusable results instead of one good one.
  `grow.mjs ppo` refuses to start a second experiment for this reason.
- **A "free month" CPP aimed at everyone captures nobody.** It is an offer page,
  so it belongs pointed at paid traffic and at people who searched for a free
  alternative, not run as a general second home page.

Cut, on a quarterly review:

1. Any CPP with **fewer than 50 product page views in 60 days**. Delete it.
   Apple allows 70 pages; a shelf of dead pages is maintenance with no return.
2. Any PPO experiment that has not reached **800 views per cell in 60 days**.
   Stop it and adopt nothing. A truncated experiment is not evidence.
3. The **third event type** if events 1 and 2 did not move taps. Two working
   surfaces beat three untested ones.
4. **Bespoke creative beyond the top seven locales** if those locales show fewer
   than 20 views per week each.
5. The **tier-3 locales' hand-cut screenshots** — tier 3 is machine-translated by
   definition; bespoke art contradicts the tiering.

---

## 9. Cadence

| When | Do |
|---|---|
| Weekly | Read Impressions, page view rate and conversion by territory from Analytics. Do not act on a single week. |
| Weekly | Reply to every new review. |
| Every version | Re-cut screenshots for the winning lead frame. Re-run `grow.mjs submit --audit` to see the live page against the checks. |
| Monthly | Create or expire an in-app event so the page is never stale. |
| Quarterly | Run the §8 cut list. Delete pages, stop experiments, drop locales. |

---

## 10. Runbook

In order, dry by default, `--apply` to write:

```bash
node scripts/asc/verify.mjs                                  # live state, read-only
node scripts/asc/grow.mjs status                             # growth dashboard, read-only
node scripts/asc/grow.mjs submit --audit                     # what the live page is missing
node scripts/asc/media.mjs status                            # library + manifest diff
node scripts/asc/media.mjs upload --manifest store/creative/manifest.json   # dry run
node scripts/asc/grow.mjs cpp                                # dry run, prints every request
node scripts/asc/grow.mjs ppo                                # dry run
node scripts/asc/grow.mjs events                             # dry run
node scripts/asc/grow.mjs submit                             # refuses, names every gap
```

Every command prints the exact method, path and body it would send. Nothing
writes without `--apply`. Re-running after a successful apply reports "already
present" and sends nothing.
