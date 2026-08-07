/**
 * Build-time feature flags.
 *
 * Vite statically replaces every `import.meta.env.VITE_*` reference with a
 * literal at build time, so `FEATURES.refunds` becomes `false` in the bundle
 * and any `{FEATURES.refunds && <X/>}` branch (plus the module it pulls in)
 * is eliminated by the minifier's dead-code pass. A disabled feature costs
 * zero bytes, not just zero pixels.
 *
 * The comparison is `=== 'true'` on purpose: env vars are always strings and
 * an unset var is therefore `false` — the intended default for half-built
 * wave-2 features.
 *
 * Add a matching entry to `ImportMetaEnv` in `src/vite-env.d.ts` for any new
 * flag, so a typo is a compile error instead of a silent `false`.
 */
export const FEATURES = {
  /** Admin-initiated refunds on subscription/IAP detail pages. */
  refunds: import.meta.env.VITE_ENABLE_ADMIN_REFUNDS === 'true',
  /** One-click temp-storage cleanup in System → Storage. */
  storageCleanup: import.meta.env.VITE_ENABLE_ADMIN_STORAGE_CLEANUP === 'true',
} as const
