"""Route-level coverage for app/api/v1/users.py.

Companion to tests/integration/test_users_routes.py (which owns the happy
paths for /me, preferences, settings, body profiles, dashboard, export and
account deletion). This file targets what that file misses: the missing-column
schema-shim loop in PUT /me, auth-metadata sync helpers, the not-found/DatabaseError
branches of every handler, avatar-replace cleanup, the delete-account
ticket/avatar storage-path assembly, and the dashboard weather/outfit-of-the-day
edge branches.

Follows the house convention: call route functions directly with the shared
FakeDB (tests.utils.fake_db), seed via tests.factories.row_factories, patch
services with monkeypatch, and assert envelopes / raised exceptions.
"""

from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import users as users_module
from app.core.exceptions import (
    BodyProfileNotFoundError,
    DatabaseError,
    UnsupportedMediaTypeError,
)
from app.models.user import (
    BodyProfileCreate,
    BodyProfileUpdate,
    UserPreferences,
    UserPreferencesUpdate,
    UserSettingsUpdate,
    UserUpdate,
)
from app.services.storage_service import StorageService
from tests.factories.row_factories import (
    body_profile_row,
    settings_row,
    user_row,
)

USER_ID = "11111111-1111-1111-1111-111111111111"
PROFILE_ID = "22222222-2222-2222-2222-222222222222"


class _FakeUpload:
    def __init__(self, data: bytes = b"png-bytes", filename: str = "a.png", content_type: str = "image/png"):
        self._data = data
        self.filename = filename
        self.content_type = content_type

    async def read(self, size: int = -1) -> bytes:
        if size is None or size < 0:
            out, self._data = self._data, b""
            return out
        out, self._data = self._data[:size], self._data[size:]
        return out

    async def seek(self, offset: int) -> None:
        assert offset == 0


class _ColumnError(Exception):
    """Postgres undefined-column error shape (code 42703 / PGRST204)."""

    def __init__(self, message: str, code: str = "42703"):
        super().__init__(message)
        self.code = code


class _FlakyBuilder:
    """users-table builder that fails UPDATEs mentioning configured columns.

    Mirrors postgrest behaviour the schema-shim loop branches on: the UPDATE
    raises until the offending column disappears from the payload. SELECTs
    always succeed with the seeded rows so the read fallback of PUT /me works.
    """

    def __init__(self, rows, fail_columns=(), fail_once=True):
        self._rows = rows
        self._fail_columns = set(fail_columns)
        self._fail_once = fail_once
        self._failures = 0
        self._op = "select"
        self._payload = None

    def select(self, *_a, **_k):
        self._op = "select"
        return self

    def update(self, payload):
        self._op = "update"
        self._payload = payload
        return self

    def eq(self, *_a, **_k):
        return self

    def execute(self):
        if self._op == "update" and self._payload:
            offending = [c for c in self._payload if c in self._fail_columns]
            if offending and (not self._fail_once or self._failures == 0):
                self._failures += 1
                raise _ColumnError(f'column users.{offending[0]} does not exist')
        return SimpleNamespace(data=[dict(r) for r in self._rows])


class _FlakyDB:
    def __init__(self, rows, fail_columns=(), fail_once=True):
        self.rows = rows
        self.builder = _FlakyBuilder(rows, fail_columns, fail_once)
        self.auth = SimpleNamespace(admin=None)

    def table(self, name):
        return self.builder


def _run_sync_fake_with(users_module_run_sync, calls_to_empty):
    """Wrap run_sync_with_reconnect so the nth call returns no rows (used to
    force the not-found-after-write DatabaseError branches)."""

    def _fake(fn, db, **kwargs):
        calls_to_empty["n"] += 1
        if calls_to_empty["n"] == calls_to_empty["at"]:
            return SimpleNamespace(data=[])
        return users_module_run_sync(fn, db, **kwargs)

    return _fake


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------


def test_extract_missing_users_column_recognises_postgres_shapes():
    """The schema-shim loop must translate 42703/PGRST204 errors from any
    wording PostgREST actually uses into the missing column name."""
    assert users_module._extract_missing_users_column(
        _ColumnError("column users.birth_date does not exist")
    ) == "birth_date"
    assert users_module._extract_missing_users_column(
        _ColumnError("could not find the 'full_name' column of 'users'")
    ) == "full_name"
    # PGRST204 code with a "column users.X" mention still resolves.
    assert users_module._extract_missing_users_column(
        _ColumnError("column users.suspended_at does not exist", code="PGRST204")
    ) == "suspended_at"
    assert users_module._extract_missing_users_column(ValueError("some other failure")) is None
    assert users_module._extract_missing_users_column(
        _ColumnError("column users is not a column of users")
    ) is None


