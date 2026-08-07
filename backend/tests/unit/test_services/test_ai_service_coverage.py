"""Coverage-completing tests for app/services/ai_service.py.

Exercises the embedding pipeline (single, item, batch - success and every
failure branch), the module-level client factory, and the SmartMatcher
scoring/boost/reason paths. The google-genai client is faked at the
module-level `_client` boundary (the SDK's sync `embed_content` is mocked, so
no network or event-loop weirdness); `parallel_with_retry` is stubbed for the
batch path.
"""

from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.core.exceptions import AIServiceError
from app.services import ai_service as ai_module
from app.services.ai_service import AIService, EmbeddingService, SmartMatcher
from app.utils.parallel import ParallelResult


def _fake_client(embed_content=None) -> SimpleNamespace:
    return SimpleNamespace(models=SimpleNamespace(embed_content=embed_content or Mock()))


# =============================================================================
# Module-level client factory
# =============================================================================


def test_create_genai_client_returns_none_without_key(monkeypatch):
    monkeypatch.setattr(ai_module.settings, "AI_GEMINI_API_KEY", None)
    assert ai_module._create_genai_client() is None


def test_create_genai_client_raises_on_client_failure(monkeypatch):
    monkeypatch.setattr(ai_module.settings, "AI_GEMINI_API_KEY", "k")
    with patch.object(ai_module.genai, "Client", side_effect=RuntimeError("no client")):
        with pytest.raises(AIServiceError, match="Failed to initialize AI client"):
            ai_module._create_genai_client()


# =============================================================================
# EmbeddingService.generate_embedding
# =============================================================================


@pytest.mark.asyncio
async def test_generate_embedding_success():
    embed_content = Mock(
        return_value=SimpleNamespace(embeddings=[SimpleNamespace(values=[0.1, 0.2])])
    )
    with patch.object(ai_module, "_client", _fake_client(embed_content)):
        result = await EmbeddingService.generate_embedding("hello world")

    assert result == [0.1, 0.2]
    call = embed_content.call_args
    assert call.kwargs["model"] == ai_module.settings.AI_GEMINI_EMBEDDING_MODEL
    assert call.kwargs["contents"] == "hello world"
    assert call.kwargs["config"].task_type == "RETRIEVAL_DOCUMENT"
    assert call.kwargs["config"].output_dimensionality == ai_module.settings.PINECONE_DIMENSION


@pytest.mark.asyncio
async def test_generate_embedding_without_client_raises():
    with patch.object(ai_module, "_client", None):
        with pytest.raises(AIServiceError, match="not configured"):
            await EmbeddingService.generate_embedding("hello")


@pytest.mark.asyncio
async def test_generate_embedding_empty_response_raises():
    with patch.object(ai_module, "_client", _fake_client(Mock(return_value=SimpleNamespace(embeddings=[])))):
        with pytest.raises(AIServiceError, match="empty response"):
            await EmbeddingService.generate_embedding("hello")


@pytest.mark.asyncio
async def test_generate_embedding_missing_values_raises():
    with patch.object(
        ai_module, "_client",
        _fake_client(Mock(return_value=SimpleNamespace(embeddings=[SimpleNamespace(values=None)]))),
    ):
        with pytest.raises(AIServiceError, match="empty response"):
            await EmbeddingService.generate_embedding("hello")


@pytest.mark.asyncio
async def test_generate_embedding_propagates_aiservice_error():
    with patch.object(
        ai_module, "_client", _fake_client(Mock(side_effect=AIServiceError("quota exhausted")))
    ):
        with pytest.raises(AIServiceError, match="quota exhausted"):
            await EmbeddingService.generate_embedding("hello")


@pytest.mark.asyncio
async def test_generate_embedding_wraps_unexpected_error():
    with patch.object(
        ai_module, "_client", _fake_client(Mock(side_effect=RuntimeError("boom")))
    ):
        with pytest.raises(AIServiceError, match="Failed to generate embedding: boom"):
            await EmbeddingService.generate_embedding("hello")


# =============================================================================
# EmbeddingService.generate_item_embedding
# =============================================================================


@pytest.mark.asyncio
async def test_generate_item_embedding_combines_attributes():
    with patch.object(EmbeddingService, "generate_embedding", AsyncMock(return_value=[1.0])) as mock_gen:
        result = await EmbeddingService.generate_item_embedding({
            "id": "item-1",
            "name": "Denim Jacket",
            "category": "outerwear",
            "sub_category": "jacket",
            "colors": ["Blue", "Black"],
            "brand": "Levis",
            "tags": ["denim"],
            "material": "cotton",
        })

    assert result == [1.0]
    text = mock_gen.await_args.args[0]
    assert text == "Denim Jacket outerwear jacket Blue Black Levis denim cotton"


@pytest.mark.asyncio
async def test_generate_item_embedding_empty_item_raises():
    with pytest.raises(AIServiceError, match="no text content"):
        await EmbeddingService.generate_item_embedding({"id": "empty-item"})


# =============================================================================
# EmbeddingService.batch_generate_embeddings
# =============================================================================


@pytest.mark.asyncio
async def test_batch_generate_embeddings_empty_returns_empty():
    assert await EmbeddingService.batch_generate_embeddings([]) == []


@pytest.mark.asyncio
async def test_batch_generate_embeddings_success():
    results = [
        ParallelResult(success=True, data=[1.0], index=0),
        ParallelResult(success=True, data=[2.0], index=1),
    ]
    with patch.object(ai_module, "parallel_with_retry", AsyncMock(return_value=results)):
        embeddings = await EmbeddingService.batch_generate_embeddings(["a", "b"])
    assert embeddings == [[1.0], [2.0]]


