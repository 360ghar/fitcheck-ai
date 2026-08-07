/**
 * Tests for the image-serving Worker's authorization boundary.
 *
 * This Worker is the ONLY thing standing between a stable public URL and a
 * private R2 bucket, and it previously had no tests at all. What is pinned here
 * is exactly what a review found missing or wrong:
 *
 *   1. `exp` was never checked — a signature-valid but long-expired token
 *      granted access to a user's whole image namespace forever.
 *   2. the ownership check was a bare "first path segment == sub" prefix test,
 *      far looser than the backend's `_is_owned_by_user`, so it would serve
 *      `{user}/export/data.json` — the complete personal-data export.
 *   3. `Cache-Control` was forced to 24h `immutable` on every object,
 *      discarding a deliberately short TTL.
 *   4. there was no CORS handling at all, and OPTIONS returned 405.
 *   5. `Content-Range` was built from `range.end`, which R2 omits for an
 *      open-ended range, producing "bytes 500-undefined/1234".
 *
 * Runs on the Node test runner (no dependencies): `npm test` in this directory.
 * Cloudflare-only globals (`caches`) and bindings (R2, ctx) are stubbed.
 */

import assert from 'node:assert/strict';
import { before, beforeEach, describe, it } from 'node:test';

const SUPABASE_URL = 'https://proj.supabase.co';
const JWT_SECRET = 'test-jwt-secret-value';
const ORIGIN = 'https://www.fitcheckaiapp.com';
const USER = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const OTHER_USER = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const NAME = '0123456789abcdef0123456789abcdef';
const KEY = `${USER}/items/${NAME}.webp`;

let worker;
let putCalls;

// --------------------------------------------------------------------------
// Cloudflare runtime stubs
// --------------------------------------------------------------------------
function installCachesStub({ hit = null } = {}) {
  putCalls = [];
  globalThis.caches = {
    default: {
      match: async () => hit,
      put: async (req, res) => {
        putCalls.push({ url: req.url, status: res.status });
      },
    },
  };
}

/** Minimal R2ObjectBody stand-in. */
function r2Object({
  body = 'IMAGEBYTES',
  contentType = 'image/webp',
  cacheControl = undefined,
  range = undefined,
  size = 10,
} = {}) {
  return {
    body,
    size,
    range,
    httpEtag: '"etag-1"',
    httpMetadata: { contentType, cacheControl },
    writeHttpMetadata(headers) {
      if (contentType) headers.set('Content-Type', contentType);
    },
  };
}

function makeEnv({ objects = { [KEY]: r2Object() }, allowedOrigins = ORIGIN } = {}) {
  return {
    SUPABASE_URL,
    SUPABASE_JWT_SECRET: JWT_SECRET,
    ALLOWED_ORIGINS: allowedOrigins,
    IMAGES_BUCKET: {
      async get(key, opts) {
        const obj = objects[key];
        if (!obj) return null;
        if (opts && opts.range) return { ...obj, range: obj.range };
        return obj;
      },
    },
  };
}

const ctx = { waitUntil: () => {} };

// --------------------------------------------------------------------------
// HS256 token minting (WebCrypto, same shape Supabase emits)
// --------------------------------------------------------------------------
function b64url(bytes) {
  return Buffer.from(bytes).toString('base64url');
}

async function mintToken(claims = {}, { secret = JWT_SECRET } = {}) {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'HS256', typ: 'JWT' };
  const payload = {
    sub: USER,
    iss: `${SUPABASE_URL}/auth/v1`,
    exp: now + 3600,
    iat: now,
    ...claims,
  };
  const h = b64url(new TextEncoder().encode(JSON.stringify(header)));
  const p = b64url(new TextEncoder().encode(JSON.stringify(payload)));
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(`${h}.${p}`));
  return `${h}.${p}.${b64url(new Uint8Array(sig))}`;
}

// --------------------------------------------------------------------------
// request helper
// --------------------------------------------------------------------------
async function call(
  key,
  { token, method = 'GET', origin, range, env = makeEnv(), headers = {} } = {},
) {
  const h = new Headers(headers);
  if (token) h.set('Authorization', `Bearer ${token}`);
  if (origin) h.set('Origin', origin);
  if (range) h.set('Range', range);
  const request = new Request(`https://images.fitcheckaiapp.com/${key}`, { method, headers: h });
  return worker.fetch(request, env, ctx);
}

