#!/usr/bin/env python3
"""Translate the Flutter ARB catalogs into every supported locale.

`flutter/lib/l10n/app_en.arb` is the source. Translations live in
`flutter/lib/l10n/.translations.json`, keyed by locale and then by ARB key, each
row carrying the hash of the English text it was produced from. The `.arb` files
are generated from that cache.

That indirection is the point: the ARB files are build artifacts, and a reworded
English string re-translates only itself instead of invalidating a locale. It
also means an interrupted run resumes instead of paying for every key again.

Placeholders are the failure mode that matters. `{uploads}`, `{plan}` and a
`{count, plural, ...}` block must survive translation; a locale that drops one
renders a literal brace to the user or throws inside `intl`. Every translation is
compared against the English ICU shape, a batch that fails is retried one key at
a time, and a locale that still has a bad string is reported instead of written.

Usage:
    python3 scripts/i18n/translate_arb.py                 # missing/stale only
    python3 scripts/i18n/translate_arb.py --force
    python3 scripts/i18n/translate_arb.py --locale hi,ta
    python3 scripts/i18n/translate_arb.py --dry-run
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

from check_locales import icu_problems, icu_shape  # noqa: E402  - one ICU parser, not two
from inventory import FALLBACK_BASES  # noqa: E402  - shared with check_locales
from translate_listings import MODEL, call_gemini, load_env  # noqa: E402

# The transport, swapped by `--provider`. Gemini's free tier is 500 requests per
# day per model and a full pass needs ~1,000, so the catalogs cannot finish in a
# day on it; Agnes allows 1,500 per 5 hours. Both satisfy the same signature.
MODEL_CALL = call_gemini

ROOT = Path(__file__).resolve().parents[2]
L10N = ROOT / "flutter" / "lib" / "l10n"
SOURCE = L10N / "app_en.arb"
CACHE = L10N / ".translations.json"
LOCALES = ROOT / "store" / "asc" / "locales.json"

# One request per chunk. The old script sent all ~144 keys in a single call,
# which for a non-Latin script overflows `maxOutputTokens` and returns truncated
# JSON — the whole locale then failed and nothing was written.
CHUNK = 30


# A catalog below this share of the English keys is not shipped at all: users
# then get consistent English instead of a screen that switches language
# mid-sentence. Above it, the few stragglers keep the English value.
COVERAGE_FLOOR = 0.9

SYSTEM = """You are a professional mobile-app localization editor.

You receive a JSON object of English UI strings and translate every value into the
target language.

Rules:
1. Output ONLY a JSON object with exactly the same keys as the input. No prose,
   no markdown fences.
2. Never translate the brand "FitCheck AI", the plan names "Pro" and "Plus", or
   platform names (iPhone, iPad, App Store, Google Play).
3. Preserve ICU placeholders exactly: any token like {uploads}, {plan}, {price}
   must appear unchanged in the translation. Do not add, remove or rename them.
4. Preserve ICU plural syntax exactly. For a value like
   "{count, plural, =1{one item} other{{count} items}}" translate only the text
   inside the braces, keep the structure, keep the `other` branch, and keep
   {count} where it appears. You may add the plural categories your language
   needs (zero, one, two, few, many) but never remove `other`.
5. Keep UI copy short. These strings sit in buttons, tabs, list rows and dialogs.
   A translation that is twice as long as the English will overflow.
6. Use the vocabulary a local user expects in a fashion and wardrobe app, not a
   literal word-for-word rendering.
7. Tab labels ("Home", "Closet", "Outfits", "More") must be one or two words.
8. In right-to-left languages, write natural RTL text; do not insert direction
   control characters.
9. Do not add punctuation the English does not have, and do not add emoji.
10. Single-word taxonomy labels ("Tops", "Casual", "Navy") are the vocabulary of
    a fashion app: use the word a shopping app in that language uses.
