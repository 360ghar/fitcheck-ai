# Implementation: Validation

## Overview

Input validation, business rules, and constraints for FitCheck AI.

## Frontend Validation (Zod)

### User Profile Schema
```typescript
const profileSchema = z.object({
  fullName: z.string().min(2, "Name is too short").max(100),
  email: z.string().email("Invalid email address"),
});
```

### Item Schema
```typescript
const itemSchema = z.object({
  name: z.string().min(1, "Name is required"),
  category: z.enum(['tops', 'bottoms', 'shoes', 'accessories', 'outerwear']),
  price: z.number().nonnegative().optional(),
  tags: z.array(z.string()).max(10, "Too many tags"),
});
```

## Backend Validation (Pydantic v2)

### Outfit Generation Request
```python
class GenerateOutfitRequest(BaseModel):
    items: List[OutfitItemInput] = Field(..., min_length=1)  # >= 1 item required

    @field_validator("items")
    def validate_item_count(cls, value):
        if len(value) > settings.AI_MAX_OUTFIT_ITEMS:  # = 100 (config.py)
            raise ValueError("Too many items")
```
(Real model: `backend/app/models/ai.py` `GenerateOutfitRequest`; pose/lighting
are free-form strings with `max_length` on `GenerationRequest` in
`backend/app/models/outfit.py` — there are no enum `pattern` constraints.)

## Business Rules

### Wardrobe Rules
- Items must belong to the authenticated user.
- Categories are restricted to a predefined list.
- No backend-enforced cap on images per item — uploads accept up to
  `MAX_UPLOAD_FILES = 50` files per request and any count can be attached to
  an item (`backend/app/core/uploads.py`, `backend/app/api/v1/items.py`). The
  "Up to 5 images, max 5MB each" limit that appears in the UI applies to
  **support-ticket attachments**, not item images
  (`frontend/src/components/settings/SupportPanel.tsx:288`,
  `flutter/lib/features/feedback/views/feedback_page.dart:376`).

### Outfit Rules
- An outfit must contain at least 1 unique item (`OutfitCreate` validator,
  `backend/app/models/outfit.py:91-101`).
- No fixed max item count on outfit creation. The only item-count ceiling is
  `AI_MAX_OUTFIT_ITEMS = 100` (`backend/app/core/config.py:357`), enforced on
  AI outfit-generation requests only (`GenerateOutfitRequest` in
  `backend/app/models/ai.py`).

### Recommendations Rules
- Items marked `laundry`, `repair`, or `donate` are excluded from
  recommendation candidates (`backend/app/api/v1/recommendations.py:520-521`
  and `:904`) and from astrology recommendations
  (`backend/app/services/astrology_service.py:95, 425`). Outfit generation
  itself does NOT gate on item condition.

### AI Limits
Enforced from `backend/app/core/config.py` (`PLAN_*`); see
`SubscriptionService.get_plan_limits`.

- Monthly outfit generations: Free 50, Plus 350, Pro 1,000.
- Monthly item extractions: Free 50, Plus 200, Pro 400.
- Daily photoshoot images: Free 10, Plus 30, Pro 50 (enforced by
  `PhotoshootService._get_daily_limit` via `PLAN_*_DAILY_PHOTOSHOOT_IMAGES` in
  `backend/app/core/config.py`; `SubscriptionService.get_plan_limits` covers the
  monthly limits only).

## Error Responses
- All validation errors return a `422 Unprocessable Entity` with a detailed `details` object mapping field names to error messages.
