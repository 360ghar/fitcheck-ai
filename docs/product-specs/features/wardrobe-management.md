# Feature: Wardrobe Management

## Overview

Wardrobe Management is the foundational feature of FitCheck AI, allowing users to build, organize, and manage their digital wardrobe. Users can upload clothing photos, use AI to extract individual items, categorize items with tags, and browse their collection with powerful filtering capabilities.

## User Value

- **Complete Visibility:** See all owned items in one place
- **Time Savings:** AI-powered extraction eliminates manual entry
- **Better Organization:** Smart categorization and tagging
- **Informed Decisions:** Analytics and insights into wardrobe usage
- **Reduced Clutter:** Identify duplicates and underutilized items

## Functional Requirements

### 1. Upload Clothing Items

**Priority:** P0 (MVP)

**Description:** Users can upload single or multiple photos of their clothing items to build their virtual wardrobe.

**Requirements:**

**File Upload:**
- Support formats: JPG, PNG, WEBP
- Maximum file size: 10MB per image
- Maximum batch size: 20 images per upload
- Progress indicator for each image
- Drag-and-drop support
- Camera capture option (mobile)

**Image Processing:**
- Automatic image compression (max 2MB for storage)
- Background removal option
- AI enhancement for poor quality photos
- Aspect ratio normalization (preserve original ratio)

**Validation:**
- Validate file type before upload
- Check file size limits
- Verify image is not corrupt
- Alert user for invalid files

**API Endpoints:**
```
POST /api/v1/items/upload
- Upload one or more images to storage (no item record created yet)
- Request: multipart/form-data
  - files: List of image files
- Response: 202 Accepted
  - upload_id: string
  - status: "completed"
  - uploaded_count: number
  - images: List<uploaded_image>
    - image_url: string
    - thumbnail_url: string
    - storage_path: string

Then create items with extracted metadata:

POST /api/v1/items
- Request: JSON
  - name, category, colors, ... (from AI extraction + user edits)
  - images: List<{image_url, thumbnail_url, storage_path, is_primary}>
```

**Acceptance Criteria:**
- [ ] User can upload 1-20 images in a single request
- [ ] Progress indicator shown for each image
- [ ] Invalid files are rejected with clear error message
- [ ] Images are compressed automatically
- [ ] Upload is cancellable mid-process
- [ ] Success message shows number of uploaded items
- [ ] Uploaded images are immediately visible in wardrobe

**Error Handling:**
- `400 Invalid File Type`: File format not supported
- `413 Payload Too Large`: File exceeds size limit
- `415 Unsupported Media Type`: Not an image file
- `503 Service Unavailable`: Upload service temporarily unavailable

---

### 2. AI Item Extraction

**Priority:** P0 (MVP)

**Description:** Automatically detect and extract individual clothing items from uploaded photos containing multiple pieces.

**Requirements:**

**AI Processing:**
- Primary multi-upload path: async **batch job** + SSE (`POST /api/v1/ai/batch-extract-multipart` on web; `POST /api/v1/ai/batch-extract` JSON base64 on Flutter)
- One-shot helpers still available: `POST /api/v1/ai/extract-items`, `POST /api/v1/ai/generate-product-image`
- Providers: Gemini, OpenAI, or custom proxy (configurable per user)
- Categories: tops, bottoms, shoes, accessories, outerwear, etc.
- Detection accuracy target: >85% on clear, well-lit photos

**Extraction Types:**
- Single item from single photo
- Multiple items from single photo
- Batch extraction for multiple photos (1–50)

**Client prepare:**
- Optional compress before AI upload: longest edge ≤ ~1568px, JPEG quality ~0.85
- Originals kept for wardrobe save if studio images are not ready yet

**User Review:**
- Review as soon as items exist (do not block on full studio generation)
- Edit name, category, colors, tags; exclude or delete items
- Studio product images stream in via SSE; regenerate failed/unsatisfactory images
- Save can use studio image or original photo mid-generation

**Confidence Scoring:**
- Display confidence level for each extraction (0-100%)
- Flag low-confidence extractions for review
- Suggest manual review for scores <70%

**API Endpoints:**
```
POST /api/v1/ai/batch-extract-multipart   # web preferred (binary files)
POST /api/v1/ai/batch-extract             # JSON base64 (Flutter / legacy)
GET  /api/v1/ai/batch-extract/{job_id}/events
GET  /api/v1/ai/batch-extract/{job_id}/status
POST /api/v1/ai/batch-extract/{job_id}/cancel

Then persist:
POST /api/v1/items/upload
POST /api/v1/items
```

