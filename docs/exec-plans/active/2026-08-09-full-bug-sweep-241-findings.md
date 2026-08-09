# Findings ledger — full bug sweep (wave 2, evidence-backed)

Date: 2026-08-09
Status: active (companion to `2026-08-09-full-bug-sweep-241.md`)
Scope: all four apps (backend, frontend, admin, flutter) + migrations + infra
Method: 11 parallel read-only audit agents (one per area), each finding backed by path:line + verbatim quote; high-value claims spot-verified by the orchestrator against the working tree.

## Summary

- **104 findings** in this ledger (10 Critical/High, 39 Medium, 55 Low).
- All findings reflect the **current working tree** (post prior-session fixes). Previously-fixed patterns (migration-044/045 RPCs with PGRST202 fallback, `maybe_single()`, `asyncio.to_thread()`, migration 039/043 RLS scoping) were verified present and are **not** re-reported.
- The earlier two-wave run (13 agents, 254 raw / 241 unique findings) is recorded in `2026-08-09-full-bug-sweep-241.md`; this ledger regenerates the per-finding evidence after the fix wave, so some of the 241 are now resolved and some of these 104 are new.
- Criticals C1–C3 from the plan (unscoped FOR ALL "Service role can manage…" policies, users self-write escalation, blog_posts write scoping, user_ai_settings quota-counter writes) are **verified fixed** in migration 043; migration-guard script `scripts/check_migrations.py` exists.

## Severity distribution

| Area | Agent | High | Medium | Low | Total |
|------|-------|------|--------|-----|-------|
| Backend identity/money | A1 | 5 | 3 | 2 | 10 |
| Backend items/storage | A2 | 2 | 4 | 3 | 9 |
| Backend AI/photoshoot/outfits | A3 | 0 | 7 | 5 | 12 |
| Backend social/admin | A4 | 0 | 4 | 7 | 11 |
| Backend data/infra | A5 | 0 | 2 | 9 | 11 |
| Backend models/validation/docs | B3 | 0 | 4 | 5 | 9 |
| Frontend data layer | F1 | 0 | 7 | 5 | 12 |
| Frontend UI layer | F2 | 0 | 1 | 2 | 3 |
| Admin console | A8 | 2 | 4 | 4 | 10 |
| Flutter core | A9 | 1 | 4 | 5 | 10 |
| Flutter features | A10 | 0 | 2 | 5 | 7 |
| **Total** | | **10** | **42** | **52** | **104** |

---

# A1 — Backend identity/money (10)

## A1-01 | High | High conf | backend/app/api/v1/auth.py:293 + backend/app/services/referral_service.py:352-361
**Referral redemption at signup is permanently dead for email/password registrations (hardcoded `email_verified: False`, never set True).**
- why: `register` upserts the profile with `"email_verified": False` unconditionally, then immediately calls `redeem_referral`. The service gate rejects because the flag is False, and the retry hook (`users.referred_by_code`) is never persisted because the gate returns before the hook write. No code path sets the flag True for email/password users (login only touches `last_login_at`; the DB trigger runs only on auth.users INSERT; only OAuth paths write True) — so even after email confirmation, `/referral/redeem` keeps rejecting and `process_pending_referral` finds no hook.
- fix: set `email_verified` from `auth_response.user.email_confirmed_at is not None` (or session presence) at register, and flip the flag on login.

## A1-02 | High | High conf | backend/db/supabase/migrations/033_fix_referral_credit_stacking.sql:96-123 + backend/app/services/subscription_service.py:284-289
**Referral months are granted twice: trial is created/extended AND the same months are banked, then the bank is consumed as a second trial when the plan lapses.**
- why: `apply_referral_credit_atomic` branches 2 (live trial) and 3 (free) both `SET trial_end = … + make_interval(months => p_months)` **and** `referral_credit_months = COALESCE(…,0) + p_months`. The read path then consumes the whole bank once the plan is effectively free → 2× the advertised `REFERRAL_CREDIT_MONTHS` for every redemption (referrer included). Only branch 1 (paying subscriber) banking is correct.
- fix: increment `referral_credit_months` only in branch 1; branches 2/3 grant the trial without banking the same months.

## A1-03 | High | High conf | backend/app/api/v1/iap.py:406-425 + backend/app/services/subscription_service.py:555-602
**Registering an expired/revoked store purchase ("free" entitlement) downgrades a cross-rail paid subscription to free — the staleness guard only checks same-rail identities.**
- why: the free branch's stale check only flags rows holding the *other store's* identity; a Stripe-billed row (both identities NULL) falls through with `stale=False`, so the downgrade payload (`"plan_type": "free"`) overwrites an active Stripe entitlement. An expired Google token re-registered by a user who switched to Stripe/Apple silently kills their paid plan.
- fix: in the free branch, skip the downgrade unless the row's identity column matches the incoming identifier (or the row has no paid entitlement).

## A1-04 | High | High conf | backend/app/api/v1/subscription.py:341-347
**Web checkout is permanently blocked for every trial user (promo, referral, or banked referral credit).**
- why: the guard fires for any paid `plan_type` row without a `stripe_subscription_id` — exactly the state of every promo/referral trial (plan_type `pro_monthly`, status `trial`, no Stripe ID). The intended target was stale paid rows; the guard misfires on legitimate trials, so a free user who redeems a promo can never buy Plus/Pro on the web.
- fix: exempt `status == "trial"` with a future `trial_end` from the guard.

## A1-05 | High | High conf | backend/app/api/v1/subscription.py:330-338 + backend/app/services/subscription_service.py:477-487
**`billing_provider` is never reset to "stripe" by the Stripe sync paths — anyone who ever used store billing is locked out of web checkout and cancellation forever.**
- why: `sync_stripe_subscription`'s upsert payload contains no `billing_provider` key (nor does `upgrade_to_pro`); only the store paths write it, and the store webhook downgrade keeps it. The /checkout and /cancel guards then permanently reject the user even when their row is plan "free" with no active store subscription.
- fix: set `billing_provider: "stripe"` in `sync_stripe_subscription`/`upgrade_to_pro`, and/or let the checkout guard consider plan state.

## A1-06 | Medium | High conf | backend/app/api/v1/referral.py:77 + backend/app/services/referral_service.py:252-253
**Public /referral/validate leaks the referrer's real full name — the `neutral` privacy flag is never wired into the route.**
- why: the route calls `validate_referral_code(request.code, db)` with no `neutral` argument; the service defaults to `neutral=False` and returns the real account name. The A1-18 fix ("A friend") exists in the service but the public unauthenticated endpoint never passes `neutral=True`, so anyone can harvest account full_names by probing codes. (Orchestrator-verified: route call has no `neutral` kwarg.)
- fix: call `validate_referral_code(request.code, db, neutral=True)` from the public route.

