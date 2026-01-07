# Feature: Gamification

## Overview

Gamification features add engagement and motivation through streaks, achievements, statistics, and sustainability goals. These features encourage consistent usage and help users get more value from their wardrobe.

## User Value

- **Motivation:** Build healthy wardrobe habits
- **Achievement:** Earn recognition for accomplishments
- **Insight:** Understand fashion patterns
- **Sustainability:** Track environmental impact
- **Fun:** Enjoy the experience

## Functional Requirements

### 1. Streak Tracking

**Priority:** P2

**Description:** Track consecutive days of outfit planning to build habits.

**Requirements:**

**Daily Planning Streak:**
- Count consecutive days of planning an outfit
- Reset streak if day is missed
- Show current streak on profile

**Streak Calculation:**
- Plan outfit before midnight local time
- Check within 24-hour window to prevent cheating
- Allow grace period: 24 hours to maintain streak

**Streak Milestones:**
- 7 days: "One Week Streak"
- 30 days: "Monthly Master"
- 60 days: "Two-Month Champion"
- 90 days: "Quarterly Queen/King"
- 100 days: "Century Streak"
- 365 days: "Yearly Legend"

**Streak Freeze:**
- Option to freeze streak for emergencies (max 3 per month)
- Vacation mode: set dates to pause streak
- Streak freezes don't count toward milestones

**Streak Protection:**
- Option to use "skip day" without breaking streak (limited usage)
- Earn skips through achievements

**Reminders:**
- Daily reminder to plan outfit
- "Don't lose your streak!" notification
- Streak status shown on home screen

**API Endpoints:**

```
GET /api/v1/user/streak
- View current streak
- Response: 200 OK
  - streak: {
        current_streak: number
        longest_streak: number
        last_planned: ISO8601 date
        streak_freezes_remaining: number
        streak_skips_remaining: number
        next_milestone: {
            days: number
            badge: string
            name: string
        }
      }
```

```
POST /api/v1/user/streak/freeze
- Use streak freeze
- Response: 200 OK
  - streak: updated_streak_object
```

```
POST /api/v1/user/streak/vacation
- Set vacation mode
- Request: JSON
  - start_date: ISO8601 date
  - end_date: ISO8601 date
- Response: 200 OK
  - vacation: vacation_object
```

**Acceptance Criteria:**
- [ ] Streak is calculated correctly
- [ ] Milestones are awarded properly
- [ ] Streak freezes work as expected
- [ ] Vacation mode pauses streak
- [ ] Reminders are sent daily
- [ ] Streak data is accurate

**Error Handling:**
- `403 Forbidden`: No streak freezes remaining
- `400 Bad Request`: Invalid vacation dates

---

### 2. Achievements

**Priority:** P2

**Description:** Earn badges and achievements for completing various goals.

**Requirements:**

**Achievement Categories:**

**Variety:**
- "Style Explorer": Create 50 unique outfits
- "Mix Master": Create 100 outfits
- "Wardrobe Pro": Create 500 outfits
- "Color Chameleon": Use 20 different colors
- "Brand Diverse": Wear items from 10+ brands

**Sustainability:**
- "Eco Warrior": Go 30 days without shopping
- "Thrifty Stylist": Buy 10 second-hand items
- "Repair Champion": Repair 5 items instead of replacing
- "Waste Reducer": Sell 10 items instead of discarding
- "Green Fashion": Wear sustainable brands only for a week

**Social:**
- "Community Star": Share 20 outfits
- "Feedback Giver": Leave 50 comments/reviews
- "Inspiration Source": 100 likes on shared outfits
- "Social Butterfly": Invite 5 friends

**Challenges:**
- "Challenge Champion": Complete 5 challenges
- "30-Day Hero": Complete a 30-day challenge
- "Perfect Streak": Complete challenge without missing a day

**Usage:**
- "Daily Planner": Plan outfit for 30 consecutive days
- "Wardrobe Explorer": Wear every item at least once
- "Repeat Offender": Wear same item 50 times
- "Most Versatile": Find item with highest cost-per-wear

**Achievement Display:**
- Show earned badges on profile
- Show badge details (earned date, description)
- Progress toward unearned achievements
- Rarity indicator (common, rare, legendary)

**Achievement Notifications:**
- Celebratory animation when achievement earned
- Share achievement on social media
- Push notification for new achievements

**Reward System:**
- Earn free AI generations
- Earn additional storage
- Earn premium trial days
- Earn "streak skips"

**API Endpoints:**

```
GET /api/v1/user/achievements
- View all achievements
- Response: 200 OK
  - achievements: {
        earned: List<achievement_object>
        available: List<achievement_object>
          - id: string
          - name: string
          - description: string
          - icon: string
          - category: string
          - rarity: "common"|"rare"|"legendary"
          - requirement: {
              type: string
              target: number
              current: number
            }
          - reward: {
              type: string
              amount: number
            }
      }
```

```
GET /api/v1/user/achievements/{id}
- View achievement details
- Response: 200 OK
  - achievement: achievement_detail_object
    - earned: boolean
    - earned_at: timestamp
    - progress: number
    - reward_claimed: boolean
```

