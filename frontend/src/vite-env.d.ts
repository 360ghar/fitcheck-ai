/// <reference types="vite/client" />

/**
 * Typed build-time env for the feature flags.
 *
 * Both are optional `string` because Vite inlines a literal only when the var
 * is actually set; unset means `undefined`. That is exactly why flags compare
 * with `=== 'true'` rather than coercing — see `src/lib/feature-flags.ts`,
 * which is the only place flags should be read.
 *
 * Two honest caveats:
 *
 * 1. This interface MERGES with the one from `vite/client`, which carries an
 *    `[key: string]: any` index signature. A misspelled var name therefore
 *    still type-checks as `any`; what this block buys is a real
 *    `string | undefined` (not `any`) on the vars we do declare, and a
 *    documented home for new ones.
 * 2. Only the flags are declared on purpose. The other vars stay `any` from the
 *    `vite/client` index signature. (This used to be forced by
 *    `<PostHogProvider apiKey={...}>` needing a non-optional `string`; that
 *    provider is gone — `lib/analytics.ts` now reads
 *    `VITE_PUBLIC_POSTHOG_KEY` and narrows it itself — so the remaining
 *    looseness is just untouched pre-existing scope.)
 */
interface ImportMetaEnv {
  readonly VITE_ENABLE_SOCIAL_IMPORT?: string
  readonly VITE_ENABLE_GAMIFICATION?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
