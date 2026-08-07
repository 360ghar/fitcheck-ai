# Plan: Dashboard image materialization + activity thumbnails

Status: active
Started: 2026-08-05
Owner: agent

## Goal

Fix the mobile Home page so "Today's Suggestions" (outfit of the day) and
"Recent Activity" show real images. Root cause: after the 2026-08-04 Railway S3
bucket migration, image URLs are short-lived presigned GET URLs that must be
regenerated at read time from the durable `storage_path` DB key (canonical
pattern: `materialize_image_urls` in `backend/app/api/v1/images.py`, used by the
items/outfits list endpoints). The mobile-only `GET /users/dashboard` handler in
`backend/app/api/v1/users.py` was missed:

- `_get_outfit_of_the_day` returned the raw DB `image_url`/`thumbnail_url`
  (expired presigned URL or legacy Supabase URL whose bucket was purged) — the
  card image never loads.
- `_build_recent_activity` returned no image field at all, so the mobile
  activity feed had no thumbnail to render.

Same-class gap fixed in the same change: `GET /outfits/available-items`
(used by picker grids) also read raw URLs without materialization.

**Self-review extension (2026-08-05):** a full sweep of the backend found the
same root cause on every remaining read path that surfaces image URLs:
`recommendations.py` (match, complete-look, personalized, astrology, similar,
capsule) and the secondary items/outfits paths (`by-category`, `search`,
`update` responses, duplicate check, find-similar, public share,
`recently-worn`, `favorites`, `weather-suggestions`, add/remove item from
outfit). All now materialize fresh presigned URLs at read time.

## Non-goals

- No change to web (its dashboard builds "Recent items" from the materialized
  items list and is unaffected).
- No storage/backend architecture changes; only read-path materialization.
- No migration of legacy rows without `storage_path` (they keep their stored
  URL; the materialization helper already handles that case).

## Acceptance criteria

- [x] `_get_outfit_of_the_day` selects `storage_path` and materializes a fresh
      presigned URL before returning `image_url`.
- [x] `_build_recent_activity` returns `image_url` per activity entry
      (primary/first image, thumbnail preferred, fresh presigned URL).
- [x] `GET /outfits/available-items` materializes per-row item images.
- [x] All recommendations read paths and the secondary items/outfits read
      paths materialize fresh presigned URLs before returning images.
- [x] Backend tests cover materialization (fresh URL wins over stale stored
      value; legacy row without `storage_path` keeps stored URL) for the
      dashboard, available-items, recommendations match, and the secondary
      items/outfits read paths.
- [x] Flutter `DashboardActivity` parses `image_url`; activity rows render a
      44x44 rounded thumbnail with the icon-circle fallback.
- [x] Docs: `docs/references/api-spec.md` dashboard payload updated; this plan
      filed per PLANS.md (cross-app change).

## Context / links

- Related code: `backend/app/api/v1/users.py` (`_build_recent_activity`,
  `_get_outfit_of_the_day`, `get_dashboard`), `backend/app/api/v1/outfits.py`
  (`available_items`), `backend/app/api/v1/images.py` (`materialize_image_urls`),
  `flutter/lib/features/dashboard/models/dashboard_models.dart`,
  `flutter/lib/features/dashboard/widgets/activity_feed.dart`.
- Related docs: `docs/exec-plans/completed/2026-08-04-railway-bucket-migration-contract.md`
  (storage contract: DB stores `storage_path`, URLs materialized at read time),
  `docs/references/api-spec.md` (dashboard payload).
- Related issues: user report — Home page Today's Suggestion + Recent Activity
  images don't load in the mobile app.

## Progress log

| Date | Note |
|------|------|
| 2026-08-05 | Diagnosed: dashboard read paths missed read-time URL materialization after the S3 migration. Implemented backend + tests, Flutter model/widget, docs. |
| 2026-08-05 | Self-review sweep found the same root cause on every remaining URL-surfacing read path: recommendations (8 endpoints) and secondary items/outfits paths (by-category, search, update responses, duplicate check, find-similar, public share, recently-worn, favorites, weather-suggestions, add/remove item from outfit). All fixed with the same materialization pattern; regression tests added in `tests/test_read_path_url_materialization.py`. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-05 | Reuse `materialize_image_urls` (images.py) instead of calling `StorageService.get_public_url` inline | One shared serving path; helper already refreshes both `image_url` and `thumbnail_url` and skips rows without `storage_path`. |
| 2026-08-05 | `available-items` fixed in the same change | Identical root cause (raw URL read without materialization); one-line-class fix with a regression test. |
| 2026-08-05 | Extended the fix to all recommendations and secondary items/outfits read paths found in the self-review sweep | Same root cause from the 2026-08-04 migration; leaving them would serve expired URLs to mobile/web in every secondary surface (search, favorites, share links, duplicate check, recommendations). |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest                          # 962 passed, 1 skipped
ruff check app/api/v1/ tests/   # clean

cd flutter
flutter analyze                 # no issues
flutter test                    # 131 passed
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None.