```
POST /api/v1/user/achievements/{id}/claim-reward
- Claim achievement reward
- Response: 200 OK
  - reward: reward_object
```

**Acceptance Criteria:**
- [ ] Achievements track progress correctly
- [ ] Badges are awarded automatically
- [ ] Notifications appear when achievements earned
- [ ] Rewards can be claimed
- [ ] Progress is visible
- [ ] Rarity system works

**Error Handling:**
- `404 Not Found`: Achievement doesn't exist
- `400 Bad Request`: Reward already claimed or not earned

---

### 3. Wardrobe Stats

**Priority:** P1

**Description:** Display fun and useful statistics about wardrobe and usage.

**Requirements:**

**Wardrobe Composition:**
- Total items
- Items by category (breakdown chart)
- Items by color
- Items by brand
- Items by season

**Usage Statistics:**
- Most worn item (and count)
- Least worn item
- Average cost-per-wear
- Items never worn
- Total days of outfits possible

**Financial Metrics:**
- Total wardrobe value
- Cost-per-wear by item
- Money saved by wearing owned items
- Most expensive item
- Most valuable item (highest CPW savings)

**Style Insights:**
- Favorite colors worn
- Favorite brands
- Most common outfit combinations
- Style preferences (casual, formal, etc.)

**Time-Based Trends:**
- Weekly outfit creation trends
- Monthly usage patterns
- Seasonal preferences

**Fun Metrics:**
- "If you wore a different outfit every day, how long would you last?"
- "Most versatile item"
- "Best investment" (highest CPW)
- "Most expensive outfit"
- "Favorite outfit" (most liked)

**Visual Charts:**
- Pie charts (wardrobe composition)
- Bar charts (usage by category)
- Line charts (trends over time)
- Heat maps (color usage)

**Export Stats:**
- Download stats report (PDF)
- Share stats on social media
- Export to CSV for analysis

**API Endpoints:**

```
GET /api/v1/user/stats
- View overall statistics
- Response: 200 OK
  - stats: {
        wardrobe: {
            total_items: number
            by_category: {
                category: string
                count: number
            }[]
            by_color: {
                color: string
                count: number
            }[]
            by_brand: {
                brand: string
                count: number
            }[]
        }
        usage: {
            most_worn: {
                item_id: string
                name: string
                count: number
            }
            least_worn: {
                item_id: string
                name: string
                count: number
            }
            never_worn: number
            average_cost_per_wear: number
        }
        financial: {
            total_value: number
            savings_from_owned_items: number
            most_expensive_item: {
                item_id: string
                price: number
            }
            best_investment: {
                item_id: string
                cost_per_wear: number
                total_savings: number
            }
        }
        fun: {
            days_of_unique_outfits: number
            most_versatile_item: string
            favorite_color: string
            favorite_brand: string
        }
    }
```

```
GET /api/v1/user/stats/trends
- View trends over time
- Query Parameters:
  - period: "week"|"month"|"quarter"|"year"
  - start_date: ISO8601 date
  - end_date: ISO8601 date
- Response: 200 OK
  - trends: {
        outfits_created_by_day: {
            date: string
            count: number
        }[]
        items_worn_by_category: {
            category: string
            count: number
        }[]
        color_usage_trend: {
            color: string
            usage: number
        }[]
    }
```

```
GET /api/v1/user/stats/export
- Export statistics
- Query Parameters:
  - format: "pdf"|"csv"|"json"
- Response: 200 OK
  - file: {
        url: string
        filename: string
        expires_at: timestamp
      }
```

**Acceptance Criteria:**
- [ ] All statistics are accurate
- [ ] Charts are visually appealing
- [ ] Trends are calculated correctly
- [ ] Export works for all formats
- [ ] Fun metrics are engaging

**Error Handling:**
- `400 Bad Request`: Invalid date range or format
- `404 Not Found`: No data available for date range

---

### 4. Sustainability Goals

**Priority:** P2

**Description:** Track environmental impact and sustainability achievements.

**Requirements:**

**Metrics Tracked:**

**Shopping Reduction:**
- Days since last purchase
- Money not spent (vs. previous habits)
- Items avoided buying (due to wardrobe usage)

**Wardrobe Utilization:**
- Percentage of wardrobe worn in last 30 days
- Items worn more than 10 times
- Reduction in unworn items

**Environmental Impact:**
- CO2 saved (by wearing existing items vs. buying new)
- Water saved (from not producing new items)
- Waste prevented (by not discarding clothes)

**Sustainable Choices:**
- Items from sustainable brands
- Second-hand purchases
- Items repaired instead of replaced
- Items donated instead of discarded

**Goals:**
- Set custom sustainability goals
- Track progress toward goals
- Get alerts when goals reached

**Goal Types:**
- "No shopping for 30 days"
- "Wear every item at least once"
- "Buy only sustainable brands for a month"
- "Repair 5 items instead of replacing"
- "Donate 10 unworn items"

**Impact Visualization:**
- Show environmental impact in relatable terms:
  - "You saved X kg of CO2 = Y car trips"
  - "You saved X liters of water = Y bathtubs"
  - "You prevented X kg of waste"
