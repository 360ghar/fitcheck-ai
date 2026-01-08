# Feature: AI-Powered Recommendations

## Overview

AI-Powered Recommendations use machine learning to provide personalized style advice, suggest outfit combinations, identify wardrobe gaps, and improve over time based on user behavior.

## User Value

- **Personalized Style:** Recommendations that match personal taste
- **Discover New Looks:** Try combinations never considered
- **Smart Shopping:** Buy only what the wardrobe needs
- **Continuous Improvement:** AI learns and adapts over time
- **Confidence:** Trust AI's style suggestions

## Functional Requirements

### 1. Style Matching

**Priority:** P0 (MVP)

**Description:** Suggest items from the user's wardrobe that match well with selected items.

**Requirements:**

**Match Types:**
- **Color Harmony:** Complementary, analogous, triadic color schemes
- **Style Compatibility:** Casual, formal, bohemian, minimalist
- **Occasion Matching:** Work, casual, formal, workout
- **Material Compatibility:** Denim with denim, cotton with cotton, etc.

**Matching Algorithm:**
- Use Gemini Embeddings for item similarity
- Calculate compatibility score (0-100%)
- Consider user preferences (learned over time)
- Filter out items marked "in laundry" or "needs repair"

**Match Presentation:**
- Display matched items with score
- Sort by highest match score first
- Show why item was suggested (color match, style match, etc.)
- Quick-add to current outfit

**"Complete the Look" Suggestions:**
- Starting from one item, suggest complete outfit
- Suggest: top, bottom, shoes, accessories
- Show multiple complete outfit options

**API Endpoints:**

```
POST /api/v1/recommendations/match
- Get matching items for selected items
- Request: JSON
  - item_ids: List<string> (1-5 items)
  - match_type: "color"|"style"|"occasion"|"all"
  - limit: number (default: 10, max: 20)
- Response: 200 OK
  - matches: List<match_result>
    - item: item_object
    - score: number (0-100)
    - reasons: List<string>
      - "Color: Complementary to blue shirt"
      - "Style: Matches casual aesthetic"
  - complete_looks: List<outfit_suggestion>
```

```
POST /api/v1/recommendations/complete-look
- Get complete outfit suggestions
- Request: JSON
  - start_item_id: string
  - occasion?: string
  - weather_condition?: string
  - limit: number (default: 5, max: 10)
- Response: 200 OK
  - complete_looks: List<outfit_suggestion>
    - items: List<item_objects>
    - match_score: number
    - description: string
```

**Acceptance Criteria:**
- [ ] AI suggests matching items with >80% relevance
- [ ] Match scores are calculated accurately
- [ ] "Complete the Look" creates cohesive outfits
- [ ] Reasons are explained clearly
- [ ] Suggestions update in real-time

**Error Handling:**
- `400 Bad Request`: Invalid item IDs or parameters
- `404 Not Found`: One or more items do not exist
- `503 AI Service Unavailable`: Recommendation engine down

---

### 2. Gap Analysis

**Priority:** P1

**Description:** Analyze wardrobe composition and identify missing versatile pieces.

**Requirements:**

**Wardrobe Analysis:**
- Analyze item count per category
- Identify under-represented categories (e.g., only 2 jackets, 30 tops)
- Calculate category ratios (ideal vs actual)
- Identify missing basic essentials

**Essential Items:**
- Define capsule wardrobe essentials:
  - Basic tops (white, black, neutral)
  - Versatile bottoms (jeans, black pants)
  - Outerwear (blazer, coat)
  - Shoes (sneakers, dress shoes)
  - Accessories (belt, bag)

**Gap Prioritization:**
- Prioritize gaps by:
  - Most-used categories
  - Versatility (matches many existing items)
  - Seasonal needs
  - Cost-per-wear potential

**Recommendations:**
- Suggest specific items to fill gaps
- Show how many outfits would be created by adding item
- Calculate estimated cost-per-wear
- Link to shopping suggestions (if shopping integration enabled)

**Visual Gap Display:**
- Show wardrobe breakdown chart (donut chart)
- Highlight gaps visually
- Show "top 5 missing items"

**API Endpoints:**

```
GET /api/v1/recommendations/wardrobe-gaps
- Analyze wardrobe for gaps
- Response: 200 OK
  - analysis: {
        category_breakdown: {
            category: string
            count: number
            ideal_min: number
            ideal_max: number
            is_underrepresented: boolean
          }[]
        missing_essentials: List<essential_item>
          - category: string
          - description: string
          - priority: "high"|"medium"|"low"
          - would_complete: number (outfits)
          - estimated_cpw: number
        wardrobe_completeness_score: number (0-100)
      }
```

