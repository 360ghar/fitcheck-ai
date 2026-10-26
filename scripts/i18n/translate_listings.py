#!/usr/bin/env python3
"""Translate the App Store listing into every locale App Store Connect accepts.

The English entry in `store/asc/listings.json` is the source. This script fills
every other locale from it, using the Gemini API, and writes the result back.

Why a script rather than 49 hand-written entries:

* The copy changes. A description edit that leaves 49 stale translations is
  worse than no translations, because the storefront quietly shows last
  quarter's offer. Every entry carries `_source_hash`; a changed source makes
  the entry stale, and `--stale-only` (the default) re-translates only those.
* Apple's limits are hard. The script measures every field after translation
  and asks the model again with the over-limit field named, so a submission is
  not rejected at upload time.
* Review state is data. `reviewed` is false for machine output and true only
  after a human edits the entry. The validator surfaces the count, so shipping
  unreviewed copy is a decision rather than an accident.

Usage:
    python3 scripts/i18n/translate_listings.py                 # stale/missing only
    python3 scripts/i18n/translate_listings.py --force          # everything
    python3 scripts/i18n/translate_listings.py --locale hi,ta   # a subset
    python3 scripts/i18n/translate_listings.py --dry-run        # report only

Credentials: GEMINI_API_KEY from the environment, or from the repo `.env` /
`backend/.env` (the same key the backend uses). Nothing is logged.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
LISTINGS = ROOT / "store" / "asc" / "listings.json"
LOCALES = ROOT / "store" / "asc" / "locales.json"
CACHE = ROOT / "store" / "asc" / ".translation-cache.json"

MODEL = os.environ.get("TRANSLATE_MODEL", "gemini-3.1-flash-lite")
ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

# Fallback chain. A single model is not enough: the free tier caps
# `gemini-3.1-flash-lite` at 500 requests per DAY, and translating 49 locales
# several times in one afternoon exhausts it. The API then rejects every call for
# hours with `RESOURCE_EXHAUSTED ... requests per day limit exceeded`, which is
# not a rate limit the backoff below can wait out — the run dies with 22 locales
# left, having produced nothing for seven minutes. Daily quotas are tracked per
# model, so rotating to the next entry restores service immediately.
# `gemini-flash-lite-latest` and `gemini-3-flash-preview` were both verified live
# on the same key while the primary was exhausted.
MODEL_CHAIN = [MODEL] + [
    m.strip()
    for m in os.environ.get(
        "TRANSLATE_MODELS", "gemini-flash-lite-latest,gemini-3-flash-preview"
    ).split(",")
    if m.strip() and m.strip() != MODEL
]

# Seconds to wait after the first 429 from a rate-limited key. Gemini's limit is
# per minute and shared across every translation call, so a whole run shares one
# budget; the retry has to outlast a window rather than a moment.
QUOTA_BACKOFF = int(os.environ.get("TRANSLATE_QUOTA_BACKOFF", "45"))

# Keys proven invalid during this run. A dead key stays dead, and rediscovering
# it per locale wasted a request and masked the real error each time.
_DEAD_KEYS: set[str] = set()

# Models proven spent for the day. A daily cap does not reset mid-run, so
# remembering it stops every subsequent chunk from re-probing a dead model.
_EXHAUSTED_MODELS: set[str] = set()

LIMITS = {
    "name": 30,
    "subtitle": 30,
    "promotionalText": 170,
    "description": 4000,
    "keywords": 100,
    "whatsNew": 4000,
}

FIELDS = ["name", "subtitle", "promotionalText", "description", "keywords", "whatsNew"]

# The fields whose translations this script owns.
#
# `keywords` is deliberately absent. A keyword field is not a translation of the
# English keyword field: the words a Berlin shopper types are not the words a
# Texas shopper types, so `scripts/asc/keyword_planner.py` plans each locale's
# field against that locale's own search behaviour. Including `keywords` here
# would also mean a keyword edit rewrote every locale's source hash and forced a
# full re-translation of 3,000-character descriptions to change eight words.
PROSE_FIELDS = ["name", "subtitle", "promotionalText", "description", "whatsNew"]

# Languages where a literal translation of the brand reads badly or where the
# storefront expects a transliteration. The brand itself never changes.
BRAND = "FitCheck AI"

SYSTEM = """You are a professional App Store localization editor and ASO specialist.

