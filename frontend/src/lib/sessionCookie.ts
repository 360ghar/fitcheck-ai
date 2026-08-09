/**
 * Worker-mode image auth cookie (TD-068).
 *
 * The images Worker (`infra/images-worker`) serves stable R2 URLs that
 * require the app's access token. Flutter sends it as an
 * `Authorization: Bearer` header; the web cannot set headers on `<img>`
 * requests, so the Worker also accepts the `sb-<ref>-auth-token` cookie.
 * supabase-js never sets it — the browser `createClient` persists sessions
 * to localStorage — so the app sets it itself, scoped to the registrable
 * domain. That makes `www.`, `admin.` and `images.` all send it on same-site
 * subresource requests (`SameSite=Lax` is enough: an `<img>` from
 * `fitcheckaiapp.com` to `images.fitcheckaiapp.com` is same-site).
 *
 * The cookie is written wherever the token store changes (login, register,
 * refresh, session restore) via `setTokens`/`clearTokens` in `lib/auth.ts`,
 * so every flow stays in sync without call-site churn.
 *
 * This module also owns the URL-based fetch/canvas credential rules for the
 * four image `fetch()` paths (download / share / photoshoot / try-on) and
 * the bounding-box cropper: worker-mode URLs on our own host must carry the
 * cookie (`credentials: 'include'` / `crossOrigin = 'use-credentials'`),
 * while presigned R2 URLs must NOT — the bucket's CORS policy has no
 * `Access-Control-Allow-Credentials`, so a credentialed fetch to a presigned
 * URL is rejected by the browser.
 */

const REGISTRABLE_DOMAIN = '.fitcheckaiapp.com'

/** Project ref embedded in Supabase URLs, e.g. `abcdefgh` in `https://abcdefgh.supabase.co`. */
function projectRef(): string | null {
  const url = import.meta.env.VITE_SUPABASE_URL || ''
  const match = url.match(/^https:\/\/([a-z0-9]+)\.supabase\.co(?:\/|$)/i)
  return match ? match[1].toLowerCase() : null
}

/** The `sb-<ref>-auth-token` cookie name, or null when the ref is unknown. */
export function authCookieName(): string | null {
  const ref = projectRef()
  return ref ? `sb-${ref}-auth-token` : null
}

/**
 * Domain attribute for the cookie: the registrable domain on production
 * (so every subdomain sends it), nothing on dev hosts (a `Domain=...`
 * attribute for another domain is rejected by browsers; worker URLs are not
 * used in local dev anyway, so a host-only cookie is fine).
 */
function cookieDomain(): string | undefined {
  if (typeof window === 'undefined') return undefined
  const host = window.location.hostname
  if (host === 'fitcheckaiapp.com' || host.endsWith('.fitcheckaiapp.com')) {
    return REGISTRABLE_DOMAIN
  }
  return undefined
}

/** Seconds until the access token's `exp` claim, floored at 60. */
function expiresInFromJwt(token: string): number {
  try {
    const b64 = (token.split('.')[1] || '').replace(/-/g, '+').replace(/_/g, '/')
    const padded = b64.padEnd(b64.length + ((4 - (b64.length % 4)) % 4), '=')
    const payload = JSON.parse(atob(padded)) as { exp?: number }
    if (typeof payload.exp === 'number') {
      const seconds = Math.floor(payload.exp - Date.now() / 1000)
      if (Number.isFinite(seconds)) return Math.max(60, seconds)
    }
  } catch {
    // Not a JWT-shaped token: fall through to the default lifetime.
  }
  return 3600
}

/** Whether a URL belongs to our own image-serving hosts. */
export function isOurImageHost(url: string): boolean {
  try {
    const host = new URL(url).hostname.toLowerCase()
    return host === 'fitcheckaiapp.com' || host.endsWith('.fitcheckaiapp.com')
  } catch {
    return false
  }
}

/** Whether a URL is a presigned S3/R2 URL (query signature). */
function isPresignedUrl(url: string): boolean {
  return url.includes('X-Amz-')
}

/** Whether a URL may carry credentials (the cookie) on a fetch. */
export function urlAcceptsCredentials(url: string): boolean {
  return !isPresignedUrl(url) && isOurImageHost(url)
}

/**
 * Fetch options for an image URL: `credentials: 'include'` only for
 * worker-mode URLs on our own host. Presigned R2 URLs and third-party URLs
 * must stay credential-free — the R2 bucket CORS policy has no
 * `Access-Control-Allow-Credentials`, so including credentials would make
 * the browser reject the response.
 */
export function imageFetchOptions(url: string): RequestInit {
  return urlAcceptsCredentials(url) ? { credentials: 'include' } : {}
}

/**
 * `crossOrigin` for canvas-bound image loads: `use-credentials` on our
 * worker host (the auth cookie must reach the Worker), `anonymous`
 * everywhere else (presigned R2 URLs, third-party URLs, blob:/data: sources
 * where the attribute is a no-op).
 */
export function imageCrossOrigin(url: string): 'anonymous' | 'use-credentials' {
  return urlAcceptsCredentials(url) ? 'use-credentials' : 'anonymous'
}

/**
 * Set the auth cookie from an access token. Safe to call on every token
 * write (login/register/refresh/restore): it simply overwrites the cookie
 * with the current token and lifetime.
 */
export function setAuthSessionCookie(accessToken: string): void {
  if (typeof document === 'undefined' || !accessToken) return
  const name = authCookieName()
  if (!name) return
  const domain = cookieDomain()
  const domainAttr = domain ? `Domain=${domain}; ` : ''
  document.cookie = `${name}=${accessToken}; ${domainAttr}Path=/; Max-Age=${expiresInFromJwt(accessToken)}; Secure; SameSite=Lax`
}

/** Expire the auth cookie immediately (logout / token clear). */
export function clearAuthSessionCookie(): void {
  if (typeof document === 'undefined') return
  const name = authCookieName()
  if (!name) return
  const domain = cookieDomain()
  const domainAttr = domain ? `Domain=${domain}; ` : ''
  document.cookie = `${name}=; ${domainAttr}Path=/; Max-Age=0; Secure; SameSite=Lax`
}