before(async () => {
  worker = (await import('./worker.js')).default;
});

beforeEach(() => {
  installCachesStub();
});

// ==========================================================================
// 1. token lifetime — the missing exp check
// ==========================================================================
describe('token claims', () => {
  it('serves a valid unexpired token', async () => {
    const res = await call(KEY, { token: await mintToken() });
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('Content-Type'), 'image/webp');
  });

  it('404s an EXPIRED token', async () => {
    const now = Math.floor(Date.now() / 1000);
    const res = await call(KEY, { token: await mintToken({ exp: now - 3600 }) });
    assert.equal(res.status, 404, 'an expired token must not grant access');
  });

  it('404s a token with no exp at all', async () => {
    // Signature-valid but eternal: must be rejected, not treated as forever-good.
    const res = await call(KEY, { token: await mintToken({ exp: undefined }) });
    assert.equal(res.status, 404);
  });

  it('404s a token from another Supabase project (iss mismatch)', async () => {
    const res = await call(KEY, {
      token: await mintToken({ iss: 'https://someone-else.supabase.co/auth/v1' }),
    });
    assert.equal(res.status, 404);
  });

  it('404s a token not yet valid (nbf in the future)', async () => {
    const now = Math.floor(Date.now() / 1000);
    const res = await call(KEY, { token: await mintToken({ nbf: now + 3600 }) });
    assert.equal(res.status, 404);
  });

  it('404s a token signed with the wrong secret', async () => {
    const res = await call(KEY, { token: await mintToken({}, { secret: 'wrong-secret' }) });
    assert.equal(res.status, 404);
  });

  it('404s a malformed token and a missing token', async () => {
    assert.equal((await call(KEY, { token: 'not.a.jwt' })).status, 404);
    assert.equal((await call(KEY)).status, 404);
  });

  it('tolerates small clock skew on a just-expired token', async () => {
    const now = Math.floor(Date.now() / 1000);
    const res = await call(KEY, { token: await mintToken({ exp: now - 5 }) });
    assert.equal(res.status, 200, 'a 5s skew must not lock out a live session');
  });
});

