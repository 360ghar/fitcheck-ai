"""
Recommendations API routes.
Provides AI-powered outfit recommendations and item matching.
"""

import uuid
import logging
from typing import Optional, List
from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel
from supabase import Client

from app.db.connection import get_db
from app.core.security import get_current_user_id
from app.models.recommendation import (
    MatchRequest, MatchResponse, CompleteLookRequest, CompleteLookResponse,
    SimilarItemsRequest, SimilarItemsResponse, ShoppingRecommendationsResponse,
    StyleAnalysisResponse, MatchResult, SuggestedItem, CompleteLookSuggestion,
    SimilarItemResult, ShoppingSuggestion, StyleAnalysis
)
from app.services.ai_service import AIService
from app.services.vector_service import get_vector_service
from app.services.weather_service import get_weather_service, WeatherOutfitRecommender

logger = logging.getLogger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST MODELS
# ============================================================================


class MatchItemsRequest(BaseModel):
    """Request to find items that match a given item."""
    item_id: str
    categories: Optional[List[str]] = None
    limit: int = 10
    min_score: float = 0.5


class CompleteLookRequestApi(BaseModel):
    """Request to generate complete outfit suggestions."""
    base_item_ids: List[str] = []
    style: Optional[str] = None
    occasion: Optional[str] = None
    season: Optional[str] = None
    max_suggestions: int = 5
    include_accessories: bool = True


class WeatherRecommendationRequest(BaseModel):
    """Request for weather-based outfit recommendations."""
    location: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None


# ============================================================================
# MATCH ENDPOINTS
# ============================================================================


