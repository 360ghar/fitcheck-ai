"""
Recommendations API routes.

For MVP we provide deterministic, fast recommendations using:
- rule-based matching (category + color harmony)
- optional embeddings + Pinecone when configured
"""

from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel, Field, model_validator
from supabase import Client

from app.core.exceptions import (
    AIServiceError,
    DatabaseError,
    ItemNotFoundError,
    ValidationError,
    WeatherServiceError,
)
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.vector_service import get_vector_service
from app.services.weather_service import get_weather_service

logger = get_context_logger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST MODELS (aligned to docs/2-technical/api-spec.md)
# ============================================================================


class MatchRequest(BaseModel):
    # Docs-aligned payload (preferred)
    item_ids: Optional[List[str]] = None
    # Legacy payload used by current frontend
    item_id: Optional[str] = None
    match_type: str = Field(default="all")  # reserved for future
    limit: Optional[int] = Field(default=None, ge=1, le=50)

    @model_validator(mode="after")
    def _validate_ids(self):
        if not self.item_ids and not self.item_id:
            raise ValueError("Provide either item_ids or item_id")
        return self


class CompleteLookRequest(BaseModel):
    # Docs-aligned payload (preferred)
    start_item_id: Optional[str] = None
    # Frontend payload
    item_ids: Optional[List[str]] = None
    occasion: Optional[str] = None
    weather_condition: Optional[str] = None
    limit: Optional[int] = Field(default=None, ge=1, le=20)

    @model_validator(mode="after")
    def _validate_seed(self):
        if not self.start_item_id and not self.item_ids:
            raise ValueError("Provide either start_item_id or item_ids")
        return self


# ============================================================================
# MATCHING LOGIC (rule-based MVP)
# ============================================================================


_COMPLEMENTARY: Dict[str, List[str]] = {
    "tops": ["bottoms", "shoes", "accessories", "outerwear"],
    "bottoms": ["tops", "shoes", "accessories", "outerwear"],
    "shoes": ["tops", "bottoms", "accessories", "outerwear"],
    "outerwear": ["tops", "bottoms", "shoes"],
    "accessories": ["tops", "bottoms", "shoes", "outerwear"],
}


def _score_match(source: Dict[str, Any], candidate: Dict[str, Any]) -> Tuple[float, List[str]]:
    score = 0.5
    reasons: List[str] = []

    source_cat = (source.get("category") or "").lower()
    cand_cat = (candidate.get("category") or "").lower()

    if cand_cat in _COMPLEMENTARY.get(source_cat, []):
        score += 0.15
        reasons.append(f"complements your {source_cat}")

    # Color overlap / neutral bonus
    source_colors = {c.lower() for c in (source.get("colors") or [])}
    cand_colors = {c.lower() for c in (candidate.get("colors") or [])}
    neutrals = {"black", "white", "gray", "grey", "beige", "cream", "navy"}

    if source_colors and cand_colors:
        if source_colors & cand_colors:
            score += 0.2
            reasons.append("matches your colors")
        elif (source_colors & neutrals) or (cand_colors & neutrals):
            score += 0.1
            reasons.append("coordinates with neutrals")

    return min(1.0, score), reasons


# ============================================================================
# ENDPOINTS
# ============================================================================