**Acceptance Criteria:**
- [x] AI extracts items from single- and multi-photo uploads
- [x] User can review and edit before save
- [x] Low-confidence extractions are flagged
- [x] Multiple items can be extracted from one photo
- [x] Progress streams over SSE; job can continue after soft-closing the dialog

**Error Handling:**
- `400 Invalid Image`: Image cannot be processed
- `422 Unprocessable Entity`: No items detected in image
- `429` / rate limit: daily extraction or generation caps
- `503 AI Service Unavailable`: AI processing temporarily down

---

### 2.1 Multi-Item Extraction with Product Image Generation

**Priority:** P0 (MVP Enhancement)

**Description:** Batch flow that detects clothing items in one or more photos and generates clean, e-commerce style product images for each item. Extraction and generation **overlap**: as soon as items from an image are detected, product generation for those items starts while other images may still be extracting.

**Pipeline:**

**Step 1: Multi-Item Detection (batch job)**
- Analyzes each uploaded image (parallel extracts)
- For each item: category/sub-category, colors, material, pattern, brand, bounding box, detailed description, confidence, person labels when relevant

**Step 2: Product Image Generation (overlapped)**
- For each detected item, generates a studio product photo (white background, isolated item)
- Continuous concurrent pool (up to `generation_batch_size`, max 5) — not a hard barrier after all extracts
- SSE events: `item_generation_complete` / `item_generation_failed` as each finishes

**User Flow:**
1. User selects photos (outfit, flat lay, multi-image batch)
2. Web compresses and uploads via multipart; job returns `job_id` + SSE URL
3. UI shows extract progress; review can open when first items exist
4. Studio images fill in progressively; user edits metadata / excludes items
5. User saves: uploads images + creates wardrobe rows (`/items/upload`, `/items`)

**Key Components (web):**
- `BatchExtractionFlow.tsx` — primary orchestration (`ItemUpload` re-export)
- `useBatchExtraction` / `useBatchSSE` — job state + SSE
- `frontend/src/api/batch.ts` — start (multipart + JSON), status, cancel
- `image-compress.ts`, `crop-from-bounding-box.ts` — upload compress + review crops
- `ExtractedItemsGrid.tsx` / `ExtractedItemCard.tsx` — review UI
- App-level `JobPill` + `jobUiStore` — background progress when dialog is closed
- Backend: `batch_processing.py`, `batch_extraction_service.py`, `batch_job_service.py`

**Acceptance Criteria:**
- [x] AI detects multiple items from outfit / multi-item photos
- [x] Each item can get a product-style generated image
- [x] Generation may start before all images finish extracting
- [x] User can review and edit before saving
- [x] User can delete/exclude unwanted items and regenerate images
- [x] Save works mid-generation (studio or original photo)
- [x] Each saved item is a separate wardrobe entry

**Error Handling:**
- No items detected: message + retry with clearer photo
- Low confidence (&lt;70%): review badge
- Image generation fails: mark failed, allow retry; originals may still save
- All generations fail: still allow save with source photos when available

---

### 3. Manual Item Entry

**Priority:** P1

**Description:** Allow users to manually add clothing items when they don't have a photo available.

**Requirements:**

**Entry Form:**
- Required fields: Item name, Category
- Optional fields: Brand, Color, Size, Purchase date, Price, Purchase location, Tags
- Photo upload (optional)
- Custom notes field

**Category Selection:**
- Pre-defined categories: Tops, Bottoms, Shoes, Accessories, Outerwear, Swimwear, Activewear, Sleepwear, Underwear, Other
- Allow custom category creation

**Tag System:**
- Add multiple tags per item
- Auto-complete suggestions based on existing tags
- Common tags: Summer, Winter, Casual, Formal, Work, Workout, Vintage, New, Favorite

**Duplicate Detection:**
- Check for visually similar items (using image embeddings if photo provided)
- Check for similar descriptions
- Alert user if potential duplicate detected
- Allow user to confirm or dismiss

**API Endpoints:**
```
POST /api/v1/items
- Create new item manually
- Request: JSON
  - name: string (required)
  - category: string (required)
  - brand?: string
  - colors?: List<string>
  - size?: string
  - purchase_date?: ISO8601 date
  - price?: number
  - purchase_location?: string
  - tags?: List<string>
  - notes?: string
  - image?: file
- Response: 201 Created
  - item: item_object
```

