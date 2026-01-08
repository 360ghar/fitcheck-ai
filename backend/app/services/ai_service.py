"""
AI service for FitCheck AI.

This service provides AI-powered features for the application.
Following the server-side architecture:
- Item extraction: Server-side via AI Provider Service (Gemini/OpenAI/Custom)
- Outfit generation: Server-side via AI Provider Service image generation
- Embeddings & matching: Server-side via Gemini Embeddings + Pinecone

@see https://docs.fitcheck.ai/technical/architecture
"""

from typing import Any, Dict, List, Optional

from google import genai
from google.genai import types
from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.utils.parallel import parallel_with_retry

logger = get_context_logger(__name__)

def _create_genai_client() -> genai.Client | None:
    if not settings.GEMINI_API_KEY:
        logger.info("GEMINI_API_KEY is not set; server-side embeddings are disabled.")
        return None

    try:
        return genai.Client(api_key=settings.GEMINI_API_KEY)
    except Exception as e:
        logger.error(
            "Failed to initialize Gemini client",
            error=str(e),
        )
        raise AIServiceError(f"Failed to initialize AI client: {str(e)}")


_client = _create_genai_client()


# ============================================================================
# TEXT EMBEDDINGS (for Pinecone recommendations)
# ============================================================================


class EmbeddingService:
    """Generate text embeddings using Gemini Embeddings.

    Used for:
    - Item similarity matching
    - Outfit recommendations
    - Search functionality
    """

    @staticmethod
    async def generate_embedding(text: str) -> List[float]:
        """Generate an embedding vector for the given text.

        Args:
            text: Text to embed

        Returns:
            List of float values (dimension controlled by `PINECONE_DIMENSION`)

        Raises:
            AIServiceError: If client not configured or embedding generation fails
        """
        if _client is None:
            logger.error(
                "AI client not initialized",
                text_length=len(text),
            )
            raise AIServiceError("AI service not configured. GEMINI_API_KEY is required.")

        try:
            result = _client.models.embed_content(
                model=settings.GEMINI_EMBEDDING_MODEL,
                contents=text,
                config=types.EmbedContentConfig(
                    task_type="RETRIEVAL_DOCUMENT",
                    output_dimensionality=settings.PINECONE_DIMENSION,
                ),
            )

            embeddings = getattr(result, "embeddings", None) or []
            if embeddings and getattr(embeddings[0], "values", None) is not None:
                logger.debug(
                    "Generated embedding",
                    text_length=len(text),
                    embedding_dimension=len(embeddings[0].values),
                )
                return list(embeddings[0].values)

            logger.error(
                "Embedding response missing values",
                text_length=len(text),
                embeddings_count=len(embeddings),
            )
            raise AIServiceError("Failed to generate embedding: empty response from AI service")

        except AIServiceError:
            raise
        except Exception as e:
            logger.error(
                "Failed to generate embedding",
                text_length=len(text),
                error=str(e),
            )
            raise AIServiceError(f"Failed to generate embedding: {str(e)}")

    @staticmethod
    async def generate_item_embedding(item: Dict[str, Any]) -> List[float]:
        """Generate embedding for an item's combined attributes.

        Combines name, category, colors, brand, tags, and material
        into a single embedding vector for similarity matching.

        Args:
            item: Item dict with name, category, colors, brand, etc.

        Returns:
            Embedding vector

        Raises:
            AIServiceError: If embedding generation fails
        """
        # Combine item attributes for embedding
        parts = [
            item.get("name", ""),
            item.get("category", ""),
            item.get("sub_category", ""),
            " ".join(item.get("colors", [])),
            item.get("brand", ""),
            " ".join(item.get("tags", [])),
            item.get("material", ""),
        ]

        text = " ".join(p for p in parts if p)

        if not text.strip():
            logger.error(
                "Cannot generate embedding for empty item",
                item_id=item.get("id"),
            )
            raise AIServiceError("Cannot generate embedding: item has no text content")

        return await EmbeddingService.generate_embedding(text)

    @staticmethod
    async def batch_generate_embeddings(
        texts: List[str],
    ) -> List[List[float]]:
        """Generate embeddings for multiple texts in parallel.

        Args:
            texts: List of texts to embed

        Returns:
            List of embedding vectors

        Raises:
            AIServiceError: If any embedding generation fails
        """
        if not texts:
            return []

        # Process all embeddings in parallel with retry
        results = await parallel_with_retry(
            texts,
            lambda text, _: EmbeddingService.generate_embedding(text),
            max_retries=3,
            initial_delay=1.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
        )

        # Check for failures
        failed_indices = [r.index for r in results if not r.success]
        if failed_indices:
            first_error = next(r.error for r in results if not r.success)
            logger.error(
                "Failed to generate embeddings in batch",
                failed_indices=failed_indices,
                first_error=str(first_error),
            )
            raise AIServiceError(
                f"Failed to generate embeddings for indices {failed_indices}: {first_error}"
            )

        embeddings = [r.data for r in results]

        logger.info(
            "Generated batch embeddings in parallel",
            count=len(embeddings),
        )

        return embeddings


