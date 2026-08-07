"""
Route-level behaviour tests for app/api/v1/users.py.

Written as the safety net for the event-loop-blocking pass that wraps every
synchronous supabase-py `.execute()` in `asyncio.to_thread`. Every assertion
here is about *behaviour* (returned payload, raised exception, queries issued),
never about threading, so the suite is green both before and after that change
and therefore actually catches a botched conversion.

Follows the house convention of calling route functions directly with a fake
Supabase client rather than going through a TestClient. Auth is asserted at the
dependency level (the direct-call convention bypasses it entirely).

Deliberately does NOT re-cover what tests/test_phase2e_hardening.py already
owns: the capped avatar upload / oversized-file rejection.
"""
import inspect
import json
from types import SimpleNamespace
from typing import Any, Dict, List, Optional
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import users as users_module
from app.api.v1.deps import get_active_user_id
from app.core.exceptions import (
    BodyProfileNotFoundError,
    UnsupportedMediaTypeError,
    UserNotFoundError,
)
from app.models.user import (
    BodyProfileCreate,
    BodyProfileUpdate,
    UserPreferencesUpdate,
    UserSettingsUpdate,
    UserUpdate,
)
from app.services.storage_service import StorageService

USER_ID = "11111111-1111-1111-1111-111111111111"
PROFILE_ID = "22222222-2222-2222-2222-222222222222"
NOW = "2026-01-01T00:00:00"

# Columns a real Postgres table fills in for you. The fake echoes the insert
# payload back the way postgrest does, so without these the NOT NULL timestamp
# defaults (user_preferences.last_updated, body_profiles.id) come back null and
# model validation fails for reasons that have nothing to do with the handler.
_DB_DEFAULTS = {"id": PROFILE_ID, "created_at": NOW, "updated_at": NOW, "last_updated": NOW}


class _FakeQuery:
    """Chainable postgrest stub.

    Filters (`eq`/`gte`/`order`/`limit`) are accepted and ignored: the fidelity
    level here is "which table, which operation, what payload", which is what
    the handlers' logic actually branches on.
    """

    def __init__(self, db: "_FakeDB", table: str):
        self._db = db
        self._table = table
        self._op = "select"
        self._payload: Any = None
        self._single = False

    def select(self, _columns: str = "*", count: Optional[str] = None):
        self._op = "select"
        return self

    def insert(self, payload):
        self._op = "insert"
        self._payload = payload
        return self

    def update(self, payload):
        self._op = "update"
        self._payload = payload
        return self

    def upsert(self, payload, **_kwargs):
        self._op = "insert"
        self._payload = payload
        return self

    def delete(self):
        self._op = "delete"
        return self

    def _noop(self, *_a, **_k):
        return self

    eq = neq = gte = lte = in_ = order = limit = range = _noop

    def single(self, *_a, **_k):
        self._single = True
        return self

    maybe_single = single

    def execute(self):
        self._db.calls.append((self._op, self._table, self._payload))
        rows = self._db.tables.setdefault(self._table, [])

        if self._op == "insert":
            payloads = self._payload if isinstance(self._payload, list) else [self._payload]
            written = []
            for p in payloads:
                row = dict(p)
                for column, default in _DB_DEFAULTS.items():
                    if row.get(column) is None:
                        row[column] = default
                written.append(row)
            rows.extend(written)
            return SimpleNamespace(data=written, count=len(written))

        if self._op == "update":
            merged = [{**r, **(self._payload or {})} for r in rows]
            self._db.tables[self._table] = merged
            return SimpleNamespace(data=merged, count=len(merged))

        if self._op == "delete":
            self._db.tables[self._table] = []
            return SimpleNamespace(data=list(rows), count=len(rows))

        data = list(rows)
        if self._single:
            # Matches tests/test_phase2e_hardening.py's stub. NOTE: real
            # postgrest .single() raises PGRST116 on zero rows instead of
            # returning None - see the module docstring of the conversion pass.
            return SimpleNamespace(data=data[0] if data else None, count=len(data))
        return SimpleNamespace(data=data, count=len(data))


