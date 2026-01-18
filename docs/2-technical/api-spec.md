# API Specification

## Overview

This document provides a complete specification for all FastAPI endpoints, including request/response examples, error codes, and authentication requirements.

## Base URL

```
Development: http://localhost:8000/api/v1
Production: https://api.fitcheck.ai/api/v1
```

## Authentication

All API endpoints (except auth endpoints) require a valid JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Response Format

### Success Response

```json
{
  "data": {},
  "message": "Success message"
}
```

### Error Response

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

## Status Codes

| Code | Description |
|------|-------------|
| 200 | OK |
| 201 | Created |
| 202 | Accepted |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 413 | Payload Too Large |
| 415 | Unsupported Media Type |
| 422 | Unprocessable Entity |
| 429 | Too Many Requests |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

---

## Authentication Endpoints

### POST /auth/register

Register a new user.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "full_name": "John Doe"
}
```

**Response (201):**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "full_name": "John Doe"
    },
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "requires_email_confirmation": false
  }
}
```

**Errors:**
- `400`: Invalid email or password format
- `409`: Email already registered
- `503`: Database schema not initialized/complete

---

### POST /auth/login

Login with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "data": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "full_name": "John Doe"
    }
  }
}
```

**Errors:**
- `401`: Invalid credentials
- `403`: Email not confirmed

---

### POST /auth/logout

Logout user (invalidate token).

**Headers:**
```
Authorization: Bearer <token>
```

**Response (204):** No Content

---

### POST /auth/refresh

Refresh access token.

**Request:**
```json
{
  "refresh_token": "refresh_token"
}
```

**Response (200):**
```json
{
  "data": {
    "access_token": "new_jwt_token",
    "refresh_token": "new_refresh_token",
    "user": { "id": "uuid", "email": "user@example.com" }
  }
}
```

---

### POST /auth/reset-password

Request password reset.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Password reset email sent"
}
```

---

### POST /auth/confirm-reset-password

Confirm password reset using a Supabase recovery session.

**Request:**
```json
{
  "access_token": "access_token_from_recovery_link",
  "refresh_token": "refresh_token_from_recovery_link",
  "new_password": "NewSecurePass123!"
}
```

**Response (200):**
```json
{
  "message": "Password reset successfully"
}
```

---

## AI Endpoints

These endpoints provide server-side AI processing for item extraction and outfit generation.

### POST /ai/extract-items

Extract clothing items from an uploaded image using AI.

**Request (multipart/form-data):**
```
file: <image>
```

**Response (200):**
```json
{
  "data": {
    "items": [
      {
        "name": "Blue Oxford Shirt",
        "category": "tops",
        "sub_category": "shirt",
        "colors": ["blue", "white"],
        "material": "cotton",
        "pattern": "solid",
        "brand": null,
        "confidence": 0.92
      }
    ],
    "processing_time_ms": 1250
  }
}
```

---

### POST /ai/generate-outfit

Generate a realistic outfit visualization image.

**Request:**
```json
{
  "outfit_id": "outfit_uuid",
  "body_profile_id": "body_profile_uuid",
  "pose": "front",
  "lighting": "natural",
  "variations": 1
}
```

**Response (202):**
```json
{
  "data": {
    "generation_id": "gen_uuid",
    "status": "processing",
    "estimated_time": 30
  }
}
```

---

### POST /ai/generate-product-image

Generate a clean product image from a clothing item photo.

**Request (multipart/form-data):**
```
file: <image>
item_id: "item_uuid" (optional)
```

**Response (200):**
```json
{
  "data": {
    "image_url": "https://...",
    "thumbnail_url": "https://..."
  }
}
```

---

### GET /ai/settings

Get the current user's AI provider settings.

**Response (200):**
```json
{
  "data": {
    "provider": "gemini",
    "model": "gemini-3-flash-preview",
    "has_custom_api_key": false,
    "available_providers": ["gemini", "openai", "custom"]
  }
}
```

---

### PUT /ai/settings

Update AI provider settings (per-user configuration).

**Request:**
```json
{
  "provider": "openai",
  "api_key": "sk-...",
  "model": "gpt-4o"
}
```

**Response (200):**
```json
{
  "data": {
    "provider": "openai",
    "model": "gpt-4o",
    "has_custom_api_key": true
  },
  "message": "AI settings updated"
}
```

---

### POST /ai/settings/test

Test AI provider configuration.

**Request:**
```json
{
  "provider": "openai",
  "api_key": "sk-..."
}
```

**Response (200):**
```json
{
  "data": {
    "success": true,
    "provider": "openai",
    "response_time_ms": 450
  }
}
```

---

## User Endpoints

### GET /users/me