// ==========================================================================
// 2. key allowlist — must match the backend, not a bare prefix
// ==========================================================================
describe('key authorization', () => {
  it('404s ANOTHER user key even though the object exists', async () => {
    const otherKey = `${OTHER_USER}/items/${NAME}.webp`;
    const env = makeEnv({ objects: { [otherKey]: r2Object() } });
    const res = await call(otherKey, { token: await mintToken(), env });
    assert.equal(res.status, 404);
  });

  it('404s the personal-data export under the user own prefix', async () => {
    // The regression that motivated porting the backend allowlist here: a
    // prefix-only check served this.
    const exportKey = `${USER}/export/data.json`;
    const env = makeEnv({
      objects: { [exportKey]: r2Object({ contentType: 'application/json' }) },
    });
    const res = await call(exportKey, { token: await mintToken(), env });
    assert.equal(res.status, 404, 'the data export must never be servable here');
  });

  it('accepts every canonical image category', async () => {
    for (const category of ['items', 'outfits', 'avatars', 'sources', 'feedback']) {
      const key = `${USER}/${category}/${NAME}.jpg`;
      const env = makeEnv({ objects: { [key]: r2Object({ contentType: 'image/jpeg' }) } });
      const res = await call(key, { token: await mintToken(), env });
      assert.equal(res.status, 200, `${category} should be servable`);
    }
  });

  it('accepts nested preview keys (tmp/ and generated/) and thumb siblings', async () => {
    // Top-level tmp/ and generated/ folders (new layout) plus the legacy
    // per-user preview layout (served until migrate_temp_keys_layout.py runs).
    const keys = [
      `tmp/${USER}/social-import/${NAME}.webp`,
      `generated/${USER}/try-on/${NAME}.png`,
      `${USER}/tmp/social-import/${NAME}.webp`,
      `${USER}/generated/try-on/${NAME}.png`,
      `${USER}/items/${NAME}_thumb.webp`,
    ];
    for (const key of keys) {
      const env = makeEnv({ objects: { [key]: r2Object() } });
      const res = await call(key, { token: await mintToken(), env });
      assert.equal(res.status, 200, `${key} should be servable`);
    }
  });

  it('rejects a cross-user top-level preview key', async () => {
    // Ownership for tmp/ and generated/ keys is the SECOND segment.
    const key = `tmp/${OTHER_USER}/social-import/${NAME}.webp`;
    const env = makeEnv({ objects: { [key]: r2Object() } });
    const res = await call(key, { token: await mintToken(), env });
    assert.equal(res.status, 404);
  });

  it('404s traversal, bad names and unknown categories', async () => {
    const bad = [
      `${USER}/../${OTHER_USER}/items/${NAME}.webp`,
      `${USER}/items/short.webp`,
      `${USER}/items/${NAME}.exe`,
      `${USER}/unknowncat/${NAME}.webp`,
      `${USER}/items/${NAME}`,
    ];
    for (const key of bad) {
      const env = makeEnv({ objects: { [key]: r2Object() } });
      const res = await call(key, { token: await mintToken(), env });
      assert.equal(res.status, 404, `${key} must be rejected`);
    }
  });

  it('404s (not 500s) a path with malformed percent-encoding', async () => {
    // decodeURIComponent throws on `%zz`; an uncaught throw would surface as a
    // 500 and distinguish "malformed" from "not found".
    const request = new Request('https://images.fitcheckaiapp.com/%zz/items/x.webp', {
      headers: { Authorization: `Bearer ${await mintToken()}` },
    });
    const res = await worker.fetch(request, makeEnv(), ctx);
    assert.equal(res.status, 404);
  });

  it('404s a thumb key with a non-webp extension', async () => {
    // Thumbs are always .webp; a `_thumb.jpg` key cannot have been written by us.
    const key = `${USER}/items/${NAME}_thumb.jpg`;
    const env = makeEnv({ objects: { [key]: r2Object() } });
    const res = await call(key, { token: await mintToken(), env });
    assert.equal(res.status, 404);
  });

  it('404s a missing object with the same body as an unauthorized one', async () => {
    const env = makeEnv({ objects: {} });
    const missing = await call(KEY, { token: await mintToken(), env });
    const unauthorized = await call(KEY, { env });
    assert.equal(missing.status, unauthorized.status);
    assert.equal(await missing.text(), await unauthorized.text());
  });
});

// ==========================================================================
// 3. cache-control — do not override a deliberate short TTL
// ==========================================================================
describe('cache-control', () => {
  it('defaults to 24h immutable for write-once image objects', async () => {
    const res = await call(KEY, { token: await mintToken() });
    assert.equal(res.headers.get('Cache-Control'), 'public, max-age=86400, immutable');
  });

  it('overrides the app default max-age=3600 on a write-once key', async () => {
    // THE REAL-WORLD CASE. S3StorageBackend.upload stamps
    // `max-age=<DEFAULT_CACHE_CONTROL>` (3600) on every object the app writes,
    // thumbnails included, so httpMetadata.cacheControl is ALWAYS set. Honouring
    // it unconditionally made the 24h immutable policy unreachable in production
    // and cost 24x the origin fetches the R2 cutover existed to remove. The
    // previous test only "passed" because it stubbed cacheControl: undefined,
    // which no real object has.
    const env = makeEnv({
      objects: { [KEY]: r2Object({ cacheControl: 'max-age=3600' }) },
    });
    const res = await call(KEY, { token: await mintToken(), env });
    assert.equal(res.headers.get('Cache-Control'), 'public, max-age=86400, immutable');
  });

  it('applies the immutable policy to thumbnail siblings too', async () => {
    const thumbKey = `${USER}/items/${NAME}_thumb.webp`;
    const env = makeEnv({
      objects: { [thumbKey]: r2Object({ cacheControl: 'max-age=3600' }) },
    });
    const res = await call(thumbKey, { token: await mintToken(), env });
    assert.equal(res.headers.get('Cache-Control'), 'public, max-age=86400, immutable');
  });

  it('leaves a short-lived nested preview key on its own TTL', async () => {
    // tmp/ and generated/ objects are NOT write-once-immutable in the same way,
    // so the object still decides there (both layouts).
    for (const previewKey of [
      `tmp/${USER}/social-import/${NAME}.webp`,
      `${USER}/tmp/social-import/${NAME}.webp`,
    ]) {
      const env = makeEnv({
        objects: { [previewKey]: r2Object({ cacheControl: 'max-age=60' }) },
      });
      const res = await call(previewKey, { token: await mintToken(), env });
      assert.equal(res.headers.get('Cache-Control'), 'max-age=60');
    }
  });

  it('honours a MORE restrictive object cache-control on a write-once key', async () => {
    // The immutable default must never pin something the uploader marked private.
    const env = makeEnv({
      objects: { [KEY]: r2Object({ cacheControl: 'private, max-age=0' }) },
    });
    const res = await call(KEY, { token: await mintToken(), env });
    assert.equal(res.headers.get('Cache-Control'), 'private, max-age=0');
  });

  it('does not attempt to edge-cache a no-store object', async () => {
    // caches.default.put REJECTS a no-store response; an unhandled rejection
    // inside waitUntil would fire on every request for such an object.
    const env = makeEnv({
      objects: { [KEY]: r2Object({ cacheControl: 'no-store' }) },
    });
    const res = await call(KEY, { token: await mintToken(), env });
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('Cache-Control'), 'no-store');
    assert.deepEqual(putCalls, []);
  });

  it('still caches a normal public object', async () => {
    await call(KEY, { token: await mintToken() });
    assert.equal(putCalls.length, 1);
  });
});

