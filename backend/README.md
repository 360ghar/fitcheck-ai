# FitCheck AI - Backend

FastAPI backend for the FitCheck AI wardrobe management application.

## Tech Stack

- **FastAPI** - Web framework
- **Python 3.12+** - Runtime
- **Pydantic v2** - Data validation & settings
- **Supabase** - PostgreSQL database & storage
- **Pinecone** - Vector database for embeddings
- **Google Gemini / OpenAI** - AI services
- **pydantic-ai** - AI agent framework
- **httpx** - Async HTTP client
- **uvicorn** - ASGI server

## Quick Start

### Prerequisites
- Python 3.12+
- Supabase account (hosted)
- AI API keys (Gemini or OpenAI)
- Pinecone account (for vector search)

### Installation

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Environment Setup

Copy and configure environment variables:
```bash
cp .env.example .env
```

Required variables:
```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret

# AI Providers
GOOGLE_API_KEY=your-gemini-api-key
OPENAI_API_KEY=your-openai-api-key  # Optional

# Pinecone (Vector DB)
PINECONE_API_KEY=your-pinecone-key
PINECONE_INDEX=fitcheck-embeddings

# Security
SECRET_KEY=your-jwt-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Weather API
OPENWEATHERMAP_API_KEY=your-weather-api-key
```

### Running the Server

```bash
uvicorn app.main:app --reload --port 8000
```

Access:
- **API**: http://localhost:8000
- **Docs (Swagger)**: http://localhost:8000/docs
- **Docs (ReDoc)**: http://localhost:8000/redoc

## Project Structure

```
app/
├── api/
│   └── v1/                     # API routes (versioned)
│       ├── auth.py             # Authentication endpoints
│       ├── users.py            # User management
│       ├── items.py            # Wardrobe items CRUD
│       ├── outfits.py          # Outfit management
│       ├── ai.py               # AI extraction & generation
│       ├── ai_settings.py      # AI provider configuration
│       ├── recommendations.py  # AI recommendations
│       ├── calendar.py         # Calendar integration
│       ├── weather.py          # Weather API
│       ├── gamification.py     # Streaks & achievements
│       ├── shared_outfits.py   # Public outfit sharing
│       ├── waitlist.py         # Pre-launch waitlist
│       └── deps.py             # Dependency injection
├── agents/                     # AI agent definitions
├── core/                       # Core configuration
│   ├── config.py              # Settings management
│   ├── security.py            # Auth & JWT utilities
│   └── exceptions.py          # Custom exceptions
├── db/                         # Database utilities
│   └── supabase.py            # Supabase client
├── models/                     # Pydantic models
│   ├── user.py                # User schemas
│   ├── item.py                # Item schemas
│   ├── outfit.py              # Outfit schemas
│   └── ...                    # Other models
├── services/                   # Business logic
│   ├── ai_service.py          # Core AI operations
│   ├── ai_provider_service.py # Multi-provider AI support
│   ├── ai_settings_service.py # AI configuration management
│   ├── storage_service.py     # Supabase storage
│   ├── vector_service.py      # Pinecone embeddings
│   └── weather_service.py     # Weather API integration
├── utils/                      # Utility functions
└── main.py                     # FastAPI application entry
```

## API Endpoints

### Authentication (`/api/v1/auth`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | User registration |
| POST | `/login` | User login |
| POST | `/refresh` | Refresh access token |
| POST | `/logout` | Logout (invalidate refresh token) |
| POST | `/forgot-password` | Request password reset |
| POST | `/reset-password` | Reset password with token |

### Users (`/api/v1/users`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/me` | Get current user |
| PUT | `/me` | Update current user |
| POST | `/me/avatar` | Upload avatar |
| GET | `/me/preferences` | Get user preferences |
| PUT | `/me/preferences` | Update preferences |
| GET | `/me/settings` | Get user settings |
| PUT | `/me/settings` | Update settings |
| GET | `/me/body-profile` | Get body profile |
| PUT | `/me/body-profile` | Update body profile |