Get current user profile.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "avatar_url": "https://...",
    "created_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### PUT /users/me

Update current user profile.

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "full_name": "Jane Doe",
  "avatar_url": "https://..."
}
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Jane Doe",
    "avatar_url": "https://...",
    "updated_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### GET /users/preferences

Get user preferences.

**Response (200):**
```json
{
  "data": {
    "favorite_colors": ["blue", "black"],
    "preferred_styles": ["casual", "minimalist"],
    "liked_brands": ["Zara", "H&M"],
    "disliked_patterns": ["stripes"],
    "preferred_occasions": ["work"],
    "color_temperature": "cool",
    "style_personality": "minimalist",
    "data_points_collected": 12
  }
}
```

---

### PUT /users/preferences

Update user preferences.

**Request:**
```json
{
  "favorite_colors": ["red", "black"],
  "preferred_styles": ["formal"]
}
```

**Response (200):**
```json
{
  "data": {
    "favorite_colors": ["red", "black"],
    "preferred_styles": ["formal"],
    "liked_brands": [],
    "disliked_patterns": [],
    "preferred_occasions": [],
    "color_temperature": null,
    "style_personality": null,
    "data_points_collected": 12
  },
  "message": "Updated"
}
```

---

### GET /users/settings

Get user settings.

**Response (200):**
```json
{
  "data": {
    "default_location": "New York, NY",
    "timezone": "America/New_York",
    "language": "en",
    "measurement_units": "imperial",
    "notifications_enabled": true,
    "email_marketing": false,
    "dark_mode": false
  }
}
```

---

### PUT /users/settings

Update user settings.

**Request:**
```json
{
  "default_location": "New York, NY",
  "measurement_units": "metric",
  "dark_mode": true
}
```

**Response (200):**
```json
{
  "data": {
    "default_location": "New York, NY",
    "timezone": null,
    "language": "en",
    "measurement_units": "metric",
    "notifications_enabled": true,
    "email_marketing": false,
    "dark_mode": true
  },
  "message": "Updated"
}
```

---

### POST /users/me/avatar

Upload a new avatar image for the current user.

**Request (multipart/form-data):**
```
file: <image>
```

**Response (200):**
```json
{
  "data": {
    "avatar_url": "https://..."
  }
}
```

---

### DELETE /users/me

Delete the current user's account (best-effort).

**Response (204):** No Content

---

### GET /users/body-profiles

List body profiles for outfit visualization.

**Response (200):**
```json
{
  "data": {
    "body_profiles": [
      {
        "id": "uuid",
        "name": "Default",
        "height_cm": 170,
        "weight_kg": 65,
        "body_shape": "athletic",
        "skin_tone": "medium",
        "is_default": true
      }
    ]
  }
}
```

---

### POST /users/body-profiles

Create a new body profile.

**Request:**
```json
{
  "name": "Work profile",
  "height_cm": 170,
  "weight_kg": 65,
  "body_shape": "athletic",
  "skin_tone": "medium",
  "is_default": false
}
```

**Response (201):**
```json
{
  "data": {
    "id": "uuid",
    "name": "Work profile",
    "height_cm": 170,
    "weight_kg": 65,
    "body_shape": "athletic",
    "skin_tone": "medium",
    "is_default": false
  }
}
```

---

### PUT /users/body-profiles/{profile_id}

Update a body profile.

**Request:**
```json
{
  "name": "Updated profile name",
  "is_default": true
}
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "name": "Updated profile name",
    "is_default": true
  },
  "message": "Updated"
}
```

---

### DELETE /users/body-profiles/{profile_id}

Delete a body profile.

**Response (204):** No Content

---

### GET /users/body-profile

