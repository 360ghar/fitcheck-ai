# Feature: Social & Community

## Overview

Social & Community features allow users to share outfits, get feedback from friends, browse community inspiration, and connect with professional stylists.

## User Value

- **Social Validation:** Get feedback before events
- **Inspiration:** Discover new styles from community
- **Expert Advice:** Access professional stylists
- **Motivation:** Participate in challenges
- **Connection:** Share fashion journey with friends

## Functional Requirements

### 1. Share Outfits

**Priority:** P1

**Description:** Users can share outfit images and links with friends and on social media.

**Requirements:**

**Sharing Options:**
- Share to Instagram, TikTok, Twitter/X, Facebook
- Share via direct link (public or private)
- Share via QR code
- Share to specific friends within app
- Download image to device

**Privacy Controls:**
- Public: Anyone with link can view
- Friends: Only friends can view
- Private: Only via direct message
- Time-limited links (expire after 24h, 7 days)

**Social Media Sharing:**
- Pre-generated caption with outfit details
- Hashtags: #FitCheckAI, #OOTD, #StyleInspo
- Tag brands (if item brands are known)
- Customizable caption and hashtags
- Direct integration (no need to download first)

**In-App Sharing:**
- Send to specific users (if friends list implemented)
- Group sharing (share to multiple friends at once)
- Request feedback (ask friends to rate outfit)
- Comments and reactions

**Share Preview:**
- Preview how share will look on each platform
- Adjust caption before sharing
- Choose which image to share (if multiple poses)

**Analytics (for public shares):**
- Track views, likes, shares
- (Optional) Track which social platform gets most engagement

**API Endpoints:**

```
POST /api/v1/outfits/{outfit_id}/share
- Generate share link
- Request: JSON
  - visibility: "public"|"friends"|"private"
  - expires_at?: ISO8601 datetime
  - allow_feedback: boolean
  - custom_caption?: string
- Response: 201 Created
  - share_link: {
        url: string
        qr_code_url: string
        expires_at: timestamp
        views: number
      }
```

```
POST /api/v1/outfits/{outfit_id}/share/social
- Generate social media post
- Request: JSON
  - platform: "instagram"|"tiktok"|"twitter"|"facebook"
  - caption: string
  - hashtags: List<string>
  - tag_brands: boolean
- Response: 200 OK
  - post_data: {
        image_url: string
        caption: string
        hashtags: string
        platform: string
        share_url: string
      }
```

```
GET /api/v1/shared-outfits/{share_id}
- View shared outfit
- Response: 200 OK
  - outfit: shared_outfit_data
    - images: List<image_urls>
    - items: List<item_summary> (anonymized or brand only)
    - caption: string
    - comments: List<comment>
    - likes: number
    - view_count: number
```

```
POST /api/v1/shared-outfits/{share_id}/feedback
- Leave feedback
- Request: JSON
  - rating: number (1-5)
  - comment: string
- Response: 201 Created
  - feedback: feedback_object
```

**Acceptance Criteria:**
- [ ] Users can generate share links
- [ ] Privacy controls work correctly
- [ ] Social media sharing is seamless
- [ ] QR codes are generated
- [ ] Feedback can be collected
- [ ] Analytics are tracked

**Error Handling:**
- `400 Bad Request`: Invalid visibility or parameters
- `403 Forbidden`: User doesn't own outfit
- `404 Not Found`: Share link has expired or doesn't exist
- `410 Gone`: Share link has expired

---

### 2. Browse Community Outfits

**Priority:** P2

**Description:** Users can browse outfit combinations shared anonymously by the community for inspiration.

**Requirements:**

**Community Feed:**
- Infinite scroll feed of shared outfits
- Filter by style, occasion, season
- Sort by: Trending, Recent, Most Liked
- Randomize (discover new styles)

**Anonymity:**
- No user names or avatars
- Items shown with brand names only (no personal info)
- Locations generic (e.g., "New York, NY" not full address)

**Interaction:**
- Like outfits (heart button)
- Save to own favorites
- Report inappropriate content
- Share to social media

**Outfit Details:**
- View item breakdown (category, color, brand)
- No pricing or personal details
- See item composition (e.g., "1 top, 1 bottom, 1 pair of shoes")

**Search:**
- Search by keywords (e.g., "summer", "casual", "minimalist")
- Search by color
- Search by occasion

**Content Moderation:**
- AI moderation for inappropriate content
- User reports for manual review
- Automatic removal if flagged

