import { z } from 'zod'

/**
 * Typed access to `import.meta.env`. Never read `import.meta.env` inline —
 * everything is validated here once at boot, so a misconfigured deploy fails
 * loudly at startup instead of mid-session.
 *
 * All values are optional: the admin app works out of the box against the
 * same-origin API proxy (dev: Vite `/api` → :8000, prod: Netlify `/api/*` →
 * api.fitcheckaiapp.com) with Sentry disabled.
 */
const envSchema = z.object({
  /** Base URL of the FitCheck AI API. Empty string = same origin. */
  VITE_API_BASE_URL: z.string().default(''),
  /** Sentry DSN. Empty/absent disables Sentry. */
  VITE_SENTRY_DSN: z.string().optional(),
})

const parsed = envSchema.safeParse({
  VITE_API_BASE_URL: import.meta.env.VITE_API_BASE_URL ?? '',
  VITE_SENTRY_DSN: import.meta.env.VITE_SENTRY_DSN || undefined,
})

if (!parsed.success) {
   
  console.error('[env] invalid environment configuration:', parsed.error.flatten())
  throw new Error('Invalid environment configuration — see console for details.')
}

export const env = parsed.data

export const isDev = import.meta.env.DEV
export const isProd = import.meta.env.PROD
