#!/usr/bin/env python3
"""Reject characters written in the wrong script for a locale.

Why this exists
---------------
Every other checker in this directory validates *form*: the JSON parses, the
keys match, the ICU braces balance, the string is not empty and is not equal to
English. None of them can see that a Malayalam paragraph contains three Bengali
letters, or that the Punjabi release notes contain a Georgian consonant, because
those strings are complete, correct-length and thoroughly untranslated-looking
in every way except meaning.

That is not hypothetical. The 1.3.0 draft shipped a `pa-IN` "What's New" reading
`ਸੱჯੇ ਤੋਂ ਖੱબੇ` — a Georgian `ჯ` and a Gujarati `બ` inside `ਸੱਜੇ ਤੋਂ ਖੱਬੇ` — and an
`or-IN` description with 27 Devanagari letters scrambled into Odia. Apple
accepted most of them; the one it refused surfaced the rest.

Why not just compare against a whitelist of characters
------------------------------------------------------
Real listings legitimately mix scripts: `FitCheck AI`, `Pro`, `LinkedIn`,
`Instagram`, `iOS`, `5.1.1`, urls. So Latin is allowed everywhere, and each
locale additionally allows its own script. Everything else is a defect.

Shared punctuation, symbols and emoji are allowed everywhere, including the CJK
full-width forms and the Indic danda, which are used across script families.

Usage
-----
    python3 scripts/i18n/check_scripts.py              # ARB + listings + web
    python3 scripts/i18n/check_scripts.py --listings    # one surface
    python3 scripts/i18n/check_scripts.py --json        # machine-readable
"""

from __future__ import annotations

import argparse
import json
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STORE = ROOT / "store" / "asc" / "listings.json"
ARB_DIR = ROOT / "flutter" / "lib" / "l10n"
WEB_DIR = ROOT / "frontend" / "src" / "i18n" / "locales"

# Script name -> inclusive codepoint ranges. Only the scripts this project ships.
SCRIPTS: dict[str, list[tuple[int, int]]] = {
    "latin": [(0x0041, 0x005A), (0x0061, 0x007A), (0x00C0, 0x024F), (0x1E00, 0x1EFF)],
    "greek": [(0x0370, 0x03FF), (0x1F00, 0x1FFF)],
    "cyrillic": [(0x0400, 0x04FF), (0x0500, 0x052F)],
    "armenian": [(0x0530, 0x058F)],
    "hebrew": [(0x0590, 0x05FF), (0xFB1D, 0xFB4F)],
    "arabic": [(0x0600, 0x06FF), (0x0750, 0x077F), (0x08A0, 0x08FF), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF)],
    "syriac": [(0x0700, 0x074F)],
    "thaana": [(0x0780, 0x07BF)],
    "devanagari": [(0x0900, 0x097F), (0xA8E0, 0xA8FF)],
    "bengali": [(0x0980, 0x09FF)],
    "gurmukhi": [(0x0A00, 0x0A7F)],
    "gujarati": [(0x0A80, 0x0AFF)],
    "oriya": [(0x0B00, 0x0B7F)],
    "tamil": [(0x0B80, 0x0BFF)],
    "telugu": [(0x0C00, 0x0C7F)],
    "kannada": [(0x0C80, 0x0CFF)],
    "malayalam": [(0x0D00, 0x0D7F)],
    "sinhala": [(0x0D80, 0x0DFF)],
    "thai": [(0x0E00, 0x0E7F)],
    "lao": [(0x0E80, 0x0EFF)],
    "tibetan": [(0x0F00, 0x0FFF)],
    "myanmar": [(0x1000, 0x109F)],
    "georgian": [(0x10A0, 0x10FF)],
    "ethiopic": [(0x1200, 0x137F)],
    "cherokee": [(0x13A0, 0x13FF)],
    "hangul": [(0x1100, 0x11FF), (0x3130, 0x318F), (0xA960, 0xA97F), (0xAC00, 0xD7AF)],
    "kana": [(0x3040, 0x30FF), (0x31F0, 0x31FF)],
    "bopomofo": [(0x3100, 0x312F)],
    "han": [(0x3400, 0x4DBF), (0x4E00, 0x9FFF), (0xF900, 0xFAFF)],
}

