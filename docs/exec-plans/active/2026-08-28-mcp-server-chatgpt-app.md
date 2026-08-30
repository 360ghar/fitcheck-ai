# Plan: MCP server + ChatGPT app

Status: active
Started: 2026-08-28
Owner: agent / saksham

## Goal

FitCheck's API is reachable by AI agents: a full API mirror at `/mcp`
(streamable HTTP, bearer auth) for MCP clients (Claude, Cursor, Droid), and a
curated ChatGPT app at `/mcp/chatgpt` (Apps-SDK widgets, OAuth 2.1 connect
flow) — one MCP codebase, loopback execution, denylist-guarded.

## Non-goals

- OpenAI store listing/review (developer-mode connector only).
- OAuth for third-party developers beyond the ChatGPT redirect allowlist.
- stdio transport; admin MCP surface.
- `generate_outfit` as a ChatGPT tool (long latency; needs async job UI).

## Acceptance criteria

- [x] `/mcp` serves generated tools (denylist excluded; 161 tools at build).
- [x] Tool calls loop back through real routes (auth/validation/rate limits identical).
- [x] OAuth 2.1 gateway: discovery, DCR (allowlist), PKCE code flow, refresh rotation with family revocation.
- [x] `verify_token` accepts backend-minted MCP JWTs (loopback auth works end-to-end).
- [x] `/mcp/chatgpt` curated tools + `ui://` widget resources; widgets build from `widgets/`.
- [x] Architecture checker enforces the `mcp` layer.
- [x] llms.txt "For developers & AI agents" section; docs/SECURITY.md posture; docs/references/mcp.md is the system of record.
- [ ] Migrations 057 and 058 applied to hosted Supabase.
- [ ] End-to-end ChatGPT developer-mode connect verified against a public tunnel.
- [ ] `MCP_OAUTH_ISSUER` etc. set on the production environment (opt-in).

## Context / links

- Related docs: `docs/references/mcp.md` (system of record), `docs/SECURITY.md`
- Related code: `backend/app/mcp/`, `backend/app/api/v1/oauth.py`,
  `backend/app/services/mcp_oauth_service.py`,
  `backend/db/supabase/migrations/057_mcp_oauth.sql`,
  `backend/db/supabase/migrations/058_mcp_oauth_atomic_token_exchange.sql`,
  `frontend/src/pages/oauth/OAuthBridgePage.tsx`, `widgets/`
- Spec: `~/.factory/specs/2026-08-28-fitcheck-mcp-server-chatgpt-app-one-server-two-mounts.md`

## Progress log

| Date | Note |
|------|------|
| 2026-08-28 | Phases A–D implemented; backend suite + lint + checker green; widgets build. |
| 2026-08-29 | Review fixes: expiry-enforced access tokens; database-atomic code consumption and refresh rotation; nested widget envelopes. Full backend suite, frontend suite/build, widgets build, and repository checks passed. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-28 | Tools generated from OpenAPI, executed via ASGI loopback | Zero per-tool maintenance; auth/validation/rate limits identical to the public API |
| 2026-08-28 | Backend-minted HS256 MCP JWTs + `verify_token` fallback branch | Supabase can't mint tokens for the OAuth gateway; without the branch every loopback call 401s |
| 2026-08-28 | MCP transports mounted at router root behind a path-dispatching ASGI app | Starlette `Mount("/mcp")` 307s the exact `/mcp` URL clients POST to; a second root mount would be unreachable |
| 2026-08-28 | Curated ChatGPT registry cloned from the mirror registry | Schemas stay in sync with the API automatically |
| 2026-08-28 | Stateless JSON transport | Works behind Railway scale-out; no session affinity; proxy-friendly |
| 2026-08-29 | Use service-role SQL RPCs for OAuth code consumption and refresh rotation | Row locks make a code or refresh artifact single-use across concurrent API workers. |

## Verification

```bash
cd backend && pytest tests/unit/test_mcp_registry.py tests/unit/test_mcp_widgets.py \
  tests/api/test_mcp_endpoint.py tests/api/test_mcp_oauth.py
cd backend && pytest && ruff check .
python scripts/check_architecture.py
cd widgets && npm run build
cd frontend && npm run lint && npm run build
```
