"""
AI service for integrating with Google Gemini AI.
Handles item extraction, embeddings, and outfit generation.
"""

import base64
import logging
from typing import Optional, List, Dict, Any
from datetime import datetime
import io

import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)

# Configure Gemini
genai.configure(api_key=settings.GEMINI_API_KEY)


# ============================================================================
# ITEM EXTRACTION FROM IMAGES
# ============================================================================


class ItemExtractor:
    """Extract clothing items from photos using Gemini Vision."""

    # Categories we recognize
    CATEGORIES = [
        'tops', 'bottoms', 'shoes', 'accessories',
        'outerwear', 'swimwear', 'activewear', 'other'
    ]

    # Colors we recognize
    COLORS = [
        'black', 'white', 'gray', 'grey', 'red', 'blue',
        'green', 'yellow', 'pink', 'purple', 'orange', 'brown',
        'beige', 'cream', 'navy', 'burgundy', 'teal', 'gold',
        'silver', 'metallic', 'multicolor', 'patterned'
    ]

    @staticmethod
    def _encode_image(image_data: bytes) -> str:
        """Encode image bytes to base64."""
        return base64.b64encode(image_data).decode('utf-8')

    @staticmethod
    async def extract_items(
        image_data: bytes,
        filename: str = "image.jpg"
    ) -> Dict[str, Any]:
        """Extract clothing items from an uploaded photo.

        Args:
            image_data: Raw image bytes
            filename: Original filename

        Returns:
            Dict with extracted items and metadata
        """
        try:
            # Use Gemini 2.0 Flash for vision
            model = genai.GenerativeModel(
                model_name=settings.GEMINI_MODEL,
                safety_settings={
                    HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                    HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                    HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                    HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                }
            )

            # Prepare the image
            image_part = {
                "mime_type": "image/jpeg",
                "data": ItemExtractor._encode_image(image_data)
            }

            # Prompt for item extraction
            prompt = f"""
            Analyze this clothing image and extract all visible items.

            For each item, identify:
            1. Category (must be one of: {', '.join(ItemExtractor.CATEGORIES)})
            2. Sub-category (e.g., "t-shirt", "jeans", "sneakers")
            3. Colors (from: {', '.join(ItemExtractor.COLORS)})
            4. Estimated material (e.g., cotton, denim, leather)
            5. Pattern (e.g., solid, striped, plaid)
            6. Brand (if visible/logo is clear)
            7. Confidence score (0.0 to 1.0)

            Return as JSON array:
            {{
              "items": [
                {{
                  "category": "tops",
                  "sub_category": "t-shirt",
                  "colors": ["blue"],
                  "material": "cotton",
                  "pattern": "solid",
                  "brand": null,
                  "confidence": 0.95,
                  "description": "Blue cotton t-shirt"
                }}
              ],
              "overall_confidence": 0.95,
              "image_description": "A person wearing a blue t-shirt"
            }}
            """

            # Generate content
            response = model.generate_content([prompt, image_part])

            if not response or not response.text:
                return ItemExtractor._fallback_result()

            # Parse response
            result = ItemExtractor._parse_extraction_response(response.text)
            result["filename"] = filename
            result["processed_at"] = datetime.now().isoformat()

            return result

        except Exception as e:
            logger.error(f"Error extracting items: {str(e)}")
            return ItemExtractor._fallback_result()

    @staticmethod
    def _parse_extraction_response(text: str) -> Dict[str, Any]:
        """Parse Gemini response into structured data."""
        try:
            import json

            # Try to extract JSON from response
            start = text.find('{')
            end = text.rfind('}') + 1

            if start >= 0 and end > start:
                json_str = text[start:end]
                data = json.loads(json_str)

                # Validate and normalize
                if "items" in data:
                    for item in data["items"]:
                        # Ensure category is valid
                        if item.get("category") not in ItemExtractor.CATEGORIES:
                            item["category"] = "other"
                        # Normalize colors
                        if item.get("colors"):
                            item["colors"] = [
                                c.lower() for c in item["colors"]
                                if c.lower() in ItemExtractor.COLORS
                            ]

                return data

        except Exception as e:
            logger.warning(f"Failed to parse extraction response: {str(e)}")

        return ItemExtractor._fallback_result()

    @staticmethod
    def _fallback_result() -> Dict[str, Any]:
        """Return a fallback result when extraction fails."""
        return {
            "items": [
                {
                    "category": "other",
                    "sub_category": None,
                    "colors": [],
                    "material": None,
                    "pattern": None,
                    "brand": None,
                    "confidence": 0.5,
                    "description": "Item detected - please provide details"
                }
            ],
            "overall_confidence": 0.5,
            "image_description": "Unable to analyze image automatically",
            "requires_manual_entry": True
        }


# ============================================================================
# TEXT EMBEDDINGS
# ============================================================================


