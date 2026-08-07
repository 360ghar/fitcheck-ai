# Plan: Admin revenue analytics, trends page, CSV export polish

Status: active (implementation complete, deployment pending)
Started: 2026-08-07
Owner: agent

## Goal

Give the admin console three revenue/engagement reads the 040/041 data already
supports: a revenue strip on the dashboard (MRR split Stripe vs IAP, paid
counts, trials, churn, refunds), a daily time-series trends page
(`/dashboard/trends`, 30/90-day windows) covering signups, AI jobs, paid
subscriptions and AI-active users, and one-click CSV export on every list page
that lacked it (users, subscriptions, IAP, quotas, promo, feedback). Campaigns
(pro-trial upsell tooling) were explicitly removed from scope by the user.

## Non-goals

- Pro-trial campaign manager and bulk upgrade tooling (removed from scope).
- Ops/reliability ideas from the original menu (webhook dashboards, queue
  lags) — deferred.
- Any new admin permissions or RBAC changes: everything rides on
  `dashboards.read`.
- Real-time revenue data: MRR is an estimate computed from configured plan
  prices; store-billed rows never carry amounts.

## Acceptance criteria

- [x] Migration `041_admin_trends.sql` adds 4 service-role RPCs
      (`admin_trend_signups/_jobs/_paid/_active`) with the 040 hardening
      pattern (SECURITY DEFINER, locked `search_path`, EXECUTE revoked from
      browser roles).
- [x] `GET /api/v1/admin/dashboards/revenue` returns MRR total + Stripe/IAP
      split, paid subscription counts, active trials, 30-day churn + refund
      counts (lifecycle events from `stripe_webhook_events` + Apple
      `EXPIRED`/`REVOKE` + Google `SUBSCRIPTION_*` + `audit_events` refund
      actions), both behind `dashboards.read`.
- [x] `GET /api/v1/admin/dashboards/trends?days=30|90` returns zero-filled
      daily series for signups, AI jobs, paid subscriptions, AI-active users
      (distinct users with ≥1 durable job that day).
- [x] Dashboard shows a revenue strip card (MRR, paid, trials, churn,
      refunds hint) linking to the trends page.
- [x] Trends page with 30/90-day toggle persisted in URL search params and
      four charts (lazy-loaded recharts chunk).
- [x] CSV export (`shared/hooks/useCsvExport.ts` + `shared/lib/csv`) wired
      into users, subscriptions, IAP, quotas, promo, feedback toolbars with
      i18n keys.
- [x] Backend suite green (1306 passed / 4 skipped), admin suite green
      (27 files / 194 tests), lint + typecheck + build + `check:schema` clean,
      `docs/generated/db-schema.md` regenerated.

## Context / links

- Related docs: `docs/exec-plans/active/2026-08-07-admin-panel.md`
  (permissions matrix + endpoint inventory), `docs/BACKEND.md` (Admin API &
  RBAC section), `admin/README.md`
- Related code:
  - `backend/db/supabase/migrations/041_admin_trends.sql`
  - `backend/app/services/admin_service.py`, `backend/app/models/admin.py`
  - `backend/app/api/v1/admin/dashboards.py`
  - `admin/src/features/dashboard/{components/TrendsCharts.tsx,pages/TrendsPage.tsx}`
  - `admin/src/shared/hooks/useCsvExport.ts`
- Precedent: migration `040_admin_dashboard_rpcs.sql` (same security posture)

## Progress log

| Date | Note |
|------|------|
| 2026-08-07 | Spec approved (revenue + trends + CSV export; campaigns removed). |
| 2026-08-07 | Migration 041 + revenue/trends endpoints + models; backend tests green. |
| 2026-08-07 | Revenue strip on dashboard; trends page + charts; nav + i18n. |
| 2026-08-07 | useCsvExport wired into 6 list pages; export tests incl. new promo/feedback handlers + page tests. |
| 2026-08-07 | Full verification (pytest 1306/4, vitest 194, lint, typecheck, build, check:schema, db-schema regen). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-07 | Campaign manager dropped from plan | User explicitly removed it. |
| 2026-08-07 | Trends RPCs as SQL functions (not service-side queries) | Matches 040 precedent; zero-fill and daily bucketing are cheaper in SQL. |
| 2026-08-07 | "AI-active users" = distinct users with a durable job row that day | `users.last_login_at` is a snapshot, not a daily series. |
| 2026-08-07 | MRR estimated from `PLAN_AMOUNTS` (yearly amortized) | Store receipts carry no amounts; documented as estimate in UI copy. |
| 2026-08-07 | Churn counted from lifecycle webhook events + refund audit actions | Same event tables the webhook pipeline writes; no new ingestion. |
| 2026-08-07 | Google RTDN webhook stores the mapped notification type name (`notification_type_name`), not a blanket `'rtdn'` label | Review found `GOOGLE_CHURN_EVENT_TYPES` could never match a literal `'rtdn'`, making Google churn permanently 0; the fix mirrors Stripe (raw type) and Apple (raw notificationType). Pre-fix rows stay invisible to churn (type not recoverable). |
| 2026-08-07 | `admin_trend_active` counts all four job tables, extraction included | Review found extraction-only users were missing from "AI-active users" while extraction still appears in the jobs series. Migration 041 edited in place; already applied to hosted Supabase (the PGRST202 hint later referenced the `p_days` signature), so the edit must be re-applied for the active-users series to include extraction. |
| 2026-08-07 | RPC call site passes `p_days` (was `days`) | Live `/trends` 500'd with PGRST202: PostgREST matches RPC args by parameter name; the migration functions declare `p_days` (migration was already applied — the hint referenced the `p_days` signature). Tests now assert the `p_days` shape so it cannot regress. |
| 2026-08-07 | Trends windows widened to 7/15/30/90 days | User request ("1 week, 15 days, 30 days, 90 days"). One backend constant (`TREND_DAYS_CHOICES`) + frontend tab list; RPCs already accept any `p_days`. Contract re-exported. |
| 2026-08-07 | Migration 041 UNION functions qualify outer columns with alias `s` | Live verification of the fixed call site exposed Postgres 42702 ("column reference `day` is ambiguous") in `admin_trend_jobs/_paid/_active`: `RETURNS TABLE` out-params shadow the subquery's `day` column. 040 is unaffected (no subqueries). **Re-apply 041 to hosted Supabase** (`CREATE OR REPLACE` swaps bodies; signature unchanged) and sanity-check with `SELECT public.admin_trend_jobs(30)`. |
| 2026-08-07 | Churn counts select each ledger's real PK (`event_id` / `notification_id` / `message_id`), never `id` | Live `/dashboards/revenue` 500'd with Postgres 42703 ("column stripe_webhook_events.id does not exist"): the three webhook dedupe tables have no `id` column — their PK is the provider's own event ID (022/030). Unit tests missed it because `FakeDB.select()` never validates columns; the fake now records every select (`db.selects`) and the revenue test pins the three PK columns so this cannot regress. No migration needed; deploy the backend fix. |

## Verification

```bash
cd backend && source .venv/bin/activate && python -m pytest -q   # 1306 passed, 4 skipped
cd admin && npm run lint && npm test && npm run build && npm run check:schema
python scripts/generate_db_schema_doc.py && python scripts/check_docs_structure.py
```

## Deferred debt

- Playwright e2e for the admin console (incl. revenue strip + trends page)
  remains pending from the admin-panel plan.
- Revenue estimate could be made exact later by capturing provider prices
  (e.g. subscription `amount` fields) — tracked as an estimate for now.
