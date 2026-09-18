# Plan: Admin user detail — generations explorer/viewer + billing/referrals/body profile

Status: active
Started: 2026-09-18
Owner: agent / human

## Goal

Make the admin user detail page show everything the product has generated for
a user — not just outfit covers and photoshoot text rows. All AI generation
kinds (item extractions, outfits, outfit render runs, photoshoots, social
imports) surface in one paginated explorer with status filter; every card
opens a full-page viewer (`/users/:id/generations/:kind/:generationId`)
showing exactly what was generated (media gallery, metadata, errors, source
ids). The page also gains three support sections chosen from the shortlist:
Billing history, Referrals & promo redemptions, and Body profile.

## Non-goals

- AI provider / model settings section on the user page (declined).
- Any write operations — everything here is read-only (no retry, no delete).
- Changing how generations are produced or stored; this is a read-model only.
- Mobile/frontend app changes.

## Acceptance criteria

- [x] One normalized generation contract across all 5 kinds
      (`kind, id, status, created_at, completed_at, duration_ms, title,
      subtitle, media[], media_count, failed_count, error, meta, source`).
- [x] Every `*_base64` key stripped before leaving the backend.
- [x] Presigned image URLs re-minted at read time (`key_from_path` →
      `parse_key` gate → `StorageService.get_public_url`); foreign URLs pass
      through untouched; ephemeral `tmp/` photoshoot objects degrade to an
      unavailable placeholder.
- [x] `GET /users/{id}/generations` with `kind` (incl. `all`), `status`,
      `page`, `page_size` ≤ 50; exact per-kind counts; `kind=all` merges
      recent per-kind windows sorted by `created_at`.
- [x] `GET /users/{id}/generations/{kind}/{generation_id}` — ownership
      enforced (foreign ids 404, not cross-user leaks).
- [x] User detail payload carries the 4 kind counts.
- [x] Billing endpoint: Stripe invoices via `Invoice.list(customer=…)` +
      subscription; IAP rows only when the caller holds `iap.read`.
- [x] Referrals endpoint: code, redemptions with referred identity (bounded
      `in_` lookup), promo redemptions.
- [x] Body-profile endpoint: profiles + gender, never `encrypted_data`.
- [x] Admin UI: explorer tabs/status/pagination in URL state; viewer with
      gallery + thumbnail strip, broken-image fallbacks, meta rows, source
      ids, extracted-items / import-photos lists; items grid tiles open a
      dialog with all images + source photo.
- [x] New sections render with permission gating (billing hidden without
      `subscriptions.read`).
- [x] Contract regenerated end-to-end (`openapi.json` → `schema.d.ts` →
      `api-spec.md`) + flat aliases in `schemaTypes.ts`.
- [x] Backend: 19 new tests (16 + outfits/status guard, all+status total,
      photoshoot by-id beyond window); admin: 9+ new component/page tests
      (incl. invoice-date regression), MSW fixtures/handlers for all 5
      endpoints, e2e users journey extended.
- [x] Stripe invoice timestamps normalized to ISO-8601 UTC (unix-seconds
      rendered as January 1970 by `new Date(n)` consumers); MSW fixture +
      invoice-date test updated.
- [x] Viewer fetches photoshoots by id (any age), not via the recent window.
- [x] Social-import photo queries fan out concurrently (no N sequential
      round trips on full pages).

## Context / links

- Related docs: `docs/ADMIN.md` ("User detail: generations + context"),
  `docs/BACKEND.md` ("Admin API & RBAC"),
  `docs/exec-plans/active/2026-08-07-admin-panel.md` (endpoint inventory).
- Related code: `backend/app/services/admin_user_generations_service.py`,
  `backend/app/api/v1/admin/users.py`,
  `admin/src/features/users/components/GenerationsExplorer.tsx`,
  `admin/src/features/users/pages/GenerationDetailPage.tsx`,
  `admin/src/features/users/components/{BillingCard,ReferralsCard,BodyProfileCard}.tsx`.
- Replaces: `admin/src/features/users/components/OutfitsGallery.tsx` (deleted).

## Progress log

| Date | Note |
|------|------|
| 2026-09-18 | Backend service + 5 routes + models landed; 16 backend tests green |
| 2026-09-18 | Contract regenerated; admin hooks/components/pages/i18n landed; 240 unit tests, lint/typecheck green |
| 2026-09-18 | E2E users journey extended (explorer → viewer); 14/14 Playwright tests pass |
| 2026-09-18 | Docs updated (ADMIN.md, BACKEND.md, admin-panel inventory, TD-110) |
| 2026-09-18 | Review pass: invoice 1970-date bug, outfits+status filter gap, unfiltered all+status total, photoshoot viewer window limit, social-import N+1 — all fixed + regression tests; contract re-exported |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-18 | Normalized single generation contract instead of per-kind shapes | One renderer for 5 kinds; the viewer stays generic |
| 2026-09-18 | Counts both in user detail AND paginated endpoint | Detail page shows kind counts without fetching lists; explorer pages server-side |
| 2026-09-18 | Full-page viewer route, not a dialog | Media galleries need space; deep-linkable, refresh-stable |
| 2026-09-18 | Read-time URL re-minting duplicated in the new service (not shared with `materialize_image_urls`) | `materialize_image_urls` is a dashboard hot-path function; the admin reads are one-user-at-a-time (TD-110) |
| 2026-09-18 | Billing IAP rows gated on a second permission (`iap.read`) | Mirrors the existing permission vocabulary instead of inventing a combined one |
| 2026-09-18 | Outfits excluded (not error) under a status filter; counts/total honor the filter | `outfits` has no status column — error-path "handling" would spam warnings and diverge between FakeDB and PostgREST; explicit guard returns `([], 0)` |
| 2026-09-18 | Invoice timestamps normalized server-side to ISO-8601 | Stripe sends unix seconds; every other API datetime is ISO and the admin `toDate` treats numbers as millis — normalizing at the source fixes all consumers, no contract shape change (`Dict[str, Any]`) |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest tests/integration/test_admin tests/unit -q && ruff check .
python scripts/check_architecture.py && python scripts/check_docs_structure.py
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema && npm run check:bundle
cd admin && npm run e2e
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-110 — read-time presign logic duplicated between admin generations
  service and `admin_service.materialize_image_urls`.
