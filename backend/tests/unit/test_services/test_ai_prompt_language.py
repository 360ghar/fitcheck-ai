"""The prompt-side half of the language contract.

Two prompt classes exist in this backend and they must never converge:

- **Generated prose** — text a human reads that the client cannot translate.
  Every such prompt must carry `language_instruction(...)`.
- **Canonical output and image prompts** — taxonomy values, garment
  descriptions and anything an image model consumes. These must stay English
  and must never read the request language, or a language switch duplicates a
  user's wardrobe and fractures the embedding index.

This backend has no user-visible prose path today (see docs/BACKEND.md →
"Language contract" for the audit). The tests below pin both halves so the
first prose path cannot be added without the instruction and the extraction
path cannot quietly acquire one.
"""

import json

import pytest

from app.agents.item_extraction_agent import (
    COLOR_DETECTION_PROMPT,
    SINGLE_ITEM_DESCRIPTION_RULES,
    SINGLE_ITEM_EXTRACTION_PROMPT,
    ItemExtractionAgent,
    _build_multi_item_extraction_prompt,
)
from app.core import middleware
from app.core.i18n import DEFAULT_LANGUAGE, language_instruction, language_name
from app.core.middleware import set_request_language
from app.models.photoshoot import PhotoshootUseCase
from app.services import extraction_cache_service
from app.services.ai_provider_interface import AIResponse
from app.services.extraction_cache_service import ExtractionCacheService
from app.services.photoshoot_service import PhotoshootService

# Phrases that only ever appear when a prompt was localized on purpose.
INSTRUCTION_MARKER = "Write all user-facing text"

CANONICAL_PROMPTS = {
    "multi_item_with_profile": _build_multi_item_extraction_prompt(True),
    "multi_item_without_profile": _build_multi_item_extraction_prompt(False),
    "single_item": SINGLE_ITEM_EXTRACTION_PROMPT.format(
        category_hint="", description_rules=SINGLE_ITEM_DESCRIPTION_RULES
    ),
    "color_detection": COLOR_DETECTION_PROMPT,
}


@pytest.fixture(autouse=True)
def _isolate_request_language():
    token = middleware._request_language.set(DEFAULT_LANGUAGE)
    yield
    middleware._request_language.reset(token)


@pytest.fixture(autouse=True)
def _reset_extraction_cache():
    extraction_cache_service._cache.clear()
    yield
    extraction_cache_service._cache.clear()


class _CapturingProvider:
    """Stands in for AIProviderService; records prompts, returns a fixed reply."""

    def __init__(self, text: str | None = None):
        self.text = text
        self.prompts: list[str] = []

    async def chat_with_vision(self, prompt: str, images, **_kwargs):
        self.prompts.append(prompt)
        return AIResponse(text=self.text, model="fake", provider="fake")


class _CapturingChatProvider:
    """Same, for the photoshoot planner which uses `chat` + `close`."""

    def __init__(self, payload: dict):
        self.payload = payload
        self.messages = []

    async def chat(self, messages, **_kwargs):
        self.messages.append(messages)
        return AIResponse(text=json.dumps(self.payload), model="fake", provider="fake")

    async def close(self):
        return None


# ---------------------------------------------------------------------------
# Canonical prompts must never localize
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("name", sorted(CANONICAL_PROMPTS))
def test_canonical_prompt_has_no_language_instruction(name):
    prompt = CANONICAL_PROMPTS[name]

    assert INSTRUCTION_MARKER not in prompt
    for code in ("hi", "ar", "ja", "pt"):
        assert f"in {language_name(code)}" not in prompt


@pytest.mark.asyncio
async def test_extraction_prompt_is_identical_whatever_the_request_language():
    """The request language must not reach an extraction prompt, at all."""

    async def _prompts_for(language: str) -> list[str]:
        set_request_language(language)
        provider = _CapturingProvider(text=None)
        agent = ItemExtractionAgent(provider)  # type: ignore[arg-type]
        await agent.extract_multiple_items("aGVsbG8=")
        await agent.extract_single_item("aGVsbG8=")
        await agent.detect_colors("aGVsbG8=")
        return provider.prompts

    english = await _prompts_for("en")
    hindi = await _prompts_for("hi")

    assert len(english) == 3
    assert english == hindi


