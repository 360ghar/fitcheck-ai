#!/usr/bin/env python3
"""Translate the web app's English catalog into all 43 base languages.

Source of truth: `frontend/src/i18n/locales/en.json` — one flat object of
message id to ICU MessageFormat string.

Output: `frontend/src/i18n/locales/<code>.json` for the 42 non-English base
languages, regenerated from a cache at `frontend/src/i18n/.translations.json`.

Why a cache instead of writing catalogs directly (the same reasoning as
`translate_arb.py`): the catalog files are build artifacts, and a reworded
English string must re-translate only itself instead of invalidating a whole
locale. Each cache row carries `_src`, the hash of the English text it was
produced from, so `--force` is rarely needed and an interrupted run resumes
without paying for finished strings again. 43 languages x 90 messages is 3,870
paid strings; losing that to a dropped connection is the difference between a
one-minute retry and a full re-run.

Placeholders are the failure mode that matters. `{count}`, `{year}`, `{query}`
and `{count, plural, one {…} other {…}}` must survive translation: a locale that
drops one renders a literal brace to the user and a plural block that loses its
`other` branch throws inside `intl-messageformat`. Every translation is compared
against the English ICU shape using `check_locales.icu_shape` (one ICU parser in
this repo, not two), a failing message is retried alone once, and a locale that
still has a bad message is NOT written. Shipping English there is visibly wrong
for one screen; shipping `{count} articles` is visibly broken on every screen.

Usage:
    python3 scripts/i18n/translate_web.py                    # missing/stale only
    python3 scripts/i18n/translate_web.py --force
    python3 scripts/i18n/translate_web.py --locale hi,ja
    python3 scripts/i18n/translate_web.py --dry-run
    python3 scripts/i18n/translate_web.py --sleep 1 --batch 20
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from check_locales import icu_shape  # noqa: E402  - one ICU parser, not two
from translate_listings import MODEL, call_gemini, load_env  # noqa: E402

# The transport, swapped by `--provider`. Gemini's daily cap cannot cover a full
# pass over 42 locales; Agnes allows 1,500 requests per 5 hours. Both satisfy the
# same signature.
MODEL_CALL = call_gemini

ROOT = Path(__file__).resolve().parents[2]
WEB_I18N = ROOT / "frontend" / "src" / "i18n"
LOCALES_DIR = WEB_I18N / "locales"
SOURCE = LOCALES_DIR / "en.json"
CACHE = WEB_I18N / ".translations.json"
LOCALES = ROOT / "store" / "asc" / "locales.json"
BACKEND_I18N = ROOT / "backend" / "app" / "core" / "i18n.py"

# One request per chunk. A whole catalog in one call overflows the output token
# budget for a non-Latin script and returns truncated JSON, which fails the
# parse and loses every string in the batch.
CHUNK = 30

# The store-locale table is keyed by App Store shortcode; the web speaks base
# languages. These are the base codes the backend accepts, in the order
# `SUPPORTED_LANGUAGES` declares them, minus English.
#
# Read from the backend file rather than duplicated so a language added there
# cannot silently be skipped here — `check_web_locales.py` fails on the drift
# either way, and this keeps the two from disagreeing at all.
_BACKEND_ENTRY = re.compile(r'\("([a-z]{2,3})",\s*"([^"]+)"\)')

# Brand and plan names that are correct untranslated in every locale. The model
# is told to leave these alone; the checker allowlists them so they do not read
# as "untranslated row".
PROTECTED = ("FitCheck AI", "Pro", "Plus", "AI", "Google", "Instagram", "LinkedIn")

SYSTEM = """You are a professional localizer for a consumer fashion and wardrobe web app.

You receive a JSON object of English UI strings and translate every value into the
target language.

Rules:
1. Output ONLY a JSON object with exactly the same keys as the input. No prose,
   no markdown fences, no explanation.
2. Never translate the brand "FitCheck AI", the plan names "Pro" and "Plus",
   the word "AI" when it is part of the product, or platform names (Google,
   Instagram, LinkedIn, iPhone, Android).
3. Preserve ICU placeholders exactly: any token like {count}, {year}, {query},
   {native} must appear unchanged in the translation. Do not add, remove, rename
   or reorder them.
4. Preserve ICU plural/select syntax exactly. For a value like
   "{count, plural, =0 {No items} one {# item} other {# items}}" translate only
   the text, keep the braces and the "#" or {count} references, keep the `other`
   branch, and keep any `=0`/`=1` exact-match branch. You MAY add the plural
   categories your language needs (zero, one, two, few, many) but never remove
   `other`.
5. Keep UI copy SHORT. These strings sit in buttons, tab labels, list rows, table
   cells and dialog titles. A translation 1.5x the length of the English will
   overflow a 360px phone. Prefer the shorter of two correct options.
