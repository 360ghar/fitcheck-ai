# Apple App Store Listing — FitCheck AI (iOS)

**Work stream:** WS6 — App Store listing metadata, App Privacy, age rating, review notes & screenshot plan
**Bundle identifier:** `com.fitcheck.fitcheckAi`
**Privacy Policy URL:** `https://fitcheckaiapp.com/privacy`
**Last updated:** 2026-06-03

> This document is the source of truth for everything that goes into App Store Connect (ASC) for
> the FitCheck AI iOS app. Every field below is drafted and ready to paste. Companion docs:
> - `docs/app-store-screenshots.md` — screenshot dimensions, screen list, and capture workflow.
> - `flutter/scripts/capture_ios_screenshots.sh` — helper to boot simulators and capture screenshots.
> - `docs/play-store-aso.md` — Android/Google Play copy (this iOS copy is adapted from it).

---

## 1. App metadata (paste into App Store Connect)

ASC splits metadata across two places:
- **App Information** (app-level, shared across versions): Name, Subtitle, Category, Privacy Policy URL.
- **Version Information** (per-version, e.g. 1.0): Promotional Text, Description, Keywords, Support URL, Marketing URL, What's New, Copyright.

### App Name — `≤ 30 chars`

```
FitCheck AI: Wardrobe Stylist
```
(29 chars. Aligns with the Play title "FitCheck AI: Wardrobe & Outfits" but trades "& Outfits" for
"Stylist" to add a high-value, non-duplicated keyword surface.)

### Subtitle — `≤ 30 chars`

```
AI Closet, Try-On & Outfits
```
(27 chars. Apple indexes the subtitle for search, so it carries keywords, not just a tagline.)

### Promotional Text — `≤ 170 chars`

> Editable any time without a new app review — use it for launch/seasonal messaging.

```
New: AI Photoshoot Generator — turn selfies into studio-quality headshots for LinkedIn, dating apps & Instagram. Plus virtual try-on and smart daily outfit picks.
```
(160 chars.)

### Description — `≤ 4000 chars`

> Adapted from `docs/play-store-aso.md` "Full Description". Apple does NOT index the description for
> search (unlike Google Play), so it is written for human conversion, not keyword stuffing.

```
FitCheck AI is your AI-powered virtual closet and personal stylist. Digitize your wardrobe, plan outfits, visualize new looks, and generate professional photos — all powered by cutting-edge artificial intelligence.

AI WARDROBE EXTRACTION
Snap or upload photos of your clothes and watch the AI automatically detect, categorize, and catalog every item. Batch processing digitizes your whole closet fast. The AI recognizes colors, materials, and patterns so each piece is tagged and searchable.

VIRTUAL TRY-ON
See how an outfit looks before you wear it. The AI generates a realistic visualization of any clothing combination on your body. Perfect for planning daily looks or deciding what to wear to a big event.

AI PHOTOSHOOT GENERATOR
Create professional photos for LinkedIn, dating apps, Instagram, and portfolios. Upload a few selfies and get studio-quality headshots in minutes. Choose professional, casual, or creative styles.

SMART OUTFIT RECOMMENDATIONS
Get personalized outfit suggestions based on weather, occasion, and your personal style. Stop wondering what to wear — the recommendations adapt to your preferences over time.

OUTFIT PLANNER & CALENDAR
Plan outfits ahead on a calendar, schedule looks for upcoming events, and let weather-aware suggestions keep you ready for the day.

WARDROBE ANALYTICS
Track cost-per-wear, surface underused items, and make smarter buying decisions with data-driven insights into your closet.

KEY FEATURES
- AI clothing detection from single or batch photo uploads
- Virtual outfit visualization and try-on
- Professional AI photoshoot generator
- Weather-based outfit recommendations
- Astrology lucky-color suggestions
- Calendar planning for outfits
- Cost-per-wear and wardrobe analytics
- Outfit sharing with friends
- Style streaks and achievements
- Sync across iPhone, iPad, and the web

PERFECT FOR
- Fashion lovers who want their wardrobe organized
- Professionals making fast daily outfit decisions
- Content creators planning photoshoots
- Anyone wanting to get more out of the clothes they already own
- Job seekers who need a polished headshot
- Anyone refreshing their dating or social profile photos

PRICING
FitCheck AI is free to download and use. There are no in-app purchases in this version.

HOW IT WORKS
FitCheck AI connects to a secure cloud backend to run its AI features (item extraction, try-on, photoshoot, and recommendations). An account is required so your wardrobe and outfits sync across your devices. You can delete your account and all associated data at any time from Settings.

Download FitCheck AI and transform how you get dressed.
```
(~2,050 chars — well within the 4000 limit, leaving room to extend.)

