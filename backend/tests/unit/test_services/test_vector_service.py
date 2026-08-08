"""
Tests for VectorService (Pinecone wrapper): upsert/delete/search/index
management and the module-level singleton.

The Pinecone client is never constructed: ``service._pc`` / ``service._index``
are injected as Mocks, and the ``pc``/``index`` property tests patch the
``Pinecone`` class itself. All SDK calls run through ``asyncio.to_thread``, so
plain Mocks are sufficient for the thread-offloaded calls.
"""

import math
from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from app.core.config import settings
from app.services import vector_service as svc
from app.services.vector_service import VectorService


@pytest.fixture(autouse=True)
def _reset_singleton(monkeypatch):
    """Each test starts with a fresh module-level singleton."""
    monkeypatch.setattr(svc, "_vector_service", None)


@pytest.fixture
def service():
    """A VectorService with mocked Pinecone client/index wired in directly."""
    instance = VectorService()
    instance._pc = Mock()
    instance._index = Mock()
    return instance


def _match(item_id: str, score: float = 0.9, metadata=None) -> SimpleNamespace:
    return SimpleNamespace(id=item_id, score=score, metadata=metadata)


# ---------------------------------------------------------------------------
# Client/index property construction
# ---------------------------------------------------------------------------


def test_pc_property_creates_pinecone_client_once(monkeypatch):
    monkeypatch.setattr(settings, "PINECONE_API_KEY", "test-pinecone-key")
    fake_pinecone = Mock()
    monkeypatch.setattr(svc, "Pinecone", fake_pinecone)

    service = VectorService()
    client = service.pc

    assert client is service.pc
    fake_pinecone.assert_called_once_with(api_key="test-pinecone-key")


def test_index_property_creates_index_once():
    service = VectorService()
    service._pc = Mock()

    idx = service.index

    assert idx is service.index
    service._pc.Index.assert_called_once_with(settings.PINECONE_INDEX_NAME)


# ---------------------------------------------------------------------------
# ITEM OPERATIONS
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_upsert_item_success(service):
    assert await service.upsert_item(
        "item-1", [0.1, 0.2], {"user_id": "u1", "brand": None, "tags": ["a", None, "b"]}
    ) is True

    service._index.upsert.assert_called_once_with(
        vectors=[("item-1", [0.1, 0.2], {"user_id": "u1", "tags": ["a", "b"]})]
    )


@pytest.mark.asyncio
async def test_upsert_item_error_returns_false(service):
    service._index.upsert.side_effect = RuntimeError("pinecone down")

    assert await service.upsert_item("item-1", [0.1], {"user_id": "u1"}) is False


@pytest.mark.asyncio
async def test_batch_upsert_empty_returns_zero(service):
    assert await service.batch_upsert([]) == 0
    service._index.upsert.assert_not_called()


@pytest.mark.asyncio
async def test_batch_upsert_success(service):
    items = [
        ("a", [1.0], {"user_id": "u1"}),
        ("b", [2.0], {"user_id": "u1", "note": None}),
    ]
    assert await service.batch_upsert(items) == 2

    service._index.upsert.assert_called_once_with(
        vectors=[
            ("a", [1.0], {"user_id": "u1"}),
            ("b", [2.0], {"user_id": "u1"}),
        ]
    )


@pytest.mark.asyncio
async def test_batch_upsert_error_returns_zero(service):
    service._index.upsert.side_effect = RuntimeError("boom")

    assert await service.batch_upsert([("a", [1.0], {})]) == 0


@pytest.mark.asyncio
async def test_delete_item_success(service):
    assert await service.delete_item("item-1") is True
    service._index.delete.assert_called_once_with(ids=["item-1"])


@pytest.mark.asyncio
async def test_delete_item_error_returns_false(service):
    service._index.delete.side_effect = RuntimeError("boom")

    assert await service.delete_item("item-1") is False


@pytest.mark.asyncio
async def test_batch_delete_empty_returns_zero(service):
    assert await service.batch_delete([]) == 0
    service._index.delete.assert_not_called()


@pytest.mark.asyncio
async def test_batch_delete_success(service):
    assert await service.batch_delete(["a", "b"]) == 2
    service._index.delete.assert_called_once_with(ids=["a", "b"])


@pytest.mark.asyncio
async def test_batch_delete_error_returns_zero(service):
    service._index.delete.side_effect = RuntimeError("boom")

    assert await service.batch_delete(["a"]) == 0


@pytest.mark.asyncio
async def test_delete_user_items_deletes_found_ids(service):
    service._index.query.return_value = SimpleNamespace(
        matches=[_match("a"), _match("b")]
    )

    assert await service.delete_user_items("u1") == 2

    service._index.query.assert_called_once_with(
        vector=[0.0] * settings.PINECONE_DIMENSION,
        filter={"user_id": {"$eq": "u1"}},
        top_k=10000,
        include_metadata=False,
    )
    service._index.delete.assert_called_once_with(ids=["a", "b"])