You receive one English App Store listing and translate it into one target language.
Rules, in priority order:

1. Output ONLY a JSON object with exactly the keys: name, subtitle, promotionalText,
   description, keywords, whatsNew. No prose, no markdown fences.
2. `name` keeps the brand "FitCheck AI" unchanged. Translate or transliterate the
   descriptive part after the colon so it reads naturally in the target language.
   HARD BUDGET: the whole name must be at most 30 characters, and "FitCheck AI: "
   already uses 13, so the descriptor after the colon has 17 characters. Aim for
   14. If the natural translation is longer, choose a shorter synonym rather than
   exceeding the budget.
3. `keywords` is a comma-separated list of search terms in the target language, with
   NO spaces after commas. Keep it under 100 characters. Do not repeat any word that
   already appears in the translated name or subtitle. Prefer the words a local user
   would actually type into the App Store, not literal translations of English terms.
4. `subtitle` must be at most 30 characters. Count characters, not bytes: Hindi,
   Tamil, Japanese and other scripts are dense. Shorten the idea rather than
   exceeding the limit. Target 22-26 characters; a two-to-four word phrase is
   correct here, not a sentence.
5. `promotionalText` must be at most 170 characters and must keep the offer intact:
   one month of Pro free, free forever afterwards with 50 AI uploads and 50 outfits
   per month.
6. `description` must be at most 4000 characters. Keep the section structure,
   the bullet points, the exact URLs, and the subscription disclosure. Translate
   everything else naturally. Do not add claims that are not in the source.
7. `whatsNew` must be at most 4000 characters. Keep the version number 1.3.0.
8. Do not translate: URLs, the words "FitCheck AI", "Pro", "Plus", "LinkedIn",
   "Instagram", "iPhone", "iPad", "App Store".
9. Numbers and limits must stay identical: 50, 50, 10, 1 month, 24 hours, 100-piece.
10. Use the register a local app store listing would use: direct, second person,
    no machine-translation stiffness, no honorific inflation.
11. Right-to-left languages (Arabic, Hebrew, Urdu): write natural RTL text. Do not
    insert direction-control characters.
"""


# `repair_parity` translates individual lines, not a whole listing. The default
# SYSTEM prompt describes the listing object, so the model answers with
# name/subtitle/description and every line silently falls back to English. This
# states the key-for-key contract instead.
PARITY_SYSTEM = """You are a professional App Store listing localization editor.

You receive a JSON object under "strings" whose keys are line numbers and whose
values are English listing text, one line per entry.

Rules:
1. Output ONLY a JSON object with exactly the same keys as "strings". No prose,
   no markdown fences, no extra fields.
2. Translate every value into the target language. Never copy the English
   through: an identical value is a failure.
3. Keep a leading "• " bullet character on any line that starts with one.
4. Never translate "FitCheck AI!", "FitCheck AI", "Pro", "Plus", "LinkedIn",
   "Instagram", "iPhone", "iPad" or "App Store".
5. Copy URLs, version numbers and every digit group (50, 50, 10, 1 month,
   24 hours, 100-piece) through unchanged.