def test_extract_birth_patch_picks_only_birth_fields():
    assert users_module._extract_birth_patch(
        {"birth_date": "1990-01-01", "birth_place": "Pune", "full_name": "Ada"}
    ) == {"birth_date": "1990-01-01", "birth_place": "Pune"}
    assert users_module._extract_birth_patch({"full_name": "Ada"}) == {}


def test_handle_db_error_adds_extra_context(caplog):
    with pytest.raises(DatabaseError, match="Failed to upload avatar"):
        users_module._handle_db_error(
            "upload avatar", USER_ID, ValueError("boom"), {"file_name": "a.png"}
        )


# ---------------------------------------------------------------------------
# Auth metadata helpers
# ---------------------------------------------------------------------------


class _MetaAdmin:
    def __init__(self, metadata=None):
        self.metadata = metadata or {}
        self.updates = []

    def get_user_by_id(self, user_id):
        return SimpleNamespace(user=SimpleNamespace(user_metadata=self.metadata))

    def update_user_by_id(self, user_id, payload):
        self.updates.append((user_id, payload))


def test_get_auth_user_metadata_reads_admin_api():
    admin = _MetaAdmin({"birth_place": "Pune"})
    db = Mock()
    db.auth = SimpleNamespace(admin=admin)

    assert users_module._get_auth_user_metadata(db, USER_ID) == {"birth_place": "Pune"}


def test_get_auth_user_metadata_handles_missing_admin_or_user():
    db = Mock()
    db.auth = SimpleNamespace(admin=None)
    assert users_module._get_auth_user_metadata(db, USER_ID) == {}

    db.auth = SimpleNamespace(admin=Mock(get_user_by_id=Mock(return_value=None)))
    assert users_module._get_auth_user_metadata(db, USER_ID) == {}

    db.auth = SimpleNamespace(admin=Mock(get_user_by_id=Mock(side_effect=RuntimeError("auth down"))))
    assert users_module._get_auth_user_metadata(db, USER_ID) == {}


def test_update_auth_user_metadata_merges_and_writes():
    admin = _MetaAdmin({"full_name": "Ada"})
    db = Mock()
    db.auth = SimpleNamespace(admin=admin)

    users_module._update_auth_user_metadata(db, USER_ID, {"birth_place": "Pune"})

    assert admin.updates == [(USER_ID, {"user_metadata": {"full_name": "Ada", "birth_place": "Pune"}})]


def test_update_auth_user_metadata_skips_empty_patch_and_missing_admin():
    admin = _MetaAdmin()
    db = Mock()
    db.auth = SimpleNamespace(admin=admin)

    users_module._update_auth_user_metadata(db, USER_ID, {})
    assert admin.updates == []

    db.auth = SimpleNamespace(admin=None)
    users_module._update_auth_user_metadata(db, USER_ID, {"birth_place": "Pune"})
    assert admin.updates == []


# ---------------------------------------------------------------------------
# GET/PUT /me — schema shim + metadata sync
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_current_user_with_all_birth_fields_skips_metadata_fallback():
    row = user_row(
        birth_date="1990-01-01",
        birth_time="14:30:00",
        birth_place="Pune",
    )
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[row]
    )
    db.auth = SimpleNamespace(admin=Mock())  # must NOT be touched

    result = await users_module.get_current_user(user_id=USER_ID, db=db)

    assert result["data"]["birth_place"] == "Pune"
    db.auth.admin.get_user_by_id.assert_not_called()


@pytest.mark.asyncio
async def test_get_current_user_fills_partial_birth_fields_from_metadata():
    """A row carrying some astrology fields still pulls the missing ones from
    auth metadata (pre-migration fallback)."""
    row = user_row(birth_date="1990-01-01", birth_time="14:30:00", birth_place=None)
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[row]
    )
    db.auth = SimpleNamespace(admin=_MetaAdmin({"birth_place": "Mumbai"}))

    result = await users_module.get_current_user(user_id=USER_ID, db=db)

    assert result["data"]["birth_place"] == "Mumbai"
    assert result["data"]["birth_date"] == "1990-01-01"


