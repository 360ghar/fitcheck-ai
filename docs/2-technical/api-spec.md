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
      "full_name": "John Doe",
      "created_at": "2026-01-06T00:00:00Z"
    },
    "access_token": "jwt_token",
    "refresh_token": "refresh_token"
  }
}
```

**Errors:**
- `400`: Invalid email or password format
- `409`: Email already registered

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
- `403`: Account disabled

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
    "refresh_token": "new_refresh_token"
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

Confirm password reset with token.

**Request:**
```json
{
  "token": "reset_token",
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
    "color_temperature": "cool"
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
  "message": "Preferences updated successfully"
}
```

---

## Item Endpoints

### POST /items

Create new item (manual entry).

**Request (multipart/form-data):**
```
name: "Blue T-Shirt"
category: "tops"
brand: "Zara"
colors: ["blue"]
price: 29.99
image: <file>
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

Upload item images for AI extraction.

**Request (multipart/form-data):**
```
files: [<file1>, <file2>, ...]
category: "tops"
```

**Response (202):**
```json
{
  "data": {
    "upload_id": "upload_uuid",
    "status": "processing",
    "uploaded_count": 5
  }
}
```

---

### POST /items/extract

Extract items from uploaded image.

**Request (multipart/form-data):**
```
image: <file>
```

**Response (200):**
```json
{
  "data": {
    "extraction_id": "extraction_uuid",
    "items": [
      {
        "id": "temp_item_id",
        "image_url": "https://...",
        "category": "tops",
        "confidence": 0.92,
        "bounding_box": {
          "x": 10,
          "y": 20,
          "width": 200,
          "height": 300
        }
      }
    ]
  }
}
```

---

### GET /items

Browse items with filters.

**Query Parameters:**
```
category=tops,shoes
color=blue,black
brand=Zara
condition=clean
page=1
page_size=20
sort=created_desc
search=blue t-shirt
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
        "images": ["https://..."],
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
    "items": [
      {"id": "item1_uuid", "name": "Blue T-Shirt", ...},
      {"id": "item2_uuid", "name": "Black Jeans", ...},
      {"id": "item3_uuid", "name": "White Sneakers", ...}
    ],
    "tags": ["work", "casual"],
    "is_draft": true,
    "created_at": "2026-01-06T00:00:00Z"
  }
}
```

---

### POST /outfits/{id}/generate

Generate AI outfit image.

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
