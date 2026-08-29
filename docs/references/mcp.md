# MCP server & ChatGPT app (agent surface)

FitCheck exposes its API to AI agents through **MCP** (Model Context
Protocol, streamable HTTP). One codebase in `backend/app/mcp/`, two mounts:

| Mount | Audience | Contents |
|---|---|---|
| `/mcp` | Claude, Cursor, Droid, power users | Full API mirror: one tool per endpoint (denylist excluded) |
| `/mcp/chatgpt` | ChatGPT developer-mode connector (Apps SDK) | Curated ~8 tools with widget UI (`ui://` resources) |

A ChatGPT app **is** an MCP server: registering it in developer mode is just
pasting `https://api.fitcheckaiapp.com/mcp/chatgpt`. Both mounts are
**stateless** (no session affinity; every JSON-RPC POST is self-contained and
bearer-authenticated), so requests hit any worker.

## How tool execution works

Tools are **generated from the FastAPI OpenAPI schema** at startup
(`app/mcp/generate.py`): name = sanitized `operationId` prefixed by tag
(`items_create_item`), input schema = merged path/query/body, description =
summary + tags. Tool names/schemas therefore track the live API with zero
per-tool maintenance.

Tool calls execute as **in-process ASGI loopback requests** against the real
routes (`app/mcp/executor.py`):

```
MCP client → /mcp (bearer) → tool dispatch → httpx ASGITransport loopback
           → /api/v1 route (get_current_user, validation, rate limits)
           → services → JSON result → structuredContent
```

Consequences: auth, validation, rate limits, and error formatting are
identical to the public API; 2xx returns the API payload as
`structuredContent`; 4xx/5xx returns `{"error": {"status", ...}}` without
raising so agents can read and self-correct.

## Denylist (never exposed to agents)

`admin/*` (RBAC console), `auth/*` (session management), any webhook,
SSE/streaming endpoints (batch-extract, photoshoot/social-import events),
multipart/binary uploads (single-call extraction of items stays exposed),
`demo/*`, `waitlist/*`, `images/*` (presigned bytes), `/health`, `/ready`.
Rules live in `app/mcp/denylist.py`.

## Authentication

**Header-auth clients (Claude Code, Cursor, Droid, inspector):** send the
user's Supabase access token:

```
claude mcp add --transport http fitcheck https://api.fitcheckaiapp.com/mcp \
  --header "Authorization: Bearer <SUPABASE_JWT>"
```

Tokens are verified inside the loopbacked route by the normal
`get_current_user` dependency (`app/core/security.py` tries Supabase
verification first, then MCP-issued tokens). The MCP transport itself only
checks presence (401 + `WWW-Authenticate` challenge) — one verification code
path, no duplication.

**ChatGPT connectors (require OAuth 2.1):** the backend implements a minimal
OAuth gateway (`app/api/v1/oauth.py` + `app/services/mcp_oauth_service.py`),
issuer = `MCP_OAUTH_ISSUER` (convention: `{PUBLIC_API_BASE_URL}/api/v1/oauth`):

- `GET  {issuer}/.well-known/oauth-authorization-server` and
  `.../oauth-protected-resource` — RFC 8414 / 9728 discovery
- `POST {issuer}/register` — dynamic client registration (RFC 7591); public
  clients only, redirect URIs must match `MCP_REDIRECT_URI_ALLOWLIST`
- `GET  {issuer}/authorize` — validates PKCE S256, redirects to the frontend
  bridge `/oauth/bridge` (`frontend/src/pages/oauth/OAuthBridgePage.tsx`),
  which signs the user in via Supabase and POSTs the session to
- `POST {issuer}/authorize/complete` — binds the Supabase user, 302s the code
- `POST {issuer}/token` — code exchange / refresh rotation (RFC 6749 §5.2
  error semantics); `POST {issuer}/revoke` (RFC 7009)

Access tokens are backend-minted HS256 JWTs (`aud=fitcheck-mcp`,
`sub` = FitCheck user id) and expire after one hour. Signing key:
`MCP_JWT_SECRET`, falling back to `SUPABASE_JWT_SECRET`. Migration
`057_mcp_oauth.sql` creates the three service-role-only tables. Migration
`058_mcp_oauth_atomic_token_exchange.sql` atomically consumes codes and
rotates refresh tokens with family revocation on replay. Codes and refresh
tokens are stored SHA-256-hashed.

## ChatGPT widgets

Widgets are single-file HTML bundles built from `widgets/` (Vite + React +
vite-plugin-singlefile) into `backend/app/mcp/static/`, exposed as
`ui://fitcheck/<name>.html` resources with `_meta.openai/widgetCSP`
(`app/mcp/widgets.py`). Curated tools reference them via
`_meta["openai/outputTemplate"]` (`app/mcp/curated.py`); curated tools are
cloned from the mirror registry by method+path, so schemas stay in sync.
Widget runtime: initial data via `window.openai.toolOutput`, follow-ups via
`window.openai.callTool` (no direct API fetch → no CORS surface), theming via
`window.openai.theme`.

Regenerate after widget changes: `cd widgets && npm run build`.

## Environment

| Variable | Meaning |
|---|---|
| `PUBLIC_API_BASE_URL` | Public origin of the backend (metadata URLs) |
| `MCP_OAUTH_ISSUER` | OAuth issuer URL; **setting it enables** `/oauth/*` (blank = OAuth disabled, 503) |
| `MCP_JWT_SECRET` | HS256 key for MCP tokens (falls back to `SUPABASE_JWT_SECRET`) |
| `MCP_REDIRECT_URI_ALLOWLIST` | Comma-separated redirect-URI *prefixes* for DCR; blank disables registration |

Local dev: `./run-dev.sh`, then connect Claude to
`http://localhost:8000/mcp` with a local Supabase JWT. For ChatGPT developer
mode the backend must be publicly reachable over HTTPS — tunnel it
(`cloudflared tunnel --url http://localhost:8000`) and add
`https://<tunnel>/mcp/chatgpt`; also set the env vars above to the tunnel URL.

## Architecture rules

`app/mcp/` is its own layer (`scripts/check_architecture.py`): it may import
`app.core` (and itself) only — tool calls go through HTTP loopback, never
direct domain imports. Only `app/main.py` may wire the servers. Both mounts
are registered as a single root-level ASGI app (`app/mcp/http.py`
`ManagedMCPASGIApp`) AFTER every route, because Starlette `Mount("/mcp")`
would 307-redirect the exact `/mcp` URL clients POST to; unmatched paths get
the standard 404 envelope.

## Tests

`tests/unit/test_mcp_registry.py` (generation, denylist, executor),
`tests/unit/test_mcp_widgets.py` (resources, traversal guard),
`tests/api/test_mcp_endpoint.py` (protocol: 401 challenge, initialize,
tools/list, tools/call, curated mount, routing),
`tests/api/test_mcp_oauth.py` (DCR, code+PKCE flow, rotation, MCP token on a
real route).

## Deferred follow-ups

- OpenAI app-store listing/review (dev-mode connector works today).
- OAuth beyond the ChatGPT redirect allowlist (third-party developer clients).
- `generate_outfit` as a ChatGPT tool (minutes-long latency needs async job UI).
- Expired token/code cleanup job on `mcp_oauth_*` tables.
