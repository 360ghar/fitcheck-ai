"""
Interface-conformance tests: catches accidental signature drift between the
two provider implementations at CI time rather than at a call site.
"""

from app.services.ai_provider_interface import AIProvider, AIProviderClient, get_provider_class, valid_provider_values
from app.services.ai_provider_service import AIProviderService, ProviderConfig
from app.services.gemini_provider import GeminiConfig, GeminiProvider


def _make_provider_config() -> ProviderConfig:
    return ProviderConfig(api_url="https://llm.example.com/v1", api_key="k", model="m")


def _make_gemini_config() -> GeminiConfig:
    return GeminiConfig(api_key="k")


def test_ai_provider_service_conforms_to_interface():
    assert isinstance(AIProviderService(_make_provider_config()), AIProviderClient)


def test_gemini_provider_conforms_to_interface():
    assert isinstance(GeminiProvider(_make_gemini_config()), AIProviderClient)


def test_openai_and_custom_both_registered_to_ai_provider_service():
    assert get_provider_class(AIProvider.OPENAI) is AIProviderService
    assert get_provider_class(AIProvider.CUSTOM) is AIProviderService


def test_gemini_registered_to_gemini_provider():
    assert get_provider_class(AIProvider.GEMINI) is GeminiProvider


def test_valid_provider_values_includes_all_three():
    assert set(valid_provider_values()) == {"openai", "custom", "gemini"}


def test_config_cls_matches_registered_implementation():
    assert AIProviderService.config_cls is ProviderConfig
    assert GeminiProvider.config_cls is GeminiConfig
