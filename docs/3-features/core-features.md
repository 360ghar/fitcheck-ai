 # Feature Implementation: Core Features
 
 ## Overview
 
 This document details the implementation of core wardrobe and outfit features.
 
 ## 1. Wardrobe Management
 
 ### WardrobeGrid.tsx
 - Uses `react-window` for virtualization of large wardrobes
 - Infinite scroll implementation with TanStack Query `useInfiniteQuery`
 - Drag-and-drop support for multi-selection
 - Responsive grid layout (Tailwind)
 
 ### ItemUpload.tsx
 - Supports multi-file upload
 - Integration with Putter.js for client-side compression
 - Progress bars for each file
 - Post-upload AI extraction review screen
 
 ### ItemFilters.tsx
 - Category, color, and tag filtering
 - Search bar with debounced input
 - Saved filter presets
 
 ## 2. Outfit Builder
 
 ### SelectionCanvas.tsx
 - Visual workspace for selecting items
 - Z-index management for layering visualization
 - Quick-remove and replace actions
 
 ### AIGenerator.tsx
 - Triggers background job for image generation
 - Polling or WebSocket for real-time status updates
 - Comparison view for generated variations
 
 ## 3. Planning & Organization
 
 ### OutfitCalendar.tsx
 - Month/Week/Day views using `fullcalendar` or custom implementation
 - Drag-and-drop outfits onto dates
 - Integration with local weather API for "Safe to Wear" indicators
 
 ## State Management
 
 ### wardrobeStore.ts
 ```typescript
 interface WardrobeState {
   items: Item[];
   selectedItems: string[];
   filters: FilterOptions;
   toggleSelection: (id: string) => void;
   clearSelection: () => void;
   setFilters: (filters: FilterOptions) => void;
 }
 ```
 
 ## Workflows
 
 ### AI Outfit Generation Workflow
 1. User selects 2-5 items in `WardrobeGrid`
 2. User clicks "Generate Outfit"
 3. Backend receives request, creates `outfit` record (status: pending)
 4. Backend triggers Pydantic AI agent
 5. Agent calls Gemini 3 Pro with item images and body profile
 6. Image generated, uploaded to Supabase Storage
 7. `outfit` record updated with image URL and status: completed
 8. Frontend receives update via polling/real-time
 9. User reviews and saves to collection
 
 ## Error Handling
 - **AI Timeout:** Show "Generation taking longer than expected" message, continue in background
 - **Conflicting Items:** UI warning when selecting two tops/bottoms
 - **Upload Limits:** Client-side check for max 20 images at once
