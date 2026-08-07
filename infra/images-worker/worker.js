/**
 * FitCheck image-serving Worker.
 *
 * Serves private R2 bucket objects behind STABLE, path-only URLs so the
 * Cloudflare edge, the browser HTTP cache and Flutter's disk cache can all
 * hit (the "rotating presigned URL busts every cache" egress driver — see
 * docs/exec-plans/active/2026-08-05-railway-egress-rca.md). R2 egress to the
 * internet is free, so moving image serving here removes the Railway egress
 * bill entirely.
 *
 * URL scheme:  https://<IMAGE_CDN_BASE_URL>/{user_id}/{category}/{name}
 *              https://<IMAGE_CDN_BASE_URL>/{tmp|generated}/{user_id}/{sub}/{name}
 *
 * Authorization (both are accepted; at least one must match):
 *   1. `Authorization: Bearer <access token>` header (Flutter / API clients).
 *   2. The auth cookie `sb-<ref>-auth-token` (web app). NOTE: supabase-js's
 *      default browser client stores the session in localStorage and sets NO
 *      cookie, and a host-only cookie on the app domain would not reach this
 *      subdomain anyway — the frontend must set a domain-scoped cookie itself
 *      before worker mode works on web (see README "Web browser auth" / TD-068).
 *
 * Access rules, ALL of which must pass (mirrors backend/app/api/v1/images.py
 * `_is_owned_by_user` — deliberately the same shape, not a looser prefix test):
 *   - the token verifies AND is unexpired;
 *   - the key matches the canonical layout (category allowlist, 32-hex name,
 *     image extension) or the nested preview layout (tmp/ | generated/);
 *   - the OWNING path segment equals the token's `sub`: the first segment for
 *     canonical keys (``{user}/{category}/...``) and for the legacy per-user
 *     preview keys (``{user}/tmp/...``), the SECOND segment for the top-level
 *     preview folders (``tmp/{user}/...``, ``generated/{user}/...``).
 * Any failure is a 404, indistinguishable from a missing object, so object
 * existence is never revealed across users.
 *
 * Why the key allowlist matters and not just the user prefix: a prefix-only
 * check would serve ANYTHING under the user's prefix, including
 * `{user_id}/export/data.json` — the user's complete personal-data export
 * (backend users.py). That object is also the one key overwritten in place, so
 * it must never be edge-cached as `immutable` either (see CACHE_CONTROL below).
 *
 * Token verification (mirrors backend/app/core/security.py):
 *   - HS256 (legacy Supabase JWT secret)  -> HMAC-SHA256 via WebCrypto.
 *   - ES256 / RS256 (Supabase "JWT Signing Keys") -> JWKS fetched from
 *     {SUPABASE_URL}/auth/v1/.well-known/jwks.json, cached 1h, verified via
 *     WebCrypto. The JWK `kid` must match the token header.
 *   - `exp` is REQUIRED and enforced (with a small clock-skew allowance), and
 *     `iss` must be the project's auth issuer. Verifying only the signature
 *     would make any leaked token valid forever.
 *
 * Caching: responses are stored in `caches.default` keyed by the PATH ONLY
 * (query strings ignored), with `Cache-Control: public, max-age=86400,
 * immutable` for image objects. Signed URLs are deliberately NOT used, so the
 * cache key stays stable and every repeat view of a wardrobe hits the edge
 * instead of R2. Uploads always mint a new UUID key, so canonical and `_thumb`
 * objects are write-once per key and `immutable` is correct — the app stamps
 * `max-age=3600` on every upload, so honouring the object's own value there
 * would make this policy unreachable (see `cacheControlFor`). An object's own
 * value still wins when it is MORE restrictive (`no-store` / `private` /
 * `no-cache` / `max-age=0`), and short-lived nested `tmp/` + `generated/`
 * previews are always left on their own TTL.
 *
 * CORS: the web app fetch()es image URLs to build Blobs (download / share) and
 * reads one through a canvas, both of which need
 * `Access-Control-Allow-Origin`. Origins come from the ALLOWED_ORIGINS var.
 *
 * Range requests are forwarded to R2 via `R2ObjectBody`'s native range support.
 */

