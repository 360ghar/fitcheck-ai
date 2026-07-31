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
 * 2. Only the flags are declared on purpose. Narrowing the other vars (e.g.
 *    `VITE_PUBLIC_POSTHOG_KEY`) from `any` to `string | undefined` immediately
 *    breaks `main.tsx`'s `<PostHogProvider apiKey={...}>`, which requires a
 *    non-optional `string`. That looseness is real and pre-existing, but
 *    fixing it is not this change's job.
 */
interface ImportMetaEnv {
  readonly VITE_ENABLE_SOCIAL_IMPORT?: string
  readonly VITE_ENABLE_GAMIFICATION?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
