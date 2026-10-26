#!/usr/bin/env python3
"""Verify that the copy we publish about localization is true.

The store listing promises features, and a promise that the binary does not keep
is an App Review metadata rejection. Two claims are especially easy to make and
hard to keep:

1. "N languages" in the listing, versus the number of `app_<lang>.arb` catalogs
   that `flutter gen-l10n` can actually compile.
2. "A translated interface", versus the number of user-facing English literals
   still sitting in widget code where no catalog can reach them.

Neither failure crashes anything. `gen-l10n` silently drops a locale with no
catalog and Flutter renders English, and a hardcoded `Text('Restore purchases')`
renders English in all 50 storefronts. That silence is exactly why this check
exists: it is the only thing that turns "we localized the app" from an
assumption into a measurement.

Modes:
  (default)   report the gap and exit 0
  --gate      exit 1 when the published copy claims more than the build delivers

The `--gate` mode is what the release runbook runs. It is deliberately not part
of `check_all.sh`: during ordinary development the build is expected to be
mid-migration and failing every commit would train people to ignore it.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
L10N = ROOT / "flutter" / "lib" / "l10n"
LIB = ROOT / "flutter" / "lib"
LISTINGS = ROOT / "store" / "asc" / "listings.json"

# UI-text positions worth scanning. Deliberately covers what a user reads and
# nothing else: log lines, route paths, storage keys and Pexels URLs are not
# translated and must not be counted, or the number becomes meaningless noise.
TEXT_PATTERNS = [
    re.compile(r"Text\(\s*'((?:[^'\\]|\\.){3,})'"),
    re.compile(r'Text\(\s*"((?:[^"\\]|\\.){3,})"'),
    re.compile(r"tooltip:\s*'((?:[^'\\]|\\.){3,})'"),
    re.compile(r"tooltip:\s*\"((?:[^\"\\]|\\.){3,})\""),
    re.compile(r"(?:labelText|hintText|helperText|errorText):\s*'((?:[^'\\]|\\.){3,})'"),
    re.compile(r"(?:labelText|hintText|helperText|errorText):\s*\"((?:[^\"\\]|\\.){3,})\""),
    re.compile(r"(?:title|message|label|subtitle):\s*'((?:[^'\\]|\\.){3,})'"),
    re.compile(r"(?:title|message|label|subtitle):\s*\"((?:[^\"\\]|\\.){3,})\""),
]

# Anything matching these is not prose a translator should touch.
NOT_PROSE = re.compile(
    r"https?://|api/|assets/|\.(png|jpg|jpeg|svg|json|dart|sql)\b|package:|"
    r"^[a-z0-9_.:-]+$|^\s*$",
    re.IGNORECASE,
)
HAS_WORDS = re.compile(r"[A-Za-z]{2}")

# English-variant storefronts. Their catalogs legitimately match `en`, so a
# coverage check that treated them as untranslated would report the correct
# build as broken. Kept as ARB filename stems, which use underscores.
ENGLISH_VARIANT_CATALOGS = {"en_AU", "en_CA", "en_GB"}

# Files whose English literals are correct and must not be extracted. Every
# entry needs the reason it is exempt, because an allowlist without one becomes
# where untranslated copy goes to hide.
ALLOWED_ENGLISH_FILES = {
    "core/exceptions/app_exceptions.dart": (
        "Exception `message` fields are the English source of truth. "
        "ErrorHandler._localizedByCode maps each stable errorCode to localized "
        "copy, and extractMessage() keeps English on purpose so Sentry groups "
        "one error per cause instead of one per locale. No user reads these "
        "directly."
    ),
    "core/widgets/brand.dart": (
        "The product name. Brand names are not translated."
    ),
    "features/settings/views/language_page.dart": (
        "Renders a locale identifier like `English · en-US`, which is the "
        "native name plus the storefront code, not prose."
    ),
}


def count_catalogs() -> tuple[int, set[str]]:
    files = sorted(L10N.glob("app_*.arb"))
    langs = {p.stem.replace("app_", "").split("_")[0] for p in files}
    return len(files), langs


def translation_coverage() -> tuple[float, list[tuple[str, float]]]:
    """Share of template values that are actually translated, per catalog.

    Counting catalog *files* is not enough to support a "translated interface"
    claim. A catalog that exists but is 60% English still renders English, and
    the release gate passed while 48 locales sat at 37-68% because it only
    checked that the files were there. English-variant storefronts
    (`en_GB`, `en_AU`, `en_CA`) legitimately match the source, so they are
    excluded rather than reported as failures.
    """
    source = L10N / "app_en.arb"
    if not source.exists():
        return 0.0, []
    english = {
        key: value
        for key, value in json.loads(source.read_text(encoding="utf-8")).items()
        if not key.startswith("@")
    }
    if not english:
        return 0.0, []
    rows: list[tuple[str, float]] = []
    for path in sorted(L10N.glob("app_*.arb")):
        code = path.stem.replace("app_", "")
        if code == "en" or code in ENGLISH_VARIANT_CATALOGS:
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        translated = sum(
            1
            for key, value in english.items()
            if str(data.get(key, "")).strip() and str(data.get(key, "")).strip() != str(value).strip()
        )
        rows.append((code, translated / len(english)))
    overall = sum(ratio for _code, ratio in rows) / len(rows) if rows else 0.0
    return overall, rows


def count_hardcoded() -> tuple[int, dict[str, int]]:
    """Distinct user-facing literals still outside the ARB system."""
    seen: set[str] = set()
    per_file: dict[str, int] = {}
    for path in LIB.rglob("*.dart"):
        relative = path.relative_to(LIB).as_posix()
        if "l10n/generated" in path.as_posix():
            continue
        if relative in ALLOWED_ENGLISH_FILES:
            continue
        try:
            src = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        hits = 0
        for pattern in TEXT_PATTERNS:
            for match in pattern.finditer(src):
                value = match.group(1).strip()
                # Interpolation is not prose. `'${value.currentStreak}'` and
                # `'$rank'` are numbers being formatted, and counting them as
                # untranslated English inflated this metric by a third and hid
                # the sentences that actually needed a translator.
                prose = re.sub(r"\$\{[^}]*\}|\$\w+", " ", value).strip()
                prose = re.sub(r"[\s\u00b7·:.,%-]+", " ", prose).strip()
                if not prose or not HAS_WORDS.search(prose):
                    continue
                if NOT_PROSE.search(value):
                    continue
                # A single lowercase token is almost always a key or an enum
                # name, not a sentence a user reads.
                if " " not in value and (value.islower() or "_" in value):
                    continue
                if value not in seen:
                    seen.add(value)
                    hits += 1
        if hits:
            per_file[path.relative_to(LIB).as_posix()] = hits
    return len(seen), per_file


def claimed_language_count() -> tuple[int | None, str]:
    """The largest N in any published "N languages" phrase, and the source."""
    if not LISTINGS.exists():
        return None, ""
    data = json.loads(LISTINGS.read_text(encoding="utf-8"))
    source = data.get("en-US") or {}
    best: int | None = None
    where = ""
    for field in ("description", "promotionalText", "whatsNew", "subtitle", "name"):
        text = source.get(field) or ""
        for match in re.finditer(r"\b(\d{1,3})\s+(?:global\s+)?languages\b", text, re.IGNORECASE):
            value = int(match.group(1))
            if best is None or value > best:
                best, where = value, f"en-US.{field}"
    return best, where


def claims_translated_interface() -> tuple[bool, str]:
    if not LISTINGS.exists():
        return False, ""
    source = (json.loads(LISTINGS.read_text(encoding="utf-8")).get("en-US") or {})
    for field in ("description", "promotionalText", "whatsNew"):
        text = (source.get(field) or "").lower()
        for phrase in ("translated interface", "fully translated", "interface is translated"):
            if phrase in text:
                return True, f"en-US.{field}: {phrase!r}"
    return False, ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--gate", action="store_true")
    parser.add_argument("--max-hardcoded", type=int, default=0)
    parser.add_argument("--min-coverage", type=float, default=0.90)
    args = parser.parse_args()

    n_files, langs = count_catalogs()
    n_hardcoded, per_file = count_hardcoded()
    claimed, where = claimed_language_count()
    translated_claim, translated_where = claims_translated_interface()
    coverage, coverage_rows = translation_coverage()
    untranslated = sorted(
        ((code, ratio) for code, ratio in coverage_rows if ratio < args.min_coverage),
        key=lambda kv: kv[1],
    )

    print("Localization claims vs reality")
    print("-" * 30)
    print(f"  catalogs on disk          {n_files} file(s), {len(langs)} base language(s)")
    print(f"  hardcoded UI literals     {n_hardcoded} distinct, across {len(per_file)} file(s)")
    print(f"  mean catalog coverage     {coverage * 100:.1f}% of template strings")
    print(f"  below {args.min_coverage * 100:.0f}%             {len(untranslated)} of {len(coverage_rows)} catalog(s)")
    print(f"  listing language claim    {claimed if claimed is not None else 'none'}"
          + (f"  ({where})" if where else ""))
    print(f"  listing translation claim {translated_claim}"
          + (f"  ({translated_where})" if translated_where else ""))

    failures: list[str] = []

    if claimed is not None and len(langs) < claimed:
        failures.append(
            f'listing says "{claimed} languages" but only {len(langs)} have a catalog '
            f"({claimed - len(langs)} missing). Generate the remaining app_<lang>.arb "
            "files before shipping this copy."
        )

    if translated_claim and n_hardcoded > args.max_hardcoded:
        failures.append(
            f'listing claims a "translated interface" but {n_hardcoded} user-facing '
            f"English literal(s) are still hardcoded in widgets (limit "
            f"{args.max_hardcoded}). Every one of these renders English in all "
            f"{len(langs)} catalogs. Extract them into app_en.arb first."
        )

    if translated_claim and untranslated:
        worst = ", ".join(f"{code} {ratio * 100:.0f}%" for code, ratio in untranslated[:8])
        failures.append(
            f'listing claims a "translated interface" but {len(untranslated)} of '
            f"{len(coverage_rows)} catalogs are below {args.min_coverage * 100:.0f}% "
            f"translated ({worst}). A catalog that exists but falls back to English "
            "still renders English on the device. Finish the translation pass, or "
            "stop claiming a translated interface."
        )

    if untranslated:
        print("\n  least translated catalogs:")
        for code, ratio in untranslated[:12]:
            print(f"    {ratio * 100:5.1f}%  {code}")

    if per_file:
        print("\n  heaviest files:")
        for path, count in sorted(per_file.items(), key=lambda kv: -kv[1])[:8]:
            print(f"    {count:4}  {path}")

    if not failures:
        print("\nOK — the published copy matches what the build delivers.")
        return 0

    print("\nFAIL — the published copy promises more than the build delivers:")
    for item in failures:
        print(f"  · {item}")

    if not args.gate:
        print("\n(report only; re-run with --gate to make this exit 1)")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
