# FitCheck AI Frontend

React + TypeScript web app for FitCheck AI.

## Responsibilities

- Auth flows and protected app shell
- Wardrobe and outfit management UX
- Recommendations, calendar, gamification, and photoshoot interfaces
- API integration with access-token refresh handling
- Supabase client setup for frontend-side integrations

## Tech Stack

- React 18 + TypeScript
- Vite 5
- Tailwind CSS + shadcn/ui primitives
- Zustand (client state)
- TanStack Query (server state)
- Axios API client with interceptors

## Quick Start

```bash
cd frontend
npm install
npm run dev
```

App URL: `http://localhost:3000`

## Scripts

```bash
npm run dev
npm run lint
npm run build
npm run preview
```

## Environment

Template: `frontend/.env.example`

Common keys:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL`
- `VITE_ENABLE_SOCIAL_IMPORT`
- `VITE_PUBLIC_POSTHOG_KEY`
- `VITE_PUBLIC_POSTHOG_HOST`

## Project Layout

- `src/App.tsx`: route registration and protected/public routing
- `src/pages/`: route-level pages
- `src/components/`: feature components
- `src/components/ui/`: shared UI primitives
- `src/api/`: backend API wrappers
- `src/stores/`: Zustand stores
- `src/lib/`: utility modules
- `src/hooks/`: custom hooks

## Key Routes

Public:
- `/`
- `/about`
- `/terms`
- `/privacy`
- `/auth/*`
- `/shared/outfits/:id`

Authenticated app:
- `/dashboard`
- `/wardrobe`
- `/outfits`
- `/calendar`
- `/recommendations`
- `/photoshoot`
- `/try-on`
- `/gamification`
- `/profile`

## Validation

```bash
cd frontend
npm run lint
npm run build
```

## Development Notes

- API client is in `src/api/client.ts`.
- Token refresh and global API error handling are centralized in interceptors.
- Keep page-level logic in `src/pages/*` and reusable UI in components/hooks/lib.