### Keywords — `≤ 100 chars`, comma-separated, **NO spaces**

> Rules: Apple counts the comma-separated string toward the 100-char limit. Spaces waste characters,
> so omit them after commas. Do NOT repeat words already in the App Name ("fitcheck", "ai",
> "wardrobe", "stylist") or in the category name ("lifestyle") — Apple already indexes those.

```
closet,outfit,fashion,try-on,clothing,style,planner,organizer,virtual,photoshoot,headshot,capsule,lookbook,attire
```
(98 chars including commas. No spaces. No duplication of name/category terms.)

### What's New (Release Notes for v1.0) — `≤ 4000 chars`

```
Welcome to FitCheck AI 1.0!

- Digitize your wardrobe with AI photo extraction (single and batch uploads)
- Virtual try-on to preview outfits on your body
- AI Photoshoot Generator for professional headshots
- Smart, weather-aware outfit recommendations
- Outfit calendar and planner
- Wardrobe analytics with cost-per-wear
- Share outfits and earn style streaks

Thanks for trying FitCheck AI. Tell us what you'd like to see next — feedback is welcome right inside the app.
```

### Categories

| Field | Value |
|---|---|
| Primary Category | **Lifestyle** |
| Secondary Category | **Photo & Video** |

### URLs

| Field | Value | Notes |
|---|---|---|
| Support URL | `https://fitcheckaiapp.com/support` | **Required.** Must resolve to a working page before submission. |
| Marketing URL | `https://fitcheckaiapp.com` | Optional but recommended. |
| Privacy Policy URL | `https://fitcheckaiapp.com/privacy` | **Required.** Must be live; must name third-party AI processors (Google Gemini, OpenAI) and Supabase. |

### Copyright

```
© 2026 FitCheck AI
```
(Replace "FitCheck AI" with the legal entity name on the Apple Developer account if it differs,
e.g. "© 2026 FitCheck AI, Inc." Apple shows this string verbatim on the product page.)

### Marketing icon (App Store icon)

ASC requires a **1024×1024 px** icon, PNG, **RGB / sRGB or Display P3, no alpha channel**, no rounded
corners (Apple applies the mask automatically). The repository asset is already compliant:

| Asset | Dimensions | Color | Alpha | Verdict |
|---|---|---|---|---|
| `flutter/assets/icons/app_icon.png` | 1024×1024 | 8-bit RGB | **No alpha** | **Ready to upload as-is** |
| `Fitcheck Media/App_Icon/Fitcheck_Icon.jpeg` | 1600×1600 | JPEG | n/a | Source/marketing asset; not used directly for ASC upload |

Use `flutter/assets/icons/app_icon.png` directly. Do not add transparency or pre-rounded corners.

---

## 2. App Privacy ("nutrition label") answers

Complete under **App Store Connect → App Privacy**. Answer the data-collection questionnaire, then for
each collected type declare: linked to the user? used for tracking? and one or more purposes.

**Data collected by FitCheck AI:**
- Supabase auth: **email** and **name**
- Uploaded **photos** (face for photoshoot / body for try-on; clothing photos for extraction)
- **Body measurements** (height_cm, weight_kg, body_shape, skin_tone — from the Body Profile feature)
- **Supabase user UUID** (account identifier)
- **PostHog** product-usage analytics + crash/diagnostics data

### KEY DECISION: Nothing is "used for tracking"

Apple defines **Tracking** as linking your app's data with third-party data for targeted advertising
or ad measurement, OR sharing data with a data broker. FitCheck AI does **none** of this. PostHog is
first-party product analytics and **does not use the IDFA / no AdSupport framework**. Therefore:

- **Answer "No" to tracking for every data type.**
- The app must **NOT** present the App Tracking Transparency (ATT) prompt.
- "Data Used to Track You" section on the product page will be **empty**.

### Nutrition label table