## A1-07 | Medium | High conf | backend/app/services/subscription_service.py:1149-1168
**Monthly quota reservation (`reserve_usage`) is a non-idempotent conditional increment wrapped in `execute_with_reconnect` — a retry after a lost response double-charges quota or wrongly denies the operation.**
- why: the retry either increments again (double consumption) or returns FALSE against the already-incremented counter → RateLimitError for an operation that already consumed quota. The codebase itself acknowledges this hazard on the daily twin: `AISettingsService.reserve_usage` deliberately does NOT wrap in `execute_with_reconnect`.
- fix: don't reconnect-retry the `reserve_usage` RPC (fail closed; retry at a higher layer).

## A1-08 | Medium | High conf | backend/app/api/v1/admin/quotas.py:65-73 + backend/app/services/ai_settings_service.py:452-490
**Admin `custom_daily_quota` override is written but never enforced — the feature is a no-op.**
- why: `set_quota_override` updates `users.custom_daily_quota`, but `check_rate_limit`/`reserve_usage` read only the `AI_DAILY_*_LIMIT` constants and never look up the override.
- fix: load `users.custom_daily_quota` and use it as the `p_limit` when set.

## A1-09 | Low | Medium conf | backend/db/supabase/migrations/031_promo_codes.sql + backend/app/api/v1/subscription.py:353-355
**Promo redemption leaves a stale `stripe_subscription_id`; a later web upgrade modifies the old (canceled) Stripe subscription instead of starting a new checkout.**
- why: `redeem_promo_atomic`'s `ON CONFLICT (user_id) DO UPDATE` never clears `stripe_subscription_id`/`stripe_customer_id`; `/checkout` sees a truthy ID and calls Stripe modify on the old subscription.
- fix: clear the IDs in the promo RPC's conflict branch (and verify the stored subscription is still active before modifying).

## A1-10 | Low | High conf | backend/app/services/referral_service.py:225-226
**Referral stats `credits_earned`/`months_earned` are recomputed from the current `REFERRAL_CREDIT_MONTHS` setting instead of stored grant values — totals drift if the setting ever changes.**
- fix: store/read the granted months from `referral_redemptions` instead of the live setting.

---

# A2 — Backend items/storage (9)

## A2-01 | High | High conf | backend/app/api/v1/items.py:409 + backend/app/services/storage_service.py:944-947 + items.py:926/948
**Unvalidated `source_image_storage_path` is collected verbatim by the delete paths and used to delete arbitrary bucket keys.**
- why: `create_item` stores the client-supplied path with no ownership check (unlike `item.images`, which pass through `_is_owned_by_user`), and `resolve_owned_storage_paths` feeds it straight into the storage delete used by `delete_item`, `batch_delete_items`, and account deletion. The service-role client bypasses RLS. A user who can learn another user's key (presigned URLs are re-minted for authenticated callers; shared-outfit images expose item keys) can create an item with that path and delete the victim's object plus its `_thumb` sibling. (Orchestrator-verified: verbatim insert of the request field; collection has no path-prefix guard.)
- fix: validate the path with `_is_owned_by_user` at create time and re-verify ownership inside `resolve_owned_storage_paths`.

## A2-02 | High | High conf | backend/app/api/v1/users.py:452-456
**Account deletion deletes whatever bucket key `key_from_path` extracts from the user-settable `users.avatar_url`, with no ownership check.**
- why: `UserUpdate.avatar_url` is a free string persisted verbatim; the gamification leaderboard re-mints other users' avatars as presigned URLs for any caller. `delete_account` appends `key_from_path(avatar_url)` to the deletion list without the `startswith(f"{user_id}/avatars/")` guard that `upload_avatar`'s replace path correctly uses. (Orchestrator-verified: append is unconditional when key is truthy.)
- fix: only append the avatar key when it is owned by `user_id` (same prefix rule as `upload_avatar`).

## A2-03 | Medium | High conf | backend/app/services/batch_extraction_service.py:358,392-394,466
**A successful extraction that detects zero items orphans the persisted source photo forever.**
- why: `_persist_source_image` uploads the full photo before the vision call; cleanup runs only in the exception branch. Empty `items` on success (VLM detected nothing) and abandoned batches leave multi-MB objects under `{user}/sources/` with no DB reference and no sweep (only `tmp/` previews get weekly cleanup).
- fix: delete the source object when `add_detected_items` returns zero items, mirroring the failure-path cleanup.

## A2-04 | Medium | High conf | backend/app/api/v1/items.py:1105-1135
**A non-PGRST202 failure of `set_primary_item_image` after the image-row insert leaves the DB with two primaries and 500s; the client retry then duplicates the image row.**
- why: the insert commits first; the RPC fallback only covers the migration-gap case. Any other RPC failure raises after the row exists with `is_primary=True`, leaving the exact double-primary state migration 044 was written to eliminate.
- fix: on post-insert RPC failure, clear the just-inserted row (or flip primaries) before raising.

## A2-05 | Medium | High conf | infra/images-worker/worker.js:452-463 + README.md:48-49,171
**The documented `public, max-age=86400, immutable` serving policy is unreachable for app-uploaded objects; they are served with `max-age=3600`.**
- why: `S3StorageBackend.upload` stamps `cache-control: max-age=3600`; `cacheControlFor` returns the object's own value whenever `ownMaxAge < CACHE_TTL_SECONDS` (3600 < 86400). Code comment and README (including the cutover curl expecting `immutable`) directly contradict the code.
- fix: align one side — upgrade the app's 3600 stamp to the immutable default, or fix the README/verification steps.

## A2-06 | Medium | High conf | backend/app/api/v1/items.py:1501-1523
**`PUT /items/{id}/categories` bypasses the category whitelist and tag normalization that `ItemCreate`/`ItemUpdate` enforce.**
- why: `category` is only lowercased — an invalid value persists and the item vanishes from category-filtered lists; `colors`/`seasonal_tags` are stored raw, so mixed-case values evade the case-sensitive `jsonb_contains` color filter.
- fix: route through the same validators as `ItemUpdate`.

## A2-07 | Low | High conf | backend/app/api/v1/users.py:640-644
**If the `users` row update fails after a successful avatar upload, the new avatar object is orphaned.**
- fix: best-effort delete of the new object when the update raises.

## A2-08 | Low | High conf | backend/app/api/v1/items.py:982
**`toggle_favorite`'s UPDATE is scoped only by item id, not `user_id`** (ownership checked in a prior read only — benign TOCTOU today, IDOR write if a reassignment flow ever appears).
- fix: add `.eq("user_id", user_id)` to the update.

## A2-09 | Low | Medium conf | backend/app/services/batch_job_service.py:694-722 + batch_extraction_service.py:160-175
**A cancel adopted via `check_durable_cancel` never releases unused generation quota; the in-memory cancel release is computed before in-flight generations settle.**
- why: `cancel_job` is the only cancel path that releases quota; the durable-adopt path exits through the `if not job.is_cancelled():` skip with no release, burning reserved-but-unused quota. Conversely, the release counts `generation_completed` at cancel time, so in-flight completions afterwards over-release (small user-favorable leak; `GREATEST(0,…)` bounds make double-release harmless).
- fix: release unused quota on the durable-adopt exit too; compute the release after in-flight generations are awaited.

---

