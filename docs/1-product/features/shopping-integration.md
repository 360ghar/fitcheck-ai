# Feature: Shopping Integration

## Overview

Shopping Integration allows users to find items similar to what they own, try before buying with virtual visualization, track prices, and sell unused items.

## User Value

- **Smart Shopping:** Buy only what completes wardrobe
- **Try Before Buying:** Visualize with existing items
- **Save Money:** Price tracking and alerts
- **Reduce Waste:** Sell unused items
- **Sustainability:** Make ethical fashion choices

## Functional Requirements

### 1. Find Similar Items

**Priority:** P1

**Description:** Search for items similar to what user owns or wants.

**Requirements:**

**Search Methods:**
- Upload photo of desired item
- Select item from wardrobe to find similar
- Search by keywords, brand, style
- Search by color

**AI Image Search:**
- Use Gemini Embeddings to find visually similar items
- Search across partner retailer databases
- Show multiple results from different retailers
- Similarity score (0-100%)

**Filter Options:**
- Price range
- Brand
- Category
- Color
- Size
- Material
- Rating

**Comparison View:**
- Compare similar items side-by-side
- Show price, rating, material, sizing info
- Direct links to product pages

**Retailer Partnerships:**
- Partner with major retailers (Nordstrom, ASOS, Zara, etc.)
- Real-time inventory availability
- Affiliate commissions (5% per purchase)

**Wishlist Integration:**
- Add items to wishlist from search results
- Track wishlist items
- Get notified of price drops

**API Endpoints:**

```
POST /api/v1/shopping/search/similar
- Find items similar to image
- Request: multipart/form-data
  - image: image file
  - category?: string
  - max_price?: number
  - limit: number (default: 20)
- Response: 200 OK
  - results: {
        query_image: string
        similar_items: List<shopping_item>
          - id: string
          - name: string
          - brand: string
          - image_url: string
          - price: number
          - retailer: string
          - similarity_score: number
          - product_url: string
          - in_stock: boolean
      }
```

```
GET /api/v1/shopping/search
- Text-based search
- Query Parameters:
  - q: string (search query)
  - category?: string
  - brand?: string
  - min_price?: number
  - max_price?: number
  - color?: string
  - sort: "relevance"|"price_low"|"price_high"|"rating"
  - page: number
- Response: 200 OK
  - results: {
        items: List<shopping_item>
        total: number
        page: number
        total_pages: number
    }
```

```
POST /api/v1/shopping/wishlist
- Add item to wishlist
- Request: JSON
  - shopping_item_id: string
  - notes?: string
- Response: 201 Created
  - wishlist_item: wishlist_item_object
```

```
GET /api/v1/shopping/wishlist
- View wishlist
- Response: 200 OK
  - wishlist: List<wishlist_item>
```

**Acceptance Criteria:**
- [ ] Image search finds visually similar items
- [ ] Text search returns relevant results
- [ ] Filters work correctly
- [ ] Retailer links are functional
- [ ] Wishlist is saved and accessible
- [ ] Similarity scores are accurate

**Error Handling:**
- `400 Bad Request`: Invalid search parameters
- `404 Not Found`: No results found
- `503 Service Unavailable`: Retailer API down

---

### 2. Virtual Shopping

**Priority:** P2

**Description:** Try potential purchases with existing wardrobe before buying.

**Requirements:**

**Virtual Try-On:**
- Select item from shopping results
- Generate outfit combining with wardrobe items
- See realistic visualization
- Try multiple combinations

**"Try with" Suggestions:**
- AI suggests wardrobe items that match shopping item
- Show multiple outfit options
- "Complete the Look" with existing items

**Save for Later:**
- Save virtual outfit
- Add to wishlist
- Compare with other potential purchases

**Purchase Decision Support:**
- Calculate cost-per-wear potential
- Show how many outfits can be created
- Compare to similar items already owned

**Buy Button:**
- Direct link to purchase page
- Affiliate link (for commission tracking)
- Return policy info (if available)

**API Endpoints:**

```
POST /api/v1/shopping/virtual-try
- Generate outfit with shopping item
- Request: JSON
  - shopping_item_id: string
  - wardrobe_item_ids?: List<string>
  - pose: string (default: "front")
- Response: 202 Accepted
  - generation_id: string
```

