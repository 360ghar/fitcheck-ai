# User Stories — Full Platform Audit (2026-08-03)

Authoritative consolidation of every user story derived from the code during the
`2026-08-03-full-flow-hardening` audit, plus the verification status and the
master findings register. Companion to the existing
[user-story-ledger.md](./user-story-ledger.md) (which tracks product-intent
stories); this doc records the **code-derived platform stories** each agent
traced, in one place, so the test phase can verify each one.

Coverage: `frontend/` (web), `flutter/` (mobile), `backend/` (API). Written by
13 parallel verification agents + 2 read-only gap audits, consolidated by the
orchestrator on 2026-08-03.

Legend: ✅ = verified (code trace + tests), ⚠️ = behavior differs from intent /
edge case documented, ⏳ = deferred to fix phase.

---

## 1. Web — Marketing & Public

| ID | Feature / route | User story (actor → action → expected) | Status |
|----|-----------------|------------------------------------------|--------|
| W-1 | Landing `/` | Visitor sees value prop + real plan numbers; "Start free" → `/auth/register`; Android → Play Store; iOS → waitlist note | ✅ |
| W-2 | Landing sections `/`#demo/#pricing/#faq | Nav hash links scroll on home, navigate elsewhere; demos run unauthenticated with rate-limit + error + retry states | ✅ |
| W-3 | Waitlist form | Email/name → success; duplicate → friendly error; disabled while empty | ✅ |
| W-4 | Pricing `/`#pricing | 3 tiers, real prices, monthly/yearly toggle, CTA carries `plan_type` | ✅ |
| W-5 | FAQ landing + `/faq` | Accordion opens/closes; JSON-LD schema; links to comparisons | ✅ |
| W-6 | Features index + 5 feature pages | Cards link to real routes; each renders from `featurePageContent`; CTAs → register | ✅ |
| W-7 | SEO intent pages `/best`,`/compare`,`/alternatives`,`/for`,`/guides`,`/wear/:city` | `IntentSeoPage` resolves path → content or redirect home; all routes covered | ✅ |
| W-8 | Cost-per-wear calculator | Live CPW math; **decimal entry works** (was snapping `49.99`→`4999`, fixed) | ✅ |
| W-9 | Blog index `/blog` + `/blog/category/:c` | Category filter, search, 12/page pagination, loading/error/empty states | ✅ |
| W-10 | Blog post `/blog/:slug` | Loader, 404 vs error, article render, related posts | ✅ |
| W-11 | Public pages (About/Terms/Privacy/Support/FAQ) | Static content, correct canonical URLs, email links, register CTA | ✅ |
| W-12 | Public layout/nav/footer | Auth-aware nav + footer links; skip link; mobile sheet; no fake social icons | ✅ |
| W-13 | LoginPromptModal (demo CTA) | Promises what it delivers (was falsely claiming "result stays ready after signup", fixed) | ✅ |

## 2. Web — Auth

| ID | Feature / route | User story | Status |
|----|-----------------|------------|--------|
| W-14 | Register `/auth/register` | Email+password → POST `/auth/register`; tokens → destination; no-tokens (email confirm) → toast + `/auth/login?plan_type&returnTo`; referral toast; inline error, cleared on mount | ✅ |
| W-15 | Login `/auth/login` | Success → destination; failure → inline `Invalid email or password` / `Email not confirmed`; double-submit guarded | ✅ |
| W-16 | Google OAuth (login & register) | Stashes `pending_plan_type`/`promo`/`return_to` (idempotent) → callback → oauth/sync → destination; failure → login after 3s | ✅ |
| W-17 | Forgot password | POST reset; always "If an account exists…" (enumeration-safe); works while signed-in (not under PublicRoute) | ✅ |
| W-18 | Reset password `/auth/reset-password#tokens` | Parses tokens, strips from URL, POST confirm; client-side strength mirror matches backend; double-submit guarded; success → login after 800ms | ✅ |
| W-19 | Auth callback `/auth/callback` | `handleOAuthCallback` fires once (StrictMode guard); syncs profile; navigate destination | ✅ |
| W-20 | Redirect-after-login | `getPostAuthDestination`: validated internal `returnTo` wins; else promo/plan → `/profile?tab=plan`; else `/dashboard`; open-redirect safe | ✅ |
| W-21 | Hydration + session persistence | Rehydrates → guards stop spinners; `/users/me` refreshes user (silent fail) | ✅ |
| W-22 | Forced logout on 401 | Interceptor single-flight refresh once; failure → `forceLogout` → login?returnTo (guards `/auth/*`) | ✅ |
| W-23 | Manual logout | POST logout (best-effort), clear tokens, → login | ✅ |
| W-24 | OAuth sync cross-user risk | A 401 on `/auth/oauth/sync` no longer retries with the wrong app token (`_skipAuth`) — **P1 fixed** | ✅ |

