# Plan: Hybrid vision leg (Agnes chat + native Gemini vision + Agnes vision-fallback)

Status: completed
Started: 2026-07-27
Completed: 2026-07-27

## Goal

Enable this specific mixed AI configuration:
```
AI Chat model:            Agnes 2.5 flash
AI Vision Model:          gemini 3.6 flash   (direct to Google, not via Agnes)
AI Vision Fallback Model: Agnes 2.5 flash
```
Chat and vision-fallback stay on the existing Custom/Agnes provider; only the vision leg's
*primary* call is routed directly to Google's native Gemini API (using the `GeminiProvider`
built in the prior pass), falling back to Agnes if that direct call fails.

## Why

The prior pass in this session (`docs/exec-plans/completed/2026-07-27-native-gemini-provider.md`)
built `GeminiProvider` as a first-class, registry-dispatched provider, but deliberately deferred
cross-provider fallback (TD-026): `GeminiProvider.chat_with_vision()` can only fall from one
Gemini model to another Gemini model, never to a different vendor entirely. Explicitly asked
whether the new vision leg should route through Agnes's proxy (zero new code — `gemini-3.6-flash`
is already reachable through Agnes) or hit Google directly, the answer was direct-to-Google —
which requires genuinely new capability: one logical provider config whose vision leg can be
routed to a different provider implementation than its chat/fallback legs, plus the first real
cross-provider fallback in the codebase.

## Non-goals (explicit, deferred to `tech-debt-tracker.md`)

- **No BYOK support** — `AI_VISION_PROVIDER=gemini` is system-config only (`ProviderConfig.from_settings()`);
  `from_user_dict()` never sets `vision_provider`/`vision_gemini_api_key`. Tracked as TD-029.
- **No symmetric hybrid routing for chat/image legs** — only vision was requested; the same
  pattern (a `*_provider` field + a `_chat_via_native_gemini`-style method) would extend cleanly
  if ever needed, but wasn't built speculatively.
- **Does not touch TD-026** — that item describes a different scenario
  (`AI_DEFAULT_PROVIDER=gemini`, i.e. Gemini as the *default* provider, with no cross-vendor
  fallback at all for chat/vision/image). This change is about the Custom/Agnes provider's
  vision leg optionally routing its *primary* call to Gemini; TD-026 remains valid and untouched.

## Acceptance criteria

- [x] `AI_VISION_PROVIDER` setting (`custom` default / `gemini`) in `app/core/config.py` and
      `.env.example`, documented next to `AI_VISION_MODEL`/`AI_VISION_FALLBACK_MODEL`.
- [x] `ProviderConfig` gains `vision_provider: Optional[AIProvider]` and
      `vision_gemini_api_key: Optional[str]`, populated by `from_settings()`'s `CUSTOM` branch.
- [x] `AIProviderService.chat_with_vision()` branches to
      `_chat_with_vision_via_native_gemini()` when `vision_provider == AIProvider.GEMINI`; that
      method calls the internal `GeminiProvider.chat()` directly (not `.chat_with_vision()`, to
      avoid a silent second fallback hop via `AI_GEMINI_VISION_FALLBACK_MODEL`), and on **any**
      `AIServiceError` (permissive, not just `e.retryable`) falls back to Agnes via `self.chat()`
      with the configured vision-fallback url/key/model.
- [x] `_get_native_vision_provider()` lazily builds one `GeminiProvider` per
      `AIProviderService` instance; `close()` closes it too.
- [x] Import cleanup: `gemini_provider` import moved from a bottom-of-file side-effect trick to
      a top-level import (no circularity — `gemini_provider.py` only imports
      `ai_provider_interface.py`) — verified `PROVIDER_REGISTRY` still has all three entries
      after the move.
- [x] `config_health.py`: two new error-severity checks — `AI_VISION_PROVIDER=gemini` + blank
      `AI_GEMINI_API_KEY`; `AI_VISION_PROVIDER=gemini` + non-blank `AI_VISION_API_URL` (the
      latter would otherwise be silently dead config once the leg is redirected — the same class
      of "which setting wins" ambiguity that caused the original production 401).
