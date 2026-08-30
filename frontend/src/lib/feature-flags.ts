/**
 * Build-time feature flags.
 *
 * Vite statically replaces every `import.meta.env.VITE_*` reference with a
 * literal at build time, so `FEATURES.gamification` becomes `false` in the
 * bundle and any `{FEATURES.gamification && <X/>}` branch (plus the module it
 * pulls in) is eliminated by the minifier's dead-code pass. That means a
 * disabled feature costs no bytes, not just no pixels.
 *
 * Gamification uses `=== 'true'`: an unset var is false because the feature
 * must stay off unless someone explicitly opts in. Gift vouchers are enabled
 * by default and use an explicit `false` opt-out instead.
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
  /** Gift studio and dashboard priority. Set false only for a UI rollback. */
  gifts: import.meta.env.VITE_ENABLE_GIFT_VOUCHERS !== 'false',
} as const
