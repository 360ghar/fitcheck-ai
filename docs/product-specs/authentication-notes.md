# Feature Implementation: Authentication

## Overview

FitCheck AI uses **Supabase Auth** for user authentication (email/password + JWT access/refresh tokens).

The frontend authenticates against the **FastAPI backend**, which wraps Supabase Auth server-side and returns a consistent `{ data, message }` envelope.

## UI Pages (Frontend)

- **Login:** `frontend/src/pages/auth/LoginPage.tsx`
- **Register:** `frontend/src/pages/auth/RegisterPage.tsx`
- **Forgot password:** `frontend/src/pages/auth/ForgotPasswordPage.tsx`
- **Reset password (recovery link):** `frontend/src/pages/auth/ResetPasswordPage.tsx`

Routes are defined in `frontend/src/App.tsx` and rendered inside `frontend/src/components/layout/AuthLayout.tsx`.

## State Management (Zustand)

Authentication state is managed in:
- `frontend/src/stores/authStore.ts`

Token storage and Axios auth headers are managed in:
- `frontend/src/api/client.ts`

## Backend Endpoints (FastAPI)

Auth endpoints are implemented in:
- `backend/app/api/v1/auth.py`

Key endpoints:
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout` (204)
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/reset-password`
- `POST /api/v1/auth/confirm-reset-password`

## Password Reset Flow

1. User requests reset on `/auth/forgot-password` -> `POST /api/v1/auth/reset-password`
2. Supabase sends an email with a recovery link that redirects to `/auth/reset-password`
3. The redirect includes a recovery session in the URL (typically `#access_token=...&refresh_token=...`)
4. `/auth/reset-password` posts `{ access_token, refresh_token, new_password }` to `POST /api/v1/auth/confirm-reset-password`

## Route Protection

`frontend/src/App.tsx` uses a `ProtectedRoute` wrapper driven by `useIsAuthenticated()` to guard application routes under `AppLayout`.

## Error Handling (High-Level)

- 401/403 auth failures are normalized via `frontend/src/api/client.ts` and surfaced through `authStore`.
- If the Supabase public schema is not initialized, `/auth/register` returns `503` with instructions to apply `backend/db/supabase/migrations/001_full_schema.sql`.

