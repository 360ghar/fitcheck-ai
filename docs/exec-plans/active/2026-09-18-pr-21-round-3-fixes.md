# Plan: PR 21 round-3 review fixes

Status: active  
Started: 2026-09-18  
Owner: agent

## Goal

Address every still-valid PR #21 review thread (30 bot comments across backend,
admin, campaign, docs) on `feat/admin-generations-prod-rca-fixes`: 3 older qodo
highs were already fixed on HEAD and get resolve-with-note replies only; 4 human
threads stay deferred to TD-111/TD-112.

## Non-goals

- TD-111 (persisted promotion record) and TD-112 (thin-route refactor, ~half day).
- Live Stripe price fetch for `subscription.amount` (needs a new
  `stripe.Subscription` call; kept as a settings mirror with a code comment).
- Ownership-token CAS for IAP ledger (needs a schema column; documented residual).

## Acceptance criteria

- [x] Batch 1: outfit-name lookup owner-scoped, photoshoot `failed_count` deduped, billing empty-row guard
- [x] Batch 2: overload 2s floor reachable (chat + images legs), host:port overload key, 10s same-host floor gated on overload text, `clear_cache` releases host deadlines + sweeps expired, fail-fast carries `retry_after_seconds`, admission test covers second key
- [x] Batch 3: rebuild builds before swapping state, IAP reclaim `max_retries=0` + re-read before ACK (double miss 500s), batch gate fails closed on post-status (`provider_status`) overload text
- [x] Batch 4: MediaGallery remount key, stable extracted-item keys, ItemsGrid stable-id selection + valid button markup, clipboard guard, card thumbnail fallback, fixture `failed_count: 1` + per-card assertion, e2e mock `user_id`/counts, anchored back-URL regex, awaited back-link
- [x] Batch 5: tracker header TD-030–TD-112, TD-110/TD-111 wording, campaign doc reads-audit + `.venv/bin/python`, referral `quote()` + HTML-escape, `urlparse` ValueError fallback
- [x] Verification green (see below)

## Context / links

- PR: <https://github.com/360ghar/fitcheck-ai/pull/21>
- Raw threads: `/tmp/pr21_review.json` (150 inline), `/tmp/pr21_latest.md` (newest 30)
- Approved spec: `~/.factory/specs/2026-09-18-pr-21-round-3-fix-30-validated-review-threads.md`

## Progress log

| Date | Note |
|------|------|
| 2026-09-18 | Validated 33 threads (30 VALID, 3 FIXED_ALREADY), spec approved, all 5 batches implemented |
| 2026-09-18 | Fixed self-caused syntax error (connection.py line merge); updated 4 tests that pinned old behavior (photoshoot double-count, batch text-only gate understanding refined via provider_status, IAP blind-ACK) |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-18 | Batch gate uses `provider_status` discriminator instead of dropping text-only overload retry | Round-2 tests pin bare-overload retry; HTTPStatusError path is the only post-accept source and always sets `provider_status` |
| 2026-09-18 | IAP double CAS miss raises 500 instead of ACKing | Fail closed so the store redelivers; matches the file's insert-path contract |

## Verification

```bash
cd backend && source .venv/bin/activate && python -m pytest tests/integration/test_admin/test_admin_user_generations.py tests/unit/test_services/test_ai_provider_health_service_coverage.py tests/unit/test_services/test_batch_extraction_service_coverage.py tests/unit/test_utils/test_db_connection_coverage.py tests/unit/test_utils/test_db_connection_retry.py tests/integration/test_iap_routes_coverage.py tests/unit/test_scripts/test_campaign_scripts.py -q -p no:cacheprovider --no-cov
# 168 passed
cd backend && source .venv/bin/activate && ruff check app/ scripts/
cd admin && npm run lint && npm run typecheck && npm test -- --run && npm run check:schema
# 240 passed, lint/typecheck/schema clean
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-111 / TD-112 wording corrected, not resolved (see Non-goals)
