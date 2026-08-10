"""Pins the storage key grammar (app/core/storage_keys.py).

This is the single owner of key shapes: mint helpers, parse_key, the URL
reducer and the object-URL composer. The existing storage_service tests
already pin the exact formats through the StorageService aliases; this file
pins them at the grammar layer and covers the structural parser.
"""

import re
import uuid

import pytest

from app.core.storage_keys import (
    CANONICAL_CATEGORIES,
    GENERATED_FOLDER,
    PREVIEW_FOLDERS,
    TEMP_FOLDER,
    THUMB_EXTENSION,
    THUMB_SUFFIX,
    USER_ID_SEGMENT_RE,
    build_object_url,
    is_owned_storage_key,
    is_preview_key,
    is_public_key,
    key_from_path,
    migrate_key_to_users_layout,
    mint_export_key,
    mint_key,
    mint_preview_key,
    mint_public_key,
    parse_key,
    thumb_key_for,
)

USER = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
HEX32 = "0" * 32


# --------------------------------------------------------------------------- #
# mint_key — canonical layout
# --------------------------------------------------------------------------- #
class TestMintKey:
    def test_canonical_shape(self):
        key = mint_key(USER, "items", ".png")
        assert re.fullmatch(rf"users/{USER}/items/[0-9a-f]{{32}}\.png", key)
        assert key.startswith(f"users/{USER}/items/")
        assert is_owned_storage_key(key, USER)

    def test_normalizes_leading_dot_on_extension(self):
        assert mint_key(USER, "outfits", "webp").endswith(".webp")

    def test_unique_per_call(self):
        assert mint_key(USER, "items", ".png") != mint_key(USER, "items", ".png")

    @pytest.mark.parametrize("category", ["tmp", "generated", "export", "not-a-category"])
    def test_rejects_non_canonical_category(self, category):
        with pytest.raises(ValueError):
            mint_key(USER, category, ".png")

    @pytest.mark.parametrize("category", sorted(CANONICAL_CATEGORIES))
    def test_every_canonical_category_is_accepted(self, category):
        key = mint_key(USER, category, ".png")
        assert parse_key(key).layout == "canonical"
        assert parse_key(key).category == category


# --------------------------------------------------------------------------- #
# mint_preview_key — staging-only preview layout
# --------------------------------------------------------------------------- #
class TestMintPreviewKey:
    def test_tmp_shape(self):
        key = mint_preview_key(TEMP_FOLDER, USER, "batch", ".webp")
        assert re.fullmatch(rf"users/{USER}/tmp/batch/[0-9a-f]{{32}}\.webp", key)
        assert is_owned_storage_key(key, USER)
        assert parse_key(key).layout == "preview"

    def test_generated_shape(self):
        key = mint_preview_key(GENERATED_FOLDER, USER, "try-on", ".png")
        assert key.startswith(f"users/{USER}/generated/try-on/")
        assert parse_key(key).folder == GENERATED_FOLDER
        assert parse_key(key).sub == "try-on"

    @pytest.mark.parametrize("folder", ["items", "outfits", "export", "nope"])
    def test_rejects_non_preview_folder(self, folder):
        with pytest.raises(ValueError):
            mint_preview_key(folder, USER, "batch", ".png")


# --------------------------------------------------------------------------- #
# mint_export_key — deterministic per-user export
# --------------------------------------------------------------------------- #
class TestMintExportKey:
    def test_shape(self):
        assert mint_export_key(USER) == f"users/{USER}/export/data.json"

    def test_deterministic(self):
        assert mint_export_key(USER) == mint_export_key(USER)


