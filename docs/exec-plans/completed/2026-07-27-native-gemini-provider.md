# Plan: Native Gemini provider + registry-driven AI provider dispatch

Status: completed
Started: 2026-07-27
Completed: 2026-07-27

## Goal

RCA of a Railway production log surfaced two errors: startup `Config issue`
warnings, and every vision request 401-ing against Google's native Gemini
endpoint before falling back to Agnes. Root cause: `AI_VISION_API_URL` was
pointed directly at `generativelanguage.googleapis.com`, which is not
OpenAI-compatible.

Rather than just fixing the misconfiguration, the goal became: make native
Gemini chat/vision/image generation a real, first-class, registry-dispatched
provider (`AIProvider.GEMINI`) alongside the existing OpenAI-compatible path
(Agnes/OpenAI), using the async `google-genai` SDK directly — not another
OpenAI-shaped HTTP config entry.

## Why this, not just an env var fix

Direct Gemini chat/vision existed in this codebase before and was
**deliberately removed** (commit `74ce4d2`, migration
`018_default_ai_provider_custom.sql`) because that attempt sent Gemini
requests through the same OpenAI-shaped Bearer-auth HTTP client
(`AI_GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta"`),
which is fundamentally wrong — Google's SDK authenticates via `x-goog-api-key`,
not Bearer, and speaks a different request/response shape entirely. This pass
builds a *real* second implementation instead of repeating that mistake.

## Non-goals (explicit, deferred to `tech-debt-tracker.md`)

- No cross-provider fallback for Gemini (Gemini-model-to-Gemini-model only).
- No OpenAI `response_format` json_schema → Gemini `response_schema`
  translation (both `json_object` and `json_schema` map to
  `response_mime_type="application/json"` only).
- No health-check circuit breaker for Gemini (bypasses
  `ai_provider_health_service` entirely — a bad key/model/quota surfaces from
  the real `generate_content()` call itself).
- No frontend changes (provider selector in `AISettingsPanel.tsx` for
  testing/choosing Gemini via the UI) — backend contract is
  backward-compatible (`TestProviderRequest.provider` defaults to `"custom"`).

## Acceptance criteria

- [x] `app/utils/parallel.py` logging crash fixed (`logger.warning(..., item_index=...)`
      → `extra={...}`) — root cause of 4 pre-existing failing tests.
- [x] Already-staged (uncommitted at start of this pass) AI-provider defensive
      fix reviewed and committed separately (`0d829f1`) before this feature's
      diff, keeping it isolated.
- [x] `AIProviderClient` Protocol + `PROVIDER_REGISTRY` (`app/services/ai_provider_interface.py`)
      — `AIProvider` enum, `ChatMessage`, `AIResponse` moved here (re-exported
      from `ai_provider_service.py` for backward compatibility).
- [x] `AIProviderService` registered under both `OPENAI` and `CUSTOM`
      (`config_cls = ProviderConfig`); `get_system_provider_config()` /
      `get_ai_service()` are registry-driven, not if/elif.
