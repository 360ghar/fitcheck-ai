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
class GenerationRequest(BaseModel):
    item_ids: List[UUID] = Field(..., min_items=1, max_items=10)
    pose: str = Field("front", pattern="^(front|side|back)$")
    lighting: str = Field("natural", pattern="^(natural|office|evening)$")
```

## Business Rules

### Wardrobe Rules
- Items must belong to the authenticated user.
- Categories are restricted to a predefined list.
- Each item can have max 5 images.

### Outfit Rules
- An outfit must contain at least 1 item.
- Max 10 items per outfit.
- Cannot generate an outfit with items currently marked as "dirty" or "laundry".

### AI Limits
Enforced from `backend/app/core/config.py` (`PLAN_*`); see
`SubscriptionService.get_plan_limits`.

- Monthly outfit generations: Free 50, Plus 350, Pro 1,000.
- Monthly item extractions: Free 25, Plus 100, Pro 200.
- Daily photoshoot images: Free 10, Plus 30, Pro 50.

## Error Responses
- All validation errors return a `422 Unprocessable Entity` with a detailed `details` object mapping field names to error messages.