## 3. Web — Dashboard & Onboarding

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| W-25 | First-run dashboard | New user → "Welcome, {name}" + activation checklist (4 steps) + "How it works"; stats hidden (`isEmpty`) | ✅ |
| W-26 | Activation checklist | Row → opens upload/navigates; completion auto-checks steps; optional avatar/photo-of-you; auto-hides when core complete | ✅ |
| W-27 | Returning-user dashboard | "Welcome back"; 4 StatCards (Total Items / Outfits Created / Total Wears / Favorites) linking to sections; AI tools + Quick actions + Recent items | ✅ |
| W-28 | Dashboard stat cards | Count cards use **server totals** (was showing first-24 page size, fixed) | ✅ |
| W-29 | Referral banner | Dismissible 7 days (per-user key, fixed); near-limit → urgent, not dismissible; copy/share with clipboard fallback | ✅ |
| W-30 | Live job status (JobPill) | Upload → pill persists across routes; reopen restores flow; resolves → clearJob | ✅ |
| W-31 | Dashboard CTA destinations | Add Item → upload modal; Create Outfit → `/outfits/new`; What to wear → `/recommendations`; AI tools → each feature | ✅ |
| W-32 | Dashboard error state | Friendly copy, no raw backend body (was leaking, fixed); usage loaded on mount so banner escalates | ✅ |

## 4. Web — Wardrobe (Closet)

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| W-33 | Browse closet `/wardrobe` | Masonry grid, header count, category chips, search/filter/sort, Load-more; **first frame shows skeleton, never false "empty"** (`hasLoaded`, fixed) | ✅ |
| W-34 | Filter/sort | Search client-side instant; category/color/condition/favorites refetch server-side; active-filter badges; Clear All resets | ✅ |
| W-35 | Open detail | Card → split pane (desktop)/sheet (mobile); hero, spec sheet, cost-per-wear ledger, notes, extra photos; URL-driven selection | ✅ |
| W-36 | Edit item | Inline form patches in place (no list blink); failed save keeps form | ✅ |
| W-37 | Favorite/worn/delete/bulk | Single API + in-place patch; delete confirm; bulk select + bulk delete; deleting open item closes pane | ✅ |
| W-38 | Batch add | Select 1–50 → compress → multipart upload → SSE extraction → review → save (per-item retry, source-photo fallback) → auto-outfit per source photo | ✅ |
| W-39 | Batch resilience | SSE reconnect (3×), 45s watchdog, `/status` reconcile, job-lost recovery, capacity → "AI busy" (never upgrade), plan limit → upgrade prompt | ✅ |
| W-40 | Batch cross-route resume | Soft-close → pill → navigate away → reopen restores in-flight job (store-backed, **P1 fixed**) | ✅ |
| W-41 | Cancel mid-batch | "Upload Different Images" from review **cancels the server job** (was burning quota, fixed) | ✅ |
| W-42 | Social import | URL → job → auth (Meta popup/scraper) → progress → review queue (approve/reject/edit) → save + auto-outfit; resumes across mounts | ✅ |
| W-43 | Cost-per-wear ledger | `price/wears` or `paid` or `times worn` — no NaN/Infinity | ✅ |
| W-44 | Favorites filter URL sync | Toggling favorites persists to URL (was resetting on remount, fixed) | ✅ |

