"""Wardrobe gaps + shopping recommendation helpers and empty-wardrobe behavior.

Regression: empty wardrobe used to raise ItemNotFoundError(message=...) which
TypeError'd because ItemNotFoundError only accepts item_id, producing 500s on
GET /recommendations/shopping.
"""

from app.api.v1.recommendations import (
    _analyze_wardrobe_gaps,
    _count_by_category,
    _WARDROBE_IDEALS,
)


def test_count_by_category_normalizes_non_string():
    counts = _count_by_category(
        [
            {"category": "Tops"},
            {"category": "  bottoms "},
            {"category": None},
            {"category": 123},
            {},
        ]
    )
    assert counts["tops"] == 1
    assert counts["bottoms"] == 1
    assert counts["other"] == 2  # None + missing
    assert counts["123"] == 1


def test_analyze_empty_wardrobe_returns_all_gaps_not_error():
    analysis = _analyze_wardrobe_gaps([])
    assert analysis["wardrobe_completeness_score"] == 0
    missing = analysis["missing_essentials"]
    assert len(missing) == len(_WARDROBE_IDEALS)
    assert {m["category"] for m in missing} == set(_WARDROBE_IDEALS)
    assert all(row["is_underrepresented"] for row in analysis["category_breakdown"])


def test_analyze_full_wardrobe_has_no_missing_essentials():
    items = []
    for cat, (ideal_min, _) in _WARDROBE_IDEALS.items():
        for i in range(ideal_min):
            items.append({"id": f"{cat}-{i}", "category": cat})
    analysis = _analyze_wardrobe_gaps(items)
    assert analysis["missing_essentials"] == []
    assert analysis["wardrobe_completeness_score"] == 100


def test_analyze_partial_wardrobe_flags_underrepresented():
    items = [{"id": "1", "category": "tops"} for _ in range(10)]
    analysis = _analyze_wardrobe_gaps(items)
    missing_cats = {m["category"] for m in analysis["missing_essentials"]}
    assert "tops" not in missing_cats
    assert "bottoms" in missing_cats
    assert "shoes" in missing_cats