@pytest.mark.asyncio
async def test_delete_user_items_with_no_matches(service):
    service._index.query.return_value = SimpleNamespace(matches=[])

    assert await service.delete_user_items("u1") == 0
    service._index.delete.assert_not_called()


@pytest.mark.asyncio
async def test_delete_user_items_error_returns_zero(service):
    service._index.query.side_effect = RuntimeError("boom")

    assert await service.delete_user_items("u1") == 0


# ---------------------------------------------------------------------------
# SEARCH OPERATIONS
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_find_similar_builds_filters_filters_matches_and_slices(service):
    service._index.query.return_value = SimpleNamespace(
        matches=[
            _match("excluded", 0.95, {"category": "tops"}),
            _match("weak", 0.1, None),
            _match("hit-1", 0.8, {"category": "tops"}),
            _match("hit-2", 0.7, None),
            _match("hit-3", 0.6, {"category": "tops"}),  # beyond top_k
        ]
    )

    result = await service.find_similar(
        embedding=[0.5, 0.5],
        user_id="u1",
        category="tops",
        colors=["red", "blue"],
        exclude_item_ids=["excluded"],
        top_k=2,
        min_score=0.5,
    )

    assert [r["item_id"] for r in result] == ["hit-1", "hit-2"]
    assert result[1]["metadata"] == {}  # None metadata becomes {}
    service._index.query.assert_called_once_with(
        vector=[0.5, 0.5],
        filter={
            "user_id": {"$eq": "u1"},
            "category": {"$eq": "tops"},
            "colors": {"$in": ["red", "blue"]},
        },
        top_k=4,
        include_metadata=True,
    )


@pytest.mark.asyncio
async def test_find_similar_without_filters_passes_none_filter(service):
    service._index.query.return_value = SimpleNamespace(matches=[])

    assert await service.find_similar([0.5]) == []

    service._index.query.assert_called_once_with(
        vector=[0.5], filter=None, top_k=20, include_metadata=True
    )


@pytest.mark.asyncio
async def test_find_similar_error_returns_empty(service):
    service._index.query.side_effect = RuntimeError("boom")

    assert await service.find_similar([0.5]) == []


@pytest.mark.asyncio
async def test_find_matching_items_appends_source_category_and_excludes_self(service):
    """Each item's $nin filter is built from a copy of the caller's
    exclude_categories list, so source-category appends never leak into
    other items' filters (or back into the caller's own list)."""
    service._index.fetch.return_value = SimpleNamespace(
        vectors={
            "item-a": SimpleNamespace(metadata={"category": "tops"}, values=[1.0]),
            "item-b": SimpleNamespace(metadata={}, values=[2.0]),
        }
    )
    service._index.query.side_effect = [
        SimpleNamespace(matches=[_match("item-x", 0.9, {}), _match("item-a", 0.8, {})]),
        SimpleNamespace(matches=[_match("item-y", 0.7, {})]),
    ]

    excludes = ["bottoms"]
    result = await service.find_matching_items(
        ["item-a", "item-b"],
        user_id="u1",
        exclude_categories=excludes,
    )

    # item-a: self-match excluded, source category appended to the $nin list.
    assert [m["item_id"] for m in result["item-a"]] == ["item-x"]
    assert [m["item_id"] for m in result["item-b"]] == ["item-y"]

    service._index.fetch.assert_called_once_with(ids=["item-a", "item-b"])
    assert service._index.query.call_count == 2
    # item-a filter: exclude_categories + own category.
    assert service._index.query.call_args_list[0].kwargs["filter"] == {
        "user_id": {"$eq": "u1"},
        "category": {"$nin": ["bottoms", "tops"]},
    }
    # item-b filter: the caller's list is not aliased, so "tops" must NOT leak in.
    assert service._index.query.call_args_list[1].kwargs["filter"] == {
        "user_id": {"$eq": "u1"},
        "category": {"$nin": ["bottoms"]},
    }
    # The caller's list is never mutated.
    assert excludes == ["bottoms"]


@pytest.mark.asyncio
async def test_find_matching_items_without_excludes_drops_category_filter(service):
    """With no exclude_categories and no source category, the filter is
    user_id-only (the `if excluded:` branch is False)."""
    service._index.fetch.return_value = SimpleNamespace(
        vectors={
            "item-a": SimpleNamespace(metadata={"category": "tops"}, values=[1.0]),
            "item-b": SimpleNamespace(metadata={}, values=[2.0]),
        }
    )
    service._index.query.side_effect = [
        SimpleNamespace(matches=[_match("item-a", 0.8, {})]),
        SimpleNamespace(matches=[_match("item-c", 0.7, {})]),
    ]

    result = await service.find_matching_items(["item-a", "item-b"], user_id="u1")

    assert result["item-a"] == []  # only a self-match: excluded
    assert [m["item_id"] for m in result["item-b"]] == ["item-c"]
    assert service._index.query.call_args_list[0].kwargs["filter"] == {
        "user_id": {"$eq": "u1"},
        "category": {"$nin": ["tops"]},
    }
    assert service._index.query.call_args_list[1].kwargs["filter"] == {
        "user_id": {"$eq": "u1"}
    }