## 5. Web — Outfits

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| W-45 | Outfits list `/outfits` | Grid page 1; closet fetched if empty; skeletons; error+retry; empty → add CTAs | ✅ |
| W-46 | Outfits filter/sort | Style/season/search/favorite to API; `useFilteredOutfits()` selector; URL-selectedId drives detail pane | ✅ |
| W-47 | Outfit detail | Hero, wear ledger, pieces; Back clears id | ✅ |
| W-48 | Generate/regenerate look | `startGeneration` → backend registers → client AI → upload → completed; failed → Retry | ✅ |
| W-49 | Create outfit preview | Draft meta + item rails + **real garment preview** (`item_id` sent, **P1 fixed**) → save attaches approved bytes | ✅ |
| W-50 | Auto-generation after save | Fire-and-forget; card shows spinner → image or failed tile; failed card opens detail (was unopenable, fixed) | ✅ |
| W-51 | Outfit from photo | `createOutfitFromSavedItems` groups by source, tags `from-upload`, uses source photo | ✅ |
| W-52 | Share outfit | Dialog → social/copy/download; **share-link cache invalidated on option change** (fixed); download is blob (was navigating away, fixed) | ✅ |
| W-53 | Quota exhaustion | 429 → upgrade prompt (now fires even in preview flow, fixed) | ✅ |

## 6. Web — Recommendations / Calendar / Gamification

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| W-54 | Recs no-closet | Today/Match show "Add clothes first" CTA; Complete Look "add items"; Weather/Astro/Shopping usable | ✅ |
| W-55 | Recs closet-loading | Skeleton while closet loads (was blank, fixed); first-frame empty-flash suppressed | ✅ |
| W-56 | Recs Today (weather) | Auto-fires weather; temp/category badges, notes, clean items; Refresh; Save-as-outfit (guarded, fixed); Try-on/Complete-look links; failure → inline note | ✅ |
| W-57 | Recs Find Matches | Search → select item → match results + looks; **results cleared on selection change** (stale results fixed) | ✅ |
| W-58 | Recs Complete Look | Multi-select → generate → suggestion cards; client fallback on empty; "No outfit suggestions" after failed attempt | ✅ |
| W-59 | Recs Astrology | Mode + date → colors; `profile_required` → Complete Profile CTA; superseded requests dropped; **arrays defensive-guarded** (crash fixed) | ✅ |
| W-60 | Recs Shopping | Category/style/budget → suggestions with priority badges; analytics events | ✅ |
| W-61 | Calendar month load | Mount loads current month; prev/next; **rapid-click race fixed** (stale month no longer stranded); error+retry; empty month message | ✅ |
| W-62 | Calendar create event | Tap day → dialog pre-filled 09:00–10:00; validates title + end>start; appends locally | ✅ |
| W-63 | Calendar event details | Time range (localized), description, assigned outfit or "No outfit assigned"; Assign/Change/Remove | ✅ |
| W-64 | Calendar assign outfit | Picker → POST → optimistic update; failures toasted; dialog stays open | ✅ |
| W-65 | Calendar weather widget | Location from settings/geolocation; per-day chips (current conditions); single-flight; failure degrades, never crashes; **honest spinner** (was fake progress) | ✅ |
| W-66 | Calendar connect | "Enable local calendar" → `local` provider; external sync explicitly not implemented | ✅ |
| W-67 | Gamification flag-off | Route + lazy import gated; bookmarked `/gamification` → dashboard; chunk not emitted | ✅ |
| W-68 | Gamification flag-on | Streak/achievements/leaderboard in parallel; any failure → error card; zero-data empty states; podium + "You" row | ✅ |

