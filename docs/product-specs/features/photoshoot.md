# Feature: AI Photoshoot Generator

## Overview

The AI Photoshoot Generator creates professional-style images of users based on uploaded photos. Users upload 1-4 photos, select a use case (LinkedIn, Dating App, Model Portfolio, Instagram, or Custom), and receive AI-generated professional images.

## User Value

- **Professional Quality:** Get professional-looking photos without expensive photoshoots
- **Multiple Use Cases:** Optimized images for LinkedIn, dating apps, portfolios, and social media
- **Quick Results:** Generate up to 10 images in a single session
- **Try Before Subscribe:** Landing page trial with 2 free images for anonymous users

## Usage Limits

| Plan | Daily Limit | Notes |
|------|-------------|-------|
| Demo (Anonymous) | 2 images | Landing page trial, IP-based rate limiting |
| Free | 10 images/day | Resets at midnight UTC |
| Pro | 50 images/day | Resets at midnight UTC |

## Functional Requirements

### 1. Photo Upload

**Priority:** P0 (MVP)

**Description:** Users upload 1-4 photos that will be used as reference for AI generation.

**Requirements:**

**Upload Interface:**
- Upload 1-4 photos (single photo for demo mode)
- Drag and drop or tap to select
- Preview uploaded photos before generation
- Remove individual photos
- Clear all photos

**Photo Guidelines:**
- Clear face visibility for best results
- Good lighting recommended
- Supported formats: PNG, JPG, JPEG, WebP
- Maximum file size: 10MB per image

**Acceptance Criteria:**
- [ ] Users can upload 1-4 photos
- [ ] Photos can be previewed and removed
- [ ] Drag and drop upload works
- [ ] File type and size validation

---

### 2. Use Case Selection

**Priority:** P0 (MVP)

**Description:** Users select the intended use case to optimize AI generation for specific contexts.

**Use Case Options:**
| Use Case | Description | Style Focus |
|----------|-------------|-------------|
| LinkedIn | Professional headshots and portraits | Business attire, confident pose, neutral background |
| Dating App | Approachable, friendly photos | Natural smile, warm lighting, casual-smart attire |
| Model Portfolio | Editorial and fashion-forward | Dynamic poses, creative lighting, varied expressions |
| Instagram | Social media ready content | Trendy aesthetic, lifestyle shots, vibrant colors |
| Custom | User-defined prompt | Full control over generation style |

**Custom Prompt:**
- Available when "Custom" use case is selected
- Free-text input for specific requirements
- Character limit: 500 characters

---

### 3. Image Count Selection

**Priority:** P0 (MVP)

**Description:** Slider to select the number of images to generate.

**Requirements:**
- Range: 1-10 images
- Default: 10 images
- Shows remaining daily quota
- Auto-caps to remaining quota if user tries to exceed

**Display:**
- "10 images (7 remaining today)"
- Slider visual feedback
- Warning when approaching limit

---

### 4. Image Generation

**Priority:** P0 (MVP)

**Description:** Generate AI-powered professional images.

**Generation Process:**
- Send photos and configuration to the configured backend AI provider/model
- Generate requested number of images
- Show progress indicator
- Display results in gallery format

**Progress Tracking:**
- Progress bar with percentage
- Image count: "3/10 images generated"
- Estimated time remaining
- Cancel option

---

### 5. Results Display

**Priority:** P0 (MVP)

**Description:** Display generated images with download options.

**Results Interface:**
- Grid gallery of generated images
- Tap to view full-screen
- Download individual images
- Download all images (separate files, not zipped)
- Start a new generation session

**Download Options:**
- Single image download
- Download all (separate files)
- Save to device gallery (mobile)

---

### 6. Referral Integration

**Priority:** P1

**Description:** Prompt users to refer friends when daily limit is reached.

**Trigger:**
- User attempts to generate after exhausting daily limit
- Modal dialog appears

**Modal Content:**
- "You've used all 10 free images today!"
- "Refer a Friend" CTA (copy/share referral link)
- "Upgrade to Pro" CTA
- Benefit message: "Refer a friend, both get 1 month Pro free"

---

### 7. Landing Page Trial

**Priority:** P0 (MVP)

**Description:** Anonymous users can try the feature on the landing page.

**Demo Restrictions:**
- Single photo upload only
- Fixed use case selection (no custom prompt)
- 2 images generated
- IP-based rate limiting (1 generation/day)

**Signup CTA:**
- After generation: "Want more? Sign up for 10 free images/day!"
- Prominent sign-up button

---

## API Endpoints

### Generate Photoshoot (Authenticated)

```
POST /api/v1/photoshoot/generate
```

**Request:**
```json
{
  "photos": ["base64...", "base64..."],
  "use_case": "linkedin",
  "custom_prompt": null,
  "num_images": 10
}
```

**Response (200):**
```json
{
  "data": {
    "session_id": "ps_abc123",
    "status": "complete",
    "images": [
      {
        "id": "img_1",
        "index": 0,
        "image_base64": "base64...",
        "image_url": "https://..."
      }
    ],
    "usage": {
      "used_today": 10,
      "limit_today": 10,
      "remaining": 0,
      "plan_type": "free",
      "resets_at": "2026-01-17T00:00:00Z"
    }
  }
}
```