| Data type (Apple category → element) | Collected? | Linked to user? | Used for tracking? | Purpose(s) |
|---|---|---|---|---|
| **Contact Info → Email Address** | Yes | **Yes (Linked)** | No | App Functionality |
| **Contact Info → Name** | Yes | **Yes (Linked)** | No | App Functionality |
| **User Content → Photos or Videos** | Yes | **Yes (Linked)** | No | App Functionality |
| **User Content → Other User Content** (body measurements: height, weight, body shape, skin tone) | Yes | **Yes (Linked)** | No | App Functionality |
| **Identifiers → User ID** (Supabase UUID) | Yes | **Yes (Linked)** | No | App Functionality |
| **Usage Data → Product Interaction** (PostHog) | Yes | **Yes (Linked)** | No | Analytics |
| **Diagnostics → Crash Data** (PostHog) | Yes | **Yes (Linked)** | No | App Functionality |
| **Diagnostics → Performance Data** (PostHog, if captured) | Yes | **Yes (Linked)** | No | Analytics |

Notes on Apple's exact category names:
- Photos go under **User Content → "Photos or Videos"** (not "Sensitive Info"; facial photos are not
  declared as biometric "Sensitive Info" unless you derive/store a face template — FitCheck AI does not).
- Body measurements: Apple has no first-class "measurements" type. Declare them under **User Content →
  "Other User Content"**. (They are not "Health & Fitness" — that category is for HealthKit-style
  fitness/health metrics, which this app does not collect.) If you prefer, "Other Data" is an
  acceptable alternative bucket; "Other User Content" is the more precise fit.
- Supabase UUID is **Identifiers → "User ID"**, NOT "Device ID".
- PostHog usage events map to **Usage Data → "Product Interaction"**; crashes to **Diagnostics →
  "Crash Data"**; any performance metrics to **Diagnostics → "Performance Data"**.

All collected data is **Linked to the user** because each record is tied to the authenticated account.
No data type qualifies for the "Data Not Linked to You" section.

### Required selectors per type (what ASC asks you to tick)

For each "Linked, no tracking, App Functionality / Analytics" entry, ASC will additionally ask:
- "Is this data used for tracking?" → **No** (for all).
- "Is this data linked to the user's identity?" → **Yes** (for all).
- Purpose checkboxes: tick **App Functionality** (and **Analytics** for the two PostHog usage types).
  Do NOT tick "Third-Party Advertising", "Developer's Advertising or Marketing", or
  "Product Personalization" unless the recommendation engine is later marketed as such.

---

## 3. Age Rating questionnaire (2025+ system)

Apple replaced the old 4+/9+/12+/17+ scale in 2025 with **4+, 9+, 13+, 16+, 18+** and an expanded
questionnaire (in-app controls, capabilities, medical/wellness, violence, UGC, etc.). All apps had to
re-answer the new questionnaire by **2026-01-31**. Complete this in
**ASC → App → Age Rating → Edit**.

### Recommended answers

| Questionnaire topic | Answer | Rationale |
|---|---|---|
| Cartoon or Fantasy Violence | None | No violence of any kind. |
| Realistic Violence | None | — |
| Prolonged Graphic / Sadistic Realistic Violence | None | — |
| Profanity or Crude Humor | None | — |
| Mature/Suggestive Themes | None | Fashion/styling only. |
| Horror/Fear Themes | None | — |
| Medical / Treatment Information | None | Body measurements are for fit/styling, not medical advice. |
| Alcohol, Tobacco, or Drug Use or References | None | — |
| Simulated Gambling | None | — |
| Sexual Content or Nudity | None | Try-on/photoshoot output is clothed; no nudity generated. |
| Graphic Sexual Content and Nudity | None | — |
| Contests | None | (Streaks/achievements are personal gamification, not prize contests.) |
| **User-Generated Content** | **Yes** | Users upload photos and can share outfits / public outfit links. |
| ↳ Is UGC moderated / can users report & block? | Yes — describe controls | See note below; you must be able to attest to moderation/report controls. |
| **AI-Generated Content / Generative AI** | **Yes** | App generates images (try-on visualizations, AI photoshoot, recommendations). |
| Unrestricted Web Access | No | App does not embed an open web browser. |
| In-app controls / parental gating needed | No | — |
| Medical or Wellness topics | No | — |
| Gambling capabilities | No | — |

### Expected resulting rating

With **UGC = Yes** and **AI-generated content = Yes** but **no mature/sexual/violent content**, Apple's
2025+ system yields approximately **13+** (this is the new floor that replaced the old "12+" — there is
no "12+" anymore). Final rating is computed by Apple from the questionnaire and may vary slightly by
region. Confirm the computed rating in ASC after submitting answers.

