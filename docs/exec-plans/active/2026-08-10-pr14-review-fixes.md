# Plan: PR #14 review fixes — 40 cubic findings

Status: completed
Started: 2026-08-10
Owner: agent

## Goal

Validate all 40 `cubic-dev-ai` review findings on PR #14 (backend A3–A5 + frontend F1 hardening, commit `0ea249d`), fix every valid one, and keep the full verification gate green.

Validation result: **38 VALID, 2 PARTIALLY VALID, 0 invalid.** Both partially-valid findings are substantively real (frontend #5 cited the wrong line — the 67-char key is generated in `outfitStore.ts`, not `api/outfits.ts`; 045's RPC is atomic in isolation but image-insert + primary-reassign were two separate transactions). Finding 046 (bucket privatization) was already resolved by commit `1f62b40` (migration 048 drops legacy buckets instead; `backend/scripts/backfill_storage_paths.py` exists); only the anonymous share-link residual is handled defensively via docs.

## Non-goals

- No new product features beyond the review findings.
- No changes to `main`; all fixes land on `fix/full-bug-sweep-241`.

## Fixes landed

### Migrations (new forward migrations for already-shipped files; in-place edits for unshipped PR migrations)

| Migration | Fix |
|-----------|-----|
| 049 `fix_redeem_promo_atomic_null_stripe` | `redeem_promo_atomic` nulls `stripe_subscription_id`/`stripe_customer_id` on promo redemption (A1-09) — shipped 032 lacked the assignments |
| 050 `fix_referral_credit_no_banking` | `apply_referral_credit_atomic` no longer banks months on trial grants (A1-02 double-grant) |
| 051 `add_referral_redemptions_credit_months` | `credit_months` column for `get_referral_stats` on deployed DBs |
| 052 `iap_identifier_ownership` | partial unique indexes on `apple_original_transaction_id` / `google_purchase_token` — atomic claim for concurrent IAP registrations (A1-01) |
| 053 `extraction_jobs_reserved_generations` | durable column so batch generation reservations survive restarts and are reconciled |
| 054 `drop_overbroad_blog_manage_policy` | drops `FOR ALL TO authenticated USING(true)` on `blog_posts` (any signed-in user could CRUD every post via PostgREST) |
| 017 (in-place) | no longer creates the over-broad blog policy for fresh installs |
| 044 (in-place) | `remove_outfit_item` returns INTEGER status; enforces >=1 member UNDER the row lock (concurrent removals can't persist `item_ids=[]`) |
| 045 (in-place) | new `add_outfit_image_and_set_primary` RPC: image insert + primary reassignment in ONE transaction (two-primaries window) |
| 047 (in-place) | unique index predicate now excludes soft-deleted items (`is_deleted = FALSE`) so a fresh create after delete takes the insert path |

### Backend services
- `subscription_service.py` — banked-credit claim re-checks still-effectively-free at write time (A1-08); Stripe sync + `upgrade_to_pro` skip when a live store entitlement is active (A1-05).
- `admin_service.py` — refund resolves the subscription's OWN charge (`latest_invoice` then subscription-linked `Invoice.list`); fails closed (404) instead of refunding an unrelated later customer purchase.
- `batch_job_service.py` / `batch_processing.py` — reservation persisted at admission, restored in `_hydrate`, released when a recovered non-terminal job is evicted.
- `social_import_pipeline_service.py` — capacity-pause releases generation reservation for unattempted items before requeue.
- `ai_provider_service.py` — a CDN download failure after a successful image API call no longer opens the provider circuit.
- `gemini_provider.py` — manual redirect loop bounded (`_MAX_REMOTE_IMAGE_REDIRECTS = 5`).
- `auth.py` — login syncs `users.email_verified` from `email_confirmed_at` so confirmed users stop deferring referral grants forever.
- `ip_rate_limit.py` — pruning uses per-operation window cutoffs; an auth check can no longer evict still-valid 24h demo reservations (demo quota reset via auth request).
- `object_storage.py` — `exists()` classifies `NoSuchKey` as absent.
- `storage_keys.py` — allowlist includes every extension StorageService can mint (`bmp|tif|tiff|heic|heif`), mirrored in `infra/images-worker/worker.js`.

### Backend API
- `iap.py` — duplicate-ledger read failure raises 500 (store retries) instead of acking; concurrent same-transaction registrations map the migration-052 23505 to the existing "already used on another account" validation error.
- `items.py` — public `worn_count` sort maps to the real `usage_times_worn` column (PostgREST was rejecting the query).
- `calendar.py` — event update loads existing time/all-day fields and validates whenever any window field is supplied.
- `social_import.py` / `social_oauth_service.py` / `social_auth_service.py` — server-side multi-account picker: callback persists the exchanged token (`selection_pending` session) and renders a picker page; new `POST /social-import/jobs/{id}/auth/oauth/select-page` (signed selection token) resolves identity from the chosen page and resumes the import. No web/flutter client changes needed.

### Frontend
- `outfitStore.ts` / `wardrobeStore.ts` / `subscriptionStore.ts` — `resetEpoch` session guard: responses from requests begun before logout/reset are discarded.
- `outfitStore.ts` — preview idempotency key shortened to `pv-…` (≤64 chars, the backend Form limit).
- `WardrobePage.tsx` — search refetches server-side (debounced) so page 1 and page N are filtered identically (no more skipped matches mid-pagination).
- `CalendarPage.tsx` — month bounds use UTC date components (`toISOString().slice(0,10)`), fixing the local-getter round-trip that dropped month-boundary events.

### Flutter
- `wardrobe_controller.dart` — `clearAllFilters()` also clears `favoritesOnly` (matches OutfitListController); fetched single item held in `fetchedItem` so deep links render under filters.
- `item_detail_page.dart` — renders `fetchedItem` when the id isn't on the loaded page (fixes the infinite detail shimmer).
- `calendar_event_model.dart` — naive (Z-less) stored timestamps parsed as UTC (the columns hold UTC wall-clock; `DateTime.tryParse` was treating them as local).
- `calendar_controller.dart` — generation reserved BEFORE the first await so navigation during a build frame invalidates an in-flight request.

### Infra
- `infra/images-worker/worker.js` — `SUPABASE_JWT_SECRET` no longer required (JWKS-only deployments); HS256 rejected indistinguishably when it's absent. Tests updated.

### Scripts
- `scripts/check_migrations.py` — rejects `FOR ALL TO PUBLIC/anon/authenticated` and requires service-role policies to be `TO service_role` exactly (or auth.role() guarded).

## Acceptance criteria

- [x] All 40 findings validated; 38 valid + 2 partially valid, all fixed.
- [x] Backend `pytest` full suite green (3897 passed, 4 skipped).
- [x] Backend `ruff` clean.
- [x] Frontend vitest (277 passed), lint (0 warnings), production build green.
- [x] Flutter analyze + tests green.
- [x] `scripts/check_migrations.py` green on all 55 migrations.
- [x] images-worker node tests (53) green.

## Context / links

- PR: https://github.com/360ghar/fitcheck-ai/pull/14
- Review findings: cubic `cubic-dev-ai` review + inline comments on PR #14.

## Progress log

| Date | Note |
|------|------|
| 2026-08-10 | Validated all 40 findings; implemented fixes across migrations, backend, frontend, flutter, infra; full verification green |

## Verification

```bash
python3 scripts/check_migrations.py
cd backend && source .venv/bin/activate && ruff check app tests scripts && pytest
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
cd flutter && flutter analyze && flutter test
cd infra/images-worker && node --test worker.test.mjs
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- The `items.py`/`wardrobe` "most worn" ordering still depends on `usage_times_worn` being populated (wear-tracking granularity unchanged).
- Instagram picker is server-rendered HTML (no native picker UI in the web/flutter clients yet); the `submit_oauth_auth` API path remains for programmatic clients.
- Batch reservation reconciliation is best-effort (durable column + eviction release); a periodic sweep of stale non-terminal rows was NOT added.