# Ranges allowed in every locale: punctuation, spacing, currency, symbols,
# arrows, dingbats, emoji, variation selectors, combining marks and joiners.
SHARED: list[tuple[int, int]] = [
    (0x0000, 0x0040), (0x005B, 0x0060), (0x007B, 0x00BF),  # ascii core + latin-1 punct
    (0x2000, 0x206F),  # general punctuation incl. en/em dash, ellipsis, narrow nbsp
    (0x0964, 0x0965),  # danda / double danda — shared by bn, pa, or, hi, mr, ne
    (0x20A0, 0x20CF),  # currency
    (0x2100, 0x27BF),  # letterlike, arrows, math, dingbats
    (0x2E00, 0x2E7F),  # supplemental punctuation
    (0x3000, 0x303F),  # CJK punctuation (。 、 「 」) — used by ja/zh/ko listings
    (0xFE00, 0xFE0F),  # variation selectors
    (0xFF00, 0xFFEF),  # half/full-width forms (， ： ＆)
    (0x1F000, 0x1FAFF),  # emoji
    (0x200B, 0x200F), (0x202A, 0x202E), (0x2066, 0x2069),  # zero-width + bidi marks
    (0xFEFF, 0xFEFF),
]

# Locale -> the scripts its text may use, beyond Latin (always allowed).
LOCALE_SCRIPTS: dict[str, set[str]] = {
    "ar": {"arabic"}, "he": {"hebrew"}, "fa": {"arabic"}, "ur": {"arabic"},
    "hi": {"devanagari"}, "mr": {"devanagari"}, "ne": {"devanagari"},
    "bn": {"bengali"}, "as": {"bengali"},
    "pa": {"gurmukhi"}, "gu": {"gujarati"}, "or": {"oriya"},
    "ta": {"tamil"}, "te": {"telugu"}, "kn": {"kannada"},
    "ml": {"malayalam"}, "si": {"sinhala"},
    "th": {"thai"}, "lo": {"lao"}, "my": {"myanmar"}, "km": set(), "bo": {"tibetan"},
    "ja": {"kana", "han"}, "zh": {"han", "bopomofo"}, "ko": {"hangul", "han"},
    "ru": {"cyrillic"}, "uk": {"cyrillic"}, "bg": {"cyrillic"}, "sr": {"cyrillic"},
    "mk": {"cyrillic"}, "be": {"cyrillic"}, "kk": {"cyrillic"}, "ky": {"cyrillic"},
    "el": {"greek"}, "hy": {"armenian"}, "ka": {"georgian"}, "am": {"ethiopic"},
}


def script_of(cp: int) -> str | None:
    """Return the script that owns `cp`, or None when it is shared/exempt."""
    for name, spans in SCRIPTS.items():
        for low, high in spans:
            if low <= cp <= high:
                return name
    return None


def is_shared(cp: int) -> bool:
    for low, high in SHARED:
        if low <= cp <= high:
            return True
    # Format and private-use characters carry no script. Combining marks are NOT
    # exempt: a Bengali vowel sign inside a Malayalam word is the same defect as a
    # Bengali letter there, and `MALAYALAM VOWEL SIGN E` exists, so it is both
    # worth reporting and mechanically fixable. Only marks whose script is unknown
    # are treated as shared.
    return unicodedata.category(chr(cp)) in {"Cf", "Cs", "Co"}


def base_language(locale: str) -> str:
    """`pa-IN` -> `pa`, `zh-Hans` -> `zh`, `en-US` -> `en`."""
    return locale.replace("_", "-").split("-")[0].lower()


# The prefix Unicode puts on a character's name, per script in `SCRIPTS`.
# `kana` and `han` map to more than one prefix; ideographs have no name to map.
NAME_PREFIX: dict[str, tuple[str, ...]] = {
    "latin": ("LATIN",), "greek": ("GREEK",), "cyrillic": ("CYRILLIC",),
    "armenian": ("ARMENIAN",), "hebrew": ("HEBREW",), "arabic": ("ARABIC",),
    "syriac": ("SYRIAC",), "thaana": ("THAANA",), "devanagari": ("DEVANAGARI",),
    "bengali": ("BENGALI",), "gurmukhi": ("GURMUKHI",), "gujarati": ("GUJARATI",),
    "oriya": ("ORIYA",), "tamil": ("TAMIL",), "telugu": ("TELUGU",),
    "kannada": ("KANNADA",), "malayalam": ("MALAYALAM",), "sinhala": ("SINHALA",),
    "thai": ("THAI",), "lao": ("LAO",), "tibetan": ("TIBETAN",),
    "myanmar": ("MYANMAR",), "georgian": ("GEORGIAN",), "ethiopic": ("ETHIOPIC",),
    "cherokee": ("CHEROKEE",), "hangul": ("HANGUL",),
    "kana": ("HIRAGANA", "KATAKANA"), "bopomofo": ("BOPOMOFO",), "han": (),
}

