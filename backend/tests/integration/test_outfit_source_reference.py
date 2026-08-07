"""
Tests for resolve_outfit_source_reference + the upload-flow source-photo
reference in outfit generation.

The upload flow (auto-outfit per uploaded photo) opts in via
GenerateOutfitRequest.use_source_photo. The backend then resolves the ORIGINAL
uploaded source photo the outfit's items were extracted from
(items.source_image_url) and sends it to the image model as one extra "as
worn" reference, so the render reproduces real fit/draping instead of
compounding the loss from the extracted/generated item shots.

Security property under test: source photos are only ever resolved through
the caller's own items rows (.eq("user_id", ...)), and StorageService is
never handed a client-chosen URL.
"""

import base64
import io
from typing import Any, Dict, List, Optional
from unittest.mock import AsyncMock

import pytest
from PIL import Image

from app.core.config import settings
from app.services import item_reference_service
from app.services.item_reference_service import resolve_outfit_source_reference


def _make_image_b64(size=(2000, 2000)) -> str:
    img = Image.new("RGB", size, (120, 30, 40))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=90)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _longest_edge(image_b64: str) -> int:
    with Image.open(io.BytesIO(base64.b64decode(image_b64))) as img:
        return max(img.size)


class _FakeQuery:
    """Records the filters applied so tests can assert on the user scoping."""

    def __init__(self, rows: List[Dict[str, Any]], captured: Dict[str, Any]):
        self._rows = rows
        self._captured = captured

    def select(self, columns: str):
        self._captured["select"] = columns
        return self

    def eq(self, column: str, value: Any):
        self._captured.setdefault("eq", {})[column] = value
        return self

    def in_(self, column: str, values: List[Any]):
        self._captured.setdefault("in_", {})[column] = list(values)
        return self

    def execute(self):
        eq = self._captured.get("eq", {})
        requested = set(self._captured.get("in_", {}).get("id", []))
        rows = [
            row
            for row in self._rows
            if row["user_id"] == eq.get("user_id") and row["id"] in requested
        ]
        # Mimic the real client: the user_id column is a filter, not a result
        # column, so it is not selected back.
        return type(
            "Result", (), {"data": [{k: v for k, v in r.items() if k != "user_id"} for r in rows]}
        )()


class _FakeDb:
    def __init__(self, rows: List[Dict[str, Any]]):
        self._rows = rows
        self.captured: Dict[str, Any] = {}
        self.table_calls: List[str] = []

    def table(self, name: str):
        self.table_calls.append(name)
        return _FakeQuery(self._rows, self.captured)


def _row(item_id: str, source_image_url: Optional[str], user_id: str = "user-1"):
    return {"id": item_id, "user_id": user_id, "source_image_url": source_image_url}


def _item(item_id: Optional[str], name: str = "item", category: str = "tops"):
    item: Dict[str, Any] = {"name": name, "category": category, "colors": []}
    if item_id is not None:
        item["item_id"] = item_id
    return item


@pytest.fixture
def stub_download(monkeypatch):
    """Map url -> base64 (or None to simulate a failed download)."""

    def _install(by_url: Dict[str, Optional[str]]):
        from app.utils.image_processing import (
            DEFAULT_MAX_EDGE,
            DEFAULT_QUALITY,
            downscale_base64_image,
        )

        async def fake_download(
            url: str,
            max_edge: int = DEFAULT_MAX_EDGE,
            quality: int = DEFAULT_QUALITY,
            timeout: float = 10.0,
        ):
            payload = by_url.get(url)
            if payload is None:
                return None
            # Mirror the production path's download-time downscale so size
            # assertions (test_source_photo_is_downscaled) hold.
            return downscale_base64_image(payload, max_edge=max_edge, quality=quality)

        monkeypatch.setattr(
            item_reference_service.StorageService,
            "download_and_downscale_to_base64",
            staticmethod(fake_download),
        )

    return _install


# =============================================================================
# RESOLVER
# =============================================================================


@pytest.mark.asyncio
async def test_no_item_ids_skips_the_database_entirely(stub_download):
    db = _FakeDb([])
    stub_download({})

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item(None), _item(None)]
    )

    assert db.table_calls == []
    assert stats["with_item_id"] == 0
    assert base64_out is None