@pytest.mark.asyncio
async def test_photoshoot_scene_plans_stay_english(monkeypatch):
    """Scene plans are an image prompt, not copy: they never localize."""
    payload = {
        "subject_lock": "adult, dark hair, neutral expression",
        "prompts": [
            {
                "index": 0,
                "setting": "glass office at noon",
                "outfit": "navy blazer, white shirt",
                "pose": "half-body, facing camera",
                "lighting": "soft window light",
                "style": "corporate",
                "mood": "confident",
                "scene_body": "glass office at noon. navy blazer, white shirt.",
            }
        ],
    }
    provider = _CapturingChatProvider(payload)

    async def _fake_get_ai_service():
        return provider

    import app.services.ai_provider_service as ai_provider_service

    monkeypatch.setattr(ai_provider_service, "get_ai_service", _fake_get_ai_service)
    set_request_language("hi")

    prompts = await PhotoshootService.generate_prompts(PhotoshootUseCase.LINKEDIN, 1)

    system_prompt = provider.messages[0][0].content
    assert INSTRUCTION_MARKER not in system_prompt
    assert "Hindi" not in system_prompt
    assert prompts[0].setting == "glass office at noon"


# ---------------------------------------------------------------------------
# The instruction itself, for the prose paths that will carry it
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("code", "expected_name"),
    [("hi", "Hindi"), ("ar-SA", "Arabic"), ("ja", "Japanese")],
)
def test_language_instruction_names_the_language(code, expected_name):
    instruction = language_instruction(code, subject="outfit rationale")

    assert expected_name in instruction
    assert "for outfit rationale" in instruction
    # The JSON guard is what keeps a localized prose field from breaking parsing.
    assert "Keep JSON keys, enum values and category identifiers in English" in instruction


def test_language_instruction_is_english_only_for_the_default():
    assert language_instruction(DEFAULT_LANGUAGE) == "Write all user-facing text in English."
    assert INSTRUCTION_MARKER in language_instruction("en", subject="anything")


@pytest.mark.parametrize(
    ("code", "expected_name"),
    [("hi", "Hindi"), ("ar-SA", "Arabic"), ("ja", "Japanese")],
)
def test_a_prose_prompt_carries_the_instruction(code, expected_name):
    """Shape every future prose prompt must have (see docs/BACKEND.md)."""
    system_prompt = (
        "You write the one-line rationale shown under a recommended outfit.\n"
        'Return JSON: {"rationale": string, "occasion": "work"|"casual"}.\n'
        f"{language_instruction(code, subject='outfit rationale')}"
    )

    assert INSTRUCTION_MARKER in system_prompt
    assert f"in {expected_name}" in system_prompt
    assert '"rationale"' in system_prompt, "the JSON skeleton must survive"


@pytest.mark.asyncio
async def test_json_output_keeps_english_keys_when_values_are_localized():
    """A localized prose field must not turn into localized keys.

    The provider is mocked with English keys and Hindi values, exactly what a
    model following `language_instruction` is allowed to return. The real
    parser and normalizers must still produce the canonical shape.
    """
    prompt = SINGLE_ITEM_EXTRACTION_PROMPT.format(
        category_hint="", description_rules=SINGLE_ITEM_DESCRIPTION_RULES
    )
    prompt = f"{prompt}\n\n{language_instruction('hi', subject='item preview')}"
    assert "Hindi" in prompt

    hindi_description = "गोल गले वाली कॉटन टी-शर्ट; नीली धारियाँ"
    provider = _CapturingProvider(
        text=json.dumps(
            {
                "category": "tops",
                "sub_category": "टी-शर्ट",
                "colors": ["Blue", "WHITE"],
                "material": "cotton",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.91,
                "description": hindi_description,
            }
        )
    )
    agent = ItemExtractionAgent(provider)  # type: ignore[arg-type]

    parsed = await agent.extract_single_item("aGVsbG8=")

    assert set(parsed) == {
        "category",
        "sub_category",
        "colors",
        "material",
        "pattern",
        "brand",
        "confidence",
        "description",
    }
    assert parsed["category"] == "tops", "enum stays canonical English"
    assert parsed["colors"] == ["blue", "white"], "colors stay lowercase basic names"
    assert parsed["sub_category"] == "टी-शर्ट", "prose value survives untouched"
    assert parsed["description"] == hindi_description


# ---------------------------------------------------------------------------
# Caches
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_extraction_cache_key_is_language_free_by_design():
    """Canonical output: one entry serves every language. Do not add language."""
    image = "aGVsbG8="
    result = {"items": [{"category": "tops", "sub_category": "t-shirt"}]}

    set_request_language("en")
    await ExtractionCacheService.set_cached_result(image, "user-1", result)

    set_request_language("hi")
    cached = await ExtractionCacheService.get_cached_result(image, "user-1")

    assert cached == result
    assert len(extraction_cache_service._cache) == 1, (
        "a second, per-language entry would mean canonical output got localized"
    )
