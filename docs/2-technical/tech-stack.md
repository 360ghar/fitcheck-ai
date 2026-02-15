# Tech Stack

Last updated: 2026-02-15

## Overview

This document captures the technologies actively used by the FitCheck AI codebase and their roles.

## Backend

### Framework and Runtime

- FastAPI (`backend/requirements.txt`)
- Python 3.12+
- Uvicorn ASGI server
- Pydantic + `pydantic-settings`

Why:
- async-friendly API server
- typed request/response validation
- straightforward route/service modularity

### Data and Storage

- Supabase (PostgreSQL + Auth + Storage)
- Supabase Python client

Why:
- managed relational database with auth/storage integration
- strong fit for user-scoped multi-entity app data

### AI and Integrations

- `google-genai` (Gemini access)
- OpenAI-compatible access path via backend provider abstraction
- `httpx` for outbound API calls
- `pydantic-ai` package present for agent workflows

Provider configuration groups:
- `AI_GEMINI_*`
- `AI_OPENAI_*`
- `AI_CUSTOM_*`

### Vector and Search (Optional)

- Pinecone SDK (`pinecone`)

Why:
- embedding-based similarity and retrieval flows

### Billing and Other Services

- Stripe (`stripe`)
- Weather integration via configured weather API key
- OAuth integrations for social import flows

## Web Frontend

### Core

- React 18
- TypeScript 5
- Vite 5

### UI and State

- Tailwind CSS
- Radix UI primitives + shadcn-style component composition
- Zustand
- TanStack Query

### Forms and Validation

- React Hook Form
- Zod

### HTTP and Analytics

- Axios
- PostHog JS

## Mobile App (Flutter)

### Core

- Flutter (Dart SDK in `flutter/pubspec.yaml`)
- GetX (routing + state/dependency patterns)

### Networking and Data

- Dio + `http`
- Supabase Flutter

### Utilities

- `image_picker`, `cached_network_image`, `shimmer`, `share_plus`
- PostHog Flutter

## Remotion

- Remotion 4
- React-based video composition packages

Role:
- marketing/promo video generation assets and scenes

## Developer Tooling

### JavaScript/Frontend

- ESLint
- TypeScript compiler (`tsc` via build script)

### Python/Backend

- Pytest
- Pytest-asyncio

### Flutter

- Flutter test
- build_runner/freezed/json_serializable for model generation

## Environment Strategy

Backend keys are loaded from:
- `backend/.env`
- root `.env`

Frontend keys are provided through Vite env vars:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL`

Flutter keys are provided through:
- `--dart-define` values
- optional `.env` asset fallback

## Infrastructure Notes

- Hosted Supabase is required.
- Local development uses non-Docker workflows.
- Dockerfiles are present for containerized deployment paths, not for standard local dev.

## Summary Table

| Layer | Primary Technologies |
|------|-----------------------|
| Backend API | FastAPI, Uvicorn, Pydantic |
| Data/Auth/Storage | Supabase |
| AI Provider Access | Gemini/OpenAI/custom via backend abstraction |
| Vector Search | Pinecone (optional) |
| Web App | React, TypeScript, Vite, Tailwind, Zustand, TanStack Query |
| Mobile App | Flutter, GetX, Supabase Flutter, Dio |
| Video Assets | Remotion |
| Testing | Pytest, frontend build/lint validation, Flutter test |