@pytest.mark.asyncio
async def test_scopes_query_to_caller_and_ignores_other_users_photos(stub_download):
    """Another user's source photo resolves to nothing: no reference, no
    download, no leak. The user_id filter is asserted directly because it is
    the only thing enforcing ownership."""
    db = _FakeDb([
        _row("mine", "https://x.test/mine.jpg", user_id="user-1"),
        _row("theirs", "https://x.test/theirs.jpg", user_id="user-2"),
    ])
    stub_download({
        "https://x.test/mine.jpg": _make_image_b64((400, 400)),
        "https://x.test/theirs.jpg": _make_image_b64((400, 400)),
    })

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("mine"), _item("theirs")]
    )

    assert db.captured["eq"]["user_id"] == "user-1"
    assert db.captured["in_"]["id"] == ["mine", "theirs"]
    assert base64_out is not None
    assert stats["distinct_source_urls"] == 1
    assert stats["resolved"] is True


@pytest.mark.asyncio
async def test_most_shared_photo_wins(stub_download):
    """The URL shared by the most items wins; a second, less-covered photo is
    ignored entirely."""
    db = _FakeDb([
        _row("a1", "https://x.test/outfit-photo.jpg"),
        _row("a2", "https://x.test/outfit-photo.jpg"),
        _row("a3", "https://x.test/outfit-photo.jpg"),
        _row("b1", "https://x.test/other-photo.jpg"),
    ])
    stub_download({
        "https://x.test/outfit-photo.jpg": _make_image_b64((400, 400)),
        "https://x.test/other-photo.jpg": _make_image_b64((400, 400)),
    })

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item(i) for i in ("a1", "a2", "a3", "b1")]
    )

    assert stats["best_coverage"] == 3
    assert stats["candidate_selected"] is True
    assert stats["resolved"] is True
    assert base64_out is not None


@pytest.mark.asyncio
async def test_tie_between_two_photos_is_skipped(stub_download):
    """Two unrelated photos both covering the outfit is ambiguity - resolved
    to no reference rather than an arbitrary pick."""
    db = _FakeDb([
        _row("a1", "https://x.test/photo-a.jpg"),
        _row("b1", "https://x.test/photo-b.jpg"),
    ])
    stub_download({
        "https://x.test/photo-a.jpg": _make_image_b64((400, 400)),
        "https://x.test/photo-b.jpg": _make_image_b64((400, 400)),
    })

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("a1"), _item("b1")]
    )

    assert stats["tie_skipped"] is True
    assert base64_out is None


@pytest.mark.asyncio
async def test_below_min_shared_gate_skips(stub_download, monkeypatch):
    """MIN_SHARED_ITEMS is a floor so a scattered multi-photo outfit can never
    feed a busy photo in. The upload flow groups one photo per outfit, so its
    default of 1 always passes."""
    db = _FakeDb([_row("a1", "https://x.test/photo-a.jpg")])
    stub_download({"https://x.test/photo-a.jpg": _make_image_b64((400, 400))})
    monkeypatch.setattr(settings, "AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS", 2)

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("a1")]
    )

    assert stats["below_min_shared"] is True
    assert base64_out is None


@pytest.mark.asyncio
async def test_default_min_shared_is_one(stub_download):
    """The upload flow builds one outfit per photo, so even a single-item
    outfit resolves its source photo by default."""
    db = _FakeDb([_row("a1", "https://x.test/photo-a.jpg")])
    stub_download({"https://x.test/photo-a.jpg": _make_image_b64((400, 400))})

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("a1")]
    )

    assert stats["resolved"] is True
    assert base64_out is not None


@pytest.mark.asyncio
async def test_source_photo_is_downscaled(stub_download):
    db = _FakeDb([_row("a1", "https://x.test/big.jpg")])
    stub_download({"https://x.test/big.jpg": _make_image_b64((3000, 2000))})

    base64_out, _ = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("a1")], max_edge=768
    )

    assert base64_out is not None
    assert _longest_edge(base64_out) <= 768


@pytest.mark.asyncio
async def test_download_failure_returns_none(stub_download):
    db = _FakeDb([_row("a1", "https://x.test/dead.jpg")])
    stub_download({"https://x.test/dead.jpg": None})

    base64_out, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("a1")]
    )

    assert stats["download_failed"] is True
    assert base64_out is None


@pytest.mark.asyncio
async def test_query_failure_returns_none(stub_download):
    """A DB hiccup must not fail the generation - it degrades to today's
    item-reference-only behavior."""

    class _ExplodingDb:
        def table(self, name):
            raise RuntimeError("supabase down")

    stub_download({})
    base64_out, stats = await resolve_outfit_source_reference(
        db=_ExplodingDb(), user_id="user-1", items=[_item("item-1")]
    )

    assert stats["query_failed"] is True
    assert base64_out is None


# =============================================================================
# AGENT PROMPT ASSEMBLY
# =============================================================================


class _FakeImageResponse:
    def __init__(self, image_b64: str):
        self.images = [image_b64] if image_b64 else []
        self.model = "fake-model"
        self.provider = "fake-provider"


