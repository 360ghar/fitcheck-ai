"""Regression tests for Wave A auth, ownership, and storage hardening."""

from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from app.api.v1 import items as items_module
from app.api.v1 import outfits as outfits_module
from app.api.v1 import users as users_module
from app.core.exceptions import AuthenticationError, DatabaseError, UnsupportedMediaTypeError
from app.services.storage_service import StorageService


USER_ID = "user-a"
FOREIGN_USER_ID = "user-b"
OWNED_ITEM_ID = "item-a"
FOREIGN_ITEM_ID = "item-b"
OWNED_OUTFIT_ID = "outfit-a"
FOREIGN_OUTFIT_ID = "outfit-b"


class _Query:
    def __init__(self, db, table):
        self.db = db
        self.table_name = table
        self.operation = "select"
        self.filters = []

    def select(self, *_args, **_kwargs):
        self.operation = "select"
        return self

    def delete(self):
        self.operation = "delete"
        return self

    def eq(self, column, value):
        self.filters.append(("eq", column, value))
        return self

    def in_(self, column, values):
        self.filters.append(("in", column, set(values)))
        return self

    def execute(self):
        rows = list(self.db.tables.get(self.table_name, []))
        for kind, column, value in self.filters:
            if kind == "eq":
                rows = [row for row in rows if row.get(column) == value]
            else:
                rows = [row for row in rows if row.get(column) in value]
        self.db.queries.append((self.table_name, self.operation, list(self.filters)))
        return SimpleNamespace(data=rows)


class _DB:
    def __init__(self, tables):
        self.tables = tables
        self.queries = []

    def table(self, table_name):
        return _Query(self, table_name)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("route_module", "request_type", "image_table", "foreign_id", "owned_id", "foreign_path", "owned_path"),
    [
        (
            items_module,
            items_module.BatchDeleteItemsRequest,
            "item_images",
            FOREIGN_ITEM_ID,
            OWNED_ITEM_ID,
            "user-b/item.jpg",
            "user-a/item.jpg",
        ),
        (
            outfits_module,
            outfits_module.BatchDeleteOutfitsRequest,
            "outfit_images",
            FOREIGN_OUTFIT_ID,
            OWNED_OUTFIT_ID,
            "user-b/outfit.jpg",
            "user-a/outfit.jpg",
        ),
    ],
)
async def test_batch_delete_only_cleans_images_owned_by_requesting_user(
    monkeypatch,
    route_module,
    request_type,
    image_table,
    foreign_id,
    owned_id,
    foreign_path,
    owned_path,
):
    id_column = "item_id" if image_table == "item_images" else "outfit_id"
    parent_table = "items" if image_table == "item_images" else "outfits"
    db = _DB(
        {
            image_table: [
                {id_column: owned_id, "user_id": USER_ID, "storage_path": owned_path},
                {id_column: foreign_id, "user_id": FOREIGN_USER_ID, "storage_path": foreign_path},
            ],
            parent_table: [
                {"id": owned_id, "user_id": USER_ID},
                {"id": foreign_id, "user_id": FOREIGN_USER_ID},
            ],
        }
    )
    deleted_paths = []
    deleted_vector_ids = []

    async def fake_delete_multiple_images(*, db, storage_paths, bucket=None):
        deleted_paths.extend(storage_paths)
        return len(storage_paths)

    monkeypatch.setattr(
        route_module.StorageService,
        "delete_multiple_images",
        staticmethod(fake_delete_multiple_images),
    )
    if route_module is items_module:
        vector_service = Mock()

        async def fake_batch_delete(_item_ids):
            deleted_vector_ids.extend(_item_ids)
            return 0

        vector_service.batch_delete = fake_batch_delete
        monkeypatch.setattr(items_module, "get_vector_service", lambda: vector_service)

    request = request_type(item_ids=[owned_id, foreign_id]) if route_module is items_module else request_type(
        outfit_ids=[owned_id, foreign_id]
    )

    if route_module is items_module:
        await route_module.batch_delete_items(request=request, user_id=USER_ID, db=db)
        assert deleted_vector_ids == [owned_id]
    else:
        await route_module.batch_delete_outfits(request=request, user_id=USER_ID, db=db)

    assert deleted_paths == [owned_path]


class _Admin:
    def __init__(self, error=None):
        self.error = error
        self.deleted = []

    def delete_user(self, user_id):
        if self.error:
            raise self.error
        self.deleted.append(user_id)


class _DeleteDB:
    def __init__(self, admin, delete_error=None):
        self.auth = SimpleNamespace(admin=admin)
        self.delete_error = delete_error
        self.delete_called = False

    def table(self, _table_name):
        db = self

        class _DeleteQuery:
            def delete(self):
                return self

            def select(self, *_args):
                return self

            def eq(self, *_args):
                return self

            def in_(self, *_args):
                return self

            def maybe_single(self):
                return self

            def execute(self):
                db.delete_called = True
                if db.delete_error:
                    raise db.delete_error
                return SimpleNamespace(data=[{"id": USER_ID}])

        return _DeleteQuery()


@pytest.mark.asyncio
async def test_delete_current_user_reports_auth_failure_without_deleting_profile():
    admin = _Admin(error=RuntimeError("auth unavailable"))
    db = _DeleteDB(admin)

    with pytest.raises(DatabaseError):
        await users_module.delete_current_user(user_id=USER_ID, db=db)

    # Public data is removed first so an Auth outage cannot leave a live
    # wardrobe/profile behind. The client receives an error and may retry Auth
    # deletion with the same session.
    assert db.delete_called is True


@pytest.mark.asyncio
async def test_delete_current_user_reports_public_delete_failure():
    admin = _Admin()
    db = _DeleteDB(admin, delete_error=RuntimeError("database unavailable"))

    with pytest.raises(DatabaseError):
        await users_module.delete_current_user(user_id=USER_ID, db=db)

    # Auth is intentionally not touched when the public deletion boundary
    # fails; retrying the same request remains safe.
    assert admin.deleted == []


@pytest.mark.asyncio
async def test_profile_lookup_failure_does_not_trigger_auto_provisioning():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.side_effect = RuntimeError(
        "temporary database timeout"
    )

    from app.api.v1.deps import get_current_user
    from app.core.security import TokenData

    with pytest.raises(AuthenticationError) as exc_info:
        await get_current_user(db=db, token_data=TokenData(sub=USER_ID))

    assert getattr(exc_info.value, "error_code", None) == "AUTH_PROFILE_LOOKUP_ERROR"
    assert db.auth.admin.get_user_by_id.called is False


def test_validate_image_rejects_non_image_bytes_with_allowed_extension():
    with pytest.raises(UnsupportedMediaTypeError):
        StorageService._validate_image(b"not an image", "photo.png")
