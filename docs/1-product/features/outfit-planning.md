# Feature: Outfit Planning & Organization

## Overview

Outfit Planning & Organization features help users plan their wardrobe usage in advance, integrate with calendar events, and make weather-appropriate outfit decisions. These features reduce decision fatigue and ensure users are prepared for any occasion.

## User Value

- **Reduced Decision Fatigue:** Plan outfits in advance
- **Never Unprepared:** Know what to wear before the day starts
- **Weather-Appropriate:** Always dressed for conditions
- **Better Utilization:** Use all items in wardrobe effectively
- **Time Savings:** No more last-minute outfit scrambling

## Functional Requirements

### 1. Calendar Integration

**Priority:** P1

**Description:** Connect external calendars (Google, Apple, Outlook) to assign outfits to specific events and dates.

**Requirements:**

**Calendar Providers:**
- Google Calendar
- Apple Calendar (CalDAV)
- Outlook (Microsoft Graph)
- Local device calendar (mobile)

**OAuth Integration:**
- Secure OAuth2 authentication for each provider
- Request appropriate scopes (read-only calendar access)
- Handle token refresh automatically
- Allow disconnect/reconnect anytime

**Calendar Display:**
- View calendar events within app
- Show event details: title, time, location, attendees
- Weekly and monthly view options
- Sync in real-time

**Outfit Assignment:**
- Assign saved outfit to calendar event
- Create new outfit directly from event
- See which events have outfits assigned
- Assign outfits for full days (no specific event)

**Sync Behavior:**
- Sync events every 15 minutes or on app open
- Store events locally for offline access
- Handle event updates (rescheduling, cancellations)
- Outfit assignment persists with event

**Notifications:**
- Get notified day before about outfit assignment
- Morning reminder: "Today's outfit is ready!"
- Option to customize notification times

**API Endpoints:**

```
POST /api/v1/calendar/connect
- Connect calendar provider
- Request: JSON
  - provider: "google"|"apple"|"outlook"
  - auth_code: string
- Response: 200 OK
  - calendar_connection: {
        id: string
        provider: string
        email: string
        connected_at: timestamp
    }
```

```
GET /api/v1/calendar/connections
- List connected calendars
- Response: 200 OK
  - calendars: List<calendar_connection>
```

```
DELETE /api/v1/calendar/connections/{id}
- Disconnect calendar
- Response: 204 No Content
```

```
GET /api/v1/calendar/events
- Fetch calendar events
- Query Parameters:
  - start_date: ISO8601 date
  - end_date: ISO8601 date
- Response: 200 OK
  - events: List<calendar_event>
    - id: string
    - calendar_id: string
    - title: string
    - description: string
    - start: ISO8601 datetime
    - end: ISO8601 datetime
    - location: string
    - attendees: List<string>
    - outfit_id?: string
```

```
POST /api/v1/calendar/events/{event_id}/outfit
- Assign outfit to event
- Request: JSON
  - outfit_id: string
- Response: 200 OK
  - event: updated_event_object
```

```
DELETE /api/v1/calendar/events/{event_id}/outfit
- Remove outfit assignment
- Response: 200 OK
  - event: updated_event_object
```

**Acceptance Criteria:**
- [ ] Users can connect Google, Apple, and Outlook calendars
- [ ] Calendar events display in app
- [ ] Users can assign outfits to events
- [ ] Notifications remind users of outfit assignments
- [ ] Calendar syncs automatically
- [ ] Outfit assignments persist with events

**Error Handling:**
- `401 Unauthorized`: OAuth token expired or invalid
- `403 Forbidden`: Invalid OAuth scopes
- `429 Too Many Requests`: Calendar API rate limit
- `503 Service Unavailable`: Calendar provider down

---

### 2. Weather-Based Suggestions

**Priority:** P1

**Description:** Fetch weather data and suggest outfits appropriate for current and forecasted conditions.

**Requirements:**

**Weather Data:**
- Provider: OpenWeatherMap API
- Data points: temperature, condition (sunny, rainy, cloudy), humidity, wind
- Location: User's default location or current location (with permission)
- Forecast: 7-day forecast available

**Weather Conditions:**
- Sunny/Clear
- Cloudy/Overcast
- Rainy
- Snowy
- Windy
- Hot (>80°F/27°C)
- Cold (<50°F/10°C)
- Moderate (50-80°F/10-27°C)

**Outfit Suggestions:**
- Suggest weather-appropriate items (coat for cold, light clothes for hot)
- Filter wardrobe by weather-appropriate items
- Show weather icon with suggestions
- Consider humidity (suggest breathable fabrics for humid conditions)