## 7. Web — Profile / Settings / Subscription / Admin / Shared

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| W-69 | Avatar upload | Picker → uploadAvatar → merged against live store (no stale-profile resurrection) → toast | ✅ |
| W-70 | Edit profile | Fields → update → re-fetch; partial-save warning for skipped birth fields | ✅ |
| W-71 | Style preferences | Load (cancelled on fast switch) → chips → save → toast; error → inline + retry | ✅ |
| W-72 | App settings | Toggle → dirty-flag → save; in-flight-edit detection prevents silent overwrite; theme selector brand | ✅ |
| W-73 | Security/password | "Send Password Reset Email" → request → toast | ✅ |
| W-74 | Delete account | Confirm dialog (locked) → delete → logout → login; single-step confirm (type-to-confirm deferred, design choice) | ✅ |
| W-75 | Plan display + upgrade | Fetch sub/usage/referral/plans → plan card; Plus=paid but sees Pro upsell; Free sees Plus+Pro | ✅ |
| W-76 | Promo validate→redeem | Code / `?promo=` → validate → banner → redeem → refresh; **failure now shows inline** (was silent, fixed) | ✅ |
| W-77 | Stripe checkout return | `/profile?tab=plan&success=true` → **toast + param strip** (params were never consumed, fixed) | ✅ |
| W-78 | Upgrade prompt | Single mounted dialog; capacity → "try again", never upsell; closes after in-place upgrade (fixed) | ✅ |
| W-79 | Sidebar ↔ bottom nav | Desktop sidebar (collapsed persisted), mobile bottom nav; active via pathname prefix; tooltips when collapsed | ✅ |
| W-80 | Theme persistence | Seeds from localStorage; pre-hydration script; system-pref listener; theme-color meta | ✅ |
| W-81 | Error boundaries | Feature routes wrapped (`/profile`+`/dashboard` now included, fixed); crash → inline card; global boundary last resort | ✅ |
| W-82 | Shared outfit (public) | GET public → hero/badges/items; bad/expired → "Outfit not available"; `returnTo` preserved | ✅ |
| W-83 | Blog admin | List with filters/pagination/delete-confirm; editor RTE + markdown preview (HTML-escaped); dashboard stats; categories | ✅ |
| W-84 | One-toast guarantee | Checkout/portal/cancel/promo failures fire ONE toast (was 2×, fixed) | ✅ |

## 8. Backend — API surface

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| B-1 | Register | 201; creates auth user + profile/preferences/settings (upsert); referral code; tokens or email-confirm empty; IP-limited 5/hr | ✅ |
| B-2 | Login | 200; password auth; auto-provisions missing profile; IP-limited 10/hr | ✅ |
| B-3 | Refresh | 200; dedup service (prevents "Already Used" race) | ✅ |
| B-4 | Logout | 204; best-effort sign-out | ✅ |
| B-5 | Reset password | Always 200 (anti-enumeration); recovery-link session + update; IP-limited | ✅ |
| B-6 | OAuth sync | 200; idempotent profile create/update; referral; `is_new_user` | ✅ |
| B-7 | Users CRUD / avatar / body-profile | Ownership-scoped; delete cascades storage+vectors+rows then auth user | ✅ |
| B-8 | Dashboard aggregate | Counts, recent activity, weather/outfit-of-day suggestions | ✅ |
| B-9 | Items CRUD + upload + favorite/wear/categorize + duplicate + similar | Ownership-scoped; embeddings best-effort with daily-quota reserve/release | ✅ |
| B-10 | Outfits CRUD + collections + share + wear + duplicate + images | Ownership-scoped; membership validated; share upsert idempotent | ✅ |
| B-11 | Outfits public | `is_public=true` only; view-count; expiry | ✅ |
| B-12 | Subscription + Stripe | Plan/usage/plans; checkout (store-billed fails closed); webhook signature+dedup+CAS | ✅ |
| B-13 | IAP (Apple/Google) | Provider-verified entitlement only; product cross-check; webhook dedup; 500 on failure → store retries | ✅ |
| B-14 | Referral + Promo | Get-or-create code; atomic redeem; one redemption/user; paid never overwritten | ✅ |
| B-15 | Feedback | ≤5 attachments, ≤5MB; IP-limited; auth-optional | ✅ |
| B-16 | Weather / Calendar / AI-settings | OpenWeather mock fallback; CRUD scoped; provider configs encrypted + keys masked; test 200 | ✅ |
| B-17 | Shared-outfit feedback | IP-limited; rating 1–5; respects allow_feedback + expiry (410) | ✅ |
| B-18 | Gamification | Flag-off → neutral 200 (never 404); flag-on reads with zeroed fallback | ✅ |
| B-19 | Waitlist / Demo | IP-limited; bounded payloads; AI service closed in finally (**leak fixed**) | ✅ |
| B-20 | Health/Ready | `/health` liveness; `/ready` 5-min-cached schema check fail-closed (**stripe_webhook_events added, fixed**) | ✅ |
| B-21 | **Route shadowing** | `/items/stats`, `/search`, `/outfits/stats`, `/favorites`, `/recently-worn` were 422-dead; now live (`:uuid` converter) — **P1 fixed** | ✅ |
| B-22 | **Search-term injection** | `.or_` filters sanitized (mirrors blog.py) — **P1/P2 fixed** | ✅ |