**Trending Section:**
- Show most-liked outfits from last 7 days
- Show top outfits by category
- Show "curated" selections (featured by team)

**API Endpoints:**

```
GET /api/v1/community/outfits
- Browse community outfits
- Query Parameters:
  - style?: string
  - occasion?: string
  - season?: string
  - sort: "trending"|"recent"|"liked"
  - page: number
  - page_size: number
- Response: 200 OK
  - outfits: List<community_outfit>
    - id: string
    - images: List<image_urls>
    - items: List<item_summary_anonymous>
      - category: string
      - color: string
      - brand: string
    - likes: number
    - created_at: timestamp
    - tags: List<string>
  - pagination: {
        page: number
        total_pages: number
        total_count: number
    }
```

```
GET /api/v1/community/outfits/{id}
- View community outfit details
- Response: 200 OK
  - outfit: community_outfit_detail
```

```
POST /api/v1/community/outfits/{id}/like
- Like community outfit
- Response: 201 Created
```

```
DELETE /api/v1/community/outfits/{id}/like
- Unlike community outfit
- Response: 204 No Content
```

```
POST /api/v1/community/outfits/{id}/report
- Report outfit
- Request: JSON
  - reason: string
  - details?: string
- Response: 201 Created
```

**Acceptance Criteria:**
- [ ] Community feed loads quickly
- [ ] Filtering and sorting work correctly
- [ ] Anonymity is maintained
- [ ] Inappropriate content can be reported
- [ ] Trending section is updated daily

**Error Handling:**
- `404 Not Found`: Outfit not found or removed
- `400 Bad Request`: Invalid filter parameters
- `403 Forbidden`: Outfit not available in user's region

---

### 3. Virtual Stylist

**Priority:** P2

**Description:** Users can connect with professional stylists for personalized advice and recommendations.

**Requirements:**

**Stylist Marketplace:**
- Browse stylists with:
  - Profile photo
  - Bio and specialties
  - Portfolio (past work)
  - Reviews and ratings
  - Pricing per session
  - Availability
- Filter by specialty: Casual, Professional, Wedding, Men's Fashion, etc.
- Sort by rating, price, availability

**Stylist Profiles:**
- Stylist name and photo
- Bio and credentials
- Specialties
- Portfolio (anonymized outfit examples)
- Reviews from past clients
- Pricing structure
- Availability calendar

**Booking Sessions:**
- Choose session type:
  - Quick advice (15 min, $25)
  - Full consultation (60 min, $75)
  - Ongoing styling (monthly, $150)
- Select date and time
- Submit styling request with:
  - Occasion (work, event, general)
  - Budget constraints
  - Style preferences
  - Photos (optional)

**Stylist Dashboard:**
- View client requests
- Accept or decline requests
- Access client's wardrobe (with permission)
- Create outfit recommendations
- Send messages
- Track sessions

**Client-Stylist Communication:**
- In-app messaging
- Share outfits and items
- Stylist can view client's wardrobe
- Secure, private communication

**Payment Processing:**
- Secure payment integration (Stripe)
- Stylist receives payment after session
- Refund policy if stylist doesn't deliver

**Session Completion:**
- Stylist provides recommendations
- Client reviews and rates stylist
- Outfits saved to client's wardrobe

**API Endpoints:**

```
GET /api/v1/stylists
- Browse stylists
- Query Parameters:
  - specialty?: string
  - min_price?: number
  - max_price?: number
  - min_rating?: number
  - sort: "rating"|"price"|"availability"
  - page: number
- Response: 200 OK
  - stylists: List<stylist_summary>
```

```
GET /api/v1/stylists/{id}
- View stylist profile
- Response: 200 OK
  - stylist: stylist_detail
```

```
POST /api/v1/stylist-sessions/book
- Book stylist session
- Request: JSON
  - stylist_id: string
  - session_type: "quick"|"full"|"ongoing"
  - date: ISO8601 date
  - time: string (HH:MM)
  - request_details: {
        occasion?: string
        budget_range?: {min, max}
        preferences: string
        photo_urls?: List<string>
      }
- Response: 201 Created
  - session: booking_confirmation
    - id: string
    - stylist: stylist_summary
    - date: date
    - time: string
    - session_type: string
    - price: number
    - status: "pending_stylist_approval"
```

```
GET /api/v1/users/stylist-sessions
- View user's stylist sessions
- Response: 200 OK
  - sessions: List<session_detail>
```