# --------------------------------------------------------------------------- #
# thumb_key_for — derived thumbnail siblings (both layouts)
# --------------------------------------------------------------------------- #
class TestThumbKeyFor:
    def test_derives_thumb_sibling_new_layout(self):
        assert thumb_key_for(f"users/{USER}/items/{HEX32}.png") == (
            f"users/{USER}/items/{HEX32}_thumb.webp"
        )

    def test_derives_thumb_sibling_legacy_layout(self):
        assert thumb_key_for(f"{USER}/items/{HEX32}.png") == (
            f"{USER}/items/{HEX32}_thumb.webp"
        )

    def test_thumb_is_always_webp(self):
        for ext in ("jpg", "jpeg", "png", "avif"):
            assert thumb_key_for(f"users/{USER}/avatars/{HEX32}.{ext}").endswith("_thumb.webp")

    def test_returns_none_for_preview_keys(self):
        assert thumb_key_for(f"users/{USER}/tmp/batch/{HEX32}.webp") is None
        assert thumb_key_for(f"tmp/{USER}/batch/{HEX32}.webp") is None

    def test_returns_none_for_thumb_of_thumb(self):
        assert thumb_key_for(f"users/{USER}/items/{HEX32}_thumb.webp") is None

    def test_returns_none_for_public_keys(self):
        assert thumb_key_for(f"public/banners/home/{HEX32}.webp") is None

    def test_returns_none_for_extensionless_and_empty(self):
        assert thumb_key_for(f"users/{USER}/items/{HEX32}") is None
        assert thumb_key_for("") is None
        assert thumb_key_for(None) is None


# --------------------------------------------------------------------------- #
# parse_key — structural parser
# --------------------------------------------------------------------------- #
class TestParseKey:
    def test_canonical(self):
        ref = parse_key(f"users/{USER}/items/{HEX32}.png")
        assert ref.layout == "canonical"
        assert ref.user == USER
        assert ref.category == "items"
        assert ref.name == HEX32
        assert ref.ext == "png"

    def test_thumb(self):
        ref = parse_key(f"users/{USER}/outfits/{HEX32}_thumb.webp")
        assert ref.layout == "thumb"
        assert ref.category == "outfits"
        assert ref.name == HEX32
        assert ref.ext == "webp"

    def test_preview(self):
        ref = parse_key(f"users/{USER}/tmp/social-import/{HEX32}.webp")
        assert ref.layout == "preview"
        assert ref.user == USER
        assert ref.folder == "tmp"
        assert ref.sub == "social-import"

    def test_export(self):
        ref = parse_key(f"users/{USER}/export/data.json")
        assert ref.layout == "export"
        assert ref.user == USER
        assert ref.category == "export"
        assert ref.name == "data.json"
        assert ref.ext == "json"

    def test_public(self):
        ref = parse_key(f"public/banners/home/{HEX32}.webp")
        assert ref.layout == "public"
        assert ref.group == "banners"
        assert ref.slug == "home"
        assert ref.name == HEX32
        assert ref.ext == "webp"

    @pytest.mark.parametrize(
        "key",
        [
            "",
            "   ",
            None,
            f"users/{USER}/tmp/batch/not-hex.webp",
            f"users/{USER}/items/{HEX32}.txt",
            "items/abc.png",
            f"users/{USER}/export/data.json/extra",
            "users/junk.webp",
            "public/misc/home/x.webp",
            f"http://example.com/{USER}/items/{HEX32}.png",  # URLs are not bare keys
            # Legacy pre-restructure keys are retired: they no longer parse.
            f"{USER}/items/{HEX32}.png",
            f"{USER}/tmp/batch/{HEX32}.webp",
            f"tmp/{USER}/batch/{HEX32}.webp",
            f"{USER}/export/data.json",
        ],
    )
    def test_unparseable_returns_none(self, key):
        assert parse_key(key) is None


