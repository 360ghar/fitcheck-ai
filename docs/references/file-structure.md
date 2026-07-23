# Implementation: File Structure

## Overview

Complete project directory layout for FitCheck AI.

## Directory Tree

```text
fitcheck-ai/
├── backend/                # FastAPI Application
│   ├── app/
│   │   ├── api/            # API Route handlers
│   │   │   ├── v1/         # Versioned endpoints (incl. batch_processing.py)
│   │   │   └── deps.py     # Dependencies (Auth, DB)
│   │   ├── core/           # Config, Security, Logging
│   │   ├── models/         # Pydantic schemas
│   │   ├── services/       # Business logic (AI, batch jobs, storage, …)
│   │   ├── agents/         # Server-side AI agents (extract / image gen)
│   │   ├── db/             # Database migrations & seeds
│   │   └── main.py         # Entry point
│   ├── tests/              # Pytest suite
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .env.example
├── frontend/               # React Application
│   ├── src/
│   │   ├── api/            # Axios clients (ai.ts, batch.ts, items.ts, …)
│   │   ├── components/     # Reusable UI components
│   │   │   ├── ui/         # shadcn/ui components
│   │   │   ├── wardrobe/   # BatchExtractionFlow, ItemCard, …
│   │   │   ├── jobs/       # JobPill, GeneratingSurface
│   │   │   └── layout/     # Nav, Sidebar, AppLayout
│   │   ├── hooks/          # useBatchExtraction, useBatchSSE, …
│   │   ├── lib/            # image-compress, crop-from-bounding-box, utils
│   │   ├── pages/          # Page components
│   │   ├── stores/         # Zustand (auth, wardrobe, jobUiStore, …)
│   │   ├── types/          # TypeScript interfaces
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── public/
│   ├── vite.config.ts
│   └── package.json
├── flutter/                # Mobile app (GetX)
├── docs/                   # Knowledge base (system of record)
│   ├── design-docs/        # Beliefs, design decisions
│   ├── exec-plans/         # active/, completed/, tech-debt tracker
│   ├── product-specs/      # Product overview, stories, feature PRDs
│   ├── references/         # API, auth, setup, stack, implementation notes
│   ├── store/              # App / Play store listing copy
│   ├── generated/          # Regenerable artifacts (e.g. db-schema)
│   ├── BACKEND.md          # Backend deep dive
│   ├── FRONTEND.md         # Web deep dive
│   └── …                   # DESIGN, PLANS, PRODUCT_SENSE, QUALITY, etc.
├── scripts/                # Harness checks (architecture, docs structure)
├── AGENTS.md               # Repo map / agent entry (identical to CLAUDE.md)
├── CLAUDE.md               # Same as AGENTS.md
├── ARCHITECTURE.md         # Domains and allowed dependency edges
├── README.md
└── .gitignore
```

## Key Directories Explained

### Backend
- **api/**: Route definitions. Batch wardrobe jobs: `api/v1/batch_processing.py`. Logic delegated to services.
- **services/**: Supabase, Stripe, weather, AI providers; batch pipeline: `batch_extraction_service.py` (overlapped extract→generate), `batch_job_service.py`.
- **agents/**: Vision extraction and product/outfit image generation agents.
- **models/**: All Pydantic v2 models for request validation and response serialization.

### Frontend
- **components/ui/**: Managed by shadcn/ui. Don't edit directly unless customizing base styles.
- **components/wardrobe/**: Batch upload/review UI (`BatchExtractionFlow`, grids, progress).
- **api/**: Domain clients — `ai.ts`, **`batch.ts`** (multipart + JSON job start, SSE helpers), `items.ts`.
- **hooks/**: `useBatchExtraction`, `useBatchSSE` for wardrobe AI jobs.
- **lib/**: Supabase config, `image-compress.ts` (AI upload prep), `crop-from-bounding-box.ts`.
- **stores/**: Domain stores (auth, wardrobe, planning) plus **`jobUiStore`** for the app job pill.
- **pages/**: Follows the routing structure.