**Acceptance Criteria:**
- [ ] User can add item without photo
- [ ] Form validates required fields
- [ ] User can select from pre-defined categories
- [ ] Tags support auto-complete
- [ ] Duplicate detection works for items with photos
- [ ] Item is saved and immediately visible in wardrobe

**Error Handling:**
- `400 Validation Error`: Missing required fields or invalid data
- `409 Conflict`: Duplicate item detected (with option to override)

---

### 4. Smart Categorization

**Priority:** P0 (MVP)

**Description:** Automatically categorize and tag items using AI to save users time and ensure consistency.

**Requirements:**

**Category Detection:**
- Auto-detect: Tops, Bottoms, Shoes, Accessories, Outerwear, Swimwear, Activewear
- Sub-categories: T-shirts, Blouses, Jeans, Sneakers, Handbags, etc.
- Use Backend AI API for extraction and server-side heuristics for derived metadata

**Color Extraction:**
- Extract primary and secondary colors
- Use standard color palette (RGB, Hex)
- Map to common color names: Red, Blue, Black, White, Navy, Burgundy, etc.
- Detect color patterns: Solid, Striped, Plaid, Floral

**Style Detection:**
- Detect style attributes: Casual, Formal, Business, Athletic, Bohemian, Minimalist
- Detect material patterns: Denim, Cotton, Wool, Silk, Leather

**Seasonal Tagging:**
- Auto-tag based on style: Summer (shorts, t-shirts), Winter (coats, sweaters)
- All-season items: Jeans, basic tops

**User Override:**
- Allow users to change AI-suggested categories and tags
- Learn from user corrections
- Improve accuracy over time

**API Endpoints:**
```
POST /api/v1/items/{id}/categorize
- Run AI categorization on item
- Response: 200 OK
  - category: string
  - sub_category: string
  - colors: List<string>
  - style: string
  - materials: List<string>
  - seasonal_tags: List<string>
  - confidence: number
```

```
PUT /api/v1/items/{id}/categories
- Update item categories (user override)
- Request: JSON
  - category: string
  - sub_category?: string
  - colors?: List<string>
  - style?: string
  - materials?: List<string>
  - seasonal_tags?: List<string>
- Response: 200 OK
  - item: updated_item_object
```

**Acceptance Criteria:**
- [ ] AI categorizes items with >85% accuracy
- [ ] Primary and secondary colors are detected
- [ ] Seasonal tags are applied correctly
- [ ] User can override AI suggestions
- [ ] AI learns from corrections over time
- [ ] Categorization completes in <5 seconds

**Error Handling:**
- `404 Not Found`: Item does not exist
- `422 Unprocessable Entity`: Unable to categorize item (image too blurry, etc.)
- `503 AI Service Unavailable`: AI processing temporarily down

---

### 5. Browse and Filter Wardrobe

**Priority:** P0 (MVP)

**Description:** Provide powerful filtering and sorting capabilities to help users quickly find items in their wardrobe.

**Requirements:**

**Filter Options:**
- Category (tops, bottoms, shoes, etc.)
- Color (multi-select)
- Brand
- Season (summer, winter, all-season)
- Style (casual, formal, etc.)
- Condition (clean, dirty, in laundry, needs repair)
- Tags
- Price range
- Date added
- Purchase date

**Sort Options:**
- Name (A-Z, Z-A)
- Date added (newest first, oldest first)
- Price (high to low, low to high)
- Most worn
- Least worn
- Color name

**View Modes:**
- Grid view (thumbnails)
- List view (details)
- Compact view (small thumbnails)
- User preference saved

**Search:**
- Full-text search across: name, brand, tags, notes
- Search suggestions as user types
- Highlight matching terms

**Saved Filters:**
- Save frequently used filter combinations
- Quick access to saved filters
- Create, rename, delete saved filters

**API Endpoints:**
```
GET /api/v1/items
- Browse items with filters
- Query Parameters:
  - category: string (multi)
  - color: string (multi)
  - brand: string (multi)
  - season: string (multi)
  - style: string (multi)
  - condition: string (multi)
  - tags: string (multi)
  - min_price: number
  - max_price: number
  - added_after: ISO8601 date
  - added_before: ISO8601 date
  - search: string
  - sort: string
  - page: number
  - page_size: number
- Response: 200 OK
  - items: List<item_objects>
  - total: number
  - page: number
  - total_pages: number
```

```
POST /api/v1/filters
- Save filter combination
- Request: JSON
  - name: string
  - filters: object
- Response: 201 Created
  - filter_id: string
```