## 9. Backend — AI / batch / job pipelines

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| B-23 | Batch extraction | 202 + job_id; atomic quota reservation; durable row; parallel extraction; SSE per-image; overlap generation; terminal event; TTL cleanup | ✅ |
| B-24 | Batch SSE | Connected → progress → terminal; 30s heartbeat; slow-client drop; **recovered jobs get `job_failed` (never stuck)** | ✅ |
| B-25 | Outfit generation | Monthly rate limit → item-ref resolution → source-photo → agent (input-image cap) → provider fallback → matte → storage | ✅ |
| B-26 | Social import discovery | URL normalize → per-user concurrency (429) → scheduled → paginated discovery (3× retry, caps) | ✅ |
| B-27 | Social import processing | Per-photo extract → generate → review; quota reserve/pause; approve→save+embed; reject→cleanup; capacity→bounded 300s auto-retry | ✅ |
| B-28 | Photoshoot | Daily RPC reservation → durable job → prompts → batched generation (SSE per-image) → unused quota released → terminal | ✅ |
| B-29 | Recommendations/weather/astro | Rule-based match; OpenWeather typed exceptions; astrology deterministic + geocode TTL; embedding reservation released on failed vector search | ✅ |
| B-30 | **Consumer-crash honesty** | Generation consumer crash no longer marks batch COMPLETED; re-raises → FAILED + `job_failed` — **P1 fixed** | ✅ |
| B-31 | **Retry-task survival** | Capacity-retry task strongly referenced (was GC-able mid-sleep, stranding jobs) — **P1 fixed** | ✅ |
| B-32 | **Scraper traceback** | `_instagram_login` uses `logger.exception` (B1 complete) | ✅ |

## 10. Mobile (Flutter) — Core / Auth / Shell

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| F-1 | Boot | No white/light flicker for dark-theme user (theme awaited before runApp, no deadlock) | ✅ |
| F-2 | Session restore | Signed-in → Home; guest → onboarding; gotrue replays initial session | ✅ |
| F-3 | Email/password login | Success → Home; unconfirmed-email → inline re-send | ✅ |
| F-4 | Register | Email-confirm required → "Confirm your email", no fake session | ✅ |
| F-5 | Google OAuth | PKCE deep-link → Home (guest routes cleared) | ✅ |
| F-6 | Apple Sign-In | Native; cancel silent; first-time name persisted | ✅ |
| F-7 | Password reset | Email sends; success snackbar; back after 2s | ✅ |
| F-8 | Logout | Clears state → splash → onboarding | ✅ |
| F-9 | API auth | Bearer token on non-public; **no double interceptor stacks** (guarded) | ✅ |
| F-10 | 401 refresh | One refresh; concurrent 401s share one future; `_retryMarkerKey` prevents loop; unrecoverable → signOut | ✅ |
| F-11 | Error mapping | Timeout/status/connection map to friendly messages; telemetry via showError (not showValidation) | ✅ |
| F-12 | Offline | NetworkService tracks connectivity; consumed by controllers | ✅ |
| F-13 | SSE reconnect | Capped backoff + jitter; terminal events stop loop; clean-end → polling fallback | ✅ |
| F-14 | Theme persist | Survives restart, no flash; backend sync wins online | ✅ |
| F-15 | Secure storage | Supabase session in keychain/keystore; legacy migration | ✅ |
| F-16 | Route order / shell | Static-before-param; IndexedStack keeps tabs alive | ✅ |
| F-17 | Analytics + DI | Route observer; no DI cycles at boot | ✅ |
| F-18 | **AI consent persistence** | Consent key restored from garbage `**********************` — **P1 fixed** (backward compatible) | ✅ |
| F-19 | Image viewer | Zoom/pan/swipe; null-safe drag velocity | ✅ |

