/**
 * Dev-aware logger.
 *
 * - `info`, `warn`, `table` are gated on `import.meta.env.DEV` so production
 *   bundles stay quiet and fast.
 * - `error` always fires (real failures belong in production logs too).
 *
 * Reserve plain `console.*` for build scripts and tests. App/runtime code
 * should route through this logger so a future Sentry/error-reporting hook
 * has a single interception point.
 */

const isDev = Boolean(import.meta.env?.DEV);

export const logger = {
  info: (...args: unknown[]): void => {
    if (isDev) console.info(...args);
  },
  warn: (...args: unknown[]): void => {
    if (isDev) console.warn(...args);
  },
  error: (...args: unknown[]): void => {
    // Always emit; real failures should not be silenced in production.
    console.error(...args);
  },
  table: (data: unknown): void => {
    if (isDev) console.table(data as never);
  },
} as const;