# A3 — Backend AI/photoshoot/outfits (12)

## A3-01 | Medium | High conf | backend/app/services/ai_provider_service.py:909 + 1032
**Circuit breaker for the OpenAI-compatible chat leg never learns from real outcomes — success recording is dead code.**
- why: `chat()` ends its try block with `return self._parse_chat_response(...)`, so the `else:` clause that calls `record_result(ok=True)` is unreachable (a return in the try body skips the else). Provider failures converted to `AIServiceError` re-raise without `record_result(ok=False)`; only the transport-error and generic paths record. The breaker therefore opens/resets only on transport errors, not on 5xx/429s. (Orchestrator-verified.)
- fix: record success before the return; record failure in the `AIServiceError` handler.

## A3-02 | Medium | Medium conf | backend/app/api/v1/ai.py:296-300
**Cross-user body-profile read in `generate_outfit`: `body_profiles` fetched by id without a `user_id` scope** (service-role client bypasses RLS). Same bug class `upload_outfit_image` explicitly guards.
- fix: add `.eq("user_id", user_id)` to the query.

## A3-03 | Medium | Medium conf | backend/app/api/v1/outfits.py:583-613
**`get_public_outfit` never checks `shared_outfits.visibility` — legacy non-public share rows are served publicly.**
- why: the share-row lookup selects only `id, expires_at` and gates on row existence + `outfits.is_public`. Pre-045 data (the old two-statement flow wrote `is_public=true` and persisted `friends`/`private` rows) is served at the anonymous public URL forever.
- fix: add `.eq("visibility", "public")` to the share-row query.

## A3-04 | Medium | High conf | backend/app/services/gemini_provider.py:401-413
**Redirect-based SSRF bypass in Gemini's remote-image download.**
- why: `_decode_image_part` validates only the initial URL, then downloads with `follow_redirects=True`; a user-controllable https URL that 3xx-redirects to `http://169.254.169.254/...` or loopback is fetched with no re-check.
- fix: `follow_redirects=False` and re-validate each `Location` (or refuse redirects).

## A3-05 | Low | High conf | backend/app/services/ai_provider_health_service.py:166-168
**Probe-path breaker never accumulates HTTP-status failures** — `consecutive_failures=0 if is_healthy else 1` resets to 1 each time, so only connection errors accumulate. Combined with A3-01, the breaker effectively trips only on connect failures.
- fix: carry the previous counter forward for unhealthy HTTP statuses.

## A3-06 | Medium | High conf | backend/app/services/photoshoot_service.py:1493-1497 (and sync path ~1080)
**Photoshoot generated images skip the empty/garbage payload validation that outfit/try-on paths have.**
- why: only `if not response.images: raise` — an empty-string or HTML-error-page payload is marked success, counted in `generated_count`, broadcast `image_complete`, and consumes daily quota.
- fix: run the same `_validated_image`-style check; `mark_image_failed` on failure.

## A3-07 | Low | High conf | backend/app/api/v1/outfits.py:105 + 1176-1180
**`mark_worn` serialization is in-process only (two workers still lose concurrent wears), and `_wear_locks` grows without bound.**
- fix: prefer a DB-side atomic increment RPC; prune lock entries; document the single-worker assumption.

## A3-08 | Low | Medium conf | backend/app/services/photoshoot_job_service.py:627-634
**`set_error` silently drops the failure when the terminal CAS transition fails** — on a non-CAS-lost transition failure the job stays PROCESSING until TTL cleanup.
- fix: distinguish "CAS lost to a concurrent FAILED writer" from other transition failures (log; still set error_message/status).

## A3-09 | Low | Medium conf | backend/app/services/vector_service.py:238 + 254
**`find_similar` can under-fill results** — the 2× window is filtered by exclusions/min_score before `items[:top_k]`, so results are silently truncated when many exclusions exist.
- fix: raise the fetch multiplier or issue a follow-up query when filtered results fall short.

## A3-10 | Medium | High conf | backend/app/services/ai_provider_health_service.py:96 + 228
**Health/circuit-breaker cache keyed by `base_url` only — one user's bad BYOK key opens the breaker for every user on the same host.**
- fix: key by `(base_url, api_key)` (hash the key).

## A3-11 | Low | Medium conf | backend/app/services/photoshoot_service.py:1319-1322 / 1240-1244
**Photoshoot quota release has no day-rollover guard — a post-midnight release can over-credit the new day** (migration 024 resets the counter on `CURRENT_DATE`; `recommendations.py` guards the identical hazard with `reserved_on == utc_today()`, the photoshoot paths do not).
- fix: capture the reservation UTC date and skip the release once the day rolls over.

## A3-12 | Low | High conf | backend/app/api/v1/outfits.py:806-813
**`share_outfit` passes the client's `expires_at` string unvalidated into a `TIMESTAMP` RPC parameter** — malformed input → SQLSTATE 22P02 → 500 instead of 422.
- fix: validate/parse with `parse_utc_datetime` before the RPC.

---

# A4 — Backend social/admin (11)

## A4-01 | Medium | High conf | backend/app/services/social_import_pipeline_service.py:1299 (write at 1375)
**approve_photo has no reviewable-state guard (reject does) — approve can race a photo still in `processing`.**
- why: approving the `processing_photo` saves 0 items, flips APPROVED, then the running `_process_single_photo` overwrites status back to `awaiting_review`/`buffered_ready` (reverted approval) or FAILED; if two photos land in `awaiting_review`, `get_slots()` returns only the first and the job never completes.
- fix: gate approve on `{awaiting_review, buffered_ready}` like reject.

## A4-02 | Medium | High conf | backend/app/api/v1/calendar.py:370-372
**Calendar date-range filters apply UTC-midnight boundaries to a naive TIMESTAMP column** — for non-UTC users, events near local midnight are grouped on the wrong day in month views and dropped from week-range fetches.
- fix: filter with a user-timezone day window.

