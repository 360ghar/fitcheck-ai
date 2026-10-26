"""Language resolution: contextvar defaults, precedence, and the auth upgrade.

The contract under test (docs/BACKEND.md → "Language contract"):

1. Outside a request the language is `DEFAULT_LANGUAGE` — a background job,
   startup path or unit test must never explode over a missing request.
2. Precedence inside a request is explicit argument > contextvar > default.
3. The user's stored `user_settings.language` beats `Accept-Language` when it
   names a supported non-default language, because a user who picked Japanese
   on an English phone must get Japanese.
4. The auth dependencies are where the stored choice is read, so services can
   keep reading the contextvar instead of taking a parameter.
"""

from unittest.mock import Mock

import pytest
from starlette.requests import Request
from starlette.responses import Response

from app.api.v1 import deps
from app.api.v1.deps import get_active_user_id, get_current_user
from app.core import middleware
from app.core.i18n import (
    DEFAULT_LANGUAGE,
    language_from_accept_header,
    normalize_language,
)
from app.core.middleware import (
    LanguageMiddleware,
    apply_user_language,
    effective_language,
    get_request_language,
    resolve_language,
    set_request_language,
)
from app.core.security import TokenData


@pytest.fixture(autouse=True)
def _isolate_request_language():
    """Give every test a private slot of the contextvar and restore it after.

    The contextvar is process state; without this a test that sets `hi` leaks
    into the next one (the existing `_reset_user_profile_cache` fixture exists
    for exactly this reason).
    """
    token = middleware._request_language.set(DEFAULT_LANGUAGE)
    yield
    middleware._request_language.reset(token)


def _token(sub: str = "user-1") -> TokenData:
    token_data = TokenData(sub=sub, exp=1, aud="authenticated")
    token_data.email = "user@example.com"
    return token_data


def _request(headers: dict[str, str] | None = None) -> Request:
    raw = [
        (key.lower().encode("latin-1"), value.encode("latin-1"))
        for key, value in (headers or {}).items()
    ]
    return Request({"type": "http", "method": "GET", "path": "/", "headers": raw, "query_string": b""})


# ---------------------------------------------------------------------------
# Defaults and precedence
# ---------------------------------------------------------------------------


def test_get_request_language_is_unset_safe():
    """No request, no header, no exception: English."""
    assert get_request_language() == DEFAULT_LANGUAGE


def test_resolve_language_prefers_explicit_argument_over_contextvar():
    set_request_language("hi")

    assert resolve_language("ja") == "ja"
    assert resolve_language() == "hi"


def test_resolve_language_falls_back_to_default_without_any_signal():
    assert resolve_language() == DEFAULT_LANGUAGE
    assert resolve_language(None) == DEFAULT_LANGUAGE


def test_resolve_language_normalizes_raw_client_tags():
    assert resolve_language("hi-IN") == "hi"
    assert resolve_language("pt_BR") == "pt"
    assert resolve_language("zh-Hans") == "zh"


def test_set_request_language_normalizes_before_storing():
    set_request_language("pt_BR")

    assert get_request_language() == "pt"


def test_resolve_language_unknown_language_falls_back_to_english():
    assert resolve_language("xx-YY") == DEFAULT_LANGUAGE


# ---------------------------------------------------------------------------
# Accept-Language normalization
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("header", "expected"),
    [
        ("hi-IN,en;q=0.5", "hi"),
        ("pt_BR", "pt"),
        ("zh-Hans", "zh"),
        ("en-US,en;q=0.9", "en"),
        ("not a tag", "en"),
        (None, "en"),
    ],
)
def test_language_from_accept_header_normalizes_to_supported_code(header, expected):
    assert language_from_accept_header(header) == expected


def test_normalize_language_accepts_variant_and_weighted_values():
    assert normalize_language("pt_BR") == "pt"
    assert normalize_language("zh-Hans") == "zh"
    assert normalize_language("hi-IN;q=0.8") == "hi"


# ---------------------------------------------------------------------------
# Stored user choice beats the header
# ---------------------------------------------------------------------------


def test_stored_choice_beats_accept_language():
    set_request_language("en")  # what an English phone sends

    assert effective_language("ja") == "ja"
    assert get_request_language() == "en", "pure resolvers must not mutate the contextvar"


def test_stored_choice_is_normalized():
    set_request_language("en")

    assert effective_language("ar-SA") == "ar"


def test_explicit_english_beats_a_japanese_header():
    """The reason `language_explicit` exists (migration 065).

    A user who opened the picker and chose English must get English even though
    the phone is set to Japanese. Before the flag, this case was
    indistinguishable from an untouched `DEFAULT 'en'` row and lost.
    """
    set_request_language("ja")

    assert effective_language("en", explicit=True) == "en"


def test_explicit_non_default_still_wins():
    set_request_language("en")

    assert effective_language("hi", explicit=True) == "hi"


def test_non_explicit_english_defers_to_a_japanese_header():
    set_request_language("ja")

    assert effective_language("en", explicit=False) == "ja"


