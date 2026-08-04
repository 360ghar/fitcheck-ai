/**
 * Single source of truth for the API base URL.
 *
 * The web app is served through same-origin proxies in every environment:
 *   - dev: Vite proxy (`/api` → backend :8000, see vite.config.ts)
 *   - prod: Netlify redirect (`/api/*` → api.fitcheckaiapp.com, see netlify.toml)
 *
 * So the default base is an EMPTY string: endpoint constants already carry
 * the `/api/v1/...` prefix, which makes every request same-origin and avoids
 * CORS preflights entirely (the `Authorization` header is not a safelisted
 * header, so a cross-origin absolute URL would force an OPTIONS round-trip
 * per endpoint).
 *
 * Absolute URLs remain supported for environments that genuinely need them
 * (e.g. a standalone web build pointed at a remote API), via
 * `VITE_API_BASE_URL` / `VITE_API_URL` set to a full origin. A trailing
 * slash is stripped so concatenating endpoint constants never produces
 * `//api/v1/...`.
 */

function normalizeBaseUrl(value: string | undefined): string {
  if (!value) return ''
  const trimmed = value.trim()
  if (!trimmed) return ''
  return trimmed.endsWith('/') ? trimmed.slice(0, -1) : trimmed
}

export const API_BASE_URL: string = normalizeBaseUrl(
  import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_URL
)