class _FakeDB:
    def __init__(self, tables: Optional[Dict[str, List[Dict[str, Any]]]] = None):
        self.tables: Dict[str, List[Dict[str, Any]]] = {k: [dict(r) for r in v] for k, v in (tables or {}).items()}
        self.calls: List[Any] = []
        # _get_auth_user_metadata / _update_auth_user_metadata probe for an
        # admin API and no-op when it is absent.
        self.auth = SimpleNamespace(admin=None)

    def table(self, name: str) -> _FakeQuery:
        return _FakeQuery(self, name)

    def ops(self, table: str) -> List[str]:
        return [op for op, tbl, _ in self.calls if tbl == table]


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


def _user_row(**overrides) -> Dict[str, Any]:
    row = {
        "id": USER_ID,
        "email": "wardrobe@example.com",
        "full_name": "Ada Lovelace",
        "avatar_url": None,
        "gender": None,
        "birth_date": None,
        "birth_time": None,
        "birth_place": None,
        "is_active": True,
        "email_verified": True,
        "created_at": NOW,
        "updated_at": NOW,
        "last_login_at": None,
        "body_profile_id": None,
    }
    row.update(overrides)
    return row


def _body_profile_row(**overrides) -> Dict[str, Any]:
    row = {
        "id": PROFILE_ID,
        "user_id": USER_ID,
        "name": "Everyday",
        "height_cm": 170.0,
        "weight_kg": 65.0,
        "body_shape": "hourglass",
        "skin_tone": "medium",
        "is_default": True,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


# ---------------------------------------------------------------------------
# Auth: every route is gated on the shared token dependency
# ---------------------------------------------------------------------------

_HANDLERS = [
    "get_current_user",
    "update_current_user",
    "delete_current_user",
    "export_user_data",
    "upload_avatar",
    "get_user_preferences",
    "update_user_preferences",
    "get_user_settings",
    "update_user_settings",
    "list_body_profiles",
    "create_body_profile",
    "update_body_profile",
    "delete_body_profile",
    "get_body_profile",
    "upsert_body_profile",
    "get_dashboard",
]


@pytest.mark.parametrize("handler_name", _HANDLERS)
def test_every_user_route_requires_authentication(handler_name):
    """Direct-call tests bypass auth, so assert the gate at the dependency.

    An unauthenticated request never reaches these bodies: verify_token raises
    before the handler runs, so a route that lost this Depends would silently
    become public. Every user route depends on get_active_user_id (the token
    gate + suspension check), never the bare token dependency.
    """
    param = inspect.signature(getattr(users_module, handler_name)).parameters["user_id"]
    assert param.default.dependency is get_active_user_id


# ---------------------------------------------------------------------------
# GET/PUT /me
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_current_user_returns_the_profile():
    db = _FakeDB({"users": [_user_row()]})

    result = await users_module.get_current_user(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["id"] == USER_ID
    assert result["data"]["email"] == "wardrobe@example.com"
    assert result["data"]["full_name"] == "Ada Lovelace"


@pytest.mark.asyncio
async def test_get_current_user_materializes_an_owned_avatar_key():
    """An avatar stored as an owned bucket key must come back as a fresh
    served URL (presigned or worker-mode), never as the raw key."""
    row = _user_row()
    row["avatar_url"] = f"{USER_ID}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"
    db = _FakeDB({"users": [row]})

    async def _fake_materialize(avatar_url, *, presigned=False):
        return f"https://served.example/{avatar_url}"

    monkeypatch = pytest.MonkeyPatch()
    monkeypatch.setattr(users_module, "materialize_avatar_url", _fake_materialize)
    try:
        result = await users_module.get_current_user(user_id=USER_ID, db=db)
    finally:
        monkeypatch.undo()
    assert result["data"]["avatar_url"] == (
        f"https://served.example/{USER_ID}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"
    )


@pytest.mark.asyncio
async def test_get_current_user_passes_external_oauth_avatar_through():
    """An external https avatar (OAuth provider picture) must pass through
    untouched — key_from_path would otherwise mangle it into a bogus bucket
    key and the read path would serve a 404 for it."""
    external = "https://lh3.googleusercontent.com/a/ACw8oPics97qXtDAbcD=w96-h96"
    row = _user_row()
    row["avatar_url"] = external
    db = _FakeDB({"users": [row]})
    result = await users_module.get_current_user(user_id=USER_ID, db=db)
    assert result["data"]["avatar_url"] == external


@pytest.mark.asyncio
async def test_get_current_user_raises_when_the_row_is_missing():
    db = _FakeDB({"users": []})

    with pytest.raises(UserNotFoundError):
        await users_module.get_current_user(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_update_current_user_persists_and_returns_the_patch():
    db = _FakeDB({"users": [_user_row()]})

    result = await users_module.update_current_user(
        UserUpdate(full_name="Grace Hopper"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["full_name"] == "Grace Hopper"
    assert "updated_at" in db.calls[0][2]
    assert db.ops("users") == ["update"]


@pytest.mark.asyncio
async def test_update_current_user_with_an_empty_patch_reads_instead_of_writing():
    db = _FakeDB({"users": [_user_row()]})

    result = await users_module.update_current_user(UserUpdate(), user_id=USER_ID, db=db)

    assert result["data"]["full_name"] == "Ada Lovelace"
    assert db.ops("users") == ["select"], "an empty patch must not issue an UPDATE"


@pytest.mark.asyncio
async def test_update_current_user_cannot_set_admin_only_fields():
    """PUT /users/me must never write is_active/role/is_admin/custom_daily_quota.

    Those are admin-panel fields: writing is_active would let a user
    (un)suspend themselves, and the others would let them escalate. is_active
    is accepted by the schema but stripped before the write — the profile
    stays active and only the editable fields change.
    """
    db = _FakeDB({"users": [_user_row()]})

    result = await users_module.update_current_user(
        UserUpdate(is_active=False, full_name="Ada"), user_id=USER_ID, db=db
    )

    update_payload = db.calls[0][2]
    for admin_only in ("is_active", "role", "is_admin", "custom_daily_quota"):
        assert admin_only not in update_payload, (
            f"PUT /users/me must not write {admin_only}"
        )
    assert result["data"]["is_active"] is True, "suspension flag must be untouched"
    assert result["data"]["full_name"] == "Ada"


# ---------------------------------------------------------------------------
# Avatar upload (oversized-file handling is covered by test_phase2e_hardening)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_upload_avatar_stores_the_file_and_writes_the_url(monkeypatch):
    seen = {}

    async def fake_upload_avatar(*, db, user_id, filename, file_data):
        seen.update(user_id=user_id, filename=filename, size=len(file_data))
        return "https://cdn.example.com/avatars/a.png"

    monkeypatch.setattr(
        "app.services.storage_service.StorageService.upload_avatar",
        staticmethod(fake_upload_avatar),
    )
    db = _FakeDB({"users": [_user_row()]})

    result = await users_module.upload_avatar(file=_FakeUpload(), user_id=USER_ID, db=db)

    assert result["data"]["avatar_url"] == "https://cdn.example.com/avatars/a.png"
    assert seen == {"user_id": USER_ID, "filename": "a.png", "size": len(b"png-bytes")}
    assert db.tables["users"][0]["avatar_url"] == "https://cdn.example.com/avatars/a.png"


@pytest.mark.asyncio
async def test_upload_avatar_rejects_a_non_image_content_type():
    upload = _FakeUpload(data=b"not-an-image", filename="notes.txt", content_type="text/plain")

    with pytest.raises(UnsupportedMediaTypeError):
        await users_module.upload_avatar(file=upload, user_id=USER_ID, db=_FakeDB())


# ---------------------------------------------------------------------------
# Preferences
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_user_preferences_returns_the_existing_row():
    db = _FakeDB(
        {
            "user_preferences": [
                {
                    "user_id": USER_ID,
                    "favorite_colors": ["olive"],
                    "preferred_styles": ["minimal"],
                    "liked_brands": [],
                    "disliked_patterns": [],
                    "preferred_occasions": [],
                    "color_temperature": "cool",
                    "style_personality": None,
                    "data_points_collected": 7,
                    "last_updated": NOW,
                }
            ]
        }
    )

    result = await users_module.get_user_preferences(user_id=USER_ID, db=db)

    assert result["data"]["favorite_colors"] == ["olive"]
    assert result["data"]["data_points_collected"] == 7
    assert db.ops("user_preferences") == ["select"], "an existing row must not be re-inserted"


@pytest.mark.asyncio
async def test_get_user_preferences_creates_defaults_on_first_read():
    db = _FakeDB({"user_preferences": []})

    result = await users_module.get_user_preferences(user_id=USER_ID, db=db)

    assert db.ops("user_preferences") == ["select", "insert", "select"]
    assert result["data"]["favorite_colors"] == []
    assert result["data"]["data_points_collected"] == 0
    assert db.tables["user_preferences"][0]["user_id"] == USER_ID


@pytest.mark.asyncio
async def test_update_user_preferences_updates_an_existing_row():
    db = _FakeDB(
        {
            "user_preferences": [
                {
                    "user_id": USER_ID,
                    "favorite_colors": [],
                    "preferred_styles": [],
                    "liked_brands": [],
                    "disliked_patterns": [],
                    "preferred_occasions": [],
                    "data_points_collected": 0,
                    "last_updated": NOW,
                }
            ]
        }
    )

    result = await users_module.update_user_preferences(
        UserPreferencesUpdate(favorite_colors=["rust"], data_points_collected=3),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["favorite_colors"] == ["rust"]
    assert result["data"]["data_points_collected"] == 3
    assert db.ops("user_preferences") == ["select", "update"]


@pytest.mark.asyncio
async def test_update_user_preferences_inserts_when_no_row_exists():
    db = _FakeDB({"user_preferences": []})

    result = await users_module.update_user_preferences(
        UserPreferencesUpdate(preferred_styles=["workwear"]), user_id=USER_ID, db=db
    )

    assert db.ops("user_preferences") == ["select", "insert"]
    assert result["data"]["preferred_styles"] == ["workwear"]


# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------


def _settings_row(**overrides) -> Dict[str, Any]:
    row = {
        "user_id": USER_ID,
        "default_location": None,
        "timezone": None,
        "language": "en",
        "measurement_units": "imperial",
        "notifications_enabled": True,
        "email_marketing": False,
        "dark_mode": False,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


@pytest.mark.asyncio
async def test_get_user_settings_returns_the_existing_row():
    db = _FakeDB({"user_settings": [_settings_row(dark_mode=True, timezone="Asia/Kolkata")]})

    result = await users_module.get_user_settings(user_id=USER_ID, db=db)

    assert result["data"]["dark_mode"] is True
    assert result["data"]["timezone"] == "Asia/Kolkata"
    assert db.ops("user_settings") == ["select"]


@pytest.mark.asyncio
async def test_get_user_settings_creates_defaults_on_first_read():
    db = _FakeDB({"user_settings": []})

    result = await users_module.get_user_settings(user_id=USER_ID, db=db)

    assert db.ops("user_settings") == ["select", "insert", "select"]
    assert result["data"]["language"] == "en"
    assert result["data"]["measurement_units"] == "imperial"


@pytest.mark.asyncio
async def test_update_user_settings_updates_an_existing_row():
    db = _FakeDB({"user_settings": [_settings_row()]})

    result = await users_module.update_user_settings(
        UserSettingsUpdate(measurement_units="metric", dark_mode=True), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["measurement_units"] == "metric"
    assert result["data"]["dark_mode"] is True
    assert db.ops("user_settings") == ["select", "update"]


@pytest.mark.asyncio
async def test_update_user_settings_inserts_when_no_row_exists():
    db = _FakeDB({"user_settings": []})

    result = await users_module.update_user_settings(
        UserSettingsUpdate(language="hi"), user_id=USER_ID, db=db
    )

    assert db.ops("user_settings") == ["select", "insert"]
    assert result["data"]["language"] == "hi"


# ---------------------------------------------------------------------------
# Body profiles (collection CRUD)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_list_body_profiles_returns_every_profile():
    db = _FakeDB({"body_profiles": [_body_profile_row(), _body_profile_row(id=PROFILE_ID, name="Gym", is_default=False)]})

    result = await users_module.list_body_profiles(user_id=USER_ID, db=db)

    names = [p["name"] for p in result["data"]["body_profiles"]]
    assert names == ["Everyday", "Gym"]


@pytest.mark.asyncio
async def test_list_body_profiles_returns_an_empty_list_not_an_error():
    db = _FakeDB({"body_profiles": []})

    result = await users_module.list_body_profiles(user_id=USER_ID, db=db)

    assert result["data"]["body_profiles"] == []


@pytest.mark.asyncio
async def test_create_body_profile_forces_the_first_profile_to_be_default():
    db = _FakeDB({"body_profiles": [], "users": [_user_row()]})

    result = await users_module.create_body_profile(
        BodyProfileCreate(
            name="Everyday",
            height_cm=170,
            weight_kg=65,
            body_shape="hourglass",
            skin_tone="medium",
            is_default=False,
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["is_default"] is True, "the only profile has to be the default one"
    assert result["data"]["name"] == "Everyday"
    # The new default is linked back onto the user row.
    assert db.tables["users"][0]["body_profile_id"] == result["data"]["id"]


@pytest.mark.asyncio
async def test_update_body_profile_applies_the_patch():
    db = _FakeDB({"body_profiles": [_body_profile_row()], "users": [_user_row()]})

    result = await users_module.update_body_profile(
        PROFILE_ID, BodyProfileUpdate(weight_kg=70), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["weight_kg"] == 70.0
    assert db.ops("body_profiles") == ["select", "update"]


@pytest.mark.asyncio
async def test_update_body_profile_raises_for_an_unknown_profile():
    db = _FakeDB({"body_profiles": []})

    with pytest.raises(BodyProfileNotFoundError):
        await users_module.update_body_profile(
            PROFILE_ID, BodyProfileUpdate(weight_kg=70), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_body_profile_clears_the_user_link_when_none_remain():
    db = _FakeDB({"body_profiles": [_body_profile_row()], "users": [_user_row(body_profile_id=PROFILE_ID)]})

    assert await users_module.delete_body_profile(PROFILE_ID, user_id=USER_ID, db=db) is None

    assert "delete" in db.ops("body_profiles")
    assert db.tables["users"][0]["body_profile_id"] is None


@pytest.mark.asyncio
async def test_delete_body_profile_raises_for_an_unknown_profile():
    db = _FakeDB({"body_profiles": []})

    with pytest.raises(BodyProfileNotFoundError):
        await users_module.delete_body_profile(PROFILE_ID, user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Body profile (singular, default-profile shortcut)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_body_profile_returns_the_default_profile():
    db = _FakeDB({"body_profiles": [_body_profile_row()]})

    result = await users_module.get_body_profile(user_id=USER_ID, db=db)

    assert result["data"]["name"] == "Everyday"
    assert result["data"]["is_default"] is True


@pytest.mark.asyncio
async def test_get_body_profile_raises_when_the_user_has_none():
    db = _FakeDB({"body_profiles": []})

    with pytest.raises(BodyProfileNotFoundError):
        await users_module.get_body_profile(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_upsert_body_profile_creates_the_first_profile():
    db = _FakeDB({"body_profiles": [], "users": [_user_row()]})

    result = await users_module.upsert_body_profile(
        BodyProfileUpdate(
            name="Everyday", height_cm=170, weight_kg=65, body_shape="hourglass", skin_tone="medium"
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["is_default"] is True
    assert db.tables["users"][0]["body_profile_id"] == result["data"]["id"]


@pytest.mark.asyncio
async def test_upsert_body_profile_updates_an_existing_profile():
    db = _FakeDB({"body_profiles": [_body_profile_row()], "users": [_user_row()]})

    result = await users_module.upsert_body_profile(
        BodyProfileUpdate(skin_tone="deep"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    assert result["data"]["skin_tone"] == "deep"


# ---------------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_dashboard_aggregates_counts_and_recent_activity():
    db = _FakeDB(
        {
            "users": [_user_row()],
            "items": [
                {"id": "i1", "name": "Linen shirt", "created_at": "2026-01-02T00:00:00", "usage_times_worn": 9},
                {"id": "i2", "name": "Denim jacket", "created_at": "2026-01-01T00:00:00", "usage_times_worn": 2},
            ],
            "outfits": [
                {
                    "id": "o1",
                    "name": "Weekend",
                    "created_at": "2026-01-03T00:00:00",
                    "outfit_images": [
                        {"image_url": "https://cdn/x.jpg", "thumbnail_url": "https://cdn/x-t.jpg", "is_primary": True}
                    ],
                }
            ],
            # No default_location -> the weather suggestion opts out.
            "user_settings": [_settings_row()],
        }
    )

    result = await users_module.get_dashboard(user_id=USER_ID, db=db)

    stats = result["data"]["statistics"]
    assert stats["total_items"] == 2
    assert stats["total_outfits"] == 1
    assert stats["most_worn_item"] == {"name": "Linen shirt", "times_worn": 9}

    activity = result["data"]["recent_activity"]
    assert activity[0] == {
        "type": "outfit_created",
        "description": "Created Weekend",
        "timestamp": "2026-01-03T00:00:00",
        # No storage_path on the legacy row -> the stored thumbnail is kept.
        "image_url": "https://cdn/x-t.jpg",
    }
    assert len(activity) == 3
    # Items without any images degrade to a null image_url, never an error.
    assert activity[1]["type"] == "item_created"
    assert activity[1]["image_url"] is None

    assert result["data"]["suggestions"]["weather_based"] is None
    assert result["data"]["suggestions"]["outfit_of_the_day"] == {
        "id": "o1",
        "name": "Weekend",
        "image_url": "https://cdn/x-t.jpg",
    }


@pytest.mark.asyncio
async def test_get_dashboard_materializes_presigned_image_urls(monkeypatch):
    """storage_path rows must come back as fresh presigned URLs, not the stale
    stored values, for both the activity feed and the outfit of the day."""
    db = _FakeDB(
        {
            "users": [_user_row()],
            "items": [
                {
                    "id": "i1",
                    "name": "Linen shirt",
                    "created_at": "2026-01-02T00:00:00",
                    "usage_times_worn": 9,
                    "item_images": [
                        {
                            "storage_path": "u1/items/i1.jpg",
                            "image_url": "https://stale/1.jpg",
                            "thumbnail_url": "https://stale/1-t.jpg",
                            "is_primary": True,
                        }
                    ],
                }
            ],
            "outfits": [
                {
                    "id": "o1",
                    "name": "Weekend",
                    "created_at": "2026-01-03T00:00:00",
                    "outfit_images": [
                        {
                            "storage_path": "u1/outfits/o1.jpg",
                            "image_url": "https://stale/o.jpg",
                            "thumbnail_url": "https://stale/o-t.jpg",
                            "is_primary": True,
                        }
                    ],
                }
            ],
            # No default_location -> the weather suggestion opts out.
            "user_settings": [_settings_row()],
        }
    )

    async def _fake_presign(key):
        return f"https://presigned.example/{key}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fake_presign))

    result = await users_module.get_dashboard(user_id=USER_ID, db=db)

    activity = result["data"]["recent_activity"]
    by_type = {a["type"]: a for a in activity}
    assert by_type["item_created"]["image_url"] == "https://presigned.example/u1/items/i1.jpg"
    assert by_type["outfit_created"]["image_url"] == "https://presigned.example/u1/outfits/o1.jpg"

    assert result["data"]["suggestions"]["outfit_of_the_day"]["image_url"] == (
        "https://presigned.example/u1/outfits/o1.jpg"
    )


@pytest.mark.asyncio
async def test_get_dashboard_raises_when_the_user_row_is_missing():
    db = _FakeDB({"users": []})

    with pytest.raises(UserNotFoundError):
        await users_module.get_dashboard(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_dashboard_includes_a_weather_suggestion_when_a_location_is_set(monkeypatch):
    class _FakeWeather:
        async def get_weather(self, location, units):
            assert (location, units) == ("Pune", "imperial")
            return {"temperature": 95.0}

    monkeypatch.setattr(users_module, "get_weather_service", lambda: _FakeWeather())
    db = _FakeDB(
        {
            "users": [_user_row()],
            "items": [],
            "outfits": [],
            "user_settings": [_settings_row(default_location="Pune")],
        }
    )

    result = await users_module.get_dashboard(user_id=USER_ID, db=db)

    weather = result["data"]["suggestions"]["weather_based"]
    assert weather["temperature"] == 35.0
    assert "breathable" in weather["recommendation"]


@pytest.mark.asyncio
async def test_available_items_materializes_presigned_image_urls(monkeypatch):
    """GET /outfits/available-items must return fresh presigned URLs from
    storage_path (same contract as the list endpoints), never stale stored
    values, so outfit-builder picker grids render on mobile."""
    from app.api.v1 import outfits as outfits_module

    db = _FakeDB(
        {
            "items": [
                {
                    "id": "i1",
                    "name": "Linen shirt",
                    "category": "tops",
                    "colors": ["white"],
                    "is_deleted": False,
                    "item_images": [
                        {
                            "storage_path": "u1/items/i1.jpg",
                            "image_url": "https://stale/1.jpg",
                            "thumbnail_url": "https://stale/1-t.jpg",
                            "is_primary": True,
                        }
                    ],
                },
                {
                    "id": "i2",
                    "name": "Denim jacket",
                    "category": "outerwear",
                    "colors": ["blue"],
                    "is_deleted": False,
                    "item_images": [
                        {
                            "image_url": "https://cdn/2.jpg",
                            "thumbnail_url": "https://cdn/2-t.jpg",
                            "is_primary": True,
                        }
                    ],
                },
            ]
        }
    )

    async def _fake_presign(key):
        return f"https://presigned.example/{key}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fake_presign))

    result = await outfits_module.available_items(user_id=USER_ID, db=db)
    items = {item["id"]: item for item in result["data"]}
    # storage_path row -> fresh presigned URL (thumbnail slot).
    assert items["i1"]["image_url"] == "https://presigned.example/u1/items/i1.jpg"
    # Legacy row without storage_path keeps its stored thumbnail.
    assert items["i2"]["image_url"] == "https://cdn/2-t.jpg"


# ---------------------------------------------------------------------------
# Data export
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_export_user_data_returns_a_presigned_url_with_data_sections(monkeypatch):
    """POST /users/export must return the standard envelope with a fresh
    presigned URL and an archive that contains every data section."""
    db = _FakeDB(
        {
            "users": [_user_row()],
            "user_preferences": [
                {
                    "user_id": USER_ID,
                    "favorite_colors": ["olive"],
                    "preferred_styles": ["minimal"],
                    "liked_brands": [],
                    "disliked_patterns": [],
                    "preferred_occasions": [],
                    "color_temperature": "cool",
                    "style_personality": None,
                    "data_points_collected": 3,
                    "last_updated": NOW,
                }
            ],
            "user_settings": [_settings_row()],
            "body_profiles": [_body_profile_row()],
            "items": [
                {"id": "i1", "name": "Linen shirt", "category": "tops", "colors": ["white"], "is_deleted": False, "created_at": NOW}
            ],
            "outfits": [{"id": "o1", "name": "Weekend", "created_at": NOW}],
            "calendar_events": [
                {"id": "c1", "user_id": USER_ID, "title": "Date night", "event_date": "2026-02-14", "created_at": NOW}
            ],
            "subscriptions": [
                {
                    "id": "s1",
                    "user_id": USER_ID,
                    "plan_type": "free",
                    "status": "active",
                    "current_period_start": NOW,
                    "current_period_end": None,
                    "cancel_at_period_end": False,
                    "stripe_customer_id": "cus_123",
                }
            ],
        }
    )
    seen = {}

    async def fake_upload_file(*, db, file_data, file_path, content_type="application/octet-stream", bucket=None, upsert=True, cache_control=None):
        seen.update(
            file_path=file_path,
            content_type=content_type,
            cache_control=cache_control,
            file_data=file_data,
        )
        return {
            "public_url": f"https://presigned.example/{file_path}",
            "storage_path": file_path,
            "bucket": "b",
        }

    monkeypatch.setattr(StorageService, "upload_file", staticmethod(fake_upload_file))

    result = await users_module.export_user_data(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["export_url"] == f"https://presigned.example/{USER_ID}/export/data.json"
    assert seen["content_type"] == "application/json"
    assert seen["cache_control"] == "60"

    payload = json.loads(seen["file_data"])
    assert payload["generated_at"]
    assert payload["user"]["id"] == USER_ID
    assert payload["preferences"]["favorite_colors"] == ["olive"]
    assert payload["settings"]["language"] == "en"
    assert payload["body_profiles"][0]["id"] == PROFILE_ID
    assert payload["items"][0]["name"] == "Linen shirt"
    assert payload["outfits"][0]["name"] == "Weekend"
    assert payload["calendar_events"][0]["title"] == "Date night"
    # Billing summary carries the billing columns, not provider identifiers.
    assert payload["subscriptions"][0]["plan_type"] == "free"
    assert "stripe_customer_id" not in payload["subscriptions"][0]
    assert "image files are not included" in payload["note"]


@pytest.mark.asyncio
async def test_export_user_data_overwrites_the_same_key_and_returns_a_fresh_url_per_call(monkeypatch):
    """A second call must succeed and write the same deterministic key (so
    account deletion knows exactly one export object per user), while the
    presigned URL is regenerated per call."""
    seen = {"paths": [], "urls": []}

    async def fake_upload_file(*, db, file_data, file_path, content_type="application/octet-stream", bucket=None, upsert=True, cache_control=None):
        seen["paths"].append(file_path)
        url = f"https://presigned.example/{file_path}?fresh={len(seen['paths'])}"
        seen["urls"].append(url)
        return {"public_url": url, "storage_path": file_path, "bucket": "b"}

    monkeypatch.setattr(StorageService, "upload_file", staticmethod(fake_upload_file))
    db = _FakeDB({"users": [_user_row()]})

    first = await users_module.export_user_data(user_id=USER_ID, db=db)
    second = await users_module.export_user_data(user_id=USER_ID, db=db)

    assert seen["paths"] == [
        f"{USER_ID}/export/data.json",
        f"{USER_ID}/export/data.json",
    ]
    assert first["data"]["export_url"] != second["data"]["export_url"]


@pytest.mark.asyncio
async def test_export_user_data_raises_when_the_user_row_is_missing():
    db = _FakeDB({"users": []})

    with pytest.raises(UserNotFoundError):
        await users_module.export_user_data(user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Account deletion: support tickets + export archive cleanup
# ---------------------------------------------------------------------------


class _FakeAdmin:
    def __init__(self):
        self.deleted = []

    def delete_user(self, user_id):
        self.deleted.append(user_id)


@pytest.mark.asyncio
async def test_delete_current_user_anonymizes_tickets_and_purges_export_archive(monkeypatch):
    """The requester's personal data goes; the ticket RECORD stays.

    support_tickets holds in-app content reports about OTHER users and open
    support/billing threads, and its user_id is ON DELETE SET NULL precisely so
    a row can outlive its author. Hard-deleting the requester's rows destroyed
    the only record of a third party's violation (reported user never actioned,
    content stays up). Erasure clears user_id + contact_email instead, so
    nothing links back to the deleted account while moderation keeps the body.
    """
    db = _FakeDB(
        {
            "users": [_user_row()],
            "support_tickets": [
                {
                    "id": "t1",
                    "user_id": USER_ID,
                    "contact_email": "reporter@example.com",
                    "subject": "Content report: shared outfit abc",
                },
            ],
        }
    )
    db.auth = SimpleNamespace(admin=_FakeAdmin())

    fake_vectors = Mock()
    fake_vectors.delete_user_items = AsyncMock(return_value=0)
    monkeypatch.setattr(users_module, "get_vector_service", lambda: fake_vectors)

    deleted_paths = []

    async def fake_delete_multiple_images(*, db, storage_paths, bucket=None):
        deleted_paths.extend(storage_paths)
        return len(storage_paths)

    monkeypatch.setattr(
        StorageService,
        "delete_multiple_images",
        staticmethod(fake_delete_multiple_images),
    )

    await users_module.delete_current_user(user_id=USER_ID, db=db)

    # The report survives, stripped of everything identifying its author.
    ticket = db.tables["support_tickets"][0]
    assert ticket["user_id"] is None
    assert ticket["contact_email"] is None
    assert ticket["subject"] == "Content report: shared outfit abc"

    assert db.tables["users"] == []
    anonymize = ("update", "support_tickets", {"user_id": None, "contact_email": None})
    assert anonymize in db.calls, "tickets must be anonymized, not deleted"
    assert ("delete", "support_tickets", None) not in db.calls
    assert db.calls.index(anonymize) < db.calls.index(
        ("delete", "users", None)
    ), "tickets must be anonymized before the users row"
    assert f"{USER_ID}/export/data.json" in deleted_paths