def test_non_explicit_non_default_still_wins():
    """Pre-065 behaviour, kept: a synced value without the flag is honoured.

    A client that writes a language but has not learned to send the flag must
    not lose its preference when this migration lands.
    """
    set_request_language("en")

    assert effective_language("hi", explicit=False) == "hi"


def test_stored_default_defers_to_the_header():
    """An untouched `user_settings.language='en'` row is not a choice.

    The column is `DEFAULT 'en'`, so treating it as a deliberate English pick
    would pin every auto-provisioned profile to English and ignore the header.
    """
    set_request_language("hi")

    assert effective_language("en") == "hi"


def test_explicit_flag_never_lifts_an_unsupported_value():
    """A garbage stored tag still falls back to the header, flag or not."""
    set_request_language("hi")

    assert effective_language("tlh", explicit=True) == "hi"


def test_unsupported_stored_value_defers_to_the_header():
    set_request_language("hi")

    assert effective_language("tlh") == "hi"


def test_apply_user_language_updates_the_contextvar():
    set_request_language("en")

    assert apply_user_language("ar-SA") == "ar"
    assert get_request_language() == "ar"


def test_apply_user_language_without_stored_choice_keeps_the_header_language():
    set_request_language("ta-IN")

    assert apply_user_language(None) == "ta"
    assert get_request_language() == "ta"


# ---------------------------------------------------------------------------
# Auth dependencies are the read site for the stored column
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_current_user_applies_stored_language(monkeypatch):
    profile = {
        "id": "user-1",
        "email": "user@example.com",
        "is_active": True,
        "user_settings": {"language": "ja"},
    }
    deps.user_profile_cache.clear()

    async def _lookup(_builder, _db, **_kwargs):
        result = Mock()
        result.data = dict(profile)
        return result

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    set_request_language("en")  # Accept-Language resolved to English

    await get_current_user(db=Mock(), token_data=_token())

    assert get_request_language() == "ja"


@pytest.mark.asyncio
async def test_get_current_user_without_settings_keeps_header_language(monkeypatch):
    deps.user_profile_cache.clear()

    async def _lookup(_builder, _db, **_kwargs):
        result = Mock()
        result.data = {"id": "user-1", "email": "user@example.com", "is_active": True}
        return result

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    set_request_language("hi")

    await get_current_user(db=Mock(), token_data=_token())

    assert get_request_language() == "hi"


@pytest.mark.asyncio
async def test_get_active_user_id_applies_stored_language(monkeypatch):
    async def _lookup(_builder, _db, **_kwargs):
        result = Mock()
        result.data = {"is_active": True, "user_settings": {"language": "ar-SA"}}
        return result

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    set_request_language("en")

    user_id = await get_active_user_id(db=Mock(), token_data=_token())

    assert user_id == "user-1"
    assert get_request_language() == "ar"


@pytest.mark.asyncio
async def test_get_active_user_id_ignores_missing_settings_embed(monkeypatch):
    async def _lookup(_builder, _db, **_kwargs):
        result = Mock()
        result.data = {"is_active": True}
        return result

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    set_request_language("ta")

    await get_active_user_id(db=Mock(), token_data=_token())

    assert get_request_language() == "ta"


def test_stored_language_tolerates_list_embed_shape():
    """PostgREST returns a list when a relation is one-to-many."""
    assert deps._stored_language({"user_settings": [{"language": "ko"}]}) == ("ko", False)
    assert deps._stored_language({"user_settings": []}) == (None, False)
    assert deps._stored_language({}) == (None, False)


def test_stored_language_reads_the_explicit_flag():
    assert deps._stored_language(
        {"user_settings": {"language": "en", "language_explicit": True}}
    ) == ("en", True)
    assert deps._stored_language(
        {"user_settings": {"language": "en", "language_explicit": False}}
    ) == ("en", False)
    # A row read before migration 065 lands has no such column.
    assert deps._stored_language({"user_settings": {"language": "hi"}}) == ("hi", False)
    # Only a real boolean True counts; a truthy string must not.
    assert deps._stored_language(
        {"user_settings": {"language": "hi", "language_explicit": "t"}}
    ) == ("hi", False)


@pytest.mark.asyncio
async def test_get_current_user_honours_an_explicit_english_choice(monkeypatch):
    """End-to-end proof of the migration's purpose: explicit en beats a ja header."""
    deps.user_profile_cache.clear()

    async def _lookup(_builder, _db, **_kwargs):
        result = Mock()
        result.data = {
            "id": "user-1",
            "email": "user@example.com",
            "is_active": True,
            "user_settings": {"language": "en", "language_explicit": True},
        }
        return result

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    set_request_language("ja")

    await get_current_user(db=Mock(), token_data=_token())

    assert get_request_language() == "en"


