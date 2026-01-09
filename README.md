# FitCheck AI

Virtual closet with AI-powered outfit visualization

FitCheck AI is a comprehensive wardrobe management application that uses artificial intelligence to help users organize their clothing, create outfit combinations, and visualize how outfits will look before wearing them.

## Features

### Core Functionality
- **Digital Wardrobe**: Upload outfit photos and let AI extract individual clothing items automatically
- **Smart Categorization**: Auto-tag items by category (tops, bottoms, shoes, accessories, outerwear)
- **Color Detection**: Automatic color palette extraction for each item
- **Mix & Match**: Select items from your wardrobe to create new outfit combinations
- **AI Outfit Generation**: Generate realistic images showing outfit combinations

### Planning & Organization
- **Calendar Integration**: Plan outfits for specific dates and events
- **Weather-Based Suggestions**: Get outfit recommendations based on weather forecasts
- **Usage Analytics**: Track most/least worn items with cost-per-wear calculations
- **Condition Tracking**: Mark items as clean, dirty, needs repair, or donate

### AI-Powered Recommendations
- **Style Matching**: Find complementary pieces from your wardrobe
- **Complete Look Suggestions**: Get AI-generated outfit ideas
- **Shopping Recommendations**: Identify gaps in your wardrobe

### Social & Gamification
- **Share Outfits**: Get feedback from friends before events
- **Streak Tracking**: Build consistency with outfit planning
- **Achievements**: Unlock badges for wardrobe milestones
- **Leaderboard**: Compare style stats with the community

## Technology Stack

### Backend
- **Framework**: FastAPI (Python)
- **Database**: Supabase (PostgreSQL)
- **Vector DB**: Pinecone
- **Storage**: Supabase Storage
- **AI Services**: Google Gemini, OpenAI (configurable)

### Frontend
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite 5
- **UI**: shadcn/ui + Tailwind CSS
- **State**: TanStack Query + Zustand
- **Forms**: React Hook Form + Zod

## Quick Start

### Prerequisites
- Python 3.12+
- Node.js 18+
- Supabase account (hosted)
- AI API keys (Gemini or OpenAI)

### Environment Setup

1. Clone the repository:
```bash
git clone https://github.com/your-org/fitcheck-ai.git
cd fitcheck-ai
```

2. Copy environment files:
```bash
cp .env.example .env
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env  # if exists
```

3. Configure your `.env` files with:
   - Supabase URL and keys
   - AI provider API keys (Gemini/OpenAI)
   - JWT secrets

### Running Locally

**Option 1: Using the dev script (recommended)**
```bash
./run-dev.sh
```
This starts both backend (port 8000) and frontend (port 3000).

**Option 2: Manual start**

Backend:
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # or `.venv\Scripts\activate` on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Frontend:
```bash
cd frontend
npm install
npm run dev
```

### Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## Project Structure

```
fitcheck-ai/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/v1/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── models/         # Pydantic models
│   │   └── main.py         # Entry point
│   ├── db/                 # Database migrations
│   └── requirements.txt
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/     # UI components
│   │   ├── pages/          # Route pages
│   │   ├── stores/         # Zustand stores
│   │   ├── api/            # API client
│   │   ├── lib/            # Utilities
│   │   └── types/          # TypeScript types
│   └── package.json
├── docs/                   # Comprehensive documentation
│   ├── 1-product/          # Product specs & user stories
│   ├── 2-technical/        # Architecture & API specs
│   ├── 3-features/         # Feature implementations
│   ├── 4-implementation/   # Development guides
│   └── 5-development/      # Setup & deployment
└── docker-compose.yml      # Container orchestration
```

## Documentation

Comprehensive documentation is available in the `/docs` folder:

| Section | Description |
|---------|-------------|
| [Product Overview](./docs/1-product/overview.md) | Vision, target users, business model |
| [User Stories](./docs/1-product/user-stories.md) | 40+ detailed user journeys |
| [Architecture](./docs/2-technical/architecture.md) | System design & diagrams |
| [API Specification](./docs/2-technical/api-spec.md) | 90+ endpoints documented |
| [Data Models](./docs/2-technical/data-models.md) | Database schemas |
| [Setup Guide](./docs/5-development/setup.md) | Local development setup |

See [docs/README.md](./docs/README.md) for the complete documentation index.

## Development Commands

### Backend
```bash
cd backend
pytest                      # Run tests
uvicorn app.main:app --reload  # Dev server
```

### Frontend
```bash
cd frontend
npm run dev                 # Dev server
npm run build              # Production build
npm run lint               # Lint check
npm run preview            # Preview build
```

### Docker (optional)
```bash
docker compose up --build   # Run full stack
```

## AI Configuration

FitCheck AI supports multiple AI providers. Configure in the app settings or via environment:

| Provider | Use Case | Models |
|----------|----------|--------|
| Google Gemini | Vision, Generation | gemini-3-flash, gemini-3-pro |
| OpenAI | Vision, Generation | gpt-4o, dall-e-3 |
| Custom | Self-hosted endpoints | Any OpenAI-compatible |

## Implementation Status

### Fully Implemented
- Core wardrobe management (upload, categorize, filter, edit)
- AI-powered item extraction from photos
- Outfit creation and generation
- Calendar integration with outfit planning
- Weather-based recommendations
- Gamification (streaks, achievements, leaderboard)
- Virtual try-on
- Social sharing and feedback

### In Progress
- Duplicate detection (embedding-based)
- Multi-pose outfit generation
- Personal style learning
- Wardrobe gap analysis

### Planned
- Community style feed
- Price tracking and alerts
- Sustainability scoring
- Export to PDF/lookbook

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention
Use conventional commits: `type: description`
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests

## License

This project is proprietary. All rights reserved.

## Support

For questions or issues:
- Check the [documentation](./docs/README.md)
- Review [AGENTS.md](./AGENTS.md) for AI agent guidelines
- Open a GitHub issue