// ==========================================================================
// 4. CORS
// ==========================================================================
describe('CORS', () => {
  it('answers preflight for an allowed origin', async () => {
    const res = await call(KEY, { method: 'OPTIONS', origin: ORIGIN });
    assert.equal(res.status, 204);
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), ORIGIN);
    assert.match(res.headers.get('Access-Control-Allow-Methods'), /GET/);
  });

  it('refuses preflight for an unlisted origin', async () => {
    const res = await call(KEY, { method: 'OPTIONS', origin: 'https://evil.example' });
    assert.equal(res.status, 403);
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), null);
  });

  it('echoes the allowed origin on a served image and Varies on Origin', async () => {
    const res = await call(KEY, { token: await mintToken(), origin: ORIGIN });
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), ORIGIN);
    assert.match(res.headers.get('Vary') || '', /Origin/);
  });

  it('sends no CORS header for an unlisted origin', async () => {
    const res = await call(KEY, { token: await mintToken(), origin: 'https://evil.example' });
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), null);
  });

  it('re-applies CORS to an edge-cache hit stored without it', async () => {
    // The shared cache entry may have been stored for a different Origin; the
    // response must not leak one origin ACAO to another, nor drop it entirely.
    installCachesStub({
      hit: new Response('CACHED', { status: 200, headers: { 'Content-Type': 'image/webp' } }),
    });
    const res = await call(KEY, { token: await mintToken(), origin: ORIGIN });
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), ORIGIN);
    assert.equal(await res.text(), 'CACHED');
  });

  it('does not inherit a cached entry ACAO for an unlisted origin', async () => {
    // The entry is shared per zone. Overwriting-but-not-deleting left the first
    // caller's Access-Control-Allow-Origin on it.
    installCachesStub({
      hit: new Response('CACHED', {
        status: 200,
        headers: {
          'Content-Type': 'image/webp',
          'Access-Control-Allow-Origin': ORIGIN,
          Vary: 'Origin',
        },
      }),
    });
    const res = await call(KEY, {
      token: await mintToken(),
      origin: 'https://evil.example',
    });
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), null);
  });

  it('does not inherit a cached entry ACAO when there is no Origin at all', async () => {
    installCachesStub({
      hit: new Response('CACHED', {
        status: 200,
        headers: {
          'Content-Type': 'image/webp',
          'Access-Control-Allow-Origin': ORIGIN,
        },
      }),
    });
    const res = await call(KEY, { token: await mintToken() });
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), null);
  });

  it('405s a write method and still advertises Allow', async () => {
    const res = await call(KEY, { method: 'PUT', token: await mintToken() });
    assert.equal(res.status, 405);
    assert.match(res.headers.get('Allow'), /GET/);
  });
});

