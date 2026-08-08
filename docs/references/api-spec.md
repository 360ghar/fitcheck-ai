# API Specification

> **Generated document.** This file is generated from the live FastAPI OpenAPI document (`GET /api/v1/openapi.json`, exposed at `/api/v1/docs`). Do not edit by hand — regenerate after backend API changes:
>
> ```bash
> cd backend && source .venv/bin/activate && python ../scripts/generate_api_spec_doc.py
> ```
>
> Or from the repo root: `python scripts/generate_api_spec_doc.py [OUTPUT_PATH]`. CI drift-checks this file (`.github/workflows/backend-ci.yml`), so API changes must land with a regenerated copy.

## Overview

This reference covers **203** operations across **178** paths, grouped by router. Request bodies and response models are rendered from the OpenAPI `components.schemas`; where a route is declared with an arbitrary-JSON response model (no schema), the response is documented as the `{data, message}` envelope and the shape of `data` should be confirmed against the route source.

Job-based endpoints (photoshoot, batch extraction, social import) accept work asynchronously: they return a `job_id` in `data` immediately (202) and expose `/status` polling plus `/events` SSE streams (see TD-020 below).

## Known reconciliation points

These curated caveats carry forward from manual review of the API and remain true at generation time (see `docs/exec-plans/tech-debt-tracker.md`):

- **TD-023** — `POST /api/v1/items/upload` declares `202 Accepted` but runs synchronously: it uploads all files and returns the final result in the same response; there is no job to poll.
- **TD-020** — SSE terminal event names differ between streams: batch and photoshoot emit `job_complete`; social import emits `job_completed`.
- **Feature flags alter route behavior** — `ENABLE_SOCIAL_IMPORT` mounts the social-import router and `ENABLE_GAMIFICATION` is enforced inside handlers (the router stays mounted); the OpenAPI above reflects the flags enabled at generation time.
- **Stripe price IDs are environment configuration** (`STRIPE_*_PRICE_ID`), not API data.
- **Outfit garment references** — generation sends the avatar plus up to `AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES` (default 12) garment reference images per generation (the request list is separately capped at `AI_MAX_OUTFIT_ITEMS`, default 100); provider image-count behavior for garment references remains unverified (TD-033).

## Base URL

```text
Development: http://localhost:8000/api/v1
Production:  https://api.fitcheckaiapp.com/api/v1
```

The web app calls the API same-origin through a proxy (`/api` → backend in dev; Netlify redirect to `api.fitcheckaiapp.com` in prod); mobile apps use the absolute production origin.

## Authentication

All endpoints except the public set below require a JWT bearer token in the `Authorization` header:

```text
Authorization: Bearer <jwt_token>
```

The OpenAPI security scheme is `HTTPBearer`; tokens are verified server-side (`app/core/security.py`), and admin routes additionally enforce RBAC via `require_admin` / `require_permission`.

Public endpoints (no auth required):

