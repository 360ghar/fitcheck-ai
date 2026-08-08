# Data Models

## Overview

This document summarizes FitCheck AI’s data model across:
- Supabase Postgres schema (tables, relationships, RLS)
- Vector index (Pinecone)
- Backend Pydantic models (FastAPI)
- Frontend TypeScript interfaces (React)

## Source Of Truth

- **Database DDL:** `backend/db/supabase/migrations/` (all files, 001..042 — see "Database Migrations" below)
- **Backend Pydantic models:** `backend/app/models/user.py`, `backend/app/models/item.py`, `backend/app/models/outfit.py`, `backend/app/models/recommendation.py`
- **Frontend types:** `frontend/src/types/index.ts`

The docs intentionally avoid duplicating full table DDL in Markdown to prevent drift; the migration file is canonical.

## Database Schema (Supabase PostgreSQL)

### Auth + Users

- **`auth.users`**: Supabase Auth (email/password + session tokens)
- **`public.users`**: Profile table keyed by `id` (FK -> `auth.users(id)`), including:
  - `avatar_url`, `full_name`, `email_verified`, `last_login_at`, `is_active`
  - astrology profile fields: `birth_date` (DATE), `birth_time` (TIME), `birth_place` (VARCHAR)
  - admin/RBAC columns (migration 037): `is_admin`, `role`
    (`user` | `super_admin` | `admin` | `ops` | `support` | `content_editor`),
    `custom_daily_quota`

### Preferences + Settings

- **`public.user_preferences`**: JSONB arrays for `favorite_colors`, `preferred_styles`, `preferred_occasions`, etc.
- **`public.user_settings`**: `measurement_units`, `notifications_enabled`, `email_marketing`, `dark_mode`, etc.
- **`public.user_ai_settings`**: Per-user AI provider configuration (migration
  `003_remove_puter_add_ai_settings.sql`): `default_provider`
  (`gemini|openai|custom`), `provider_configs` (JSONB holding per-provider
  `api_key_encrypted` + model config), daily counters
  (`daily_extraction_count`, `daily_generation_count`, `last_reset_date`).
  Read/written by `backend/app/services/ai_settings_service.py` (keys
  encrypted via `AI_ENCRYPTION_KEY`). `public.users` itself has **no**
  AI-provider columns.

### Wardrobe

- **`public.items`**: Core wardrobe items plus enrichment fields used by recommendations:
  - `material`, `pattern`, `style`
  - `materials`, `seasonal_tags`, `occasion_tags` (JSONB arrays)
  - Usage analytics: `usage_times_worn`, `usage_last_worn`, `cost_per_wear`, `is_favorite`
- **`public.item_images`**: persisted columns are `storage_path` (the bucket
  key) plus `is_primary`/ordering flags. `image_url` and `thumbnail_url` are
  **response-only** fields: the API materializes them as short-lived presigned
  URLs at read time. They are never stored in the database — new code must not
  write URL strings into `item_images` (S3-compatible/R2 object storage)
- **`public.item_colors`**: Optional detailed color analysis (manual or derived)

### Outfit Management

- **`public.outfits`**: `item_ids` UUID[] plus metadata:
  - `description`, `style`, `season`, `occasion`
  - Sharing: `is_public`
  - Usage analytics: `worn_count`, `last_worn_at`, `is_favorite`
- **`public.outfit_images`**: Supports manual + AI images:
  - `generation_type` (`ai`/`manual`), `generation_metadata`, `is_primary`
  - `storage_path` for object-storage objects (S3-compatible/R2)
- **`public.outfit_collections`** and **`public.outfit_collection_items`**: Group outfits into collections
- **`public.outfit_wear_history`**: Per-outfit wear log (`worn_at`, `created_at`) written by `POST /outfits/{id}/wear` and read by `GET /outfits/{id}/wear-history` (migration 042)

### Body Profiles

- **`public.body_profiles`**: Stored body attributes used to guide server-side visualization prompts.

### Planning (Calendar)

- **`public.calendar_connections`**: Connect a provider (MVP stores the link; external sync is a future enhancement)
- **`public.calendar_events`**: Store events and allow assigning/unassigning `outfit_id`

### AI Generation Tracking

- **`public.outfit_generations`**: Tracks generation requests (the image is generated server-side via the Backend AI API and stored in the S3-compatible object store (R2)).

### Social + Feedback (MVP scaffolding)

- **`public.shared_outfits`** and **`public.share_feedback`**: Enable share links and feedback capture.
- **`public.recommendation_logs`**: Capture feedback and clicks for improving recommendations over time.

