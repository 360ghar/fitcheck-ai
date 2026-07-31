# Plan: Duplicate toasts on web — RCA + one-toast-per-failure fix

Status: completed
Started: 2026-08-01
Owner: agent

## Goal

A single failed request surfaced multiple identical toasts on web (up to the
`TOAST_LIMIT = 5` cap). This change makes every logical HTTP failure produce
exactly ONE toast, with defense-in-depth at the toast store so identical
messages can never stack.

## RCA

| # | Finding | Evidence | Fix |
|---|---------|----------|-----|
| RC1 | The global toast lives in the axios **toast/401 error interceptor**, which sits after the **retry interceptor** in the same response chain. Retries re-issue `apiClient(config)`, which re-runs the WHOLE chain (including the toast interceptor). On exhaustion the same rejection propagates outward through every chain level, firing the toast once per level. | `frontend/src/api/client.ts`; reproduced against the installed axios with the exact interceptor shape: **3 HTTP attempts → 3 identical toasts** for a persistent 500 (`MAX_RETRIES = 2`). The old comment "toasts only fire once retries exhaust" was wrong. | Transient failures are now toasted exactly once by the retry interceptor at the terminal branch (exhaustion / auth endpoint / refresh retry); the toast interceptor only toasts permanent failures. |
| RC2 | Amplifier: `withRetry`/`parallelWithRetry` (`lib/retry.ts`) wrap the axios chain again (outfit preview `maxRetries: 3`, batch item saves `maxRetries: 3`), multiplying RC1 per attempt. | `outfitStore.ts` (preview), `BatchExtractionFlow.tsx` (item saves) | Those flows render their own inline failure UI (`previewError`, per-item results + progress), so their underlying requests now pass `skipToast`. |
| RC3 | Amplifier: React Query global `retry: 1` re-runs the whole axios chain for the same logical failure (blog queries/mutations). | `main.tsx` defaultOptions | `retry: 0` — transport retries are owned by the axios interceptor; a second retry layer re-runs it (and its toast). |
| RC4 | Remaining call-site double-toasts: `OutfitCreatePage.handleSave` and `AISettingsPanel` load toasts in `catch` on top of the interceptor (kept by 938c141 without `skipToast` on their requests). | `OutfitCreatePage.tsx`, `AISettingsPanel.tsx` | The create-outfit and get-AI-settings requests now pass `skipToast`; the contextual catch toast is the only one. |
| RC5 | Toast store has no dedupe: every `toast()` call gets a fresh id and stacks. Single `<Toaster/>` is mounted, so the store is not the source — but it should be resilient. | `use-toast.ts` ADD_TOAST | ADD_TOAST skips an identical open toast (title + description + variant). |

## Code changes

1. `frontend/src/api/client.ts` — shared `isTransientFailure`,
   `shouldShowApiToast`, `notifyApiError`, `notifyTerminalTransientError`;
   retry interceptor toasts terminal transient failures once; toast/401
   interceptor toasts only permanent failures (4xx etc.). Upgrade-prompt path
   for `RATE_LIMIT_EXCEEDED` unchanged.
2. `frontend/src/components/ui/use-toast.ts` — content-dedupe in ADD_TOAST;
   exported `State`/`Action` types for the new reducer test.
3. `frontend/src/api/{outfits,ai,items}.ts` — optional `config` parameter on
   `createOutfit`, `generateOutfit`, `getAISettings`, `createItem`,
   `uploadItemImages` so callers can pass `skipToast`.
4. `frontend/src/stores/outfitStore.ts`, `AISettingsPanel.tsx`,
   `BatchExtractionFlow.tsx` — pass `skipToast` on the calls that own their
   failure UX.
5. `frontend/src/main.tsx` — React Query `retry: 0` (single retry layer).
6. Tests:
   - `frontend/src/api/__tests__/client.test.ts` — one-toast matrix (persistent
     500 → 1, retry success → 0, 400 → 1, persistent 429 → 1 warning, network
     → 1, `skipToast` → 0, auth-endpoint 5xx → 1, quota 429 → prompt only).
   - `frontend/src/components/ui/__tests__/use-toast.test.ts` (new) — reducer
     dedupe behavior.

## Non-goals

- Not changing `useToast`'s `[state]` effect (matches the shadcn reference;
  not implicated).
- No dedupe by error content at the interceptor — the one-toast-per-request
  fix is structural; the reducer dedupe is defense-in-depth for identical
  copies from any future path.
- No changes to the retry policy itself (3 attempts, 1s/2s backoff) — only to
  how many toasts a failed cascade emits.

## Verification

```bash
cd frontend
npx tsc --noEmit
npx eslint src/api/client.ts src/components/ui/use-toast.ts \
  src/api/outfits.ts src/api/ai.ts src/api/items.ts \
  src/stores/outfitStore.ts src/components/settings/AISettingsPanel.tsx \
  src/components/wardrobe/BatchExtractionFlow.tsx src/main.tsx \
  src/api/__tests__/client.test.ts src/components/ui/__tests__/use-toast.test.ts
npx vitest run            # 30 files / 106 tests pass
npm run build             # tsc + vite build + prerender OK
```

## Deferred debt

- None filed. (RC1 was caused by an untested interceptor interaction; the
  toast-count assertions in `client.test.ts` now lock it down.)