- Show progress with animated counters

**Sustainability Score:**
- Calculate overall score (0-100)
- Breakdown by category
- Compare to community average
- Show improvement over time

**Achievement Integration:**
- Sustainability-related achievements
- Share sustainability milestones

**API Endpoints:**

```
GET /api/v1/user/sustainability
- View sustainability metrics
- Response: 200 OK
  - sustainability: {
        score: number
        shopping: {
            days_since_last_purchase: number
            money_saved: number
            items_avoided: number
        }
        utilization: {
            percentage_worn: number
            items_worn_10_plus_times: number
        }
        impact: {
            co2_saved_kg: number
            water_saved_liters: number
            waste_prevented_kg: number
            car_equivalent: number
            bathtub_equivalent: number
        }
        sustainable_choices: {
            sustainable_brands: number
            second_hand: number
            repaired_items: number
            donated_items: number
        }
        comparison: {
            user_score: number
            community_average: number
        }
    }
```

```
POST /api/v1/user/sustainability/goals
- Set sustainability goal
- Request: JSON
  - type: string
  - target: number
  - deadline: ISO8601 date
- Response: 201 Created
  - goal: sustainability_goal_object
```

```
GET /api/v1/user/sustainability/goals
- View sustainability goals
- Response: 200 OK
  - goals: List<sustainability_goal_object>
    - id: string
    - type: string
    - target: number
    - current: number
    - progress: number (0-100)
    - deadline: date
    - status: "active"|"completed"|"failed"
```

```
POST /api/v1/user/sustainability/log-purchase
- Log purchase (reduces sustainability score)
- Request: JSON
  - item_name: string
  - price: number
  - is_sustainable: boolean
  - is_second_hand: boolean
- Response: 201 Created
  - impact: {
        score_change: number
        new_score: number
      }
```

**Acceptance Criteria:**
- [ ] Sustainability metrics are calculated accurately
- [ ] Goals can be set and tracked
- [ ] Impact is shown in relatable terms
- [ ] Score updates correctly
- [ ] Community comparison works

**Error Handling:**
- `400 Bad Request`: Invalid goal data
- `409 Conflict`: Active goal of same type exists

---

## Database Schema

### User Streaks Table

```sql
CREATE TABLE user_streaks (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_planned_date DATE,
    streak_freezes_remaining INTEGER DEFAULT 3,
    streak_skips_remaining INTEGER DEFAULT 1,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### User Achievements Table

```sql
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(100) NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reward_claimed BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON user_achievements(achievement_id);
```

### Achievement Definitions Table

```sql
CREATE TABLE achievement_definitions (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    category VARCHAR(50),
    rarity VARCHAR(20) DEFAULT 'common',
    requirement_type VARCHAR(50),
    requirement_target INTEGER,
    reward_type VARCHAR(50),
    reward_amount INTEGER,
    is_active BOOLEAN DEFAULT TRUE
);
```

### Sustainability Goals Table

```sql
CREATE TABLE sustainability_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_type VARCHAR(100) NOT NULL,
    target INTEGER NOT NULL,
    current INTEGER DEFAULT 0,
    deadline DATE,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_sustainability_goals_user_id ON sustainability_goals(user_id);
CREATE INDEX idx_sustainability_goals_status ON sustainability_goals(status);
```

### Sustainability Metrics Table

```sql
CREATE TABLE sustainability_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    co2_saved_kg DECIMAL(10, 2),
    water_saved_liters DECIMAL(10, 2),
    waste_prevented_kg DECIMAL(10, 2),
    days_without_shopping INTEGER,
    items_worn INTEGER,
    sustainability_score INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, metric_date)
);

CREATE INDEX idx_sustainability_metrics_user_id ON sustainability_metrics(user_id);
CREATE INDEX idx_sustainability_metrics_date ON sustainability_metrics(metric_date);
```

---

## Frontend Components

### StreakDisplay.tsx
Show current streak on profile

### AchievementBadge.tsx
Display individual achievement badge

### AchievementGallery.tsx
View all achievements and progress

### StatsDashboard.tsx
Display comprehensive statistics

### TrendChart.tsx
Show usage trends over time

### SustainabilityTracker.tsx
Track sustainability progress

### SustainabilityGoals.tsx
Set and track sustainability goals

### ImpactVisualization.tsx
Show environmental impact

---

## Success Metrics

- **Streak Engagement:** 30% of users maintain 7+ day streak
- **Achievement Completion:** 50% of users earn at least 5 achievements
- **Stats Viewing:** 40% DAU view stats
- **Sustainability Engagement:** 20% of users set sustainability goals
- **Feature Satisfaction:** 4.4/5 stars for gamification

---

## Future Enhancements

- Leaderboards (friends, community)
- Competitive challenges
- Seasonal achievements
- Achievement sharing
- Custom achievement creation
- Team challenges
- Weekly/monthly goals
- Reward marketplace (redeem points)
- Virtual rewards (exclusive themes, badges)
- Achievement-based unlocks (features, storage)
- Sustainability certificates
- Year-in-review reports
- Streak leaderboards
- Prediction games (predict next trend)
