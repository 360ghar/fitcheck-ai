# Data Models

## Overview

This document summarizes FitCheck AI’s data model across:
- Supabase Postgres schema (tables, relationships, RLS)
- Vector index (Pinecone)
- Backend Pydantic models (FastAPI)
- Frontend TypeScript interfaces (React)

## Source Of Truth

- **Database DDL:** `backend/db/supabase/migrations/001_full_schema.sql`
- **Backend Pydantic models:** `backend/app/models/user.py`, `backend/app/models/item.py`, `backend/app/models/outfit.py`, `backend/app/models/recommendation.py`
- **Frontend types:** `frontend/src/types/index.ts`

The docs intentionally avoid duplicating full table DDL in Markdown to prevent drift; the migration file is canonical.

## Database Schema (Supabase PostgreSQL)

### Auth + Users

- **`auth.users`**: Supabase Auth (email/password + session tokens)
- **`public.users`**: Profile table keyed by `id` (FK -> `auth.users(id)`), including:
  - `avatar_url`, `full_name`, `email_verified`, `last_login_at`, `is_active`
  - **AI settings**: `ai_provider`, `ai_model`, `ai_api_key_encrypted`

### Preferences + Settings

- **`public.user_preferences`**: JSONB arrays for `favorite_colors`, `preferred_styles`, `preferred_occasions`, etc.
- **`public.user_settings`**: `measurement_units`, `notifications_enabled`, `email_marketing`, `dark_mode`, etc.

### Wardrobe

- **`public.items`**: Core wardrobe items plus enrichment fields used by recommendations:
  - `material`, `pattern`, `style`
  - `materials`, `seasonal_tags`, `occasion_tags` (JSONB arrays)
  - Usage analytics: `usage_times_worn`, `usage_last_worn`, `cost_per_wear`, `is_favorite`
- **`public.item_images`**: `image_url`, `thumbnail_url`, and `storage_path` for Supabase Storage object tracking
- **`public.item_colors`**: Optional detailed color analysis (manual or derived)

### Outfit Management

- **`public.outfits`**: `item_ids` UUID[] plus metadata:
  - `description`, `style`, `season`, `occasion`
  - Sharing: `is_public`
  - Usage analytics: `worn_count`, `last_worn_at`, `is_favorite`
- **`public.outfit_images`**: Supports manual + AI images:
  - `generation_type` (`ai`/`manual`), `generation_metadata`, `is_primary`
  - `storage_path` for Storage objects
- **`public.outfit_collections`** and **`public.outfit_collection_items`**: Group outfits into collections

### Body Profiles

- **`public.body_profiles`**: Stored body attributes used to guide server-side visualization prompts.

### Planning (Calendar)

- **`public.calendar_connections`**: Connect a provider (MVP stores the link; external sync is a future enhancement)
- **`public.calendar_events`**: Store events and allow assigning/unassigning `outfit_id`

### AI Generation Tracking

- **`public.outfit_generations`**: Tracks generation requests (the image is generated server-side via the Backend AI API and stored in Supabase Storage).

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
- **Embeddings model:** `GEMINI_EMBEDDING_MODEL` (default: `gemini-embedding-001`)

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

## Database Migrations

This repository uses a single consolidated migration:
- `backend/db/supabase/migrations/001_full_schema.sql`

Apply it in the Supabase SQL Editor before running the app. The backend `/health` endpoint reports whether the schema is ready and lists missing tables/columns to help diagnose partial setups.

## Validation Rules (High-Level)

- **Items:** category ∈ `tops|bottoms|shoes|accessories|outerwear|swimwear|activewear|other`; condition ∈ `clean|dirty|laundry|repair|donate`
- **Outfits:** must include at least one unique `item_id`
- **Uploads:** backend enforces max file size and supported MIME types; Storage paths are tracked on image rows

Canonical validation lives in Pydantic models and request handlers; see `backend/app/models/` and `backend/app/api/v1/`.