class EmbeddingService:
    """Generate text embeddings using Gemini embeddings."""

    @staticmethod
    async def generate_embedding(text: str) -> Optional[List[float]]:
        """Generate an embedding vector for the given text.

        Args:
            text: Text to embed

        Returns:
            List of float values (768 dimensions for text-embedding-004)
        """
        try:
            model = 'models/' + settings.GEMINI_EMBEDDING_MODEL
            result = genai.embed_content(
                model=model,
                content=text,
                task_type="retrieval_document"
            )

            if result and 'embedding' in result:
                return result['embedding']

            return None

        except Exception as e:
            logger.error(f"Error generating embedding: {str(e)}")
            return None

    @staticmethod
    async def generate_item_embedding(item: Dict[str, Any]) -> Optional[List[float]]:
        """Generate embedding for an item's combined attributes.

        Args:
            item: Item dict with name, category, colors, brand, etc.

        Returns:
            Embedding vector
        """
        # Combine item attributes for embedding
        parts = [
            item.get('name', ''),
            item.get('category', ''),
            item.get('sub_category', ''),
            ' '.join(item.get('colors', [])),
            item.get('brand', ''),
            ' '.join(item.get('tags', [])),
            item.get('material', ''),
        ]

        text = ' '.join(p for p in parts if p)
        return await EmbeddingService.generate_embedding(text)

    @staticmethod
    async def batch_generate_embeddings(texts: List[str]) -> List[Optional[List[float]]]:
        """Generate embeddings for multiple texts.

        Args:
            texts: List of texts to embed

        Returns:
            List of embedding vectors
        """
        embeddings = []

        for text in texts:
            embedding = await EmbeddingService.generate_embedding(text)
            embeddings.append(embedding)

        return embeddings


# ============================================================================
# OUTFIT GENERATION (AI IMAGE GENERATION)
# ============================================================================


class OutfitGenerator:
    """Generate AI visualization of outfits.

    For MVP, this is a placeholder. Full implementation would use:
    - Gemini 2.0 Flash with image generation capabilities
    - Or integration with services like Midjourney, DALL-E, Stable Diffusion
    """

    @staticmethod
    async def generate_outfit_image(
        items: List[Dict[str, Any]],
        prompt: Optional[str] = None,
        style: str = "casual",
        background: str = "studio",
        include_model: bool = True,
        model_gender: str = "female"
    ) -> Dict[str, Any]:
        """Generate an AI image of the outfit.

        Args:
            items: List of items in the outfit
            prompt: Optional custom prompt
            style: Style of the outfit
            background: Background setting
            include_model: Show on a model
            model_gender: Gender of model

        Returns:
            Dict with generation status and image URL
        """
        # For MVP, return a placeholder response
        # In production, this would call an image generation API

        logger.info(f"Generating outfit image with {len(items)} items")

        # Build detailed prompt
        item_descriptions = []
        for item in items:
            desc = f"{item.get('name', '')} ({item.get('category', '')})"
            if item.get('colors'):
                desc += f" in {', '.join(item['colors'])}"
            item_descriptions.append(desc)

        base_prompt = f"A {style} outfit featuring: {', '.join(item_descriptions)}"
        if background:
            base_prompt += f" on a {background} background"
        if include_model:
            base_prompt += f" worn by a {model_gender} model"

        final_prompt = prompt or base_prompt

        # Placeholder response - would return actual generated image URL
        return {
            "generation_id": f"gen_{datetime.now().timestamp()}",
            "status": "pending",  # Would be "processing" then "completed"
            "prompt_used": final_prompt,
            "estimated_time": 30,  # seconds
            "image_url": None,  # Would be populated when complete
            "message": "Outfit generation initiated. Check status endpoint for updates."
        }

    @staticmethod
    async def get_generation_status(generation_id: str) -> Dict[str, Any]:
        """Check the status of an outfit generation.

        Args:
            generation_id: ID from generation request

        Returns:
            Status information
        """
        # MVP: Always return pending
        # Production: Check actual generation status
        return {
            "generation_id": generation_id,
            "status": "pending",
            "progress": 0.0,
            "image_url": None,
            "error": None,
            "started_at": None,
            "completed_at": None
        }


# ============================================================================
# SMART MATCHING
# ============================================================================