@pytest.mark.asyncio
async def test_find_matching_items_error_returns_empty_dict(service):
    service._index.fetch.side_effect = RuntimeError("boom")

    assert await service.find_matching_items(["a"], user_id="u1") == {}


@pytest.mark.asyncio
async def test_search_by_metadata_builds_all_filters(service):
    service._index.query.return_value = SimpleNamespace(matches=[_match("a"), _match("b")])

    result = await service.search_by_metadata(
        "u1", category="tops", colors=["red"], brand="nike", limit=50
    )

    assert result == ["a", "b"]
    service._index.query.assert_called_once_with(
        vector=[0.0] * settings.PINECONE_DIMENSION,
        filter={
            "user_id": {"$eq": "u1"},
            "category": {"$eq": "tops"},
            "colors": {"$in": ["red"]},
            "brand": {"$eq": "nike"},
        },
        top_k=50,
        include_metadata=False,
    )


@pytest.mark.asyncio
async def test_search_by_metadata_only_user_id(service):
    service._index.query.return_value = SimpleNamespace(matches=[])

    assert await service.search_by_metadata("u1") == []

    service._index.query.assert_called_once_with(
        vector=[0.0] * settings.PINECONE_DIMENSION,
        filter={"user_id": {"$eq": "u1"}},
        top_k=100,
        include_metadata=False,
    )


@pytest.mark.asyncio
async def test_search_by_metadata_error_returns_empty(service):
    service._index.query.side_effect = RuntimeError("boom")

    assert await service.search_by_metadata("u1") == []


# ---------------------------------------------------------------------------
# INDEX MANAGEMENT
# ---------------------------------------------------------------------------


def test_create_index_when_index_exists_skips_creation(service):
    service._pc.list_indexes.return_value = [
        SimpleNamespace(name="other"),
        SimpleNamespace(name=settings.PINECONE_INDEX_NAME),
    ]

    assert service.create_index() is True
    service._pc.create_index.assert_not_called()


def test_create_index_creates_missing_index(service):
    service._pc.list_indexes.return_value = [SimpleNamespace(name="other")]

    assert service.create_index() is True

    call = service._pc.create_index.call_args
    assert call.kwargs["name"] == settings.PINECONE_INDEX_NAME
    assert call.kwargs["dimension"] == settings.PINECONE_DIMENSION
    assert call.kwargs["metric"] == "cosine"
    assert call.kwargs["spec"].cloud == "aws"
    assert call.kwargs["spec"].region == "us-east-1"


def test_create_index_error_returns_false(service):
    service._pc.list_indexes.side_effect = RuntimeError("boom")

    assert service.create_index() is False


def test_get_index_stats_returns_stats(service):
    service._index.describe_index_stats.return_value = {"totalVectorCount": 5}

    assert service.get_index_stats() == {"totalVectorCount": 5}


def test_get_index_stats_error_returns_none(service):
    service._index.describe_index_stats.side_effect = RuntimeError("boom")

    assert service.get_index_stats() is None


# ---------------------------------------------------------------------------
# UTILITY METHODS
# ---------------------------------------------------------------------------


def test_prepare_metadata_drops_none_and_normalizes_types():
    cleaned = VectorService._prepare_metadata(
        {
            "none": None,
            "str": "text",
            "int": 3,
            "float": 1.5,
            "bool": True,
            "list": [1, None, "x"],
            "dict": {"nested": True},
        }
    )

    assert cleaned == {
        "str": "text",
        "int": 3,
        "float": 1.5,
        "bool": True,
        "list": ["1", "x"],
        "dict": "{'nested': True}",
    }


def test_calculate_similarity_cosine_value():
    similarity = VectorService.calculate_similarity([1.0, 2.0], [3.0, 4.0])
    expected = (3.0 + 8.0) / (math.sqrt(5.0) * math.sqrt(25.0))
    assert similarity == pytest.approx(expected)


def test_calculate_similarity_dimension_mismatch_raises():
    with pytest.raises(ValueError, match="same dimension"):
        VectorService.calculate_similarity([1.0], [1.0, 2.0])


def test_calculate_similarity_zero_magnitude_returns_zero():
    assert VectorService.calculate_similarity([0.0, 0.0], [1.0, 1.0]) == 0.0
    assert VectorService.calculate_similarity([1.0, 1.0], [0.0, 0.0]) == 0.0


# ---------------------------------------------------------------------------
# SINGLETON
# ---------------------------------------------------------------------------


def test_get_vector_service_returns_singleton():
    first = svc.get_vector_service()
    second = svc.get_vector_service()

    assert isinstance(first, VectorService)
    assert first is second


def test_get_vector_service_resets_after_singleton_cleared(monkeypatch):
    monkeypatch.setattr(svc, "_vector_service", None)
    first = svc.get_vector_service()
    monkeypatch.setattr(svc, "_vector_service", None)
    second = svc.get_vector_service()

    assert first is not second