```
POST /api/v1/stylist-sessions/{id}/accept
- Stylist accepts session
- Response: 200 OK
  - session: updated_session
```

```
POST /api/v1/stylist-sessions/{id}/recommendations
- Stylist sends recommendations
- Request: JSON
  - recommendations: {
        outfits: List<outfit_suggestion>
        advice: string
        shopping_suggestions?: List<shopping_suggestion>
      }
- Response: 201 Created
```

```
POST /api/v1/stylist-sessions/{id}/complete
- Complete session
- Request: JSON
  - rating: number (1-5)
  - review?: string
- Response: 200 OK
  - message: "Session completed"
```

**Acceptance Criteria:**
- [ ] Stylist marketplace is easy to browse
- [ ] Booking flow is seamless
- [ ] Stylists can access client wardrobes
- [ ] Payments are secure
- [ ] Reviews and ratings are collected

**Error Handling:**
- `400 Bad Request`: Invalid booking data
- `404 Not Found`: Stylist or session not found
- `409 Conflict`: Time slot already booked
- `402 Payment Required`: Payment failed

---

### 4. Challenge Participation

**Priority:** P2

**Description:** Users can participate in style challenges for motivation and community engagement.

**Requirements:**

**Challenge Types:**
- "30 Items, 30 Ways": Use same 30 items for 30 days
- "Color Week": Wear outfits of same color family each day
- "Capsule Wardrobe": Create 10 outfits from 5 items
- "Vintage Vibes": Only wear vintage/thrifted items
- "Summer Ready": Summer outfit challenge
- Community-created challenges

**Challenge Details:**
- Challenge name and description
- Rules and requirements
- Duration (days)
- Prizes (badges, AI generation credits, etc.)
- Leaderboard

**Joining Challenges:**
- View available challenges
- Read rules before joining
- Join challenge (opt-in)
- Track progress

**Daily Submissions:**
- Upload outfit photo
- Describe how it meets challenge criteria
- Submit for the day
- Get feedback from community

**Leaderboard:**
- Rank by points, completion rate, likes
- Top participants visible to all
- Awards for top finishers

**Achievements:**
- Badges for completing challenges
- Special badges for top performers
- Showcase badges on profile

**Social Sharing:**
- Share progress on social media
- Tag friends to join challenge
- Post updates to challenge feed

**Challenge Feed:**
- See what others are wearing for the challenge
- Like and comment on submissions
- Get inspiration

**API Endpoints:**

```
GET /api/v1/challenges
- Browse available challenges
- Response: 200 OK
  - challenges: List<challenge>
    - id: string
    - name: string
    - description: string
    - rules: string
    - duration_days: number
    - start_date: date
    - end_date: date
    - participants: number
    - prize: string
    - is_active: boolean
```

```
POST /api/v1/challenges/{id}/join
- Join challenge
- Response: 201 Created
  - participation: {
        challenge_id: string
        user_id: string
        joined_at: timestamp
        progress: {
            days_completed: number
            total_days: number
            current_streak: number
        }
      }
```

```
GET /api/v1/users/challenges/{challenge_id}/progress
- View challenge progress
- Response: 200 OK
  - progress: challenge_progress
```

```
POST /api/v1/users/challenges/{challenge_id}/submissions
- Submit daily outfit
- Request: JSON
  - day: number
      - outfit_id: string
      - description: string
      - photo_url: string
- Response: 201 Created
  - submission: submission_object
```

```
GET /api/v1/challenges/{id}/leaderboard
- View challenge leaderboard
- Query Parameters:
  - limit: number (default: 10)
- Response: 200 OK
  - leaderboard: List<leaderboard_entry>
```

```
GET /api/v1/challenges/{id}/feed
- View challenge feed
- Response: 200 OK
  - feed: List<community_submission>
```

**Acceptance Criteria:**
- [ ] Users can join challenges
- [ ] Progress is tracked accurately
- [ ] Leaderboard updates in real-time
- [ ] Badges are awarded correctly
- [ ] Challenge feed is engaging

**Error Handling:**
- `400 Bad Request`: Invalid submission or challenge rules violated
- `404 Not Found`: Challenge not found
- `409 Conflict`: Already submitted for this day
- `403 Forbidden`: Challenge is not active or user is not participant

---

## Database Schema

### Shared Outfits Table

