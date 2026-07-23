# Security

Status: draft  
Last updated: 2026-07-22

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
- Images and assets via Supabase Storage with controlled paths; validate ownership on upload/read paths in services.
- CORS configured via backend settings (`BACKEND_CORS_ORIGINS`, `FRONTEND_URL`).

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