## 11. Mobile — Wardrobe / Outfits / Try-on / Photoshoot

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| F-20 | Closet list | Grid 3-col, pull-to-refresh, infinite scroll, debounced filter/search/sort; empty → CTA | ✅ |
| F-21 | Closet stats | `/items/stats` → shimmer → error+Retry → total/value/category bars; **category key fixed** (was all 0) | ✅ |
| F-22 | Add item (AI) | Photo → single-extract SSE phases → review grid → save → back; rate-limit/capacity/network dialogs | ✅ |
| F-23 | Add item (manual) | Form validates → create → **closet list synced** (was stale, fixed) | ✅ |
| F-24 | Edit item | Validates → update → refetch; **category always sent** (was dropped when name unchanged, fixed) | ✅ |
| F-25 | Item detail/delete | Read from list; favorite/worn in place; delete + refetch; **deep-link fetch-by-id** (was infinite spinner, fixed) | ✅ |
| F-26 | Batch extraction | Pick ≤50 → SSE → auto-navigate review → save; bounded polling fallback | ✅ |
| F-27 | Social import | URL → auth → SSE (auth-required/2FA/checkpoint) → review → approve/reject/patch; persisted resume | ✅ |
| F-28 | Outfits list | Dense 2-col grid; modal detail; favorites/filter/collections; pull-to-refresh + infinite scroll | ✅ |
| F-29 | Outfit builder | Rails → tap-select → AI preview → save → **list notified** (was stale, fixed) | ✅ |
| F-30 | Outfit detail/edit/share | Carousel, stats, wear history; edit refetches; share downloads image + sheet | ✅ |
| F-31 | Collections | CRUD; add outfits (paginated); delete | ✅ |
| F-32 | Try-on | Avatar (consent gate) + garment → generate → result + download; single-garment guard; extended timeout; report badge | ✅ |
| F-33 | Photoshoot | Usage check → 4-step wizard → SSE per-image → results grid → per-slot retry → download all → referral/upgrade on limit | ✅ |
| F-34 | Photoshoot usage-failure | Transient failure **no longer locks user out** (usage null → free default, fixed) | ✅ |
| F-35 | Try-on avatar failure | Restores previous avatar + ready flag (was permanently blocked, fixed) | ✅ |

## 12. Mobile — Profile / Settings / Subscription / Calendar / Recs

| ID | Feature | User story | Status |
|----|---------|------------|--------|
| F-36 | Settings load | Prefs → theme sync; shimmer; 404 → defaults | ✅ |
| F-37 | Theme/unit change | Dialog → local + ThemeService + PUT; temp unit C/F | ✅ |
| F-38 | Change password | Validates (≥8, upper, lower, digit, match) → POST → dialog pops | ✅ |
| F-39 | Export data | Confirm → POST → "email when ready" | ✅ |
| F-40 | Delete account | Destructive confirm → DELETE → logout → splash | ✅ |
| F-41 | AI settings | Provider/config save; Test Connection (guidance for saved key); saved key never echoed | ⚠️ backend test-with-saved-key deferred |
| F-42 | Profile hub + edit + body profiles | Identity card, stats, menus, pull-to-refresh; avatar/DOB/place; body-profile CRUD + default | ✅ |
| F-43 | Subscription + upgrade (IAP) | Plan card, usage, tier cards, referral, restore; **purchase completed only after backend verify**; store-billed cancel blocked locally | ✅ |
| F-44 | Subscription error state | Entitlement-fetch failure → error card + retry (was silent "Free", fixed) | ✅ |
| F-45 | Referral | Share card (copy/share with popover origin), how-it-works, stats; clipboard fallback | ✅ |
| F-46 | Calendar month/day | Month grid, dots, prev/next refetch; tap day → events; **Today navigates month** (was dead, fixed) | ✅ |
| F-47 | Calendar add/edit/delete + outfit assign | Validates title + end>start; optimistic assign | ✅ |
| F-48 | Calendar connect | Bottom sheet (Google/Apple/Outlook) → "Coming soon"; no fake OAuth | ✅ |
| F-49 | Recs Find Matches / Complete Look / Weather / Astrology / Shopping | ≤3 items → match grid (score/reason); complete-look with fallback; weather (unit-aware, **"20 F" bug fixed**); astrology with profile-required; shopping priority badges | ✅ |
| F-50 | Feedback | Submit category/subject/desc/attachments (≤5, ≤5MB) → success + refresh | ✅ |
| F-51 | Legal / shared outfit / gamification | Links; public outfit load/hide/report; streak/achievements/leaderboard with empty states | ✅ |