"""


def source_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()[:12]


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
    keys: list[str], english: dict[str, str], locale: dict, api_keys: list[str], retries: int = 4
) -> dict:
    """One model call for one chunk of keys, rotating keys on an invalid key."""
    prompt = json.dumps(
        {
            "target_language": locale["english"],
            "native_name": locale["native"],
            "app_store_locale": locale["asc"],
            "note": "Translate the values. Keys are identifiers and stay unchanged.",
            "strings": {key: english[key] for key in keys},
        },
        ensure_ascii=False,
        indent=2,
    )
    last_error: Exception | None = None
    api_key = api_keys[0]
    for attempt in range(retries):
        try:
            # `retries=1`: `call_gemini` has its own 45/90/135s quota backoff.
            # Running it under this loop turned one 429 into a nine-minute stall
            # and then a failed locale; one attempt here, and the schedule below
            # owns the wait.
            raw = MODEL_CALL(
                api_key,
                prompt,
                retries=1,
                system=SYSTEM,
                max_output_tokens=8192,
            )
        except RuntimeError as error:
            last_error = error
            message = str(error)
            # The whole model chain is spent for the day. Sleeping cannot help:
            # the limit resets in hours and every model is already exhausted, so
            # fail fast with the retry hint instead of burning four backoffs.
            if "daily quota exhausted on every model" in message:
                raise
            if "API key not valid" in message:
                # A dead key: move to the next one and try again.
                if len(api_keys) == 1:
                    raise
                api_keys.remove(api_key)
                api_key = api_keys[0]
                continue
            # The two failures need different waits. 503 is the model being
            # busy for a moment: a short pause and the same chunk goes through.
            # 429 is the per-minute quota, so the wait has to clear the window
            # or every retry lands inside the same exhausted minute.
            if "503" in message or "500" in message:
                wait = 10 * (attempt + 1)
            else:
                wait = 30 * (2**attempt)
            print(
                f"    · {locale['asc']}: waiting {wait}s, attempt {attempt + 1}/{retries} "
                f"({message[:80]})",
                file=sys.stderr,
            )
            time.sleep(wait)
            continue
        api_keys.remove(api_key)
        api_keys.insert(0, api_key)
        return parse_response(raw)
    raise RuntimeError(str(last_error) if last_error else "no usable API key")


def translate_chunk(
    keys: list[str],
    english: dict[str, str],
    locale: dict,
    api_keys: list[str],
    sleep: float,
) -> tuple[dict[str, str], list[str]]:
    """Translate a chunk, halving it on transport errors so one bad key is isolated.

    Returns the good translations and the keys that could not be translated.
    """
    try:
        time.sleep(sleep)
        result = ask(keys, english, locale, api_keys)
    except (RuntimeError, ValueError, json.JSONDecodeError) as error:
        if len(keys) == 1:
            print(f"    ! {locale['asc']}.{keys[0]}: {error}", file=sys.stderr)
            return {}, list(keys)
        # Halving isolates ONE bad key: a dropped placeholder, a value the model
        # refuses. A spell of daily quota is not per-key, so splitting turned one
        # 60-key chunk into 119 doomed requests and buried the real message under
        # thousands of lines of noise. Nothing below can succeed, so stop.
        if "daily quota exhausted" in str(error):
            print(
                f"    ! {locale['asc']}: daily quota spent, skipping {len(keys)} key(s)",
                file=sys.stderr,
            )
            return {}, list(keys)
        print(f"    ~ {locale['asc']}: chunk of {len(keys)} failed ({error}); splitting", file=sys.stderr)
        midpoint = len(keys) // 2
        left, left_bad = translate_chunk(keys[:midpoint], english, locale, api_keys, sleep)
        right, right_bad = translate_chunk(keys[midpoint:], english, locale, api_keys, sleep)
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


def validate(key: str, translated: str, english_value: str) -> str | None:
    """Why this value is unusable, or None when it is fine."""
    expected_names, expected_blocks = icu_shape(english_value)
    names, blocks = icu_shape(translated)
    if names != expected_names:
        return (
            f"placeholder mismatch (expected {sorted(expected_names)}, got {sorted(names)})"
        )
    if blocks != expected_blocks:
        return f"ICU block mismatch (expected {sorted(expected_blocks)}, got {sorted(blocks)})"
    if translated.count("{") != translated.count("}"):
        return "unbalanced braces"
    # Shape parity is not enough to build: a message can carry the right
    # placeholders and still be unparseable, which fails `flutter gen-l10n` for
    # the entire catalog rather than for one string.
    problems = icu_problems(translated)
    if problems:
        return "; ".join(problems)
    return None


def translate_locale(
    locale: dict, english: dict[str, str], cache: dict, api_keys: list[str], sleep: float
) -> tuple[dict, list[str], list[str]]:
    """Fill one locale. Returns (rows, failures, fell_back_to_english)."""
    existing = cache.get(locale["dart"], {})
    pending = pending_keys(english, existing)
    if not pending:
        return existing, [], []

    print(f"  {locale['asc']:<9} {len(pending)} string(s)")

    good: dict[str, str] = {}
    bad: list[str] = []
    for start in range(0, len(pending), CHUNK):
        chunk = pending[start : start + CHUNK]
        translated, failed = translate_chunk(chunk, english, locale, api_keys, sleep)
        good.update(translated)
        bad.extend(failed)

    # A value that fails the ICU check gets one focused retry of its own: with a
    # single string in front of it the model reliably fixes a dropped `{plan}`.
    failures: list[str] = []
    for key in list(good):
        problem = validate(key, good[key], english[key])
        if problem is None:
            continue
        print(f"    ~ {locale['asc']}.{key}: {problem}; retrying alone", file=sys.stderr)
        retry, retry_bad = translate_chunk([key], english, locale, api_keys, sleep)
        if key in retry and validate(key, retry[key], english[key]) is None:
            good[key] = retry[key]
        else:
            failures.append(f"{locale['asc']}.{key}: {problem}")
            good.pop(key, None)
        bad.extend(retry_bad)

    for key in bad:
        failures.append(f"{locale['asc']}.{key}: no translation returned")

    for key, value in good.items():
        existing[key] = {
            "value": value,
            "_src": source_hash(english[key]),
            "_model": MODEL,
        }

    fell_back = [
        key
        for key in english
        if not existing.get(key) or existing[key].get("_src") != source_hash(english[key])
    ]
    return existing, failures, fell_back


def write_arb(dart_code: str, translations: dict, english: dict[str, str], template: dict) -> Path:
    data: dict[str, object] = {"@@locale": dart_code}
    for key, value in english.items():
        row = translations.get(key)
        data[key] = row["value"] if row and row.get("value") else value
    # Metadata blocks explain keys to translators and are never translated. They
    # are duplicated into every catalog so a translator opening `app_hi.arb`
    # sees the same context as the English source. `@@locale` is written above
    # and must not be copied: doing so labelled all 49 catalogs "en", which
    # `flutter gen-l10n` rejects ("@@locale and filename do not match").
    for key, value in template.items():
        if key.startswith("@") and key != "@@locale":
            data[key] = value
    path = L10N / f"app_{dart_code}.arb"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def repair_message(value: str) -> str:
    """Drop plural branches that shadow a category the same block already has.

    Models add `=1{…}` alongside `one{…}` often. Both mean "exactly one", so the
    translation is right and only the encoding is unbuildable: gen-l10n warns
    that `=1` is overridden and refuses the whole catalog. Removing the
    redundant exact branch keeps the meaning and needs no new API call — which
    matters when the quota is spent and a retranslation is hours away.
    """
    for head, body_start, body_end in _icu_blocks(value):
        inner = value[body_start + 1 : body_end]
        if ", plural," not in inner and ", select," not in inner:
            continue
        body = inner.split(",", 2)[2]
        branches = _branch_spans(body)
        if branches is None:
            continue
        present = {selector for selector, _s, _e in branches}
        redundant = [
            (start, end)
            for selector, start, end in branches
            if selector in ("=1", "=2")
            and {1: "one", 2: "two"}[int(selector[1:])] in present
        ]
        # Only the first block with a redundant branch is touched per call; the
        # caller loops until `icu_problems` is clean, which re-derives spans.
        if redundant:
            rebuilt = body
            for start, end in reversed(redundant):
                rebuilt = rebuilt[:start] + rebuilt[end:]
            head, kind = inner.split(",", 2)[0], inner.split(",", 2)[1]
            rebuilt = rebuilt.lstrip(" ,\t\n")
            rebuilt = re.sub(r",[ \t]{2,}", ", ", rebuilt)
            return value[:body_start + 1] + head + ", " + kind + ", " + rebuilt + value[body_end:]
    return value


def _icu_blocks(value: str) -> list[tuple[str, int, int]]:
    """Top-level `{` groups as (head, index_of_open, index_of_close)."""
    blocks: list[tuple[str, int, int]] = []
    index = 0
    while index < len(value):
        if value[index] != "{":
            index += 1
            continue
        depth, start = 0, index
        while index < len(value):
            if value[index] == "{":
                depth += 1
            elif value[index] == "}":
                depth -= 1
                if depth == 0:
                    break
            index += 1
        blocks.append((value[start + 1 :].split(",", 1)[0].strip(), start, index))
        index += 1
    return blocks


def _branch_spans(body: str) -> list[tuple[str, int, int]] | None:
    """(selector, start, end) for each `selector{message}` in a plural body."""
    spans: list[tuple[str, int, int]] = []
    index = 0
    while index < len(body):
        while index < len(body) and body[index] in " ,\t\n":
            index += 1
        if index >= len(body):
            break
        start = index
        while index < len(body) and body[index] not in "{\t\n ":
            index += 1
        selector = body[start:index].strip()
        while index < len(body) and body[index] in " \t\n,":
            index += 1
        if index >= len(body) or body[index] != "{":
            return None
        depth, open_at = 0, index
        while index < len(body):
            if body[index] == "{":
                depth += 1
            elif body[index] == "}":
                depth -= 1
                if depth == 0:
                    break
            index += 1
        if depth != 0:
            return None
        index += 1
        spans.append((selector, start, index))
        _ = open_at
    return spans


def repair_catalogs(cache: dict, english: dict[str, str], template: dict) -> int:
    """Make cached values buildable: normalize what can be, drop what cannot."""
    dropped = 0
    complete: list[str] = []
    low_coverage: list[tuple[str, int, int]] = []
    for code, rows in cache.items():
        if not isinstance(rows, dict):
            continue
        if not code.startswith("en_"):
            for key in list(rows):
                row = rows.get(key)
                if not isinstance(row, dict) or not isinstance(row.get("value"), str):
                    continue
                value = row["value"]
                if not icu_problems(value):
                    continue
                fixed = value
                for _ in range(4):  # one block per pass, then re-check
                    candidate = repair_message(fixed)
                    if candidate == fixed:
                        break
                    fixed = candidate
                if fixed != value and not icu_problems(fixed):
                    row["value"] = fixed
                    print(f"  repaired {code}.{key}")
                    continue
                # Unrecoverable without the model: uncache it so the next run
                # retranslates, and drop the value rather than ship an ARB that
                # does not compile.
                print(f"  dropped  {code}.{key}: {icu_problems(value)[0]}")
                rows.pop(key, None)
                dropped += 1
        covered = sum(1 for key in english if isinstance(rows.get(key), dict))
        path = L10N / f"app_{code}.arb"
        # Always write, even when coverage is low. This used to delete the
        # catalog below the floor, on the theory that a missing catalog gives
        # cleaner English than a mixed screen. That reasoning breaks the moment
        # the template grows: adding 423 keys dropped every catalog from 100% to
        # 68%, and one quota-exhausted run deleted 46 of 50 languages outright.
        # The files were untracked, so the translations survived only in the
        # cache. A mixed screen is a far smaller problem than a language that
        # disappears from the picker, so low coverage is reported, never
        # enforced by deletion.
        write_arb(code, rows, english, template)
        complete.append(code)
        if english and covered < len(english) * COVERAGE_FLOOR:
            low_coverage.append((code, covered, len(english)))

    # The language-only fallback `flutter gen-l10n` needs (see FALLBACK_BASES).
    for base, source_code in FALLBACK_BASES.items():
        if source_code in complete:
            data = json.loads((L10N / f"app_{source_code}.arb").read_text(encoding="utf-8"))
            data["@@locale"] = base
            (L10N / f"app_{base}.arb").write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )
            print(f"  {base:<9} copied from {source_code} (language fallback for gen-l10n)")
    if low_coverage:
        print(
            f"  {len(low_coverage)} catalog(s) still below "
            f"{COVERAGE_FLOOR:.0%} translated; kept and filled with English:"
        )
        for code, covered, total in sorted(low_coverage):
            print(f"    {code:9} {covered}/{total} ({covered / total:.0%})")
    return dropped


def main() -> int:
    global CHUNK

    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--locale", default="")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--repair", action="store_true")
    parser.add_argument("--sleep", type=float, default=0.2)
    parser.add_argument("--batch", type=int, default=CHUNK)
    parser.add_argument(
        "--provider",
        default="gemini",
        choices=("gemini", "agnes"),
        help="gemini (default) or agnes; both fill the same cache",
    )
    args = parser.parse_args()

    CHUNK = max(1, args.batch)

    # Agnes ignores the key list and reads AGNES_AI_API_KEY itself, so the
    # rotation below is a harmless no-op with one placeholder entry.
    global MODEL_CALL
    if args.provider == "agnes":
        from agnes_client import call_agnes

        MODEL_CALL = call_agnes

    template = json.loads(SOURCE.read_text(encoding="utf-8"))
    english = {key: value for key, value in template.items() if not key.startswith("@")}
    locales = json.loads(LOCALES.read_text(encoding="utf-8"))["locales"]
    wanted = {code.strip() for code in args.locale.split(",") if code.strip()}

    cache: dict = {"_comment": "Generated by scripts/i18n/translate_arb.py. Do not edit by hand."}
    if CACHE.exists():
        cache = json.loads(CACHE.read_text(encoding="utf-8"))

    if args.force:
        for entry in cache.values():
            if isinstance(entry, dict):
                for row in entry.values():
                    if isinstance(row, dict):
                        row.pop("_src", None)

    if args.repair:
        # Rewrites catalogs from the cache without calling the model, so it works
        # on a spent quota. Anything it cannot fix is uncached for the next run.
        dropped = repair_catalogs(cache, english, template)
        CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"repair done: {dropped} value(s) uncached for retranslation")
        return 0

    selected = [
        locale
        for locale in locales
        if locale["dart"] != "en"
        and (not wanted or locale["dart"] in wanted or locale["asc"] in wanted)
    ]

    if args.dry_run:
        total = 0
        for locale in selected:
            stale = pending_keys(english, cache.get(locale["dart"], {}))
            total += len(stale)
            print(f"{locale['asc']:9} {len(stale):3} string(s) to translate")
        print(f"\n{len(selected)} locale(s), {total} string(s), {len(english)} keys in the template")
        return 0

    api_keys = load_env() if (selected and args.provider == "gemini") else (["agnes"] if selected else [])
    failures: list[str] = []
    written: dict[str, int] = {}
    skipped: list[str] = []
    fallbacks: dict[str, int] = {}
    quota_stopped = ""

    for locale in selected:
        # English variants (en-GB, en-AU, en-CA) exist so the picker can name the
        # user's own variant; their copy is the English copy. Translating them
        # would cost 3 x 144 calls to get English back.
        if locale["dart"].startswith("en_"):
            rows = {
                key: {"value": value, "_src": source_hash(value), "_model": "copy"}
                for key, value in english.items()
            }
            cache[locale["dart"]] = rows
            write_arb(locale["dart"], rows, english, template)
            written[locale["asc"]] = len(rows)
            CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            print(f"  {locale['asc']:<9} copied English (variant locale)")
            continue

        rows, locale_failures, fell_back = translate_locale(
            locale, english, cache, api_keys, args.sleep
        )
        cache[locale["dart"]] = rows
        CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

        # The day's quota is gone. Every remaining locale would fail the same
        # way, so stop and name them instead of looping through 25 silent
        # no-ops. A locale with nothing translated is left without an ARB rather
        # than written as a copy of English: an absent catalog falls back to
        # English at runtime, while an all-English catalog claims to be Danish.
        if locale_failures and all("daily quota exhausted" in f for f in locale_failures):
            quota_stopped = locale["asc"]
            break

        if locale_failures:
            # Write anyway. `write_arb` falls back to the English value for a key
            # with no usable row, so dropping the file instead threw away 480
            # good translations to punish one bad string — and left the locale
            # rendering English entirely. The failure is still reported and the
            # key is still uncached, so the next run retries it.
            failures.extend(locale_failures)
            skipped.append(locale["asc"])
            print(
                f"  {locale['asc']:<9} written with {len(locale_failures)} English "
                f"fallback(s): {len(locale_failures)} string(s) failed"
            )
        write_arb(locale["dart"], rows, english, template)
        written[locale["asc"]] = len(rows)
        if fell_back:
            fallbacks[locale["asc"]] = len(fell_back)

    print(f"\nwrote {len(written)} ARB file(s), {sum(written.values())} strings")

    # Final safety pass on what this run touched: a plural the model encoded with
    # a redundant `=N` would fail `flutter gen-l10n` for the whole catalog, and
    # finding that out after a 40-minute run is expensive. Cache-only, no calls.
    touched = {
        locale["dart"]: cache[locale["dart"]]
        for locale in selected
        if locale["dart"] in cache and isinstance(cache[locale["dart"]], dict)
    }
    repair_catalogs(touched, english, template)

    # Copy the base-language fallback Flutter requires (see FALLBACK_BASES).
    for base, source_code in FALLBACK_BASES.items():
        source = L10N / f"app_{source_code}.arb"
        if not source.exists():
            continue
        data = json.loads(source.read_text(encoding="utf-8"))
        data["@@locale"] = base
        (L10N / f"app_{base}.arb").write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"  {base:<9} copied from {source_code} (language fallback for gen-l10n)")
    if fallbacks:
        print(f"{len(fallbacks)} locale(s) still render English for some keys (will retry next run):")
        for code, count in sorted(fallbacks.items(), key=lambda item: -item[1]):
            print(f"  {code:9} {count} key(s)")
    if skipped:
        print(
            f"{len(skipped)} locale(s) shipped with at least one English fallback: "
            f"{', '.join(skipped)}"
        )
    if quota_stopped:
        remaining = [l["asc"] for l in selected if l["asc"] not in written]
        print(
            f"\nSTOPPED at {quota_stopped}: the Gemini daily quota is spent on every model.\n"
            f"{len(remaining)} locale(s) still need a catalog: {', '.join(remaining)}\n"
            "The cache holds everything translated so far; rerun the same command "
            "once the quota resets and it continues where this stopped."
        )
    if failures:
        print(f"{len(failures)} string(s) need attention:")
        for failure in failures[:40]:
            print(f"  {failure}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
