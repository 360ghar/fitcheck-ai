"""Language support shared by the API and the AI prompts.

The app ships 50 locales (see `store/asc/locales.json`). The backend does not
translate UI copy — the Flutter client owns that — but it does need to:

* accept and validate the language the client reports,
* expose the supported set so a client can fall back deliberately, and
* tell an LLM which language to answer in when the answer is user-facing.

One list, one normalizer, one instruction builder. Keeping the list here means
a language added to the store cannot silently be rejected by the API.
"""

from __future__ import annotations

import re
from typing import Optional

# (BCP-47 tag, English name). Tags mirror the Flutter locale the client sends;
# region variants collapse to the base language because the API only needs to
# know which language to write in.
SUPPORTED_LANGUAGES: tuple[tuple[str, str], ...] = (
    ("en", "English"),
    ("es", "Spanish"),
    ("pt", "Portuguese"),
    ("fr", "French"),
    ("de", "German"),
    ("it", "Italian"),
    ("nl", "Dutch"),
    ("sv", "Swedish"),
    ("no", "Norwegian"),
    ("da", "Danish"),
    ("fi", "Finnish"),
    ("pl", "Polish"),
    ("cs", "Czech"),
    ("sk", "Slovak"),
    ("sl", "Slovenian"),
    ("hr", "Croatian"),
    ("ro", "Romanian"),
    ("hu", "Hungarian"),
    ("el", "Greek"),
    ("tr", "Turkish"),
    ("ru", "Russian"),
    ("uk", "Ukrainian"),
    ("ar", "Arabic"),
    ("he", "Hebrew"),
    ("ur", "Urdu"),
    ("hi", "Hindi"),
    ("bn", "Bangla"),
    ("gu", "Gujarati"),
    ("kn", "Kannada"),
    ("ml", "Malayalam"),
    ("mr", "Marathi"),
    ("or", "Odia"),
    ("pa", "Punjabi"),
    ("ta", "Tamil"),
    ("te", "Telugu"),
    ("zh", "Chinese"),
    ("ja", "Japanese"),
    ("ko", "Korean"),
    ("th", "Thai"),
    ("vi", "Vietnamese"),
    ("id", "Indonesian"),
    ("ms", "Malay"),
    ("ca", "Catalan"),
)

_LANGUAGE_NAMES = dict(SUPPORTED_LANGUAGES)
_SUPPORTED_CODES = frozenset(_LANGUAGE_NAMES)

DEFAULT_LANGUAGE = "en"

# Right-to-left languages. The client mirrors the layout; the backend uses this
# only to avoid injecting Latin punctuation into an RTL sentence.
RTL_LANGUAGES = frozenset({"ar", "he", "ur"})

_TAG = re.compile(r"^([A-Za-z]{2,3})(?:[-_][A-Za-z0-9]{2,8})*$")


def normalize_language(value: Optional[str]) -> str:
    """Return a supported base language code, or the default.

    Accepts what clients actually send: `hi`, `hi-IN`, `pt_BR`, `zh-Hans`.
    An unsupported or malformed value falls back to English rather than
    raising, because a request must never fail over a display preference.
    """
    if not value:
        return DEFAULT_LANGUAGE
    candidate = value.strip()
    if not candidate:
        return DEFAULT_LANGUAGE
    # `Accept-Language` lists carry weights: "hi-IN,hi;q=0.9,en;q=0.8".
    first = candidate.split(",")[0].split(";")[0].strip()
    match = _TAG.match(first)
    if not match:
        return DEFAULT_LANGUAGE
    code = match.group(1).lower()
    return code if code in _SUPPORTED_CODES else DEFAULT_LANGUAGE


def is_supported_language_tag(value: Optional[str]) -> bool:
    """Whether `value` names a language this app ships.

    `normalize_language` deliberately collapses an unknown tag to the default,
    which makes "the user said English" and "the user said something we do not
    support" indistinguishable. Callers that must not act on a garbage value —
    e.g. letting a stored `language_explicit` flag override the device language
    — need the distinction, so they ask here first.
    """
    if not value:
        return False
    first = value.strip().split(",")[0].split(";")[0].strip()
    match = _TAG.match(first)
    if not match:
        return False
    return match.group(1).lower() in _SUPPORTED_CODES


def language_name(code: str) -> str:
    """English name of a supported language, for prompts and logs."""
    return _LANGUAGE_NAMES.get(normalize_language(code), "English")


def is_rtl(code: str) -> bool:
    return normalize_language(code) in RTL_LANGUAGES


def language_instruction(code: str, *, subject: str = "the user") -> str:
    """A prompt fragment that keeps user-facing text in one language.

    Deliberately explicit about what must stay English: JSON keys, enum values
    and category identifiers are read by code, and a model that translates
    `"category": "tops"` breaks parsing.
    """
    language = normalize_language(code)
    if language == DEFAULT_LANGUAGE:
        return "Write all user-facing text in English."

    name = language_name(language)
    return (
        f"Write all user-facing text (names, descriptions, suggestions) in {name} "
        f"for {subject}. Keep JSON keys, enum values and category identifiers in "
        "English exactly as specified. Do not mix languages inside one field."
    )


def supported_languages() -> list[dict[str, object]]:
    """The wire shape for `GET /api/v1/i18n/languages`."""
    return [
        {"code": code, "name": name, "rtl": code in RTL_LANGUAGES}
        for code, name in SUPPORTED_LANGUAGES
    ]


def language_from_accept_header(value: Optional[str], *, fallback: Optional[str] = None) -> str:
    """Best supported language from an `Accept-Language` header.

    Walks the weighted list in order and returns the first supported tag. This
    is intentionally not the most specific match: a phone set to
    `[ta-IN, en-US]` must get Tamil, not English, even though both are
    supported.
    """
    if not value:
        return normalize_language(fallback)
    for part in value.split(","):
        tag = part.split(";")[0].strip()
        if not tag:
            continue
        candidate = normalize_language(tag)
        if candidate != DEFAULT_LANGUAGE or tag.lower().startswith("en"):
            return candidate
    return normalize_language(fallback)