### Items (`/api/v1/items`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List items (with filters) |
| POST | `/` | Create item |
| GET | `/{id}` | Get item by ID |
| PUT | `/{id}` | Update item |
| DELETE | `/{id}` | Delete item |
| POST | `/{id}/images` | Upload item images |
| POST | `/{id}/mark-worn` | Mark item as worn |
| POST | `/batch-delete` | Batch delete items |

### Outfits (`/api/v1/outfits`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List outfits |
| POST | `/` | Create outfit |
| GET | `/{id}` | Get outfit |
| PUT | `/{id}` | Update outfit |
| DELETE | `/{id}` | Delete outfit |
| POST | `/{id}/generate` | Generate outfit visualization |
| POST | `/{id}/share` | Share outfit publicly |

### AI (`/api/v1/ai`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/extract-items` | Extract items from photo |
| POST | `/extract-single-item` | Extract single item |
| POST | `/generate-product-image` | Generate product photo |
| POST | `/generate-outfit` | Generate outfit visualization |
| POST | `/generate-try-on` | Virtual try-on |

### Recommendations (`/api/v1/recommendations`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/match/{id}` | Find matching items |
| POST | `/complete-look` | Complete look suggestions |
| GET | `/weather` | Weather-based recommendations |
| GET | `/shopping` | Shopping recommendations |
| GET | `/capsule` | Capsule wardrobe suggestions |
| GET | `/similar/{id}` | Find similar items |

### Calendar (`/api/v1/calendar`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/events` | List calendar events |
| POST | `/events` | Create event |
| PUT | `/events/{id}` | Update event |
| DELETE | `/events/{id}` | Delete event |
| POST | `/events/{id}/outfit` | Assign outfit to event |

### Gamification (`/api/v1/gamification`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/streak` | Get user streak |
| GET | `/achievements` | Get user achievements |
| GET | `/leaderboard` | Get community leaderboard |

## AI Services

### Supported Providers

1. **Google Gemini** (default)
   - Vision: `gemini-3-flash-preview`, `gemini-3-pro-preview`
   - Image Gen: `gemini-3-pro-image-preview`
   - Embeddings: `text-embedding-004`

2. **OpenAI**
   - Vision: `gpt-4o`, `gpt-4o-mini`
   - Image Gen: `dall-e-3`, `dall-e-2`
   - Embeddings: `text-embedding-3-small`

3. **Custom Provider**
   - Any OpenAI-compatible endpoint
   - Configurable base URL and models

### AI Settings
Users can configure their preferred AI provider via `/api/v1/ai/settings`. Settings are stored per-user with encrypted API keys.

## Database

### Supabase Tables
- `users` - User accounts
- `user_preferences` - Style preferences
- `user_settings` - App settings
- `body_profiles` - Body measurements
- `items` - Wardrobe items
- `item_images` - Item photos
- `outfits` - Outfit combinations
- `outfit_images` - Generated outfit images
- `calendar_events` - Planned outfits
- `streaks` - Gamification streaks
- `achievements` - User achievements

### Migrations
SQL migrations are in `db/supabase/migrations/`. Apply via Supabase dashboard or CLI.

## Testing

```bash
pytest
pytest -v                    # Verbose
pytest --cov=app            # With coverage
```

## Development Tips

1. **Auto-reload**: Use `--reload` flag with uvicorn
2. **Swagger UI**: Test endpoints at `/docs`
3. **Logging**: Check `logs/` directory for detailed logs
4. **Environment**: Never commit `.env` files

## Deployment

### Railway
Configured via `railway.json`:
```json
{
  "build": {"builder": "DOCKERFILE"},
  "deploy": {"startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT"}
}
```

### Docker
```bash
docker build -t fitcheck-backend .
docker run -p 8000:8000 --env-file .env fitcheck-backend
```

## Error Handling

All API errors follow the format:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

Common error codes:
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Permission denied
- `NOT_FOUND` - Resource not found
- `VALIDATION_ERROR` - Invalid input
- `AI_ERROR` - AI service failure
- `RATE_LIMITED` - Too many requests