6. Do not merge, split, add or drop lines."""


@dataclass
class Result:
    locale: str
    ok: bool
    message: str


def load_env() -> list[str]:
    """Every Gemini key available, best first.

    More than one key lives in this workspace and only one of them is live, so
    the caller rotates on an "API key not valid" response rather than assuming
    the first name it finds is the right one. Keys are never printed.
    """
    keys: list[str] = []

    def add(value: str | None) -> None:
        if value and value not in keys:
            keys.append(value)

    add(os.environ.get("AI_GEMINI_API_KEY"))
    add(os.environ.get("GEMINI_API_KEY"))
    for path in (ROOT / "backend" / ".env", ROOT / ".env"):
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            match = re.match(r"^(AI_GEMINI_API_KEY|GEMINI_API_KEY)=(.+)$", line.strip())
            if match:
                add(match.group(2).strip().strip('"').strip("'"))
    if not keys:
        raise SystemExit(
            "No Gemini key. Set GEMINI_API_KEY, or add it to .env / backend/.env."
        )
    return keys


def call_gemini(
    api_key: str,
    prompt: str,
    retries: int = 3,
    system: str | None = None,
    max_output_tokens: int = 8192,
) -> str:
    """One generateContent call. Defaults to the App Store listing persona.

    `system` exists because the ARB translator has a different job with the same
    transport: without it the model answers as a store-listing writer and returns
    `name`/`subtitle`/`description` instead of the ARB keys it was handed.
    """
    body = {
        "system_instruction": {"parts": [{"text": system or SYSTEM}]},
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.2,
            "responseMimeType": "application/json",
            "maxOutputTokens": max_output_tokens,
        },
    }
    data = json.dumps(body).encode("utf-8")
    last_error = ""
    model_index = 0
    # Start on the first model that still has quota. A daily cap lasts hours, so
    # re-probing a spent model on every call burned one request per chunk (and
    # printed the same "switching" line 9 times) for no chance of success.
    while model_index < len(MODEL_CHAIN) and MODEL_CHAIN[model_index] in _EXHAUSTED_MODELS:
        model_index += 1
    if model_index >= len(MODEL_CHAIN):
        raise RuntimeError(f"daily quota exhausted on every model in {MODEL_CHAIN}")
    # Rotating models consumes an attempt, and a spent chain still needs its
    # normal retries, so give the loop room for both.
    attempts = max(retries, len(MODEL_CHAIN) + 2)
    for attempt in range(attempts):
        model = MODEL_CHAIN[model_index]
        request = urllib.request.Request(
            ENDPOINT.format(model=model),
            data=data,
            headers={
                "Content-Type": "application/json",
                "x-goog-api-key": api_key,
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                payload = json.loads(response.read().decode("utf-8"))
            candidates = payload.get("candidates") or []
            if not candidates:
                last_error = f"no candidates: {json.dumps(payload)[:300]}"
            else:
                parts = (candidates[0].get("content") or {}).get("parts", [])
                text = "".join(part.get("text", "") for part in parts).strip()
                if text:
                    return text
                last_error = f"empty text, finishReason={candidates[0].get('finishReason')}"
        except urllib.error.HTTPError as error:
            # Read the WHOLE body for classification, then keep a short slice for
            # display. Gemini puts the telling phrase late: in a 1,663-character
            # daily-quota error, "requests per day" starts at index 462 and the
            # `PerDay` quota id at 1,313. Classifying on a 400-character prefix
            # missed both, so an exhausted *daily* quota was retried as if it were
            # a per-minute one — the run slept 45s, 90s, 135s, 180s and then died.
            body_text = error.read().decode("utf-8", errors="ignore")
            detail = body_text[:400]
            daily_exhausted = "per day" in body_text.lower() or "perday" in body_text.lower()
            last_error = f"HTTP {error.code} on {model}: {detail}"
            if error.code in (400, 403, 404):
                # 404 on a model name means the chain entry does not exist for
                # this key. That is worth one rotation, not an abort.
                if error.code == 404 and model_index + 1 < len(MODEL_CHAIN):
                    model_index += 1
                    print(
                        f"    {model} unavailable, trying {MODEL_CHAIN[model_index]}",
                        file=sys.stderr,
                        flush=True,
                    )
                    continue
                break
            if error.code == 429:
                # Two different 429s hide behind one status code. A per-DAY cap
                # cannot be waited out inside a run and is tracked per model, so
                # rotate models immediately. A per-minute cap is shared and does
                # need the clock.
                if daily_exhausted:
                    _EXHAUSTED_MODELS.add(model)
                    if model_index + 1 < len(MODEL_CHAIN):
                        model_index += 1
                        print(
                            f"    daily quota exhausted on {model}; "
                            f"switching to {MODEL_CHAIN[model_index]}",
                            file=sys.stderr,
                            flush=True,
                        )
                        continue
                    # Every model in the chain is spent. Backing off is the
                    # only remaining option, and it will take hours.
                    hint = ""
                    marker = re.search(r"retry in ([0-9hms.]+)", body_text, re.I)
                    if marker:
                        hint = f" (retry in {marker.group(1)})"
                    last_error = (
                        f"daily quota exhausted on every model in {MODEL_CHAIN}{hint}"
                    )
                    break
                # A per-minute quota needs minutes, not seconds. The generic
                # `2 ** attempt` backoff (1s, 2s, 4s) gave up while the limit was
                # still counting down, so a whole run died after translating 41
                # of 49 locales. Gemini's limit is per minute, so wait past a
                # full window, and honour Retry-After when it says to wait longer.
                wait = QUOTA_BACKOFF * (attempt + 1)
                try:
                    announced = int(error.headers.get("Retry-After", 0))
                    if announced > wait:
                        wait = announced
                except (TypeError, ValueError, AttributeError):
                    pass
                print(
                    f"    429 quota hit, waiting {wait}s "
                    f"(attempt {attempt + 1}/{attempts})",
                    file=sys.stderr,
                    flush=True,
                )
                time.sleep(wait)
                continue
        except Exception as error:  # noqa: BLE001 - retried below, reported after
            last_error = str(error)
        time.sleep(2 ** attempt)
    raise RuntimeError(last_error)


def parse_json(text: str) -> dict:
    """Decode exactly one JSON object from a model reply.

    Slicing from the first `{` to the LAST `}` assumes the reply holds a single
    object. A model that repeats its answer does not: it emits `{...}\\n{...}`,
    and that slice becomes two adjacent objects, so `json.loads` fails with
    `Extra data: line 9 column 1`. Seven locales (he, gu-IN, or-IN, ta-IN, ja,
    vi, ca) died that way in one run. `raw_decode` stops at the end of the first
    complete value and ignores whatever trails it.
    """
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```[a-zA-Z]*\n?", "", cleaned)
        cleaned = re.sub(r"```$", "", cleaned).strip()
    start = cleaned.find("{")
    if start == -1:
        raise ValueError("response is not a JSON object")
    value, _end = json.JSONDecoder().raw_decode(cleaned[start:])
    if not isinstance(value, dict):
        raise ValueError(f"expected a JSON object, got {type(value).__name__}")
    return value


def source_hash(listing: dict) -> str:
    payload = json.dumps({field: listing.get(field, "") for field in PROSE_FIELDS}, sort_keys=True)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:16]


def over_limit(entry: dict) -> list[str]:
    problems = []
    for field, limit in LIMITS.items():
        value = entry.get(field) or ""
        if len(value) > limit:
            problems.append(f"{field} is {len(value)} chars, limit {limit}")
    return problems


def repair_field(
    api_key: str,
    english_value: str,
    locale: dict,
    field: str,
    limit: int,
    *,
    feedback: str,
) -> str:
    """Retranslate one over-limit field with an explicit character budget.

    Narrow on purpose. `subtitle` is the field that trips this: Apple gives it
    30 characters, and a faithful Telugu or Odia rendering of "AI Closet,
    Try-On & Outfits" is longer than that. Telling the model the exact budget
    and asking for a shorter idea works where a whole-listing retry does not.
    """
    instruction = {
        "field": field,
        "target_language": locale["english"],
        "native_name": locale["native"],
        "english_source": english_value,
        "previous_attempt": feedback,
        "hard_character_limit": limit,
        "task": (
            f"Translate `english_source` into {locale['english']} and return ONLY a JSON "
            f'object of the form {{"{field}": "..."}}. '
            f"The result MUST be at most {limit} characters long, counting every "
            "character including spaces and punctuation. Shorter is better: a "
            "three- or four-word phrase that a local user would recognise beats a "
            "complete sentence that has to be truncated. "
            "Keep the brand name 'FitCheck AI' unchanged if it appears. "
            "Do not add a trailing period."
        ),
    }
    raw = call_gemini(api_key, json.dumps(instruction, ensure_ascii=False, indent=2))
    parsed = parse_json(raw)
    value = parsed.get(field)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"repair of {field} returned nothing")
    return value.strip()


def translate(api_keys: list[str], english: dict, locale: dict) -> dict:
    prompt = json.dumps(
        {
            "target_language": locale["english"],
            "native_name": locale["native"],
            "app_store_locale": locale["asc"],
            "brand_must_remain": BRAND,
            "english_listing": {field: english.get(field, "") for field in FIELDS},
        },
        ensure_ascii=False,
        indent=2,
    )
    # Retries are per-locale, not per-key: a per-minute quota is spent by the
    # run, not by the key, so retrying a second key immediately burns the same
    # exhausted window. `call_gemini` waits out the window internally when it
    # sees a 429.
    entry = None
    last_error = None
    for attempt in range(3):
        for api_key in list(api_keys):
            if api_key in _DEAD_KEYS:
                continue
            try:
                raw = call_gemini(api_key, prompt, retries=3)
                # Remember which key worked so the next locale starts there.
                if api_key in api_keys:
                    api_keys.remove(api_key)
                    api_keys.insert(0, api_key)
                entry = parse_json(raw)
                break
            except RuntimeError as error:
                last_error = error
                if "API key not valid" in str(error):
                    # A dead key answers instantly; leaving it in the rotation
                    # makes the next locale pay for the same discovery and, worse,
                    # makes its 400 mask a real quota 429 in the final error.
                    _DEAD_KEYS.add(api_key)
                    print(
                        "    one Gemini key is not valid; skipping it for the rest of the run",
                        file=sys.stderr,
                        flush=True,
                    )
                    continue
                break
        if entry is not None:
            break
        if "429" not in str(last_error):
            break
        wait = QUOTA_BACKOFF * 2 * (attempt + 1)
        print(
            f"    quota still exhausted, waiting {wait}s before retrying {locale['asc']}",
            file=sys.stderr,
            flush=True,
        )
        time.sleep(wait)
    if entry is None:
        raise RuntimeError(str(last_error))

    missing = [field for field in FIELDS if not isinstance(entry.get(field), str) or not entry[field].strip()]
    if missing:
        raise ValueError(f"missing fields: {', '.join(missing)}")

    problems = over_limit(entry)
    if problems:
        shortened = call_gemini(
            api_keys[0],
            prompt
            + "\n\nThe previous attempt exceeded these limits:\n"
            + "\n".join(f"- {problem}" for problem in problems)
            + "\nRewrite EVERY field so all limits are satisfied. Keep the meaning. "
            "For `subtitle`, aim for 24 characters to leave headroom. Output the full JSON again.",
        )
        entry = parse_json(shortened)
        problems = over_limit(entry)

    # A whole-listing rewrite is the wrong tool for one stubborn field: the
    # model re-does 3,000 characters of description to save four characters of
    # subtitle, and the retry itself can drift. Repair the over-limit fields
    # one at a time instead, with the budget stated as a hard number.
    for _ in range(2):
        if not problems:
            break
        for problem in problems:
            field = problem.split(" ", 1)[0]
            if field not in LIMITS or field == "name":
                continue
            entry[field] = repair_field(
                api_keys[0],
                english[field],
                locale,
                field,
                LIMITS[field],
                feedback=entry[field],
            )
        problems = over_limit(entry)

    # `name` is the one field with no acceptable partial answer: Apple rejects
    # the submission outright. A localized descriptor that will not fit is
    # dropped in favour of the English name, which is known to fit and is
    # already the brand. Every other field is worth failing loudly over,
    # because silently shortening a description loses the offer.
    if len(entry.get("name", "")) > LIMITS["name"]:
        fallback = english["name"]
        if len(fallback) <= LIMITS["name"]:
            entry["name"] = fallback
            problems = [problem for problem in problems if not problem.startswith("name ")]
        else:
            raise ValueError("name is over 30 chars and the English source is too")

    if problems:
        raise ValueError("; ".join(problems))

    # Length limits are not the only way a description degrades. A translation
    # can be within 4,000 characters and still have dropped half the feature
    # bullets — `or-IN` shipped at 3 of 9 bullets and 17% of the English length,
    # losing the auto-renewal disclosure Guideline 3.1.2 requires. Length alone
    # never caught it, so structure is checked explicitly and repaired per line.
    lost = parity_gaps(entry, english)
    if lost:
        for field in [problem.split(" ", 1)[0] for problem in lost]:
            entry[field] = repair_parity(api_keys[0], english[field], entry[field], locale)
        remaining = parity_gaps(entry, english)
        if remaining:
            raise ValueError("lost structure: " + "; ".join(remaining))

    entry["reviewed"] = False
    entry["_translated_by"] = MODEL
    entry["_source_hash"] = source_hash(english)
    return entry


def parity_gaps(entry: dict, english: dict, allow_english: bool = False) -> list[str]:
    """Fields whose translation dropped bullets, paragraphs, or the language.

    Structure and language are different failures and both ship broken. A
    truncated description renders fine and quietly omits the auto-renewal
    disclosure; a description identical to the English one renders fine and is
    simply not translated, which is what a per-line repair produces when it
    copies the source through. Neither is visible from a character count.

    `allow_english` is for `en-GB`/`en-AU`/`en-CA`, where matching the source is
    the correct output rather than a defect.
    """
    gaps: list[str] = []
    for field in ("description", "whatsNew"):
        source = english.get(field)
        result = entry.get(field)
        if not isinstance(source, str) or not isinstance(result, str):
            continue
        if not result.strip():
            gaps.append(f"{field} is empty")
            continue
        if not allow_english and result.strip() == source.strip():
            gaps.append(f"{field} is still the English source")
            continue
        wanted = sum(1 for line in source.split("\n") if line.strip().startswith("•"))
        found = sum(1 for line in result.split("\n") if line.strip().startswith("•"))
        if found < wanted:
            gaps.append(f"{field} has {found} of {wanted} bullets")
    return gaps


def repair_parity(api_key: str, english: str, current: str, locale: dict) -> str:
    """Re-translate a long field line by line, keeping the source's exact shape.

    Translating the whole string again and hoping for parity is what produced
    the truncations in the first place. One call per line makes the output have
    exactly the source's lines, blank lines and bullets by construction.
    """
    lines = english.split("\n")
    # Translate every non-empty source line. Reusing the existing translation by
    # index is wrong precisely when the field is truncated: the lines have
    # already shifted, so "index N has text" does not mean "line N was
    # translated". That mistake made an earlier version of this repair a no-op
    # that reported success.
    wanted = {
        str(index): line
        for index, line in enumerate(lines)
        if line.strip()
    }
    if not wanted:
        return current
    prompt = json.dumps(
        {
            "task": (
                f"Translate each value into {locale['english']} ({locale['native']}). "
                "Output a JSON object with exactly the same keys. Do not return a "
                "listing object, do not add fields, do not rename keys."
            ),
            "rules": (
                "Keep the leading bullet character `• ` on lines that start with it. "
                "Preserve URLs, version numbers, and the numbers 50, 50, 10, 1 month, "
                "24 hours, 100-piece exactly. Do not translate: FitCheck AI, Pro, Plus, "
                "LinkedIn, Instagram, iPhone, iPad, App Store. Do not merge or split "
                "lines. A value copied through in English is a failure."
            ),
            "strings": wanted,
        },
        ensure_ascii=False,
        indent=2,
    )
    # `call_gemini` defaults to the store-listing persona, which answers with
    # name/subtitle/description no matter what it is handed — that silently
    # produced English-through-a-round-trip. This overrides it with the plain
    # "same keys in, same keys out" contract.
    translated = parse_json(call_gemini(api_key, prompt, system=PARITY_SYSTEM))

    out: list[str] = []
    # Track positions, not values: the description repeats lines (blank-only
    # section headers aside, two bullets can share text), and `out.index(value)`
    # then rewrites the wrong copy or raises once the first copy is replaced.
    untranslated: list[tuple[int, str]] = []
    for index, source in enumerate(lines):
        if not source.strip():
            out.append("")
            continue
        value = translated.get(str(index))
        if not isinstance(value, str) or not value.strip() or value.strip() == source.strip():
            untranslated.append((index, source))
            out.append(source)
            continue
        out.append(value)

    if untranslated:
        # Short all-caps section headings ("TRY PRO FREE FOR 1 MONTH") are the
        # lines a batch call drops most often, and they are also the lines that
        # carry the offer. Retry just those in one call before giving up.
        retry_wanted = {str(slot): source for slot, (_index, source) in enumerate(untranslated)}
        retry_prompt = json.dumps(
            {
                "task": (
                    f"Translate each value into {locale['english']} "
                    f"({locale['native']}). These are short App Store listing "
                    "headings. Output a JSON object with exactly the same keys. "
                    "Translate every value; do not copy the English through."
                ),
                "strings": retry_wanted,
            },
            ensure_ascii=False,
            indent=2,
        )
        retried = parse_json(call_gemini(api_key, retry_prompt, system=PARITY_SYSTEM))
        still: list[str] = []
        for slot, (position, source) in enumerate(untranslated):
            value = retried.get(str(slot))
            if isinstance(value, str) and value.strip() and value.strip() != source.strip():
                out[position] = value
            else:
                still.append(source)
        if still:
            # Reporting success while shipping English is the failure this whole
            # function exists to prevent, so say so instead of writing a hole.
            raise RuntimeError(
                f"{len(still)} line(s) came back empty or untranslated, "
                f"e.g. {still[0][:60]!r}"
            )
    return "\n".join(out)



def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true", help="retranslate even if current")
    parser.add_argument("--locale", default="", help="comma-separated ASC codes")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--sleep", type=float, default=1.0, help="pause between calls")
    args = parser.parse_args()

    data = json.loads(LISTINGS.read_text(encoding="utf-8"))
    locales = json.loads(LOCALES.read_text(encoding="utf-8"))
    english = data["en-US"]
    wanted_codes = {code.strip() for code in args.locale.split(",") if code.strip()}

    cache = {}
    if CACHE.exists():
        cache = json.loads(CACHE.read_text(encoding="utf-8"))

    api_keys = [] if args.dry_run else load_env()
    current_hash = source_hash(english)
    results: list[Result] = []

    targets = [
        locale
        for locale in locales["locales"]
        if locale["asc"] != locales["default"]
        and (not wanted_codes or locale["asc"] in wanted_codes)
    ]

    for locale in targets:
        code = locale["asc"]
        existing = data.get(code)
        fresh = (
            existing
            and existing.get("_source_hash") == current_hash
            and not args.force
        )
        # "Current" only means the source has not changed since this entry was
        # written. An entry can be current and still be missing half the
        # description, so structure is part of freshness: a locale with parity
        # gaps is repaired even though its hash matches.
        allow_english = (locale.get("english") or "").lower().startswith("english")
        gaps = parity_gaps(existing, english, allow_english) if existing else []
        if fresh and not gaps:
            results.append(Result(code, True, "current"))
            continue
        if fresh and gaps:
            if args.dry_run:
                results.append(Result(code, True, "would repair: " + "; ".join(gaps)))
                continue
            if not api_keys:
                results.append(Result(code, False, "needs repair but no API key"))
                continue
            repaired = dict(existing)
            try:
                for field in [problem.split(" ", 1)[0] for problem in gaps]:
                    repaired[field] = repair_parity(
                        api_keys[0], english[field], existing.get(field, ""), locale
                    )
            except Exception as error:  # noqa: BLE001 - one locale must not stop the run
                results.append(Result(code, False, str(error)[:200]))
                continue
            remaining = parity_gaps(repaired, english)
            if remaining:
                results.append(Result(code, False, "still truncated: " + "; ".join(remaining)))
                continue
            repaired["reviewed"] = False
            data[code] = repaired
            results.append(Result(code, True, "repaired structure"))
            # Persist immediately: this branch does not fall through to the
            # translate path's write, and a repair that is only held in memory
            # reports success while changing nothing on disk.
            LISTINGS.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )
            continue

        if args.dry_run:
            results.append(Result(code, True, "would translate"))
            continue

        cached = cache.get(code)
        if cached and cached.get("_source_hash") == current_hash and not args.force:
            data[code] = cached
            results.append(Result(code, True, "from cache"))
            continue

        try:
            entry = translate(api_keys, english, locale)
        except Exception as error:  # noqa: BLE001 - one locale must not stop the run
            results.append(Result(code, False, str(error)[:200]))
            continue

        # A planned keyword field outranks a translated one. The planner chose
        # words this storefront's users actually search; this script can only
        # approximate that by translating English ones. Re-translating the prose
        # must not quietly throw the plan away.
        if existing and existing.get("_keywords_planned"):
            entry["keywords"] = existing["keywords"]
            entry["_keywords_planned"] = True

        data[code] = entry
        cache[code] = entry
        results.append(Result(code, True, "translated"))
        # Written after every locale so an interrupted run resumes instead of
        # repeating API calls.
        LISTINGS.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        time.sleep(args.sleep)

    ok = sum(1 for result in results if result.ok)
    for result in results:
        if not result.ok:
            print(f"FAIL {result.locale}: {result.message}")
    print(f"\n{ok}/{len(results)} locales current")
    if args.dry_run:
        print("dry run: nothing written")
    return 0 if ok == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