```
GET /api/v1/recommendations/gap-fillers/{category_id}
- Get items to fill specific gap
- Response: 200 OK
  - suggestions: {
        category: string
        items: List<shopping_suggestion>
          - name: string
          - image_url: string
          - price: number
          - store_url: string
          - match_with_wardrobe_score: number
          - estimated_uses: number
      }
```

**Acceptance Criteria:**
- [ ] Wardrobe composition is analyzed accurately
- [ ] Essential gaps are identified correctly
- [ ] Recommendations are prioritized by impact
- [ ] Cost-per-wear estimates are reasonable
- [ ] Visual breakdown is clear

**Error Handling:**
- `404 Not Found`: Wardrobe has no items to analyze
- `503 AI Service Unavailable`: Analysis engine down

---

### 3. Trend Alignment

**Priority:** P2

**Description:** Compare user's wardrobe to current fashion trends and suggest updates.

**Requirements:**

**Trend Data:**
- Source: Fashion trend APIs, fashion magazines, social media
- Update frequency: Weekly
- Categories: Colors, styles, patterns, items
- Season-specific trends

**Trend Analysis:**
- Analyze user's wardrobe items against trends
- Identify:
  - On-trend items (currently fashionable)
  - Classic items (always in style)
  - Outdated items (no longer fashionable)
- Calculate "trend score" per item (0-100)

**Trend Categories:**
- Colors: Pantone color of the year, seasonal color palettes
- Styles: Minimalist, maximalist, vintage, y2k, cottagecore, etc.
- Items: Wide-leg pants, oversized blazers, crop tops, etc.
- Patterns: Floral, geometric, plaid, animal print

**Recommendations:**
- Suggest on-trend items that match wardrobe
- Suggest ways to modernize outdated items (styling tips)
- Show trend predictions (coming trends)

**Trend Dashboard:**
- Show current season's top 5 trends
- Show user's "trend score" (how fashionable is wardrobe)
- Show items to keep vs. items to donate

**API Endpoints:**

```
GET /api/v1/recommendations/trends
- Get current fashion trends
- Query Parameters:
  - season: string
  - category: "colors"|"styles"|"items"|"all"
- Response: 200 OK
  - trends: {
        season: string
        updated_at: timestamp
        top_trends: List<trend>
          - id: string
          - name: string
          - category: string
          - description: string
          - examples: List<string>
          - popularity_score: number
      }
```

```
GET /api/v1/recommendations/wardrobe-trend-alignment
- Compare wardrobe to trends
- Response: 200 OK
  - alignment: {
        overall_trend_score: number (0-100)
        item_analysis: List<trend_item_analysis>
          - item_id: string
          - item_name: string
          - trend_status: "on_trend"|"classic"|"outdated"
          - trend_score: number
          - trending_with: string[]
        wardrobe_trend_breakdown: {
            on_trend: number
            classic: number
            outdated: number
        }
      }
```

```
GET /api/v1/recommendations/trend-suggestions
- Get on-trend items to add
- Response: 200 OK
  - suggestions: List<trend_suggestion>
    - trend_name: string
    - items: List<shopping_suggestion>
    - how_to_style: string
```

**Acceptance Criteria:**
- [ ] Trend data is current and accurate
- [ ] Wardrobe items are categorized correctly
- [ ] Trend scores are reasonable
- [ ] Suggestions are actionable
- [ ] Trend dashboard is informative

**Error Handling:**
- `404 Not Found`: No trend data available
- `503 Service Unavailable`: Trend API down

---

### 4. Color Coordination

**Priority:** P1

**Description:** Suggest harmonious color combinations based on color theory.

**Requirements:**

**Color Extraction:**
- Extract primary and secondary colors from items
- Convert to HSL (Hue, Saturation, Lightness)
- Store color values for matching

**Color Harmony Rules:**
- **Complementary:** Opposite colors on color wheel (e.g., blue and orange)
- **Analogous:** Adjacent colors (e.g., blue, blue-green, green)
- **Triadic:** Three colors equally spaced (e.g., red, yellow, blue)
- **Split-Complementary:** Base color + two adjacent to complement
- **Monochromatic:** Variations of same hue
- **Neutral Matching:** Black, white, gray, beige go with everything

