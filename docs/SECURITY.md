# Security

Status: verified  
Last updated: 2026-08-08

## Authentication and authorization

- Supabase Auth for identity; backend verifies JWTs (`SUPABASE_JWT_SECRET`).
- Protected routes use `get_current_user` / deps in `app/api/v1/deps.py`.
- Prefer user-scoped queries (`user_id` filters) even when using the service role client.
- RLS should be enabled on user data tables in Supabase; treat service role as privileged and careful.

## Secrets

- Never commit real keys. Use `*.env.example` for names only.
- Production secrets via host env (not git).
- User-provided AI keys encrypted at rest (`AI_ENCRYPTION_KEY`, settings service).

## Input and output

- Backend: Pydantic models at API boundaries.
- Frontend: React escaping; avoid `dangerouslySetInnerHTML` unless audited.
- Social import and OAuth popup flows: watch XSS / open redirect classes (see backend tests for social import).
- Stripe webhooks: verify signatures in subscription paths.

## Transport and storage

- HTTPS in production.
- Images and assets live in a **private S3-compatible bucket** (Railway Bucket
  or Cloudflare R2 — the S3 layer is provider-agnostic; R2's egress is $0, see
  `docs/exec-plans/active/2026-08-05-railway-egress-rca.md`). Validate
  ownership on upload/read paths in services.
- CORS configured via backend settings (`BACKEND_CORS_ORIGINS`, `FRONTEND_URL`).

### Storage serving model (private buckets, presigned URLs)

The bucket is private — there are no public object URLs. The DB stores the bucket
key (`storage_path`), never a URL. Read paths materialize a **short-lived presigned
GET URL** (default 1h, `OBJECT_STORAGE_PRESIGN_TTL=3600`) at serve time; clients must treat image URLs as
ephemeral and re-fetch as needed. The download path (`download_to_base64` /
`download_and_downscale_to_base64`) is **SSRF-safe**: it reduces a caller-supplied
string to a known bucket key via `key_from_path`
([storage_service.py](../backend/app/services/storage_service.py)) and reads it
from the S3 backend, never from an arbitrary URL. `build_object_url` exists only as
a stable locator for inventory tooling, not as a served endpoint.

### Worker serving mode (stable, cacheable URLs — `IMAGE_SERVING_MODE=worker`)

Rotating presigned URLs defeat every cache (the URL's query-string signature
changes per fetch), so Phase 2 of the egress RCA serves images through a
**Cloudflare Worker** (`infra/images-worker/`) on a custom domain with
**stable, path-only URLs** (`https://<base>/{storage_path}`):

- The Worker validates the caller's Supabase access token (HS256 with
  `SUPABASE_JWT_SECRET`, or the project JWKS for ES256/RS256) from the
  `Authorization` header or the `sb-<ref>-auth-token` cookie, and enforces the
  same per-user path ownership as the backend (`_is_owned_by_user`): the
  owning path segment must equal the token's `sub` — the **first** segment for
  canonical keys (`{user}/items|outfits|avatars|sources|feedback/...`) and for
  the legacy per-user preview keys (`{user}/tmp/...`, `{user}/generated/...`),
  the **second** segment for the top-level preview folders
  (`tmp/{user}/...`, `generated/{user}/...`). Any mismatch returns 404,
  indistinguishable from a missing object.
- Responses are cached at the Cloudflare edge keyed by path only. Accepted
  trade-off: an edge-cached object is served to anyone who knows the path for
  the TTL. Paths embed the user UUID + a uuid4 name (unguessable), and URLs are
  only ever issued by ownership-checked API responses; objects are write-once
  per key (`immutable` caching is correct).
- Read paths materialize worker URLs when configured; AI provider-bound fetches
  always stay **presigned** (providers cannot send JWTs).
- Web clients can only authenticate via the `sb-<ref>-auth-token` cookie
  (`<img>` tags cannot set headers); the frontend must set that cookie scoped
  to the registrable domain before worker mode is enabled on web — see TD-068
  and `infra/images-worker/README.md`.

### Storage access model (thumbnails + deletes)

- Every canonical image (items/outfits/avatars/sources/feedback) gets a
  `_thumb` sibling at upload; `thumbnail_url` points at it when
  `THUMBNAIL_SERVING=true`. Delete paths and account deletion remove thumbs
  with their originals; the inventory script treats `_thumb` keys as
  referenced, never orphaned.
- Thumb creation is **best-effort**, so `thumbnail_url` can name an object that
  was never written (undecodable bytes, a failed PUT, or an object predating the
  backfill). Clients therefore retry the full size on a thumb error rather than
  the read path proving existence per object — `useImageWithFallback` /
  `thumbnailErrorFallback` on web, `AppNetworkImage.fallbackUrl` on Flutter.

### Account deletion: erase the person, keep the record

`DELETE /users/me` removes the profile row, the Auth user, every storage object
(including the deterministic `{user_id}/export/data.json` archive) and the
wardrobe embeddings.

`support_tickets` is deliberately **anonymized, not deleted**: `user_id` and
`contact_email` are cleared and the ticket body, category and status survive.
The column is `ON DELETE SET NULL` for exactly this reason (`009_support_tickets`
also supports anonymous submissions). The table holds in-app **content reports
about other users** and open support/billing threads, so hard-deleting a
requester's rows destroys the only record of a third party's violation — the
reported user is never actioned and the content stays up — along with any
unresolved dispute. Erasure applies to the requester's personal data; severing
every link back to them satisfies it without deleting evidence about someone
else. Attachment objects are still purged with the rest of the user's storage.

The AI provider boundary can fetch image URLs server-side (`GeminiProvider`
downloads http(s) image parts for vision/try-on). Those fetches are bounded
(10 MB, 20 s) and gated by an SSRF guard that refuses loopback, link-local
(`169.254.x`), RFC1918, multicast, reserved and unspecified IP literals plus
`localhost` / `.local` / `.internal` hostnames before any request is made.
Route-level input validation additionally requires owned storage paths
(canonical layout) or public https URLs for try-on avatars, so a stored avatar
URL can never point the backend at an internal endpoint.

## Logging and PII

- Correlation IDs on requests; avoid logging raw tokens or full card data.
- Prefer user ids over emails in logs when possible.

## Agent checklist

When touching auth, billing, sharing, or file upload:

1. Confirm auth dependency on the route.  
2. Confirm user ownership checks on read/write.  
3. Add/adjust tests for abuse cases when practical.  
4. Update this doc if a new threat class is introduced.  

Related: `docs/references/auth-flow.md`, `docs/references/error-handling.md`.