```
GET /api/v1/shopping/virtual-try/{generation_id}
- Check virtual try-on status
- Response: 200 OK
  - status: string
  - image_url: string (if completed)
  - items_used: List<item_summary>
```

```
POST /api/v1/shopping/virtual-try/suggestions
- Get "try with" suggestions
- Request: JSON
  - shopping_item_id: string
- Response: 200 OK
  - suggestions: {
        shopping_item: shopping_item_summary
        suggested_items: List<item_object>
        complete_looks: List<outfit_suggestion>
      }
```

**Acceptance Criteria:**
- [ ] Virtual try-on generates accurate visualization
- [ ] Wardrobe items are matched correctly
- [ ] "Try with" suggestions are helpful
- [ ] Cost-per-wear is calculated
- [ ] Purchase link is functional

**Error Handling:**
- `404 Not Found`: Shopping item not available
- `422 Unprocessable Entity`: Cannot generate outfit
- `503 AI Service Unavailable`: Generation engine down

---

### 3. Price Tracking

**Priority:** P1

**Description:** Track prices on wishlist items and get notified of price drops.

**Requirements:**

**Price History:**
- Track price changes over time
- Show price history graph
- Calculate average price
- Show lowest/highest prices

**Price Alerts:**
- Set target price
- Get notified when price drops to/below target
- Daily/weekly price summary email
- In-app notifications

**Price Comparison:**
- Compare prices across retailers
- Show cheapest option
- Alert when cheaper option available

**Auto-Tracking:**
- Automatically track wishlist items
- Check prices daily
- Update price history

**Bulk Actions:**
- Set price alerts for multiple items
- Remove items from wishlist
- Mark items as purchased

**Purchase Tracking:**
- Mark item as purchased
- Add to wardrobe
- Track purchase history

**API Endpoints:**

```
POST /api/v1/shopping/wishlist/{item_id}/price-alert
- Set price alert
- Request: JSON
  - target_price: number
  - notify_via: "email"|"push"|"both"
- Response: 200 OK
  - alert: price_alert_object
```

```
GET /api/v1/shopping/wishlist/{item_id}/price-history
- Get price history
- Response: 200 OK
  - history: {
        item_id: string
        price_history: List<price_point>
          - price: number
          - recorded_at: timestamp
          - retailer: string
        current_price: number
        lowest_price: number
        highest_price: number
        average_price: number
        price_change_percent: number
      }
```

```
GET /api/v1/shopping/price-comparison/{item_id}
- Compare prices across retailers
- Response: 200 OK
  - comparison: {
        item_id: string
        retailers: List<retailer_price>
          - name: string
          - price: number
          - in_stock: boolean
          - url: string
        cheapest: retailer_price
        price_range: {min, max}
      }
```

```
POST /api/v1/shopping/wishlist/{item_id}/mark-purchased
- Mark item as purchased
- Request: JSON
  - purchase_price: number
  - purchase_date: ISO8601 date
  - notes?: string
- Response: 200 OK
  - purchase: {
        id: string
        shopping_item: shopping_item_summary
        purchase_price: number
        purchase_date: date
      }
```

**Acceptance Criteria:**
- [ ] Price history is tracked accurately
- [ ] Price alerts trigger correctly
- [ ] Price comparisons are current
- [ ] Purchases are tracked
- [ ] Notifications are sent as configured

**Error Handling:**
- `404 Not Found`: Wishlist item not found
- `400 Bad Request`: Invalid target price

---

### 4. Sustainability Score

**Priority:** P2

**Description:** Show sustainability ratings for shopping items to help users make ethical choices.

**Requirements:**

**Sustainability Data:**
- Score items 0-100 on sustainability
- Factors:
  - Materials (organic, recycled, sustainable)
  - Production (ethical labor, low carbon footprint)
  - Brand reputation (sustainability commitments)
  - Longevity (quality, durability)
  - Certifications (Fair Trade, GOTS, etc.)

**Score Breakdown:**
- Show individual factor scores
- Explain how score was calculated
- Compare to category average

**Certification Display:**
- Show relevant certifications (Fair Trade, Organic, etc.)
- Explain what each certification means
- Links to certification details

**Material Information:**
- Show material composition
- Highlight sustainable materials
- Warn about problematic materials