class SmartMatcher:
    """Find matching items using AI analysis."""

    @staticmethod
    async def find_matching_items(
        source_item: Dict[str, Any],
        candidate_items: List[Dict[str, Any]],
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Find items that match well with the source item.

        Args:
            source_item: The item to find matches for
            candidate_items: Items to consider as matches
            limit: Maximum number of matches

        Returns:
            List of matched items with scores
        """
        # Use embeddings for similarity matching
        source_embedding = await EmbeddingService.generate_item_embedding(source_item)

        if not source_embedding:
            # Fallback to simple rule-based matching
            return SmartMatcher._rule_based_matching(source_item, candidate_items, limit)

        # Calculate cosine similarity with each candidate
        matches = []

        for candidate in candidate_items:
            candidate_embedding = candidate.get('embedding')
            if not candidate_embedding:
                continue

            similarity = SmartMatcher._cosine_similarity(source_embedding, candidate_embedding)

            # Boost score for complementary categories
            category_boost = SmartMatcher._get_category_boost(
                source_item.get('category', ''),
                candidate.get('category', '')
            )

            # Color harmony bonus
            color_bonus = SmartMatcher._get_color_harmony_bonus(
                source_item.get('colors', []),
                candidate.get('colors', [])
            )

            final_score = min(1.0, similarity + category_boost + color_bonus)

            matches.append({
                "item": candidate,
                "score": final_score,
                "reasons": SmartMatcher._get_match_reasons(source_item, candidate, final_score)
            })

        # Sort by score and limit
        matches.sort(key=lambda x: x['score'], reverse=True)
        return matches[:limit]

    @staticmethod
    def _cosine_similarity(a: List[float], b: List[float]) -> float:
        """Calculate cosine similarity between two vectors."""
        import math

        dot_product = sum(x * y for x, y in zip(a, b))
        magnitude_a = math.sqrt(sum(x * x for x in a))
        magnitude_b = math.sqrt(sum(y * y for y in b))

        if magnitude_a == 0 or magnitude_b == 0:
            return 0.0

        return dot_product / (magnitude_a * magnitude_b)

    @staticmethod
    def _get_category_boost(source_cat: str, candidate_cat: str) -> float:
        """Get score boost for complementary categories."""
        complementary = {
            'tops': ['bottoms', 'shoes', 'accessories'],
            'bottoms': ['tops', 'shoes', 'accessories'],
            'shoes': ['tops', 'bottoms', 'accessories'],
            'outerwear': ['tops', 'bottoms'],
            'accessories': ['tops', 'bottoms', 'shoes', 'outerwear'],
        }

        if candidate_cat in complementary.get(source_cat, []):
            return 0.1  # Small boost for complementary items
        return 0.0

    @staticmethod
    def _get_color_harmony_bonus(source_colors: List[str], candidate_colors: List[str]) -> float:
        """Calculate color harmony bonus."""
        if not source_colors or not candidate_colors:
            return 0.0

        # Neutrals match with anything
        neutrals = {'black', 'white', 'gray', 'grey', 'beige', 'cream'}

        source_set = set(c.lower() for c in source_colors)
        candidate_set = set(c.lower() for c in candidate_colors)

        # Both neutral - good match
        if source_set.issubset(neutrals) and candidate_set.issubset(neutrals):
            return 0.05

        # Complementary colors (simplified)
        complementary_pairs = {
            'blue': {'orange', 'brown', 'white'},
            'red': {'green', 'black', 'white'},
            'green': {'red', 'brown', 'cream'},
            'yellow': {'purple', 'gray', 'navy'},
            'purple': {'yellow', 'gray', 'black'},
            'pink': {'gray', 'navy', 'white'},
            'navy': {'white', 'beige', 'yellow'},
        }

        for sc in source_colors:
            for cc in candidate_colors:
                if cc in complementary_pairs.get(sc, set()):
                    return 0.1

        return 0.0

    @staticmethod
    def _get_match_reasons(source: Dict, candidate: Dict, score: float) -> List[str]:
        """Generate human-readable match reasons."""
        reasons = []

        if score > 0.8:
            reasons.append("excellent style match")
        elif score > 0.6:
            reasons.append("good style compatibility")

        source_cat = source.get('category', '')
        cand_cat = candidate.get('category', '')

        if source_cat != cand_cat:
            reasons.append(f"complementary {cand_cat} for your {source_cat}")

        source_colors = source.get('colors', [])
        cand_colors = candidate.get('colors', [])

        if source_colors and cand_colors:
            if set(source_colors) & set(cand_colors):
                reasons.append("matching colors")

        return reasons

    @staticmethod
    def _rule_based_matching(
        source_item: Dict,
        candidate_items: List[Dict],
        limit: int
    ) -> List[Dict[str, Any]]:
        """Fallback rule-based matching when embeddings aren't available."""
        matches = []

        source_cat = source_item.get('category', '')
        source_colors = set(c.lower() for c in source_item.get('colors', []))

        for candidate in candidate_items:
            score = 0.5  # Base score
            reasons = []

            # Category complement check
            if candidate.get('category') != source_cat:
                score += 0.2
                reasons.append(f"complementary {candidate.get('category')}")

            # Color check
            cand_colors = set(c.lower() for c in candidate.get('colors', []))

            neutrals = {'black', 'white', 'gray', 'grey', 'beige', 'cream'}
            if source_colors and cand_colors:
                if source_colors & cand_colors:
                    score += 0.15
                    reasons.append("matching colors")
                elif (source_colors & neutrals) or (cand_colors & neutrals):
                    score += 0.1
                    reasons.append("neutral color coordination")

            matches.append({
                "item": candidate,
                "score": min(1.0, score),
                "reasons": reasons
            })

        matches.sort(key=lambda x: x['score'], reverse=True)
        return matches[:limit]


# ============================================================================
# SERVICE EXPORTS
# ============================================================================


class AIService:
    """Main AI service interface."""

    extract_items = ItemExtractor.extract_items
    generate_embedding = EmbeddingService.generate_embedding
    generate_item_embedding = EmbeddingService.generate_item_embedding
    generate_outfit_image = OutfitGenerator.generate_outfit_image
    get_generation_status = OutfitGenerator.get_generation_status
    find_matching_items = SmartMatcher.find_matching_items