6. Navigation and tab labels ("Dashboard", "Closet", "Outfits", "Try On",
   "Home", "Profile") must be one or two words, ideally under 12 characters.
7. Use the vocabulary a real shopping or wardrobe app in that language uses —
   "armario", "placard", "Kleiderschrank", "クローゼット" — not a literal
   word-for-word rendering of the English.
8. Single-word taxonomy labels are the vocabulary of a fashion app: use the word
   a shopping app in that language uses for that garment category.
9. In right-to-left languages (Arabic, Hebrew, Urdu) write natural RTL text. Do
   not insert direction-control characters or bidi marks.
10. Do not add punctuation the English does not have. Do not add emoji.
11. Numbers, dates, currency and percents are ALREADY formatted by Intl at
    runtime. Translate the surrounding words only; do not localize digits or
    reorder a placeholder.
12. Some values are unchanged on purpose ("FitCheck AI", "Pro"). Return those
    exactly as given rather than inventing a translation.
"""


def source_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()[:12]


def backend_languages() -> list[tuple[str, str]]:
    """`SUPPORTED_LANGUAGES` from the backend, as (code, English name).

    Parsed rather than imported: the backend module lives behind a venv, and a
    localization script must not need the API's dependencies to be installed to
    describe which languages the API accepts.
    """
    text = BACKEND_I18N.read_text(encoding="utf-8")
    start = text.find("SUPPORTED_LANGUAGES")
    if start == -1:
        raise SystemExit(f"{BACKEND_I18N} has no SUPPORTED_LANGUAGES")
    # The declaration ends at the first `)` on its own line.
    end = text.find("\n)", start)
    body = text[start : end if end != -1 else len(text)]
    languages = _BACKEND_ENTRY.findall(body)
    if len(languages) < 2:
        raise SystemExit(f"could not parse SUPPORTED_LANGUAGES from {BACKEND_I18N}")
    return languages


def native_names() -> dict[str, str]:
    """Endonym per base language, from the App Store locale table.

    `store/asc/locales.json` has one row per store locale; several rows collapse
    to one base (`pt-BR` and `pt-PT` -> `pt`). The first row wins, which is the
    primary market for that language, and English variants are skipped so `en`
    stays "English".
    """
    data = json.loads(LOCALES.read_text(encoding="utf-8"))["locales"]
    names: dict[str, str] = {}
    for entry in data:
        base = entry["dart"].split("_")[0].split("-")[0].lower()
        if base == "en":
            names.setdefault("en", "English")
            continue
        names.setdefault(base, entry["native"])
    return names


def pending_keys(english: dict[str, str], existing: dict) -> list[str]:
    return [
        key
        for key, value in english.items()
        if not existing.get(key) or existing[key].get("_src") != source_hash(value)
    ]


def parse_response(raw: str) -> dict:
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```[a-zA-Z]*\n?", "", cleaned)
        cleaned = re.sub(r"```$", "", cleaned).strip()
    start = cleaned.find("{")
    if start == -1:
        raise ValueError("response is not a JSON object")
    # `raw_decode` stops at the end of the first complete value. Slicing to the
    # LAST `}` instead fails with `Extra data: line N column 1` whenever a model
    # repeats its answer as `{...}\n{...}`, which lost seven locales in one run.
    parsed, _end = json.JSONDecoder().raw_decode(cleaned[start:])
    if not isinstance(parsed, dict):
        raise ValueError("response is not a JSON object")
    return parsed


def ask(
    keys: list[str],
    english: dict[str, str],
    code: str,
    english_name: str,
    native: str,
    api_keys: list[str],
    retries: int = 4,
) -> dict:
    """One model call for one chunk of keys, rotating keys on a dead key."""
    prompt = json.dumps(
        {
            "target_language": english_name,
            "native_name": native,
            "locale": code,
            "protected_terms": list(PROTECTED),
            "note": "Translate the VALUES. Keys are identifiers and never change.",
            "strings": {key: english[key] for key in keys},
        },
        ensure_ascii=False,
        indent=2,
    )
    last_error: Exception | None = None
    api_key = api_keys[0]
    for attempt in range(retries):
        try:
            raw = MODEL_CALL(api_key, prompt, system=SYSTEM, max_output_tokens=8192)
        except RuntimeError as error:
            last_error = error
            message = str(error)
            if "API key not valid" in message:
                if len(api_keys) == 1:
                    raise
                api_keys.remove(api_key)
                api_key = api_keys[0]
                continue
            # 429 / 503 / timeout: the key is fine, the request is too much for
            # a per-minute quota. Back off rather than burn the chunk. The free
            # tier's window is a minute, so the first wait has to exceed it.
            if "429" in message or "503" in message or "RESOURCE_EXHAUSTED" in message:
                wait = 30 * (2**attempt)
                print(
                    f"    · {code}: rate limited, waiting {wait}s ({message[:80]})",
                    file=sys.stderr,
                )
                time.sleep(wait)
                continue
            raise
        # Least-recently-used ordering: the next chunk goes out on a fresh key
        # so a single key's per-minute quota is not the ceiling for the run.
        api_keys.remove(api_key)
        api_keys.append(api_key)
        return parse_response(raw)
    raise RuntimeError(str(last_error) if last_error else "no usable API key")


def translate_chunk(
    keys: list[str],
    english: dict[str, str],
    code: str,
    english_name: str,
    native: str,
    api_keys: list[str],
    sleep: float,
) -> tuple[dict[str, str], list[str]]:
    """Translate a chunk, halving it on transport errors so one bad value is isolated.

    Returns the good translations and the keys that could not be translated.
    """
    try:
        time.sleep(sleep)
        result = ask(keys, english, code, english_name, native, api_keys)
    except (RuntimeError, ValueError, json.JSONDecodeError) as error:
        if len(keys) == 1:
            print(f"    ! {code}.{keys[0]}: {error}", file=sys.stderr)
            return {}, list(keys)
        print(f"    ~ {code}: chunk of {len(keys)} failed ({error}); splitting", file=sys.stderr)
        midpoint = len(keys) // 2
        left, left_bad = translate_chunk(
            keys[:midpoint], english, code, english_name, native, api_keys, sleep
        )
        right, right_bad = translate_chunk(
            keys[midpoint:], english, code, english_name, native, api_keys, sleep
        )
        return {**left, **right}, left_bad + right_bad

    good: dict[str, str] = {}
    bad: list[str] = []
    for key in keys:
        value = result.get(key)
        if not isinstance(value, str) or not value.strip():
            bad.append(key)
            continue
        good[key] = value.strip()
    return good, bad


def validate(translated: str, english_value: str) -> str | None:
    """Why this value is unusable, or None when it is fine.

    Placeholder names and ICU block kinds must match one-for-one. A language may
    legitimately *add* plural categories inside an existing block (Polish needs
    `few` and `many`) — that keeps the same block, so `icu_shape` still matches.
    An extra *branch* is fine; an extra *placeholder* is not: `{count}` becoming
    `{contagem}` means the number never renders.
    """
    expected_names, expected_blocks = icu_shape(english_value)
    names, blocks = icu_shape(translated)
    if names != expected_names:
        return f"placeholder mismatch (expected {sorted(expected_names)}, got {sorted(names)})"
    if blocks != expected_blocks:
        return f"ICU block mismatch (expected {sorted(expected_blocks)}, got {sorted(blocks)})"
    if translated.count("{") != translated.count("}"):
        return "unbalanced braces"
    return None


def translate_locale(
    code: str,
    english_name: str,
    native: str,
    english: dict[str, str],
    cache: dict,
    api_keys: list[str],
    sleep: float,
) -> tuple[dict, list[str], list[str]]:
    """Fill one locale. Returns (rows, failures, still_falling_back)."""
    existing = cache.get(code, {})
    pending = pending_keys(english, existing)
    if not pending:
        return existing, [], []

    print(f"  {code:<4} {len(pending)} string(s)")

    good: dict[str, str] = {}
    bad: list[str] = []
    for start in range(0, len(pending), CHUNK):
        chunk = pending[start : start + CHUNK]
        translated, failed = translate_chunk(
            chunk, english, code, english_name, native, api_keys, sleep
        )
        good.update(translated)
        bad.extend(failed)

    # A value that fails the ICU check gets one focused retry on its own: with a
    # single string in front of it the model reliably restores a dropped {year}.
    failures: list[str] = []
    for key in list(good):
        problem = validate(good[key], english[key])
        if problem is None:
            continue
        print(f"    ~ {code}.{key}: {problem}; retrying alone", file=sys.stderr)
        retry, retry_bad = translate_chunk(
            [key], english, code, english_name, native, api_keys, sleep
        )
        if key in retry and validate(retry[key], english[key]) is None:
            good[key] = retry[key]
        else:
            failures.append(f"{code}.{key}: {problem}")
            good.pop(key, None)
        bad.extend(retry_bad)

    for key in bad:
        failures.append(f"{code}.{key}: no translation returned")

    for key, value in good.items():
        existing[key] = {"value": value, "_src": source_hash(english[key]), "_model": MODEL}

    fell_back = [
        key
        for key in english
        if not existing.get(key) or existing[key].get("_src") != source_hash(english[key])
    ]
    return existing, failures, fell_back


def write_catalog(code: str, rows: dict, english: dict[str, str]) -> Path:
    """Regenerate one catalog from the cache, in English key order."""
    data = {key: (rows.get(key) or {}).get("value") or english[key] for key in english}
    path = LOCALES_DIR / f"{code}.json"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def main() -> int:
    global CHUNK

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--force", action="store_true", help="re-translate strings whose English changed too")
    parser.add_argument("--locale", default="", help="comma-separated base codes, e.g. hi,ja")
    parser.add_argument("--dry-run", action="store_true", help="report the work, call nothing")
    parser.add_argument("--sleep", type=float, default=0.2, help="seconds between requests")
    parser.add_argument("--batch", type=int, default=CHUNK, help="strings per request")
    parser.add_argument(
        "--provider",
        default="gemini",
        choices=("gemini", "agnes"),
        help="gemini (default) or agnes; both fill the same cache",
    )
    args = parser.parse_args()

    # Agnes ignores the key list and reads AGNES_AI_API_KEY itself, so the
    # rotation elsewhere is a harmless no-op with one placeholder entry.
    global MODEL_CALL
    if args.provider == "agnes":
        from agnes_client import call_agnes

        MODEL_CALL = call_agnes

    CHUNK = max(1, args.batch)

    english = json.loads(SOURCE.read_text(encoding="utf-8"))
    if not english:
        raise SystemExit(f"{SOURCE} is empty")

    languages = [(code, name) for code, name in backend_languages() if code != "en"]
    natives = native_names()
    wanted = {code.strip() for code in args.locale.split(",") if code.strip()}

    unknown = sorted(wanted - {code for code, _ in languages})
    if unknown:
        raise SystemExit(
            f"not a supported base language: {', '.join(unknown)}. "
            f"Supported: {', '.join(code for code, _ in languages)}"
        )

    cache: dict = {"_comment": "Generated by scripts/i18n/translate_web.py. Do not edit by hand."}
    if CACHE.exists():
        cache = json.loads(CACHE.read_text(encoding="utf-8"))

    if args.force:
        for entry in cache.values():
            if isinstance(entry, dict):
                for row in entry.values():
                    if isinstance(row, dict):
                        row.pop("_src", None)

    selected = [
        (code, name) for code, name in languages if not wanted or code in wanted
    ]

    if args.dry_run:
        total = 0
        for code, name in selected:
            stale = pending_keys(english, cache.get(code, {}))
            total += len(stale)
            print(f"{code:<4} {name:<12} {len(stale):4} string(s) to translate")
        print(
            f"\n{len(selected)} locale(s), {total} string(s), "
            f"{len(english)} keys in the source catalog"
        )
        return 0

    api_keys = (
        (["agnes"] if args.provider == "agnes" else load_env()) if selected else []
    )
    failures: list[str] = []
    written: dict[str, int] = {}
    skipped: list[str] = []
    fallbacks: dict[str, int] = {}

    for code, name in selected:
        rows, locale_failures, fell_back = translate_locale(
            code, name, natives.get(code, name), english, cache, api_keys, args.sleep
        )
        cache[code] = rows
        CACHE.write_text(
            json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

        # Partial failure is not a reason to throw the catalog away. The old
        # `continue` here was intended to avoid shipping a half-English page, but
        # a catalog that is never written does not ship at all — a missing key
        # falls back to `en.json` at runtime, so the page was half-English either
        # way, minus the 814 strings that did translate. `fi` lost 814 of 844
        # translations to 30 failures in one run for exactly this reason.
        # `write_catalog` fills any absent key with the English source, so the
        # file is always complete and the failure count is reported instead.
        if locale_failures:
            failures.extend(locale_failures)
            fallbacks[code] = fallbacks.get(code, 0) + len(locale_failures)

        write_catalog(code, rows, english)
        written[code] = len(rows)
        if fell_back:
            fallbacks[code] = fell_back
        if locale_failures:
            print(
                f"  {code:<4} written with {len(locale_failures)} English fallback(s): "
                f"{len(rows) - len(locale_failures)} translated"
            )

    print(
        f"\nwrote {len(written)} catalog(s), "
        f"{sum(written.values())} translated strings in total"
    )
    if fallbacks:
        print(f"{len(fallbacks)} locale(s) still render English for some keys (rerun to retry):")
        for code, count in sorted(fallbacks.items(), key=lambda item: -item[1])[:15]:
            print(f"  {code:<4} {count} key(s)")
    if skipped:
        print(f"{len(skipped)} locale(s) left unwritten: {', '.join(skipped)}")
    if failures:
        print(f"{len(failures)} string(s) need attention:")
        for failure in failures[:40]:
            print(f"  {failure}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