- `GET /`
- `GET /api/v1/ai/social-import/auth/oauth/callback`
- `POST /api/v1/auth/confirm-reset-password`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/reset-password`
- `GET /api/v1/blog/categories`
- `GET /api/v1/blog/posts`
- `GET /api/v1/blog/posts/{slug}`
- `GET /api/v1/calendar`
- `POST /api/v1/demo/extract-items`
- `POST /api/v1/demo/try-on`
- `GET /api/v1/health`
- `GET /api/v1/outfits/public/{outfit_id}`
- `POST /api/v1/photoshoot/demo`
- `GET /api/v1/photoshoot/demo/{job_id}/status`
- `GET /api/v1/photoshoot/use-cases`
- `POST /api/v1/promo/validate`
- `POST /api/v1/referral/validate`
- `POST /api/v1/subscription/apple/notifications`
- `POST /api/v1/subscription/google/notifications`
- `GET /api/v1/subscription/plans`
- `POST /api/v1/subscription/webhook`
- `POST /api/v1/waitlist/join`
- `GET /health`
- `GET /ready`
- `GET /robots.txt`

## Response Format

### Success Response

Routes wrap payloads in a `{data, message}` envelope (verified across the route modules; a few endpoints return a bare `{message}` — e.g. password reset). The shape of `data` varies per endpoint:

```json
{
  "data": {},
  "message": "OK"
}
```

Many routes declare `response_model=Dict[str, Any]`, so OpenAPI cannot enumerate `data`'s fields; endpoint sections show a model table only where a real response model is declared.

### Error Response

All error responses (from `backend/app/main.py` exception handlers) share this envelope — the `code` field carries the domain error code:

```json
{
  "error": "Error message",
  "code": "DOMAIN_ERROR_CODE",
  "details": {},
  "correlation_id": "..."
}
```

Handler mapping (from `app/main.py`):

| Source | HTTP status | `code` | `details` |
|--------|-------------|--------|-----------|
| `FitCheckException` | its `status_code` | class `error_code` | exception `details` |
| `StarletteHTTPException` | its status | `HTTP_ERROR` | `{}` |
| `RequestValidationError` | 422 | `VALIDATION_ERROR` | `{errors: [{field, message}]}` |
| Unhandled exception | 500 | `INTERNAL_ERROR` | `{}` |

`X-Correlation-ID` is also exposed on responses (CORS `expose_headers`).

Common domain error codes (full set in `backend/app/core/exceptions.py`):

| Code | Status | Meaning |
|------|--------|---------|
| `AUTH_UNAUTHORIZED` | 401 | Missing/invalid credentials |
| `AUTH_TOKEN_EXPIRED` | 401 | Access token has expired |
| `AUTH_TOKEN_INVALID` | 401 | Access token is invalid or malformed |
| `AUTH_EMAIL_EXISTS` | 409 | Email already registered |
| `PERMISSION_DENIED` | 403 | User lacks permission (admin RBAC) |
| `VALIDATION_ERROR` | 422 | Request body/query validation failed |
| `INVALID_INPUT` | 422 | Invalid input value |
| `FILE_TOO_LARGE` | 422 | Uploaded file exceeds the size limit |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | Unsupported file type |
| `ITEM_NOT_FOUND` | 404 | Wardrobe item not found |
| `OUTFIT_NOT_FOUND` | 404 | Outfit not found |
| `USER_NOT_FOUND` | 404 | User not found |
| `RATE_LIMIT_EXCEEDED` | 429 | Daily AI quota or IP rate limit hit |
| `AI_SERVICE_ERROR` | 503 | AI provider unavailable/failed |
| `STORAGE_SERVICE_ERROR` | 503 | Storage service unavailable |
| `DATABASE_ERROR` | 500 | Database operation failed |
| `SCHEMA_NOT_INITIALIZED` | 503 | Supabase schema/migrations incomplete |
| `SERVICE_UNAVAILABLE` | 503 | External service temporarily unavailable |
| `BILLING_NOT_CONFIGURED` | 503 | Stripe billing not configured for this deployment |
| `HTTP_ERROR` | varies | Generic HTTP exception (e.g. 404 from FastAPI) |
| `INTERNAL_ERROR` | 500 | Unhandled exception (catch-all handler) |

## Status Codes

| Code | Description |
|------|-------------|
| 200 | Success — body uses the success envelope. |
| 201 | Created — resource created. |
| 202 | Accepted — async job/upload accepted (see reconciliation points). |
| 204 | No Content — success with no body. |
| 207 | Multi-Status — partial success (photoshoot sync mode). |
| 400 | Bad Request — error envelope with a domain code. |
| 401 | Unauthorized — `AUTH_UNAUTHORIZED` / `AUTH_TOKEN_EXPIRED` / `AUTH_TOKEN_INVALID`. |
| 403 | Forbidden — `PERMISSION_DENIED` (admin routes re-check RBAC server-side). |
| 404 | Not Found — `NOT_FOUND` family (`ITEM_NOT_FOUND`, `OUTFIT_NOT_FOUND`, ...). |
| 409 | Conflict — e.g. `AUTH_EMAIL_EXISTS`, `SOCIAL_IMPORT_MFA_REQUIRED`. |
| 415 | Unsupported Media Type — `UNSUPPORTED_MEDIA_TYPE`. |
| 422 | Validation Error — `VALIDATION_ERROR` with `details.errors[]`. |
| 429 | Too Many Requests — `RATE_LIMIT_EXCEEDED` (AI daily quota / IP rate limit). |
| 500 | Internal Server Error — `INTERNAL_ERROR` / `DATABASE_ERROR`. |
| 501 | Not Implemented — e.g. the Stripe webhook endpoint when webhooks are not configured (`HTTPException(501)`). |
| 502 | Bad Gateway — e.g. `SOCIAL_IMPORT_OAUTH_EXCHANGE_ERROR`. |
| 503 | Service Unavailable — `AI_SERVICE_ERROR` / `SERVICE_UNAVAILABLE` / `SCHEMA_NOT_INITIALIZED` / `BILLING_NOT_CONFIGURED`. |

Error responses always use the error envelope below (with `correlation_id`); the `code` field is the domain code, not the HTTP status.

## Root & robots

### GET /

Root endpoint.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /robots.txt

Serve a permissive robots.txt at the API origin.

The frontend host serves its own SEO robots.txt; this only answers direct
hits to the backend origin (scanners, misrouted ingress) so they stop
producing 404 noise. API endpoints should not be crawled.
(RCA 2026-08-05: GET /robots.txt 404.)

**Auth:** none (public endpoint)

**Responses:**

- **200** Returns string.

## Health & readiness

### GET /api/v1/health

Compatibility alias for probes configured against /api/v1/health.

The canonical liveness endpoint is /health. Probes pointed at
/api/v1/health produced 404 noise (observed 2026-08-07); serve the same
cheap payload instead. Operators should still fix the probe path - this
only makes a misconfiguration harmless.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /health

Liveness probe for the hosting platform (Railway).

Must stay cheap and free of DB/network I/O. Platform probes poll this
path; any blocking work here can delay restarts or mark the deploy
unhealthy while the process is still fine. Schema/DB readiness lives
on GET /ready instead.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /ready

Readiness: schema cache status (no live multi-table scan on every hit).

Uses the 5-minute schema cache so operators can see migration state
without hammering Supabase. Cache misses run in a worker thread so the
event loop is not blocked. Not used by Railway restarts (/health is).

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

## Authentication Endpoints

### POST /api/v1/auth/confirm-reset-password

Confirm password reset with the token from the email.

Updates the user's password with the new password.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `access_token` | string (nullable) | no |  |
| `new_password` | string | yes |  |
| `refresh_token` | string (nullable) | no |  |
| `token` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/login

Login with email and password.

Returns JWT tokens and user data.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `password` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/logout

Logout user by invalidating the session.

With a Bearer access token, POSTs to Supabase /auth/v1/logout so the
session's refresh token is revoked server-side. Without one, falls back
to the legacy best-effort sign_out() on the anon client. Always
best-effort: a failure is logged and 204 is still returned — the client
discards its tokens regardless.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, optional):

_No structured fields declared._

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/oauth/sync

Sync user profile after OAuth authentication.

Called by frontend after successful OAuth flow. Creates or updates
the user profile in public.users table if it doesn't exist.

This endpoint is idempotent - calling it multiple times is safe.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, optional):

_No structured fields declared._

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/refresh

Refresh access token using a refresh token.

Returns new access and refresh tokens.

Uses deduplication to prevent "Invalid Refresh Token: Already Used" errors
when multiple concurrent requests arrive with the same refresh token.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `refresh_token` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/register

Register a new user.

Creates a user in Supabase Auth and adds a profile to the public.users table.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `full_name` | string (nullable) | no |  |
| `password` | string | yes |  |
| `referral_code` | string (nullable) | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/auth/reset-password

Request a password reset email.

Sends an email with a password reset link to the user's email address.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Waitlist

### POST /api/v1/waitlist/join

Join the mobile app waitlist.

Public endpoint - no authentication required, so it is IP rate limited.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `full_name` | string (nullable) | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Demo

### POST /api/v1/demo/extract-items

Extract clothing items from an image (demo mode).

Public endpoint - no authentication required.
Rate limited to 3 requests per day per IP.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `image` | string | yes | Base64-encoded image data |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/demo/try-on

Generate a virtual try-on visualization (demo mode).

Public endpoint - no authentication required.
Rate limited to 2 requests per day per IP.
User provides both person photo and clothing photo.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `clothing_description` | string (nullable) | no | Optional description of the clothing |
| `clothing_image` | string | yes | Base64-encoded clothing photo |
| `person_image` | string | yes | Base64-encoded person photo |
| `style` | string | no | Overall style (casual, formal, etc.) |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Users

### GET /api/v1/users/body-profile

Get Body Profile

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### PUT /api/v1/users/body-profile

Upsert Body Profile

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `body_shape` | string (nullable) | no |  |
| `height_cm` | number (nullable) | no |  |
| `is_default` | boolean (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `skin_tone` | string (nullable) | no |  |
| `weight_kg` | number (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/users/body-profiles

List all body profiles for the user.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/users/body-profiles

Create a new body profile.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `body_shape` | string | yes |  |
| `height_cm` | number | yes |  |
| `is_default` | boolean | no |  |
| `name` | string | yes |  |
| `skin_tone` | string | yes |  |
| `weight_kg` | number | yes |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/users/body-profiles/{profile_id}

Update an existing body profile.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `profile_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `body_shape` | string (nullable) | no |  |
| `height_cm` | number (nullable) | no |  |
| `is_default` | boolean (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `skin_tone` | string (nullable) | no |  |
| `weight_kg` | number (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/users/body-profiles/{profile_id}

Delete a body profile.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `profile_id` | path | string (uuid) | yes |  |

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/users/dashboard

Aggregate endpoint for the dashboard UI.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/users/export

Generate a JSON archive of the current user's data and return a
short-lived presigned download URL.

Metadata only: rows carry their storage keys (``storage_path``); image
bytes are never included. The archive is written to a single
deterministic key per user (``{user_id}/export/data.json``, overwritten on
each call - the same key account deletion cleans up), and served as a
short-lived presigned GET URL (the repo's ~15-minute pattern). Every call
returns a fresh URL, so repeat requests never hand out a stale link.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/users/me

Get Current User

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### PUT /api/v1/users/me

Update Current User

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_url` | string (nullable) | no |  |
| `birth_date` | string (date) (nullable) | no |  |
| `birth_place` | string (nullable) | no |  |
| `birth_time` | string (nullable) | no |  |
| `full_name` | string (nullable) | no |  |
| `gender` | string (nullable) | no |  |
| `is_active` | boolean (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/users/me

Delete the current user's account and data.

External vectors/storage are cleaned before the public user row is removed.
The public row is deleted before Auth so an Auth outage cannot leave a live
user profile and wardrobe behind. Auth and Postgres still cannot share a
transaction; every boundary fails loudly and the operation is safe to
retry with the same authenticated session.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **204** No Content

### POST /api/v1/users/me/avatar

Upload Avatar

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | file (binary) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/users/preferences

Get User Preferences

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### PUT /api/v1/users/preferences

Update User Preferences

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `color_temperature` | string (nullable) | no |  |
| `data_points_collected` | integer (nullable) | no |  |
| `disliked_patterns` | array<string> (nullable) | no |  |
| `favorite_colors` | array<string> (nullable) | no |  |
| `liked_brands` | array<string> (nullable) | no |  |
| `preferred_occasions` | array<string> (nullable) | no |  |
| `preferred_styles` | array<string> (nullable) | no |  |
| `style_personality` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/users/settings

Get User Settings

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### PUT /api/v1/users/settings

Update User Settings

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `dark_mode` | boolean (nullable) | no |  |
| `default_location` | string (nullable) | no |  |
| `email_marketing` | boolean (nullable) | no |  |
| `language` | string (nullable) | no |  |
| `measurement_units` | string (nullable) | no |  |
| `notifications_enabled` | boolean (nullable) | no |  |
| `timezone` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Items

### GET /api/v1/items

Browse items with filtering and pagination.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `brand` | query | string (nullable) | no |  |
| `category` | query | string (nullable) | no |  |
| `color` | query | string (nullable) | no |  |
| `condition` | query | string (nullable) | no |  |
| `is_favorite` | query | boolean (nullable) | no |  |
| `occasion` | query | string (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `search` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items

Create a new wardrobe item.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `condition` | string | no |  |
| `images` | array<`ItemImageBase`> | no |  |
| `is_favorite` | boolean | no |  |
| `material` | string (nullable) | no |  |
| `materials` | array<string> | no |  |
| `name` | string | yes |  |
| `notes` | string (nullable) | no |  |
| `occasion_tags` | array<string> | no |  |
| `pattern` | string (nullable) | no |  |
| `price` | number (nullable) | no |  |
| `purchase_date` | string (date-time) (nullable) | no |  |
| `purchase_location` | string (nullable) | no |  |
| `seasonal_tags` | array<string> | no |  |
| `size` | string (nullable) | no |  |
| `source_image_storage_path` | string (nullable) | no |  |
| `source_image_url` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/batch-delete

Batch delete items (and best-effort remove embeddings/images).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `item_ids` | array<string> | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/items/by-category/{category}

Get Items By Category

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/check-duplicates

Check for potential duplicate items in the user's wardrobe.

Uses AI embeddings to find items with similar attributes.
Called before creating a new item to warn about potential duplicates.

Args:
    request: Item attributes to check for duplicates
    threshold: Minimum similarity score to consider a duplicate (default 0.75)
    limit: Maximum number of duplicates to return (default 5)

Returns:
    has_duplicates: Whether any duplicates were found
    duplicates: List of potential duplicate items with similarity scores
    threshold: The threshold used for matching

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no | Max duplicates to return |
| `threshold` | query | number | no | Similarity threshold (0.5-0.99) |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `material` | string (nullable) | no |  |
| `name` | string | yes |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/items/search

Search items by name/brand (best-effort; Supabase full-text can be added later).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no |  |
| `q` | query | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/items/stats

Compute wardrobe item statistics for dashboard/analytics.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/items/upload

Upload one or more images to Supabase Storage for later item creation.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `files` | array<file (binary)> | yes |  |

**Responses:**

- **202** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/items/{item_id}

Get Item

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/items/{item_id}

Update Item

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `condition` | string (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `material` | string (nullable) | no |  |
| `materials` | array<string> (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `notes` | string (nullable) | no |  |
| `occasion_tags` | array<string> (nullable) | no |  |
| `pattern` | string (nullable) | no |  |
| `price` | number (nullable) | no |  |
| `purchase_date` | string (date-time) (nullable) | no |  |
| `purchase_location` | string (nullable) | no |  |
| `seasonal_tags` | array<string> (nullable) | no |  |
| `size` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/items/{item_id}

Delete an item (hard delete).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/items/{item_id}/categories

Update item category-related fields (user override).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `materials` | array<string> (nullable) | no |  |
| `occasion_tags` | array<string> (nullable) | no |  |
| `seasonal_tags` | array<string> (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/{item_id}/categorize

Run lightweight categorization and persist derived fields.

Item extraction is server-side via the AI provider service. This endpoint focuses on
deriving metadata (style/materials/seasonal_tags) that powers recommendations.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/{item_id}/favorite

Toggle Favorite

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/{item_id}/images

Upload an additional image for an existing item.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | file (binary) | yes |  |
| `is_primary` | boolean | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/items/{item_id}/images/{image_id}

Delete an item image and best-effort remove it from storage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `image_id` | path | string (uuid) | yes |  |
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/items/{item_id}/similar

Find items similar to the specified item.

Uses AI embeddings for similarity matching. Useful for:
- Finding duplicates in existing wardrobe
- Discovering items that could be paired together
- Identifying items to consolidate or declutter

Args:
    item_id: The item to find similar items for
    limit: Maximum number of similar items to return
    min_score: Minimum similarity score (0-1)

Returns:
    List of similar items with similarity scores

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |
| `limit` | query | integer | no |  |
| `min_score` | query | number | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/items/{item_id}/wear

Mark Worn

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Outfits

### GET /api/v1/outfits

List Outfits

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `drafts_only` | query | boolean (nullable) | no |  |
| `favorites_only` | query | boolean (nullable) | no |  |
| `is_favorite` | query | boolean (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `search` | query | string (nullable) | no |  |
| `season` | query | string (nullable) | no |  |
| `seasons` | query | string (nullable) | no | Comma-separated season filters |
| `style` | query | string (nullable) | no |  |
| `styles` | query | string (nullable) | no | Comma-separated style filters |
| `tags` | query | string (nullable) | no | Comma-separated tags |

**Responses:**

**Response 200:** Returns `DataResponse_OutfitListResponse_`

| Field | Type | Required | Description |
|---|---|---|---|
| `data` | `OutfitListResponse` | yes |  |
| `message` | string | no |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits

Create Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_draft` | boolean | no |  |
| `is_favorite` | boolean | no |  |
| `is_public` | boolean | no |  |
| `item_ids` | array<string (uuid)> | no |  |
| `name` | string | yes |  |
| `occasion` | string (nullable) | no |  |
| `season` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/available-items

Return simplified items list suitable for outfit-building UIs.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/outfits/batch-delete

Batch delete outfits and best-effort remove their images from storage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_ids` | array<string> | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/collections

List Collections

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/outfits/collections

Create Collection

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_favorite` | boolean | no |  |
| `name` | string | yes |  |
| `outfit_ids` | array<string (uuid)> | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/outfits/collections/{collection_id}

Update Collection

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `collection_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `outfit_ids` | array<string (uuid)> (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/outfits/collections/{collection_id}

Delete Collection

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `collection_id` | path | string (uuid) | yes |  |

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/collections/{collection_id}/outfits

Add one owned outfit to a collection without replacing existing members.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `collection_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_id` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/outfits/collections/{collection_id}/outfits

Replace Collection Outfits

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `collection_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_ids` | array<string> | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/outfits/collections/{collection_id}/outfits/{outfit_id}

Remove one outfit from an owned collection.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `collection_id` | path | string (uuid) | yes |  |
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/favorites

Favorites

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/outfits/generation/{generation_id}

Get Generation Status

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `generation_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/public/{outfit_id}

Public outfit view for share links (no auth).

Only returns data when `is_public=true` on the outfit record.

**Auth:** none (public endpoint)

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/recently-worn

Recently Worn

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/stats

Compute outfit statistics for analytics/dashboard.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/outfits/suggestions/weather

Return simple outfit suggestions based on temperature and seasonal tags.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `temperature` | query | number | yes | Current temperature in Celsius |
| `weather_condition` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/{outfit_id}

Get Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

**Response 200:** Returns `DataResponse_OutfitResponse_`

| Field | Type | Required | Description |
|---|---|---|---|
| `data` | `OutfitResponse` | yes |  |
| `message` | string | no |  |

- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/outfits/{outfit_id}

Update Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_draft` | boolean (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `is_public` | boolean (nullable) | no |  |
| `item_ids` | array<string (uuid)> (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `occasion` | string (nullable) | no |  |
| `season` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `tags` | array<string> (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/outfits/{outfit_id}

Delete an outfit and best-effort remove its images from storage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **204** No Content
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/duplicate

Duplicate Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/favorite

Toggle Favorite

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/generate

Create a generation record and return a generation_id.

The frontend performs generation via the backend AI service and then uploads the
resulting image(s) to `/outfits/{outfit_id}/images` including the returned
generation_id to mark completion.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `body_profile_id` | string (uuid) (nullable) | no |  |
| `lighting` | string (nullable) | no |  |
| `pose` | string | no |  |
| `variations` | integer | no |  |

**Responses:**

- **202** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/images

Upload an outfit image and create an outfit_images record.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `body_profile_id` | string (nullable) | no |  |
| `file` | file (binary) | yes |  |
| `generation_id` | string (nullable) | no |  |
| `is_primary` | boolean | no |  |
| `lighting` | string (nullable) | no |  |
| `pose` | string | no |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/outfits/{outfit_id}/images/{image_id}

Delete an outfit image and best-effort remove it from storage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `image_id` | path | string (uuid) | yes |  |
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/items

Add Item To Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `item_id` | string | yes |  |
| `position` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/outfits/{outfit_id}/items/{item_id}

Remove Item From Outfit

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/share

Enable public sharing for an outfit and return a share URL.

MVP: visibility/expires_at are accepted but only `public` visibility is enforced.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `allow_feedback` | boolean | no |  |
| `custom_caption` | string (nullable) | no |  |
| `expires_at` | string (nullable) | no | ISO8601 datetime (optional) |
| `visibility` | string | no | public\|friends\|private |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/outfits/{outfit_id}/wear

Mark Worn

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/outfits/{outfit_id}/wear-history

Get wear history for an outfit.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `outfit_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Shared Outfits

### POST /api/v1/shared-outfits/{share_id}/feedback

Submit Feedback

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `share_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `comment` | string (nullable) | no |  |
| `rating` | integer | yes |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Recommendations

### GET /api/v1/recommendations/astrology

Return astrology-driven lucky colors with wardrobe-linked picks.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit_per_category` | query | integer | no |  |
| `mode` | query | string | no |  |
| `target_date` | query | string (date) (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/capsule

Return a simple capsule wardrobe suggestion from existing favorites.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_count` | query | integer | no |  |
| `season` | query | string (nullable) | no |  |
| `style` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/recommendations/complete-look

Generate complete outfit suggestions from a start item.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no |  |
| `occasion` | query | string (nullable) | no |  |
| `style` | query | string (nullable) | no |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `item_ids` | array<string> (nullable) | no |  |
| `limit` | integer (nullable) | no |  |
| `occasion` | string (nullable) | no |  |
| `start_item_id` | string (nullable) | no |  |
| `weather_condition` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/recommendations/match

Find items that match the given item(s).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | query | string (nullable) | no |  |
| `limit` | query | integer | no |  |
| `min_score` | query | integer | no |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `item_id` | string (nullable) | no |  |
| `item_ids` | array<string> (nullable) | no |  |
| `limit` | integer (nullable) | no |  |
| `match_type` | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/personalized

Return simple personalized recommendations (favorites + least worn).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no |  |
| `type` | query | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/shopping

Return actionable shopping recommendations based on wardrobe gaps.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `budget` | query | number (nullable) | no |  |
| `category` | query | string (nullable) | no |  |
| `style` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/similar

Similar Items

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | query | string (nullable) | no |  |
| `item_id` | query | string | yes |  |
| `limit` | query | integer | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/style/{item_id}

Style Analysis

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string (uuid) | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/recommendations/wardrobe-gaps

Wardrobe Gaps

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/recommendations/weather

Return a weather-driven recommendation object for the frontend.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `location` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/recommendations/{recommendation_id}/rate

Store user feedback to improve future recommendations.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `recommendation_id` | path | string (uuid) | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `rating` | string | yes | thumbs_up\|thumbs_down\|neutral |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Calendar

### GET /api/v1/calendar

Root handler for the calendar router.

Some clients (and probes) GET the bare ``/api/v1/calendar`` path; without a
root handler it 404s and adds log noise. The real functionality lives under
``/connect``, ``/connections`` and ``/events``. (RCA 2026-08-05: 404 noise.)

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/calendar/connect

Connect a calendar provider.

For MVP, we record the connection and return it.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `auth_code` | string (nullable) | no | OAuth auth code (if applicable) |
| `provider` | string | yes | google\|apple\|outlook\|local |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/calendar/connections

List connected calendar providers for the user.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### DELETE /api/v1/calendar/connections/{connection_id}

Disconnect a calendar provider (soft disable).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `connection_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/calendar/events

Get calendar events in a date range.

Both dates are optional, so without a bound this returned the user's
entire event history in one response. Default limit is deliberately
generous (500): existing clients send neither limit nor offset and expect
a whole month/year of events back.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `end_date` | query | string (nullable) | no | YYYY-MM-DD |
| `limit` | query | integer | no | Max events to return |
| `offset` | query | integer | no |  |
| `start_date` | query | string (nullable) | no | YYYY-MM-DD |

**Responses:**

- **200** SSE event stream (`text/event-stream`; OpenAPI declares no schema). Frames are `data: {…}` JSON; terminal events: batch and photoshoot emit `job_complete`, social import emits `job_completed` (TD-020).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/calendar/events

Create an in-app calendar event (local planning).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `calendar_id` | string (nullable) | no |  |
| `description` | string (nullable) | no |  |
| `end_time` | string | yes |  |
| `event_type` | string | no |  |
| `is_all_day` | boolean | no |  |
| `location` | string (nullable) | no |  |
| `outfit_id` | string (nullable) | no |  |
| `start_time` | string | yes |  |
| `title` | string | yes |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/calendar/events/{event_id}

Update a calendar event.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `event_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `end_time` | string (nullable) | no |  |
| `event_type` | string (nullable) | no |  |
| `is_all_day` | boolean (nullable) | no |  |
| `location` | string (nullable) | no |  |
| `outfit_id` | string (nullable) | no |  |
| `start_time` | string (nullable) | no |  |
| `title` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/calendar/events/{event_id}

Delete a calendar event.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `event_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/calendar/events/{event_id}/outfit

Assign an outfit to a calendar event.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `event_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_id` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/calendar/events/{event_id}/outfit

Remove outfit assignment from an event.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `event_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Weather

### GET /api/v1/weather

Get current weather (Celsius).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `location` | query | string (nullable) | no | City name or 'lat,lon' |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/weather/forecast

Get a simple daily forecast (Celsius).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `days` | query | integer | no |  |
| `location` | query | string (nullable) | no | City name or 'lat,lon' |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Gamification

### GET /api/v1/gamification/achievements

Get Achievements

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/gamification/leaderboard

Get Leaderboard

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/gamification/streak

Get Streak

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

## AI Settings

### GET /api/v1/ai/settings

Get AI settings for the current user.

Returns the default provider and configured provider settings (with masked API keys).

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### PUT /api/v1/ai/settings

Update AI settings for the current user.

Can update the default provider and provider-specific configurations.
API keys are encrypted before storage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `default_provider` | string (nullable) | no |  |
| `provider_configs` | object<`ProviderConfigInput`> (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/settings/rate-limit/{operation_type}

Check rate limit for a specific operation type.

Returns whether the operation is allowed and remaining quota.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `operation_type` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/settings/reset-provider/{provider}

Reset a provider configuration to defaults.

Removes any user-specific API key and URL for the specified provider.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `provider` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/settings/test

Test an AI provider configuration.

Sends a simple test request to verify the API URL and key are valid
(api_url is required for openai/custom, ignored for gemini).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `api_key` | string | yes |  |
| `api_url` | string (nullable) | no |  |
| `model` | string | yes |  |
| `provider` | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/settings/usage

Get AI usage statistics for the current user.

Returns daily and total usage counts along with rate limits.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

## Social Import

### GET /api/v1/ai/social-import/auth/oauth/callback

Social Oauth Callback

**Auth:** none (public endpoint)

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `code` | query | string (nullable) | no |  |
| `error` | query | string (nullable) | no |  |
| `error_description` | query | string (nullable) | no |  |
| `state` | query | string (nullable) | no |  |

**Responses:**

- **200** Returns string.
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs

Create Social Import Job

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `source_url` | string | yes |  |

**Responses:**

- **202** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/auth/oauth

Submit Oauth Auth

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `expires_at` | string (date-time) (nullable) | no |  |
| `provider_access_token` | string | yes |  |
| `provider_page_access_token` | string (nullable) | no |  |
| `provider_page_id` | string (nullable) | no |  |
| `provider_refresh_token` | string (nullable) | no |  |
| `provider_user_id` | string (nullable) | no |  |
| `provider_username` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/auth/oauth/connect

Create Oauth Connect Url

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |
| `mobile_redirect_uri` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/auth/scraper-login

Submit Scraper Login

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `otp_code` | string (nullable) | no |  |
| `password` | string | yes |  |
| `two_factor_identifier` | string (nullable) | no |  |
| `username` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/cancel

Cancel Social Import Job

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/social-import/jobs/{job_id}/events

Social Import Events

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |
| `last_event_id` | query | integer (nullable) | no |  |

**Responses:**

- **200** SSE event stream (`text/event-stream`; OpenAPI declares no schema). Frames are `data: {…}` JSON; terminal events: batch and photoshoot emit `job_complete`, social import emits `job_completed` (TD-020).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/photos/{photo_id}/approve

Approve Social Photo

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |
| `photo_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PATCH /api/v1/ai/social-import/jobs/{job_id}/photos/{photo_id}/items/{item_id}

Patch Social Item

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `item_id` | path | string | yes |  |
| `job_id` | path | string | yes |  |
| `photo_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `detailed_description` | string (nullable) | no |  |
| `material` | string (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `pattern` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/social-import/jobs/{job_id}/photos/{photo_id}/reject

Reject Social Photo

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |
| `photo_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/social-import/jobs/{job_id}/status

Get Social Import Status

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Batch Processing

### POST /api/v1/ai/batch-extract

Start a batch extraction job (JSON body with base64 images).

Prefer multipart ``POST /batch-extract-multipart`` from web clients for
smaller uploads. Extraction runs in parallel; product-image generation
starts as soon as each image's items are detected (overlapped).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no | Automatically start generation after extraction |
| `generation_batch_size` | integer | no | Max concurrent product-image generations for this job (1-30). The process-wide GENERATION_SEMAPHORE (same cap) is the hard ceiling regardless. Capped at 50 to match the DB CHECK valid_batch_size. |
| `images` | array<`BatchImageInput`> | yes | List of images to process (max 50) |

**Responses:**

**Response 202:** Returns `BatchJobResponse` — Response with job information.

| Field | Type | Required | Description |
|---|---|---|---|
| `job_id` | string | yes |  |
| `message` | string | yes |  |
| `sse_url` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/batch-extract-multipart

Start batch extraction via multipart file upload (preferred for web).

Smaller on the wire than base64 JSON. Same SSE progress contract as
``POST /batch-extract``.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no |  |
| `files` | array<file (binary)> | yes | Image files (1–50) |
| `generation_batch_size` | integer | no |  |
| `image_ids` | string (nullable) | no | Optional JSON array of client image IDs, parallel to files |

**Responses:**

**Response 202:** Returns `BatchJobResponse` — Response with job information.

| Field | Type | Required | Description |
|---|---|---|---|
| `job_id` | string | yes |  |
| `message` | string | yes |  |
| `sse_url` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/batch-extract/{job_id}/cancel

Cancel a running batch job.

Cancellation is best-effort - currently running operations may complete.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Returns object<string>.
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/batch-extract/{job_id}/events

SSE endpoint for real-time batch job progress.

Connect to this endpoint to receive real-time updates as images are processed.

Event types:
- connected: Initial connection established
- heartbeat: Keep-alive (every 30s)
- extraction_started: Extraction phase begins
- image_extraction_complete: Single image processed
- image_extraction_failed: Single image failed
- all_extractions_complete: All images processed
- generation_started: First generation batch started (overlaps extraction;
  total_items is only a partial count until all_extractions_complete)
- item_generation_complete: Single item image generated (total_items grows
  as later images finish extracting)
- item_generation_failed: Single item generation failed
- all_generations_complete: All items generated
- job_complete: Full pipeline complete
- job_failed: Pipeline failed
- job_cancelled: User cancelled job

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** SSE event stream (`text/event-stream`; OpenAPI declares no schema). Frames are `data: {…}` JSON; terminal events: batch and photoshoot emit `job_complete`, social import emits `job_completed` (TD-020).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/batch-extract/{job_id}/status

Get current status of a batch job.

Useful for reconnection scenarios or checking progress without SSE.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

**Response 200:** Returns `BatchJobStatusResponse` — Full job status response.

| Field | Type | Required | Description |
|---|---|---|---|
| `error` | string (nullable) | no |  |
| `extractions_completed` | integer | yes |  |
| `extractions_failed` | integer | yes |  |
| `generations_completed` | integer | yes |  |
| `generations_failed` | integer | yes |  |
| `items` | array<object> | yes |  |
| `job_id` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |
| `total_items` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

## AI Operations

### POST /api/v1/ai/embeddings

Generate an embedding for a single text.

Used for similarity matching and semantic search.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string (nullable) | no |  |
| `text` | string | yes | Text to generate embedding for |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/embeddings/batch

Generate embeddings for multiple texts in batch.

More efficient than calling single embedding endpoint multiple times.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string (nullable) | no |  |
| `texts` | array<string> | yes | List of texts to generate embeddings for |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/embeddings/search

Search for similar items using text or embedding.

Uses vector similarity to find matching items in the user's wardrobe.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `embedding` | array<number> (nullable) | no |  |
| `min_score` | number | no |  |
| `text` | string (nullable) | no |  |
| `top_k` | integer | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/embeddings/test

Test an embedding model configuration.

Generates a test embedding to verify the model is working correctly.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string | yes |  |
| `provider` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/extract-items

Extract multiple clothing items from an image.

Returns detected items with categories, colors, materials, bounding boxes,
and detailed descriptions suitable for image generation.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `image` | string (nullable) | no | Legacy base64-encoded image data |
| `storage_path` | string (nullable) | no | Owned storage key for the image |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/extract-single-item

Extract a single clothing item from an image.

Useful when the image contains only one item.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `category_hint` | string (nullable) | no |  |
| `image` | string (nullable) | no | Legacy base64-encoded image data |
| `storage_path` | string (nullable) | no | Owned storage key for the image |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/generate-outfit

Generate an outfit visualization image.

Creates a professional fashion photo or flat lay of the specified items.
If include_user_face is True and user has an avatar, generates with the user's face.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `background` | string | no |  |
| `custom_prompt` | string (nullable) | no |  |
| `include_model` | boolean | no |  |
| `include_user_face` | boolean | no |  |
| `items` | array<`OutfitItemInput`> | yes |  |
| `lighting` | string | no |  |
| `model_gender` | string | no |  |
| `pose` | string | no |  |
| `save_to_storage` | boolean | no |  |
| `style` | string | no |  |
| `use_body_profile` | boolean | no |  |
| `use_source_photo` | boolean | no |  |
| `view_angle` | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/generate-product-image

Generate a clean e-commerce style product image.

Creates a professional product photo suitable for catalog listings.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `background` | string | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `include_shadows` | boolean | no |  |
| `item_description` | string | yes |  |
| `material` | string (nullable) | no |  |
| `reference_image` | string (nullable) | no | Optional legacy base64 source photo |
| `reference_storage_path` | string (nullable) | no | Owned source photo storage key |
| `save_to_storage` | boolean | no |  |
| `sub_category` | string (nullable) | no |  |
| `view_angle` | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/ai/models

Get available AI models by provider.

Returns a list of recommended models for each provider type.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/ai/single-extract

Start a single-item extraction job with async processing.

Uses the same infrastructure as batch processing but optimized for single images.
Returns a job_id and SSE URL for real-time progress updates.

Includes intelligent caching - if the same image was extracted within the last 24 hours,
returns cached results immediately (indicated by 'cached: true' in response).

This provides feature parity with batch extraction - users get real-time updates
via SSE as items are detected and product images are generated.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no | Auto-generate product images |
| `image` | string | yes | Base64-encoded image (max ~10MB encoded) |
| `skip_cache` | boolean | no | Skip cache lookup (force fresh extraction) |

**Responses:**

**Response 202:** Returns `BatchJobResponse` — Response with job information.

| Field | Type | Required | Description |
|---|---|---|---|
| `job_id` | string | yes |  |
| `message` | string | yes |  |
| `sse_url` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/ai/try-on

Generate a virtual try-on image.

Combines user's profile picture with uploaded clothing image
to show how the user would look wearing those clothes.

Requires user to have uploaded a profile picture (avatar).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_storage_path` | string (nullable) | no | Owned avatar storage key; defaults to profile avatar |
| `background` | string | no |  |
| `clothing_description` | string (nullable) | no | Optional description to improve accuracy |
| `clothing_image` | string (nullable) | no | Legacy base64-encoded clothing image |
| `clothing_storage_path` | string (nullable) | no | Owned clothing image storage key |
| `lighting` | string | no |  |
| `pose` | string | no |  |
| `save_to_storage` | boolean | no |  |
| `style` | string | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Photoshoot

### POST /api/v1/photoshoot/demo

Start a demo photoshoot for anonymous users (job-based, polling status).

Rate limited to 1 demo per IP per day (generates 2 images).
Used for landing page trial experience.
Custom prompts are not allowed in demo mode.

Returns a job_id immediately; poll GET /demo/{job_id}/status for progress
and results. Demo jobs skip daily-quota reservation (the IP rate limit is
enforced here at creation time).

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `photo` | string | yes | Base64-encoded reference photo (max 10MB) |
| `use_case` | `PhotoshootUseCase` | no | The use case for the photoshoot (no custom allowed) |

**Responses:**

- **202** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/photoshoot/demo/{job_id}/status

Poll status of a demo photoshoot job (no auth).

Ownership is validated by re-deriving the demo pseudo-user from the
request IP, so one visitor cannot read another visitor's demo job.

**Auth:** none (public endpoint)

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/photoshoot/generate

Start a photoshoot generation job.

By default (sync=False), returns job_id immediately and processes in background.
Connect to /{job_id}/events for real-time SSE progress updates.

With sync=True, waits for completion and returns all images (legacy behavior).

- Upload 1-4 reference photos
- Select a use case or provide custom prompt
- Choose number of images (1-10, default 10)
- Optional batch_size for SSE progress granularity
- Optional aspect_ratio (1:1, 9:16, 16:9, 3:4, 4:3)

Daily limits:
- Free: 10 images/day
- Pro: 50 images/day

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `sync` | query | boolean | no | If true, wait for completion (sync mode) |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `aspect_ratio` | string | no | Aspect ratio for generated images: 1:1, 9:16, 16:9, 3:4, 4:3 |
| `batch_size` | integer | no | Number of images per batch for SSE progress updates |
| `custom_prompt` | string (nullable) | no | Custom prompt for 'custom' use case |
| `num_images` | integer | no | Number of images to generate (1-10) |
| `photos` | array<string> | yes | Base64-encoded reference photos (1-4, max 10MB each) |
| `use_case` | `PhotoshootUseCase` | yes | The use case for the photoshoot |

**Responses:**

- **202** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/photoshoot/usage

Get the current user's photoshoot usage for today.

Returns:
- used_today: Images generated today
- limit_today: Daily limit based on plan
- remaining: Images remaining today
- plan_type: Current subscription plan
- resets_at: When the daily limit resets (midnight UTC)

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/photoshoot/use-cases

Get all available photoshoot use cases.

Returns list of use cases with names, descriptions, and example prompts.
No authentication required.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/photoshoot/{job_id}/cancel

Cancel a running photoshoot job.

Cancellation is best-effort - currently running image generations may complete.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Returns object<string>.
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/photoshoot/{job_id}/events

SSE endpoint for real-time photoshoot job progress.

Connect to this endpoint after calling /generate to receive real-time updates
as images are generated.

Event types:
- connected: Initial connection established
- heartbeat: Keep-alive (every 30s)
- generation_started: Job started, includes total_batches
- batch_started: Batch started, includes batch_index
- image_complete: Single image generated, includes image data
- image_failed: Single image failed, includes error
- batch_complete: Batch finished
- job_complete: All done, includes session_id and usage
- job_failed: Job failed, includes error
- job_cancelled: Job was cancelled

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** SSE event stream (`text/event-stream`; OpenAPI declares no schema). Frames are `data: {…}` JSON; terminal events: batch and photoshoot emit `job_complete`, social import emits `job_completed` (TD-020).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/photoshoot/{job_id}/status

Get current status of a photoshoot job.

Useful for reconnection scenarios or checking progress without SSE.
Returns the same data format as SSE job_complete event.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `job_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Images

### GET /api/v1/images/presigned

Return a fresh client-fetchable URL for a caller-owned object.

The ``storage_path`` must be scoped to the authenticated user (key layout
prefix ``{user_id}/``). A request for another user's object returns 404 so
object existence is never revealed across users.

Routed through ``serve_url``, so the URL matches whatever the list/read paths
are emitting in the current ``IMAGE_SERVING_MODE``. Minting a presigned URL
here regardless would hand clients an uncacheable URL for an object every
other surface serves from the cacheable Worker origin — the response name is
historical, the contract is "a URL you can fetch now".

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `storage_path` | query | string | yes | Bucket key (storage_path) to serve |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Subscription

### GET /api/v1/subscription

Get current user's subscription status and usage.

Returns the subscription plan details, current period, and monthly usage stats.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/apple/notifications

Receive App Store Server Notifications V2 (renewals, expirations, refunds).

The JWS signedPayload is verified against the Apple certificate chain.
Entitlements are written only from provider-verified data: notifications
carrying signedTransactionInfo sync it (REFUND/REVOKE transactions carry
revocationDate -> status "free"); entitlement-loss types without
transaction info downgrade from the signed renewal info; billing-state
types (DID_FAIL_TO_RENEW, PRICE_INCREASE) and unknown types are acked
without touching the subscription.
Returns 500 on processing failure so Apple retries with backoff.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/cancel

Cancel subscription at the end of the current billing period.

The user will retain access until the period ends.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/checkout

Create a Stripe Checkout session for upgrading to Pro.

Returns a checkout URL to redirect the user to.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `cancel_url` | string | no | URL to redirect to if payment is cancelled |
| `plan_type` | `PlanType` | yes | Plan to subscribe to (plus_monthly, plus_yearly, pro_monthly or pro_yearly) |
| `success_url` | string | no | URL to redirect to after successful payment |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/subscription/google/notifications

Receive Google Play Real-time Developer Notifications (Pub/Sub push).

Verifies the OIDC bearer token (audience = GOOGLE_RTDN_AUDIENCE) and the
Pub/Sub envelope, then reconciles the subscription against the Play
Developer API. Returns 500 on processing failure so Pub/Sub retries.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/iap/transaction

Register a purchase made through Apple In-App Purchase or Play Billing.

The backend verifies the transaction with the store's server API before
granting any entitlement, so a spoofed client payload alone can never
upgrade an account.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `product_id` | string (nullable) | no | Store product ID the client intended to purchase |
| `store` | `StoreType` | yes | Billing store (apple or google) |
| `transaction_id` | string | yes | App Store transaction ID or Play purchase token |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/subscription/plans

Get available subscription plans and pricing.

Returns plan details for display on pricing pages. Each paid plan also
carries the store product IDs used by the mobile apps (null when the
store billing rail is not configured server-side).

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/portal

Create a Stripe Customer Portal session for managing subscription.

Allows users to update payment method, view invoices, and cancel subscription.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `return_url` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/subscription/usage

Get detailed monthly usage statistics.

Returns current usage vs limits for extractions, generations, and embeddings.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/subscription/webhook

Handle Stripe webhook events.

Events handled:
- checkout.session.completed: Activate subscription after payment
- customer.subscription.updated: Handle plan changes
- customer.subscription.deleted: Handle cancellation
- invoice.payment_failed: Mark subscription as past_due

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

## Referral

### GET /api/v1/referral/code

Get the current user's referral code.

Returns the user's unique referral code and a shareable URL.
If no code exists, one will be generated.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/referral/redeem

Redeem a referral code.

This applies referral credits to both the current user and the referrer.
Each user can only redeem one referral code.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `referral_code` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/referral/stats

Get detailed referral statistics.

Returns the user's referral code, times used, credits earned,
and a list of referred users.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### POST /api/v1/referral/validate

Validate a referral code without redeeming it.

This endpoint is public and can be used during signup
to verify a referral code before registration.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Promo

### POST /api/v1/promo/redeem

Redeem a promo code for the current user.

Grants the code's plan for free for its configured number of months
(one redemption per user; paid subscribers are never overwritten).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `promo_code` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/promo/validate

Validate a promo code without redeeming it.

Public endpoint: used by landing/register pages before signup to show the
visitor what the code grants. Never mutates state.

**Auth:** none (public endpoint)

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Feedback

### POST /api/v1/feedback

Submit feedback, bug report, or feature request.

Accepts both authenticated and anonymous submissions, so it is IP rate
limited. Supports up to 5 screenshot attachments (max 5MB each).

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`multipart/form-data`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `app_platform` | string (nullable) | no |  |
| `app_version` | string (nullable) | no |  |
| `attachments` | array<file (binary)> | no |  |
| `category` | `TicketCategory` | yes |  |
| `contact_email` | string (nullable) | no |  |
| `description` | string | yes |  |
| `device_info` | string (nullable) | no |  |
| `subject` | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/feedback/my-tickets

Get the current user's submitted tickets.

Requires authentication.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `limit` | query | integer | no |  |
| `offset` | query | integer | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Blog

### GET /api/v1/blog/admin/posts

List all blog posts including unpublished ones.

**Admin only.** Returns all blog posts with pagination.
Useful for content management.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | query | string (nullable) | no |  |
| `include_unpublished` | query | boolean | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `search` | query | string (nullable) | no |  |
| `status` | query | enum: published, draft, all (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/blog/categories

Get all unique categories from published blog posts.

Returns a sorted list of category names.

**Auth:** none (public endpoint)

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).

### GET /api/v1/blog/posts

List all published blog posts with pagination.

Returns paginated list of blog post summaries.
Supports filtering by category and searching by title/excerpt.

**Auth:** none (public endpoint)

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | query | string (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `search` | query | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/blog/posts

Create a new blog post.

**Admin only.** Creates a new blog post with the provided data.
Slug must be unique.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `author` | string | yes | Author name |
| `author_title` | string (nullable) | no | Author title/role |
| `category` | string | yes | Post category |
| `content` | string | yes | Full markdown content |
| `date` | string (date) | yes | Publication date |
| `emoji` | string | yes | Category emoji |
| `excerpt` | string | yes | Short summary for previews |
| `featured_image_url` | string (nullable) | no | Hero image URL |
| `is_published` | boolean | no | Whether post is publicly visible |
| `keywords` | array<string> | no | SEO keywords |
| `read_time` | string | yes | Estimated reading time |
| `slug` | string | yes | URL-friendly unique identifier |
| `title` | string | yes | Post title |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/blog/posts/{slug}

Get a single blog post by slug.

Returns the full blog post including content.
Only returns published posts for public access.

**Auth:** none (public endpoint)

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `slug` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PUT /api/v1/blog/posts/{slug}

Update an existing blog post.

**Admin only.** Updates the blog post identified by slug.
If slug is being changed, the new slug must be unique.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `slug` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `author` | string (nullable) | no |  |
| `author_title` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `content` | string (nullable) | no |  |
| `date` | string (date) (nullable) | no |  |
| `emoji` | string (nullable) | no |  |
| `excerpt` | string (nullable) | no |  |
| `featured_image_url` | string (nullable) | no |  |
| `is_published` | boolean (nullable) | no |  |
| `keywords` | array<string> (nullable) | no |  |
| `read_time` | string (nullable) | no |  |
| `slug` | string (nullable) | no |  |
| `title` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### DELETE /api/v1/blog/posts/{slug}

Delete a blog post.

**Admin only.** Permanently deletes the blog post identified by slug.
This action cannot be undone.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `slug` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Admin

### GET /api/v1/admin/audit

Paginated audit trail with filters + actor email join.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `action` | query | string (nullable) | no |  |
| `actor_id` | query | string (nullable) | no |  |
| `entity_id` | query | string (nullable) | no |  |
| `entity_type` | query | string (nullable) | no |  |
| `from` | query | string (date-time) (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `sort_dir` | query | enum: asc, desc | no |  |
| `to` | query | string (date-time) (nullable) | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminAuditEventItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminAuditEventItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/audit/entity/{entity_type}/{entity_id}

Full audit history for one entity (e.g. a user or subscription).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `entity_id` | path | string | yes |  |
| `entity_type` | path | string | yes |  |
| `limit` | query | integer | no |  |

**Responses:**

- **200** Returns array<`AdminAuditEventItem`>.
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/dashboards/overview

Signups / active users / paid subscriptions / AI jobs aggregates.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminOverviewResponse` — GET /admin/dashboards/overview.

| Field | Type | Required | Description |
|---|---|---|---|
| `active_users` | object<integer> | no |  |
| `ai_jobs_7d` | object | no |  |
| `paid_subscriptions` | integer | no |  |
| `signups` | object<integer> | no |  |


### GET /api/v1/admin/dashboards/referrals

Referral totals: codes issued, redemptions, credits granted/pending.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminReferralsResponse` — GET /admin/dashboards/referrals.

| Field | Type | Required | Description |
|---|---|---|---|
| `codes_issued` | integer | no |  |
| `credits_granted` | integer | no |  |
| `credits_pending` | integer | no |  |
| `redemptions` | integer | no |  |


### GET /api/v1/admin/dashboards/revenue

MRR estimate (Stripe vs IAP), paid/trial counts, churn events, refunds.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminRevenueResponse` — GET /admin/dashboards/revenue — MRR estimate + paid/trial + churn. ``mrr`` is ``{total, stripe, iap}`` in USD, an estimate derived from the configured plan prices (store rows do not carry amounts). ``churn_events_30d`` is ``{total, stripe, apple, google}`` lifecycle event counts (Stripe ``customer.subscription.deleted`` + store expiry/revoke notifications).

| Field | Type | Required | Description |
|---|---|---|---|
| `as_of` | object (nullable) | no |  |
| `churn_events_30d` | object<integer> | no |  |
| `mrr` | object<number> | no |  |
| `paid_subscriptions` | integer | no |  |
| `refunds_30d` | integer | no |  |
| `trial_subscriptions` | integer | no |  |


### GET /api/v1/admin/dashboards/top-users

Top-10 users by outfits, items and referrals.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminTopUsersResponse` — GET /admin/dashboards/top-users.

| Field | Type | Required | Description |
|---|---|---|---|
| `top_items` | array<object> | no |  |
| `top_outfits` | array<object> | no |  |
| `top_referrers` | array<object> | no |  |


### GET /api/v1/admin/dashboards/trends

Daily signups / AI jobs / paid / active series over the window.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `days` | query | integer | no | Window in days (7, 15, 30, or 90) |

**Responses:**

**Response 200:** Returns `AdminTrendsResponse` — GET /admin/dashboards/trends — daily series over a 30/90-day window. ``signups``/``active`` are ``[{day, count}]`` (zero-filled), ``jobs`` is ``[{day, total, succeeded, failed}]`` (zero-filled), and ``paid`` is ``[{day, provider, count}]`` with provider ``stripe`` or ``iap`` (zero-filled per day per provider).

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | array<object> | no |  |
| `days` | integer | no |  |
| `jobs` | array<object> | no |  |
| `paid` | array<object> | no |  |
| `signups` | array<object> | no |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/feedback

Paginated support tickets with filters (status, category, search).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `category` | query | string (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `q` | query | string (nullable) | no |  |
| `sort_dir` | query | string | no |  |
| `status` | query | string (nullable) | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminFeedbackListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminFeedbackListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### PATCH /api/v1/admin/feedback/{ticket_id}

Update a ticket's status and/or internal notes. Audit: feedback.updated.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `ticket_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `internal_notes` | string (nullable) | no |  |
| `status` | enum: open, in_progress, resolved, closed (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/iap/transactions

Paginated store transactions (Apple App Store / Google Play).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `platform` | query | enum: apple, google (nullable) | no |  |
| `sort_dir` | query | enum: asc, desc | no |  |
| `status` | query | string (nullable) | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminIapTransactionListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminIapTransactionListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/iap/transactions/{txn_id}

IAP transaction detail (looked up by any provider identifier).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `txn_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### POST /api/v1/admin/iap/transactions/{txn_id}/mark-refunded

Mark a store transaction refunded (status-only update + audit).

Store-side refunds arrive via webhooks; this endpoint only records the
refunded state for the admin UI.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `txn_id` | path | string | yes |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/me

Return the current admin's profile, role and granted permissions.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminMeResponse` — GET /admin/me — session bootstrap payload.

| Field | Type | Required | Description |
|---|---|---|---|
| `permissions` | array<string> | yes |  |
| `role` | string | yes |  |
| `user` | object | yes |  |


### GET /api/v1/admin/ops/health

Liveness (same shape as public /health) + schema readiness check.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminOpsHealthResponse` — GET /admin/ops/health — liveness (mirrors /health) + schema readiness.

| Field | Type | Required | Description |
|---|---|---|---|
| `commit` | string | yes |  |
| `rss_mb` | number (nullable) | no |  |
| `schema_ready` | boolean (nullable) | no |  |
| `service` | string | yes |  |
| `status` | string | yes |  |
| `version` | string | yes |  |


### GET /api/v1/admin/ops/storage

Bounded inventory of temp preview objects (``{user_id}/tmp/...``).

The scan is capped (see ``TEMP_SCAN_MAX_PAGES``); ``truncated`` is true
when the page cap cut the scan short. Only the first 100 items are
returned for display.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminStorageResponse` — GET /admin/ops/storage — temp object inventory (bounded scan).

| Field | Type | Required | Description |
|---|---|---|---|
| `bucket` | string | yes |  |
| `count` | integer | yes |  |
| `items` | array<`AdminStorageTempItem`> | no |  |
| `newest` | object (nullable) | no |  |
| `oldest` | object (nullable) | no |  |
| `scanned_keys` | integer | yes |  |
| `total_bytes` | integer | yes |  |
| `truncated` | boolean | no |  |


### DELETE /api/v1/admin/ops/storage/temp

Delete temp objects up to a per-call safety cap (5,000). Audit logged.

Deletes the oldest-first subset of the found temp keys, capped by
``TEMP_DELETE_MAX_OBJECTS``; ``truncated`` is true when more temp objects
remain (call again to continue).

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminStorageCleanupResponse` — DELETE /admin/ops/storage/temp.

| Field | Type | Required | Description |
|---|---|---|---|
| `bytes_freed` | integer | yes |  |
| `deleted` | integer | yes |  |
| `remaining` | integer | yes |  |
| `truncated` | boolean | no |  |


### GET /api/v1/admin/promo-codes

Paginated promo codes with redemption counts.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `active` | query | boolean (nullable) | no |  |
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `plan_type` | query | string (nullable) | no |  |
| `q` | query | string (nullable) | no |  |
| `sort_dir` | query | string | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_Dict_str__Any__`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<object> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/admin/promo-codes

Create a promo code (validates format + duplicates). Audit: promo.created.

**Auth:** required — `Authorization: Bearer <jwt>`

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | boolean | no |  |
| `code` | string | yes |  |
| `expires_at` | string (date-time) (nullable) | no |  |
| `max_uses` | integer (nullable) | no |  |
| `months` | integer | no |  |
| `plan_type` | enum: plus_monthly, plus_yearly, pro_monthly, pro_yearly | yes |  |

**Responses:**

- **201** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### PATCH /api/v1/admin/promo-codes/{code_id}

Activate/deactivate + edit-safe subset of a promo code. Audit: promo.updated.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `code_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | boolean (nullable) | no |  |
| `expires_at` | string (date-time) (nullable) | no |  |
| `max_uses` | integer (nullable) | no |  |
| `months` | integer (nullable) | no |  |
| `plan_type` | enum: plus_monthly, plus_yearly, pro_monthly, pro_yearly (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/quotas

Today's AI usage per user (daily counters from user_ai_settings).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `plan` | query | string (nullable) | no |  |
| `q` | query | string (nullable) | no |  |
| `sort_by` | query | enum: extraction, generation, embedding, user | no |  |
| `sort_dir` | query | enum: asc, desc | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminQuotaUsageItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminQuotaUsageItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/search

Search users, blog posts, support tickets and promo codes (top 5 each).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `q` | query | string | yes |  |

**Responses:**

**Response 200:** Returns `AdminSearchResponse` — GET /admin/search — top-5 hits per entity kind.

| Field | Type | Required | Description |
|---|---|---|---|
| `posts` | array<object> | no |  |
| `promo_codes` | array<object> | no |  |
| `tickets` | array<object> | no |  |
| `users` | array<object> | no |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/settings

Return safe deployment info: version, env, feature toggles, billing flags.

**Auth:** required — `Authorization: Bearer <jwt>`

**Responses:**

**Response 200:** Returns `AdminSettingsResponse` — GET /admin/settings — safe deployment info (no secrets).

| Field | Type | Required | Description |
|---|---|---|---|
| `app_name` | string | yes |  |
| `billing` | object<boolean> | no |  |
| `commit` | string | yes |  |
| `environment` | string | yes |  |
| `feature_toggles` | object<boolean> | no |  |
| `limits` | object | no |  |
| `storage` | object | no |  |
| `version` | string | yes |  |


### GET /api/v1/admin/subscriptions

Paginated subscriptions with user email and display amount.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `plan` | query | string (nullable) | no |  |
| `sort_by` | query | enum: created_at, current_period_start, plan_type, status | no |  |
| `sort_dir` | query | enum: asc, desc | no |  |
| `status` | query | string (nullable) | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminSubscriptionListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminSubscriptionListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/subscriptions/user/{user_id}

Full subscription detail incl. provider identifiers + current usage.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Responses:**

**Response 200:** Returns `AdminSubscriptionDetail` — GET /admin/subscriptions/user/{user_id}.

| Field | Type | Required | Description |
|---|---|---|---|
| `subscription` | object | yes |  |
| `usage` | object | no |  |
| `user` | object | no |  |

- **Errors:** 422 Unprocessable Entity

### POST /api/v1/admin/subscriptions/user/{user_id}/refund

Refund the user's latest Stripe charge (full refund).

Only Stripe-billed subscriptions carry a Stripe customer; store-billed
rows are rejected with a validation error. The refund is audit-logged.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Responses:**

**Response 200:** Returns `AdminRefundResponse` — POST /admin/subscriptions/user/{user_id}/refund.

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | integer | yes |  |
| `charge_id` | string (nullable) | no |  |
| `currency` | string | yes |  |
| `payment_intent` | string (nullable) | no |  |
| `refund_id` | string | yes |  |
| `status` | string | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/users

Paginated user list with subscription plan + outfits/items counts.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `page` | query | integer | no |  |
| `page_size` | query | integer | no |  |
| `plan` | query | string (nullable) | no |  |
| `q` | query | string (nullable) | no |  |
| `role` | query | string (nullable) | no |  |
| `sort_by` | query | enum: created_at, last_login_at, email, full_name | no |  |
| `sort_dir` | query | enum: asc, desc | no |  |
| `status` | query | enum: active, suspended (nullable) | no |  |

**Responses:**

**Response 200:** Returns `PageResponse_AdminUserListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminUserListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/users/{user_id}

Full user detail: profile + subscription + usage + counts + recent jobs.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Responses:**

**Response 200:** Returns `AdminUserDetail` — GET /admin/users/{user_id} — full profile detail.

| Field | Type | Required | Description |
|---|---|---|---|
| `counts` | object | no |  |
| `recent_jobs` | array<object> | no |  |
| `subscription` | object (nullable) | no |  |
| `usage` | object | no |  |
| `user` | object | yes |  |

- **Errors:** 422 Unprocessable Entity

### PATCH /api/v1/admin/users/{user_id}

Edit role / is_admin / is_active with self-demotion + last-admin guards.

Role changes and status changes are audit-logged per field.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `is_active` | boolean (nullable) | no |  |
| `is_admin` | boolean (nullable) | no |  |
| `role` | string (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

### GET /api/v1/admin/users/{user_id}/activity

Recent audit events + recent jobs for one user (limit 25 each).

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Responses:**

**Response 200:** Returns `AdminUserActivity` — GET /admin/users/{user_id}/activity.

| Field | Type | Required | Description |
|---|---|---|---|
| `audit_events` | array<object> | no |  |
| `recent_jobs` | array<object> | no |  |
| `user_id` | string | yes |  |

- **Errors:** 422 Unprocessable Entity

### PATCH /api/v1/admin/users/{user_id}/quota-override

Set (or clear with null) a per-user daily AI quota override.

The override lives on ``users.custom_daily_quota`` (migration 037);
null restores the plan default. Audit: ``quota.override``.

**Auth:** required — `Authorization: Bearer <jwt>`

**Parameters:**

| Parameter | In | Type | Required | Description |
|-----------|----|------|----------|-------------|
| `user_id` | path | string | yes |  |

**Request body** (`application/json`, required):

| Field | Type | Required | Description |
|---|---|---|---|
| `daily_limit` | integer (nullable) | no |  |

**Responses:**

- **200** Arbitrary JSON object — routes wrap payloads in the `{data, message}` envelope (see [Response Format](#response-format)).
- **Errors:** 422 Unprocessable Entity

## Models

All request/response models from the OpenAPI `components.schemas`, sorted by name. Endpoint sections reference these by name; `Body_*` entries are the multipart/form-data request shapes (file fields are `file (binary)`).

### `AISettingsUpdate`

Request to update AI settings.

| Field | Type | Required | Description |
|---|---|---|---|
| `default_provider` | string (nullable) | no |  |
| `provider_configs` | object<`ProviderConfigInput`> (nullable) | no |  |

### `AddCollectionOutfitRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_id` | string | yes |  |

### `AddItemToOutfitRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `item_id` | string | yes |  |
| `position` | string (nullable) | no |  |

### `AdminAuditEventItem`

One row of GET /admin/audit.

| Field | Type | Required | Description |
|---|---|---|---|
| `action` | string | yes |  |
| `actor` | object (nullable) | no |  |
| `actor_id` | string (nullable) | no |  |
| `created_at` | object (nullable) | no |  |
| `entity_id` | string (nullable) | no |  |
| `entity_type` | string | yes |  |
| `id` | string | yes |  |
| `ip` | string (nullable) | no |  |
| `payload` | object | no |  |
| `user_agent` | string (nullable) | no |  |

### `AdminFeedbackListItem`

One row of GET /admin/feedback (support tickets).

| Field | Type | Required | Description |
|---|---|---|---|
| `app_platform` | string (nullable) | no |  |
| `app_version` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `contact_email` | string (nullable) | no |  |
| `created_at` | object (nullable) | no |  |
| `description` | string (nullable) | no |  |
| `id` | string | yes |  |
| `internal_notes` | string (nullable) | no |  |
| `status` | string (nullable) | no |  |
| `subject` | string (nullable) | no |  |
| `updated_at` | object (nullable) | no |  |
| `user` | object (nullable) | no |  |
| `user_id` | string (nullable) | no |  |

### `AdminFeedbackUpdate`

PATCH /admin/feedback/{ticket_id} body.

| Field | Type | Required | Description |
|---|---|---|---|
| `internal_notes` | string (nullable) | no |  |
| `status` | enum: open, in_progress, resolved, closed (nullable) | no |  |

### `AdminIapTransactionListItem`

One row of GET /admin/iap/transactions (store-billed subscriptions).

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | number (nullable) | no |  |
| `billing_product_id` | string (nullable) | no |  |
| `created_at` | object (nullable) | no |  |
| `plan_type` | string (nullable) | no |  |
| `platform` | string (nullable) | no |  |
| `status` | string (nullable) | no |  |
| `subscription_id` | string | yes |  |
| `transaction_id` | string (nullable) | no |  |
| `user_email` | string (nullable) | no |  |
| `user_id` | string | yes |  |

### `AdminMeResponse`

GET /admin/me — session bootstrap payload.

| Field | Type | Required | Description |
|---|---|---|---|
| `permissions` | array<string> | yes |  |
| `role` | string | yes |  |
| `user` | object | yes |  |

### `AdminOpsHealthResponse`

GET /admin/ops/health — liveness (mirrors /health) + schema readiness.

| Field | Type | Required | Description |
|---|---|---|---|
| `commit` | string | yes |  |
| `rss_mb` | number (nullable) | no |  |
| `schema_ready` | boolean (nullable) | no |  |
| `service` | string | yes |  |
| `status` | string | yes |  |
| `version` | string | yes |  |

### `AdminOverviewResponse`

GET /admin/dashboards/overview.

| Field | Type | Required | Description |
|---|---|---|---|
| `active_users` | object<integer> | no |  |
| `ai_jobs_7d` | object | no |  |
| `paid_subscriptions` | integer | no |  |
| `signups` | object<integer> | no |  |

### `AdminPromoCodeCreate`

POST /admin/promo-codes body (mirrors migration 031 constraints).

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | boolean | no |  |
| `code` | string | yes |  |
| `expires_at` | string (date-time) (nullable) | no |  |
| `max_uses` | integer (nullable) | no |  |
| `months` | integer | no |  |
| `plan_type` | enum: plus_monthly, plus_yearly, pro_monthly, pro_yearly | yes |  |

### `AdminPromoCodeUpdate`

PATCH /admin/promo-codes/{code_id} body — edit-safe subset.

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | boolean (nullable) | no |  |
| `expires_at` | string (date-time) (nullable) | no |  |
| `max_uses` | integer (nullable) | no |  |
| `months` | integer (nullable) | no |  |
| `plan_type` | enum: plus_monthly, plus_yearly, pro_monthly, pro_yearly (nullable) | no |  |

### `AdminQuotaOverride`

PATCH /admin/users/{user_id}/quota-override body. ``daily_limit`` = new per-user daily AI limit; pass null to clear the override and fall back to the plan default.

| Field | Type | Required | Description |
|---|---|---|---|
| `daily_limit` | integer (nullable) | no |  |

### `AdminQuotaUsageItem`

One row of GET /admin/quotas (today's per-user AI usage).

| Field | Type | Required | Description |
|---|---|---|---|
| `custom_daily_quota` | integer (nullable) | no |  |
| `daily_embedding_count` | integer (nullable) | no |  |
| `daily_extraction_count` | integer (nullable) | no |  |
| `daily_generation_count` | integer (nullable) | no |  |
| `daily_photoshoot_images` | integer (nullable) | no |  |
| `email` | string (nullable) | no |  |
| `full_name` | string (nullable) | no |  |
| `last_reset_date` | object (nullable) | no |  |
| `plan_type` | string (nullable) | no |  |
| `user_id` | string | yes |  |

### `AdminReferralsResponse`

GET /admin/dashboards/referrals.

| Field | Type | Required | Description |
|---|---|---|---|
| `codes_issued` | integer | no |  |
| `credits_granted` | integer | no |  |
| `credits_pending` | integer | no |  |
| `redemptions` | integer | no |  |

### `AdminRefundResponse`

POST /admin/subscriptions/user/{user_id}/refund.

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | integer | yes |  |
| `charge_id` | string (nullable) | no |  |
| `currency` | string | yes |  |
| `payment_intent` | string (nullable) | no |  |
| `refund_id` | string | yes |  |
| `status` | string | yes |  |

### `AdminRevenueResponse`

GET /admin/dashboards/revenue — MRR estimate + paid/trial + churn. ``mrr`` is ``{total, stripe, iap}`` in USD, an estimate derived from the configured plan prices (store rows do not carry amounts). ``churn_events_30d`` is ``{total, stripe, apple, google}`` lifecycle event counts (Stripe ``customer.subscription.deleted`` + store expiry/revoke notifications).

| Field | Type | Required | Description |
|---|---|---|---|
| `as_of` | object (nullable) | no |  |
| `churn_events_30d` | object<integer> | no |  |
| `mrr` | object<number> | no |  |
| `paid_subscriptions` | integer | no |  |
| `refunds_30d` | integer | no |  |
| `trial_subscriptions` | integer | no |  |

### `AdminSearchResponse`

GET /admin/search — top-5 hits per entity kind.

| Field | Type | Required | Description |
|---|---|---|---|
| `posts` | array<object> | no |  |
| `promo_codes` | array<object> | no |  |
| `tickets` | array<object> | no |  |
| `users` | array<object> | no |  |

### `AdminSettingsResponse`

GET /admin/settings — safe deployment info (no secrets).

| Field | Type | Required | Description |
|---|---|---|---|
| `app_name` | string | yes |  |
| `billing` | object<boolean> | no |  |
| `commit` | string | yes |  |
| `environment` | string | yes |  |
| `feature_toggles` | object<boolean> | no |  |
| `limits` | object | no |  |
| `storage` | object | no |  |
| `version` | string | yes |  |

### `AdminStorageCleanupResponse`

DELETE /admin/ops/storage/temp.

| Field | Type | Required | Description |
|---|---|---|---|
| `bytes_freed` | integer | yes |  |
| `deleted` | integer | yes |  |
| `remaining` | integer | yes |  |
| `truncated` | boolean | no |  |

### `AdminStorageResponse`

GET /admin/ops/storage — temp object inventory (bounded scan).

| Field | Type | Required | Description |
|---|---|---|---|
| `bucket` | string | yes |  |
| `count` | integer | yes |  |
| `items` | array<`AdminStorageTempItem`> | no |  |
| `newest` | object (nullable) | no |  |
| `oldest` | object (nullable) | no |  |
| `scanned_keys` | integer | yes |  |
| `total_bytes` | integer | yes |  |
| `truncated` | boolean | no |  |

### `AdminStorageTempItem`

One temp object summary.

| Field | Type | Required | Description |
|---|---|---|---|
| `key` | string | yes |  |
| `last_modified` | object (nullable) | no |  |
| `size` | integer | no |  |

### `AdminSubscriptionDetail`

GET /admin/subscriptions/user/{user_id}.

| Field | Type | Required | Description |
|---|---|---|---|
| `subscription` | object | yes |  |
| `usage` | object | no |  |
| `user` | object | no |  |

### `AdminSubscriptionListItem`

One row of GET /admin/subscriptions.

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | number (nullable) | no |  |
| `billing_provider` | string (nullable) | no |  |
| `cancel_at_period_end` | boolean (nullable) | no |  |
| `created_at` | object (nullable) | no |  |
| `current_period_end` | object (nullable) | no |  |
| `current_period_start` | object (nullable) | no |  |
| `id` | string | yes |  |
| `plan_type` | string (nullable) | no |  |
| `referral_credit_months` | integer (nullable) | no |  |
| `status` | string (nullable) | no |  |
| `trial_end` | object (nullable) | no |  |
| `updated_at` | object (nullable) | no |  |
| `user` | object (nullable) | no |  |
| `user_id` | string | yes |  |

### `AdminTopUsersResponse`

GET /admin/dashboards/top-users.

| Field | Type | Required | Description |
|---|---|---|---|
| `top_items` | array<object> | no |  |
| `top_outfits` | array<object> | no |  |
| `top_referrers` | array<object> | no |  |

### `AdminTrendsResponse`

GET /admin/dashboards/trends — daily series over a 30/90-day window. ``signups``/``active`` are ``[{day, count}]`` (zero-filled), ``jobs`` is ``[{day, total, succeeded, failed}]`` (zero-filled), and ``paid`` is ``[{day, provider, count}]`` with provider ``stripe`` or ``iap`` (zero-filled per day per provider).

| Field | Type | Required | Description |
|---|---|---|---|
| `active` | array<object> | no |  |
| `days` | integer | no |  |
| `jobs` | array<object> | no |  |
| `paid` | array<object> | no |  |
| `signups` | array<object> | no |  |

### `AdminUserActivity`

GET /admin/users/{user_id}/activity.

| Field | Type | Required | Description |
|---|---|---|---|
| `audit_events` | array<object> | no |  |
| `recent_jobs` | array<object> | no |  |
| `user_id` | string | yes |  |

### `AdminUserDetail`

GET /admin/users/{user_id} — full profile detail.

| Field | Type | Required | Description |
|---|---|---|---|
| `counts` | object | no |  |
| `recent_jobs` | array<object> | no |  |
| `subscription` | object (nullable) | no |  |
| `usage` | object | no |  |
| `user` | object | yes |  |

### `AdminUserListItem`

One row of GET /admin/users.

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_url` | string (nullable) | no |  |
| `created_at` | object (nullable) | no |  |
| `custom_daily_quota` | integer (nullable) | no |  |
| `email` | string (nullable) | no |  |
| `email_verified` | boolean (nullable) | no |  |
| `full_name` | string (nullable) | no |  |
| `id` | string | yes |  |
| `is_active` | boolean (nullable) | no |  |
| `is_admin` | boolean (nullable) | no |  |
| `items_count` | integer (nullable) | no |  |
| `last_login_at` | object (nullable) | no |  |
| `outfits_count` | integer (nullable) | no |  |
| `role` | string (nullable) | no |  |
| `subscription` | object (nullable) | no |  |
| `updated_at` | object (nullable) | no |  |

### `AdminUserPatch`

PATCH /admin/users/{user_id} body. ``role`` must be one of the admin roles or ``user``; ``is_admin`` and ``is_active`` are the legacy flag / suspension toggle. All fields optional; at least one must be present.

| Field | Type | Required | Description |
|---|---|---|---|
| `is_active` | boolean (nullable) | no |  |
| `is_admin` | boolean (nullable) | no |  |
| `role` | string (nullable) | no |  |

### `AssignOutfitRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_id` | string | yes |  |

### `BatchDeleteItemsRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `item_ids` | array<string> | no |  |

### `BatchDeleteOutfitsRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_ids` | array<string> | no |  |

### `BatchEmbeddingRequest`

Request to generate batch embeddings.

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string (nullable) | no |  |
| `texts` | array<string> | yes | List of texts to generate embeddings for |

### `BatchExtractionRequest`

Request to start batch extraction (JSON / Flutter).

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no | Automatically start generation after extraction |
| `generation_batch_size` | integer | no | Max concurrent product-image generations for this job (1-30). The process-wide GENERATION_SEMAPHORE (same cap) is the hard ceiling regardless. Capped at 50 to match the DB CHECK valid_batch_size. |
| `images` | array<`BatchImageInput`> | yes | List of images to process (max 50) |

### `BatchImageInput`

Single image for batch processing.

| Field | Type | Required | Description |
|---|---|---|---|
| `filename` | string (nullable) | no | Original filename |
| `image_base64` | string | yes | Base64-encoded image data (max ~10MB encoded) |
| `image_id` | string | yes | Client-generated unique ID for tracking |

### `BatchJobResponse`

Response with job information.

| Field | Type | Required | Description |
|---|---|---|---|
| `job_id` | string | yes |  |
| `message` | string | yes |  |
| `sse_url` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |

### `BatchJobStatusResponse`

Full job status response.

| Field | Type | Required | Description |
|---|---|---|---|
| `error` | string (nullable) | no |  |
| `extractions_completed` | integer | yes |  |
| `extractions_failed` | integer | yes |  |
| `generations_completed` | integer | yes |  |
| `generations_failed` | integer | yes |  |
| `items` | array<object> | yes |  |
| `job_id` | string | yes |  |
| `status` | string | yes |  |
| `total_images` | integer | yes |  |
| `total_items` | integer | yes |  |

### `BlogPostCreate`

Model for creating a new blog post.

| Field | Type | Required | Description |
|---|---|---|---|
| `author` | string | yes | Author name |
| `author_title` | string (nullable) | no | Author title/role |
| `category` | string | yes | Post category |
| `content` | string | yes | Full markdown content |
| `date` | string (date) | yes | Publication date |
| `emoji` | string | yes | Category emoji |
| `excerpt` | string | yes | Short summary for previews |
| `featured_image_url` | string (nullable) | no | Hero image URL |
| `is_published` | boolean | no | Whether post is publicly visible |
| `keywords` | array<string> | no | SEO keywords |
| `read_time` | string | yes | Estimated reading time |
| `slug` | string | yes | URL-friendly unique identifier |
| `title` | string | yes | Post title |

### `BlogPostUpdate`

Model for updating an existing blog post. All fields are optional.

| Field | Type | Required | Description |
|---|---|---|---|
| `author` | string (nullable) | no |  |
| `author_title` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `content` | string (nullable) | no |  |
| `date` | string (date) (nullable) | no |  |
| `emoji` | string (nullable) | no |  |
| `excerpt` | string (nullable) | no |  |
| `featured_image_url` | string (nullable) | no |  |
| `is_published` | boolean (nullable) | no |  |
| `keywords` | array<string> (nullable) | no |  |
| `read_time` | string (nullable) | no |  |
| `slug` | string (nullable) | no |  |
| `title` | string (nullable) | no |  |

### `BodyProfileCreate`

Model for creating a body profile.

| Field | Type | Required | Description |
|---|---|---|---|
| `body_shape` | string | yes |  |
| `height_cm` | number | yes |  |
| `is_default` | boolean | no |  |
| `name` | string | yes |  |
| `skin_tone` | string | yes |  |
| `weight_kg` | number | yes |  |

### `BodyProfileUpdate`

Model for updating body profile (all fields optional).

| Field | Type | Required | Description |
|---|---|---|---|
| `body_shape` | string (nullable) | no |  |
| `height_cm` | number (nullable) | no |  |
| `is_default` | boolean (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `skin_tone` | string (nullable) | no |  |
| `weight_kg` | number (nullable) | no |  |

### `Body_start_batch_extraction_multipart_api_v1_ai_batch_extract_multipart_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no |  |
| `files` | array<file (binary)> | yes | Image files (1–50) |
| `generation_batch_size` | integer | no |  |
| `image_ids` | string (nullable) | no | Optional JSON array of client image IDs, parallel to files |

### `Body_submit_feedback_api_v1_feedback_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `app_platform` | string (nullable) | no |  |
| `app_version` | string (nullable) | no |  |
| `attachments` | array<file (binary)> | no |  |
| `category` | `TicketCategory` | yes |  |
| `contact_email` | string (nullable) | no |  |
| `description` | string | yes |  |
| `device_info` | string (nullable) | no |  |
| `subject` | string | yes |  |

### `Body_upload_avatar_api_v1_users_me_avatar_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | file (binary) | yes |  |

### `Body_upload_item_image_api_v1_items__item_id__images_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | file (binary) | yes |  |
| `is_primary` | boolean | no |  |

### `Body_upload_item_images_api_v1_items_upload_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `files` | array<file (binary)> | yes |  |

### `Body_upload_outfit_image_api_v1_outfits__outfit_id__images_post`

| Field | Type | Required | Description |
|---|---|---|---|
| `body_profile_id` | string (nullable) | no |  |
| `file` | file (binary) | yes |  |
| `generation_id` | string (nullable) | no |  |
| `is_primary` | boolean | no |  |
| `lighting` | string (nullable) | no |  |
| `pose` | string | no |  |

### `CalendarConnectRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `auth_code` | string (nullable) | no | OAuth auth code (if applicable) |
| `provider` | string | yes | google\|apple\|outlook\|local |

### `CompleteLookRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `item_ids` | array<string> (nullable) | no |  |
| `limit` | integer (nullable) | no |  |
| `occasion` | string (nullable) | no |  |
| `start_item_id` | string (nullable) | no |  |
| `weather_condition` | string (nullable) | no |  |

### `ConfirmResetRequest`

Password reset confirmation.

| Field | Type | Required | Description |
|---|---|---|---|
| `access_token` | string (nullable) | no |  |
| `new_password` | string | yes |  |
| `refresh_token` | string (nullable) | no |  |
| `token` | string (nullable) | no |  |

### `CreateCheckoutRequest`

Request to create a Stripe checkout session.

| Field | Type | Required | Description |
|---|---|---|---|
| `cancel_url` | string | no | URL to redirect to if payment is cancelled |
| `plan_type` | `PlanType` | yes | Plan to subscribe to (plus_monthly, plus_yearly, pro_monthly or pro_yearly) |
| `success_url` | string | no | URL to redirect to after successful payment |

### `CreateEventRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `calendar_id` | string (nullable) | no |  |
| `description` | string (nullable) | no |  |
| `end_time` | string | yes |  |
| `event_type` | string | no |  |
| `is_all_day` | boolean | no |  |
| `location` | string (nullable) | no |  |
| `outfit_id` | string (nullable) | no |  |
| `start_time` | string | yes |  |
| `title` | string | yes |  |

### `DataResponse_OutfitListResponse_`

| Field | Type | Required | Description |
|---|---|---|---|
| `data` | `OutfitListResponse` | yes |  |
| `message` | string | no |  |

### `DataResponse_OutfitResponse_`

| Field | Type | Required | Description |
|---|---|---|---|
| `data` | `OutfitResponse` | yes |  |
| `message` | string | no |  |

### `DemoExtractItemsRequest`

Request to extract items from image (demo mode).

| Field | Type | Required | Description |
|---|---|---|---|
| `image` | string | yes | Base64-encoded image data |

### `DemoPhotoshootRequest`

Request for demo photoshoot (anonymous, limited to 2 images).

| Field | Type | Required | Description |
|---|---|---|---|
| `photo` | string | yes | Base64-encoded reference photo (max 10MB) |
| `use_case` | `PhotoshootUseCase` | no | The use case for the photoshoot (no custom allowed) |

### `DemoTryOnRequest`

Request for virtual try-on (demo mode).

| Field | Type | Required | Description |
|---|---|---|---|
| `clothing_description` | string (nullable) | no | Optional description of the clothing |
| `clothing_image` | string | yes | Base64-encoded clothing photo |
| `person_image` | string | yes | Base64-encoded person photo |
| `style` | string | no | Overall style (casual, formal, etc.) |

### `DuplicateCheckRequest`

Request body for duplicate check.

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `material` | string (nullable) | no |  |
| `name` | string | yes |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

### `EmbeddingRequest`

Request to generate a single embedding.

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string (nullable) | no |  |
| `text` | string | yes | Text to generate embedding for |

### `ExtractItemsRequest`

Request to extract items from an image (inline or stored).

| Field | Type | Required | Description |
|---|---|---|---|
| `image` | string (nullable) | no | Legacy base64-encoded image data |
| `storage_path` | string (nullable) | no | Owned storage key for the image |

### `ExtractSingleItemRequest`

Request to extract a single item from an image (inline or stored).

| Field | Type | Required | Description |
|---|---|---|---|
| `category_hint` | string (nullable) | no |  |
| `image` | string (nullable) | no | Legacy base64-encoded image data |
| `storage_path` | string (nullable) | no | Owned storage key for the image |

### `GenerateOutfitRequest`

Request to generate an outfit visualization.

| Field | Type | Required | Description |
|---|---|---|---|
| `background` | string | no |  |
| `custom_prompt` | string (nullable) | no |  |
| `include_model` | boolean | no |  |
| `include_user_face` | boolean | no |  |
| `items` | array<`OutfitItemInput`> | yes |  |
| `lighting` | string | no |  |
| `model_gender` | string | no |  |
| `pose` | string | no |  |
| `save_to_storage` | boolean | no |  |
| `style` | string | no |  |
| `use_body_profile` | boolean | no |  |
| `use_source_photo` | boolean | no |  |
| `view_angle` | string | no |  |

### `GenerateProductImageRequest`

Request to generate a product image.

| Field | Type | Required | Description |
|---|---|---|---|
| `background` | string | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `include_shadows` | boolean | no |  |
| `item_description` | string | yes |  |
| `material` | string (nullable) | no |  |
| `reference_image` | string (nullable) | no | Optional legacy base64 source photo |
| `reference_storage_path` | string (nullable) | no | Owned source photo storage key |
| `save_to_storage` | boolean | no |  |
| `sub_category` | string (nullable) | no |  |
| `view_angle` | string | no |  |

### `GenerationRequest`

Request model for AI outfit image generation.

| Field | Type | Required | Description |
|---|---|---|---|
| `body_profile_id` | string (uuid) (nullable) | no |  |
| `lighting` | string (nullable) | no |  |
| `pose` | string | no |  |
| `variations` | integer | no |  |

### `HTTPValidationError`

| Field | Type | Required | Description |
|---|---|---|---|
| `detail` | array<`ValidationError`> | no |  |

### `ItemCreate`

Model for creating a new item.

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string | yes |  |
| `colors` | array<string> | no |  |
| `condition` | string | no |  |
| `images` | array<`ItemImageBase`> | no |  |
| `is_favorite` | boolean | no |  |
| `material` | string (nullable) | no |  |
| `materials` | array<string> | no |  |
| `name` | string | yes |  |
| `notes` | string (nullable) | no |  |
| `occasion_tags` | array<string> | no |  |
| `pattern` | string (nullable) | no |  |
| `price` | number (nullable) | no |  |
| `purchase_date` | string (date-time) (nullable) | no |  |
| `purchase_location` | string (nullable) | no |  |
| `seasonal_tags` | array<string> | no |  |
| `size` | string (nullable) | no |  |
| `source_image_storage_path` | string (nullable) | no |  |
| `source_image_url` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

### `ItemImageBase`

Base model for item images.

| Field | Type | Required | Description |
|---|---|---|---|
| `height` | integer (nullable) | no |  |
| `image_url` | string | yes |  |
| `is_primary` | boolean | no |  |
| `storage_path` | string (nullable) | no |  |
| `thumbnail_url` | string (nullable) | no |  |
| `width` | integer (nullable) | no |  |

### `ItemUpdate`

Model for updating an item (all fields optional).

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `condition` | string (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `material` | string (nullable) | no |  |
| `materials` | array<string> (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `notes` | string (nullable) | no |  |
| `occasion_tags` | array<string> (nullable) | no |  |
| `pattern` | string (nullable) | no |  |
| `price` | number (nullable) | no |  |
| `purchase_date` | string (date-time) (nullable) | no |  |
| `purchase_location` | string (nullable) | no |  |
| `seasonal_tags` | array<string> (nullable) | no |  |
| `size` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |
| `tags` | array<string> (nullable) | no |  |

### `LoginRequest`

User login request.

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `password` | string | yes |  |

### `LogoutRequest`

Optional logout body. ``refresh_token`` is accepted for API compatibility: the actual server-side revocation happens through Supabase /auth/v1/logout, which the backend calls with the request's Bearer access token and which revokes that session's refresh token. A stateless client has no stored Supabase session to sign out from, so the token alone cannot revoke anything.

| Field | Type | Required | Description |
|---|---|---|---|
| `refresh_token` | string (nullable) | no |  |

### `MatchRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `item_id` | string (nullable) | no |  |
| `item_ids` | array<string> (nullable) | no |  |
| `limit` | integer (nullable) | no |  |
| `match_type` | string | no |  |

### `OAuthSyncRequest`

Optional metadata from OAuth provider for profile sync.

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_url` | string (nullable) | no |  |
| `full_name` | string (nullable) | no |  |
| `referral_code` | string (nullable) | no |  |

### `OutfitCollectionCreate`

Model for creating a collection.

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_favorite` | boolean | no |  |
| `name` | string | yes |  |
| `outfit_ids` | array<string (uuid)> | no |  |

### `OutfitCollectionUpdate`

Model for updating a collection.

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `outfit_ids` | array<string (uuid)> (nullable) | no |  |

### `OutfitCreate`

Model for creating a new outfit.

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_draft` | boolean | no |  |
| `is_favorite` | boolean | no |  |
| `is_public` | boolean | no |  |
| `item_ids` | array<string (uuid)> | no |  |
| `name` | string | yes |  |
| `occasion` | string (nullable) | no |  |
| `season` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `tags` | array<string> | no |  |

### `OutfitImage`

Complete outfit image model.

| Field | Type | Required | Description |
|---|---|---|---|
| `body_profile_id` | string (uuid) (nullable) | no |  |
| `created_at` | string (date-time) | yes |  |
| `generation_metadata` | object (nullable) | no |  |
| `generation_type` | string (nullable) | no |  |
| `height` | integer (nullable) | no |  |
| `id` | string (uuid) | yes |  |
| `image_url` | string | yes |  |
| `is_primary` | boolean (nullable) | no |  |
| `lighting` | string (nullable) | no |  |
| `outfit_id` | string (uuid) | yes |  |
| `pose` | string | yes |  |
| `storage_path` | string (nullable) | no |  |
| `thumbnail_url` | string (nullable) | no |  |
| `width` | integer (nullable) | no |  |

### `OutfitItemInput`

Input item for outfit generation. `item_id` is the caller's own wardrobe item. When present, the backend resolves that item's stored image server-side (scoped to the caller) and sends it to the image model as a labelled garment reference, so the generated outfit reproduces the real garment instead of inventing a lookalike from the text attributes below. Absent — or an item with no stored image — d

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `colors` | array<string> | no |  |
| `item_id` | string (uuid) (nullable) | no |  |
| `material` | string (nullable) | no |  |
| `name` | string | yes |  |
| `pattern` | string (nullable) | no |  |

### `OutfitListResponse`

Model for paginated outfit list response.

| Field | Type | Required | Description |
|---|---|---|---|
| `has_next` | boolean | no |  |
| `has_prev` | boolean | no |  |
| `outfits` | array<`OutfitResponse`> | yes |  |
| `page` | integer | yes |  |
| `total` | integer | yes |  |
| `total_pages` | integer | yes |  |

### `OutfitResponse`

Model for outfit response with all fields. `items` is included here (not only on a separate "detail" variant) since the Flutter client uses a single OutfitModel for both list and detail views (outfit_model.dart declares `items` directly) and both list_outfits and get_outfit already attach an items array to every outfit object.

| Field | Type | Required | Description |
|---|---|---|---|
| `created_at` | string (date-time) | yes |  |
| `description` | string (nullable) | no |  |
| `id` | string (uuid) | yes |  |
| `images` | array<`OutfitImage`> | no |  |
| `is_draft` | boolean | no |  |
| `is_favorite` | boolean | no |  |
| `is_public` | boolean | no |  |
| `item_ids` | array<string (uuid)> | no |  |
| `items` | array<object> (nullable) | no |  |
| `last_worn_at` | string (date-time) (nullable) | no |  |
| `name` | string | yes |  |
| `occasion` | string (nullable) | no |  |
| `season` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `tags` | array<string> | no |  |
| `updated_at` | string (date-time) | yes |  |
| `user_id` | string (uuid) | yes |  |
| `worn_count` | integer | no |  |

### `OutfitUpdate`

Model for updating an outfit (all fields optional).

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `is_draft` | boolean (nullable) | no |  |
| `is_favorite` | boolean (nullable) | no |  |
| `is_public` | boolean (nullable) | no |  |
| `item_ids` | array<string (uuid)> (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `occasion` | string (nullable) | no |  |
| `season` | string (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `tags` | array<string> (nullable) | no |  |

### `PageResponse_AdminAuditEventItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminAuditEventItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_AdminFeedbackListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminFeedbackListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_AdminIapTransactionListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminIapTransactionListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_AdminQuotaUsageItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminQuotaUsageItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_AdminSubscriptionListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminSubscriptionListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_AdminUserListItem_`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<`AdminUserListItem`> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PageResponse_Dict_str__Any__`

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | array<object> | yes |  |
| `page` | integer | yes |  |
| `page_size` | integer | yes |  |
| `total` | integer | yes |  |

### `PhotoshootUseCase`

Predefined use cases for photoshoot generation.

### `PlanType`

Subscription plan types.

### `ProviderConfigInput`

Configuration for a single provider.

| Field | Type | Required | Description |
|---|---|---|---|
| `api_key` | string (nullable) | no |  |
| `api_url` | string (nullable) | no |  |
| `image_gen_model` | string (nullable) | no |  |
| `model` | string (nullable) | no |  |
| `vision_fallback_model` | string (nullable) | no |  |
| `vision_model` | string (nullable) | no |  |

### `RateRecommendationRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `rating` | string | yes | thumbs_up\|thumbs_down\|neutral |

### `RedeemPromoRequest`

Request to redeem a promo code.

| Field | Type | Required | Description |
|---|---|---|---|
| `promo_code` | string | yes |  |

### `RedeemReferralRequest`

Request to redeem a referral code.

| Field | Type | Required | Description |
|---|---|---|---|
| `referral_code` | string | yes |  |

### `RefreshTokenRequest`

Token refresh request.

| Field | Type | Required | Description |
|---|---|---|---|
| `refresh_token` | string | yes |  |

### `RegisterIapTransactionRequest`

Request to register a store-verified purchase.

| Field | Type | Required | Description |
|---|---|---|---|
| `product_id` | string (nullable) | no | Store product ID the client intended to purchase |
| `store` | `StoreType` | yes | Billing store (apple or google) |
| `transaction_id` | string | yes | App Store transaction ID or Play purchase token |

### `RegisterRequest`

User registration request.

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `full_name` | string (nullable) | no |  |
| `password` | string | yes |  |
| `referral_code` | string (nullable) | no |  |

### `ResetPasswordRequest`

Password reset request.

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |

### `ShareFeedbackRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `comment` | string (nullable) | no |  |
| `rating` | integer | yes |  |

### `ShareOutfitRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `allow_feedback` | boolean | no |  |
| `custom_caption` | string (nullable) | no |  |
| `expires_at` | string (nullable) | no | ISO8601 datetime (optional) |
| `visibility` | string | no | public\|friends\|private |

### `SimilaritySearchRequest`

Request to search for similar items.

| Field | Type | Required | Description |
|---|---|---|---|
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `embedding` | array<number> (nullable) | no |  |
| `min_score` | number | no |  |
| `text` | string (nullable) | no |  |
| `top_k` | integer | no |  |

### `SingleExtractionRequest`

Request to start single-item extraction.

| Field | Type | Required | Description |
|---|---|---|---|
| `auto_generate` | boolean | no | Auto-generate product images |
| `image` | string | yes | Base64-encoded image (max ~10MB encoded) |
| `skip_cache` | boolean | no | Skip cache lookup (force fresh extraction) |

### `SocialImportItemPatchRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string (nullable) | no |  |
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `detailed_description` | string (nullable) | no |  |
| `material` | string (nullable) | no |  |
| `name` | string (nullable) | no |  |
| `pattern` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |

### `SocialImportOAuthAuthRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `expires_at` | string (date-time) (nullable) | no |  |
| `provider_access_token` | string | yes |  |
| `provider_page_access_token` | string (nullable) | no |  |
| `provider_page_id` | string (nullable) | no |  |
| `provider_refresh_token` | string (nullable) | no |  |
| `provider_user_id` | string (nullable) | no |  |
| `provider_username` | string (nullable) | no |  |

### `SocialImportScraperAuthRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `otp_code` | string (nullable) | no |  |
| `password` | string | yes |  |
| `two_factor_identifier` | string (nullable) | no |  |
| `username` | string | yes |  |

### `SocialImportStartRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `source_url` | string | yes |  |

### `StartPhotoshootRequest`

Request to start a photoshoot generation session.

| Field | Type | Required | Description |
|---|---|---|---|
| `aspect_ratio` | string | no | Aspect ratio for generated images: 1:1, 9:16, 16:9, 3:4, 4:3 |
| `batch_size` | integer | no | Number of images per batch for SSE progress updates |
| `custom_prompt` | string (nullable) | no | Custom prompt for 'custom' use case |
| `num_images` | integer | no | Number of images to generate (1-10) |
| `photos` | array<string> | yes | Base64-encoded reference photos (1-4, max 10MB each) |
| `use_case` | `PhotoshootUseCase` | yes | The use case for the photoshoot |

### `StoreType`

Billing store for mobile in-app purchases.

### `TestEmbeddingRequest`

Request to test embedding model.

| Field | Type | Required | Description |
|---|---|---|---|
| `model` | string | yes |  |
| `provider` | string | yes |  |

### `TestProviderRequest`

Request to test a provider configuration.

| Field | Type | Required | Description |
|---|---|---|---|
| `api_key` | string | yes |  |
| `api_url` | string (nullable) | no |  |
| `model` | string | yes |  |
| `provider` | string | no |  |

### `TicketCategory`

Support ticket categories.

### `TryOnRequest`

Request for virtual try-on generation.

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_storage_path` | string (nullable) | no | Owned avatar storage key; defaults to profile avatar |
| `background` | string | no |  |
| `clothing_description` | string (nullable) | no | Optional description to improve accuracy |
| `clothing_image` | string (nullable) | no | Legacy base64-encoded clothing image |
| `clothing_storage_path` | string (nullable) | no | Owned clothing image storage key |
| `lighting` | string | no |  |
| `pose` | string | no |  |
| `save_to_storage` | boolean | no |  |
| `style` | string | no |  |

### `UpdateCollectionOutfitsRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `outfit_ids` | array<string> | no |  |

### `UpdateEventRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string (nullable) | no |  |
| `end_time` | string (nullable) | no |  |
| `event_type` | string (nullable) | no |  |
| `is_all_day` | boolean (nullable) | no |  |
| `location` | string (nullable) | no |  |
| `outfit_id` | string (nullable) | no |  |
| `start_time` | string (nullable) | no |  |
| `title` | string (nullable) | no |  |

### `UpdateItemCategoriesRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `category` | string (nullable) | no |  |
| `colors` | array<string> (nullable) | no |  |
| `materials` | array<string> (nullable) | no |  |
| `occasion_tags` | array<string> (nullable) | no |  |
| `seasonal_tags` | array<string> (nullable) | no |  |
| `style` | string (nullable) | no |  |
| `sub_category` | string (nullable) | no |  |

### `UserPreferencesUpdate`

Model for updating user preferences (all fields optional).

| Field | Type | Required | Description |
|---|---|---|---|
| `color_temperature` | string (nullable) | no |  |
| `data_points_collected` | integer (nullable) | no |  |
| `disliked_patterns` | array<string> (nullable) | no |  |
| `favorite_colors` | array<string> (nullable) | no |  |
| `liked_brands` | array<string> (nullable) | no |  |
| `preferred_occasions` | array<string> (nullable) | no |  |
| `preferred_styles` | array<string> (nullable) | no |  |
| `style_personality` | string (nullable) | no |  |

### `UserSettingsUpdate`

Model for updating user settings (all fields optional).

| Field | Type | Required | Description |
|---|---|---|---|
| `dark_mode` | boolean (nullable) | no |  |
| `default_location` | string (nullable) | no |  |
| `email_marketing` | boolean (nullable) | no |  |
| `language` | string (nullable) | no |  |
| `measurement_units` | string (nullable) | no |  |
| `notifications_enabled` | boolean (nullable) | no |  |
| `timezone` | string (nullable) | no |  |

### `UserUpdate`

Model for updating user profile.

| Field | Type | Required | Description |
|---|---|---|---|
| `avatar_url` | string (nullable) | no |  |
| `birth_date` | string (date) (nullable) | no |  |
| `birth_place` | string (nullable) | no |  |
| `birth_time` | string (nullable) | no |  |
| `full_name` | string (nullable) | no |  |
| `gender` | string (nullable) | no |  |
| `is_active` | boolean (nullable) | no |  |

### `ValidatePromoRequest`

Request to validate a promo code without redeeming it.

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | string | yes |  |

### `ValidateReferralRequest`

Request to validate a referral code.

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | string | yes |  |

### `ValidationError`

| Field | Type | Required | Description |
|---|---|---|---|
| `ctx` | object | no |  |
| `input` | object | no |  |
| `loc` | array<one of: string \| integer> | yes |  |
| `msg` | string | yes |  |
| `type` | string | yes |  |

### `WaitlistJoinRequest`

Request to join the mobile app waitlist.

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string (email) | yes |  |
| `full_name` | string (nullable) | no |  |

---

_Regenerate after backend API changes; CI drift-checks this file (`.github/workflows/backend-ci.yml`)._