**Temperature Ranges:**
- **Hot (>80°F/27°C):** Shorts, t-shirts, breathable fabrics, sunglasses
- **Warm (70-80°F/21-27°C):** Light pants, short sleeves, light layers
- **Moderate (50-70°F/10-21°C):** Jeans, long sleeves, light jacket
- **Cool (40-50°F/4-10°C):** Sweater, jeans, coat
- **Cold (<40°F/4°C):** Heavy coat, thick sweater, warm accessories

**Location Handling:**
- Use user's saved default location
- Option to use current GPS location
- Manual location entry (city name)
- Multiple saved locations (home, work, travel destination)

**Display:**
- Current weather on home screen
- Weather icon + temperature
- "Based on weather, we suggest..." section
- Weekly forecast view

**API Endpoints:**

```
GET /api/v1/weather
- Get current weather
- Query Parameters:
  - location?: string (lat,lon or city name)
- Response: 200 OK
  - weather: {
        temperature: number (celsius)
        condition: string
        humidity: number (percentage)
        wind_speed: number (km/h)
        feels_like: number (celsius)
        location: string
    }
```

```
GET /api/v1/weather/forecast
- Get weather forecast
- Query Parameters:
  - location?: string
  - days: number (default: 7, max: 14)
- Response: 200 OK
  - forecast: List<weather_day>
    - date: ISO8601 date
    - temperature: {high, low}
    - condition: string
    - precipitation_chance: number (0-100)
```

```
GET /api/v1/outfits/suggestions/weather
- Get weather-based outfit suggestions
- Query Parameters:
  - weather_condition: string
  - temperature: number
- Response: 200 OK
  - suggestions: {
        items: List<item_objects>
        outfits: List<outfit_objects>
        reasoning: string
    }
```

**Acceptance Criteria:**
- [ ] Current weather displays on home screen
- [ ] Weather-based suggestions are relevant
- [ ] Weekly forecast is available
- [ ] Location can be set and changed
- [ ] Suggestions update automatically
- [ ] Weather API calls are cached (15 min)

**Error Handling:**
- `400 Bad Request`: Invalid location
- `404 Not Found`: Location not found
- `503 Service Unavailable`: Weather API down
- Use cached data if API unavailable

---

### 3. Occasion Presets

**Priority:** P0 (MVP)

**Description:** Filter and suggest outfits based on occasion type (work, casual, formal, etc.).

**Requirements:**

**Predefined Occasions:**
- Work / Professional
- Casual / Everyday
- Formal / Black Tie
- Semi-Formal / Business Casual
- Workout / Athletic
- Date Night / Romantic
- Party / Night Out
- Interview
- Wedding
- Weekend / Leisure
- Travel / Vacation
- Beach / Pool
- Outdoor / Adventure

**Occasion Attributes:**
- Associated tags
- Style preferences
- Weather considerations
- Time of day (day/night)

**Filtering:**
- Filter wardrobe by occasion
- Filter saved outfits by occasion
- Show most-used occasions first
- Quick access filters on home screen

**AI Suggestions:**
- Suggest outfits for selected occasion
- Consider user's past outfit choices for that occasion
- Learn from preferences over time

**Custom Occasions:**
- Users can create custom occasions
- Add to quick filters
- Tag outfits with custom occasion

**Occasion Stats:**
- Track how many outfits per occasion
- Most common occasions
- Occasion usage trends

**API Endpoints:**

```
GET /api/v1/occasions
- List available occasions
- Response: 200 OK
  - occasions: List<occasion>
    - id: string
    - name: string
    - icon: string
    - tags: List<string>
    - is_custom: boolean
```

```
POST /api/v1/occasions
- Create custom occasion
- Request: JSON
  - name: string
  - tags: List<string>
  - icon?: string
- Response: 201 Created
  - occasion: occasion_object
```

```
GET /api/v1/outfits/suggestions/occasion/{occasion_id}
- Get occasion-based suggestions
- Response: 200 OK
  - suggestions: {
        occasion: occasion_object
        items: List<item_objects>
        outfits: List<outfit_objects>
      }
```

**Acceptance Criteria:**
- [ ] Predefined occasions cover common use cases
- [ ] Users can filter by occasion
- [ ] AI suggests appropriate outfits
- [ ] Custom occasions can be created
- [ ] Most-used occasions appear first

**Error Handling:**
- `404 Not Found`: Occasion does not exist
- `400 Bad Request`: Invalid occasion name

---

### 4. Packing Assistant

**Priority:** P2

**Description:** Help users create capsule wardrobes for trips with AI-powered suggestions and packing checklists.

**Requirements:**

**Trip Creation:**
- Trip name (e.g., "Hawaii Vacation")
- Destination
- Start date and end date
- Duration (auto-calculated)
- Activities: Beach, hiking, sightseeing, dining, nightlife, etc.
- Weather preferences: Expecting hot/cold/rainy?