- [x] `GeminiProvider` (`app/services/gemini_provider.py`) — chat/vision/image
      via `client.aio.models.generate_content` (async, not the sync surface
      `ai_service.py`'s embeddings code incorrectly uses), safety-block and
      truncation guards, retryable-status classification via `APIError.code`.
- [x] `AISettingsService.get_effective_provider_config` /
      `get_ai_service_for_user` / `test_provider_config` registry-driven;
      BYOK JSONB storage needed **no migration** (`provider_configs` already
      keyed by provider-name string; literally had a `"gemini"` key before
      `74ce4d2`).
- [x] Settings surface: `config.py` new `AI_GEMINI_*` settings, `.env.example`,
      `valid_providers` lists derived from the registry, `TestProviderRequest.provider`
      discriminator (default `"custom"`, backward compatible with the one
      real frontend caller: `frontend/src/api/ai.ts:475`), `AvailableModelsResponse.gemini`,
      `config_health.py` Gemini-key check, `docs/BACKEND.md`.
- [x] Dead `AIProviderEnum` (`models/ai.py`) deleted — re-confirmed
      zero-importer via fresh grep immediately before deleting.
- [x] Tests: `tests/test_gemini_provider.py` (43 cases), `tests/test_ai_provider_interface.py`
      (conformance), `tests/test_ai_settings_service.py` (new — no file
      existed for this service before; covers the registry dispatch this
      pass introduced, plus a regression guard for a stale pre-`74ce4d2`
      OpenAI-shaped `"gemini"` BYOK row).
- [x] Real, unmocked end-to-end verification against the actual `AI_GEMINI_API_KEY`:
      `gemini-3.6-flash` correctly answered a vision question about a
      generated test image, `provider: google-genai` confirming zero Agnes
      involvement.
- [x] Full backend suite green (386/386), `ruff check` clean on all changed
      files, `scripts/check_architecture.py` and `scripts/check_docs_structure.py`
      pass.

## Context / links

- Related docs: `docs/BACKEND.md` ("AI provider system" section), `backend/.env.example`.
- Related code: `app/services/ai_provider_interface.py`, `app/services/ai_provider_service.py`,
  `app/services/gemini_provider.py`, `app/services/ai_settings_service.py`,
  `app/core/config.py`, `app/core/config_health.py`, `app/models/ai.py`,
  `app/api/v1/ai_settings.py`, `app/api/v1/ai.py`.
- Prior removal: commit `74ce4d2` (`fix: resolve production log root causes...`),
  migration `018_default_ai_provider_custom.sql`.
- Prior related fix (committed separately, `0d829f1`): Bearer-auth skip +
  forced fallback for non-OpenAI hosts in `ai_provider_health_service.py` /
  `ai_provider_service.py`.

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-27 | Registry dispatch (`PROVIDER_REGISTRY` dict + `@register_provider`), not a full package reorg of `ai_provider_service.py` into a `providers/` directory | Genuine modularity (one class + one registration line per new provider) without relocating ~800 lines of already-working, tested code nobody asked to move |
| 2026-07-27 | Keep `AI_VISION_API_URL` misconfiguration as a manual Railway env var fix, not an automatic code-level "neutralize the bad URL" | User explicitly chose "warn only" over "neutralize + warn" when asked — config_health.py's existing startup check already gives operator visibility |
| 2026-07-27 | No `response_schema` translation for OpenAI `json_schema` contracts | Every current caller passes either `json_object` or nothing; the OpenAI schema dialect (`["string","null"]` unions, `additionalProperties: false`) isn't valid in Gemini's OpenAPI-3.0 subset anyway |
| 2026-07-27 | `GeminiProvider` bypasses `ai_provider_health_service` entirely (no pre-flight probe) | Google's endpoint is a stable multi-tenant SaaS, not a self-hosted proxy that can be down independently of a given request; a bad key/quota surfaces identically and immediately from the real call |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest -q                                  # 386 passed
ruff check app/services/gemini_provider.py app/services/ai_provider_interface.py \
  app/services/ai_provider_service.py app/services/ai_settings_service.py \
  app/api/v1/ai_settings.py app/api/v1/ai.py app/models/ai.py app/core/config.py \
  app/core/config_health.py app/utils/parallel.py tests/test_gemini_provider.py \
  tests/test_ai_provider_interface.py tests/test_ai_settings_service.py
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`: TD-026, TD-027, TD-028.

## Outstanding (not applied by this pass — requires Railway dashboard access)

- Set `AI_VISION_API_URL` blank in Railway production env (currently
  `https://generativelanguage.googleapis.com/v1beta`).
- Set `AI_ENCRYPTION_KEY` in Railway production env (`openssl rand -hex 32`).
- Everything in this plan except commit `0d829f1` is uncommitted in the
  working tree pending explicit commit approval.