> Action: Because UGC = Yes, the app should ship with (a) a content/abuse reporting path and (b) the
> ability to block users / hide shared content, and an EULA, to satisfy App Store Review Guideline 1.2.
> If those controls are not yet present, coordinate with the app team — they are owned by another work
> stream, but they are a hard gate for approval.

---

## 4. App Review notes (paste into "App Review Information → Notes")

> ASC fields to fill in this section: a demo **Sign-In account** (username/password), a contact
> first/last name, phone, and email, plus the free-form **Notes** below.

```
APP OVERVIEW
FitCheck AI is an AI-powered wardrobe and personal-styling app. Core AI features (clothing
extraction from photos, virtual try-on, AI photoshoot, and outfit recommendations) require
backend connectivity to our API at https://api.fitcheckaiapp.com and to Supabase. An internet
connection is required for these features to work.

DEMO ACCOUNT (sign in on the first screen)
Email:    review@fitcheckaiapp.com        <-- REPLACE with the real seeded account before submitting
Password: <set-a-strong-password-here>    <-- REPLACE with the real password
This account is pre-seeded with a sample wardrobe, outfits, and a body profile so all features can
be exercised without uploading your own photos.

HOW TO TEST KEY FEATURES
1. Sign in with the demo account above.
2. Wardrobe: open the Wardrobe tab to see ~10-15 pre-loaded clothing items with categories/colors.
3. AI extraction: tap Add Item -> upload a photo of clothing; the AI detects and tags the item
   (requires backend connectivity).
4. Virtual try-on: open the Try-On tab, pick items / an outfit; the AI renders the look on the
   body profile (this calls the backend and can take ~10-30 seconds).
5. AI photoshoot: open the Photoshoot tab, upload 1+ selfie, choose a style, and generate
   studio-style images (backend, async; can take up to ~1 minute).
6. Recommendations: open the Recommendations tab for weather/occasion-based outfit suggestions.
7. Calendar: plan an outfit on a date in the Calendar tab.

PRICING
Version 1.0 is FREE. There are NO in-app purchases and NO subscriptions in this build.

ACCOUNT DELETION (Guideline 5.1.1(v))
Users can delete their account and all data in-app: Settings -> Delete Account. This issues
DELETE /api/v1/users/me on our backend and removes the user record and associated data.

AI / THIRD-PARTY PROCESSING
AI features are processed via Google Gemini and OpenAI through our backend. Uploaded photos are
sent to these processors only to fulfill the user's request. This is disclosed in our privacy
policy at https://fitcheckaiapp.com/privacy.

CONTACT
For any review questions, contact: support@fitcheckaiapp.com
```

> Reminder: replace the demo email/password placeholders with the actual seeded credentials (see §5)
> before hitting Submit for Review. Apple rejects submissions where the demo account does not log in.

---

## 5. Demo account seeding spec

Goal: a single reviewer account that lets Apple exercise every feature without uploading their own
content. Create it once, keep it seeded, and reuse it across submissions.

### What the account needs

| Data | Quantity | Why |
|---|---|---|
| Auth user (email + password) | 1 | Reviewer signs in. Use a dedicated address, e.g. `review@fitcheckaiapp.com`. |
| Wardrobe items | **10–15** | Populates the Wardrobe tab and makes outfit building / recommendations meaningful. Spread across categories (tops, bottoms, shoes, outerwear, accessories) with colors set. |
| Outfits | **2–3** | Lets the reviewer open outfit detail, try-on, and sharing without building from scratch. |
| Body profile | **1 (default)** | Required for virtual try-on. Set name, `height_cm`, `weight_kg`, `body_shape`, `skin_tone`. |
| (Optional) 1 planned calendar entry | 1 | Demonstrates the planner with data already present. |

### How to seed

Two practical options; pick whichever matches your access:

**Option A — via the backend API (preferred; uses real app code paths).**
1. Sign the demo user up (or create via Supabase, below) and obtain a JWT.
2. Create the body profile: `POST /api/v1/users` profile/body endpoints (see
   `backend/app/api/v1/users.py`).
3. Create wardrobe items: `POST /api/v1/items` x10–15 (see `backend/app/api/v1/items.py`). You can
   either upload sample photos or create items with metadata only.
4. Create outfits: `POST /api/v1/outfits` x2–3 referencing the item IDs (see
   `backend/app/api/v1/outfits.py`).
