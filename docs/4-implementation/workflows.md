 # Implementation: Workflows
 
 ## Overview
 
 Detailed user flows and state management transitions for key features.
 
 ## 1. Wardrobe Onboarding
 
 ```mermaid
sequenceDiagram
    User->>UI: Upload batch of photos
    UI->>API: POST /api/v1/ai/extract-items (Backend AI extraction)
    API-->>UI: Extracted items with metadata
    UI->>User: Review/edit extracted fields
    UI->>API: POST /items/upload (store originals)
    API->>Storage: Save originals + thumbnails
    API->>UI: Return image URLs
    UI->>API: POST /items (create items + image URLs)
    API->>VecDB: Generate & save embeddings (gemini-embedding-001)
    API->>UI: Return created items
```
 
 ## 2. AI Try-On Generation
 
1. **Selection:** User selects 1 top and 1 bottom in the Wardrobe.
2. **Initiation:** User clicks "Try on me".
3. **Config:** User selects pose (front) and lighting (natural).
4. **Request:** Client calls `POST /api/v1/ai/generate-outfit` which generates the image server-side.
5. **Processing (server-side):**
   - Backend fetches outfit items and body profile (optional).
   - Backend generates an image using the AI provider service (Gemini, OpenAI, or custom).
6. **Completion:** Backend stores the generated image and returns the URL.
7. **Display:** Image is shown immediately; backend stores metadata for later retrieval.
 
 ## 3. Weather-Based Suggestions
 
 1. **Trigger:** User opens Dashboard.
 2. **Fetch:** Dashboard calls `GET /weather` and `GET /outfits/suggestions/weather`.
 3. **Logic:**
    - API identifies current temp and conditions.
    - Queries Wardrobe for items tagged with appropriate "Season".
    - Selects 3 outfits (1 Casual, 1 Work, 1 Outdoor).
 4. **UI:** Displays "Perfect for today's 65°F and Sunny" section.
 
 ## 4. Packing Assistant
 
 1. **Input:** User enters destination (Paris) and dates (May 5-10).
 2. **AI Analysis:**
    - Fetches Paris forecast for May.
    - Analyzes user's Wardrobe.
 3. **Generation:** Suggests 10 items that can create 15+ combinations.
 4. **Checklist:** Generates a checklist in the UI.
 5. **Tracking:** User checks off items as they pack; item status updates in DB.