def _make_agent() -> Any:
    from app.agents.image_generation_agent import ImageGenerationAgent

    fake_ai_service = AsyncMock()
    fake_ai_service.generate_image = AsyncMock(
        return_value=_FakeImageResponse("ZmFrZQ==")
    )
    fake_ai_service.chat = AsyncMock(return_value=_FakeImageResponse("ZmFrZQ=="))
    fake_ai_service.get_image_gen_model = lambda: "fake-image-model"
    return ImageGenerationAgent(ai_service=fake_ai_service)


def _item_with_ref(name, category, reference=None):
    from app.agents.image_generation_agent import ImageGenerationAgent

    item = {"name": name, "category": category, "colors": []}
    if reference:
        item[ImageGenerationAgent.REFERENCE_KEY] = reference
    return item


def _captured_chat_content(agent):
    messages = agent.ai_service.chat.call_args.kwargs["messages"]
    assert len(messages) == 1
    return messages[0].content


@pytest.mark.asyncio
async def test_avatar_branch_sends_source_photo_between_avatar_and_garments():
    """Image order: avatar (1), source photo (2), garments (3, 4). The source
    photo is labelled as the as-worn appearance source, not an identity
    source, and the identity lock stays ahead of everything."""
    agent = _make_agent()
    result = await agent.generate_outfit(
        items=[
            _item_with_ref("Cream ribbed knit sweater", "tops", reference="c3dlYXRlcg=="),
            _item_with_ref("Black leather ankle boots", "shoes", reference="Ym9vdHM="),
        ],
        user_avatar_base64="YXZhdGFy",
        source_photo_base64="c291cmNl",
    )

    assert result.prompt
    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == [
        "image_url",
        "image_url",
        "image_url",
        "image_url",
        "text",
    ]
    # Images travel BARE in message content (the provider wraps at its own
    # wire boundary — see ai_provider_interface.build_user_multimodal_messages).
    assert content[0]["image_url"]["url"] == "YXZhdGFy"
    assert content[1]["image_url"]["url"] == "c291cmNl"
    assert content[2]["image_url"]["url"] == "c3dlYXRlcg=="
    assert content[3]["image_url"]["url"] == "Ym9vdHM="

    prompt = content[4]["text"]
    assert "IMAGE 1 = the person" in prompt
    assert "IMAGE 2 = the original photo of this outfit as worn" in prompt
    assert 'IMAGE 3 = Item 1 "Cream ribbed knit sweater" (tops)' in prompt
    assert 'IMAGE 4 = Item 2 "Black leather ankle boots" (shoes)' in prompt
    assert "SOURCE PHOTO LOCK" in prompt
    assert "appearance reference: IMAGE 3" in prompt
    assert "appearance reference: IMAGE 4" in prompt
    # Identity lock still precedes the source-photo lock and garment lock.
    assert prompt.index("IDENTITY LOCK") < prompt.index("SOURCE PHOTO LOCK")
    assert prompt.index("SOURCE PHOTO LOCK") < prompt.index("GARMENT REFERENCE LOCK")


@pytest.mark.asyncio
async def test_generic_model_branch_source_photo_takes_image_one():
    """No avatar: the source photo is IMAGE 1 and garments start at 2."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[_item_with_ref("Striped linen trousers", "bottoms", reference="dHJvdXNlcnM=")],
        source_photo_base64="c291cmNl",
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == ["image_url", "image_url", "text"]
    # Bare base64 in content; the provider wraps at the wire.
    assert content[0]["image_url"]["url"] == "c291cmNl"
    prompt = content[2]["text"]
    assert "IMAGE 1 = the original photo of this outfit as worn" in prompt
    assert 'IMAGE 2 = Item 1 "Striped linen trousers" (bottoms)' in prompt
    assert "SOURCE PHOTO LOCK" in prompt


@pytest.mark.asyncio
async def test_flat_lay_branch_carries_source_photo():
    """Flat lay gets the source photo too: the as-worn appearance still
    supplies each garment's exact look while the composition is rearranged."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[_item_with_ref("Striped linen trousers", "bottoms", reference="dHJvdXNlcnM=")],
        include_model=False,
        source_photo_base64="c291cmNl",
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == ["image_url", "image_url", "text"]
    prompt = content[2]["text"]
    assert "SOURCE PHOTO LOCK" in prompt
    assert "flat lay" in prompt