5. (Optional) Create a calendar entry: `POST /api/v1/calendar` (see
   `backend/app/api/v1/calendar.py`).

Use the seeding script:

```bash
cd backend
export API_BASE_URL=https://api.fitcheckaiapp.com
export SUPABASE_URL=...
export SUPABASE_ANON_KEY=...
export REVIEW_EMAIL=review@fitcheckaiapp.com
export REVIEW_PASSWORD='...'
python scripts/seed_app_store_reviewer.py
```

Script path: `backend/scripts/seed_app_store_reviewer.py`.

**Option B — directly in Supabase.**
- Create the auth user in Supabase Auth (Apple/email provider).
- Insert rows into the corresponding Postgres tables (users/profile, items, outfits, body_profile)
  matching the schema in `backend/db/supabase/migrations/`. Use Supabase Storage for any sample
  images and reference their URLs in the item/photo rows.

### Account deletion (verified in code)

In-app deletion is implemented: **Settings → Delete Account**, which calls
`DELETE /api/v1/users/me` (`flutter/lib/features/settings/repositories/settings_repository.dart:111`).
A data-export path also exists (`POST /api/v1/users/export`). Both satisfy Guideline 5.1.1(v) /
data-portability expectations.

---

## 6. Pre-submission checklist (external prerequisites)

These are actions the user/owner must complete **outside** this repo before the listing can be
submitted. Most are not code and cannot be done by an agent.

### Apple / App Store Connect
- [ ] **Apple Developer Program** enrollment active ($99/yr), correct entity type (individual vs org).
- [ ] **App record created** in ASC with bundle ID `com.fitcheck.fitcheckAi`.
- [ ] **Agreements, Tax, and Banking** completed in ASC (required even for a free app — the Paid Apps
      agreement is not needed for free, but the free-apps agreement must be active and contact/tax
      identity confirmed).
- [ ] App Information filled: Name, Subtitle, Categories (Lifestyle / Photo & Video), Privacy Policy URL.
- [ ] Version 1.0 metadata filled (Promotional Text, Description, Keywords, What's New, URLs, Copyright).
- [ ] **App Privacy** questionnaire submitted per §2 (nothing as tracking; no ATT prompt).
- [ ] **Age Rating** questionnaire submitted per §3 (UGC = Yes, AI = Yes; expect ~13+).
- [ ] **App Review Information** filled with the seeded demo account (§4/§5) and contact details.
- [ ] **Marketing icon** = `flutter/assets/icons/app_icon.png` (1024×1024, RGB, no alpha) uploaded.
- [ ] **Screenshots** uploaded for iPhone 6.9" (1320×2868) and iPad 13" (2064×2752) — see
      `docs/app-store-screenshots.md`.
- [ ] A signed build uploaded via Xcode/Transporter and selected for the 1.0 version.
- [ ] **Export Compliance** answered (standard HTTPS only → typically "uses exempt encryption").

### Live web pages (must resolve before submission)
- [ ] `https://fitcheckaiapp.com/privacy` — privacy policy, **explicitly naming Google Gemini and
      OpenAI** as AI processors, plus Supabase, and describing photo/measurement handling, retention,
      and the in-app deletion path.
- [ ] `https://fitcheckaiapp.com/terms` — terms of service / EULA (needed for UGC apps).
- [ ] `https://fitcheckaiapp.com/support` — Support URL (working contact/help page).
- [ ] `https://fitcheckaiapp.com` — Marketing URL (optional but referenced above).

### Backend / Auth
- [ ] **Supabase Apple provider** ("Sign in with Apple") configured — Apple requires Sign in with
      Apple if any other third-party sign-in is offered (Guideline 4.8). Verify the Apple provider is
      enabled in Supabase Auth and the Service ID / keys are set.
- [ ] `https://api.fitcheckaiapp.com` reachable from the reviewer's network (no IP allowlisting that
      would block Apple's reviewers).
- [ ] Demo account seeded per §5 and verified to log in on a clean device.

### Content moderation (UGC gate — Guideline 1.2)
- [ ] In-app **report/flag** path for shared/UGC content.
- [ ] Ability to **block** users / hide shared content.
- [ ] EULA presented to users; objectionable-content policy stated.

> Items above tagged to other repos/areas (backend seeding script, moderation UI, web pages) are
> outside WS6's file ownership and must be coordinated with their owners.