// ==========================================================================
// 5. range requests
// ==========================================================================
describe('range requests', () => {
  it('builds a valid Content-Range for an open-ended range (no range.end)', async () => {
    // R2 gives {offset, length} and may omit `end`; reading it produced
    // "bytes 5-undefined/10".
    const env = makeEnv({
      objects: { [KEY]: r2Object({ range: { offset: 5, length: 5 }, size: 10 }) },
    });
    const res = await call(KEY, { token: await mintToken(), range: 'bytes=5-', env });
    assert.equal(res.status, 206);
    assert.equal(res.headers.get('Content-Range'), 'bytes 5-9/10');
    assert.equal(res.headers.get('Content-Length'), '5');
    assert.doesNotMatch(res.headers.get('Content-Range'), /undefined/);
  });

  it('advertises Accept-Ranges on a full response', async () => {
    const res = await call(KEY, { token: await mintToken() });
    assert.equal(res.headers.get('Accept-Ranges'), 'bytes');
  });

  it('never stores a partial response in the edge cache', async () => {
    const env = makeEnv({
      objects: { [KEY]: r2Object({ range: { offset: 0, length: 4 }, size: 10 }) },
    });
    await call(KEY, { token: await mintToken(), range: 'bytes=0-3', env });
    assert.deepEqual(putCalls, [], 'a 206 body must not be cached under the full-object key');
  });

  it('caches a full 200 response', async () => {
    await call(KEY, { token: await mintToken() });
    assert.equal(putCalls.length, 1);
    assert.equal(putCalls[0].status, 200);
  });
});

// ==========================================================================
// 6. HEAD
// ==========================================================================
describe('HEAD', () => {
  it('returns headers with no body', async () => {
    const res = await call(KEY, { token: await mintToken(), method: 'HEAD' });
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('Content-Length'), '10');
    assert.equal(await res.text(), '', 'HEAD must not carry a body');
  });

  it('returns no body even when served from the edge cache', async () => {
    installCachesStub({
      hit: new Response('CACHEDBODY', { status: 200, headers: { 'Content-Type': 'image/webp' } }),
    });
    const res = await call(KEY, { token: await mintToken(), method: 'HEAD' });
    assert.equal(await res.text(), '');
  });

  it('404s an unauthorized HEAD', async () => {
    const res = await call(KEY, { method: 'HEAD' });
    assert.equal(res.status, 404);
  });
});

// ==========================================================================
// 7. JWKS handling (RS256) — cache poisoning and signing-key rotation
// ==========================================================================
//
// Two ways the old code blanked every image for every user for up to an hour:
//
//   a) `jwksCache = { keys: body.keys || [], fetchedAt: Date.now() }` stamped the
//      cache even for an unexpected 200 body (`{}` / `{"keys":[]}`), so an empty
//      key set was served for the full TTL though a retry a second later would
//      have worked. `res.ok` was the only freshness gate.
//   b) On a signing-key rotation new tokens carry a new `kid`. The cache still
//      held the pre-rotation set, the `kid` lookup missed, and the
//      `alg`-only fallback then picked the OLD key — crypto.subtle.verify
//      returned false and every request 404'd, with no cache-bust anywhere.

/** A fresh worker module instance, so module-scope jwksCache starts empty. */
let freshWorkerSeq = 0;
async function freshWorker() {
  freshWorkerSeq += 1;
  return (await import(`./worker.js?jwks=${freshWorkerSeq}`)).default;
}

async function rsaKeypair(kid) {
  const pair = await crypto.subtle.generateKey(
    {
      name: 'RSASSA-PKCS1-v1_5',
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: 'SHA-256',
    },
    true,
    ['sign', 'verify'],
  );
  const jwk = await crypto.subtle.exportKey('jwk', pair.publicKey);
  return { pair, jwk: { ...jwk, kid, alg: 'RS256', kty: 'RSA' } };
}

