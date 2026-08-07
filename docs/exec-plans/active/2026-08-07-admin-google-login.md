# Plan: admin panel Google sign-in

Status: active  
Started: 2026-08-07  
Owner: agent

## Goal

Admins who signed up via Google (no password) can sign in to the admin panel
with "Continue with Google". The admin SPA starts a Supabase Google OAuth
redirect, handles the callback at `/auth/callback`, syncs the profile via the
existing `POST /api/v1/auth/oauth/sync`, and bootstraps through the existing
`GET /api/v1/admin/me` RBAC gate — zero backend changes.

## Non-goals

- No backend changes (oauth/sync + require_admin already support this).
- No domain restriction on the Google button: RBAC remains the only gate.
- No e2e Playwright coverage for the live Google round-trip (needs real
  credentials; unit tests mock the Supabase client).
- No passwordless/other providers.

## Acceptance criteria

- [x] "Continue with Google" renders on `/login` when `VITE_SUPABASE_URL` +
      `VITE_SUPABASE_PUBLISHABLE_KEY` are set, hidden when not.
- [x] Clicking it calls `supabase.auth.signInWithOAuth({ provider: 'google',
      redirectTo: origin + '/auth/callback' })` and stashes a safe `returnTo`.
- [x] `/auth/callback` completes sign-in: `getSession` → `oauth/sync` with
      the OAuth bearer token → tokens stored → `bootstrap()` → navigate to
      stashed `returnTo` or `/dashboard`.
- [x] Non-admin Google account → 403 → dropped session + "no admin access"
      banner on the login page (existing permissionDenied path).
- [x] Cancelled-at-Google / sync failure → error UI with "Back to sign in"
      that preserves `returnTo`.
- [x] All lint/typecheck/tests/build green; i18n keys used everywhere.
- [x] Supabase redirect-URL allowlist entries documented (manual step).

## Context / links

- Related docs: `admin/README.md` (env + auth), `docs/exec-plans/active/2026-08-07-admin-panel.md`
- Related code: `admin/src/shared/stores/sessionStore.ts`, `admin/src/features/auth/`,
  `backend/app/api/v1/auth.py` (`oauth/sync`), `backend/app/api/v1/deps.py` (`require_admin`)
- Mirrors `frontend/src/lib/auth.ts` / `frontend/src/stores/authStore.ts` Google flow.

## Progress log

| Date | Note |
|------|------|
| 2026-08-07 | Implemented; unit tests, lint, typecheck, build green |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-07 | Direct Supabase OAuth from the admin domain (not via the main app) | One SPA ↔ one callback; reuses the same Supabase project + backend endpoints |
| 2026-08-07 | Mock `@/shared/lib/supabase` in tests; deferred the setup.ts store import | setup.ts's eager store import loaded the real module before `vi.mock` registered; the lazy import also bypasses the wrapper's clientPromise cache across tests |
| 2026-08-07 | `isGoogleAuthConfigured()` reads `import.meta.env` at render time | Keeps the button testable with `vi.stubEnv`; Vite statically inlines the values in production builds |

## Verification

```bash
cd admin
npm run lint
npm run typecheck
npm test
npm run build
```

Manual (requires Supabase redirect URLs):
1. Supabase dashboard → Authentication → URL Configuration → Redirect URLs:
   add `https://admin.fitcheckaiapp.com/auth/callback` +
   `http://localhost:5173/auth/callback`.
2. `npm run dev`, sign in with a Google account that has an admin role;
   confirm redirect round-trip and returnTo restore.
3. Sign in with a non-admin Google account; confirm the not-admin banner.

## Deferred debt

- None. Netlify needs `VITE_SUPABASE_URL` + `VITE_SUPABASE_PUBLISHABLE_KEY`
  build env vars set for production Google sign-in (deployment step, not code).