@pytest.mark.asyncio
async def test_batch_generate_embeddings_failure_raises():
    results = [
        ParallelResult(success=True, data=[1.0], index=0),
        ParallelResult(success=False, error=ValueError("bad bytes"), index=1),
    ]
    with patch.object(ai_module, "parallel_with_retry", AsyncMock(return_value=results)):
        with pytest.raises(AIServiceError, match=r"indices \[1\]"):
            await EmbeddingService.batch_generate_embeddings(["a", "b"])


# =============================================================================
# SmartMatcher.find_matching_items
# =============================================================================


@pytest.mark.asyncio
async def test_find_matching_items_scores_boosts_reasons_and_limit():
    source = {"id": "s1", "category": "tops", "colors": ["blue"]}
    candidates = [
        {"id": "c1", "category": "bottoms", "colors": ["orange"], "embedding": [1.0, 1.0]},
        {"id": "c2", "category": "tops", "colors": ["red"], "embedding": [0.0, 1.0]},
        # No embedding -> skipped entirely.
        {"id": "c3", "category": "tops", "colors": ["blue"]},
    ]
    with patch.object(EmbeddingService, "generate_item_embedding", AsyncMock(return_value=[1.0, 0.0])):
        matches = await SmartMatcher.find_matching_items(source, candidates, limit=1)

    assert len(matches) == 1
    assert matches[0]["item"]["id"] == "c1"
    # cosine([1,0],[1,1]) = 1/sqrt(2) ~ 0.7071 + category boost 0.1 + blue->orange harmony 0.1
    assert matches[0]["score"] == pytest.approx((1 / (2**0.5)) + 0.1 + 0.1)
    assert "excellent style match" in matches[0]["reasons"]
    assert "complementary bottoms for your tops" in matches[0]["reasons"]


@pytest.mark.asyncio
async def test_find_matching_items_neutral_colors_and_ranking():
    source = {"id": "s1", "category": "shoes", "colors": ["black"]}
    candidates = [
        {"id": "c1", "category": "shoes", "colors": ["white"], "embedding": [1.0, 1.0]},
        {"id": "c2", "category": "shoes", "colors": ["black"], "embedding": [1.0, 1.0]},
    ]
    with patch.object(EmbeddingService, "generate_item_embedding", AsyncMock(return_value=[1.0, 0.0])):
        matches = await SmartMatcher.find_matching_items(source, candidates, limit=10)

    # Both candidates: same category (no boost) + both-neutral colors (0.05);
    # cosine([1,0],[1,1]) = 1/sqrt(2).
    assert matches[0]["score"] == pytest.approx((1 / (2**0.5)) + 0.05)
    assert matches[1]["score"] == pytest.approx((1 / (2**0.5)) + 0.05)
    assert matches[0]["reasons"] == ["good style compatibility"]


@pytest.mark.asyncio
async def test_find_matching_items_matching_colors_reason():
    source = {"id": "s1", "category": "tops", "colors": ["blue"]}
    candidate = {"id": "c1", "category": "tops", "colors": ["blue"], "embedding": [1.0, 1.0]}
    with patch.object(EmbeddingService, "generate_item_embedding", AsyncMock(return_value=[1.0, 1.0])):
        matches = await SmartMatcher.find_matching_items(source, [candidate], limit=10)
    assert "matching colors" in matches[0]["reasons"]


def test_cosine_similarity_zero_magnitude():
    assert SmartMatcher._cosine_similarity([0, 0], [1, 1]) == 0.0
    assert SmartMatcher._cosine_similarity([1, 1], [0, 0]) == 0.0
    assert SmartMatcher._cosine_similarity([1, 2], [3, 4]) == pytest.approx(11 / (5**0.5 * 25**0.5))


def test_category_boost_complementary_and_same():
    assert SmartMatcher._get_category_boost("tops", "bottoms") == 0.1
    assert SmartMatcher._get_category_boost("tops", "tops") == 0.0


def test_color_harmony_bonus_branches():
    assert SmartMatcher._get_color_harmony_bonus([], ["red"]) == 0.0
    assert SmartMatcher._get_color_harmony_bonus(["red"], []) == 0.0
    assert SmartMatcher._get_color_harmony_bonus(["black"], ["white"]) == 0.05
    assert SmartMatcher._get_color_harmony_bonus(["blue"], ["orange"]) == 0.1
    assert SmartMatcher._get_color_harmony_bonus(["red"], ["blue"]) == 0.0


def test_match_reasons_tiers_and_categories():
    reasons = SmartMatcher._get_match_reasons(
        {"category": "tops", "colors": []}, {"category": "bottoms", "colors": []}, 0.9
    )
    assert reasons == ["excellent style match", "complementary bottoms for your tops"]

    reasons = SmartMatcher._get_match_reasons(
        {"category": "tops", "colors": []}, {"category": "bottoms", "colors": []}, 0.65
    )
    assert reasons == ["good style compatibility", "complementary bottoms for your tops"]

    assert SmartMatcher._get_match_reasons(
        {"category": "tops", "colors": []}, {"category": "tops", "colors": []}, 0.5
    ) == []


# =============================================================================
# AIService facade aliases
# =============================================================================


def test_aiservice_exposes_embedding_and_matching_aliases():
    assert AIService.generate_embedding is EmbeddingService.generate_embedding
    assert AIService.generate_item_embedding is EmbeddingService.generate_item_embedding
    assert AIService.batch_generate_embeddings is EmbeddingService.batch_generate_embeddings
    assert AIService.find_matching_items is SmartMatcher.find_matching_items
