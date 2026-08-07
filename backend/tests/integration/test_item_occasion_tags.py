from app.models.item import ItemCreate, ItemUpdate, normalize_tag_list


def test_normalize_tag_list_trims_lowercases_and_dedupes() -> None:
    assert normalize_tag_list([
        ' Formal ',
        'formal',
        '',
        ' Dinner ',
        'DINNER',
        None,
        'custom',
    ]) == ['formal', 'dinner', 'custom']


def test_item_create_normalizes_occasion_tags() -> None:
    item = ItemCreate(
        name='Blue Blazer',
        category='tops',
        occasion_tags=[' Formal ', 'formal', 'Party', '', 'party'],
    )

    assert item.occasion_tags == ['formal', 'party']


def test_item_update_normalizes_occasion_tags_when_present() -> None:
    update = ItemUpdate(occasion_tags=[' Date ', 'date', 'Lunch', ''])
    assert update.occasion_tags == ['date', 'lunch']


def test_item_update_keeps_none_when_not_provided() -> None:
    update = ItemUpdate()
    assert update.occasion_tags is None