@pytest.mark.asyncio
async def test_absent_source_photo_leaves_prompt_byte_identical():
    """source_photo_base64=None (every caller except the upload flow) must not
    change the prompt or the image list at all - no scaffolding leaks in."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[
            _item_with_ref("Cream ribbed knit sweater", "tops", reference="c3dlYXRlcg=="),
            _item_with_ref("Black leather ankle boots", "shoes", reference="Ym9vdHM="),
        ],
        user_avatar_base64="YXZhdGFy",
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == [
        "image_url",
        "image_url",
        "image_url",
        "text",
    ]
    prompt = content[3]["text"]
    assert "SOURCE PHOTO LOCK" not in prompt
    assert "original photo of this outfit" not in prompt
    assert "IMAGE 2 = Item 1" in prompt
    assert "IMAGE 3 = Item 2" in prompt


# =============================================================================
# ENDPOINT WIRING (flag gates the resolver; result reaches the agent)
# =============================================================================


class _NoopRateLimit:
    async def __aenter__(self):
        return None

    async def __aexit__(self, *args):
        return False


def _make_request(use_source_photo: bool):
    from app.models.ai import GenerateOutfitRequest, OutfitItemInput

    return GenerateOutfitRequest(
        items=[
            OutfitItemInput(
                item_id="11111111-1111-4111-8111-111111111111",
                name="Cream ribbed knit sweater",
                category="tops",
                colors=["cream"],
            )
        ],
        include_user_face=False,
        use_source_photo=use_source_photo,
    )


def _patch_route_deps(monkeypatch, *, source_result):
    """Patch everything the route touches so we can call it directly."""
    from app.agents.image_generation_agent import GeneratedImage
    from app.api.v1 import ai as ai_module

    captured = {"item_refs_calls": 0, "source_refs_calls": 0, "agent": None}

    async def fake_item_refs(db, user_id, items):
        captured["item_refs_calls"] += 1
        return items, {"resolved": 1}

    async def fake_source_refs(db, user_id, items):
        captured["source_refs_calls"] += 1
        return source_result, {"resolved": source_result is not None}

    fake_agent = AsyncMock()
    fake_agent.generate_outfit = AsyncMock(
        return_value=GeneratedImage(
            image_base64="ZmFrZQ==", prompt="p", model="m", provider="fake"
        )
    )

    async def fake_get_agent(user_id, db):
        return fake_agent

    monkeypatch.setattr(ai_module, "rate_limited_operation", lambda *a, **k: _NoopRateLimit())
    monkeypatch.setattr(ai_module, "resolve_outfit_item_references", fake_item_refs)
    monkeypatch.setattr(ai_module, "resolve_outfit_source_reference", fake_source_refs)
    monkeypatch.setattr(ai_module, "get_image_generation_agent", fake_get_agent)
    captured["agent"] = fake_agent
    return captured


@pytest.mark.asyncio
async def test_endpoint_default_never_resolves_source_photo(monkeypatch):
    """use_source_photo defaults False: the builder path is untouched - the
    source resolver is never called and the agent gets source_photo_base64
    None."""
    from app.api.v1 import ai as ai_module

    captured = _patch_route_deps(monkeypatch, source_result=None)

    response = await ai_module.generate_outfit(
        request=_make_request(use_source_photo=False), user_id="user-1", db=object()
    )

    assert captured["source_refs_calls"] == 0
    assert captured["item_refs_calls"] == 1
    agent_kwargs = captured["agent"].generate_outfit.call_args.kwargs
    assert agent_kwargs["source_photo_base64"] is None
    assert response["data"]["image_base64"] == "ZmFrZQ=="


@pytest.mark.asyncio
async def test_endpoint_flag_on_resolves_and_forwards_source_photo(monkeypatch):
    """Upload flow (use_source_photo=True): the source resolver runs and its
    base64 reaches the agent."""
    from app.api.v1 import ai as ai_module

    captured = _patch_route_deps(monkeypatch, source_result="c291cmNlLXBob3Rv")

    response = await ai_module.generate_outfit(
        request=_make_request(use_source_photo=True), user_id="user-1", db=object()
    )

    assert captured["source_refs_calls"] == 1
    agent_kwargs = captured["agent"].generate_outfit.call_args.kwargs
    assert agent_kwargs["source_photo_base64"] == "c291cmNlLXBob3Rv"
    assert response["data"]["image_base64"] == "ZmFrZQ=="


@pytest.mark.asyncio
async def test_endpoint_flag_on_with_unresolvable_photo_still_generates(monkeypatch):
    """A failed source-photo resolution (None) must not fail the request -
    the agent is still called, with no source reference."""
    from app.api.v1 import ai as ai_module

    captured = _patch_route_deps(monkeypatch, source_result=None)

    response = await ai_module.generate_outfit(
        request=_make_request(use_source_photo=True), user_id="user-1", db=object()
    )

    assert captured["source_refs_calls"] == 1
    agent_kwargs = captured["agent"].generate_outfit.call_args.kwargs
    assert agent_kwargs["source_photo_base64"] is None
    assert response["data"]["image_base64"] == "ZmFrZQ=="