@router.post("/match", response_model=Dict[str, Any])
async def match_items(
    request: MatchRequest,
    category: Optional[str] = Query(None),
    limit: int = Query(10, ge=1, le=50),
    min_score: int = Query(0, ge=0, le=100),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Find items that match the given item(s)."""
    try:
        requested_limit = request.limit or limit
        source_ids = list(dict.fromkeys(request.item_ids or ([request.item_id] if request.item_id else [])))
        sources_res = (
            db.table("items")
            .select("*")
            .eq("user_id", user_id)
            .in_("id", source_ids)
            .execute()
        )
        sources = sources_res.data or []
        if not sources:
            raise ItemNotFoundError()

        # Candidate pool: same wardrobe excluding sources
        candidates_q = db.table("items").select("*").eq("user_id", user_id).not_.in_("id", source_ids)
        if category:
            candidates_q = candidates_q.eq("category", category)
        # Exclude laundry/repair/donate by default (docs)
        candidates_q = candidates_q.not_.in_("condition", ["laundry", "repair", "donate"])
        candidates_res = candidates_q.limit(500).execute()
        candidates = candidates_res.data or []

        matches: List[Dict[str, Any]] = []
        for source in sources:
            for cand in candidates:
                score, reasons = _score_match(source, cand)
                score_pct = int(round(score * 100))
                if score_pct < min_score:
                    continue
                matches.append({"item": cand, "score": score_pct, "reasons": [r.capitalize() for r in reasons]})

        matches.sort(key=lambda m: m["score"], reverse=True)
        matches = matches[:requested_limit]

        # Basic "complete looks" (top+bottom+shoes when possible)
        complete_looks: List[Dict[str, Any]] = []
        by_cat: Dict[str, List[Dict[str, Any]]] = {}
        for m in matches:
            cat = (m["item"].get("category") or "other").lower()
            by_cat.setdefault(cat, []).append(m["item"])

        for i in range(min(3, requested_limit)):
            look_items: List[Dict[str, Any]] = []
            for cat in ("tops", "bottoms", "shoes", "outerwear", "accessories"):
                if cat in by_cat and len(by_cat[cat]) > i:
                    look_items.append(by_cat[cat][i])
            if look_items:
                complete_looks.append(
                    {
                        "items": look_items,
                        "match_score": 80,
                        "description": "A complete look built from your wardrobe",
                    }
                )

        logger.debug(
            "Match items completed",
            user_id=user_id,
            source_count=len(sources),
            match_count=len(matches)
        )
        return {"data": {"matches": matches, "complete_looks": complete_looks}, "message": "OK"}

    except ItemNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Match error",
            user_id=user_id,
            source_ids=source_ids if 'source_ids' in dir() else None,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to generate matches",
            operation="match_items"
        )


@router.post("/complete-look", response_model=Dict[str, Any])
async def complete_look(
    request: CompleteLookRequest,
    style: Optional[str] = Query(None),
    occasion: Optional[str] = Query(None),
    limit: int = Query(5, ge=1, le=20),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Generate complete outfit suggestions from a start item."""
    try:
        requested_limit = request.limit or limit
        effective_occasion = request.occasion or occasion

        seed_ids = request.item_ids or ([request.start_item_id] if request.start_item_id else [])
        seed_ids = [i for i in seed_ids if i]
        if not seed_ids:
            raise ValidationError(
                message="No seed items provided",
                details={"field": "item_ids or start_item_id"}
            )

        seed_res = db.table("items").select("*").eq("user_id", user_id).in_("id", seed_ids).execute()
        seeds = seed_res.data or []
        if not seeds:
            raise ItemNotFoundError()

        # Reuse match logic
        match_res = await match_items(
            MatchRequest(item_ids=seed_ids, limit=50),
            user_id=user_id,
            db=db,
        )
        matches = (match_res.get("data") or {}).get("matches") or []

        looks: List[Dict[str, Any]] = []
        for i in range(min(requested_limit, len(matches))):
            looks.append(
                {
                    "items": [seeds[0], matches[i]["item"]],
                    "match_score": matches[i]["score"],
                    "description": f"Suggested look for {effective_occasion or 'any occasion'}",
                    "style": style,
                    "occasion": effective_occasion,
                }
            )

        logger.debug(
            "Complete look generated",
            user_id=user_id,
            seed_count=len(seeds),
            look_count=len(looks)
        )
        return {"data": {"complete_looks": looks}, "message": "OK"}

    except (ItemNotFoundError, ValidationError):
        raise
    except Exception as e:
        logger.error(
            "Complete-look error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to generate complete looks",
            operation="complete_look"
        )


@router.get("/personalized", response_model=Dict[str, Any])
async def personalized(
    type: str = Query("outfits"),
    limit: int = Query(10, ge=1, le=50),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return simple personalized recommendations (favorites + least worn)."""
    try:
        items_fav = (
            db.table("items")
            .select("*")
            .eq("user_id", user_id)
            .eq("is_favorite", True)
            .limit(limit)
            .execute()
        ).data or []

        items_least = (
            db.table("items")
            .select("*")
            .eq("user_id", user_id)
            .order("usage_times_worn", desc=False)
            .limit(limit)
            .execute()
        ).data or []

        logger.debug(
            "Personalized recommendations retrieved",
            user_id=user_id,
            favorites_count=len(items_fav),
            least_worn_count=len(items_least)
        )
        return {
            "data": {
                "items": [{"item": i, "match_score": 90, "why_recommended": "Favorite item"} for i in items_fav][:limit],
                "outfits": [],
                "least_worn": items_least[:limit],
            },
            "message": "OK",
        }
    except Exception as e:
        logger.error(
            "Personalized error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to fetch recommendations",
            operation="personalized"
        )


# ============================================================================
# WEATHER RECOMMENDATIONS (MVP heuristics)
# ============================================================================


def _parse_coordinates(location: str) -> Optional[Tuple[float, float]]:
    try:
        parts = [part.strip() for part in location.split(",")]
        if len(parts) != 2:
            return None
        lat = float(parts[0])
        lon = float(parts[1])
        if not (-90 <= lat <= 90 and -180 <= lon <= 180):
            return None
        return lat, lon
    except ValueError:
        return None


@router.get("/weather", response_model=Dict[str, Any])
async def weather_recommendations(
    location: Optional[str] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return a weather-driven recommendation object for the frontend."""
    try:
        # Prefer user settings default_location when location isn't provided
        if not location:
            try:
                settings_row = db.table("user_settings").select("default_location").eq("user_id", user_id).single().execute()
                location = settings_row.data.get("default_location") if settings_row.data else None
            except Exception:
                location = None

        service = get_weather_service()
        resolved_location = (location or "New York").strip()
        coords = _parse_coordinates(resolved_location)
        if coords:
            weather = await service.get_weather_by_coordinates(lat=coords[0], lon=coords[1], units="imperial")
        else:
            weather = await service.get_weather(location=resolved_location, units="imperial")
        temp_f = float((weather or {}).get("temperature") or 70)
        temp_c = round((temp_f - 32.0) * 5.0 / 9.0, 1)
        state = (weather or {}).get("weather_state") or (weather or {}).get("condition") or "unknown"
        temp_category = (weather or {}).get("temp_category") or "mild"

        preferred_categories = ["tops", "bottoms", "shoes"]
        avoid_categories: List[str] = []
        additional_items: List[str] = []
        items_to_avoid: List[str] = []
        preferred_materials: List[str] = []
        suggested_layers = 1
        notes: List[str] = []
        color_suggestions: List[str] = []

        if temp_c < 5:
            preferred_categories = ["outerwear", "tops", "bottoms", "shoes", "accessories"]
            avoid_categories = ["swimwear"]
            suggested_layers = 3
            additional_items = ["coat", "scarf", "gloves"]
            preferred_materials = ["wool", "fleece"]
            notes.append("Dress in warm layers to stay comfortable.")
            color_suggestions = ["navy", "black", "burgundy"]
        elif temp_c < 12:
            preferred_categories = ["outerwear", "tops", "bottoms", "shoes"]
            suggested_layers = 2
            additional_items = ["light jacket"]
            preferred_materials = ["denim", "cotton", "knit"]
            color_suggestions = ["gray", "navy", "beige"]
        elif temp_c > 27:
            preferred_categories = ["tops", "bottoms", "shoes", "accessories"]
            avoid_categories = ["outerwear"]
            suggested_layers = 1
            additional_items = ["sunglasses"]
            preferred_materials = ["linen", "cotton"]
            notes.append("Choose breathable fabrics and lighter colors.")
            color_suggestions = ["white", "cream", "light blue"]

        if str(state).lower() in {"rainy", "stormy"}:
            additional_items.extend(["umbrella", "rain jacket"])
            preferred_materials.extend(["waterproof"])
            notes.append("Rain expected — consider waterproof layers.")

        logger.debug(
            "Weather recommendations generated",
            user_id=user_id,
            location=location or "New York",
            temperature=temp_c,
            weather_state=state
        )
        return {
            "data": {
                "temperature": temp_c,
                "temp_category": temp_category,
                "weather_state": state,
                "preferred_categories": preferred_categories,
                "avoid_categories": avoid_categories,
                "preferred_materials": preferred_materials,
                "suggested_layers": suggested_layers,
                "additional_items": additional_items,
                "items_to_avoid": items_to_avoid,
                "notes": notes,
                "color_suggestions": color_suggestions,
            },
            "message": "OK",
        }
    except Exception as e:
        logger.error(
            "Weather recommendations error",
            user_id=user_id,
            location=location,
            error=str(e)
        )
        raise WeatherServiceError(
            message="Failed to generate weather recommendations"
        )


# ============================================================================
# SIMILAR ITEMS (vector search when available)
# ============================================================================


@router.get("/similar", response_model=Dict[str, Any])
async def similar_items(
    item_id: str = Query(...),
    category: Optional[str] = Query(None),
    limit: int = Query(10, ge=1, le=50),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        source = db.table("items").select("*").eq("id", item_id).eq("user_id", user_id).single().execute()
        if not source.data:
            raise ItemNotFoundError(item_id=item_id)

        # Vector search best-effort
        results: List[Dict[str, Any]] = []
        try:
            rate_check = await AISettingsService.check_rate_limit(
                user_id=user_id,
                operation_type="embedding",
                db=db,
            )
            if rate_check["allowed"]:
                embedding = await AIService.generate_item_embedding(source.data)
                if embedding:
                    await AISettingsService.increment_usage(
                        user_id=user_id,
                        operation_type="embedding",
                        db=db,
                    )
                    vector_service = get_vector_service()
                    matches = await vector_service.find_similar(
                        embedding=embedding,
                        user_id=user_id,
                        category=category,
                        exclude_item_ids=[item_id],
                        top_k=limit,
                        min_score=0.2,
                    )
                    match_ids = [m["item_id"] for m in matches if m.get("item_id")]
                    if match_ids:
                        items_res = db.table("items").select("*, item_images(*)").in_("id", match_ids).execute()
                        by_id = {r["id"]: r for r in (items_res.data or [])}
                        for m in matches:
                            it = by_id.get(m.get("item_id"))
                            if not it:
                                continue
                            results.append(
                                {
                                    "item_id": it["id"],
                                    "item_name": it.get("name"),
                                    "image_url": (it.get("item_images") or [{}])[0].get("thumbnail_url")
                                    or (it.get("item_images") or [{}])[0].get("image_url"),
                                    "category": it.get("category"),
                                    "sub_category": it.get("sub_category"),
                                    "brand": it.get("brand"),
                                    "colors": it.get("colors") or [],
                                    "similarity": float(m.get("score") or 0) * 100.0,
                                    "reasons": ["Similar style and attributes"],
                                }
                            )
            else:
                logger.info(
                    "Embedding rate limit exceeded for recommendations similar, using fallback",
                    user_id=user_id,
                    item_id=item_id,
                    remaining=rate_check["remaining"],
                    limit=rate_check["limit"],
                )
        except Exception as ve:
            logger.debug(
                "Vector search failed, falling back to rule-based",
                user_id=user_id,
                item_id=item_id,
                error=str(ve)
            )
            results = []

        # Fallback: same category + color overlap
        if not results:
            candidates = (
                db.table("items")
                .select("*, item_images(*)")
                .eq("user_id", user_id)
                .neq("id", item_id)
                .limit(200)
                .execute()
            ).data or []
            src_colors = set((source.data.get("colors") or []))
            scored = []
            for cand in candidates:
                score = 0.0
                if category and cand.get("category") != category:
                    continue
                if cand.get("category") == source.data.get("category"):
                    score += 0.4
                cand_colors = set((cand.get("colors") or []))
                if src_colors and cand_colors and src_colors & cand_colors:
                    score += 0.4
                scored.append((score, cand))
            scored.sort(key=lambda t: t[0], reverse=True)
            for score, cand in scored[:limit]:
                images = cand.get("item_images") or []
                primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
                results.append(
                    {
                        "item_id": cand["id"],
                        "item_name": cand.get("name"),
                        "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
                        "category": cand.get("category"),
                        "sub_category": cand.get("sub_category"),
                        "brand": cand.get("brand"),
                        "colors": cand.get("colors") or [],
                        "similarity": int(score * 100),
                        "reasons": ["Similar category/colors"],
                    }
                )

        logger.debug(
            "Similar items retrieved",
            user_id=user_id,
            item_id=item_id,
            result_count=len(results)
        )
        return {"data": results, "message": "OK"}
    except ItemNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Similar items error",
            user_id=user_id,
            item_id=item_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to fetch similar items",
            operation="similar_items"
        )


# ============================================================================
# STYLE ANALYSIS (MVP heuristics)
# ============================================================================


@router.get("/style/{item_id}", response_model=Dict[str, Any])
async def style_analysis(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        item = db.table("items").select("*").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        tags = [str(t).lower() for t in (item.data.get("tags") or [])]
        style = item.data.get("style") or next((t for t in tags if t in {"casual", "formal", "business", "sporty", "streetwear", "vintage", "minimalist"}), "casual")

        # Simple alternatives
        alt = [s for s in ["casual", "business", "formal", "streetwear", "minimalist"] if s != style][:3]

        # Suggested occasions
        suggested_occasions = []
        if style in {"business", "formal"}:
            suggested_occasions.extend(["work", "formal"])
        else:
            suggested_occasions.extend(["casual"])
        if "workout" in tags:
            suggested_occasions.append("workout")

        # Suggested companions: top 3 match results
        match = await match_items(MatchRequest(item_id=item_id_str, limit=10), user_id=user_id, db=db)
        matches = (match.get("data") or {}).get("matches") or []
        suggested_companions = []
        for m in matches[:5]:
            it = m.get("item") or {}
            suggested_companions.append(
                {
                    "item_id": it.get("id"),
                    "item_name": it.get("name"),
                    "category": it.get("category"),
                    "confidence": m.get("score", 0) / 100.0,
                }
            )

        logger.debug(
            "Style analysis completed",
            user_id=user_id,
            item_id=item_id_str,
            style=style
        )
        return {
            "data": {
                "style": style,
                "confidence": 0.7,
                "alternative_styles": [{"style": s, "confidence": 0.5} for s in alt],
                "color_palette": item.data.get("colors") or [],
                "suggested_occasions": suggested_occasions,
                "suggested_companions": suggested_companions,
            },
            "message": "OK",
        }
    except ItemNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Style analysis error",
            user_id=user_id,
            item_id=str(item_id),
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to analyze style",
            operation="style_analysis"
        )


# ============================================================================
# WARDROBE GAPS + SHOPPING + CAPSULE (MVP heuristics)
# ============================================================================


@router.get("/wardrobe-gaps", response_model=Dict[str, Any])
async def wardrobe_gaps(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        items = db.table("items").select("id,category").eq("user_id", user_id).eq("is_deleted", False).execute().data or []
        if not items:
            raise ItemNotFoundError(message="No items to analyze")

        counts: Dict[str, int] = {}
        for it in items:
            cat = (it.get("category") or "other").lower()
            counts[cat] = counts.get(cat, 0) + 1

        # Rough targets for a balanced wardrobe
        ideals = {
            "tops": (8, 20),
            "bottoms": (5, 12),
            "shoes": (3, 10),
            "outerwear": (2, 8),
            "accessories": (3, 20),
        }

        breakdown = []
        missing = []
        for cat, (ideal_min, ideal_max) in ideals.items():
            count = counts.get(cat, 0)
            under = count < ideal_min
            breakdown.append(
                {
                    "category": cat,
                    "count": count,
                    "ideal_min": ideal_min,
                    "ideal_max": ideal_max,
                    "is_underrepresented": under,
                }
            )
            if under:
                missing.append(
                    {
                        "category": cat,
                        "description": f"Add more versatile {cat} to increase outfit options.",
                        "priority": "high" if cat in {"tops", "bottoms", "shoes"} else "medium",
                        "would_complete": 10,
                        "estimated_cpw": 5.0,
                    }
                )

        completeness = 100 - min(80, len(missing) * 12)

        logger.debug(
            "Wardrobe gaps analyzed",
            user_id=user_id,
            item_count=len(items),
            missing_categories=len(missing)
        )
        return {
            "data": {
                "analysis": {
                    "category_breakdown": breakdown,
                    "missing_essentials": missing,
                    "wardrobe_completeness_score": completeness,
                }
            },
            "message": "OK",
        }
    except ItemNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Wardrobe gaps error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to analyze wardrobe gaps",
            operation="wardrobe_gaps"
        )


@router.get("/shopping", response_model=Dict[str, Any])
async def shopping_recommendations(
    category: Optional[str] = Query(None),
    budget: Optional[float] = Query(None, ge=0),
    style: Optional[str] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return actionable shopping recommendations based on wardrobe gaps."""
    try:
        gaps = await wardrobe_gaps(user_id=user_id, db=db)
        missing = ((gaps.get("data") or {}).get("analysis") or {}).get("missing_essentials") or []
        if category:
            missing = [m for m in missing if m.get("category") == category]
        logger.debug(
            "Shopping recommendations generated",
            user_id=user_id,
            category=category,
            recommendation_count=len(missing)
        )
        return {"data": missing, "message": "OK"}
    except ItemNotFoundError:
        raise
    except Exception as e:
        logger.error(
            "Shopping recommendations error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to get shopping recommendations",
            operation="shopping_recommendations"
        )


@router.get("/capsule", response_model=Dict[str, Any])
async def capsule_wardrobe(
    season: Optional[str] = Query(None),
    style: Optional[str] = Query(None),
    item_count: int = Query(20, ge=5, le=50),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return a simple capsule wardrobe suggestion from existing favorites."""
    try:
        items_res = (
            db.table("items")
            .select("id,name,category,colors,brand,item_images(image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("is_favorite", desc=True)
            .order("usage_times_worn", desc=True)
            .limit(item_count)
            .execute()
        )
        items = []
        for it in items_res.data or []:
            images = it.get("item_images") or []
            primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
            items.append(
                {
                    "item_id": it["id"],
                    "item_name": it.get("name"),
                    "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
                    "category": it.get("category"),
                    "position": it.get("category"),
                    "confidence": 0.7,
                }
            )

        logger.debug(
            "Capsule wardrobe generated",
            user_id=user_id,
            season=season,
            item_count=len(items)
        )
        return {
            "data": {
                "name": f"{season or 'All-season'} capsule",
                "description": "A minimal set of versatile items from your wardrobe.",
                "items": items,
                "outfits": [],
                "statistics": {
                    "total_outfits_possible": max(10, len(items) * 2),
                    "cost_per_wear_estimate": 5.0,
                    "versatility_score": 75,
                },
            },
            "message": "OK",
        }
    except Exception as e:
        logger.error(
            "Capsule wardrobe error",
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to generate capsule wardrobe",
            operation="capsule_wardrobe"
        )


class RateRecommendationRequest(BaseModel):
    rating: str = Field(..., description="thumbs_up|thumbs_down|neutral")


@router.post("/{recommendation_id}/rate", response_model=Dict[str, Any])
async def rate_recommendation(
    recommendation_id: UUID,
    request: RateRecommendationRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Store user feedback to improve future recommendations."""
    try:
        db.table("recommendation_logs").insert(
            {
                "id": str(recommendation_id),
                "user_id": user_id,
                "recommendation_type": "rating",
                "feedback": {"rating": request.rating},
            }
        ).execute()
        logger.info(
            "Recommendation rated",
            user_id=user_id,
            recommendation_id=str(recommendation_id),
            rating=request.rating
        )
        return {"data": {"saved": True}, "message": "OK"}
    except Exception as e:
        logger.error(
            "Rate recommendation error",
            user_id=user_id,
            recommendation_id=str(recommendation_id),
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to store rating",
            operation="rate_recommendation"
        )
