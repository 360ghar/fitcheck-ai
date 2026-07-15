# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FitCheck AI backend - a FastAPI application for wardrobe management with AI-powered outfit visualization. Part of a monorepo with a React frontend (see `../frontend/`).

## Development Commands

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server (port 8000)
uvicorn app.main:app --reload --port 8000

# Run tests
pytest
pytest -v                    # Verbose
pytest --cov=app            # With coverage
```

**API Documentation**: Available at `http://localhost:8000/api/v1/docs` (Swagger) or `/api/v1/redoc` when running locally.

## Architecture

### Application Structure
```
app/
├── main.py              # FastAPI app, middleware, route registration, error handlers
├── api/v1/              # API route modules (auth, items, outfits, ai, etc.)
│   └── deps.py          # FastAPI dependencies (get_current_user, get_db)
├── core/
│   ├── config.py        # Pydantic Settings (all env vars)
│   ├── security.py      # JWT verification, password hashing
│   ├── exceptions.py    # Custom exception hierarchy
│   └── middleware.py    # CorrelationId, RequestLogging middleware
├── models/              # Pydantic models for request/response schemas
├── services/            # Business logic (AI, storage, vector, weather)
├── db/
│   └── connection.py    # Supabase client singleton
└── agents/              # hand-rolled agent classes (extraction, image generation)
```

### Database Layer
- Uses Supabase (hosted PostgreSQL) via `supabase-py` client
- `SupabaseDB` singleton in `app/db/connection.py` provides two clients:
  - `get_service_client()` - Service role key for elevated privileges (default for routes)
  - `get_client()` - Publishable key for certain auth flows
- FastAPI dependency: `db: Client = Depends(get_db)` injects service client

### Authentication Flow
- JWT tokens verified via `verify_token` dependency in `app/core/security.py`
- `get_current_user` dependency fetches user from database using token's `sub` claim
- Tokens issued by Supabase Auth, verified using `SUPABASE_JWT_SECRET`

### Error Handling
All custom exceptions inherit from `FitCheckException` in `app/core/exceptions.py`:
- `AuthenticationError`, `TokenExpiredError`, `InvalidTokenError`
- `NotFoundError` and subtypes (`ItemNotFoundError`, `OutfitNotFoundError`, etc.)
- `ValidationError`, `ServiceError`, `DatabaseError`, `RateLimitError`

Errors are caught by exception handlers in `main.py` and return standardized JSON:
```json
{
  "error": "Human-readable message",
  "code": "ERROR_CODE",
  "details": {},
  "correlation_id": "uuid"
}
```

### Middleware Stack (order matters)
1. `CorrelationIdMiddleware` - Generates unique ID per request
2. `RequestLoggingMiddleware` - Logs requests with timing
3. `CORSMiddleware` - Handles cross-origin requests

### AI Provider System
Multi-provider AI support configured in `app/core/config.py`:
- **Custom** (default): Agnes AI OpenAI-compatible gateway (`apihub.agnes-ai.com`)
- **OpenAI**: GPT-4o, DALL-E

The default custom stack uses Agnes for **chat, vision, and image generation**:
- Chat/vision: `agnes-2.0-flash` via `POST /v1/chat/completions`
- Images: `agnes-image-2.1-flash` (primary) → `agnes-image-2.0-flash` (fallback)
  via `POST /v1/images/generations`. If the primary model fails transiently (429
  rate limit, 503 overload, timeout, or a 200 with no images), the request
  automatically retries with the fallback model. Non-transient failures (bad key,
  content-policy rejection, unknown model) raise immediately instead of retrying.

`OPENAI_LLM_*` / `OPENAI_IMAGE_*` override `AI_CUSTOM_*` so LLM and image hosts
or keys can differ if needed. `OPENAI_IMAGE_API_STYLE` picks image routing:
`"images"` (default for Agnes — real `/images/generations`) or `"chat"`
(`response_modalities` on `/chat/completions`, legacy proxy-style).
With `"images"`, every image-generation call is intercepted inside `chat()` and
routed to `/images/generations`. For Agnes, reference images and
`response_format` must be nested under `extra_body` (gateway 400s on top-level
`response_format` and ignores top-level `image`) — see the `ponytail:` comment
in `_generate_image_via_images_api`.