const CACHE_TTL_SECONDS = 86400; // 1 day; image objects are write-once per key
const JWKS_CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour
// Minimum gap between forced re-fetches after a `kid` miss. Bounds the origin
// stampede when a signing key rotates and every in-flight request misses at once.
const JWKS_REFETCH_FLOOR_MS = 30 * 1000;
const AUTH_COOKIE_PREFIX = 'sb-'; // sb-<project-ref>-auth-token
// Tolerance for clock drift between Supabase's signer and the Cloudflare edge.
// Small on purpose: this is the window in which an expired token still works.
const CLOCK_SKEW_SECONDS = 60;

// Key allowlist, ported from backend/app/api/v1/images.py (_KEY_RE /
// _NESTED_KEY_RE). Keep the two in sync: this Worker and the presigned endpoint
// must not disagree about what a servable key is.
const CANONICAL_KEY_RE =
  /^[^/\\]+\/(?:items|outfits|avatars|sources|feedback)\/[0-9a-f]{32}\.(?:jpg|jpeg|png|webp|gif|avif)$/;
// Preview keys under the shared top-level folders:
//   {tmp|generated}/{user_id}/{sub}/{name}.{ext}
// Top-level folder so scripts/cleanup_temp_assets.py can list/clear every
// preview with one prefix (backend storage_service mints this shape).
const NESTED_KEY_RE =
  /^(?:tmp|generated)\/[^/\\]+\/[^/\\]+\/[0-9a-f]{32}\.(?:jpg|jpeg|png|webp|gif|avif)$/;
// Pre-migration preview keys: {user_id}/{tmp|generated}/{sub}/{name}.{ext}.
// Accepted ONLY until scripts/migrate_temp_keys_layout.py has rewritten every
// old key; delete this alongside images.py's _LEGACY_NESTED_KEY_RE afterwards.
const LEGACY_NESTED_KEY_RE =
  /^[^/\\]+\/(?:tmp|generated)\/[^/\\]+\/[0-9a-f]{32}\.(?:jpg|jpeg|png|webp|gif|avif)$/;
// Thumbnail siblings: same layout, `_thumb.webp`. Always .webp regardless of the
// parent's format (StorageService.THUMB_EXTENSION), because the read path derives
// the thumb key from the parent key with no lookup, so the format has to be
// predictable. Keep this in step with THUMB_EXTENSION if it ever changes.
const CANONICAL_THUMB_KEY_RE =
  /^[^/\\]+\/(?:items|outfits|avatars|sources|feedback)\/[0-9a-f]{32}_thumb\.webp$/;

let jwksCache = { keys: null, fetchedAt: 0, forcedAt: 0 };

// Imported CryptoKeys, cached for the isolate's lifetime.
//
// crypto.subtle.importKey is not free, and both signing inputs are effectively
// constant: SUPABASE_JWT_SECRET never changes for a deployment, and a JWK is
// already cached by `kid` for an hour. Importing per request paid that cost on
// the hottest path in the system — one wardrobe grid is dozens of image requests
// and every one of them re-derived the same key before verifying.
//
// Keyed by secret / `kid` + material so a rotated secret or a rotated signing key
// still produces a fresh import instead of reusing a stale CryptoKey.
let hmacKeyCache = { secret: null, key: null };
const asymmetricKeyCache = new Map();

async function hmacVerifyKey(secret) {
  if (hmacKeyCache.secret === secret && hmacKeyCache.key) return hmacKeyCache.key;
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['verify'],
  );
  hmacKeyCache = { secret, key };
  return key;
}

async function asymmetricVerifyKey(cacheKey, jwkParams, algorithm) {
  const cached = asymmetricKeyCache.get(cacheKey);
  if (cached) return cached;
  const key = await crypto.subtle.importKey('jwk', jwkParams, algorithm, false, ['verify']);
  // Bounded so a pathological stream of unknown kids cannot grow it without
  // limit; a deployment only ever has a couple of live signing keys.
  if (asymmetricKeyCache.size >= 8) asymmetricKeyCache.clear();
  asymmetricKeyCache.set(cacheKey, key);
  return key;
}