```sql
CREATE TABLE shared_outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    share_url VARCHAR(255) UNIQUE,
    visibility VARCHAR(20) DEFAULT 'public',
    expires_at TIMESTAMP,
    caption TEXT,
    allow_feedback BOOLEAN DEFAULT TRUE,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shared_outfits_user_id ON shared_outfits(user_id);
CREATE INDEX idx_shared_outfits_visibility ON shared_outfits(visibility);
CREATE INDEX idx_shared_outfits_created_at ON shared_outfits(created_at DESC);
```

### Share Feedback Table

```sql
CREATE TABLE share_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shared_outfit_id UUID NOT NULL REFERENCES shared_outfits(id) ON DELETE CASCADE,
    user_id UUID,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_share_feedback_shared_outfit_id ON share_feedback(shared_outfit_id);
```

### Stylists Table

```sql
CREATE TABLE stylists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    bio TEXT,
    specialties JSONB DEFAULT '[]'::jsonb,
    portfolio JSONB DEFAULT '[]'::jsonb,
    session_types JSONB,
      - type: string
      - duration_minutes: number
      - price: number
    availability JSONB,
      - day_of_week: string
      - time_slots: List<string>
    rating_average DECIMAL(2, 1),
    rating_count INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stylists_user_id ON stylists(user_id);
CREATE INDEX idx_stylists_specialties ON stylists USING GIN(specialties);
CREATE INDEX idx_stylists_rating ON stylists(rating_average DESC);
```

### Stylist Reviews Table

```sql
CREATE TABLE stylist_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stylist_id UUID NOT NULL REFERENCES stylists(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES stylist_sessions(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stylist_reviews_stylist_id ON stylist_reviews(stylist_id);
CREATE INDEX idx_stylist_reviews_client_id ON stylist_reviews(client_id);
```

### Stylist Sessions Table

```sql
CREATE TABLE stylist_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stylist_id UUID NOT NULL REFERENCES stylists(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_type VARCHAR(50) NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    request_details JSONB,
    recommendations JSONB,
    status VARCHAR(50) DEFAULT 'pending_approval',
    amount DECIMAL(10, 2),
    payment_status VARCHAR(50),
    client_rating INTEGER,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stylist_sessions_stylist_id ON stylist_sessions(stylist_id);
CREATE INDEX idx_stylist_sessions_client_id ON stylist_sessions(client_id);
CREATE INDEX idx_stylist_sessions_scheduled ON stylist_sessions(scheduled_date, scheduled_time);
```

### Challenges Table

```sql
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    rules TEXT,
    duration_days INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    prize TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    participant_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_challenges_is_active ON challenges(is_active);
CREATE INDEX idx_challenges_dates ON challenges(start_date, end_date);
```

### Challenge Participations Table

```sql
CREATE TABLE challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    days_completed INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    rank INTEGER,
    UNIQUE(user_id, challenge_id)
);

CREATE INDEX idx_challenge_participations_user_id ON challenge_participations(user_id);
CREATE INDEX idx_challenge_participations_challenge_id ON challenge_participations(challenge_id);
CREATE INDEX idx_challenge_participations_points ON challenge_participations(points DESC);
```

### Challenge Submissions Table

```sql
CREATE TABLE challenge_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participation_id UUID NOT NULL REFERENCES challenge_participations(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    outfit_id UUID REFERENCES outfits(id),
    description TEXT,
    image_url VARCHAR(500),
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_challenge_submissions_participation_id ON challenge_submissions(participation_id);
CREATE INDEX idx_challenge_submissions_day ON challenge_submissions(day_number);
```

---

## Frontend Components

### ShareModal.tsx
Generate share link and configure sharing

### CommunityFeed.tsx
Browse and interact with community outfits

### StylistMarketplace.tsx
Browse and book stylists

### StylistSessionView.tsx
Manage stylist sessions and recommendations

### ChallengeBrowser.tsx
Browse and join challenges

### ChallengeProgress.tsx
Track challenge progress and submissions

### Leaderboard.tsx
Display challenge leaderboard

---

## Success Metrics

- **Share Rate:** 15% of outfits are shared
- **Community Engagement:** 20% DAU browse community feed
- **Stylist Bookings:** 5% of users book stylist session
- **Challenge Participation:** 10% of users join at least one challenge
- **User Satisfaction:** 4.3/5 stars for social features

---

## Future Enhancements

- Follow/follow other users
- Stylist reviews and recommendations
- Collaborative outfit creation with friends
- Live outfit styling sessions
- Community voting on trends
- Style contests with prizes
- Influencer collaborations
- Brand ambassador program