```
GET /api/v1/filters
- List saved filters
- Response: 200 OK
  - filters: List<filter_objects>
```

**Acceptance Criteria:**
- [ ] Users can filter by multiple criteria simultaneously
- [ ] Filter results update in real-time
- [ ] Sort options work correctly
- [ ] Search returns relevant results
- [ ] Saved filters can be quickly accessed
- [ ] View mode preference is persisted
- [ ] Filter combinations are preserved across sessions

**Error Handling:**
- `400 Bad Request`: Invalid filter parameters
- `404 Not Found`: Saved filter does not exist

---

### 6. Item Details and Editing

**Priority:** P0 (MVP)

**Description:** Allow users to view full details of each item and edit information as needed.

**Requirements:**

**Item Detail View:**
- Display item image (zoomable)
- Show all item metadata:
  - Name, category, sub-category
  - Brand, size, color(s)
  - Price, purchase date, location
  - Tags, notes
  - Condition status
  - Usage statistics (times worn, last worn date)

**Edit Capabilities:**
- Inline editing for all fields
- Add/remove photos (multiple photos per item)
- Update condition status
- Edit notes
- Add/remove tags

**History Tracking:**
- Track when item was added
- Track last edit date
- Track usage history (when worn, in which outfits)

**Delete with Confirmation:**
- Delete item from wardrobe
- Confirm with "Are you sure?" prompt
- Show warning: "This action cannot be undone"
- Option to confirm or cancel

**API Endpoints:**
```
GET /api/v1/items/{id}
- Get item details
- Response: 200 OK
  - item: item_detail_object
    - id: string
    - name: string
    - category: string
    - sub_category: string
    - images: List<image_urls>
    - brand: string
    - colors: List<string>
    - size: string
    - price: number
    - purchase_date: ISO8601 date
    - purchase_location: string
    - tags: List<string>
    - notes: string
    - condition: string
    - usage: {
        times_worn: number
        last_worn: ISO8601 date
        cost_per_wear: number
      }
    - created_at: ISO8601 date
    - updated_at: ISO8601 date
```

```
PUT /api/v1/items/{id}
- Update item details
- Request: JSON
  - name?: string
  - category?: string
  - sub_category?: string
  - brand?: string
  - colors?: List<string>
  - size?: string
  - price?: number
  - purchase_date?: ISO8601 date
  - purchase_location?: string
  - tags?: List<string>
  - notes?: string
  - condition?: string
- Response: 200 OK
  - item: updated_item_object
```

```
DELETE /api/v1/items/{id}
- Delete item
- Response: 204 No Content
```

```
POST /api/v1/items/{id}/images
- Add image to item
- Request: multipart/form-data
  - image: image file
- Response: 201 Created
  - item: updated_item_object
```

```
DELETE /api/v1/items/{id}/images/{image_id}
- Remove image from item
- Response: 200 OK
  - item: updated_item_object
```

**Acceptance Criteria:**
- [ ] Item detail view displays all metadata
- [ ] Image can be zoomed
- [ ] All editable fields can be updated
- [ ] Multiple photos can be added to an item
- [ ] Delete requires confirmation
- [ ] Usage statistics are accurate
- [ ] History tracking is complete

**Error Handling:**
- `404 Not Found`: Item does not exist
- `403 Forbidden`: User does not own this item
- `422 Unprocessable Entity`: Invalid data provided

---

### 7. Condition Tracking

**Priority:** P1

**Description:** Allow users to track the condition and maintenance status of their clothing items.

**Requirements:**

**Condition Statuses:**
- Clean (default)
- Dirty
- In Laundry
- Needs Repair
- Donate
- Discard

**Bulk Updates:**
- Select multiple items
- Update condition for all selected items
- Useful for marking multiple items as "in laundry" at once

**Filter by Condition:**
- Filter wardrobe to show only clean items
- Useful for creating outfits with available clothes

**Laundry Schedule:**
- Set laundry days (e.g., "Saturday laundry day")
- Get notification before laundry day
- Show items marked "dirty" that need washing

**Condition History:**
- Track condition changes over time
- Show last condition change date
- Help identify items needing frequent repair

**API Endpoints:**
```
PUT /api/v1/items/{id}/condition
- Update item condition
- Request: JSON
  - condition: string (clean|dirty|laundry|repair|donate|discard)
  - notes?: string
- Response: 200 OK
  - item: updated_item_object
```

```
POST /api/v1/items/condition/bulk
- Bulk update item conditions
- Request: JSON
  - item_ids: List<string>
  - condition: string
  - notes?: string
- Response: 200 OK
  - updated_count: number
```