// --------------------------------------------------------------------------
// base64url helpers (WebCrypto input)
// --------------------------------------------------------------------------
function base64urlToBytes(value) {
  const b64 = value.replace(/-/g, '+').replace(/_/g, '/');
  const pad = b64.length % 4 === 0 ? '' : '='.repeat(4 - (b64.length % 4));
  const bin = atob(b64 + pad);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

function decodePayload(payloadB64) {
  const bytes = base64urlToBytes(payloadB64);
  return JSON.parse(new TextDecoder().decode(bytes));
}

function getToken(request, env) {
  const auth = request.headers.get('Authorization') || '';
  if (auth.startsWith('Bearer ')) return auth.slice(7).trim() || null;
  const cookieHeader = request.headers.get('Cookie') || '';
  const cookies = cookieHeader.split(';').map((c) => c.trim());
  for (const cookie of cookies) {
    if (cookie.startsWith(AUTH_COOKIE_PREFIX) && cookie.includes('-auth-token=')) {
      return cookie.slice(cookie.indexOf('=') + 1) || null;
    }
  }
  return null;
}

// --------------------------------------------------------------------------
// CORS
// --------------------------------------------------------------------------
function allowedOrigins(env) {
  return (env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}

/** Echo the request Origin only when it is explicitly allowed. */
function corsHeaders(request, env) {
  const origin = request.headers.get('Origin');
  if (!origin) return {};
  if (!allowedOrigins(env).includes(origin)) return {};
  return {
    'Access-Control-Allow-Origin': origin,
    // The response varies by Origin, so the edge must not serve one origin's
    // ACAO header to another.
    Vary: 'Origin',
    'Access-Control-Allow-Credentials': 'true',
  };
}

function preflight(request, env) {
  const cors = corsHeaders(request, env);
  if (!cors['Access-Control-Allow-Origin']) {
    return new Response(null, { status: 403 });
  }
  return new Response(null, {
    status: 204,
    headers: {
      ...cors,
      'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
      'Access-Control-Allow-Headers':
        request.headers.get('Access-Control-Request-Headers') || 'Authorization, Range',
      'Access-Control-Expose-Headers': 'Content-Length, Content-Range, ETag, Accept-Ranges',
      'Access-Control-Max-Age': '86400',
    },
  });
}

// --------------------------------------------------------------------------
// token verification (HS256 + JWKS, mirrors backend security.py)
// --------------------------------------------------------------------------
/**
 * The project's JWKS, cached for JWKS_CACHE_TTL_MS.
 *
 * An EMPTY key set is a failure, not a cacheable answer. Caching `keys: []`
 * (which `body.keys || []` did for any unexpected 200 body) poisoned the cache
 * for the full hour and 404'd every image for every user, even though a retry a
 * second later would have succeeded. `res.ok` alone is not freshness.
 *
 * `force` bypasses the TTL, for the signing-key rotation case: new tokens carry
 * a `kid` this cache has never seen, and waiting out the TTL is an hour of total
 * outage. JWKS_REFETCH_FLOOR_MS bounds how often a miss can stampede the origin.
 */
async function fetchJwks(env, { force = false } = {}) {
  const now = Date.now();
  const fresh =
    jwksCache.keys && jwksCache.keys.length > 0 && now - jwksCache.fetchedAt < JWKS_CACHE_TTL_MS;
  if (fresh && !force) return jwksCache.keys;
  // Forced re-fetches are rate-limited off their OWN timestamp, not the cache's:
  // the first `kid` miss must always reach the origin (otherwise a rotation is
  // still an outage, only a shorter one), while the flood of misses behind it
  // reuses whatever that fetch returned.
  if (fresh && now - jwksCache.forcedAt < JWKS_REFETCH_FLOOR_MS) return jwksCache.keys;

  const jwksUrl = `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1/.well-known/jwks.json`;
  const res = await fetch(jwksUrl, { cf: { cacheTtl: 3600 } });
  if (!res.ok) throw new Error('jwks fetch failed');
  const body = await res.json();
  const keys = (body && body.keys) || [];
  if (keys.length === 0) {
    // Do NOT stamp fetchedAt: leave the cache as it was so the next request
    // retries instead of serving an empty key set for an hour.
    throw new Error('jwks response contained no keys');
  }
  jwksCache = {
    keys,
    fetchedAt: Date.now(),
    forcedAt: force ? Date.now() : jwksCache.forcedAt,
  };
  return jwksCache.keys;
}

async function verifyAsymmetric(token, header, payloadB64, sigB64, env) {
  let keys = await fetchJwks(env);
  let jwk = keys.find((k) => k.kid === header.kid);
  if (!jwk) {
    // A `kid` miss is what a signing-key rotation looks like. Re-fetch once
    // (rate-limited by the floor inside fetchJwks) rather than waiting out the
    // TTL. There is deliberately NO `alg`-only fallback: after a rotation that
    // selects the OLD key, crypto.subtle.verify returns false, and a
    // recoverable cache miss becomes a hard verification failure — i.e. every
    // image 404s for every user until the TTL lapses.
    keys = await fetchJwks(env, { force: true });
    jwk = keys.find((k) => k.kid === header.kid);
  }
  if (!jwk) return null;

  const data = new TextEncoder().encode(`${token.split('.')[0]}.${payloadB64}`);
  const signature = base64urlToBytes(sigB64);

  let algorithm;
  let key;
  if (header.alg === 'RS256' && jwk.kty === 'RSA') {
    algorithm = { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' };
    key = await asymmetricVerifyKey(
      `RS256:${jwk.kid}:${jwk.n}`,
      { kty: 'RSA', n: jwk.n, e: jwk.e },
      algorithm,
    );
  } else if (header.alg === 'ES256' && jwk.kty === 'EC' && jwk.crv === 'P-256') {
    algorithm = { name: 'ECDSA', hash: 'SHA-256' };
    key = await asymmetricVerifyKey(
      `ES256:${jwk.kid}:${jwk.x}.${jwk.y}`,
      { kty: 'EC', crv: 'P-256', x: jwk.x, y: jwk.y },
      algorithm,
    );
  } else {
    return null;
  }

  const ok = await crypto.subtle.verify(algorithm, key, signature, data);
  return ok ? decodePayload(payloadB64) : null;
}

/**
 * Reject a payload whose lifetime or issuer is wrong.
 *
 * A valid signature only proves Supabase minted the token at some point. Without
 * these checks a token captured from a log, a shared device or an old client
 * grants access to that user's whole image namespace forever.
 */
function claimsAreValid(payload, env) {
  if (!payload || typeof payload !== 'object') return false;
  const now = Math.floor(Date.now() / 1000);

  // exp is REQUIRED — a token with no expiry must not be treated as eternal.
  if (typeof payload.exp !== 'number') return false;
  if (payload.exp + CLOCK_SKEW_SECONDS <= now) return false;
  if (typeof payload.nbf === 'number' && payload.nbf - CLOCK_SKEW_SECONDS > now) return false;

  // iss pins the token to THIS Supabase project, so a token from any other
  // project (or another Supabase-hosted app) cannot be replayed here.
  if (env.SUPABASE_URL) {
    const expected = `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1`;
    if (payload.iss && payload.iss !== expected) return false;
  }

  return typeof payload.sub === 'string' && payload.sub.length > 0;
}

async function verifyToken(token, env) {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [headerB64, payloadB64, sigB64] = parts;
  let header;
  try {
    header = JSON.parse(new TextDecoder().decode(base64urlToBytes(headerB64)));
  } catch {
    return null;
  }

  let payload = null;
  if (header.alg === 'HS256') {
    const data = new TextEncoder().encode(`${headerB64}.${payloadB64}`);
    const key = await hmacVerifyKey(env.SUPABASE_JWT_SECRET);
    const ok = await crypto.subtle.verify('HMAC', key, base64urlToBytes(sigB64), data);
    payload = ok ? decodePayload(payloadB64) : null;
  } else if (header.alg === 'RS256' || header.alg === 'ES256') {
    payload = await verifyAsymmetric(token, header, payloadB64, sigB64, env);
  } else {
    return null; // unsupported alg
  }

  // Signature checked; now the claims. Both gates, always.
  return claimsAreValid(payload, env) ? payload : null;
}

// --------------------------------------------------------------------------
// authorization (mirrors images.py `_is_owned_by_user`)
// --------------------------------------------------------------------------
function isServableKey(storagePath) {
  return (
    CANONICAL_KEY_RE.test(storagePath) ||
    NESTED_KEY_RE.test(storagePath) ||
    LEGACY_NESTED_KEY_RE.test(storagePath) ||
    CANONICAL_THUMB_KEY_RE.test(storagePath)
  );
}

function isOwnedByUser(storagePath, userId) {
  if (!storagePath || !userId) return false;
  if (storagePath !== storagePath.trim()) return false;
  if (/\\|\r|\n/.test(storagePath)) return false; // no encoded separators
  if (storagePath.includes('..')) return false; // no traversal
  if (!isServableKey(storagePath)) return false;
  // Canonical keys and legacy per-user preview keys embed the owner in the
  // FIRST segment; top-level tmp/generated preview keys embed it in the
  // SECOND segment (mirrors images.py `_is_owned_by_user`).
  const owner = NESTED_KEY_RE.test(storagePath)
    ? storagePath.split('/')[1]
    : storagePath.split('/')[0];
  return owner === userId;
}

// --------------------------------------------------------------------------
// request handler
// --------------------------------------------------------------------------
/**
 * Resolve the Cache-Control to serve for an R2 object.
 *
 * Preferring the object's own value unconditionally made the immutable default
 * UNREACHABLE in production: `S3StorageBackend.upload` stamps
 * `max-age=<DEFAULT_CACHE_CONTROL>` (3600) on EVERY object the app writes,
 * thumbnails included, so `object.httpMetadata.cacheControl` is always set. The
 * edge then re-fetched every tile hourly and, with no `immutable`, browsers
 * revalidated on each reload — 24x the origin fetches the R2 cutover existed to
 * remove. (The unit test that "proved" the default only passed because it stubbed
 * `cacheControl: undefined`, which no real object has.)
 *
 * So: canonical and `_thumb` keys are write-once (a new upload mints a new UUID),
 * which is exactly what `immutable` asserts — take the long TTL for them and let
 * the object's own value win only when it is MORE restrictive. Nested `tmp/` and
 * `generated/` keys are short-lived previews, so there the object still decides.
 */
function cacheControlFor(object, storagePath) {
  const own = object.httpMetadata && object.httpMetadata.cacheControl;
  const immutableDefault = `public, max-age=${CACHE_TTL_SECONDS}, immutable`;
  const writeOnce =
    typeof storagePath === 'string' &&
    (CANONICAL_KEY_RE.test(storagePath) || CANONICAL_THUMB_KEY_RE.test(storagePath));
  if (!own) return immutableDefault;
  if (writeOnce && isCacheable(own)) return immutableDefault;
  return own;
}

/** Whether a Cache-Control value allows storing the response in a shared cache. */
function isCacheable(cacheControl) {
  if (!cacheControl) return true;
  const value = cacheControl.toLowerCase();
  return !/\b(no-store|private|no-cache)\b/.test(value) && !/max-age=0\b/.test(value);
}

async function handleRequest(request, env, ctx) {
  const url = new URL(request.url);
  const method = request.method;

  if (method === 'OPTIONS') return preflight(request, env);
  if (method !== 'GET' && method !== 'HEAD') {
    return new Response('Method not allowed', {
      status: 405,
      headers: { Allow: 'GET, HEAD, OPTIONS', ...corsHeaders(request, env) },
    });
  }

  const cors = corsHeaders(request, env);
  const notFound = () =>
    new Response('Not found', { status: 404, headers: { ...cors } });

  // Keys are URL-safe by construction ({uuid}/{category}/{hex}.{ext}), but a
  // client may still percent-encode them. Decode inside a guard:
  // decodeURIComponent THROWS on malformed escapes (`/%zz`), which would
  // otherwise surface as a 500 and distinguish "malformed" from "not found".
  let storagePath;
  try {
    storagePath = decodeURIComponent(url.pathname).replace(/^\//, '');
  } catch {
    return notFound();
  }

  const token = getToken(request, env);
  const payload = token ? await verifyToken(token, env) : null;
  const userId = payload && payload.sub ? String(payload.sub) : null;
  if (!isOwnedByUser(storagePath, userId)) {
    // Indistinguishable 404: never reveal whether the object exists.
    return notFound();
  }

  const rangeHeader = request.headers.get('Range');

  // Edge cache key: path only (query strings ignored). The cache is shared
  // per zone, so an unauthenticated hit could serve a previously-fetched
  // object — accepted trade-off: keys embed the user UUID + a uuid4 name
  // and are only ever reachable via an ownership-checked API response.
  // Ranged requests bypass the cache entirely (a partial body must never be
  // stored under the full-object key).
  const cacheKey = new Request(`${url.origin}/${storagePath}`, { method: 'GET' });
  if (!rangeHeader) {
    const cached = await caches.default.match(cacheKey);
    if (cached) {
      // Recompute CORS for THIS request. The entry is shared per zone and was
      // stored with whatever Origin first populated it, so the stale headers must
      // be dropped (not merely overwritten) — otherwise a no-Origin or
      // unlisted-Origin request inherits the first caller's
      // Access-Control-Allow-Origin.
      const headers = new Headers(cached.headers);
      headers.delete('Access-Control-Allow-Origin');
      headers.delete('Access-Control-Allow-Credentials');
      headers.delete('Vary');
      for (const [k, v] of Object.entries(cors)) headers.set(k, v);
      // A HEAD must not carry a body, even when the cache hit came from a GET.
      return new Response(method === 'HEAD' ? null : cached.body, {
        status: cached.status,
        headers,
      });
    }
  }

  const object = await env.IMAGES_BUCKET.get(storagePath, {
    range: rangeHeader ? request.headers : undefined,
  });
  if (object === null) return notFound();

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set(
    'Content-Type',
    (object.httpMetadata && object.httpMetadata.contentType) || 'application/octet-stream',
  );
  headers.set('Cache-Control', cacheControlFor(object, storagePath));
  headers.set('ETag', object.httpEtag);
  // Advertise range support so clients (and video/partial decoders) can use it.
  headers.set('Accept-Ranges', 'bytes');
  for (const [k, v] of Object.entries(cors)) headers.set(k, v);

  const range = object.range;
  let status = 200;
  if (rangeHeader && range) {
    // R2 returns {offset, length} for an open-ended range and may omit `end`,
    // so compute the last byte instead of reading a field that can be
    // undefined ("bytes 500-undefined/1234" is a malformed header).
    const offset = range.offset ?? 0;
    const length = range.length ?? Math.max(object.size - offset, 0);
    const end = offset + length - 1;
    headers.set('Content-Range', `bytes ${offset}-${end}/${object.size}`);
    headers.set('Content-Length', String(length));
    status = 206;
  }

  // HEAD: same headers, no body.
  if (method === 'HEAD') {
    if (status === 200) headers.set('Content-Length', String(object.size));
    return new Response(null, { status, headers });
  }

  const response = new Response(object.body, { status, headers });
  // Only full responses are cached, and only when the resolved Cache-Control
  // permits it: `caches.default.put` REJECTS a no-store/private response, and an
  // unhandled rejection inside waitUntil is a silent error on every request for
  // such an object.
  if (status === 200 && isCacheable(headers.get('Cache-Control'))) {
    ctx.waitUntil(caches.default.put(cacheKey, response.clone()));
  }
  return response;
}

export default {
  async fetch(request, env, ctx) {
    try {
      return await handleRequest(request, env, ctx);
    } catch (err) {
      return new Response('Internal error', { status: 500 });
    }
  },
};