# --------------------------------------------------------------------------- #
# key_from_path — URL/key reducer (SSRF-safe); legacy shapes map to users/
# --------------------------------------------------------------------------- #
class TestKeyFromPath:
    def test_bare_users_key_passes_through(self):
        key = f"users/{USER}/items/{HEX32}.png"
        assert key_from_path(key) == key

    def test_bare_legacy_key_maps_to_users_home(self):
        assert key_from_path(f"{USER}/items/{HEX32}.png") == (
            f"users/{USER}/items/{HEX32}.png"
        )

    @pytest.mark.parametrize("value", ["", "   ", None])
    def test_empty_returns_none(self, value):
        assert key_from_path(value) is None

    def test_supabase_public_url(self):
        url = f"https://p.supabase.co/storage/v1/object/public/fitcheck-images/{USER}/items/{HEX32}.png"
        assert key_from_path(url) == f"users/{USER}/items/{HEX32}.png"

    def test_configured_bucket_path_style_url(self, monkeypatch):
        monkeypatch.setattr("app.core.storage_keys.settings.OBJECT_STORAGE_BUCKET", "fitcheck-images")
        url = f"https://acct.r2.cloudflarestorage.com/fitcheck-images/{USER}/items/{HEX32}.png?X-Amz-Signature=abc"
        assert key_from_path(url) == f"users/{USER}/items/{HEX32}.png"

    def test_foreign_bucket_name_is_dropped_by_position(self, monkeypatch):
        monkeypatch.setattr("app.core.storage_keys.settings.OBJECT_STORAGE_BUCKET", "fitcheck-images")
        # A pre-cutover Railway URL: non-UUID bucket segment dropped by position,
        # then the legacy key maps to its users/ home.
        url = f"https://t3.storageapi.dev/collapsible-saddlebag-s0pyqr/{USER}/items/{HEX32}.png"
        assert key_from_path(url) == f"users/{USER}/items/{HEX32}.png"

    def test_worker_cdn_url_is_key(self):
        url = f"https://images.fitcheckaiapp.com/{USER}/items/{HEX32}.png"
        assert key_from_path(url) == f"users/{USER}/items/{HEX32}.png"

    def test_worker_cdn_top_level_preview_is_key(self):
        url = f"https://images.fitcheckaiapp.com/tmp/{USER}/batch/{HEX32}.webp"
        assert key_from_path(url) == f"users/{USER}/tmp/batch/{HEX32}.webp"

    def test_foreign_bucket_top_level_preview_drops_bucket(self, monkeypatch):
        monkeypatch.setattr("app.core.storage_keys.settings.OBJECT_STORAGE_BUCKET", "fitcheck-images")
        url = f"https://t3.storageapi.dev/old-bucket/tmp/{USER}/batch/{HEX32}.webp"
        assert key_from_path(url) == f"users/{USER}/tmp/batch/{HEX32}.webp"

    def test_foreign_url_returns_none(self):
        assert key_from_path("https://example.com/a.jpg") is None


# --------------------------------------------------------------------------- #
# build_object_url — path-style object locator
# --------------------------------------------------------------------------- #
class TestBuildObjectUrl:
    def test_path_style_composition(self, monkeypatch):
        monkeypatch.setattr("app.core.storage_keys.settings.OBJECT_STORAGE_ENDPOINT", "https://r2.example")
        monkeypatch.setattr("app.core.storage_keys.settings.OBJECT_STORAGE_BUCKET", "fitcheck-images")
        assert build_object_url("/u1/items/a.png") == (
            "https://r2.example/fitcheck-images/u1/items/a.png"
        )
        assert build_object_url("u1/items/a.png") == (
            "https://r2.example/fitcheck-images/u1/items/a.png"
        )