### Demo Photoshoot (Anonymous)

```
POST /api/v1/photoshoot/demo
```

**Request:**
```json
{
  "photo": "base64...",
  "use_case": "linkedin"
}
```

**Response (200):**
```json
{
  "data": {
    "session_id": "ps_demo_xyz",
    "status": "complete",
    "images": [
      {
        "id": "img_1",
        "index": 0,
        "image_base64": "base64...",
        "image_url": "https://..."
      }
    ],
    "remaining_today": 0,
    "signup_cta": "Sign up for 10 free images per day!"
  }
}
```

### Get Usage Stats

```
GET /api/v1/photoshoot/usage
```

**Response (200):**
```json
{
  "data": {
    "used_today": 5,
    "limit_today": 10,
    "remaining": 5,
    "plan_type": "free",
    "resets_at": "2026-01-17T00:00:00Z"
  }
}
```

### Get Use Cases

```
GET /api/v1/photoshoot/use-cases
```

**Response (200):**
```json
{
  "data": {
    "use_cases": [
      {"id": "linkedin", "label": "LinkedIn Profile", "description": "Professional headshots"},
      {"id": "dating_app", "label": "Dating App", "description": "Approachable photos"},
      {"id": "model_portfolio", "label": "Model Portfolio", "description": "Editorial shots"},
      {"id": "instagram", "label": "Instagram Content", "description": "Social media ready"},
      {"id": "custom", "label": "Custom", "description": "Your own prompt"}
    ]
  }
}
```

---

## Database Schema

### Photoshoot Usage (subscription_usage table)

```sql
-- Added columns to subscription_usage table
daily_photoshoot_images INTEGER DEFAULT 0,
last_photoshoot_reset DATE
```

### IP Rate Limits (for demo)

```python
DEMO_RATE_LIMITS = {
    "extract": 3,       # 3 extractions per day
    "try_on": 2,        # 2 try-on generations per day
    "photoshoot": 2,    # 2 photoshoot images per day
}
```

---

## Frontend Components

### Flutter
| Component | Location |
|-----------|----------|
| PhotoshootContent | `lib/features/photoshoot/views/photoshoot_content.dart` |
| PhotoshootController | `lib/features/photoshoot/controllers/photoshoot_controller.dart` |
| PhotoshootUploadStep | `lib/features/photoshoot/views/photoshoot_upload_step.dart` |
| PhotoshootConfigureStep | `lib/features/photoshoot/views/photoshoot_configure_step.dart` |
| PhotoshootGeneratingStep | `lib/features/photoshoot/views/photoshoot_generating_step.dart` |
| PhotoshootResultsStep | `lib/features/photoshoot/views/photoshoot_results_step.dart` |
| ReferralLimitDialog | `lib/features/photoshoot/controllers/photoshoot_controller.dart` |

### React Web
| Component | Location |
|-----------|----------|
| PhotoshootPage | `src/pages/photoshoot/PhotoshootPage.tsx` |
| PhotoshootUploadStep | `src/pages/photoshoot/components/PhotoshootUploadStep.tsx` |
| PhotoshootConfigureStep | `src/pages/photoshoot/components/PhotoshootConfigureStep.tsx` |
| PhotoshootGeneratingStep | `src/pages/photoshoot/components/PhotoshootGeneratingStep.tsx` |
| PhotoshootResultsStep | `src/pages/photoshoot/components/PhotoshootResultsStep.tsx` |
| PhotoshootDemo | `src/components/landing/PhotoshootDemo.tsx` |

---

## Navigation

### Mobile (Flutter)
- Bottom navigation bar: **Home | Photoshoot | Wardrobe | Outfits | More**
- Try-On moved to More menu

### Web (React)
- Sidebar navigation with Photoshoot entry
- Landing page demo card (2-image trial)

### Setup Notes
- Supabase: run `backend/db/supabase/migrations/010_photoshoot_generator.sql` in the Supabase SQL editor to enable daily usage tracking.
- Backend: configure AI provider keys in `.env` (`AI_GEMINI_*`, `AI_OPENAI_*`, or `AI_CUSTOM_*`) and set `AI_DEFAULT_PROVIDER` as needed.

---

## Success Metrics

- **Generation Success Rate:** >95%
- **Generation Speed:** <60 seconds for 10 images
- **User Satisfaction:** 4.0/5 stars
- **Demo Conversion Rate:** 15% of demo users sign up
- **Daily Active Users:** Track Photoshoot tab usage

---

## Error Handling

| Code | Error | User Message |
|------|-------|--------------|
| 400 | Invalid request | "Please check your photos and try again" |
| 429 | Rate limit exceeded | "Daily limit reached. Sign up for more!" |
| 500 | Generation failed | "Something went wrong. Please try again." |
| 503 | Service unavailable | "Service temporarily unavailable" |

---

## Future Enhancements

- Background selection options
- Style presets (lighting, mood)
- Batch processing for multiple use cases
- Image editing/cropping before generation
- AR preview integration
- Video generation