### Gamification (MVP)

- **`public.user_streaks`**, **`public.user_achievements`**, **`public.challenges`**, **`public.challenge_participations`**

### Photoshoot Usage

Photoshoot usage is tracked in the `subscription_usage` table with additional columns:
- `daily_photoshoot_images` (INTEGER): Number of photoshoot images generated today
- `last_photoshoot_reset` (DATE): Date of last daily reset

Demo photoshoot usage is tracked via IP-based rate limiting in the backend (in-memory per backend process).

### RLS + Triggers

RLS is enabled on all user-data tables with policies ensuring users can only read/write their own records (exceptions: public challenge reads and feedback inserts). `updated_at` triggers are defined for key tables; see `backend/db/supabase/migrations/001_full_schema.sql`.

## Vector Store (Pinecone)

FitCheck AI uses Pinecone for similarity search and recommendation primitives.

- **Index name:** `PINECONE_INDEX_NAME` (default: `fitcheck-items`)
- **Dimensions:** `PINECONE_DIMENSION` (default: `768`)
- **Embeddings model:** `AI_GEMINI_EMBEDDING_MODEL` (default: `gemini-embedding-001`)

Implementation references:
- `backend/app/services/ai_service.py` (`EmbeddingService`)
- `backend/app/services/vector_service.py` (`VectorService`)

Typical item embedding text is derived from name/category/colors/brand/tags/material to support semantic similarity and rule-boosted matching.

## Backend Pydantic Models

The API layer validates inputs and normalizes outputs using Pydantic v2 models in:
- `backend/app/models/user.py`
- `backend/app/models/item.py`
- `backend/app/models/outfit.py`
- `backend/app/models/recommendation.py`

These models intentionally mirror the JSON shapes returned by the FastAPI endpoints (snake_case) and include domain validation (e.g., allowed item categories and conditions).

## Frontend TypeScript Interfaces

Frontend types are centralized in:
- `frontend/src/types/index.ts`

These types reflect the JSON returned by the backend (snake_case) and the standard `{ data, message }` API envelope.
Astrology recommendations are represented by `AstrologyRecommendation` and related interfaces in the same file.

## Database Migrations

Migrations live in `backend/db/supabase/migrations/` and must **all** be
applied in numeric order — 43 files numbered `001`..`042` (note that `002`
has two files: `002_astrology_profile.sql` and
`002_user_profile_trigger.sql`):

- `001_full_schema.sql` — core tables (users, wardrobe, outfits, planning,
  gamification)
- every later migration (`002`..`042`) builds on top; none may be skipped

Apply the whole sequence in the Supabase SQL Editor (or a migration runner)
before running the app; a partial schema is treated as broken. The backend
`GET /ready` endpoint fails closed: it reports `"schema_ready": false` until
every table in `REQUIRED_TABLES` and every column in `REQUIRED_COLUMNS`
(see `backend/app/main.py`) exists, and (in DEBUG mode) lists the missing
tables/columns to help diagnose partial setups. `/health` is liveness-only
and does NOT report schema state.

## Tables Not Covered Above

The sections above cover the core wardrobe/outfit/planning/gamification
tables. These additional tables exist in the migrations but are intentionally
not expanded here — see the DDL for details:

| Table | Migration |
|------|-----------|
| `subscriptions`, `subscription_usage` | 007 |
| `referral_codes`, `referral_redemptions` | 007 |
| `promo_codes`, `promo_redemptions` | 031 (+ 032 fix) |
| `support_tickets` | 009 (+ 034, 037) |
| `extraction_jobs` | 016 (+ 023, 029) |
| `photoshoot_jobs` | 023 (+ 035) |
| `stripe_webhook_events` | 022 (+ 027) |
| `apple_iap_events`, `google_rtdn_events` | 030 |
| `audit_events` | 038 |
| `blog_posts` (category is a TEXT column; no separate categories table) | 017 |
| `waitlist` | 005 |
| `social_import_jobs`, `social_import_photos`, `social_import_items`, `social_import_auth_sessions`, `social_import_events` | 012 |
| `trips`, `trip_capsule_items` | 001 |

## Validation Rules (High-Level)

- **Items:** category ∈ `tops|bottoms|shoes|accessories|outerwear|swimwear|activewear|other`; condition ∈ `clean|dirty|laundry|repair|donate`
- **Outfits:** must include at least one unique `item_id`
- **Uploads:** backend enforces max file size and supported MIME types; Storage paths are tracked on image rows

Canonical validation lives in Pydantic models and request handlers; see `backend/app/models/` and `backend/app/api/v1/`.