**Brand Sustainability:**
- Show brand's overall sustainability rating
- Show brand's environmental commitments
- Link to brand's sustainability report

**Shopping Filters:**
- Filter by sustainability score (min score)
- Filter by certifications
- Filter by sustainable materials

**Educational Content:**
- Explain sustainability factors
- Tips for sustainable shopping
- Explain certification labels

**API Endpoints:**

```
GET /api/v1/shopping/items/{item_id}/sustainability
- Get sustainability score
- Response: 200 OK
  - sustainability: {
        overall_score: number
        breakdown: {
            materials_score: number
            production_score: number
            brand_score: number
            longevity_score: number
        }
        certifications: List<certification>
          - name: string
          - description: string
          - url: string
        materials: List<material>
          - name: string
          - is_sustainable: boolean
          - percentage: number
        brand_sustainability: {
            brand_name: string
            overall_score: number
            commitments: List<string>
        }
        educational_tips: List<string>
      }
```

```
GET /api/v1/shopping/search?sustainability_score={min_score}
- Filter by sustainability
- Response: 200 OK
  - results: shopping_search_results
```

**Acceptance Criteria:**
- [ ] Sustainability scores are calculated accurately
- [ ] Score breakdown is clear
- [ ] Certifications are displayed
- [ ] Material information is accurate
- [ ] Educational content is helpful

**Error Handling:**
- `404 Not Found`: Item not found
- `503 Service Unavailable`: Sustainability data unavailable

---

### 5. Sell Unworn Items

**Priority:** P2

**Description:** Help users declutter by listing unworn items for sale or swap.

**Requirements:**

**Sell Features:**
- List items from wardrobe for sale
- Set price (suggested based on original price)
- Set condition
- Write description
- Upload photos

**Integration with Resale Platforms:**
- Poshmark
- Depop
- Mercari
- ThredUp

**Listing Management:**
- Sync listings across platforms
- Track views and offers
- Update inventory
- Mark as sold

**Pricing Suggestions:**
- Suggest price based on:
  - Original price
  - Condition
  - Brand demand
  - Market prices
- Show comparable sold items

**Sales Tracking:**
- Track sales history
- Calculate total earnings
- Track cost savings (money recouped)

**Swap Feature:**
- List items for swap (no money)
- Browse swap listings
- Propose swaps with other users
- Accept/reject proposals

**Impact Analytics:**
- Show money earned
- Show CO2 saved by extending item life
- Show wardrobe utilization improvement

**API Endpoints:**

```
POST /api/v1/wardrobe/items/{item_id}/list-for-sale
- List item for sale
- Request: JSON
  - price: number
  - condition: string
  - description: string
  - platforms: List<string>
- Response: 201 Created
  - listing: sale_listing_object
    - id: string
    - item_id: string
    - price: number
    - condition: string
    - description: string
    - platforms: List<platform_listing>
      - platform: string
      - listing_id: string
      - url: string
    - created_at: timestamp
```

```
GET /api/v1/wardrobe/items/sales
- View sales listings
- Query Parameters:
  - status: "active"|"sold"|"withdrawn"
- Response: 200 OK
  - listings: List<sale_listing>
```

```
PUT /api/v1/wardrobe/items/sales/{listing_id}
- Update listing
- Request: JSON
  - price?: number
  - description?: string
- Response: 200 OK
  - listing: updated_listing
```

```
DELETE /api/v1/wardrobe/items/sales/{listing_id}
- Withdraw listing
- Response: 204 No Content
```

```
POST /api/v1/wardrobe/items/sales/{listing_id}/mark-sold
- Mark item as sold
- Request: JSON
  - sale_price: number
  - platform: string
- Response: 200 OK
  - sale: sale_record_object
```

```
POST /api/v1/wardrobe/items/{item_id}/list-for-swap
- List item for swap
- Request: JSON
  - description: string
- Response: 201 Created
  - swap_listing: swap_listing_object
```

```
GET /api/v1/wardrobe/items/swap-listings
- Browse swap listings
- Response: 200 OK
  - listings: List<swap_listing>
```

```
POST /api/v1/wardrobe/items/swap/{listing_id}/propose
- Propose swap
- Request: JSON
  - my_item_id: string
  - message: string
- Response: 201 Created
  - proposal: swap_proposal_object
```