## A4-03 | Medium | High conf | backend/app/services/social_auth_service.py:150
**Scraper-auth validation treats any username containing "mfa" as requiring 2FA** — a legitimate handle like `mfa_stylist` can never submit scraper auth without an OTP.
- fix: remove the username-substring heuristic (MFA is detected from Instagram's login response).

## A4-04 | Low | Medium conf | backend/app/services/social_scraper_service.py:918-924, 1181, 1320
**Meta API 5xx falls through to anonymous HTML scrape — private OAuth profiles silently "complete" with 0 photos** instead of signaling auth/retry.
- fix: treat `None` from the Meta path as a retryable discovery failure.

## A4-05 | Low | High conf | backend/app/api/v1/calendar.py:653-690
**assign_outfit_to_event never verifies outfit ownership; a bogus outfit_id becomes a 500 (FK violation).**
- fix: verify `outfits.id = outfit_id AND user_id = current user` first; return 404/422.

## A4-06 | Low | High conf | backend/app/api/v1/social_import.py:560-672
**Feature-toggle guard missing on the auth/write endpoints** — a disabled `ENABLE_SOCIAL_IMPORT` still accepts auth payloads and job mutations.
- fix: add the same toggle check to the remaining handlers.

## A4-07 | Low | High conf | backend/app/services/social_import_pipeline_service.py:1309
**approve_photo reports "Social import job not found" when the photo id is bad** — misleading 404 body.
- fix: raise a photo-scoped not-found error.

## A4-08 | Low | Medium conf | backend/app/api/v1/feedback.py:178-192
**get_my_tickets accepts negative limit/offset → invalid PostgREST range → 500.**
- fix: add `ge=1`/`ge=0` query constraints and clamp offset.

## A4-09 | Low | High conf | backend/app/services/admin_service.py:526-545
**user_activity duplicates audit rows where the user is both actor and entity** (actor rows never seeded into the `seen` set).
- fix: seed `seen` with actor-query ids before the entity loop.

## A4-10 | Low | Medium conf | backend/app/services/social_import_job_store.py:151,187 + pipeline:385
**Discovery ordinal allocation is a non-serialized read-modify-write — two workers can collide on UNIQUE(job_id, ordinal) → 23505 → job FAILED.**
- fix: make discovery admission atomic per job (advisory lock RPC or on-conflict ordinal reservation).

## A4-11 | Low | High conf | backend/app/api/v1/calendar.py:532-546
**update_calendar_event cannot clear optional fields — explicit null is silently ignored.**
- fix: distinguish explicit null (clear) from absent (leave) via `exclude_unset` semantics.

---

# A5 — Backend data/infra (11)

## A5-01 | Medium | Medium conf | backend/Dockerfile:70 + backend/app/core/ip_rate_limit.py:132
**X-Forwarded-For spoofing bypasses every per-IP rate limit (`--forwarded-allow-ips='*'`).**
- why: uvicorn trusts the first XFF entry from *any* peer; if Railway's edge appends rather than replaces client-supplied XFF, a caller rotates `X-Forwarded-For` per request and defeats the 10/h login, 5/h register, 5/h waitlist, and demo daily limits. (Orchestrator-verified flag in CMD.)
- fix: pin `--forwarded-allow-ips` to the proxy's address range, or key limits on peer + XFF hash.

## A5-02 | Medium | High conf | backend/db/supabase/migrations/005_waitlist.sql:48 + 001_full_schema.sql:1032-1034
**Public write tables bypass the app-level IP rate limits via direct PostgREST with the embedded anon key.**
- why: waitlist (5/h) and feedback (10/h) limits exist only in FastAPI routes; 005 explicitly `GRANT INSERT ON public.waitlist TO anon, authenticated` and 001's "Anyone can insert share feedback" has `WITH CHECK (true)` — anyone holding the publishable key (shipped in bundles) can POST unlimited rows straight to PostgREST.
- fix: enforce anti-spam at the DB (SECURITY DEFINER RPC with rate guard) or accept the app limits are advisory.

## A5-03 | Low | High conf | backend/db/supabase/migrations/001_full_schema.sql:1032-1034
**share_feedback INSERT policy is weaker than the API: bypasses `allow_feedback` and `expires_at` checks.**
- fix: `WITH CHECK (EXISTS (SELECT 1 FROM shared_outfits s WHERE s.id = shared_outfit_id AND s.allow_feedback AND (s.expires_at IS NULL OR s.expires_at > NOW())))`.

## A5-04 | Low | High conf | backend/db/supabase/migrations/007_subscriptions_and_referrals.sql:185, 201
**SECURITY DEFINER RPCs without pinned `search_path`** (deviation from the repo's own 026/031/033 standard; impact theoretical since refs are schema-qualified).
- fix: add `SET search_path = public` (as 010 does).

## A5-05 | Low | High conf | backend/app/main.py:510-528 + backend/app/core/middleware.py:170
**Middleware ordering comments are inverted; CORS is actually the innermost user middleware.** Works today, but an exception raised in CorrelationId/RequestLogging escapes ExceptionMiddleware → 500 with no CORS headers (browser shows generic network error).
- fix: fix comments, or re-add CORS after the logging middleware.

## A5-06 | Low | High conf | run-dev.sh:65 + backend/app/main.py:785-788
**Dev/CI uvicorn runs without `--proxy-headers`, so all local users share one rate-limit bucket** (everything resolves to 127.0.0.1) — 5 registrations/hour and 3 demo extractions/day fire spuriously.
- fix: add the flags in dev too, or skip rate limiting for loopback.

## A5-07 | Low | High conf | backend/db/supabase/migrations/042_outfit_wear_history.sql:46-48
**Wear-history INSERT verifies only self user_id, not outfit ownership** — clients can write wear rows (and backdate `worn_at`) against other users' outfits. Self-data integrity only.
- fix: `WITH CHECK (auth.uid() = user_id AND EXISTS (SELECT 1 FROM outfits o WHERE o.id = outfit_id AND o.user_id = auth.uid()))`.

## A5-08 | Low | High conf | backend/app/core/concurrency.py:109-114
**KeyedLock can exceed `max_keys` when every cached lock is contended** — eviction loop only deletes unlocked candidates, then still creates a new lock.
- fix: serialize on an existing locked lock when no candidate was evicted.

## A5-09 | Low | High conf | scripts/check_migrations.py:29-31
**Duplicate `002_` migration prefix is hard-coded as known-good** — a prefix-deduping runner silently drops `002_user_profile_trigger.sql` (the `handle_new_user` trigger + users INSERT policy).
- fix: renumber to a unique prefix and drop the whitelist.

## A5-10 | Low | High conf | backend/db/supabase/migrations/008_update_new_user_trigger_for_subscriptions.sql:73-78
**Referral-code generation collision raises inside the auth trigger and fails the entire signup** — `ON CONFLICT (user_id) DO NOTHING` doesn't cover the `code UNIQUE` constraint.
- fix: retry with a suffix on code collision or `ON CONFLICT (code) DO NOTHING` + retry loop.

## A5-11 | Low | High conf | backend/app/core/ip_rate_limit.py:219-224
**Demo quota is consumed on failed operations** (reserve-before-yield with no release-on-failure) — a provider 503/timeout burns one of the 3-per-day demo slots.
- fix: decrement usage on exception inside the `async with` body.

---

# B3 — Backend models/validation/docs (9)

## B3-01 | Medium | High conf | backend/app/api/v1/feedback.py:44 + backend/app/models/feedback.py:38
**Form param accepts unvalidated email, then constructs a model requiring `EmailStr` → pydantic ValidationError → 500 instead of 422.**
- why: FastAPI can't validate `Form(None)` strings against `EmailStr` because the model is built manually inside the handler; the raised pydantic error is not the app's `ValidationError` and falls through to the generic 500 handler.
- fix: validate the email at the form boundary.

## B3-02 | Medium | High conf | backend/app/api/v1/ai_settings.py:318
**`GET /ai-settings/rate-limit/{operation_type}` rejects `embedding`, which the service and the quota enum fully support** — the only embedding-aware surface that 422s. No current caller hits it (latent).
- fix: accept `"embedding"` in the route.

## B3-03 | Medium | High conf | backend/app/api/v1/outfits.py:1517-1518 + backend/app/models/outfit.py:48 + migration 001
**`outfit_images.lighting` unbounded at upload, `max_length=50` in model and `VARCHAR(50)` in DB → 22001 → 500.**
- fix: cap `lighting` inline like the sibling `pose` field.

## B3-04 | Low | High conf | backend/app/models/user.py:183,196 + migration 001 (`VARCHAR(255)`)
**`user_settings.default_location` has no `max_length` in the Pydantic layer** — >255 chars → PostgREST 22001 → 500. The file's own comment shows the intent; this column was missed.
- fix: add `max_length=255` to both models.

## B3-05 | Low | High conf | backend/app/models/item.py:245,257,263-268
**Extraction models are dead code advertising a contract that contradicts the live upload endpoint** — routes use `DetectedItem`/`ExtractItemsResponse`; the real API returns `images` + `failed_count`, not `extracted_items`.
- fix: delete the dead models or align them with the live response.

## B3-06 | Low | High conf | docs/references/data-models.md:10,137-145
**Doc says migrations are `001..042` (43 files); the repo actually has 46 (`001..046`)** — 043–046 never mentioned, so a reader following the doc could run a stale schema.
- fix: update the doc ranges.

## B3-07 | Low | High conf | docs/BACKEND.md vs backend/app/api/v1/gamification.py:151-165
**Doc claims `user_streaks`/`user_achievements` are "read-only in practice — no code path writes them"; `get_streak` upserts a row whenever the flag is on** — the write-on-GET exists precisely on the flag-on path (same condition under which `/ready` requires the tables).
- fix: correct the doc or gate the write behind a real trigger.

## B3-08 | Low | Medium conf | backend/app/models/outfit.py:72-80
**`OutfitResponse.name` keeps `min_length=1`, contradicting the file's own "no validators on the response side" design rule** — a legacy row with `name=''` 500s the whole outfit list (DB has no CHECK).
- fix: drop `min_length` on the shared base (keep it on the create model).

## B3-09 | Medium | Medium conf | backend/app/api/v1/users.py:959
**`PUT /users/body-profile` with a partial payload when no profile exists → pydantic ValidationError → 500 instead of 422** (creating requires full payload via `BodyProfileCreate`, but the error escapes the app's handler list).
- fix: catch pydantic ValidationError and return 422.

---

# F1 — Frontend data layer (12)

## F1-01 | Medium | High conf | frontend/src/stores/wardrobeStore.ts:363-376 (same pattern outfitStore.ts:427-448)
**`fetchMore` clobbers fresh page-1 data with a stale pre-await snapshot (last-writer-wins race).**
- why: `state.items`/`state.page` are captured before the await; a concurrent `fetchItems(true)` that resolves during the append is overwritten by `set()` with the pre-await list + stale page-2. The store's own mutations were fixed to "Re-read after await…"; `fetchMore` was not.
- fix: re-read `get()` after the await and append to the fresh list.

## F1-02 | Medium | Medium conf | frontend/src/stores/wardrobeStore.ts:196 + 374 (+ WardrobePage.tsx:269-270)
**Search pagination is inconsistent: page 1 can be server-side searched, pages 2+ never are** (`fetchMore` deletes `filters.search` from the API filters). Matching items past the unfiltered offset are missed; `totalItems`/`hasMore` reflect the unfiltered list; `setFilter`/`setViewMode` reset `page` but not `hasMore`.
- fix: pick one model — send search on every page, or strip it from filters/cache key and reset `hasMore` on search change.

## F1-03 | Medium | High conf | frontend/src/stores/wardrobeStore.ts:455-460 + FilterPanel.tsx + WardrobePage.tsx:262-271
**Store search filter leaks across page navigations; a remount can show a searched list with an empty search box.**
- why: typing a search persists in the module-level store; the page's local state resets to `''` on remount and nothing syncs/clears the store filter on mount (only `isFavorite` is synced). The outfit store keeps search purely local; the wardrobe store does not.
- fix: sync/clear the store filter on mount (or stop including `search` in the cache key).

## F1-04 | Medium | High conf | frontend/src/stores/authStore.ts:144-162 + lib/auth.ts:38-58
**Logout / forced logout never resets in-memory store state — previous user's data remains visible** until a refetch replaces it.
- why: `clearRequestCache()` clears the wire cache only. Closet/outfit/subscription stores are never reset; the reset helpers exist but are only referenced in tests. After logout + login as another user in the same SPA session, the previous account's wardrobe and plan-gating state renders (including `selectIsPro`/`selectCanUpgrade`). (Orchestrator-verified.)
- fix: call the three reset helpers + `subscriptionStore.reset()` inside `logout` and `forceLogout`.

## F1-05 | Medium | High conf | frontend/src/lib/outfit-from-upload.ts:59-80
**Auto-outfit creation bypasses the outfit request cache invalidation** — any `fetchOutfits()` within the 30s freshness window returns the pre-create cached list and hides the just-created outfit.
- fix: call `invalidateOutfitList()` after create, mirroring `saveOutfitFromDraft`.

## F1-06 | Medium | High conf | frontend/src/stores/outfitStore.ts:545-553
**`toggleOutfitFavorite` captures store state before the await (stale-write race)** — unlike wardrobeStore's fixed mutations and the sibling `markOutfitAsWorn`.
- fix: move `const state = get()` to after the await.

## F1-07 | Medium | Medium conf | frontend/src/components/wardrobe/BatchExtractionFlow.tsx:576-651 + lib/retry.ts:151-190
**Non-idempotent POSTs are retried on ambiguous failures — duplicate items/images** (`createItem` and `uploadOutfitImage` have no client idempotency key; the transport retry can also re-issue on 408/429/5xx).
- fix: add a `client_request_id` idempotency key, or dedupe by key on the backend create path.

## F1-08 | Low | High conf | frontend/src/hooks/useInfiniteScroll.ts:56-78
**One-shot intersect latch stalls auto-paging after a failed or short append** — sentinel stays intersecting and no re-fire occurs until leave/re-enter.
- fix: clear the latch after `onLoadMore` settles; add retry on failure.

## F1-09 | Low | Medium conf | frontend/src/stores/wardrobeStore.ts:376 / outfitStore.ts:448
**Offset pagination can duplicate tiles after concurrent mutations (no dedupe on append).**
- fix: dedupe by id on append.

## F1-10 | Low | High conf | frontend/src/stores/subscriptionStore.ts:147-154
**Usage cache (60s freshness) is never invalidated after quota-consuming actions** (extraction, generation, photoshoot) — usage bars and `useIsNearLimit` show pre-action numbers for up to 60s.
- fix: invalidate the usage key after quota-consuming mutations.

## F1-11 | Low | Medium conf | frontend/src/hooks/useBatchSSE.ts:88-99
**Heartbeat resets the reconnect budget, so a heartbeat-only stream can reconnect forever without reconciling** (`onStreamEnded` → `reconcileJobStatus()` never runs).
- fix: don't count heartbeats toward reconnect budget reset; enforce a wall-clock cap.

## F1-12 | Low | High conf | frontend/src/stores/wardrobeStore.ts:494-517
**`markItemAsWorn` throws after already writing state when the item is missing from the loaded list** — callers surface a failure toast even though the server call succeeded.
- fix: don't throw when the item simply isn't in the loaded pages.

---

# F2 — Frontend UI layer (3)

## F2-01 | Low | High conf | frontend/src/components/wardrobe/ExtractedItemCard.tsx:332 (Card :190, CardContent :199)
**Delete-confirmation overlay escapes its card and scrims the entire dialog** — `absolute inset-0` resolves against the nearest positioned ancestor (the `fixed` DialogContent), so tapping trash darkens the whole review dialog instead of the single card.
- fix: add `relative` to the Card (or move the overlay inside the `relative` image div).

## F2-02 | Medium | High conf | frontend/src/components/landing/PhotoshootDemo.tsx:284-285
**A failed slot retry erases the partial-success results screen** — `setState('error')` on retry failure replaces the results view whose only action is `handleReset()`, losing all successfully generated images.
- fix: on retry failure return to the results view with the failed slot still marked.

## F2-03 | Low | Medium conf | frontend/src/components/wardrobe/BatchImageSelector.tsx:60-66 (+ ExtractionDemo.tsx:68, TryOnDemo.tsx:76,83, TryOnPage.tsx:224, PhotoshootDemo)
**All image-upload surfaces silently drop rejected files** — no `onDropRejected`/`onError` handler anywhere; an oversized (>10MB, common for iPhone HEIC) or wrong-type file produces zero feedback.
- fix: add `onDropRejected` handlers that surface a toast/inline error.

---

# A8 — Admin console (10)

## A8-01 | High | High conf | admin/src/features/subscriptions/pages/IapTransactionsPage.tsx:215
**Mark-refunded action gated on `iap.read`; backend requires `iap.write`** (`backend/app/api/v1/admin/iap.py` write endpoint). The `support` role holds `iap.read` only, so the button renders for support and every click 403s. (Orchestrator-verified: read endpoints use `iap.read`; write gate per code.)
- fix: gate on `can('iap.write')`.

## A8-02 | High | High conf | admin/src/features/quotas/pages/QuotasPage.tsx:88
**Quota override action gated on `quotas.read`; backend requires `quotas.write`** (ADMIN_ONLY_WRITE_PERMISSIONS). Support sees "Set override" and every save 403s; the comment in `quotas.ts:23-25` documents the old contract.
- fix: gate on `can('quotas.write')` and update the stale comment.

## A8-03 | Low | High conf | admin/src/shared/lib/permissions.ts:35-47
**Frontend `ops` role map missing `iap.write` that backend grants** (`backend/app/core/permissions.py:51`) — static fallback map drifts from the live permission list.
- fix: add `'iap.write'` to the frontend ops list.

## A8-04 | Medium | High conf | admin/src/shared/ui/TableToolbar.tsx:204-208 + backend/app/services/admin_service.py:1678-1679
**Audit "to" date filter excludes the entire selected day** — the date input emits `YYYY-MM-DD`, backend parses midnight UTC, `lte(created_at, midnight)` drops every event after 00:00 UTC that day.
- fix: send end-of-day (`${date}T23:59:59.999Z`) or clamp date-only values server-side.

## A8-05 | Medium | High conf | admin/src/features/subscriptions/pages/SubscriptionsPage.tsx:225 + msw/handlers/subscriptions.ts:134-157
**Refund action offered on store-billed (Apple/Google) rows that always fail; MSW fakes success** — backend rejects non-Stripe rows ("only Stripe-billed rows are refundable"), while the test handler returns `status: 'succeeded'` for any user, so tests pass and prod fails for the same flow.
- fix: hide refund unless `billing_provider === 'stripe'`; mirror the backend error in MSW.

## A8-06 | Medium | High conf | admin/src/features/audit/pages/AuditPage.tsx:66-76,297
**Audit page search filters client-side but pagination/totals stay server-side** — footer reads "Showing 1–20 of 500" while only a handful of rows render; Next can land on zero matches.
- fix: reset pagination when a q filter is active, or surface the mismatch.

## A8-07 | Low | High conf | admin/src/features/content/pages/PostsPage.tsx:181-187
**Posts "published/drafts" stats are computed from the current page, not the catalogue** — misleading page counts presented as totals on page 2+.
- fix: derive from `fetchAllAdminPosts()` or unfiltered totals.

## A8-08 | Low | High conf | backend/app/services/admin_service.py:308 + admin/src/features/users/pages/UserDetailPage.tsx:608
**Photoshoot jobs render "—" as type in user activity** — `photoshoot_jobs` has `use_case`, not `job_type` (migration 023), the query never selects it, and the UI renders `stringValue(job, 'job_type') ?? '—'`. The MSW fixture uses `job_type` for both tables, so tests don't catch it.
- fix: select `use_case` and surface it.

## A8-09 | Low | High conf | admin/src/features/users/lib/users.ts:69-70
**Role select offers roles the acting admin can never grant** — ops/support (who hold `users.write`) can pick `admin`/`super_admin` and always get "Only admins can grant admin roles".
- fix: filter `assignableRoles()` by the actor's own role.

## A8-10 | Low | High conf | admin/src/shared/hooks/useCsvExport.ts:21-32
**CSV export silently exports only the current page** — every list page wires `rows: table.data` (≤20 rows on a 500-row table) with no warning; the toast counts exported rows, masking the truncation.
- fix: fetch all matching rows for export or label "current page only".

---

# A9 — Flutter core (10)

## A9-01 | High | High conf | flutter/lib/core/network/api_interceptors.dart:21-23
**AuthInterceptor attaches the Supabase bearer token to ANY non-public request path — including absolute presigned/third-party URLs.**
- why: the interceptor only skips a short substring list, then adds `Authorization` unconditionally. S3/R2 presigned URLs reject a second auth mechanism ("Only one auth mechanism allowed" — documented in the repo's own `app_network_image.dart`), so downloads through `ApiClient.get(imageUrl)` (try-on "Save to gallery", outfit-builder image attach, batch studio images) 403 in the shipped presigned mode. (Orchestrator-verified: no host/URL guard in the interceptor.)
- fix: reuse the `urlAcceptsAuthToken`/`_isOurHost` guard from `app_network_image.dart`.

## A9-02 | Medium | High conf | flutter/lib/features/auth/services/referral_service.dart:10 (+ auth_controller.dart:336-345)
**Pending referral code is never cleared on logout, so it is redeemed under whichever account signs in next.**
- why: the stored code is only removed after a *successful* redemption; `logout()` clears user/error but not the code, and the auth-change worker retries it on every subsequent sign-in (any account).
- fix: clear `pending_referral_code` in `logout()`.

## A9-03 | Medium | High conf | flutter/lib/main.dart:54
**Status-bar icon brightness is hardcoded `Brightness.dark` for the whole app** — main-shell screens use dark backgrounds in dark mode with dark status-bar icons (invisible clock/battery); only splash/auth/viewer override it.
- fix: derive overlay style from `Theme.of(context).brightness` (or set `systemOverlayStyle` in both `AppBarTheme`s).

## A9-04 | Medium | High conf | flutter/lib/features/calendar/controllers/calendar_controller.dart:95-98
**Month-event fetches have no request-generation guard — out-of-order responses overwrite newer data** on rapid month swipes (unlike `WardrobeController`/`OutfitListController`, which use `_fetchGeneration`).
- fix: add a generation counter; ignore stale responses.

## A9-05 | Medium | Medium conf | flutter/lib/core/constants/api_constants.dart:20-21 + android/app/src/main/AndroidManifest.xml
**Debug API fallback `http://localhost:8000` is unreachable on Android** — cleartext HTTP is blocked (no `usesCleartextTraffic`/`network_security_config`) and emulator loopback is not the host (`10.0.2.2`).
- fix: add a debug network security config and document `10.0.2.2`.

## A9-06 | Low | High conf | flutter/lib/features/wardrobe/repositories/item_repository.dart:105-114
**`createItemWithImage` creates the item before uploading the image; a failed upload leaves a server-side orphan and retries create duplicates.**
- fix: best-effort delete of the created item on upload failure.

## A9-07 | Low | High conf | flutter/lib/features/outfits/repositories/outfit_repository.dart:391-393
**`getSharedOutfit` calls `GET /api/v1/outfits/shared/{id}`, which does not exist in the backend** — backend mounts `/api/v1/shared-outfits` (POST feedback only) and has `GET /outfits/public/{id}`. Latent (share links point at the web app), but any reach to this route renders "Outfit not found".
- fix: point at the real public endpoint or add the missing route.

## A9-08 | Low | Medium conf | flutter/lib/core/services/sse_service.dart:40-55
**SSE reconnect retries with a stale access token on 401; it never refreshes the session** — recovery only happens via the slower polling fallback.
- fix: run `SupabaseService.refreshSession()` before retrying on 401.

## A9-09 | Low | High conf | flutter/lib/features/wardrobe/controllers/batch_extraction_controller.dart:1476-1480
**Per-item save failures are swallowed with only a debug print** — the UI reports only a lower success count with no error detail or retry affordance.
- fix: collect failures and surface via `ErrorHandler` + a summary message.

## A9-10 | Low | Medium conf | flutter/lib/features/auth/services/referral_service.dart:56-68
**`handleOAuthCallback` runs on every auth-state change while signed in** — unconditional POSTs to `/auth/oauth/sync` and repeated redemption attempts for an already-redeemed code on every cold start (compounds A9-02).
- fix: only run the OAuth-sync/pending-redemption path when a callback or pending code exists; treat "already redeemed" as success when clearing.

---

# A10 — Flutter features (7)

## A10-01 | Medium | High conf | flutter/lib/features/tryon/views/tryon_page.dart:265,296-298 + tryon_controller.dart:146,522-528
**Live Try-On screen is the legacy view: multi-selected gallery images dead-end (no per-image removal, no "From Closet"), while the hardened UI that fixes this is dead code.**
- why: gallery triggers `pickMultipleMedia`, but the only post-selection action is a full reset ("Change Image"); the generation guard then blocks with "Remove the extra items" and there is no Remove affordance. The hardened `tryon_content.dart` (arrows, counter, Remove, wardrobe picker) has **zero importers** (orchestrator-verified) — the fixed UI never ships.
- fix: route to `TryOnContent`, or port its prev/next/remove UI into `TryOnPage` and delete the duplicate.

## A10-02 | Medium | High conf | flutter/lib/features/wardrobe/views/item_add_page.dart:57-58,255 + widgets/manual_entry_form.dart:78-81
**"Enter Manually" is advertised as photo-free, but the form hard-blocks saving when no photo is attached.**
- why: card copy says "Add item details without a photo", but the save gate requires `imageToUse != null`. The backend/API supports photo-less items (`createItem` posts without an image).
- fix: allow saving without a photo (or change the copy).

## A10-03 | Low | High conf | flutter/lib/features/auth/views/register_page.dart:44-59,333-337
**Register page shows a red "invalid referral code" icon but still submits the code; the failure is silent and the code is re-stashed as pending and retried forever on every login.**
- fix: block submission while `_referralValid == false`, or drop the code before registering.

## A10-04 | Low | Medium conf | flutter/lib/features/auth/views/register_page.dart:262 (login_page.dart) + settings change-password gates + backend auth.py (`min_length=8`)
**Password policy mismatch: signup/login accept ≥6 characters; the change-password form requires ≥8 with upper + lower + digit; the backend signup contract requires ≥8** — a 6–7 char password created at signup can never be changed to any other password that fails the stronger rule, with no warning at signup.
- fix: align the policies (and enforce the backend rule client-side at signup).

## A10-05 | Low | High conf | flutter/lib/features/profile/views/help_page.dart:131-133,180-181
**"Live Chat" tile in Help & Support opens the feedback form, not a chat** — a user expecting live chat (with stated availability hours) lands on the feedback form.
- fix: rename the tile ("Send Feedback") or remove the availability subtitle.

## A10-06 | Low | High conf | flutter/lib/features/tryon/views/tryon_content.dart + calendar/widgets/weather_recommendation_widget.dart
**Dead code with a user-visible consequence: the hardened Try-On UI and the calendar weather widget are unreferenced** (~700 lines of drifting UI; the Try-On duplicate masks the shipped regression, A10-01).
- fix: delete or wire up.

## A10-07 | Low | High conf | flutter/lib/features/wardrobe/widgets/manual_entry_form.dart:104-106
**Manual entry price field silently drops invalid input instead of validating** — `double.tryParse` returns null for `12,99`/`abc`, and the item is silently saved without a price (no validator on the field).
- fix: add a validator and inline error.

---

# Verified-fixed / not re-reported (spot-checked by orchestrator)

- Migration 039 + 043: all unscoped "Service role can manage …" FOR ALL policies now `TO service_role`; users self-write limited to profile columns via column-level grants; blog_posts and user_ai_settings writes service-role only. (Read in full.)
- `scripts/check_migrations.py` guard exists.
- A3 wave: PGRST202 fallback for 044/045 RPCs, `maybe_single()`, `asyncio.to_thread()`, `VectorStoreError`→503, share-flow 045 RPC delegation — all present; not re-reported.
- A4 wave: all admin routes gated (`require_admin`/`require_permission`); promo-code CRUD gated by `content.write` per the admin-panel spec.
- Migrations 034/035/036/042/044/046 contracts match their call sites; 046 private-bucket flip leaves no Supabase-Storage read paths.

# Caveats

- All findings are code-level evidence (path:line + quote); no live runtime was exercised (read-only audit). Severity reflects worst plausible reachability; confidence marks verification depth.
- The 20-bug-fix sweep working-tree changes are user work and were not modified; findings reflect the tree as of 2026-08-09.

---

# Deep-pass wave (F2b / A10b / A3b) — 28 findings, all fixed

Three follow-up audits (frontend UI layer, Flutter features, backend AI/outfits) ran after the main wave's fix round; every finding below was implemented and verified (backend: full `pytest` 3816 passed + ruff clean; frontend: lint + tsc + 269 vitest; admin: lint + typecheck + 230 tests + schema check; flutter: `flutter analyze` clean + 233 tests).

## F2b — Frontend deep pass (8)

| ID | Sev | Finding | Fix |
|----|-----|---------|-----|
| F2b-01 | High | `ShareOutfitDialog` allowed sharing a private outfit → backend rejects non-`public` with 400; user-visible failure | `ensureShareUrl` throws before minting when private; visibility Switch refuses to turn off public with a destructive toast |
| F2b-02 | Med | `WardrobePage` URL filters leaked server-side: only `isFavorite` re-synced from URL; search/category/etc. stayed applied after navigating away/back | mount effect resets non-URL filters (`setFilters` + store `resetFilters`) |
| F2b-03 | Med | Generation failure set store `error`, hijacking `OutfitsPage` into "Couldn't load outfits" ErrorState | `startGeneration` catch no longer sets global `error`; failure message lives in `failedMap` |
| F2b-04 | Med | `CalendarPage` month-boundary query sent local dates against UTC-stored events (missing/duplicated edge days) | sends `formatDateOnly(new Date(start.toISOString()))` and end-of-month 23:59:59.999 UTC-date |
| F2b-05 | Med | `OutfitsPage` empty state dead-end when `hasMore` (no way to load further pages) | sentinel `InfiniteScrollSentinel` rendered under the EmptyState when `hasMore` |
| F2b-06 | Low-Med | calendar localStorage `connected` flag not per-user (user A's connection leaked to user B) | `calendarConnectedKey()` scoped by `getAccessToken() || 'anon'` |
| F2b-07 | Low | `useToast` listener re-registered on every toast change (`[state]`) | effect deps `[]` (stable setter); removed now-unused eslint-disable |
| F2b-08 | Low | `OutfitCreatePage` `?items=` prefill captured in an empty-deps effect (stale after draft edits) | `useRef` mounted-guard + deps `[prefill, resetOutfitDraft, setCreationItems]` + dedupe vs current `creationItems` |

## A10b — Flutter deep pass (12)

| ID | Sev | Finding | Fix |
|----|-----|---------|-----|
| A10b-01 | High | Calendar UTC double-shift: naive local strings parsed as UTC then `.toLocal()` again | `getEvents`/`createEvent`/update payload send `.toUtc().toIso8601String()` |
| A10b-02 | High | Wardrobe sort silently ignored — backend `list_items` had no sort params | backend `sort_by`(created_at\|name\|worn_count)/`sort_order`(asc\|desc) allowlist + `.order(...)`; Flutter passes them |
| A10b-03 | High | Dashboard Favorites pill mapped to nonexistent sort key | real `favoritesOnly` RxBool → `is_favorite=true` server filter |
| A10b-04 | High | `ItemEditPage` infinite spinner on load failure (no fallback/error) | `_loadItem()` via `fetchItemById` + `_loadFailed` error/Retry UI |
| A10b-05 | Med | Edit dialog seeded raw UTC hour and had no date picker | seeds `event.startTime.toLocal()`; date picker mirrors Add dialog |
| A10b-06 | Med | Batch save failures were debugPrint-only → false-success toast | `saveFailures` RxList + partial-success `showWarning` with failed names |
| A10b-07 | Med | Try-on downloaded raw expired presigned URL, no re-mint | catch → `ItemRepository().remintImageUrl(item.storagePath)` (primary image's key) once, rethrow if no fresh URL |
| A10b-08 | Med | Calendar `ever(focusedDate)` fetch race (stale response overwrote newer month) | monotonic generation token; stale responses dropped |
| A10b-09 | Low | Deep-link item/outfit merged into filtered `items` lists | `_hasServerSideFilters` getter gates merge in wardrobe + outfit list controllers |
| A10b-10 | Low→High | **Shared outfit page 404'd permanently**: Flutter called `GET /outfits/shared/{id}`, backend only has `GET /outfits/public/{id}`; model also demanded wrong keys (`item_images`/`outfit_images` String lists vs `images` rows) | repository path → `/public/$shareId` + transformation; model + generated files add `outfitStoragePath` (`outfit_storage_path`); page passes storagePath + remintUrl |
| A10b-11 | Low | Dead `showSocialDialogTrigger` field | removed field + its setter |
| A10b-12 | Low | `colors.first`/`conditions.first` truncation (latent) | comma-join multi values; backend OR'd `colors.cs.["x"]` containments + multi `condition` → `in_` |

## A3b — Backend AI/outfits deep pass (8)

| ID | Sev | Finding | Fix |
|----|-----|---------|-----|
| A3b-01 | High | Gemini breaker probe lacked auth header for `_NON_OPENAI_HOSTS` → Google 400s `GET /v1beta/models`, latching breaker for a healthy host | probe sends `x-goog-api-key` for non-OpenAI hosts (record_result cache keys already per-(host,key); verified, not re-fixed) |
| A3b-02 | Med | `clear_cache(base_url)` popped only the bare URL; keyed `{host}|{hash}` entries survived → ConnectError recovery no-op | `clear_cache` evicts every `{base_url}|`-prefixed key |
| A3b-03 | Med | Outfit item batch fetches not user-scoped (`_fetch_outfit` + `_list_outfits_data`) | `.eq("user_id", user_id)` on both queries |
| A3b-04 | Low | Astrology `missing_fields` only listed `birth_date` → users with a date silently stuck in vedic_lite with no hint | reports `birth_date`/`birth_time`/`birth_place` |
| A3b-05 | Low | Unbounded `_wear_locks` dict | replaced with `app.core.concurrency.KeyedLock` |
| A3b-06 | Low | `mark_worn` write not user-scoped + fabricated count on zero-row update | `.eq("user_id", user_id)` + `OutfitNotFoundError` on zero rows |
| A3b-07 | Low | `/ai/embeddings/search` accepted any-dimension vectors (wrong dim → 503); `min_score` default 0.5 | 422 `ValidationError` on dimension mismatch vs `PINECONE_DIMENSION` |
| A3b-08 | Low | `use_body_profile` nested under `include_user_face` (silently ignored when face off) | independent branch: re-queries users + body_profiles when requested regardless of face flag |

## Verification notes

- Backend suite was taken from 17 failing to green; failures were stale test expectations encoding the old buggy behavior (per-key breaker seeds, canonical source-key fixtures, A1-04/05 checkout guard message + active-status fixture, A1-01 hook-before-gate, A4-03 MFA-username removal, A3b-03 `.eq` mock chain, A3b-08 FakeDB users rows, `record_result` AsyncMock in two chat tests, referral route `neutral` kwarg stub).
- Flutter `outfit_model.freezed.dart` was regenerated via `dart run build_runner build` (33 outputs; only the outfit model changed); hand-edited `.g.dart` matched codegen byte-for-byte.