**Capsule Wardrobe Generation:**
- AI suggests mix-and-match items
- Maximize outfit combinations from minimum items
- Consider destination weather and activities
- Suggest 5-10 days of outfits from 10-15 items

**Outfit Visualizations:**
- Show outfit combinations for each day
- Show how items mix and match
- Visual guide for packing

**Packing Checklist:**
- Auto-generate checklist based on capsule wardrobe
- Mark items as packed
- Show packing progress (X of Y items packed)
- Add custom items to checklist (toiletries, etc.)

**Trip Sharing:**
- Share capsule wardrobe with travel companion
- Collaborative packing
- Share packing checklist

**Historical Trips:**
- Save past trips
- Reuse capsule wardrobes for similar trips
- Track packing patterns

**API Endpoints:**

```
POST /api/v1/trips
- Create trip
- Request: JSON
  - name: string
  - destination: string
  - start_date: ISO8601 date
  - end_date: ISO8601 date
  - activities: List<string>
  - weather_expectation: string
- Response: 201 Created
  - trip: trip_object
    - id: string
    - name: string
    - destination: string
    - dates: {start, end}
    - duration_days: number
    - capsule_wardrobe?: {
          items: List<item_objects>
          outfits: List<outfit_objects>
      }
```

```
POST /api/v1/trips/{trip_id}/generate-capsule
- Generate capsule wardrobe for trip
- Response: 200 OK
  - capsule_wardrobe: {
        items: List<item_objects>
        outfits: List<outfit_objects>
        combinations: number
      }
```

```
GET /api/v1/trips/{trip_id}/packing-list
- Get packing checklist
- Response: 200 OK
  - packing_list: {
        items: List<packing_item>
          - item_id: string
          - name: string
          - is_packed: boolean
          - quantity: number
        total_items: number
        packed_count: number
        progress: number (0-100)
      }
```

```
PUT /api/v1/trips/{trip_id}/packing-list/{item_id}
- Update packing status
- Request: JSON
  - is_packed: boolean
  - quantity?: number
- Response: 200 OK
  - packing_item: updated_item
```

**Acceptance Criteria:**
- [ ] Users can create trips with details
- [ ] AI generates capsule wardrobe suggestions
- [ ] Packing checklist is generated
- [ ] Users can mark items as packed
- [ ] Trip progress is tracked
- [ ] Past trips can be viewed

**Error Handling:**
- `400 Bad Request`: Invalid dates or data
- `404 Not Found`: Trip does not exist

---

### 5. Outfit Repetition Tracking

**Priority:** P2

**Description:** Track which outfits were worn with which people/groups to help avoid repeating outfits with the same audience.

**Requirements:**

**Context Logging:**
- Log when outfit is worn
- Record context: Who was there? Where was it? What was the occasion?
- Categories: Work team, Family, Friends, Date, Party, etc.

**"Worn With" Groups:**
- Create groups: "Work Team", "Family", "Close Friends"
- Add people to groups
- Assign outfit to group when worn

**Repetition Analysis:**
- Track last worn date per group
- Show "last worn with [group] on [date]"
- Alert if outfit was recently worn with same group
- Suggest alternatives if repetition risk

**Repetition Rules:**
- Minimum time before wearing with same group (configurable, default 14 days)
- Show safe-to-wear outfits (not worn with group recently)
- Flag high-risk repetitions (worn within last 7 days)

**Smart Suggestions:**
- When planning outfit for work, show "safe to wear with work team"
- Highlight outfits that need to "rest" before wearing with certain groups

**API Endpoints:**

```
POST /api/v1/outfits/{outfit_id}/log-wearing
- Log when outfit is worn
- Request: JSON
  - date: ISO8601 date
  - group_ids: List<string>
  - occasion?: string
  - location?: string
- Response: 201 Created
  - wearing_log: {
        id: string
        outfit_id: string
        date: date
        groups: List<group_objects>
      }
```

```
GET /api/v1/outfits/{outfit_id}/repetition-status
- Check if outfit can be worn with group
- Query Parameters:
  - group_id: string
- Response: 200 OK
  - status: {
        can_wear: boolean
        last_worn_with_group?: ISO8601 date
        days_since_last_worn?: number
        recommendation: string
      }
```

```
GET /api/v1/groups
- List user's "worn with" groups
- Response: 200 OK
  - groups: List<group_object>
    - id: string
    - name: string
    - members: List<string>
  ```

```
POST /api/v1/groups
- Create "worn with" group
- Request: JSON
  - name: string
  - members: List<string>
- Response: 201 Created
  - group: group_object
```

**Acceptance Criteria:**
- [ ] Users can log outfit wearing with context
- [ ] Groups can be created and managed
- [ ] Repetition status is tracked
- [ ] Outfit suggestions consider repetition
- [ ] Alerts appear for high-risk repetitions

