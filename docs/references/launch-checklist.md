# Development: Production Hygiene Checklist

> Compact production-hygiene checklist (2026-08-08). Replaces the older
> detailed pre-launch checklist. For depth see `docs/RELIABILITY.md`
> (operations) and `docs/SECURITY.md` (security model). Storage is
> S3-compatible object storage (R2), not Supabase Storage; schema readiness
> is gated by `GET /ready`.

## Production hygiene

- [ ] Apply **all** migrations from `backend/db/supabase/migrations/` in
      numeric order (001..042, 43 files) on the hosted Supabase instance;
      verify `GET /ready` returns `"schema_ready": true` (it fails closed on
      gaps).
- [ ] Check the boot log for config-health issues (startup validation in
      `backend/app/core/config_health.py` — e.g. missing
      `AI_ENCRYPTION_KEY`, wrong `FRONTEND_URL`, non-OpenAI
      `AI_VISION_API_URL`).
- [ ] Weekly storage routine: dry-run `backend/scripts/storage_inventory.py`
      (orphan/missing-object report) and `backend/scripts/cleanup_temp_assets.py`
      (temp-preview cleanup), review the report, then re-run both with
      `--delete` (both default to dry-run).
- [ ] Confirm `IMAGE_SERVING_MODE` (`presigned` | `worker`) and thumbnail
      state: `THUMBNAIL_SERVING` / `THUMBNAILS_BACKFILLED` in
      `backend/app/core/config.py` — run
      `backend/scripts/generate_thumbnails.py` to backfill before enabling
      thumbnail serving.
- [ ] Sandbox IAP testing per `docs/store/ios-sandbox-testing-runbook.md`.
- [ ] Env: `OBJECT_STORAGE_*` (R2) configured, `BACKEND_CORS_ORIGINS` and
      `FRONTEND_URL` correct; RLS policies verified.
- [ ] AI limits / quotas reviewed (`PLAN_*` in `backend/app/core/config.py`).
- [ ] Privacy Policy and Terms of Service published; email templates (signup,
      password reset) verified in Supabase.
- [ ] Launch day: manual smoke test; monitor backend logs, AI provider
      usage/quotas, and `GET /ready`.