**Acceptance Criteria:**
- [ ] Items can be listed for sale
- [ ] Listings sync to resale platforms
- [ ] Pricing suggestions are reasonable
- [ ] Sales are tracked
- [ ] Swap functionality works
- [ ] Impact metrics are accurate

**Error Handling:**
- `400 Bad Request`: Invalid listing data
- `404 Not Found`: Item not found
- `409 Conflict`: Already listed
- `503 Service Unavailable`: Resale platform API down

---

## Database Schema

### Shopping Wishlist Table

```sql
CREATE TABLE shopping_wishlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shopping_item_id VARCHAR(255) NOT NULL,
    retailer VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(100),
    image_url VARCHAR(500),
    price DECIMAL(10, 2),
    target_price DECIMAL(10, 2),
    notes TEXT,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    price_updated_at TIMESTAMP
);

CREATE INDEX idx_shopping_wishlist_user_id ON shopping_wishlist(user_id);
CREATE INDEX idx_shopping_wishlist_shopping_item_id ON shopping_wishlist(shopping_item_id);
```

### Price History Table

```sql
CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wishlist_item_id UUID NOT NULL REFERENCES shopping_wishlist(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL,
    retailer VARCHAR(100) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_price_history_wishlist_item_id ON price_history(wishlist_item_id);
CREATE INDEX idx_price_history_recorded_at ON price_history(recorded_at DESC);
```

### Purchase Tracking Table

```sql
CREATE TABLE purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wishlist_item_id UUID REFERENCES shopping_wishlist(id),
    shopping_item_id VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(100),
    purchase_price DECIMAL(10, 2) NOT NULL,
    purchase_date DATE NOT NULL,
    retailer VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_purchases_purchase_date ON purchases(purchase_date DESC);
```

### Sale Listings Table

```sql
CREATE TABLE sale_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL,
    condition VARCHAR(50),
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sale_listings_user_id ON sale_listings(user_id);
CREATE INDEX idx_sale_listings_item_id ON sale_listings(item_id);
CREATE INDEX idx_sale_listings_status ON sale_listings(status);
```

### Sale Listing Platforms Table

```sql
CREATE TABLE sale_listing_platforms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES sale_listings(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    external_listing_id VARCHAR(255),
    external_listing_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sale_listing_platforms_listing_id ON sale_listing_platforms(listing_id);
```

### Sales Records Table

```sql
CREATE TABLE sales_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES sale_listings(id),
    sale_price DECIMAL(10, 2) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    sold_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sales_records_listing_id ON sales_records(listing_id);
```

### Swap Listings Table

```sql
CREATE TABLE swap_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_swap_listings_user_id ON swap_listings(user_id);
CREATE INDEX idx_swap_listings_item_id ON swap_listings(item_id);
```

### Swap Proposals Table

```sql
CREATE TABLE swap_proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES swap_listings(id) ON DELETE CASCADE,
    proposer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    proposer_item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    message TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_swap_proposals_listing_id ON swap_proposals(listing_id);
CREATE INDEX idx_swap_proposals_proposer_id ON swap_proposals(proposer_id);
```

---

## Frontend Components

### ShoppingSearch.tsx
Search for shopping items

### SimilarItemsGrid.tsx
Display similar items from search

### VirtualTryOn.tsx
Try shopping item with wardrobe

### WishlistView.tsx
Manage wishlist items

### PriceAlertManager.tsx
Set and manage price alerts

### SustainabilityBadge.tsx
Display sustainability score

### SellItemForm.tsx
List item for sale

### SwapBrowse.tsx
Browse and propose swaps

---

## Success Metrics

- **Search Accuracy:** >85% relevance for image search
- **Conversion Rate:** 5% of wishlist items purchased
- **Price Alert Effectiveness:** 30% of alerts lead to purchases
- **Sales Success:** 10% of listed items sold within 30 days
- **User Satisfaction:** 4.2/5 stars for shopping features

---

## Future Enhancements

- AI-powered style suggestions for shopping
- Automatic outfit completion with shopping items
- Group buying (friends coordinate purchases)
- Virtual try-on with user's own photo
- Sustainability impact calculator
- Brand loyalty programs integration
- Size recommendation AI
- Return policy optimization