**Error Handling:**
- `400 Bad Request`: Invalid data
- `404 Not Found`: Outfit or group does not exist

---

### 6. Outfit Collections

**Priority:** P1

**Description:** Organize outfits into themed collections for easy access and sharing.

**Requirements:**

**Collection Types:**
- Seasonal: "Summer 2026", "Winter Wardrobe"
- Occasion: "Work Outfits", "Date Night"
- Style: "Minimalist", "Bohemian", "Business Casual"
- Custom: User-defined collections

**Collection Management:**
- Create collections
- Add multiple outfits to collection
- Rename collections
- Delete collections (option to keep outfits)
- Reorder collections

**Collection Features:**
- Cover image (first outfit or custom)
- Description
- Public/private visibility
- Share link (for public collections)

**Default Collections:**
- "Favorites" (auto-populated)
- "Recent" (last 30 days)
- "Most Worn" (top 10)

**Collection Stats:**
- Number of outfits
- Total items used
- Average cost-per-wear
- Date created/updated

**API Endpoints:**

(See "Save and Organize Outfits" in try-on-visualization.md for detailed endpoints)

**Acceptance Criteria:**
- [ ] Collections can be created and managed
- [ ] Multiple outfits can be added to collections
- [ ] Collections can be renamed and deleted
- [ ] Public collections can be shared
- [ ] Default collections are auto-created

---

## Database Schema

### Calendar Connections Table

```sql
CREATE TABLE calendar_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP,
    connected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_calendar_connections_user_id ON calendar_connections(user_id);
CREATE INDEX idx_calendar_connections_provider ON calendar_connections(provider);
```

### Calendar Events Table

```sql
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    calendar_id UUID REFERENCES calendar_connections(id),
    external_event_id VARCHAR(255),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    location VARCHAR(500),
    attendees JSONB,
    outfit_id UUID REFERENCES outfits(id),
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_calendar_events_user_id ON calendar_events(user_id);
CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);
CREATE INDEX idx_calendar_events_outfit_id ON calendar_events(outfit_id);
```

### Occasions Table

```sql
CREATE TABLE occasions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    tags JSONB DEFAULT '[]'::jsonb,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_occasions_user_id ON occasions(user_id);
CREATE INDEX idx_occasions_is_system ON occasions(is_system);
```

### Trips Table

```sql
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    destination VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    activities JSONB DEFAULT '[]'::jsonb,
    weather_expectation VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_dates ON trips(start_date, end_date);
```

### Trip Capsule Wardrobe Table

```sql
CREATE TABLE trip_capsule_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    suggested_quantity INTEGER DEFAULT 1,
    is_packed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_trip_capsule_items_trip_id ON trip_capsule_items(trip_id);
CREATE INDEX idx_trip_capsule_items_item_id ON trip_capsule_items(item_id);
```

### Wearing Logs Table

```sql
CREATE TABLE wearing_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    worn_date DATE NOT NULL,
    group_ids UUID[] DEFAULT '{}',
    occasion VARCHAR(100),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wearing_logs_outfit_id ON wearing_logs(outfit_id);
CREATE INDEX idx_wearing_logs_user_id ON wearing_logs(user_id);
CREATE INDEX idx_wearing_logs_worn_date ON wearing_logs(worn_date);
CREATE INDEX idx_wearing_logs_group_ids ON wearing_logs USING GIN(group_ids);
```

### "Worn With" Groups Table

```sql
CREATE TABLE worn_with_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    members JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_worn_with_groups_user_id ON worn_with_groups(user_id);
```

---

## Frontend Components

### CalendarView.tsx
Display and manage calendar events

### EventOutfitAssigner.tsx
Assign outfit to calendar event

### WeatherWidget.tsx
Display current weather and forecast

### WeatherSuggestions.tsx
Show weather-based outfit suggestions

### OccasionFilter.tsx
Filter by occasion type

### TripPlanner.tsx
Create and manage trips

### PackingChecklist.tsx
Manage packing list for trips

### RepetitionTracker.tsx
Track outfit repetition with groups

### CollectionGrid.tsx
Display and manage outfit collections

---

## Success Metrics

- **Calendar Sync Success Rate:** >98%
- **Weather Accuracy:** >95% match with actual conditions
- **Occasion Prediction Accuracy:** >85%
- **Trip Planning Completion:** 70% of trips get capsule wardrobe
- **User Satisfaction:** 4.3/5 stars for planning features

---

## Future Enhancements

- Smart calendar auto-assignment (AI assigns outfits automatically)
- Outfit reminders based on calendar events
- Collaborative trip planning with friends
- Import packing lists from previous trips
- Social sharing of capsule wardrobes
- Outfit repetition analytics
- Occasion-based outfit recommendations
- Weather alerts for outfit adjustments