- [x] Tests: `tests/test_ai_provider_service.py::TestHybridGeminiVisionLeg` (primary success with
      no Agnes call, permissive fallback on a non-retryable Gemini error, missing-key raises
      before any network call, `close()` cleanup); `tests/test_config_health.py` (4 new cases for
      the two new checks, both fired and not-fired).
- [x] Docs: `docs/BACKEND.md` "AI provider system" section, this exec-plan, TD-029.
- [x] Full backend suite green, `ruff check` clean on all changed files,
      `scripts/check_architecture.py` and `scripts/check_docs_structure.py` pass.

## Context / links

- Builds on: `docs/exec-plans/completed/2026-07-27-native-gemini-provider.md` (the base
  `GeminiProvider`/registry work), TD-026 (the cross-provider-fallback gap this partially
  addresses, in one specific direction).
- Code: `app/core/config.py`, `backend/.env.example`, `app/services/ai_provider_service.py`,
  `app/core/config_health.py`, `docs/BACKEND.md`.
- Tests: `tests/test_ai_provider_service.py`, `tests/test_config_health.py`.

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-27 | Direct-to-Google for the vision leg, not routed through Agnes's proxy | Explicit choice — Agnes already proxies `gemini-3.6-flash` with zero new code, but the ask was for the native path, matching the architecture built in the prior pass |
| 2026-07-27 | Permissive fallback (any `AIServiceError`, not just `e.retryable`) | Explicit choice, prioritizing success over surfacing every Gemini-specific error — a safety-block or bad-request from Gemini may still succeed against a different vendor (Agnes), unlike same-vendor retries elsewhere in this codebase |
| 2026-07-27 | Call `GeminiProvider.chat()` directly, not `.chat_with_vision()` | The latter has its own Gemini-to-Gemini fallback (`AI_GEMINI_VISION_FALLBACK_MODEL`); going through it would silently insert a second hop (Gemini→Gemini→Agnes) nobody configured. Keeps it exactly one hop. |
| 2026-07-27 | `AI_VISION_PROVIDER=gemini` + non-blank `AI_VISION_API_URL` is a startup error, not silently ignored | A design review flagged this as the same class of "two settings, which one wins" ambiguity that caused the original production 401 (`AI_VISION_API_URL` pointed at Google's native endpoint under the OpenAI-compatible path) |
| 2026-07-27 | No BYOK support in v1 (system-config only) | Not requested; extending `from_user_dict()` and the `ProviderConfigInput` schema is a larger, separate surface — tracked as TD-029 |
| 2026-07-27 | This is not a fourth provider type — `AIProvider.CUSTOM` stays bound to `AIProviderService` | It's the existing Custom provider with one leg redirected, not a new selectable provider; no new registry entry |
| 2026-07-27 | Merged the new `AI_VISION_PROVIDER=gemini` missing-key check into the pre-existing `AI_DEFAULT_PROVIDER=gemini` missing-key check (one combined `ConfigIssue`, not two) | Caught in review: as originally written, a config with both flags set and a blank key produced two `ConfigIssue` entries with the identical key `AI_GEMINI_API_KEY` — not wrong, but noisy. Also backfilled a test for the pre-existing default-provider check, which had no dedicated coverage before this pass touched the same condition. |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest -q                                          # full suite green
ruff check app/services/ai_provider_service.py app/core/config.py app/core/config_health.py \
  tests/test_ai_provider_service.py tests/test_config_health.py
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

Manual end-to-end (not run in this environment — no local `.env` with real Agnes/Gemini keys
configured for this pass): with `AI_CHAT_MODEL=agnes-2.5-flash`, `AI_VISION_PROVIDER=gemini`,
`AI_VISION_MODEL=gemini-3.6-flash`, `AI_VISION_FALLBACK_MODEL=agnes-2.5-flash` set, exercise item
extraction (vision) and confirm the response comes back from Gemini directly with no Agnes call
in the logs, then temporarily break `AI_GEMINI_API_KEY` and confirm the same request falls back
to Agnes and still succeeds.

## Deferred debt

TD-029 (BYOK support for this hybrid mode).
