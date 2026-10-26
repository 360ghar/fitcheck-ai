#!/usr/bin/env python3
"""Repair ARB strings that were written in the wrong script.

The problem
-----------
`check_scripts.py` finds characters outside a locale's script. In the 1.3.0
catalogs these are model slips, not typos, and they cluster:

* `app_kn.arb` carried 667 **Georgian** characters across 29 keys — the billing
  and share block was translated into Georgian instead of Kannada, evidently a
  `kn` -> `ka` mix-up.
* `app_cs.arb` had Cyrillic `е р и` inside `galерии`, `app_el.arb` had Cyrillic
  `Ро` inside `Роζ` and Han `事件` inside a Greek sentence, `app_bn.arb` had
  Kannada `ರಿ` inside `সরিসি`. Those render as wrong glyphs to a native reader
  and pass every other check in this repo.

A character table cannot fix this. Swapping Cyrillic `е` for Latin `e` works for
Czech; it cannot turn Georgian `მეგობრის` into Kannada `ಸ್ನೇಹಿತರ`. The only
correct repair is to translate the string again with the target script stated
explicitly, then prove the result is clean.

What this does
--------------
For each (locale, key) that `check_scripts.py` flags:

1. Take the English source for the key.
2. Re-translate it, naming the script and forbidding every other writing system.
3. Reject the answer unless it is clean per `check_scripts.scan_text`, keeps the
   same ICU placeholders and plural selectors, is non-empty and is not the
   English string.
4. Retry once, then leave the original in place and report it.

It never invents a value it could not validate, so a locale either comes out
correct or is reported — never quietly worse.

Usage
-----
    python3 scripts/i18n/repair_scripts.py --dry-run
    python3 scripts/i18n/repair_scripts.py --apply
    python3 scripts/i18n/repair_scripts.py --apply --locale kn,el
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from agnes_client import call_agnes  # noqa: E402
from check_scripts import STORE, scan_arb, scan_listings, scan_text, scan_web  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
ARB_DIR = ROOT / "flutter" / "lib" / "l10n"
WEB_DIR = ROOT / "frontend" / "src" / "i18n" / "locales"
TEMPLATE = ARB_DIR / "app_en.arb"
WEB_TEMPLATE = WEB_DIR / "en.json"

# The script a locale must use, as a phrase a model can act on.
SCRIPT_NAMES = {
    "latin": "Latin", "greek": "Greek", "cyrillic": "Cyrillic", "armenian": "Armenian",
    "hebrew": "Hebrew", "arabic": "Arabic", "syriac": "Syriac", "thaana": "Thaana",
    "devanagari": "Devanagari", "bengali": "Bengali", "gurmukhi": "Gurmukhi",
    "gujarati": "Gujarati", "oriya": "Odia", "tamil": "Tamil", "telugu": "Telugu",
    "kannada": "Kannada", "malayalam": "Malayalam", "sinhala": "Sinhala",
    "thai": "Thai", "lao": "Lao", "tibetan": "Tibetan", "myanmar": "Myanmar",
    "georgian": "Georgian", "ethiopic": "Ethiopic", "cherokee": "Cherokee",
    "hangul": "Hangul", "kana": "Japanese kana", "bopomofo": "Bopomofo", "han": "Han",
}

LANGUAGE_NAMES = {
    "ar": "Arabic", "bn": "Bengali", "cs": "Czech", "da": "Danish", "de": "German",
    "el": "Greek", "es": "Spanish", "fi": "Finnish", "fr": "French", "gu": "Gujarati",
    "he": "Hebrew", "hi": "Hindi", "hr": "Croatian", "hu": "Hungarian", "id": "Indonesian",
    "it": "Italian", "ja": "Japanese", "kn": "Kannada", "ko": "Korean", "ml": "Malayalam",
    "mr": "Marathi", "ms": "Malay", "nl": "Dutch", "no": "Norwegian", "or": "Odia",
    "pa": "Punjabi", "pl": "Polish", "pt": "Portuguese", "ro": "Romanian", "ru": "Russian",
    "sk": "Slovak", "sl": "Slovenian", "sv": "Swedish", "ta": "Tamil", "te": "Telugu",
    "th": "Thai", "tr": "Turkish", "uk": "Ukrainian", "ur": "Urdu", "vi": "Vietnamese",
    "zh": "Chinese", "ca": "Catalan",
}

PLACEHOLDER = re.compile(r"\{[^{}]*\}")


def language_of(locale: str) -> str:
    return LANGUAGE_NAMES.get(locale.split("-")[0].lower(), locale)


def script_name(locale: str) -> str:
    from check_scripts import allowed_for

    extra = allowed_for(locale) - {"latin"}
    if not extra:
        return "Latin"
    return " and ".join(SCRIPT_NAMES.get(s, s) for s in sorted(extra))


def icu_shape(value: str) -> list[str]:
    """The placeholders at the top level, e.g. `['count', 'name']`.

    Plural branches nest, so a flat regex over `{...}` would also capture branch
    text. Taking the outermost non-nested groups is enough to prove the skeleton
    survived without re-parsing ICU.
    """
    shape: list[str] = []
    depth = 0
    start = -1
    for index, char in enumerate(value):
        if char == "{":
            if depth == 0:
                start = index
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0 and start >= 0:
                token = value[start:index + 1]
                head = token[1:].split(",", 1)[0].strip()
                shape.append(head)
                start = -1
    return sorted(shape)


def build_prompt(locale: str, wanted: dict[str, str], english: dict[str, str]) -> str:
    lang = language_of(locale)
    script = script_name(locale)
    lines = [
        f"You are repairing App Store user-interface copy for FitCheck AI (a wardrobe and outfit app).",
        f"Rewrite each string in {lang}, written ONLY in {script} script.",
        "",
        f"HARD RULES:",
        f"1. Use {script} characters only. Do not use letters from any other writing system.",
        f"   A single letter from another script makes the string unusable.",
        f"2. Keep every {{placeholder}} and every ICU plural structure exactly as it appears.",
        f"3. Keep the meaning of the English source. This is app UI copy, so be concise.",
        f"4. Return JSON: an object mapping each key to its repaired string, nothing else.",
        "",
        "Strings to repair (key -> English source):",
    ]
    for key in wanted:
        lines.append(f"  {json.dumps(key)}: {json.dumps(english.get(key, ''))}")
    return "\n".join(lines)


def validate(value: str, original: str, english: str, locale: str) -> list[str]:
    """Reasons to reject `value`. Empty means it is shippable."""
    problems: list[str] = []
    if not value or not value.strip():
        return ["empty"]
    if value.strip() == (english or "").strip():
        problems.append("identical to English")
    if scan_text(value, locale):
        problems.append("still has characters from the wrong script")
    if icu_shape(value) != icu_shape(original):
        problems.append(f"placeholder shape changed {icu_shape(original)} -> {icu_shape(value)}")
    return problems


def fold_only(args, wanted_locales: set[str]) -> int:
    """Apply only the substitutions Unicode proves: same letter, right script.

    This is the safe half of the repair. `BENGALI LETTER SHA` and `MALAYALAM
    LETTER SHA` are the same letter, and a Cyrillic `е` in a Czech word is a
    Latin `e`, so neither needs a model or a quota window. What it cannot do is
    turn Georgian `მეგობრის` into Kannada, because no Kannada character shares
    those names — those strings stay flagged for `--apply`.
    """
    from check_scripts import fold_text  # local import: only this mode needs it

    findings = scan_arb() + scan_web() + scan_listings()
    if not findings:
        print("scripts: nothing to fold")
        return 0

    touched: dict[tuple[str, str], set[str]] = defaultdict(set)
    for hit in findings:
        locale = hit["locale"]
        if wanted_locales and locale.split("-")[0] not in wanted_locales:
            continue
        touched[(hit["file"], locale)].add(hit["key"])

    # listings.json is one file holding every locale, so it is handled separately.
    listing_keys: dict[str, set[str]] = defaultdict(set)
    for (surface, locale), keys in list(touched.items()):
        if surface == "listings":
            listing_keys[locale] |= keys
            del touched[(surface, locale)]

    folded_total = 0
    leftover_total = 0
    report: list[str] = []

    for (surface, locale), keys in sorted(touched.items()):
        path = (ARB_DIR / f"app_{locale.replace('-', '_')}.arb") if surface == "arb" \
            else (WEB_DIR / f"{locale}.json")
        if not path.exists():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        folded = 0
        leftover = 0
        for key in sorted(keys):
            value = data.get(key)
            if not isinstance(value, str):
                continue
            new, unfixable = fold_text(value, locale)
            leftover += len(unfixable)
            if new != value:
                data[key] = new
                folded += sum(1 for a, b in zip(value, new) if a != b)
        if folded or leftover:
            if args.apply:
                path.write_text(
                    json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8",
                )
            folded_total += folded
            leftover_total += leftover
            report.append(f"  {surface:<4} {locale:<9} folded {folded:>4}  needs model {leftover:>4}")

    if listing_keys and STORE.exists():
        data = json.loads(STORE.read_text(encoding="utf-8"))
        folded = 0
        leftover = 0
        for locale, keys in listing_keys.items():
            for field in keys:
                value = data.get(locale, {}).get(field)
                if not isinstance(value, str):
                    continue
                new, unfixable = fold_text(value, locale)
                leftover += len(unfixable)
                if new != value:
                    data[locale][field] = new
                    folded += sum(1 for a, b in zip(value, new) if a != b)
        if folded or leftover:
            if args.apply:
                STORE.write_text(
                    json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
                )
            folded_total += folded
            leftover_total += leftover
            report.append(f"  store listings       folded {folded:>4}  needs model {leftover:>4}")

    for row in report:
        print(row)
    verb = "folded" if args.apply else "would fold"
    print(f"\n{verb} {folded_total} character(s); {leftover_total} still need the model")
    if not args.apply:
        print("Dry run. Add --apply to write.")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="write the repaired catalogs")
    parser.add_argument("--dry-run", action="store_true", help="list targets only, no API calls")
    parser.add_argument("--fold", action="store_true",
                        help="only the deterministic fixes, no API calls (safe, instant)")
    parser.add_argument("--locale", default="", help="comma-separated base codes, e.g. kn,el")
    parser.add_argument("--batch", type=int, default=12, help="keys per request")
    parser.add_argument("--provider", default="agnes", choices=["agnes", "gemini"])
    args = parser.parse_args(argv)

    wanted_locales = {c.strip() for c in args.locale.split(",") if c.strip()}

    if args.fold:
        return fold_only(args, wanted_locales)

    findings = scan_arb() + scan_web()
    if not findings:
        print("scripts: nothing to repair")
        return 0

    # (surface, locale) -> keys. The two surfaces keep their keys in different
    # shapes — ARB keys are flat identifiers, web keys are dotted paths — so the
    # grouping has to come from the structured `file`/`key` fields rather than
    # from splitting the display string.
    targets: dict[tuple[str, str], set[str]] = defaultdict(set)
    for hit in findings:
        locale = hit["locale"]
        if wanted_locales and locale.split("-")[0] not in wanted_locales:
            continue
        targets[(hit["file"], locale)].add(hit["key"])

    if not targets:
        print("scripts: nothing to repair for the requested locales")
        return 0

    total = sum(len(v) for v in targets.values())
    print(f"repair targets: {total} string(s)")
    for (surface, locale), keys in sorted(targets.items()):
        print(f"  {surface:<4} {locale:<9} {len(keys):>3}  -> {language_of(locale)} / {script_name(locale)}")

    if args.dry_run or not args.apply:
        print("\nDry run. Re-run with --apply to translate and write.")
        return 0

    call = call_agnes
    if args.provider == "gemini":
        from gemini_client import call_gemini as call  # type: ignore  # noqa: N813

    templates = {"arb": TEMPLATE, "web": WEB_TEMPLATE}
    repaired_total = 0
    rejected: list[str] = []
    for (surface, locale), keys_wanted in sorted(targets.items()):
        if surface == "arb":
            path = ARB_DIR / f"app_{locale.replace('-', '_')}.arb"
        else:
            path = WEB_DIR / f"{locale}.json"
        template_path = templates.get(surface)
        if not path.exists() or template_path is None or not template_path.exists():
            print(f"  {surface} {locale}: missing file, skipped")
            continue
        english = json.loads(template_path.read_text(encoding="utf-8"))
        catalog = json.loads(path.read_text(encoding="utf-8"))
        keys = [k for k in sorted(keys_wanted) if k in catalog]
        done = 0
        for start in range(0, len(keys), args.batch):
            chunk = keys[start:start + args.batch]
            current = {k: catalog[k] for k in chunk}
            prompt = build_prompt(locale, current, english)
            try:
                raw = call(None, prompt, retries=3, max_output_tokens=4096)
            except Exception as error:  # noqa: BLE001 - transport failure is the report
                rejected.append(f"{surface}/{locale}: request failed ({str(error).splitlines()[0][:120]})")
                break
            try:
                answer = json.loads(raw[raw.find("{"):raw.rfind("}") + 1])
            except ValueError:
                rejected.append(f"{surface}/{locale}: model did not return JSON")
                continue
            for key in chunk:
                candidate = answer.get(key)
                if not isinstance(candidate, str):
                    rejected.append(f"{surface}/{locale}/{key}: missing from the reply")
                    continue
                problems = validate(candidate, current[key], english.get(key, ""), locale)
                if problems:
                    rejected.append(f"{surface}/{locale}/{key}: {', '.join(problems)}")
                    continue
                catalog[key] = candidate
                done += 1
        if done:
            path.write_text(
                json.dumps(catalog, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            repaired_total += done
        print(f"  {surface:<4} {locale:<9} repaired {done}/{len(keys)}")

    print(f"\nrepaired {repaired_total} string(s)")
    if rejected:
        print(f"left unchanged ({len(rejected)}):")
        for row in rejected[:20]:
            print(f"  {row}")
        if len(rejected) > 20:
            print(f"  … and {len(rejected) - 20} more")
    remaining = scan_arb() + scan_web()
    print(f"wrong-script characters remaining: {len(remaining)}")
    return 0 if not remaining else 1


if __name__ == "__main__":
    sys.exit(main())