# --------------------------------------------------------------------------- #
# predicates — preview detection + legacy normalization
# --------------------------------------------------------------------------- #
class TestPredicates:
    @pytest.mark.parametrize(
        "key",
        [
            f"users/{USER}/tmp/batch/{HEX32}.webp",
            f"users/{USER}/generated/try-on/{HEX32}.webp",
        ],
    )
    def test_is_preview_key_true(self, key):
        assert is_preview_key(key) is True

    @pytest.mark.parametrize(
        "key",
        [
            f"users/{USER}/items/{HEX32}.png",
            f"users/{USER}/items/{HEX32}_thumb.webp",
            f"{USER}/items/{HEX32}.png",  # legacy keys no longer parse
            f"tmp/{USER}/batch/{HEX32}.webp",  # legacy preview no longer parses
            "public/banners/home/x.webp",
            "",
            None,
            f"users/{USER}/export/data.json",
        ],
    )
    def test_is_preview_key_false(self, key):
        assert is_preview_key(key) is False

    def test_is_public_key(self):
        assert is_public_key(f"public/banners/home/{HEX32}.webp") is True
        assert is_public_key(f"public/misc/home/{HEX32}.webp") is False
        assert is_public_key(f"users/{USER}/items/{HEX32}.png") is False
        assert is_public_key(None) is False

    def test_owned_key_checks_user(self):
        key = mint_key(USER, "items", ".png")
        other = str(uuid.uuid4())
        assert is_owned_storage_key(key, USER) is True
        assert is_owned_storage_key(key, other) is False

    def test_owned_key_public_never_owned(self):
        key = mint_public_key("banners", "home", ".webp")
        assert is_owned_storage_key(key, USER) is False

    def test_owned_key_export_never_owned(self):
        assert is_owned_storage_key(mint_export_key(USER), USER) is False

    def test_owned_key_legacy_not_owned(self):
        # Legacy pre-restructure keys no longer parse; they are never owned.
        key = f"{USER}/items/{HEX32}.png"
        assert is_owned_storage_key(key, USER) is False


# --------------------------------------------------------------------------- #
# migrate_key_to_users_layout — legacy -> users/ mapping
# --------------------------------------------------------------------------- #
class TestMigrateKeyToUsersLayout:
    def test_legacy_canonical(self):
        assert migrate_key_to_users_layout(f"{USER}/items/{HEX32}.png") == (
            f"users/{USER}/items/{HEX32}.png"
        )

    def test_legacy_thumb(self):
        assert migrate_key_to_users_layout(f"{USER}/items/{HEX32}_thumb.webp") == (
            f"users/{USER}/items/{HEX32}_thumb.webp"
        )

    def test_legacy_top_level_preview(self):
        assert migrate_key_to_users_layout(f"tmp/{USER}/batch/{HEX32}.webp") == (
            f"users/{USER}/tmp/batch/{HEX32}.webp"
        )

    def test_legacy_per_user_preview(self):
        assert migrate_key_to_users_layout(f"{USER}/generated/product/{HEX32}.webp") == (
            f"users/{USER}/generated/product/{HEX32}.webp"
        )

    def test_legacy_export(self):
        assert migrate_key_to_users_layout(f"{USER}/export/data.json") == (
            f"users/{USER}/export/data.json"
        )

    def test_current_users_key_passes_through(self):
        key = mint_key(USER, "items", ".png")
        assert migrate_key_to_users_layout(key) == key

    def test_public_key_passes_through(self):
        key = mint_public_key("banners", "home", ".webp")
        assert migrate_key_to_users_layout(key) == key

    def test_never_promotes_preview_to_durable(self):
        """The mapper preserves the category — promotion is the migration
        script's job (staging-only invariant), never this pure function."""
        assert migrate_key_to_users_layout(f"{USER}/generated/product/{HEX32}.webp").endswith(
            f"/generated/product/{HEX32}.webp"
        )

    @pytest.mark.parametrize("key", ["", None, "junk", "not/a/key"])
    def test_unknown_returns_none(self, key):
        assert migrate_key_to_users_layout(key) is None

    def test_any_public_prefixed_key_passes_through(self):
        # The mapper only rewrites legacy shapes; current-layout prefixes
        # (even a malformed public key) are returned unchanged — validation is
        # the worker/parse_key's job, not the layout mapper's.
        assert migrate_key_to_users_layout("public/x/y.webp") == "public/x/y.webp"


def test_grammar_constants_are_consistent():
    """The regex allowlist is built from the same constants as the minters."""
    key = mint_key(USER, "sources", ".jpg")
    assert is_owned_storage_key(key, USER)
    preview = mint_preview_key(TEMP_FOLDER, USER, "upload", ".png")
    assert is_owned_storage_key(preview, USER)
    assert THUMB_SUFFIX == "_thumb"
    assert THUMB_EXTENSION == ".webp"
    assert PREVIEW_FOLDERS == {TEMP_FOLDER, GENERATED_FOLDER}
    assert USER_ID_SEGMENT_RE.fullmatch(USER)