**Color Palette Generation:**
- Generate palette from selected item(s)
- Suggest items matching palette
- Show multiple palette options

**Color Theory Education:**
- Explain why colors work well together
- Show color wheel visual
- Provide tips for beginners

**Color Tags:**
- Auto-tag items with colors (extracted from image)
- Manual color correction (if AI is wrong)
- Tag with primary and secondary colors

**API Endpoints:**

```
POST /api/v1/recommendations/colors
- Get color-matching suggestions
- Request: JSON
  - item_ids: List<string> (1-3 items)
  - harmony_type: "complementary"|"analogous"|"triadic"|"split_complementary"|"monochromatic"|"neutral"|"all"
  - limit: number (default: 10)
- Response: 200 OK
  - color_suggestions: {
        base_colors: List<color_info>
          - hex: string
          - name: string
          - source_item_id: string
        harmonies: List<harmony>
          - type: string
          - colors: List<color_info>
          - description: string
        matching_items: List<color_matched_item>
          - item: item_object
          - color_match_score: number
          - color_harmony: string
          - matched_colors: List<color_info>
      }
```

```
GET /api/v1/recommendations/colors/palette/{outfit_id}
- Get color palette for outfit
- Response: 200 OK
  - palette: {
        primary_colors: List<color_info>
        secondary_colors: List<color_info>
        color_harmony: string
        harmony_explanation: string
        color_wheel_visual: url
      }
```

**Acceptance Criteria:**
- [ ] Color extraction is accurate (>90%)
- [ ] Color harmonies follow color theory rules
- [ ] Matching items are visually compatible
- [ ] Palettes are cohesive
- [ ] Explanations are educational

**Error Handling:**
- `400 Bad Request`: Invalid item IDs
- `422 Unprocessable Entity`: Colors cannot be extracted from items
- `503 AI Service Unavailable`: Color engine down

---

### 5. Personal Style Learning

**Priority:** P1

**Description:** AI learns from user behavior to provide increasingly personalized recommendations.

**Requirements:**

**Data Collection:**
Track user interactions:
- Saved outfits (and which items they contain)
- Rejected suggestions
- Liked items and outfits
- Most-worn items
- Items never worn
- Search queries
- Filters used

**Preference Modeling:**
- Build user preference profile
- Learn:
  - Favorite colors
  - Preferred styles
  - Brands liked vs. avoided
  - Patterns and materials preferred
  - Occasion preferences
- Update profile continuously

**Feedback Loop:**
- Explicit feedback: Like/dislike buttons on suggestions
- Implicit feedback: Click-through rate, save rate, wear rate
- Ask for feedback after wearing recommended outfit