@pytest.mark.asyncio
async def test_get_current_user_avatar_materialization_failure_is_tolerated(monkeypatch):
    row = user_row(avatar_url="https://cdn.example/avatars/a.png")
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[row]
    )
    monkeypatch.setattr(
        users_module, "materialize_avatar_url", AsyncMock(side_effect=RuntimeError("presign down"))
    )

    result = await users_module.get_current_user(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["avatar_url"] == "https://cdn.example/avatars/a.png"


@pytest.mark.asyncio
async def test_get_current_user_generic_db_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "execute_with_reconnect", AsyncMock(side_effect=ValueError("boom")))

    with pytest.raises(DatabaseError, match="Failed to fetch user"):
        await users_module.get_current_user(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_update_current_user_retries_with_date_of_birth(monkeypatch):
    """Legacy schemas without users.birth_date must fall back to
    users.date_of_birth and retry, never fail."""
    db = _FlakyDB([user_row()], fail_columns={"birth_date"})

    result = await users_module.update_current_user(
        UserUpdate(birth_date="1990-01-01"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert db.builder._failures == 1, "the shim must have retried once"


@pytest.mark.asyncio
async def test_update_current_user_skips_missing_column_and_keeps_going(monkeypatch):
    """A stale client sending a column the schema no longer has must degrade:
    the column is skipped and the rest of the patch is applied."""
    db = _FlakyDB([user_row()], fail_columns={"full_name"})

    result = await users_module.update_current_user(
        UserUpdate(full_name="Grace", gender="female"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["meta"] == {"skipped_fields": ["full_name"]}


@pytest.mark.asyncio
async def test_update_current_user_all_fields_skipped_returns_read_back(monkeypatch):
    """When every schema-compatible field was stripped, PUT /me falls back to a
    read and explains what was skipped."""
    db = _FlakyDB([user_row()], fail_columns={"full_name"})

    result = await users_module.update_current_user(
        UserUpdate(full_name="Grace"), user_id=USER_ID, db=db
    )

    assert result["message"] == "No schema-compatible profile fields to update"
    assert result["meta"] == {"skipped_fields": ["full_name"]}
    assert result["data"]["full_name"] == "Ada Lovelace"


@pytest.mark.asyncio
async def test_update_current_user_raises_when_update_returns_no_row():
    db = _FlakyDB([])

    with pytest.raises(DatabaseError, match="Failed to update user"):
        await users_module.update_current_user(
            UserUpdate(full_name="Grace"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_current_user_generic_error_raises_database_error(monkeypatch):
    class _BoomBuilder:
        def select(self, *_a, **_k):
            return self

        def update(self, _payload):
            return self

        def eq(self, *_a, **_k):
            return self

        def execute(self):
            raise ValueError("boom")

    db = Mock()
    db.table.return_value = _BoomBuilder()

    with pytest.raises(DatabaseError, match="Failed to update user"):
        await users_module.update_current_user(
            UserUpdate(full_name="Grace"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_current_user_syncs_birth_fields_to_auth(monkeypatch):
    """birth fields in the patch must be mirrored to auth metadata after the
    profile row is written."""
    admin = _MetaAdmin({})
    db = Mock()
    db.auth = SimpleNamespace(admin=admin)
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[user_row(birth_date="1990-01-01", birth_time="14:30:00", birth_place="Pune")]
    )

    result = await users_module.update_current_user(
        UserUpdate(birth_place="Pune"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert admin.updates == [(USER_ID, {"user_metadata": {"birth_place": "Pune"}})]


@pytest.mark.asyncio
async def test_update_current_user_metadata_sync_failure_is_non_fatal(monkeypatch):
    """A failing auth-metadata sync must not fail the profile update."""
    db = _FlakyDB([user_row()])
    monkeypatch.setattr(users_module, "_update_auth_user_metadata", Mock(side_effect=RuntimeError("auth down")))

    result = await users_module.update_current_user(
        UserUpdate(birth_place="Pune"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"


# ---------------------------------------------------------------------------
# Avatar upload
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_upload_avatar_tolerates_failed_read_of_previous_avatar():
    """The pre-replace avatar read is best-effort: a dead connection there must
    not block the upload itself."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("read failed")
    )
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = SimpleNamespace(data=[])

    async def fake_upload_avatar(*, db, user_id, filename, file_data):
        return "https://cdn.example/avatars/new.png"

    monkeypatch = pytest.MonkeyPatch()
    monkeypatch.setattr(StorageService, "upload_avatar", staticmethod(fake_upload_avatar))
    try:
        result = await users_module.upload_avatar(file=_FakeUpload(), user_id=USER_ID, db=db)
    finally:
        monkeypatch.undo()

    assert result["data"]["avatar_url"] == "https://cdn.example/avatars/new.png"


@pytest.mark.asyncio
async def test_upload_avatar_deletes_replaced_owned_object(monkeypatch):
    """Replacing an owned avatar must remove the previous bucket object."""
    old_key = f"{USER_ID}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        SimpleNamespace(data={"avatar_url": old_key})
    )
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = SimpleNamespace(data=[])

    async def fake_upload_avatar(*, db, user_id, filename, file_data):
        return f"https://cdn.example/{USER_ID}/avatars/new.png"

    delete_image = AsyncMock()
    monkeypatch.setattr(StorageService, "upload_avatar", staticmethod(fake_upload_avatar))
    monkeypatch.setattr(StorageService, "delete_image", staticmethod(delete_image))

    result = await users_module.upload_avatar(file=_FakeUpload(), user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    delete_image.assert_awaited_once_with(db=db, storage_path=old_key)


@pytest.mark.asyncio
async def test_upload_avatar_delete_failure_is_best_effort(monkeypatch):
    """A failed removal of the replaced avatar must never fail the upload."""
    old_key = f"{USER_ID}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        SimpleNamespace(data={"avatar_url": old_key})
    )
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = SimpleNamespace(data=[])

    async def fake_upload_avatar(*, db, user_id, filename, file_data):
        return f"https://cdn.example/{USER_ID}/avatars/new.png"

    monkeypatch.setattr(StorageService, "upload_avatar", staticmethod(fake_upload_avatar))
    monkeypatch.setattr(
        StorageService, "delete_image", staticmethod(AsyncMock(side_effect=RuntimeError("delete down")))
    )

    result = await users_module.upload_avatar(file=_FakeUpload(), user_id=USER_ID, db=db)

    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_upload_avatar_generic_error_raises_database_error(monkeypatch):
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        SimpleNamespace(data=None)
    )

    async def fake_upload_avatar(*, db, user_id, filename, file_data):
        raise RuntimeError("storage down")

    monkeypatch.setattr(StorageService, "upload_avatar", staticmethod(fake_upload_avatar))

    with pytest.raises(DatabaseError, match="Failed to upload avatar"):
        await users_module.upload_avatar(file=_FakeUpload(), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_upload_avatar_rejects_missing_content_type():
    upload = _FakeUpload(data=b"x", filename="a.png", content_type=None)

    with pytest.raises(UnsupportedMediaTypeError):
        await users_module.upload_avatar(file=upload, user_id=USER_ID, db=Mock())


# ---------------------------------------------------------------------------
# Preferences / settings — failure branches
# ---------------------------------------------------------------------------


def _boom_run_sync(fn, db, **kwargs):
    raise ValueError("boom")


@pytest.mark.asyncio
async def test_get_user_preferences_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _boom_run_sync)

    with pytest.raises(DatabaseError, match="Failed to fetch preferences"):
        await users_module.get_user_preferences(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_get_user_preferences_raises_when_reload_returns_no_row(monkeypatch):
    """The post-insert reload coming back empty must raise, not return a
    half-written record."""
    from tests.utils.fake_db import FakeDB, FakeBuilder

    class _LenientBuilder(FakeBuilder):
        def upsert(self, row, on_conflict=None, **kwargs):
            return super().upsert(row, on_conflict=on_conflict)

    class _LenientDB(FakeDB):
        def table(self, name):
            return _LenientBuilder(self, name)

    state = {"n": 0, "at": 3}  # select, upsert, select-reload

    def _fake(fn, db, **kwargs):
        state["n"] += 1
        if state["n"] == state["at"]:
            return SimpleNamespace(data=[])
        return fn(_LenientDB())

    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _fake)

    with pytest.raises(DatabaseError, match="Failed to create user_preferences"):
        await users_module.get_user_preferences(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_update_user_preferences_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _boom_run_sync)

    with pytest.raises(DatabaseError, match="Failed to update preferences"):
        await users_module.update_user_preferences(
            UserPreferencesUpdate(favorite_colors=["rust"]), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_update_user_preferences_raises_when_write_echoes_no_row(monkeypatch):
    """A write that echoes no row back must raise the typed DatabaseError
    (re-raised unchanged by the handler)."""
    from tests.utils.fake_db import FakeDB
    from tests.factories.row_factories import preferences_row

    db = FakeDB(rows={"user_preferences": [preferences_row(user_id=USER_ID)]})
    real = users_module.run_sync_with_reconnect
    state = {"n": 0, "at": 2}  # select lookup, then the update itself
    monkeypatch.setattr(
        users_module, "run_sync_with_reconnect", _run_sync_fake_with(real, state)
    )

    with pytest.raises(DatabaseError, match="Failed to update user_preferences"):
        await users_module.update_user_preferences(
            UserPreferencesUpdate(favorite_colors=["rust"]), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_get_user_settings_raises_when_reload_returns_no_row(monkeypatch):
    from tests.utils.fake_db import FakeDB, FakeBuilder

    class _LenientBuilder(FakeBuilder):
        def upsert(self, row, on_conflict=None, **kwargs):
            return super().upsert(row, on_conflict=on_conflict)

    class _LenientDB(FakeDB):
        def table(self, name):
            return _LenientBuilder(self, name)

    state = {"n": 0, "at": 3}  # select, upsert, select-reload

    def _fake(fn, db, **kwargs):
        state["n"] += 1
        if state["n"] == state["at"]:
            return SimpleNamespace(data=[])
        return fn(_LenientDB())

    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _fake)

    with pytest.raises(DatabaseError, match="Failed to create user_settings"):
        await users_module.get_user_settings(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_get_user_settings_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _boom_run_sync)

    with pytest.raises(DatabaseError, match="Failed to fetch settings"):
        await users_module.get_user_settings(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_update_user_settings_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "run_sync_with_reconnect", _boom_run_sync)

    with pytest.raises(DatabaseError, match="Failed to update settings"):
        await users_module.update_user_settings(
            UserSettingsUpdate(language="hi"), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_upsert_record_raises_when_write_returns_no_row(monkeypatch):
    """_upsert_record must fail loudly when the write echoes no row back."""
    real = users_module.run_sync_with_reconnect
    state = {"n": 0, "at": 2}  # select lookup, then the write itself
    monkeypatch.setattr(
        users_module, "run_sync_with_reconnect", _run_sync_fake_with(real, state)
    )

    with pytest.raises(DatabaseError, match="Failed to update user_settings"):
        await users_module.update_user_settings(
            UserSettingsUpdate(language="hi"), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_upsert_record_without_updated_field_skips_timestamps():
    """_upsert_record(updated_field=None, created_field=None) must skip both
    timestamp injections (the preferences insert path uses this)."""
    from tests.utils.fake_db import FakeDB

    db = FakeDB(insert_defaults={"last_updated": "2026-01-01T00:00:00+00:00"})
    result = users_module._upsert_record(
        db,
        "user_preferences",
        USER_ID,
        UserPreferencesUpdate(favorite_colors=["olive"]),
        UserPreferences,
        defaults={
            "favorite_colors": [],
            "preferred_styles": [],
            "liked_brands": [],
            "disliked_patterns": [],
            "preferred_occasions": [],
            "color_temperature": None,
            "style_personality": None,
            "data_points_collected": 0,
            "last_updated": None,
        },
        updated_field=None,
        created_field=None,
    )

    assert result["favorite_colors"] == ["olive"]


# ---------------------------------------------------------------------------
# Body profiles — remaining branches
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_body_profile_keeps_non_default_when_profiles_exist():
    """A non-first profile without is_default must stay non-default and must
    not touch the users.body_profile_id link."""
    from tests.utils.fake_db import FakeDB

    db = FakeDB(
        rows={
            "body_profiles": [body_profile_row(user_id=USER_ID)],
            "users": [user_row(id=USER_ID, body_profile_id=PROFILE_ID)],
        }
    )

    result = await users_module.create_body_profile(
        BodyProfileCreate(
            name="Gym", height_cm=175, weight_kg=70, body_shape="rectangle", skin_tone="deep"
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["is_default"] is False
    assert not db.updates, "no is_default unset/link writes for a non-default profile"


@pytest.mark.asyncio
async def test_create_body_profile_raises_when_insert_echoes_no_row():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[], count=1
    )
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(data=[])

    with pytest.raises(DatabaseError, match="Failed to create body profile"):
        await users_module.create_body_profile(
            BodyProfileCreate(
                name="Gym", height_cm=175, weight_kg=70, body_shape="rectangle", skin_tone="deep"
            ),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_create_body_profile_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.side_effect = ValueError("boom")

    with pytest.raises(DatabaseError, match="Failed to create body profile"):
        await users_module.create_body_profile(
            BodyProfileCreate(
                name="Gym", height_cm=175, weight_kg=70, body_shape="rectangle", skin_tone="deep"
            ),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_body_profile_makes_default_and_links_user():
    from tests.utils.fake_db import FakeDB

    db = FakeDB(
        rows={
            "body_profiles": [
                body_profile_row(user_id=USER_ID, id=PROFILE_ID, is_default=False),
                body_profile_row(user_id=USER_ID, id="other", is_default=True),
            ],
            "users": [user_row(id=USER_ID)],
        }
    )

    result = await users_module.update_body_profile(
        PROFILE_ID, BodyProfileUpdate(is_default=True), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["is_default"] is True
    db.assert_update("users", body_profile_id=PROFILE_ID)


@pytest.mark.asyncio
async def test_update_body_profile_raises_when_update_echoes_no_row():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = (
        SimpleNamespace(data=[body_profile_row()])
    )
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.execute.return_value = (
        SimpleNamespace(data=[])
    )

    with pytest.raises(DatabaseError, match="Failed to update body profile"):
        await users_module.update_body_profile(
            PROFILE_ID, BodyProfileUpdate(weight_kg=70), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_body_profile_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.side_effect = (
        ValueError("boom")
    )

    with pytest.raises(DatabaseError, match="Failed to update body profile"):
        await users_module.update_body_profile(
            PROFILE_ID, BodyProfileUpdate(weight_kg=70), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_body_profile_promotes_newest_remaining_profile():
    from tests.utils.fake_db import FakeDB

    other_id = "33333333-3333-3333-3333-333333333333"
    db = FakeDB(
        rows={
            "body_profiles": [
                body_profile_row(user_id=USER_ID, id=PROFILE_ID, is_default=True),
                body_profile_row(user_id=USER_ID, id=other_id, is_default=False),
            ],
            "users": [user_row(id=USER_ID, body_profile_id=PROFILE_ID)],
        }
    )

    assert await users_module.delete_body_profile(PROFILE_ID, user_id=USER_ID, db=db) is None

    db.assert_update("body_profiles", is_default=True)
    db.assert_update("users", body_profile_id=other_id)


@pytest.mark.asyncio
async def test_delete_body_profile_non_default_skips_promotion():
    from tests.utils.fake_db import FakeDB

    other_id = "33333333-3333-3333-3333-333333333333"
    db = FakeDB(
        rows={
            "body_profiles": [
                body_profile_row(user_id=USER_ID, id=PROFILE_ID, is_default=False),
                body_profile_row(user_id=USER_ID, id=other_id, is_default=True),
            ],
            "users": [user_row(id=USER_ID, body_profile_id=other_id)],
        }
    )

    assert await users_module.delete_body_profile(PROFILE_ID, user_id=USER_ID, db=db) is None

    # The default profile is untouched: no promotion writes at all.
    remaining = [r for r in db.rows["body_profiles"] if r["id"] == other_id][0]
    assert remaining["is_default"] is True
    assert not any(u["body_profile_id"] == PROFILE_ID for u in db.rows["users"])
    assert not any(payload.get("is_default") is True for _, payload in db.updates)


@pytest.mark.asyncio
async def test_delete_body_profile_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.side_effect = (
        ValueError("boom")
    )

    with pytest.raises(DatabaseError, match="Failed to delete body profile"):
        await users_module.delete_body_profile(PROFILE_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_body_profile_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.limit.return_value.single.return_value.execute.side_effect = ValueError("boom")

    with pytest.raises(DatabaseError, match="Failed to fetch body profile"):
        await users_module.get_body_profile(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_body_profile_raises_when_missing():
    from tests.utils.fake_db import FakeDB

    db = FakeDB(rows={"body_profiles": []})

    with pytest.raises(BodyProfileNotFoundError):
        await users_module.get_body_profile(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_upsert_body_profile_raises_when_insert_echoes_no_row():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.limit.return_value.single.return_value.execute.return_value = SimpleNamespace(data=None)
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(data=[])

    with pytest.raises(DatabaseError, match="Failed to create body profile"):
        await users_module.upsert_body_profile(
            BodyProfileUpdate(
                name="Everyday", height_cm=170, weight_kg=65, body_shape="hourglass", skin_tone="medium"
            ),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_upsert_body_profile_update_makes_default_and_links_user():
    from tests.utils.fake_db import FakeDB

    db = FakeDB(
        rows={
            "body_profiles": [
                body_profile_row(user_id=USER_ID, id=PROFILE_ID, is_default=False),
                body_profile_row(user_id=USER_ID, id="other", is_default=True),
            ],
            "users": [user_row(id=USER_ID)],
        }
    )

    result = await users_module.upsert_body_profile(
        BodyProfileUpdate(is_default=True), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["is_default"] is True
    db.assert_update("users", body_profile_id=PROFILE_ID)


@pytest.mark.asyncio
async def test_upsert_body_profile_raises_when_update_echoes_no_row():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.limit.return_value.single.return_value.execute.return_value = SimpleNamespace(data=body_profile_row())
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = SimpleNamespace(data=[])

    with pytest.raises(DatabaseError, match="Failed to update body profile"):
        await users_module.upsert_body_profile(
            BodyProfileUpdate(skin_tone="deep"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_upsert_body_profile_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.limit.return_value.single.return_value.execute.side_effect = ValueError("boom")

    with pytest.raises(DatabaseError, match="Failed to save body profile"):
        await users_module.upsert_body_profile(
            BodyProfileUpdate(skin_tone="deep"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_list_body_profiles_raises_body_profile_not_found():
    """A BodyProfileNotFoundError surfaced from the query is re-raised as-is."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.execute.side_effect = (
        BodyProfileNotFoundError(profile_id=PROFILE_ID)
    )

    with pytest.raises(BodyProfileNotFoundError):
        await users_module.list_body_profiles(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_list_body_profiles_generic_error_raises_database_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.order.return_value.execute.side_effect = ValueError("boom")

    with pytest.raises(DatabaseError, match="Failed to fetch body profiles"):
        await users_module.list_body_profiles(user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Account deletion — storage path assembly + failure branches
# ---------------------------------------------------------------------------


class _FakeAdmin:
    def __init__(self):
        self.deleted = []

    def delete_user(self, user_id):
        self.deleted.append(user_id)


@pytest.mark.asyncio
async def test_delete_current_user_collects_ticket_attachments_and_avatar(monkeypatch):
    """Deletion must clean feedback-ticket attachment objects and the avatar
    object (resolved from its stored URL), not just item images."""
    from tests.utils.fake_db import FakeDB

    avatar_key = f"{USER_ID}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"
    db = FakeDB(
        rows={
            "users": [user_row(id=USER_ID, avatar_url=avatar_key)],
            "support_tickets": [
                {
                    "id": "t1",
                    "user_id": USER_ID,
                    "attachment_storage_paths": [f"{USER_ID}/tickets/t1.jpg", None, ""],
                    "contact_email": "a@b.c",
                },
                {"id": "t2", "user_id": USER_ID, "contact_email": None},
            ],
        }
    )
    db.auth = SimpleNamespace(admin=_FakeAdmin())

    deleted = []
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(return_value={"storage_paths": [f"{USER_ID}/items/i1.jpg"]}),
    )

    async def fake_delete_multiple_images(*, db, storage_paths, bucket=None):
        deleted.extend(storage_paths)
        return len(storage_paths)

    monkeypatch.setattr(StorageService, "delete_multiple_images", staticmethod(fake_delete_multiple_images))
    monkeypatch.setattr(users_module, "get_vector_service", lambda: Mock(delete_user_items=AsyncMock()))

    assert await users_module.delete_current_user(user_id=USER_ID, db=db) is None

    assert f"{USER_ID}/tickets/t1.jpg" in deleted
    assert avatar_key in deleted
    assert f"{USER_ID}/export/data.json" in deleted
    assert db.auth.admin.deleted == [USER_ID]


@pytest.mark.asyncio
async def test_delete_current_user_vector_failure_raises_database_error(monkeypatch):
    from tests.utils.fake_db import FakeDB

    db = FakeDB(rows={"users": [user_row(id=USER_ID)], "support_tickets": []})
    db.auth = SimpleNamespace(admin=_FakeAdmin())
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(return_value={"storage_paths": []}),
    )
    monkeypatch.setattr(StorageService, "delete_multiple_images", staticmethod(AsyncMock()))
    monkeypatch.setattr(
        users_module,
        "get_vector_service",
        lambda: Mock(delete_user_items=AsyncMock(side_effect=RuntimeError("vectors down"))),
    )

    with pytest.raises(DatabaseError, match="Failed to delete wardrobe embeddings"):
        await users_module.delete_current_user(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_current_user_raises_when_auth_deletion_unavailable(monkeypatch):
    """Auth account deletion is the last step; its absence must fail loudly."""
    from tests.utils.fake_db import FakeDB

    db = FakeDB(rows={"users": [user_row(id=USER_ID)], "support_tickets": []})
    # FakeDB has no .auth attribute -> getattr(db, "auth", None) is None.
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(return_value={"storage_paths": []}),
    )
    monkeypatch.setattr(StorageService, "delete_multiple_images", staticmethod(AsyncMock()))
    monkeypatch.setattr(users_module, "get_vector_service", lambda: Mock(delete_user_items=AsyncMock()))

    with pytest.raises(DatabaseError, match="Auth account deletion is unavailable"):
        await users_module.delete_current_user(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_current_user_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(
        StorageService, "resolve_owned_storage_paths", AsyncMock(side_effect=ValueError("boom"))
    )

    with pytest.raises(DatabaseError, match="Failed to delete account"):
        await users_module.delete_current_user(user_id=USER_ID, db=Mock())


# ---------------------------------------------------------------------------
# Data export — failure branch
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_export_user_data_generic_error_raises_database_error(monkeypatch):
    from tests.utils.fake_db import FakeDB

    db = FakeDB(rows={"users": [user_row(id=USER_ID)]})

    async def fake_upload_file(*, db, file_data, file_path, content_type="application/octet-stream", bucket=None, upsert=True, cache_control=None):
        raise RuntimeError("storage down")

    monkeypatch.setattr(StorageService, "upload_file", staticmethod(fake_upload_file))

    with pytest.raises(DatabaseError, match="Failed to export user data"):
        await users_module.export_user_data(user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Dashboard — weather / outfit-of-the-day edge branches
# ---------------------------------------------------------------------------


def _dashboard_db(default_location="Pune"):
    from tests.utils.fake_db import FakeDB

    return FakeDB(
        rows={
            "users": [user_row(id=USER_ID)],
            "items": [],
            "outfits": [],
            "user_settings": [settings_row(user_id=USER_ID, default_location=default_location)],
        }
    )


@pytest.mark.asyncio
async def test_dashboard_weather_cold_recommends_warm_coat(monkeypatch):
    class _FakeWeather:
        async def get_weather(self, location, units):
            return {"temperature": 30.0}  # -1.1 C

    monkeypatch.setattr(users_module, "get_weather_service", lambda: _FakeWeather())

    result = await users_module.get_dashboard(user_id=USER_ID, db=_dashboard_db())

    assert result["data"]["suggestions"]["weather_based"]["recommendation"] == (
        "Wear a warm coat and layered outfit."
    )


@pytest.mark.asyncio
async def test_dashboard_weather_mild_recommends_layers(monkeypatch):
    class _FakeWeather:
        async def get_weather(self, location, units):
            return {"temperature": 60.0}  # ~15.6 C

    monkeypatch.setattr(users_module, "get_weather_service", lambda: _FakeWeather())

    result = await users_module.get_dashboard(user_id=USER_ID, db=_dashboard_db())

    assert result["data"]["suggestions"]["weather_based"]["recommendation"] == "Consider light layers."


@pytest.mark.asyncio
async def test_get_weather_suggestion_returns_none_when_weather_is_empty(monkeypatch):
    class _FakeWeather:
        async def get_weather(self, location, units):
            return {}

    monkeypatch.setattr(users_module, "get_weather_service", lambda: _FakeWeather())

    result = await users_module._get_weather_suggestion(USER_ID, _dashboard_db())

    assert result is None


@pytest.mark.asyncio
async def test_get_weather_suggestion_tolerates_weather_service_failure(monkeypatch):
    class _FakeWeather:
        async def get_weather(self, location, units):
            raise RuntimeError("weather down")

    monkeypatch.setattr(users_module, "get_weather_service", lambda: _FakeWeather())

    result = await users_module._get_weather_suggestion(USER_ID, _dashboard_db())

    assert result is None


class _BoomOnOutfitOrder:
    """outfits builder that fails the outfit-of-the-day query (the only outfits
    query ordered by updated_at) while everything else behaves like FakeDB."""

    def __init__(self, inner):
        self._inner = inner

    def __getattr__(self, name):
        attr = getattr(self._inner, name)
        if name == "execute":
            def _boom(*a, **k):
                raise ValueError("boom")
            return _boom
        if callable(attr):
            def _wrap(*a, **k):
                return _BoomOnOutfitOrder(attr(*a, **k))
            return _wrap
        return attr


@pytest.mark.asyncio
async def test_get_outfit_of_the_day_tolerates_query_failure(monkeypatch):
    from tests.utils.fake_db import FakeDB

    class _FlakyOutfitsDB(FakeDB):
        def table(self, name):
            if name == "outfits":
                return _BoomOnOutfitOrder(super().table(name))
            return super().table(name)

    db = _FlakyOutfitsDB(rows={"outfits": [], "users": [user_row()]})

    result = await users_module._get_outfit_of_the_day(USER_ID, db)

    assert result is None


@pytest.mark.asyncio
async def test_get_dashboard_generic_error_raises_database_error(monkeypatch):
    monkeypatch.setattr(users_module, "execute_with_reconnect", AsyncMock(side_effect=ValueError("boom")))

    with pytest.raises(DatabaseError, match="Failed to fetch dashboard"):
        await users_module.get_dashboard(user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_dashboard_most_worn_item_absent_when_no_items():
    # No default_location -> the weather suggestion opts out without a service call.
    result = await users_module.get_dashboard(user_id=USER_ID, db=_dashboard_db(default_location=None))

    assert result["data"]["statistics"]["most_worn_item"] is None
