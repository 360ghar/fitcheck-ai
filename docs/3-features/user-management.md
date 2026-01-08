# Feature Implementation: User Management

## Overview

User management includes profile editing, avatar upload, preferences, settings, AI provider configuration, and account deletion.

## UI Pages (Frontend)

- **Profile & Settings:** `frontend/src/pages/settings/ProfilePage.tsx`
  - Profile tab: update `full_name`, view `email`
  - Preferences tab: edit `user_preferences` (arrays like `favorite_colors`, `preferred_styles`, etc.)
  - Settings tab: edit `user_settings` (`measurement_units`, `dark_mode`, notifications, etc.)
  - AI Settings tab: configure AI provider (Gemini, OpenAI, custom proxy)
  - Security tab: password reset email, delete account

## API Client (Frontend)

User APIs are implemented in:
- `frontend/src/api/users.ts`

Key calls:
- `GET /api/v1/users/me`
- `PUT /api/v1/users/me`
- `POST /api/v1/users/me/avatar` (multipart)
- `GET/PUT /api/v1/users/preferences`
- `GET/PUT /api/v1/users/settings`
- `DELETE /api/v1/users/me`

AI settings calls:
- `GET /api/v1/ai/settings`
- `PUT /api/v1/ai/settings`
- `POST /api/v1/ai/settings/test`

## Backend Implementation

Backend handlers live in:
- `backend/app/api/v1/users.py`
- `backend/app/api/v1/ai.py`
- `backend/app/api/v1/ai_settings.py`

Avatar uploads and Storage bucket usage are implemented in:
- `backend/app/services/storage_service.py`

AI provider configuration is handled by:
- `backend/app/services/ai_provider_service.py`
- `backend/app/services/ai_settings_service.py`

## Notes

- Preferences/settings tables may be created lazily by the backend if missing for a user.
- Account deletion is best-effort: the backend attempts to delete the Supabase Auth user (service role) and always deletes `public.users` to cascade user-owned records.
- AI provider API keys are encrypted before storage in the database.

