# Implementation: UI Components

## Overview

This document highlights the key UI components and where core logic lives (frontend vs backend).

## Layout

- **Auth layout:** `frontend/src/components/layout/AuthLayout.tsx`
- **App layout:** `frontend/src/components/layout/AppLayout.tsx`

## Wardrobe

- **Page:** `frontend/src/pages/wardrobe/WardrobePage.tsx`
- **Upload:** `frontend/src/components/wardrobe/ItemUpload.tsx`
- **Filters:** `frontend/src/components/wardrobe/FilterPanel.tsx`
- **Item details:** `frontend/src/components/wardrobe/ItemDetailModal.tsx`

## Outfits

- **Page:** `frontend/src/pages/outfits/OutfitsPage.tsx`
- **Create dialog:** `frontend/src/components/outfits/OutfitCreateDialog.tsx`
- **Share dialog:** `frontend/src/components/social/ShareOutfitDialog.tsx`
- **Public share page:** `frontend/src/pages/shared/SharedOutfitPage.tsx`

## Planning (Calendar)

- **Page:** `frontend/src/pages/calendar/CalendarPage.tsx`
- **Components:** `frontend/src/components/calendar/*`

## Gamification

- **Page:** `frontend/src/pages/gamification/GamificationPage.tsx`
- **Leaderboard:** `frontend/src/components/gamification/Leaderboard.tsx`

## AI Integration (Server-Side)

AI processing is handled server-side via the Backend AI API:
- Item extraction (`POST /api/v1/ai/extract-items`)
- Outfit visualization (`POST /api/v1/ai/generate-outfit`)
- Product image generation (`POST /api/v1/ai/generate-product-image`)

Implementation:
- Backend Agents: `backend/app/agents/item_extraction_agent.py`, `backend/app/agents/image_generation_agent.py`
- AI Provider Service: `backend/app/services/ai_provider_service.py`
- AI Settings Service: `backend/app/services/ai_settings_service.py`
- Frontend API Client: `frontend/src/api/ai.ts`
- AI Settings UI: `frontend/src/components/settings/AISettingsPanel.tsx`

## Backend Services

- **Storage:** `backend/app/services/storage_service.py` (Supabase Storage uploads)
- **Embeddings:** `backend/app/services/ai_service.py` (Gemini embeddings)
- **Vectors:** `backend/app/services/vector_service.py` (Pinecone)
- **Weather:** `backend/app/services/weather_service.py`