**Personalization Indicators:**
- Show "Personalized for You" badge on recommendations
- Show "Based on your preferences" explanation
- Display preference match score (how well matches user's taste)

**Privacy & Transparency:**
- Show users what data is collected
- Allow users to view their preference profile
- Allow users to reset or modify preferences
- Data used only for personalization

**Cold Start Problem:**
- New users get generic recommendations initially
- Onboarding quiz: "What's your style?", "Favorite colors?"
- Use quiz answers to bootstrap personalization

**API Endpoints:**

```
GET /api/v1/recommendations/personalized
- Get personalized recommendations
- Query Parameters:
  - type: "items"|"outfits"|"all"
  - limit: number (default: 10, max: 20)
- Response: 200 OK
  - recommendations: {
        items: List<personalized_item_recommendation>
          - item: item_object
          - match_score: number
          - why_recommended: string
          - based_on: string ("Your preference for blue", "You've worn similar 5 times")
        outfits: List<personalized_outfit_recommendation>
          - outfit: outfit_object
          - match_score: number
          - why_recommended: string
      }
```

```
POST /api/v1/recommendations/feedback
- Submit feedback on recommendation
- Request: JSON
  - recommendation_id: string
  - feedback: "like"|"dislike"|"neutral"
  - context: string (optional explanation)
- Response: 200 OK
  - acknowledged: boolean
```

```
GET /api/v1/users/preferences
- View user preference profile
- Response: 200 OK
  - preferences: {
        favorite_colors: List<string>
        preferred_styles: List<string>
        liked_brands: List<string>
        disliked_patterns: List<string>
        data_points_collected: number
        last_updated: timestamp
      }
```

```
PUT /api/v1/users/preferences
- Update user preference profile
- Request: JSON
- Response: 200 OK
  - preferences: updated_preference_object
```

**Acceptance Criteria:**
- [ ] Recommendations improve over time
- [ ] User behavior is tracked correctly
- [ ] Feedback loop is implemented
- [ ] Personalization badge appears when appropriate
- [ ] Users can view and modify preferences
- [ ] Cold start problem is addressed

**Error Handling:**
- `400 Bad Request`: Invalid feedback data
- `404 Not Found`: Recommendation does not exist
- `503 Service Unavailable`: Learning engine down

---

## Database Schema

### Recommendations Table (Logs for Learning)

```sql
CREATE TABLE recommendation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50),
    items_shown UUID[],
    items_clicked UUID[],
    items_saved UUID[],
    items_worn UUID[],
    feedback JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recommendation_logs_user_id ON recommendation_logs(user_id);
CREATE INDEX idx_recommendation_logs_type ON recommendation_logs(recommendation_type);
CREATE INDEX idx_recommendation_logs_created_at ON recommendation_logs(created_at DESC);
```

### User Preferences Table

```sql
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    favorite_colors JSONB DEFAULT '[]'::jsonb,
    preferred_styles JSONB DEFAULT '[]'::jsonb,
    liked_brands JSONB DEFAULT '[]'::jsonb,
    disliked_patterns JSONB DEFAULT '[]'::jsonb,
    preferred_occasions JSONB DEFAULT '[]'::jsonb,
    color_temperature VARCHAR(20), -- warm, cool, neutral
    style_personality VARCHAR(50), -- minimalist, maximalist, etc.
    data_points_collected INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Trend Data Table

```sql
CREATE TABLE trends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    season VARCHAR(50),
    year INTEGER,
    popularity_score DECIMAL(3, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_trends_category ON trends(category);
CREATE INDEX idx_trends_season_year ON trends(season, year);
CREATE INDEX idx_trends_popularity ON trends(popularity_score DESC);
```

### Item-Color Junction Table

```sql
CREATE TABLE item_colors (
    item_id UUID PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    color_hsl JSONB, -- {h, s, l}
    is_manual BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Frontend Components

### RecommendationCarousel.tsx
Show personalized item/outfit suggestions

### StyleMatchPanel.tsx
Display style-matching suggestions

### ColorPalettePicker.tsx
Select color harmony for suggestions

### GapAnalysisChart.tsx
Display wardrobe composition and gaps

### TrendDashboard.tsx
Show current trends and wardrobe alignment

### PreferenceManager.tsx
View and edit user preferences

### FeedbackModal.tsx
Collect feedback on recommendations

---

## AI Integration Details

### Style Matching Agent

```python
class StyleMatchingAgent(Agent):
    """Agent for matching items based on style compatibility"""

    def __init__(self):
        super().__init__(
            name="style_matcher",
            model="gemini-embeddings-004",
        )

    async def find_matching_items(
        self,
        query_items: List[Item],
        user_wardrobe: List[Item],
        user_preferences: UserPreferences
    ) -> List[MatchResult]:
        """Find items that match well with query items"""
        # 1. Get embeddings for query items
        # 2. Get embeddings for wardrobe items
        # 3. Calculate cosine similarity
        # 4. Filter by user preferences
        # 5. Rank and return top matches
        pass
```

### Personalization Engine

```python
class PersonalizationEngine:
    """Engine for learning and applying user preferences"""

    async def update_preferences(
        self,
        user_id: str,
        interaction: Interaction
    ):
        """Update user preferences based on interaction"""
        # 1. Extract signals from interaction
        # 2. Update preference vectors
        # 3. Recalculate preference scores
        pass

    async def get_personalized_ranking(
        self,
        items: List[Item],
        user_id: str
    ) -> List[RankedItem]:
        """Rank items by personalized preference score"""
        # 1. Calculate item features
        # 2. Calculate similarity to user preferences
        # 3. Apply weights based on user history
        # 4. Return ranked list
        pass
```

---

## Success Metrics

- **Recommendation Click-Through Rate:** >15%
- **Recommendation Save Rate:** >5%
- **Recommendation Wear Rate:** >3%
- **User Satisfaction:** 4.2/5 stars
- **Personalization Improvement:** Recommendations improve by 20% after 50 interactions

---

## Future Enhancements

- Collaborative filtering (what do similar users like?)
- Outfit-of-the-day based on calendar and weather
- Style quizzes for faster personalization
- A/B test recommendation algorithms
- Trend prediction (what will be popular next month?)
- Seasonal wardrobe transition suggestions
- Special occasion outfit planning (weddings, interviews)