@router.post("/match", response_model=MatchResponse)
async def find_matching_items(
    request: MatchItemsRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Find items that match well with a given item.

    Returns compatible items with match scores and reasons.
    """
    try:
        # Get the source item
        source_item = db.table("items").select("*").eq("id", request.item_id).eq("user_id", user_id).single().execute()

        if not source_item.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        # Get candidate items from user's wardrobe
        query = db.table("items").select("*").eq("user_id", user_id)

        # Filter to specific categories if requested
        if request.categories:
            query = query.in_("category", request.categories)

        # Exclude the source item
        query = query.neq("id", request.item_id)

        candidates_result = query.limit(100).execute()
        candidate_items = candidates_result.data

        if not candidate_items:
            return MatchResponse(
                source_item_id=request.item_id,
                matches=[],
                total_found=0,
                search_params={"categories": request.categories}
            )

        # Use AI service to find matches
        matches = await AIService.find_matching_items(
            source_item=source_item.data,
            candidate_items=candidate_items,
            limit=request.limit
        )

        # Convert to response format
        match_results = []
        for match in matches:
            item = match.get("item", {})
            match_results.append(MatchResult(
                item_id=item.get("id"),
                item_name=item.get("name"),
                image_url=_get_primary_image(item.get("id"), db),
                category=item.get("category"),
                score=match.get("score", 0.5),
                reasons=[{"type": "match", "description": r, "confidence": 0.8} for r in match.get("reasons", [])]
            ))

        return MatchResponse(
            source_item_id=request.item_id,
            matches=match_results,
            total_found=len(match_results),
            search_params={"categories": request.categories}
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error finding matches: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while finding matches"
        )


@router.post("/complete-look", response_model=CompleteLookResponse)
async def suggest_complete_looks(
    request: CompleteLookRequestApi,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Generate complete outfit suggestions based on selected items.

    Returns full outfit combinations with item suggestions.
    """
    try:
        # Get base items
        base_items = []
        if request.base_item_ids:
            base_result = db.table("items").select("*").in_("id", request.base_item_ids).eq("user_id", user_id).execute()
            base_items = base_result.data

        # Determine what categories we need
        category_counts = {}
        for item in base_items:
            cat = item.get("category")
            category_counts[cat] = category_counts.get(cat, 0) + 1

        needed_categories = _get_needed_categories(category_counts)

        # Get items for needed categories
        suggestions = []
        max_suggestions = min(request.max_suggestions, 5)

        for i in range(max_suggestions):
            suggested_items = []

            # Add base items
            for item in base_items:
                suggested_items.append(SuggestedItem(
                    item_id=item.get("id"),
                    item_name=item.get("name"),
                    image_url=_get_primary_image(item.get("id"), db),
                    category=item.get("category"),
                    position=_infer_position(item.get("category")),
                    confidence=1.0
                ))

            # Add complementary items
            for needed_cat in needed_categories:
                # Find items in this category
                candidates = db.table("items").select("*").eq("user_id", user_id).eq("category", needed_cat).execute()

                if candidates.data:
                    # Pick a candidate (for MVP, random selection)
                    import random
                    candidate = random.choice(candidates.data)

                    suggested_items.append(SuggestedItem(
                        item_id=candidate.get("id"),
                        item_name=candidate.get("name"),
                        image_url=_get_primary_image(candidate.get("id"), db),
                        category=candidate.get("category"),
                        position=_infer_position(needed_cat),
                        confidence=0.8
                    ))

            # Create the suggestion
            suggestion = CompleteLookSuggestion(
                name=f"{request.style or 'Casual'} Look {i + 1}",
                description=f"A {request.style or 'casual'} outfit for {request.occasion or 'everyday'} wear.",
                items=suggested_items,
                style=request.style,
                occasion=request.occasion,
                confidence=0.8
            )

            suggestions.append(suggestion)

        return CompleteLookResponse(
            suggestions=suggestions,
            total_suggestions=len(suggestions),
            base_item_ids=request.base_item_ids,
            criteria={"style": request.style, "occasion": request.occasion}
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating complete look: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while generating suggestions"
        )


@router.post("/similar", response_model=SimilarItemsResponse)
async def find_similar_items(
    item_id: str = Query(...),
    limit: int = Query(10, ge=1, le=50),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Find items similar to a given item using vector similarity.
    """
    try:
        # Get the source item
        source_item = db.table("items").select("*").eq("id", item_id).eq("user_id", user_id).single().execute()

        if not source_item.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        # Generate embedding for source item
        embedding = await AIService.generate_item_embedding(source_item.data)

        if not embedding:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to generate item embedding"
            )

        # Find similar items using vector service
        vector_service = get_vector_service()
        similar = await vector_service.find_similar(
            embedding=embedding,
            user_id=user_id,
            exclude_item_ids=[item_id],
            top_k=limit
        )

        # Get full item details
        similar_ids = [s["item_id"] for s in similar]
        items_result = db.table("items").select("*, item_images(*)").in_("id", similar_ids).execute()
        items_map = {item["id"]: item for item in items_result.data}

        # Build response
        similar_items = []
        for sim in similar:
            item_id = sim["item_id"]
            if item_id in items_map:
                item = items_map[item_id]
                similar_items.append(SimilarItemResult(
                    item_id=item_id,
                    item_name=item.get("name"),
                    image_url=_get_primary_image(item_id, db),
                    category=item.get("category"),
                    sub_category=item.get("sub_category"),
                    brand=item.get("brand"),
                    colors=item.get("colors", []),
                    similarity=sim["score"],
                    reasons=[f"Similar {item.get('category')} to your item"]
                ))

        return SimilarItemsResponse(
            source_item_id=item_id,
            similar_items=similar_items[:limit],
            total_found=len(similar_items)
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error finding similar items: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while finding similar items"
        )


# ============================================================================
# WEATHER-BASED RECOMMENDATIONS
# ============================================================================


@router.post("/weather", response_model=dict)
async def get_weather_recommendations(
    request: WeatherRecommendationRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Get outfit recommendations based on current weather.
    """
    try:
        weather_service = get_weather_service()

        # Get weather data
        if request.location:
            weather = await weather_service.get_weather(request.location)
        elif request.lat and request.lon:
            weather = await weather_service.get_weather_by_coordinates(request.lat, request.lon)
        else:
            # Use default location
            weather = await weather_service.get_weather("New York")

        # Get outfit recommendations based on weather
        recommendations = WeatherOutfitRecommender.get_recommendations(weather)

        # Get suggested items from user's wardrobe
        suggested_items = []

        # Find items matching the recommended categories
        preferred_categories = recommendations.get("preferred_categories", [])

        for category in preferred_categories[:3]:  # Limit to top 3 categories
            items = db.table("items").select("*").eq("user_id", user_id).eq("category", category).eq("condition", "clean").limit(3).execute()

            for item in items.data:
                suggested_items.append({
                    "id": item.get("id"),
                    "name": item.get("name"),
                    "category": item.get("category"),
                    "image_url": _get_primary_image(item.get("id"), db)
                })

        return {
            "weather": {
                "temperature": weather.get("temperature"),
                "condition": weather.get("description"),
                "location": weather.get("location")
            },
            "recommendations": recommendations,
            "suggested_items": suggested_items[:10]
        }

    except Exception as e:
        logger.error(f"Error getting weather recommendations: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching weather recommendations"
        )


# ============================================================================
# STYLE ANALYSIS
# ============================================================================


@router.get("/style-analysis", response_model=StyleAnalysisResponse)
async def analyze_style(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Analyze user's style based on their wardrobe.

    Returns style preferences, color palette, and suggestions.
    """
    try:
        # Get all items
        items_result = db.table("items").select("*").eq("user_id", user_id).execute()
        items = items_result.data

        if not items:
            return StyleAnalysisResponse(
                analysis=StyleAnalysis(
                    dominant_styles=[],
                    color_palette=[],
                    favorite_brands=[],
                    most_common_categories=[],
                    style_score={}
                ),
                recommendations=["Start adding items to your wardrobe to get style analysis!"],
                suggestions=[]
            )

        # Analyze categories
        category_counts = {}
        for item in items:
            cat = item.get("category")
            category_counts[cat] = category_counts.get(cat, 0) + 1

        most_common_categories = [
            {"category": k, "count": v}
            for k, v in sorted(category_counts.items(), key=lambda x: x[1], reverse=True)
        ]

        # Analyze colors
        color_counts = {}
        for item in items:
            for color in item.get("colors", []):
                color_counts[color] = color_counts.get(color, 0) + 1

        color_palette = [c for c, _ in sorted(color_counts.items(), key=lambda x: x[1], reverse=True)][:10]

        # Analyze brands
        brand_counts = {}
        for item in items:
            brand = item.get("brand")
            if brand:
                brand_counts[brand] = brand_counts.get(brand, 0) + 1

        favorite_brands = [b for b, _ in sorted(brand_counts.items(), key=lambda x: x[1], reverse=True)][:5]

        # Infer style from categories and colors
        dominant_styles = _infer_dominant_styles(category_counts, color_palette)

        # Generate recommendations
        recommendations = []
        suggestions = []

        if category_counts.get("tops", 0) > category_counts.get("bottoms", 0) * 2:
            suggestions.append("Consider adding more bottoms to balance your wardrobe")

        if "black" in color_palette and "white" in color_palette:
            recommendations.append("You have a neutral base - experiment with colorful accessories")

        if len(favorite_brands) == 0:
            suggestions.append("Try adding brand information to your items for better recommendations")

        return StyleAnalysisResponse(
            analysis=StyleAnalysis(
                dominant_styles=dominant_styles,
                color_palette=color_palette,
                favorite_brands=favorite_brands,
                most_common_categories=most_common_categories[:5],
                style_score={}
            ),
            recommendations=recommendations,
            suggestions=suggestions
        )

    except Exception as e:
        logger.error(f"Error analyzing style: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while analyzing style"
        )


# ============================================================================
# SHOPPING RECOMMENDATIONS
# ============================================================================


@router.get("/shopping", response_model=ShoppingRecommendationsResponse)
async def get_shopping_recommendations(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Get recommendations for items to purchase to fill wardrobe gaps.
    """
    try:
        # Get user's current wardrobe
        items_result = db.table("items").select("category, colors, brand").eq("user_id", user_id).execute()
        items = items_result.data

        # Count items by category
        category_counts = {}
        for item in items:
            cat = item.get("category")
            category_counts[cat] = category_counts.get(cat, 0) + 1

        suggestions = []

        # Suggest items for categories with few items
        basic_categories = ["tops", "bottoms", "shoes", "outerwear"]

        for category in basic_categories:
            count = category_counts.get(category, 0)
            if count < 3:
                suggestions.append(ShoppingSuggestion(
                    category=category,
                    reason=f"You only have {count} {category}. Consider adding more variety.",
                    priority="high" if count == 0 else "medium",
                    suggested_brands=_get_brands_for_category(category),
                    price_range=_get_price_range_for_category(category),
                    fill_gaps_in_wardrobe=True
                ))

        # Suggest accessories
        if category_counts.get("accessories", 0) < 5:
            suggestions.append(ShoppingSuggestion(
                category="accessories",
                sub_category="belts",
                reason="Belts can transform an outfit and add polish.",
                priority="low",
                suggested_brands=["Any"],
                fill_gaps_in_wardrobe=True
            ))

        return ShoppingRecommendationsResponse(
            suggestions=suggestions[:5],
            wardrobe_analysis={
                "total_items": len(items),
                "category_breakdown": category_counts
            },
            total_suggestions=len(suggestions)
        )

    except Exception as e:
        logger.error(f"Error getting shopping recommendations: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while generating shopping recommendations"
        )


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================


def _get_primary_image(item_id: str, db: Client) -> Optional[str]:
    """Get the primary image URL for an item."""
    try:
        result = db.table("item_images").select("image_url").eq("item_id", item_id).eq("is_primary", True).limit(1).execute()

        if result.data:
            return result.data[0].get("image_url")

        # Try to get any image
        result = db.table("item_images").select("image_url").eq("item_id", item_id).limit(1).execute()

        if result.data:
            return result.data[0].get("image_url")

        return None

    except Exception:
        return None


def _infer_position(category: str) -> str:
    """Infer position from category."""
    position_map = {
        "tops": "top",
        "bottoms": "bottom",
        "shoes": "shoes",
        "accessories": "accessory",
        "outerwear": "outerwear",
        "swimwear": "top",
        "activewear": "top"
    }
    return position_map.get(category, "accessory")


def _get_needed_categories(category_counts: dict) -> List[str]:
    """Determine which categories are needed for a complete outfit."""
    needed = []

    if category_counts.get("tops", 0) == 0:
        needed.append("tops")
    if category_counts.get("bottoms", 0) == 0:
        needed.append("bottoms")
    if category_counts.get("shoes", 0) == 0:
        needed.append("shoes")

    # Add accessories if we have basics
    if category_counts.get("tops", 0) > 0 and category_counts.get("bottoms", 0) > 0:
        needed.append("accessories")

    return needed


def _infer_dominant_styles(category_counts: dict, color_palette: List[str]) -> List[str]:
    """Infer dominant styles from wardrobe."""
    styles = []

    # Simple style inference based on categories and colors
    if category_counts.get("outerwear", 0) > 3:
        styles.append("layered")

    if "black" in color_palette and "white" in color_palette:
        styles.append("minimalist")

    if category_counts.get("accessories", 0) > 5:
        styles.append("accessorized")

    if not styles:
        styles.append("casual")

    return styles[:3]


def _get_brands_for_category(category: str) -> List[str]:
    """Get suggested brands for a category."""
    brand_suggestions = {
        "tops": ["Uniqlo", "H&M", "Everlane"],
        "bottoms": ["Levi's", "Uniqlo", "Madewell"],
        "shoes": ["Nike", "Adidas", "Converse"],
        "outerwear": ["Uniqlo", "The North Face", "Patagonia"],
        "accessories": ["Various"]
    }
    return brand_suggestions.get(category, ["Various"])


def _get_price_range_for_category(category: str) -> str:
    """Get typical price range for a category."""
    price_ranges = {
        "tops": "$$",
        "bottoms": "$$",
        "shoes": "$$$",
        "outerwear": "$$$",
        "accessories": "$"
    }
    return price_ranges.get(category, "$")