```
GET /api/v1/items?condition=clean
- Filter items by condition
- Response: 200 OK
  - items: List<item_objects>
```

**Acceptance Criteria:**
- [ ] Users can change item condition status
- [ ] Multiple items can be updated at once
- [ ] Wardrobe can be filtered by condition
- [ ] Laundry day can be set
- [ ] Condition changes are tracked in history

**Error Handling:**
- `400 Bad Request`: Invalid condition value
- `404 Not Found`: One or more items do not exist

---

### 8. Duplicate Detection

**Priority:** P2

**Description:** Help users identify similar or duplicate items to aid in decluttering and wardrobe optimization.

**Requirements:**

**Visual Similarity:**
- Use image embeddings from Gemini Embeddings model
- Compare new items against existing wardrobe
- Calculate similarity score (0-100%)
- Show items with >70% similarity

**Text-Based Matching:**
- Match items with similar names, brands, colors
- Useful for items without photos

**Duplicate Groups:**
- Group similar items together
- Show side-by-side comparison
- Display which item is worn more frequently

**Decluttering Suggestions:**
- Recommend which duplicate to keep based on:
  - Usage frequency
  - Condition
  - Purchase price (keep more expensive?)
  - Date added (keep newer?)

**User Actions:**
- Mark item as "keep"
- Mark item as "donate"
- Mark item as "not a duplicate" (false positive)

**API Endpoints:**
```
GET /api/v1/items/duplicates
- Find duplicate items
- Query Parameters:
  - min_similarity: number (default: 0.7)
- Response: 200 OK
  - duplicate_groups: List<duplicate_group>
    - group_id: string
    - items: List<item_with_similarity>
      - item: item_object
      - similarity_score: number
    - recommendation: {
        keep_item_id: string
        reason: string
      }
```

```
POST /api/v1/items/{id}/duplicate-action
- Resolve duplicate status
- Request: JSON
  - action: "keep"|"donate"|"not_duplicate"
- Response: 200 OK
```

**Acceptance Criteria:**
- [ ] AI detects visually similar items (>70% similarity)
- [ ] Duplicate groups are displayed together
- [ ] Recommendations are provided based on usage data
- [ ] User can confirm or dismiss duplicates
- [ ] False positives can be marked as "not a duplicate"

**Error Handling:**
- `422 Unprocessable Entity`: Unable to calculate similarity

---

## Database Schema

### Items Table

```sql
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    brand VARCHAR(100),
    colors JSONB DEFAULT '[]'::jsonb,
    size VARCHAR(50),
    price DECIMAL(10, 2),
    purchase_date DATE,
    purchase_location VARCHAR(255),
    tags JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    condition VARCHAR(20) DEFAULT 'clean',
    usage_times_worn INTEGER DEFAULT 0,
    usage_last_worn TIMESTAMP,
    cost_per_wear DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_items_condition ON items(condition);
CREATE INDEX idx_items_tags ON items USING GIN(tags);
CREATE INDEX idx_items_created_at ON items(created_at DESC);
```

### Item Images Table

```sql
CREATE TABLE item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_item_images_item_id ON item_images(item_id);
```

### Vector Store (Pinecone)

```python
# Item embeddings for similarity search
{
    "id": "item_uuid",
    "values": [0.1, 0.2, 0.3, ...],  # 768-dim embedding
    "metadata": {
        "user_id": "user_uuid",
        "category": "tops",
        "colors": ["blue", "white"],
        "style": "casual"
    }
}
```

---

## Frontend Components

### WardrobeView.tsx
Main view for browsing and filtering items

### ItemCard.tsx
Individual item component for grid/list view

### ItemDetailView.tsx
Detailed view for single item with all metadata

### UploadModal.tsx
Modal for uploading new items

### ItemExtractionReview.tsx
Review and confirm AI-extracted items

### FilterPanel.tsx
Filter and sort controls

### BulkActions.tsx
Bulk update operations for multiple items

---

## Success Metrics

- **Upload Success Rate:** >95%
- **AI Extraction Accuracy:** >85%
- **Category Accuracy:** >90%
- **Duplicate Detection Precision:** >80%
- **User Satisfaction:** 4.5/5 stars for wardrobe management features

---

## Future Enhancements

- Optical character recognition (OCR) for reading brand tags
- 3D item modeling for better visualization
- Automatic price estimation for unlabeled items
- AI-powered styling advice based on wardrobe composition
- Integration with clothing care labels database
