 # Implementation: Workflows
 
 ## Overview
 
 Detailed user flows and state management transitions for key features.
 
 ## 1. Wardrobe Onboarding
 
 ```mermaid
 sequenceDiagram
     User->>UI: Upload batch of photos
     UI->>Putter.js: Compress images
     UI->>API: POST /items/upload
     API->>Storage: Save originals
     API->>Agent: Extract items (Nano Banana Pro)
     Agent->>API: Found 5 items
     API->>VecDB: Generate & save embeddings
     API->>UI: Return extraction results
     UI->>User: Show review screen
     User->>UI: Confirm tags/categories
     UI->>API: POST /items/confirm
     API->>DB: Mark items as confirmed
 ```
 
 ## 2. AI Try-On Generation
 
 1. **Selection:** User selects 1 top and 1 bottom in the Wardrobe.
 2. **Initiation:** User clicks "Try on me".
 3. **Config:** User selects pose (front) and lighting (natural).
 4. **Request:** Client calls `POST /outfits/generate`.
 5. **Processing:**
    - Backend fetches item images and user body profile.
    - Prompts Gemini 3 Pro with images + profile details.
    - Monitors generation status.
 6. **Completion:** Image is saved to Supabase storage, metadata saved to DB.
 7. **Notification:** Client receives update via real-time subscription.
 8. **Display:** Generation is shown in a modal with "Save" or "Discard" options.
 
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