async function mintRs256(privateKey, kid, claims = {}) {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT', kid };
  const payload = {
    sub: USER,
    iss: `${SUPABASE_URL}/auth/v1`,
    exp: now + 3600,
    iat: now,
    ...claims,
  };
  const h = b64url(new TextEncoder().encode(JSON.stringify(header)));
  const p = b64url(new TextEncoder().encode(JSON.stringify(payload)));
  const sig = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' },
    privateKey,
    new TextEncoder().encode(`${h}.${p}`),
  );
  return `${h}.${p}.${b64url(new Uint8Array(sig))}`;
}

/** Stub global fetch to serve a scripted sequence of JWKS responses. */
function installJwksStub(bodies) {
  const calls = [];
  const original = globalThis.fetch;
  globalThis.fetch = async (url) => {
    calls.push(String(url));
    const body = bodies[Math.min(calls.length - 1, bodies.length - 1)];
    return new Response(JSON.stringify(body), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  };
  return { calls, restore: () => { globalThis.fetch = original; } };
}

async function callWith(mod, key, token, env = makeEnv()) {
  const request = new Request(`https://images.fitcheckaiapp.com/${key}`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${token}` },
  });
  return mod.fetch(request, env, ctx);
}

describe('JWKS (RS256)', () => {
  it('verifies an RS256 token against the published key', async () => {
    const mod = await freshWorker();
    const { pair, jwk } = await rsaKeypair('kid-1');
    const stub = installJwksStub([{ keys: [jwk] }]);
    try {
      const token = await mintRs256(pair.privateKey, 'kid-1');
      const res = await callWith(mod, KEY, token);
      assert.equal(res.status, 200);
      assert.equal(stub.calls.length, 1);
    } finally {
      stub.restore();
    }
  });

  it('does not cache an empty key set', async () => {
    const mod = await freshWorker();
    const { pair, jwk } = await rsaKeypair('kid-1');
    // First response is a bad-but-200 body; second is the real key set.
    const stub = installJwksStub([{ keys: [] }, { keys: [jwk] }]);
    try {
      const token = await mintRs256(pair.privateKey, 'kid-1');

      // Fails loudly (a JWKS outage is our problem, not the caller's) and,
      // crucially, does not become the cached answer for the next hour.
      const poisoned = await callWith(mod, KEY, token);
      assert.equal(poisoned.status, 500, 'an empty key set must not verify');

      // The retry must go back to the origin, not read a poisoned cache.
      const recovered = await callWith(mod, KEY, token);
      assert.equal(recovered.status, 200, 'one bad response must not blank an hour');
      assert.ok(stub.calls.length >= 2);
    } finally {
      stub.restore();
    }
  });

  it('re-fetches on a kid miss so a signing-key rotation recovers', async () => {
    const mod = await freshWorker();
    const before = await rsaKeypair('kid-old');
    const after = await rsaKeypair('kid-new');
    const stub = installJwksStub([{ keys: [before.jwk] }, { keys: [after.jwk] }]);
    try {
      // Warm the cache with the pre-rotation key set.
      const oldToken = await mintRs256(before.pair.privateKey, 'kid-old');
      assert.equal((await callWith(mod, KEY, oldToken)).status, 200);
      const callsAfterWarm = stub.calls.length;

      // Rotation: a token whose kid the cache has never seen.
      const newToken = await mintRs256(after.pair.privateKey, 'kid-new');
      const res = await callWith(mod, KEY, newToken);

      assert.equal(res.status, 200, 'a kid miss must bust the cache, not 404 for an hour');
      assert.ok(stub.calls.length > callsAfterWarm, 'expected a forced re-fetch');
    } finally {
      stub.restore();
    }
  });

  it('does not fall back to an alg-matched key with a different kid', async () => {
    // The old `keys.find(k => k.alg === header.alg)` fallback silently picked the
    // WRONG key here, turning a recoverable miss into a failed signature.
    const mod = await freshWorker();
    const signer = await rsaKeypair('kid-signer');
    const decoy = await rsaKeypair('kid-decoy');
    const stub = installJwksStub([{ keys: [decoy.jwk] }]);
    try {
      const token = await mintRs256(signer.pair.privateKey, 'kid-signer');
      const res = await callWith(mod, KEY, token);
      assert.equal(res.status, 404);
    } finally {
      stub.restore();
    }
  });
});