Get the current user's most recent/default body profile (used for visualization).

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "name": "Default",
    "height_cm": 170,
    "weight_kg": 65,
    "body_shape": "athletic",
    "skin_tone": "medium",
    "is_default": true
  },
  "message": "OK"
}
```

---

### PUT /users/body-profile

Create or update the user's body profile (upsert).

**Request:**
```json
{
  "name": "Default",
  "height_cm": 170,
  "weight_kg": 65,
  "body_shape": "athletic",
  "skin_tone": "medium",
  "is_default": true
}
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "name": "Default",
    "height_cm": 170,
    "weight_kg": 65,
    "body_shape": "athletic",
    "skin_tone": "medium",
    "is_default": true
  },
  "message": "Updated"
}
```

---

### GET /users/dashboard

Fetch a lightweight dashboard aggregate (user + stats + recent items/outfits).

**Response (200):**
```json
{
  "data": {
    "user": { "id": "uuid", "email": "user@example.com", "full_name": "John Doe" },
    "stats": { "total_items": 10, "total_outfits": 3 },
    "recent_items": [],
    "recent_outfits": [],
    "recommendations": []
  }
}
```

---

## Item Endpoints

### POST /items

Create new item (manual entry or AI-assisted).

**Request (JSON):**
```json
{
  "name": "Blue T-Shirt",
  "category": "tops",
  "brand": "Zara",
  "colors": ["blue"],
  "price": 29.99,
  "images": [
    {
      "image_url": "https://...",
      "thumbnail_url": "https://...",
      "storage_path": "items/user_uuid/item_uuid.jpg",
      "is_primary": true
    }
  ]
}
```

**Response (201):**
```json
{
  "data": {
    "id": "item_uuid",
    "name": "Blue T-Shirt",
    "category": "tops",
    "brand": "Zara",
    "colors": ["blue"],
    "price": 29.99,
    "images": [
      {
        "id": "image_uuid",
        "image_url": "https://...",
        "is_primary": true
      }
    ],
    "created_at": "2026-01-06T00:00:00Z"
  }
}
```

**Errors:**
- `400`: Invalid data
- `413`: File too large (>10MB)
- `415`: Invalid file type

---

### POST /items/upload

Upload item images to storage (AI extraction can be triggered via POST /ai/extract-items).

**Request (multipart/form-data):**
```
files: [<file1>, <file2>, ...]
```

**Response (202):**
```json
{
  "data": {
    "upload_id": "upload_uuid",
    "status": "completed",
    "uploaded_count": 5,
    "images": [
      {
        "image_url": "https://...",
        "thumbnail_url": "https://...",
        "storage_path": "items/user_uuid/upload_uuid.jpg",
        "filename": "photo.jpg"
      }
    ]
  }
}
```

---

### Item Extraction (Server-Side)

Item extraction is performed server-side via the Backend AI API:

- `POST /api/v1/ai/extract-items` with image file
- Returns structured JSON with category/colors/material/brand/confidence
- Supports multiple AI providers (Gemini, OpenAI, custom proxy)

The backend handles both storage (`POST /items/upload`) and AI extraction (`POST /ai/extract-items`).

---

### GET /items

Browse items with filters.

**Query Parameters:**
```
category=tops,shoes
color=blue
brand=Zara
condition=clean
page=1
page_size=20
search=blue t-shirt
is_favorite=true
```

**Response (200):**
```json
{
  "data": {
    "items": [
      {
        "id": "item_uuid",
        "name": "Blue T-Shirt",
        "category": "tops",
        "brand": "Zara",
        "colors": ["blue"],
        "price": 29.99,
        "usage_times_worn": 5,
        "cost_per_wear": 5.99,
        "images": [
          {
            "id": "image_uuid",
            "image_url": "https://...",
            "thumbnail_url": "https://...",
            "is_primary": true
          }
        ],
        "created_at": "2026-01-06T00:00:00Z"
      }
    ],
    "total": 50,
    "page": 1,
    "total_pages": 3
  }
}
```

---

### GET /items/{id}

Get item details.

**Response (200):**
```json
{
  "data": {
    "id": "item_uuid",
    "name": "Blue T-Shirt",
    "category": "tops",
    "sub_category": "t-shirt",
    "brand": "Zara",
    "colors": ["blue"],
    "size": "M",
    "price": 29.99,
    "purchase_date": "2026-01-01",
    "purchase_location": "Online",
    "tags": ["casual", "summer"],
    "notes": "Good condition",
    "condition": "clean",
    "usage_times_worn": 5,
    "usage_last_worn": "2026-01-05T00:00:00Z",
    "cost_per_wear": 5.99,
    "is_favorite": false,
    "images": [
      {
        "id": "image_uuid",
        "image_url": "https://...",
        "thumbnail_url": "https://...",
        "is_primary": true,
        "width": 800,
        "height": 1200
      }
    ],
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-05T00:00:00Z"
  }
}
```

---

### PUT /items/{id}

Update item.

**Request:**
```json
{
  "name": "Blue T-Shirt",
  "notes": "Worn twice this month",
  "condition": "clean"
}
```

**Response (200):**
```json
{
  "data": {
    "id": "item_uuid",
    "name": "Blue T-Shirt",
    "notes": "Worn twice this month",
    "condition": "clean",
    "updated_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### DELETE /items/{id}

Delete item.

**Response (204):** No Content

---

### POST /items/{id}/favorite

Toggle favorite status for an item.

**Response (200):**
```json
{
  "data": { "id": "item_uuid", "is_favorite": true }
}
```

---

### POST /items/{id}/wear

Increment wear count for an item.

**Response (200):**
```json
{
  "data": { "id": "item_uuid", "usage_times_worn": 6 }
}
```

---

### POST /items/{id}/images

Upload an additional image for an existing item.

**Request (multipart/form-data):**
```
file: <image>
is_primary: false
```

**Response (201):**
```json
{
  "data": {
    "id": "image_uuid",
    "item_id": "item_uuid",
    "image_url": "https://...",
    "thumbnail_url": "https://...",
    "storage_path": "items/item_uuid/image_uuid.png",
    "is_primary": false
  }
}
```

---

### DELETE /items/{id}/images/{image_id}

Delete an item image.

**Response (200):**
```json
{
  "data": { "deleted": true }
}
```

---

### POST /items/batch-delete

Batch delete items.

**Request:**
```json
{
  "item_ids": ["uuid1", "uuid2"]
}
```

**Response (200):**
```json
{
  "data": { "deleted_count": 2 }
}
```

---

### GET /items/stats

Get item statistics for dashboard/analytics.

**Response (200):**
```json
{
  "data": {
    "total_items": 50,
    "items_by_category": { "tops": 20, "bottoms": 10 },
    "items_by_color": { "black": 12, "blue": 8 },
    "items_by_condition": { "clean": 40, "laundry": 10 },
    "total_value": 1234.56
  }
}
```

---

### GET /items/search

Search items by name/brand/notes.

**Query Parameters:**
```
q=jeans
limit=10
```

**Response (200):**
```json
{
  "data": { "items": [ { "id": "item_uuid", "name": "Black Jeans", "images": [] } ] }
}
```

---

### GET /items/by-category/{category}

Get all items in a category.

**Response (200):**
```json
{
  "data": { "items": [ { "id": "item_uuid", "category": "tops", "images": [] } ] }
}
```

---

### POST /items/{id}/categorize

Compute derived metadata (best-effort) to power recommendations.

**Response (200):**
```json
{
  "data": {
    "category": "tops",
    "colors": ["blue"],
    "style": "casual",
    "materials": ["cotton"],
    "seasonal_tags": ["all-season"],
    "confidence": 0.7
  }
}
```

---

### PUT /items/{id}/categories

Update category-related fields (user override).

**Request:**
```json
{
  "category": "tops",
  "sub_category": "t-shirt",
  "colors": ["blue"],
  "style": "casual",
  "materials": ["cotton"],
  "seasonal_tags": ["all-season"]
}
```

**Response (200):**
```json
{
  "data": { "id": "item_uuid", "category": "tops", "images": [] },
  "message": "Updated"
}
```

---

## Outfit Endpoints

### POST /outfits/create

Create new outfit from selected items.

**Request:**
```json
{
  "item_ids": ["item1_uuid", "item2_uuid", "item3_uuid"],
  "name": "Casual Friday Outfit",
  "tags": ["work", "casual"]
}
```

**Response (201):**
```json
{
  "data": {
    "id": "outfit_uuid",
    "name": "Casual Friday Outfit",
    "item_ids": ["item1_uuid", "item2_uuid", "item3_uuid"],
    "tags": ["work", "casual"],
    "is_draft": true,
    "images": [],
    "created_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### GET /outfits/available-items

Get a simplified list of wardrobe items suitable for outfit builders.

**Response (200):**
```json
{
  "data": [
    {
      "id": "item_uuid",
      "name": "Blue T-Shirt",
      "category": "tops",
      "colors": ["blue"],
      "image_url": "https://..."
    }
  ]
}
```

---

### POST /outfits/{id}/favorite

Toggle favorite status for an outfit.

**Response (200):**
```json
{
  "data": { "id": "outfit_uuid", "is_favorite": true }
}
```

---

### POST /outfits/{id}/wear

Increment wear count for an outfit.

**Response (200):**
```json
{
  "data": { "id": "outfit_uuid", "worn_count": 4, "last_worn_at": "2026-01-06T00:00:00Z" }
}
```

---

### POST /outfits/{id}/duplicate

Duplicate an outfit.

**Response (201):**
```json
{
  "data": { "id": "new_outfit_uuid", "name": "Copy of Casual Friday Outfit", "images": [] }
}
```

---

### POST /outfits/{id}/items

Add an item to an outfit.

**Request:**
```json
{
  "item_id": "item_uuid"
}
```

**Response (200):**
```json
{
  "data": { "id": "outfit_uuid", "item_ids": ["item1_uuid", "item_uuid"], "images": [] },
  "message": "Updated"
}
```

---

### DELETE /outfits/{id}/items/{item_id}

Remove an item from an outfit.

**Response (200):**
```json
{
  "data": { "id": "outfit_uuid", "item_ids": ["item1_uuid"], "images": [] },
  "message": "Updated"
}
```

---

### POST /outfits/{id}/generate

Create an AI generation record (image generation runs server-side via Backend AI API).

**Request:**
```json
{
  "pose": "front",
  "variations": 1,
  "lighting": "natural",
  "body_profile_id": "body_profile_uuid"
}
```

**Response (202):**
```json
{
  "data": {
    "generation_id": "gen_uuid",
    "status": "processing",
    "estimated_time": 30
  }
}
```

---

### POST /outfits/{id}/images

Upload an outfit image (manual or AI) and optionally complete a generation.

**Request (multipart/form-data):**
```
file: <file>
pose: "front" (optional)
lighting: "natural" (optional)
body_profile_id: "uuid" (optional)
generation_id: "gen_uuid" (optional)
is_primary: false
```

**Response (201):**
```json
{
  "data": {
    "id": "outfit_img_uuid",
    "image_url": "https://...",
    "thumbnail_url": "https://...",
    "generation_type": "ai",
    "pose": "front",
    "lighting": "natural"
  }
}
```

---

### DELETE /outfits/{id}/images/{image_id}

Delete an outfit image.

**Response (200):**
```json
{
  "data": { "deleted": true }
}
```

---

### GET /outfits/generation/{generation_id}

Check generation status.

**Response (200):**
```json
{
  "data": {
    "status": "completed",
    "progress": 100,
    "images": [
      "https://..."
    ]
  }
}
```

---

### GET /outfits

Browse outfits.

**Query Parameters:**
```
is_favorite=true
tags=work,casual
page=1
page_size=20
sort=created_desc
```

**Response (200):**
```json
{
  "data": {
    "outfits": [...],
    "total": 25,
    "page": 1,
    "total_pages": 2
  }
}
```

---

### GET /outfits/{id}

Get outfit details.

**Response (200):**
```json
{
  "data": {
    "id": "outfit_uuid",
    "name": "Casual Friday Outfit",
    "item_ids": ["item1_uuid", "item2_uuid", "item3_uuid"],
    "items": [...],
    "tags": ["work", "casual"],
    "is_favorite": false,
    "is_draft": false,
    "worn_count": 3,
    "last_worn_at": "2026-01-05T00:00:00Z",
    "created_at": "2026-01-01T00:00:00Z",
    "images": [
      {
        "id": "outfit_img_uuid",
        "image_url": "https://...",
        "pose": "front",
        "lighting": "natural"
      }
    ]
  }
}
```

---

### PUT /outfits/{id}

Update outfit.

**Request:**
```json
{
  "name": "Updated Outfit Name",
  "is_favorite": true
}
```

**Response (200):**
```json
{
  "data": {
    "id": "outfit_uuid",
    "name": "Updated Outfit Name",
    "is_favorite": true,
    "updated_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### DELETE /outfits/{id}

Delete outfit.

**Response (204):** No Content

---

### POST /outfits/{id}/share

Enable public sharing for an outfit and return a share URL.

**Request:**
```json
{
  "visibility": "public",
  "expires_at": null,
  "allow_feedback": true,
  "custom_caption": "Optional caption"
}
```

**Response (201):**
```json
{
  "data": {
    "share_link": {
      "url": "https://fitcheck.ai/shared/outfits/outfit_uuid",
      "qr_code_url": null,
      "expires_at": null,
      "views": 0
    }
  }
}
```

---

### GET /outfits/public/{id}

Public (no-auth) shared outfit view. Returns `404` if the outfit is not public.

**Response (200):**
```json
{
  "data": {
    "id": "outfit_uuid",
    "name": "Casual Friday Outfit",
    "description": "Optional",
    "style": "casual",
    "season": "all-season",
    "tags": ["work", "casual"],
    "images": [{ "image_url": "https://..." }],
    "items": [{ "id": "item_uuid", "name": "Blue T-Shirt", "category": "tops" }]
  }
}
```

---

### POST /shared-outfits/{share_id}/feedback

Leave feedback on a shared outfit (auth optional).

**Request:**
```json
{
  "rating": 5,
  "comment": "Loved this combo!"
}
```

**Response (201):**
```json
{
  "data": {
    "id": "feedback_uuid",
    "shared_outfit_id": "share_uuid",
    "user_id": "user_uuid_or_null",
    "rating": 5,
    "comment": "Loved this combo!"
  },
  "message": "Created"
}
```

---

### POST /outfits/collections

Create a collection to group outfits.

**Request:**
```json
{
  "name": "Workweek Fits",
  "description": "Outfits for Mon–Fri",
  "is_favorite": false,
  "outfit_ids": ["outfit_uuid"]
}
```

**Response (201):**
```json
{
  "data": {
    "id": "collection_uuid",
    "name": "Workweek Fits",
    "outfit_count": 1
  }
}
```

---

### GET /outfits/collections

List outfit collections.

**Response (200):**
```json
{
  "data": {
    "collections": [
      { "id": "collection_uuid", "name": "Workweek Fits", "outfit_count": 1 }
    ]
  }
}
```

---

### PUT /outfits/collections/{collection_id}

Update collection metadata and optionally replace outfits.

**Request:**
```json
{
  "name": "Updated Name",
  "outfit_ids": ["outfit_uuid"]
}
```

**Response (200):**
```json
{
  "data": { "id": "collection_uuid", "name": "Updated Name", "outfit_count": 1 }
}
```

---

### PUT /outfits/collections/{collection_id}/outfits

Replace collection outfits.

**Request:**
```json
{
  "outfit_ids": ["outfit_uuid"]
}
```

**Response (200):**
```json
{
  "data": { "id": "collection_uuid", "outfit_count": 1 }
}
```

---

### DELETE /outfits/collections/{collection_id}

Delete a collection.

**Response (204):** No Content

---

### GET /outfits/stats

Get outfit statistics for dashboard/analytics.

**Response (200):**
```json
{
  "data": {
    "total_outfits": 25,
    "outfits_by_style": { "casual": 10, "formal": 2 },
    "outfits_by_season": { "all-season": 12, "summer": 5 }
  }
}
```

---

### GET /outfits/recently-worn

Get recently worn outfits.

**Query Parameters:**
```
limit=5
```

**Response (200):**
```json
{
  "data": { "outfits": [ { "id": "outfit_uuid", "images": [] } ] }
}
```

---

### GET /outfits/favorites

Get favorite outfits.

**Response (200):**
```json
{
  "data": { "outfits": [ { "id": "outfit_uuid", "is_favorite": true, "images": [] } ] }
}
```

---

### GET /outfits/suggestions/weather

Get simple outfit suggestions based on temperature and weather.

**Query Parameters:**
```
temperature=18.5
weather_condition=rainy
```

**Response (200):**
```json
{
  "data": {
    "suggestions": {
      "outfits": [ { "id": "outfit_uuid", "images": [] } ],
      "reasoning": "Suggested based on 18.5°C and season 'all-season'."
    }
  }
}
```

---

### POST /outfits/batch-delete

Batch delete outfits.

**Request:**
```json
{
  "outfit_ids": ["uuid1", "uuid2"]
}
```

**Response (200):**
```json
{
  "data": { "deleted_count": 2 }
}
```

---

## Recommendation Endpoints

### POST /recommendations/match

Find matching items.

**Request:**
```json
{
  "item_ids": ["item1_uuid"],
  "match_type": "all",
  "limit": 10
}
```

**Response (200):**
```json
{
  "data": {
    "matches": [
      {
        "item": {...},
        "score": 92,
        "reasons": [
          "Color: Complementary to blue",
          "Style: Matches casual aesthetic"
        ]
      }
    ],
    "complete_looks": [
      {
        "items": [...],
        "match_score": 88,
        "description": "A complete casual look"
      }
    ]
  }
}
```

---

### POST /recommendations/complete-look

Get complete outfit suggestions.

**Request:**
```json
{
  "start_item_id": "item_uuid",
  "occasion": "work",
  "limit": 5
}
```

**Response (200):**
```json
{
  "data": {
    "complete_looks": [...]
  }
}
```

---

### GET /recommendations/personalized

Get personalized recommendations.

**Query Parameters:**
```
type=outfits
limit=10
```

**Response (200):**
```json
{
  "data": {
    "items": [
      {
        "item": {...},
        "match_score": 95,
        "why_recommended": "Based on your preference for blue items",
        "based_on": "You've worn similar items 5 times"
      }
    ],
    "outfits": [...]
  }
}
```

---

### GET /recommendations/weather

Get weather-driven recommendation parameters.

**Query Parameters:**
```
location=New%20York
```

**Response (200):**
```json
{
  "data": {
    "temperature": 18.5,
    "temp_category": "mild",
    "weather_state": "cloudy",
    "preferred_categories": ["tops", "bottoms", "shoes"],
    "avoid_categories": ["swimwear"],
    "preferred_materials": ["cotton"],
    "suggested_layers": 2,
    "additional_items": ["light jacket"],
    "notes": []
  }
}
```

---

### GET /recommendations/similar

Find items similar to an existing wardrobe item (vector search when available).

**Query Parameters:**
```
item_id=item_uuid
category=tops
limit=10
```

**Response (200):**
```json
{
  "data": [
    {
      "item_id": "uuid",
      "item_name": "Blue Oxford Shirt",
      "image_url": "https://...",
      "category": "tops",
      "similarity": 87.2,
      "reasons": ["Similar style and attributes"]
    }
  ]
}
```

---

### GET /recommendations/style/{item_id}

Get a simple style analysis for an item.

**Response (200):**
```json
{
  "data": {
    "style": "casual",
    "confidence": 0.7,
    "alternative_styles": [{ "style": "business", "confidence": 0.5 }],
    "color_palette": ["navy", "white"],
    "suggested_occasions": ["casual"],
    "suggested_companions": []
  }
}
```

---

### GET /recommendations/wardrobe-gaps

Analyze wardrobe balance and identify missing essentials.

**Response (200):**
```json
{
  "data": {
    "analysis": {
      "category_breakdown": [
        { "category": "tops", "count": 4, "ideal_min": 8, "ideal_max": 20, "is_underrepresented": true }
      ],
      "missing_essentials": [
        { "category": "tops", "description": "Add more versatile tops to increase outfit options.", "priority": "high" }
      ],
      "wardrobe_completeness_score": 64
    }
  }
}
```

---

### GET /recommendations/shopping

Get shopping recommendations based on wardrobe gaps.

**Query Parameters:**
```
category=tops
budget=200
style=minimalist
```

**Response (200):**
```json
{
  "data": [
    { "category": "tops", "description": "Add more versatile tops to increase outfit options.", "priority": "high" }
  ]
}
```

---

### GET /recommendations/capsule

Generate a simple capsule wardrobe suggestion from existing favorites.

**Query Parameters:**
```
season=all-season
style=casual
item_count=20
```

**Response (200):**
```json
{
  "data": {
    "name": "All-season capsule",
    "description": "A minimal set of versatile items from your wardrobe.",
    "items": [],
    "outfits": [],
    "statistics": { "total_outfits_possible": 30, "cost_per_wear_estimate": 5, "versatility_score": 75 }
  }
}
```

---

### POST /recommendations/{recommendation_id}/rate

Record feedback on a recommendation.

**Request:**
```json
{ "rating": "thumbs_up" }
```

**Response (200):**
```json
{ "data": { "saved": true } }
```

---

## Gamification Endpoints

### GET /gamification/streak

Get current streak information.

**Response (200):**
```json
{
  "data": {
    "current_streak": 7,
    "longest_streak": 30,
    "last_planned": "2026-01-06",
    "streak_freezes_remaining": 3,
    "streak_skips_remaining": 1,
    "next_milestone": { "days": 30, "name": "Monthly Master", "badge": "month" }
  }
}
```

---

### GET /gamification/achievements

Get earned achievements and available definitions.

**Response (200):**
```json
{
  "data": {
    "earned": [],
    "available": [
      { "id": "first_upload", "name": "First Upload", "description": "Add your first wardrobe item", "xp_reward": 50 }
    ]
  }
}
```

---

### GET /gamification/leaderboard

Get a lightweight leaderboard (MVP: derived from streaks).

**Response (200):**
```json
{
  "data": {
    "entries": [
      { "rank": 1, "user_id": "uuid", "username": "John Doe", "level": 2, "total_points": 140 }
    ],
    "user_rank": { "rank": 3, "total_points": 90, "level": 1, "total_users": 25, "top_percentile": 12 }
  }
}
```

---

## Calendar Endpoints

### POST /calendar/connect

Connect calendar provider.

**Request:**
```json
{
  "provider": "google",
  "auth_code": "auth_code_from_oauth"
}
```

**Response (200):**
```json
{
  "data": {
    "id": "calendar_connection_uuid",
    "provider": "google",
    "email": "user@gmail.com",
    "connected_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### GET /calendar/connections

List calendar connections for the current user.

**Response (200):**
```json
{
  "data": {
    "connections": [
      {
        "id": "calendar_connection_uuid",
        "provider": "google",
        "email": "user@gmail.com",
        "connected_at": "2026-01-06T00:00:00Z"
      }
    ]
  }
}
```

---

### DELETE /calendar/connections/{id}

Disconnect a calendar provider.

**Response (200):**
```json
{
  "data": { "id": "calendar_connection_uuid", "is_active": false }
}
```

---

### GET /calendar/events

Fetch calendar events.

**Query Parameters:**
```
start_date=2026-01-01
end_date=2026-01-31
```

**Response (200):**
```json
{
  "data": {
    "events": [
      {
        "id": "event_uuid",
        "calendar_id": "calendar_connection_uuid",
        "title": "Team Meeting",
        "description": "Weekly sync",
        "start_time": "2026-01-06T10:00:00Z",
        "end_time": "2026-01-06T11:00:00Z",
        "location": "Conference Room",
        "outfit_id": "outfit_uuid"
      }
    ]
  }
}
```

---

### POST /calendar/events

Create an in-app calendar event (local planning).

**Request:**
```json
{
  "title": "Dinner",
  "description": "Reservation at 7pm",
  "start_time": "2026-01-06T19:00:00Z",
  "end_time": "2026-01-06T21:00:00Z",
  "location": "Downtown"
}
```

**Response (201):**
```json
{
  "data": {
    "id": "event_uuid",
    "title": "Dinner",
    "start_time": "2026-01-06T19:00:00Z",
    "end_time": "2026-01-06T21:00:00Z"
  }
}
```

---

### POST /calendar/events/{id}/outfit

Assign outfit to event.

**Request:**
```json
{
  "outfit_id": "outfit_uuid"
}
```

**Response (200):**
```json
{
  "data": {
    "id": "event_uuid",
    "outfit_id": "outfit_uuid",
    "updated_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### DELETE /calendar/events/{id}/outfit

Remove outfit assignment from an event.

**Response (200):**
```json
{
  "data": { "id": "event_uuid", "outfit_id": null }
}
```

---

## Weather Endpoints

### GET /weather

Get current weather.

**Query Parameters:**
```
location=40.7128,-74.0060
```

**Response (200):**
```json
{
  "data": {
    "temperature": 5,
    "condition": "cloudy",
    "humidity": 65,
    "wind_speed": 15,
    "feels_like": 2,
    "location": "New York, NY"
  }
}
```

---

### GET /weather/forecast

Get weather forecast.

**Query Parameters:**
```
location=40.7128,-74.0060
days=7
```

**Response (200):**
```json
{
  "data": {
    "forecast": [
      {
        "date": "2026-01-06",
        "temperature": {"high": 8, "low": 2},
        "condition": "partly_cloudy",
        "precipitation_chance": 20
      }
    ]
  }
}
```

---

## Photoshoot Endpoints

### POST /photoshoot/generate

Generate AI photoshoot images (authenticated users).

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "photos": ["base64_encoded_image_1", "base64_encoded_image_2"],
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
        "image_base64": "base64_encoded_result",
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

**Errors:**
- `400`: Invalid request (bad photos, invalid use case)
- `429`: Daily limit exceeded

---

### POST /photoshoot/demo

Generate demo photoshoot images (anonymous, IP-limited).

**Request:**
```json
{
  "photo": "base64_encoded_image",
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
        "image_base64": "base64_encoded_result",
        "image_url": "https://..."
      }
    ],
    "remaining_today": 0,
    "signup_cta": "Sign up for 10 free images per day!"
  }
}
```

**Errors:**
- `400`: Invalid request
- `429`: Demo rate limit exceeded (1 generation/day per IP)

---

### GET /photoshoot/usage

Get current user's photoshoot usage stats.

**Headers:**
```
Authorization: Bearer <token>
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

---

### GET /photoshoot/use-cases

Get available photoshoot use cases.

**Response (200):**
```json
{
  "data": {
    "use_cases": [
      {
        "id": "linkedin",
        "name": "LinkedIn Profile",
        "description": "Professional headshots for LinkedIn and business profiles",
        "example_prompts": ["Professional headshot in modern office"]
      }
    ]
  }
}
```

---

## Error Response Examples

### 400 Bad Request

```json
{
  "error": "Invalid request data",
  "code": "VALIDATION_ERROR",
  "details": {
    "field": "email",
    "message": "Invalid email format"
  }
}
```

### 401 Unauthorized

```json
{
  "error": "Invalid or expired token",
  "code": "UNAUTHORIZED"
}
```

### 404 Not Found

```json
{
  "error": "Item not found",
  "code": "NOT_FOUND"
}
```

### 422 Unprocessable Entity

```json
{
  "error": "Unable to process request",
  "code": "UNPROCESSABLE_ENTITY",
  "details": {
    "reason": "AI could not extract items from image"
  }
}
```

### 500 Internal Server Error

```json
{
  "error": "Internal server error",
  "code": "INTERNAL_ERROR"
}
```

---

## Rate Limiting

For MVP, no rate limiting is implemented. For Phase 2, the following limits will apply:

| Endpoint | Limit | Window |
|----------|-------|--------|
| /auth/login | 5 | 1 minute |
| /items/upload | 20 | 1 hour |
| /outfits/generate | 50 | 1 day |
| Other endpoints | 100 | 1 hour |

Rate limit headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704240000
```

---

## WebSocket Endpoints (Future)

### Connect to WS

```
wss://api.fitcheck.ai/ws
```

### Events

```json
{
  "type": "generation_complete",
  "data": {
    "generation_id": "gen_uuid",
    "images": ["https://..."]
  }
}
```

---

## OpenAPI Specification

The complete OpenAPI specification is available at:

```
GET /api/v1/docs
```

This provides an interactive Swagger UI for testing all endpoints.
