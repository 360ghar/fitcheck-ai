# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FitCheck AI frontend - a React + TypeScript wardrobe management app with AI-powered outfit visualization. Part of a monorepo with a FastAPI backend (see `../backend/`).

## Development Commands

```bash
# Development server (port 3000)
npm run dev

# Production build (runs tsc first for type checking)
npm run build

# Lint check
npm run lint

# Preview production build
npm run preview
```

**Type checking**: Run `npm run build` to catch TypeScript errors (no separate type-check command).

## Architecture

### State Management Pattern
- **Zustand stores** (`src/stores/`) for client state with persistence to localStorage
- **TanStack Query** for server state, caching, and data fetching
- **React Hook Form + Zod** for form handling and validation

### API Layer
- All API calls go through `src/api/client.ts` which provides:
  - Automatic token injection via request interceptor
  - Token refresh on 401 with request queue (prevents duplicate refreshes)
  - Global error toasts (skippable with `skipToast` config)
  - `getApiError()` helper for consistent error extraction
- Individual API modules in `src/api/` (auth, items, outfits, ai, etc.)

### Auth Flow
- `useAuthStore` handles auth state with `persist` middleware
- `hasHydrated` flag prevents flash of unauthenticated content on reload
- `ProtectedRoute` and `PublicRoute` wrappers in `App.tsx` handle route protection
- Tokens stored in localStorage under `fitcheck_auth_tokens`

### Routing Structure
- Public routes: `/`, `/about`, `/terms`, `/privacy`
- Auth routes: `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`
- Protected routes: `/dashboard`, `/wardrobe`, `/outfits`, `/calendar`, `/recommendations`, `/try-on`, `/gamification`, `/profile`
- Public share route: `/shared/outfits/:id`

### Component Organization
- `src/components/ui/` - shadcn/ui primitives (Button, Dialog, Input, etc.)
- `src/components/layout/` - AppLayout, AuthLayout, Sidebar
- `src/components/[feature]/` - Feature-specific components (wardrobe, outfits, calendar, etc.)
- `src/pages/` - Route page components

### Path Aliases
Configured in both `vite.config.ts` and `tsconfig.json`:
```typescript
@/* → src/*
@/components/* → src/components/*
@/api/* → src/api/*
@/stores/* → src/stores/*
@/lib/* → src/lib/*
@/hooks/* → src/hooks/*
@/types/* → src/types/*
@/pages/* → src/pages/*
```

## Key Patterns

### Adding New API Endpoints
1. Add function to appropriate `src/api/*.ts` module
2. Use `apiClient` from `@/api/client`
3. Response type should match backend Pydantic models

### Adding New Pages
1. Create page component in `src/pages/[feature]/`
2. Add route in `App.tsx` (wrap with `ProtectedRoute` if auth required)
3. Add navigation link in sidebar/nav components

### Feature Components
Follow the pattern: component receives data via props, emits events via callbacks:
```tsx
export function ItemCard({ item, onSelect, onEdit }: ItemCardProps) { }
```

## Environment Variables

Required in `.env.local`:
- `VITE_API_URL` or `VITE_API_BASE_URL` - Backend API URL (defaults to `http://localhost:8000`)
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key

## Backend Integration

Backend runs on port 8000. Vite dev server proxies `/api` requests to the backend automatically.

Backend API docs available at `http://localhost:8000/docs` when running locally.

## Commit Convention

Use conventional commits: `type: description`
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