# Scripts whose names include the letter's case, e.g. `CYRILLIC SMALL LETTER A`.
# Cross-script name reuse only works letter-for-letter when the case word is the
# same, so the tail after the script prefix is kept verbatim.
def fold_char(char: str, targets: set[str]) -> str | None:
    """The same character in one of `targets`, matched by Unicode character name.

    This is what makes a wrong-script repair mechanical instead of a re-translation.
    `BENGALI LETTER SHA` and `MALAYALAM LETTER SHA` are the same letter in two
    scripts, and Unicode names both of them explicitly, so the substitution is
    provable rather than guessed. `CYRILLIC SMALL LETTER E` maps to `LATIN SMALL
    LETTER E` the same way, which fixes the `galерии` class of homoglyph.

    Returns None when the target script has no character with that name — a
    Korean syllable inside a Greek word, or a Han character anywhere — because
    then there is nothing to substitute and the string needs real translation.
    """
    name = unicodedata.name(char, "")
    if not name:
        return None
    for source in SCRIPTS:
        for prefix in NAME_PREFIX.get(source, ()):
            if not name.startswith(prefix + " "):
                continue
            tail = name[len(prefix) + 1:]
            for target in sorted(targets):
                if target == source:
                    continue
                for wanted in NAME_PREFIX.get(target, ()):
                    try:
                        candidate = unicodedata.lookup(f"{wanted} {tail}")
                    except KeyError:
                        continue
                    # Only substitute within the same case so ASCII text does not
                    # become upper-case mid-sentence.
                    if candidate.isupper() != char.isupper():
                        continue
                    return candidate
            return None
    return None


def fold_text(text: str, locale: str) -> tuple[str, list[dict]]:
    """Replace every wrong-script character that has a same-named counterpart.

    Only **isolated** foreign characters are folded. A lone Cyrillic `е` inside
    `galерии` is a homoglyph slip and becomes the Latin `e` it was meant to be.
    A *run* of foreign characters is a whole word in another language: folding
    `শেষ` into Malayalam letters produces `ശെഷ`, which is the right alphabet and
    still not Malayalam, so it would hide a real defect behind a passing check.
    Runs therefore stay flagged for the model.

    Returns the folded string and the characters that could not be folded, so a
    caller can decide whether the remainder needs the model.
    """
    allowed = allowed_for(locale)
    targets = allowed - {"latin"} or {"latin"}

    def foreign(index: int) -> bool:
        cp = ord(text[index])
        if is_shared(cp):
            return False
        script = script_of(cp)
        return script is not None and script not in allowed

    out: list[str] = []
    unfixable: list[dict] = []
    for index, char in enumerate(text):
        if not foreign(index):
            out.append(char)
            continue
        # Walk the run this character belongs to.
        start = index
        while start > 0 and foreign(start - 1):
            start -= 1
        end = index
        while end + 1 < len(text) and foreign(end + 1):
            end += 1
        isolated = end == start
        replacement = fold_char(char, targets) if isolated else None
        if replacement is None:
            unfixable.append({
                "locale": locale, "index": index, "char": char,
                "codepoint": f"U+{ord(char):04X}", "script": script_of(ord(char)),
                "run": end - start + 1,
            })
            out.append(char)
        else:
            out.append(replacement)
    return "".join(out), unfixable


def allowed_for(locale: str) -> set[str]:
    extra = LOCALE_SCRIPTS.get(base_language(locale), set())
    return {"latin"} | extra