## 13. Unowned-surface audits (read-only)

| ID | Surface | Key findings | Status |
|----|---------|--------------|--------|
| A-1 | Mobile dashboard (`features/dashboard/**`) | Season enum drift **`allSeason` vs `all-season`** (outfits invisible to backend season filters) — P2; snapshot "Loading" forever after failure — P2; no offline guard — P2; streak tile active though backend flag off — P2; light-mode contrast on hardcoded dark gradients — P2 | ⏳ fix phase |
| A-2 | Frontend shared (`components/ui/**`, `components/seo/**`, `api/client.ts`, `lib/*`) | Dialog can't scroll on desktop (clips footer) — P1; `skipToast` suppresses upgrade prompt — P2; AlertDialog = dismissible Dialog — P2; Sheet tap target <44px — P2; ScrollableTabs fake fades — P2; dead code (9 utils exports, 5 JSON-LD wrappers, .text-gradient) | ⏳ fix phase |
| A-3 | Backend `db/connection.py` + unowned models | `get_db`/`get_service_db` identical (silent elevated privileges) — P3; dashboard `user` field is a list — P3; unused models | ⏳ fix phase |

---

## Master findings register (all severities, deduped)

The full register with per-file line numbers lives in the audit's
[exec plan](../exec-plans/active/2026-08-03-full-flow-hardening.md#progress-log).
Highest-priority items still open (deferred to fix phase):

| # | Severity | Item | Owner |
|---|----------|------|-------|
| 1 | P2 | Flutter season enum `allSeason` vs backend `all-season` — mobile "All Season" outfits invisible to season filters | flutter-closet/fix |
| 2 | P1 | `proceedToManualEntry` still only sets `showManualEntry=true` — "Enter Manually" buttons dead | flutter-closet/fix |
| 3 | P1 | Desktop `Dialog` cannot scroll (`ui/dialog.tsx:58`) | fix |
| 4 | P2 | `skipToast` suppresses the upgrade prompt (`api/client.ts:411`) | fix |
| 5 | P2 | `AlertDialog` aliased to dismissible `Dialog` — destructive confirm can be X-dismissed | fix |
| 6 | P2 | No AI-photo consent revocation (App Review 5.1.2(i)) | fix |
| 7 | P2 | Mobile dashboard: snapshot "Loading" forever after failure; no offline guard; streak tile/route active when backend flag off; light-mode contrast on dark gradients | fix |
| 8 | P2 | Batch save concurrency uncapped (N uploads at once) | fix |
| 9 | P3 | `outfit_wear_history` table in no migration — feature silently dead | backend |
| 10 | P3 | `parallel_with_retry` retries hard AI errors ×3 (quota burn) | backend |
| 11 | P3 | Calendar `assign_outfit_to_event` doesn't validate outfit ownership | backend |
| 12 | P3 | Feedback tickets unbounded limit/offset | backend |
| 13 | P3 | `get_db` = `get_service_db` (silent elevated privileges) | backend |
| 14 | P3 | Dead code: `wardrobeStore.setViewMode/setPage`, `OutfitCreationController`, `TryOnContent`, `MultiPoseOutfitResult`, unused models/JSON-LD wrappers | sweep |
| 15 | P3 | `?page=abc` → "Page NaN" on blog; BlogPost italic-regex URL edge | fix |

## Verification evidence (2026-08-03, post-fix)

`./scripts/check_all.sh --include-frontend-build --allow-no-pytest`:
- architecture ✅ · docs structure ✅ · theme tokens ✅
- backend ruff ✅ · **pytest 806 passed** (23 Pydantic deprecation warnings, informational)
- frontend lint ✅ · **vitest 135/135 (34 files)** · build ✅
- flutter analyze ✅ · **test 121 passed**

Also: `npx tsc --noEmit` exit 0 (frontend). These are unit/static boundaries —
hosted Supabase RLS, live AI providers, Stripe, and authenticated browser E2E
remain external (see `docs/VERIFICATION.md`).
