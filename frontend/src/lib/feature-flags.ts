/**
 * Build-time feature flags.
 *
 * Vite statically replaces every `import.meta.env.VITE_*` reference with a
 * literal at build time, so `FEATURES.gamification` becomes `false` in the
 * bundle and any `{FEATURES.gamification && <X/>}` branch (plus the module it
 * pulls in) is eliminated by the minifier's dead-code pass. That means a
 * disabled feature costs no bytes, not just no pixels.
 *
 * The comparison is `=== 'true'` on purpose: env vars are always strings, and
 * an unset var is therefore `false`. That is the intended default for
 * `gamification` — it must stay off unless someone explicitly opts in, because
 * nothing on the backend ever writes streaks or achievements.
 *
 * Keep these in step with the backend's `ENABLE_*` settings by hand. There is
 * no `/config` endpoint, so the two sides are independent switches: the
 * backend flag controls whether the API returns real data, this one controls
 * whether the UI is reachable at all.
 *
 * Add a matching entry to `ImportMetaEnv` in `src/vite-env.d.ts` for any new
 * flag, so a typo is a compile error instead of a silent `false`.
 */
export const FEATURES = {
  /** Instagram/social import UI. Backend: `ENABLE_SOCIAL_IMPORT` (default on). */
  socialImport: import.meta.env.VITE_ENABLE_SOCIAL_IMPORT === 'true',
  /** Streaks / achievements / leaderboard. Backend: `ENABLE_GAMIFICATION` (default OFF). */
  gamification: import.meta.env.VITE_ENABLE_GAMIFICATION === 'true',
} as const