def scan_text(text: str, locale: str) -> list[dict]:
    """Every character in `text` outside the locale's scripts and shared ranges."""
    if not text:
        return []
    allowed = allowed_for(locale)
    found: list[dict] = []
    for index, ch in enumerate(text):
        cp = ord(ch)
        if is_shared(cp):
            continue
        script = script_of(cp)
        if script is None or script in allowed:
            continue
        found.append({
            "locale": locale,
            "index": index,
            "char": ch,
            "codepoint": f"U+{cp:04X}",
            "script": script,
            "expected": sorted(allowed - {"latin"}) or ["latin-only"],
            "context": text[max(0, index - 18): index + 18],
            "name": unicodedata.name(ch, "?"),
        })
    return found


def scan_listings() -> list[dict]:
    if not STORE.exists():
        return []
    data = json.loads(STORE.read_text(encoding="utf-8"))
    problems: list[dict] = []
    for locale, payload in data.items():
        if locale.startswith("_") or not isinstance(payload, dict):
            continue
        for field, value in payload.items():
            if not isinstance(value, str):
                continue
            for hit in scan_text(value, locale):
                hit.update(surface=f"listings.{field}", file="listings", key=field)
                problems.append(hit)
    return problems


def _scan_json_file(path: Path, locale: str, surface: str, surface_kind: str) -> list[dict]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return []
    problems: list[dict] = []
    for key, value in data.items():
        if key.startswith("@") or not isinstance(value, str):
            continue
        for hit in scan_text(value, locale):
            hit.update(surface=f"{surface}.{key}", file=surface_kind, key=key)
            problems.append(hit)
    return problems


def arb_locale(path: Path) -> str:
    """`app_zh_Hans.arb` -> `zh-Hans`, `app_en.arb` -> `en`."""
    stem = path.stem
    if stem.startswith("app_"):
        stem = stem[4:]
    return stem.replace("_", "-")


def scan_arb() -> list[dict]:
    if not ARB_DIR.is_dir():
        return []
    problems: list[dict] = []
    for path in sorted(ARB_DIR.glob("app_*.arb")):
        problems.extend(_scan_json_file(path, arb_locale(path), f"arb.{path.name}", "arb"))
    return problems


def scan_web() -> list[dict]:
    if not WEB_DIR.is_dir():
        return []
    problems: list[dict] = []
    for path in sorted(WEB_DIR.glob("*.json")):
        problems.extend(_scan_json_file(path, path.stem, f"web.{path.name}", "web"))
    return problems


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--listings", action="store_true", help="only store/asc/listings.json")
    parser.add_argument("--arb", action="store_true", help="only the Flutter ARB catalogs")
    parser.add_argument("--web", action="store_true", help="only the web locale files")
    parser.add_argument("--json", action="store_true", help="emit machine-readable output")
    parser.add_argument("--max-report", type=int, default=40)
    args = parser.parse_args(argv)

    selected = args.listings or args.arb or args.web
    problems: list[dict] = []
    if not selected or args.listings:
        problems.extend(scan_listings())
    if not selected or args.arb:
        problems.extend(scan_arb())
    if not selected or args.web:
        problems.extend(scan_web())

    if args.json:
        print(json.dumps(problems, ensure_ascii=False, indent=2))
        return 1 if problems else 0

    if not problems:
        print("scripts: ok — every locale uses only its own script plus shared punctuation")
        return 0

    by_locale: dict[str, list[dict]] = {}
    for hit in problems:
        by_locale.setdefault(hit["locale"], []).append(hit)

    print(f"scripts: {len(problems)} character(s) in the wrong script across "
          f"{len(by_locale)} locale(s)\n")
    shown = 0
    for locale in sorted(by_locale):
        hits = by_locale[locale]
        scripts = sorted({h["script"] for h in hits})
        print(f"  {locale:<9} {len(hits):>3}  expected {'/'.join(hits[0]['expected'])}, "
              f"got {', '.join(scripts)}")
        for hit in hits:
            if shown >= args.max_report:
                continue
            shown += 1
            print(f"      {hit['surface']} [{hit['codepoint']} {hit['script']}] "
                  f"…{hit['context'].strip()}…")
    if len(problems) > args.max_report:
        print(f"\n  … {len(problems) - args.max_report} more (raise --max-report or use --json)")
    print("\nA character outside a locale's script is a translation defect, not a style "
          "choice: it renders as a visible foreign glyph to a native reader.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