Embeddings are separate from the provider abstraction above: they always use Google's
`google.genai` SDK directly, via `AI_GEMINI_API_KEY` and `AI_GEMINI_EMBEDDING_MODEL`.

User-specific AI settings stored in `user_ai_settings` table with encrypted API keys.

## Key Patterns

### Adding New API Endpoints
1. Create route module in `app/api/v1/`
2. Define Pydantic models in `app/models/`
3. Register router in `app/main.py` with prefix and tags
4. Use dependencies: `db: Client = Depends(get_db)`, `user = Depends(get_current_user)`

### Route Handler Pattern
```python
from fastapi import APIRouter, Depends
from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import ItemNotFoundError

router = APIRouter()

@router.get("/{item_id}")
async def get_item(
    item_id: str,
    db: Client = Depends(get_db),
    user = Depends(get_current_user),
):
    result = db.table("items").select("*").eq("id", item_id).eq("user_id", user["id"]).single().execute()
    if not result.data:
        raise ItemNotFoundError(item_id)
    return result.data
```

### Service Layer
Business logic lives in `app/services/`:
- `ai_service.py` - Core AI operations (extraction, generation)
- `ai_provider_service.py` - Multi-provider abstraction
- `storage_service.py` - Supabase Storage operations
- `vector_service.py` - Pinecone embeddings
- `weather_service.py` - OpenWeatherMap integration

## Environment Variables

Required in `.env`:
```bash
# Supabase (required)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=your-anon-key
SUPABASE_SECRET_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret

# AI Configuration (custom provider is default = Agnes AI)
AI_DEFAULT_PROVIDER=custom  # Options: custom, openai
AI_GEMINI_API_KEY=your-gemini-key  # Required for embeddings (not a selectable provider)
AI_CUSTOM_API_URL=https://apihub.agnes-ai.com/v1
AI_CUSTOM_API_KEY=your-agnes-key
AI_CUSTOM_CHAT_MODEL=agnes-2.0-flash
AI_CUSTOM_VISION_MODEL=agnes-2.0-flash
AI_CUSTOM_IMAGE_MODEL=agnes-image-2.1-flash
AI_CUSTOM_IMAGE_FALLBACK_MODEL=agnes-image-2.0-flash

# Optional overrides (fall back to AI_CUSTOM_*). LLM and Image can differ.
OPENAI_LLM_URL=https://apihub.agnes-ai.com/v1
OPENAI_LLM_API_KEY=your-agnes-key
OPENAI_LLM_MODEL=agnes-2.0-flash
OPENAI_LLM_VISION_MODEL=agnes-2.0-flash
OPENAI_IMAGE_URL=https://apihub.agnes-ai.com/v1
OPENAI_IMAGE_API_KEY=your-agnes-key
OPENAI_IMAGE_MODEL=agnes-image-2.1-flash
OPENAI_IMAGE_API_STYLE=images  # "chat" | "images"

# Optional
PINECONE_API_KEY=your-pinecone-key
WEATHER_API_KEY=your-openweathermap-key
AI_ENCRYPTION_KEY=hex-key-for-user-api-keys
```

## Database Schema

Schema migrations in `db/supabase/migrations/`. Key tables:
- `users`, `user_preferences`, `user_settings`, `user_ai_settings`
- `items`, `item_images`
- `outfits`, `outfit_images`, `outfit_collections`
- `calendar_events`, `calendar_connections`
- `user_streaks`, `user_achievements`
- `shared_outfits`, `share_feedback`

On startup, `main.py` checks for required tables and logs warnings if schema is incomplete.

## Logging

- Session-based logging configured in `app/core/logging_config.py`
- Log files written to `logs/` directory
- Log level controlled by `LOG_LEVEL` env var (default: INFO)
- Correlation ID included in all log entries for request tracing

## Commit Convention

Use conventional commits: `type: description`
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