@pytest.mark.asyncio
async def test_rejected_embed_falls_back_to_a_plain_select(monkeypatch):
    """A PostgREST without the settings relation must not fail auth.

    Both auth selects embed `user_settings(language)`. If PostgREST rejects the
    embed (stale schema cache / missing FK), the lookup retries without it and
    the request keeps the language `Accept-Language` resolved to instead of
    returning 401 on every route.
    """
    deps.user_profile_cache.clear()
    calls: list[str] = []

    class _Recorder:
        def table(self, _name):
            return self

        def select(self, columns):
            calls.append(columns)
            return self

        def eq(self, *_args, **_kwargs):
            return self

        def maybe_single(self):
            return self

        def execute(self):
            if "user_settings" in calls[-1]:

                class _EmbedError(Exception):
                    code = "PGRST200"

                raise _EmbedError("embed not found")
            result = Mock()
            result.data = {"id": "user-1", "email": "user@example.com", "is_active": True}
            return result

    async def _run_query(builder, _db, **_kwargs):
        return builder(_Recorder())

    monkeypatch.setattr(deps, "execute_with_reconnect", _run_query)
    set_request_language("hi")

    user = await get_current_user(db=Mock(), token_data=_token())

    assert user["id"] == "user-1"
    assert get_request_language() == "hi"
    # Three steps, each dropping less than a naive fallback would. The middle
    # one keeps `language`; only the last gives up the whole preference.
    assert calls == [
        "*, user_settings(language, language_explicit)",
        "*, user_settings(language)",
        "*",
    ]


@pytest.mark.asyncio
async def test_a_missing_column_degrades_to_the_stored_language(monkeypatch):
    """The shape migration 065 produces before it is applied.

    Postgres answers an embed that names a column the table lacks with `42703`,
    not with one of the PGRST2xx relationship codes. That check is against the
    live project, which returns:

        HTTP 400 {"code":"42703",
                  "message":"column user_settings_1.language_explicit does not exist"}

    A fallback keyed only on PGRST200-202 therefore raised, and because this sits
    on the auth dependency, every authenticated route 400'd. Verified against
    the real project on 2026-10-26; no mocked test could have caught it, which is
    why this one asserts the retry shape as well as the outcome.
    """
    deps.user_profile_cache.clear()
    calls: list[str] = []

    class _MissingColumnError(Exception):
        code = "42703"

        def __str__(self):
            return "column user_settings_1.language_explicit does not exist"

    class _Recorder:
        def table(self, _name):
            return self

        def select(self, columns):
            calls.append(columns)
            return self

        def eq(self, *_args, **_kwargs):
            return self

        def maybe_single(self):
            return self

        def execute(self):
            if "language_explicit" in calls[-1]:
                raise _MissingColumnError()
            result = Mock()
            result.data = {
                "id": "user-1",
                "email": "user@example.com",
                "is_active": True,
                # The reduced embed still returns the stored preference.
                "user_settings": {"language": "ja"},
            }
            return result

    async def _run_query(builder, _db, **_kwargs):
        return builder(_Recorder())

    monkeypatch.setattr(deps, "execute_with_reconnect", _run_query)
    set_request_language("hi")

    user = await get_current_user(db=Mock(), token_data=_token())

    assert user["id"] == "user-1"
    assert calls == [
        "*, user_settings(language, language_explicit)",
        "*, user_settings(language)",
    ]
    # The user's stored language still wins: dropping a missing column must not
    # discard a preference that works.
    assert get_request_language() == "ja"


@pytest.mark.asyncio
async def test_a_missing_column_is_detected_without_a_code_attribute():
    """`postgrest-py` does not guarantee `.code`, so the message must also match."""

    class _NoCodeError(Exception):
        def __str__(self):
            return "column user_settings_1.language_explicit does not exist"

    assert deps._embed_is_unsupported(_NoCodeError()) is True


@pytest.mark.asyncio
async def test_an_unrelated_database_error_is_not_swallowed():
    class _OtherError(Exception):
        code = "42P01"

        def __str__(self):
            return "relation users does not exist"

    # A missing *table* is not a reason to silently drop a preference.
    assert deps._embed_is_unsupported(_OtherError()) is False


# ---------------------------------------------------------------------------
# Transport: Content-Language reports the effective language
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_middleware_sets_content_language_from_the_header():
    async def _call_next(_request):
        return Response()

    response = await LanguageMiddleware(app=None).dispatch(  # type: ignore[arg-type]
        _request({"Accept-Language": "hi-IN,en;q=0.5"}), _call_next
    )

    assert response.headers["content-language"] == "hi"


@pytest.mark.asyncio
async def test_middleware_content_language_follows_a_stored_language_upgrade():
    """The auth dependency rewrote the contextvar mid-request; the header follows."""

    async def _call_next(_request):
        apply_user_language("ja")
        return Response()

    response = await LanguageMiddleware(app=None).dispatch(  # type: ignore[arg-type]
        _request({"Accept-Language": "en-US,en;q=0.9"}), _call_next
    )

    assert response.headers["content-language"] == "ja"
    assert get_request_language() == DEFAULT_LANGUAGE, "the middleware must reset the contextvar"
