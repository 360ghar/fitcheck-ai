# Feature Implementation: Core Features

## Overview

This document describes the implemented core features across wardrobe, outfits, planning, recommendations, and sharing.

## 1. Wardrobe Management

### UI (Frontend)

- **Wardrobe Page:** `frontend/src/pages/wardrobe/WardrobePage.tsx`
  - Filtering + sorting via `frontend/src/components/wardrobe/FilterPanel.tsx`
  - Upload + AI extraction via `frontend/src/components/wardrobe/ItemUpload.tsx`
  - Item details via `frontend/src/components/wardrobe/ItemDetailModal.tsx`
  - Multi-select state via `frontend/src/stores/wardrobeStore.ts`

### API (Backend)

- `backend/app/api/v1/items.py`
  - `POST /api/v1/items/upload` (upload images + optional extraction payload)
  - CRUD: `GET/POST/PUT/DELETE /api/v1/items`
  - Actions: favorite, wear, categorize, image management

### AI (Server-Side via Backend API)

Item extraction uses the Backend AI API to produce structured JSON:
- Implementation: `backend/app/agents/item_extraction_agent.py`
- Endpoint: `POST /api/v1/ai/extract-items`
- Supports multiple providers: Gemini, OpenAI, or custom proxy (per-user configurable)

## 2. Outfit Builder + Visualization

### UI (Frontend)

- **Outfits Page:** `frontend/src/pages/outfits/OutfitsPage.tsx`
  - Create outfits: `frontend/src/components/outfits/OutfitCreateDialog.tsx`
  - Generate visualization: `frontend/src/stores/outfitStore.ts` integrates with backend AI generation API
  - Share outfits: `frontend/src/components/social/ShareOutfitDialog.tsx`
  - Public view: `frontend/src/pages/shared/SharedOutfitPage.tsx`

### API (Backend)

- `backend/app/api/v1/outfits.py`
  - CRUD: `GET/POST/PUT/DELETE /api/v1/outfits`
  - Actions: favorite, wear, duplicate, add/remove items
  - Sharing: `POST /api/v1/outfits/{outfit_id}/share` and public read `GET /api/v1/outfits/public/{outfit_id}`
  - Generation tracking: `POST /api/v1/outfits/{outfit_id}/generate` creates a record; the image is generated client-side and uploaded via `POST /api/v1/outfits/{outfit_id}/images`

### AI (Server-Side via Backend API)

Outfit visualization uses the Backend AI API:
- Implementation: `backend/app/agents/image_generation_agent.py`
- Endpoint: `POST /api/v1/ai/generate-outfit`
- Supports multiple providers: Gemini, OpenAI, or custom proxy (per-user configurable)

## 3. Planning & Calendar

### UI (Frontend)

- **Calendar Page:** `frontend/src/pages/calendar/CalendarPage.tsx`
  - Calendar UI: `frontend/src/components/calendar/*`
  - Assign/unassign outfits to events, and show weather context

### API (Backend)

- `backend/app/api/v1/calendar.py`
  - `POST /api/v1/calendar/connect` (MVP stores a connection record)
  - `GET /api/v1/calendar/events`
  - `POST /api/v1/calendar/events` (create local events)
  - `POST/DELETE /api/v1/calendar/events/{event_id}/outfit`

## 4. Recommendations

### UI (Frontend)

- `frontend/src/pages/recommendations/RecommendationsPage.tsx`

### API (Backend)

- `backend/app/api/v1/recommendations.py`
  - Wardrobe gaps, style suggestions, similar items, weather suggestions, shopping recommendations, and rating capture

## 5. Gamification (MVP)

### UI (Frontend)

- `frontend/src/pages/gamification/GamificationPage.tsx`
- `frontend/src/components/gamification/Leaderboard.tsx`

### API (Backend)

- `backend/app/api/v1/gamification.py`
  - Streak, achievements, leaderboard (derived from streaks)