# ============================================================================
# SMART MATCHING (for recommendations)
# ============================================================================


class SmartMatcher:
    """Find matching items using AI analysis and embeddings.

    Used for:
    - Completing an outfit
    - Finding similar items
    - Suggesting complementary items
    """

    @staticmethod
    async def find_matching_items(
        source_item: Dict[str, Any],
        candidate_items: List[Dict[str, Any]],
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """Find items that match well with the source item.

        Uses cosine similarity on embeddings for primary matching,
        with rule-based boosts for complementary categories and
        color harmony.

        Args:
            source_item: The item to find matches for
            candidate_items: Items to consider as matches
            limit: Maximum number of matches

        Returns:
            List of matched items with scores and reasons

        Raises:
            AIServiceError: If embedding generation fails
        """
        # Use embeddings for similarity matching
        source_embedding = await EmbeddingService.generate_item_embedding(source_item)

        logger.debug(
            "Finding matching items",
            source_item_id=source_item.get("id"),
            candidate_count=len(candidate_items),
            limit=limit,
        )

        # Calculate cosine similarity with each candidate
        matches = []

        for candidate in candidate_items:
            candidate_embedding = candidate.get("embedding")
            if not candidate_embedding:
                logger.debug(
                    "Skipping candidate without embedding",
                    candidate_id=candidate.get("id"),
                )
                continue

            similarity = SmartMatcher._cosine_similarity(
                source_embedding, candidate_embedding
            )

            # Boost score for complementary categories
            category_boost = SmartMatcher._get_category_boost(
                source_item.get("category", ""), candidate.get("category", "")
            )

            # Color harmony bonus
            color_bonus = SmartMatcher._get_color_harmony_bonus(
                source_item.get("colors", []), candidate.get("colors", [])
            )

            final_score = min(1.0, similarity + category_boost + color_bonus)

            matches.append(
                {
                    "item": candidate,
                    "score": final_score,
                    "reasons": SmartMatcher._get_match_reasons(
                        source_item, candidate, final_score
                    ),
                }
            )

        # Sort by score and limit
        matches.sort(key=lambda x: x["score"], reverse=True)

        logger.info(
            "Found matching items",
            source_item_id=source_item.get("id"),
            matches_found=len(matches[:limit]),
            total_candidates=len(candidate_items),
        )

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
            "tops": ["bottoms", "shoes", "accessories"],
            "bottoms": ["tops", "shoes", "accessories"],
            "shoes": ["tops", "bottoms", "accessories"],
            "outerwear": ["tops", "bottoms"],
            "accessories": ["tops", "bottoms", "shoes", "outerwear"],
        }

        if candidate_cat in complementary.get(source_cat, []):
            return 0.1  # Small boost for complementary items
        return 0.0

    @staticmethod
    def _get_color_harmony_bonus(
        source_colors: List[str], candidate_colors: List[str]
    ) -> float:
        """Calculate color harmony bonus."""
        if not source_colors or not candidate_colors:
            return 0.0

        # Neutrals match with anything
        neutrals = {"black", "white", "gray", "grey", "beige", "cream"}

        source_set = set(c.lower() for c in source_colors)
        candidate_set = set(c.lower() for c in candidate_colors)

        # Both neutral - good match
        if source_set.issubset(neutrals) and candidate_set.issubset(neutrals):
            return 0.05

        # Complementary colors (simplified)
        complementary_pairs = {
            "blue": {"orange", "brown", "white"},
            "red": {"green", "black", "white"},
            "green": {"red", "brown", "cream"},
            "yellow": {"purple", "gray", "navy"},
            "purple": {"yellow", "gray", "black"},
            "pink": {"gray", "navy", "white"},
            "navy": {"white", "beige", "yellow"},
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

        source_cat = source.get("category", "")
        cand_cat = candidate.get("category", "")

        if source_cat != cand_cat:
            reasons.append(f"complementary {cand_cat} for your {source_cat}")

        source_colors = source.get("colors", [])
        cand_colors = candidate.get("colors", [])

        if source_colors and cand_colors:
            if set(source_colors) & set(cand_colors):
                reasons.append("matching colors")

        return reasons


# ============================================================================
# SERVICE EXPORTS
# ============================================================================


class AIService:
    """Main AI service interface.

    Note: Item extraction and outfit generation are handled server-side
    via the AI Provider Service. This legacy service focuses on embeddings
    and smart matching for recommendations.

    @see https://docs.fitcheck.ai/technical/architecture
    """

    # Embedding services (kept on server for Pinecone integration)
    generate_embedding = EmbeddingService.generate_embedding
    generate_item_embedding = EmbeddingService.generate_item_embedding
    batch_generate_embeddings = EmbeddingService.batch_generate_embeddings

    # Smart matching services
    find_matching_items = SmartMatcher.find_matching_items
