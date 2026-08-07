# FitCheck image-serving Worker

Cloudflare Worker that serves the private R2 bucket behind **stable, path-only
URLs** (`https://<base>/{user_id}/{category}/{name}`), so the Cloudflare edge,
the browser HTTP cache, and Flutter's disk cache can all hit — fixing the
egress driver where rotating presigned URLs bust every cache and re-stream
full-size bytes on every wardrobe load. Combined with R2's free egress, image
serving stops being a billed Railway line.

This is Phase 2 of the Railway egress RCA
(`docs/exec-plans/active/2026-08-05-railway-egress-rca.md`). Phase 1 (move the
bucket to R2, keep presigned serving) lands first; this Worker flips the app
to `IMAGE_SERVING_MODE=worker`.

## Files

| File | Purpose |
|------|---------|
| `worker.js` | Worker implementation (auth + ownership + R2 + edge cache) |
| `worker.test.mjs` | Tests for the authorization boundary (`npm test`) |
| `package.json` | Marks the directory as ESM + wires `npm test` |
| `wrangler.toml.example` | Wrangler config template (copy to `wrangler.toml`) |

## How it works

1. Client fetches a stable URL it received from the backend's read path
   (`materialize_image_urls` in `backend/app/api/v1/images.py` when
   `IMAGE_SERVING_MODE=worker`).
2. The Worker validates the caller's Supabase access token — from the
   `Authorization: Bearer` header (Flutter, API clients) or the
   `sb-<ref>-auth-token` cookie (web app). Validation covers the **signature**
   (HS256 via `SUPABASE_JWT_SECRET`, or ES256/RS256 via the project JWKS) **and
   the claims**: `exp` is required and enforced (60s skew allowance), `nbf` is
   honoured, and `iss` must be this project's auth issuer. Signature-only
   verification would make any leaked token valid forever.
3. Authorization mirrors the backend (`images.py::_is_owned_by_user`) — the full
   key allowlist, not just a prefix test: the key must match the canonical
   layout (`{user}/{items|outfits|avatars|sources|feedback}/{32hex}.{ext}`, plus
   `_thumb` siblings) or the preview layout (`{tmp|generated}/{user}/{sub}/...`
   top-level folders, or the legacy `{user}/{tmp|generated}/{sub}/...` form),
   **and** the owning path segment must equal the token's `sub` — the first
   segment for canonical/legacy keys, the second for the top-level `tmp/` and
   `generated/` folders. Any mismatch → 404, indistinguishable from a missing
   object. The allowlist is what keeps `{user}/export/data.json` — the user's
   complete personal-data export — from being servable here.
4. The object is streamed from the R2 binding with
   `Cache-Control: public, max-age=86400, immutable` and stored in
   `caches.default` keyed by path only, so repeat views hit the edge. An object
   that carries its own `cache-control` keeps it, so a deliberately short-lived
   object cannot be pinned at the edge for a day.
5. CORS: `ALLOWED_ORIGINS` (a `[vars]` entry in `wrangler.toml`) lists the
   origins allowed to read a response cross-origin. Required because the web app
   `fetch()`es image URLs to build Blobs (download / share) and reads one through
   a canvas. Plain `<img>` rendering needs no CORS and works regardless.

## Cross-user images stay presigned

The ownership rule means the Worker can only ever serve the **caller's own**
objects. Two surfaces legitimately need someone else's image and therefore must
NOT use worker URLs:

- the gamification leaderboard (other users' avatars), and
- AI provider callbacks (a provider cannot present the app's JWT).

Both go through `images.materialize_avatar_url(..., presigned=True)`, which
forces a signed URL regardless of `IMAGE_SERVING_MODE`. If you add another
cross-user image surface, it needs the same treatment — otherwise it silently
renders nothing after the worker-mode flip.

## Tests

```bash
cd infra/images-worker && npm test     # node --test, no dependencies
```

Also run by `scripts/check_all.sh`. The suite covers expired/`exp`-less/wrong-
issuer/wrong-secret tokens, the key allowlist (including the data-export
regression), cache-control precedence, CORS and preflight, `Content-Range` for
open-ended ranges, and HEAD-with-no-body.

## Web browser auth (REQUIRED before worker-mode cutover)

The web app must present the access token to the Worker on every image
request, but `<img>` tags cannot set headers. The Worker therefore also
accepts the Supabase auth cookie `sb-<ref>-auth-token` — **but supabase-js
only sets that cookie when the cookie auth flow is configured**. The current
frontend (`frontend/src/lib/supabase.ts`) uses the default browser
`createClient` (localStorage persistence), which sets NO cookies, and a
host-only cookie on `fitcheckaiapp.com` would not reach
`images.fitcheckaiapp.com` anyway.

So before flipping `IMAGE_SERVING_MODE=worker`, the frontend must set the
cookie itself, scoped to the registrable domain:

```ts
// on session change / app start (after supabase.auth.getSession()):
const session = (await supabase.auth.getSession()).data.session;
if (session?.access_token) {
  document.cookie = `sb-${projectRef}-auth-token=${session.access_token}; ` +
    `Domain=.fitcheckaiapp.com; Path=/; Max-Age=${session.expires_in}; ` +
    `Secure; SameSite=Lax`;
}
```

`SameSite=Lax` is safe here: an image subresource request from
`fitcheckaiapp.com` to `images.fitcheckaiapp.com` is **same-site** (same
eTLD+1), so Lax cookies ARE sent on it. Refresh the cookie whenever the
session token rotates (supabase-js auto-refreshes; listen to
`onAuthStateChange` `TOKEN_REFRESHED`).

**The cookie alone is not enough for the `fetch()` paths.** `<img>` sends cookies
for a same-site subresource, but `fetch()` defaults to
`credentials: 'same-origin'`, so a cross-origin fetch to `images.…` sends none and
gets a 404. The four download/share paths therefore also need
`fetch(url, { credentials: 'include' })`:

| File | Call |
|------|------|
| `frontend/src/lib/utils.ts` | generic download |
| `frontend/src/components/social/ShareOutfitDialog.tsx` | share |
| `frontend/src/pages/photoshoot/components/PhotoshootResultsStep.tsx` | download |
| `frontend/src/pages/try-on/TryOnPage.tsx` | download |

With `credentials: 'include'` the Worker must echo an exact origin (never `*`) and
send `Access-Control-Allow-Credentials: true` — it does both, via
`ALLOWED_ORIGINS`. `frontend/src/lib/crop-from-bounding-box.ts` uses
`img.crossOrigin = 'anonymous'`, which sends NO credentials, so a cropped image
must be one fetched in presigned mode (or the attribute becomes
`use-credentials`).

Until all of that lands, **keep the web on presigned mode**: R2 egress is $0, so
the web loses nothing in cost by staying presigned — it only misses the
edge/browser cache hit. (See TD-068 in `docs/exec-plans/tech-debt-tracker.md`.)

## Deployment

```bash
cd infra/images-worker
cp wrangler.toml.example wrangler.toml
# edit wrangler.toml: bucket_name, ALLOWED_ORIGINS, [routes] for the custom domain
npx wrangler secret put SUPABASE_URL
npx wrangler secret put SUPABASE_JWT_SECRET
npx wrangler deploy
```

Prerequisites: the R2 bucket (created for the Phase 1 migration), the zone for
the custom domain (e.g. `images.fitcheckaiapp.com`), and `SUPABASE_JWT_SECRET`
matching the backend (needed only for legacy HS256 tokens; ES256/RS256 tokens
verify against the project JWKS automatically). `SUPABASE_URL` is not optional —
it is both the JWKS source and the expected `iss` value.

## Cutover

1. Backend: set `IMAGE_SERVING_MODE=worker` and
   `IMAGE_CDN_BASE_URL=https://images.fitcheckaiapp.com`.
2. Web: **do the cookie step above first** (see "Web browser auth"). Until
   the frontend sets the domain-scoped `sb-<ref>-auth-token` cookie, web
   images 404 in worker mode — keep the web on presigned mode instead.
3. Flutter: image fetches attach `Authorization: Bearer <token>` — the
   `cached_network_image` swap in `flutter/lib/core/widgets/app_network_image.dart`
   reads the current session token and passes it as `httpHeaders`.
4. Verification:
   - `curl -sI https://images.fitcheckaiapp.com/<user>/items/<name> -H "Authorization: Bearer <token>"` → 200, `cf-cache-status: MISS`, `Cache-Control: public, max-age=86400, immutable`.
   - Repeat the request → `cf-cache-status: HIT` (edge cache works).
   - No token → 404; another user's path → 404; an **expired** token → 404.
   - `<user>/export/data.json` → 404 (not a servable key).
   - `curl -H "Origin: https://www.fitcheckaiapp.com"` → the response carries
     `Access-Control-Allow-Origin` and `Vary: Origin`.
   - Backend list endpoint returns `image_url` starting with the CDN base.
   - The leaderboard still renders other users' avatars (they stay presigned by
     design — see "Cross-user images stay presigned").

## Rollback

Flip `IMAGE_SERVING_MODE` back to `presigned`. The presigned read path is
unchanged and still works against the R2 bucket; no client change is needed to
revert (URLs are materialized per response).

## Security notes

- The edge cache is keyed by path only and serves any caller who knows the
  path — accepted trade-off: paths embed the user UUID plus a uuid4 hex name
  (unguessable), and the only way to obtain a URL is an ownership-checked API
  response. This relaxes the "private bucket, nothing public" posture
  (TD-036) to "private bucket + ownership-checked URL issuance + unguessable
  keys". If hard per-request auth is required later, move the token check to
  a signed cookie and keep the cache key path-only.
- Objects are write-once per key (uploads mint new UUID keys), so
  `immutable` caching is safe; overwriting a key in place requires a manual
  purge (`caches.default` TTL will eventually evict). An object uploaded with
  its own `cache-control` keeps that value instead of the immutable default, so
  a short-TTL object cannot be pinned at the edge.
- Only allowlisted image keys are servable. Non-image objects that live under a
  user prefix — notably `{user}/export/data.json` — are 404 here, which is the
  reason the allowlist exists rather than a prefix check.
- Ranged responses (`206`) are never written to the edge cache, so a partial
  body can never be served later as if it were the whole object.
- A cache hit re-applies CORS headers for the current request's Origin, because
  the shared entry may have been stored for a different origin (or none).
