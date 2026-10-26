#!/usr/bin/env python3
"""Fail when the six locale inventories drift apart, or an ARB breaks ICU.

The app ships 50 App Store locales in six places: the ASC source table, the Dart
locale registry, the iOS plist, the Android locale config, the ARB catalogs and
the backend's accepted-language list. Any one of them drifting produces the same
bug from a different direction — a storefront promises Hindi, the binary shows
English, and nothing in CI notices.

This gate compares them all, plus the things a translation can silently break:

* a key missing from a locale (renders English mid-screen),
* an orphan key (translators pay for strings nobody shows),
* a dropped `{uploads}` or `{count, plural, ...}` block (renders a literal brace
  or throws at runtime),
* a value left byte-identical to English (an untranslated row that looks done),
* a wrong `@@locale` (Flutter silently ignores the whole file).

Stdlib only, so it runs anywhere CI does. Exit 0 means the tree is coherent.

Usage:
    python3 scripts/i18n/check_locales.py
    python3 scripts/i18n/check_locales.py --strict     # warnings fail too
    python3 scripts/i18n/check_locales.py --json       # machine-readable
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASC_FILE = ROOT / "store" / "asc" / "locales.json"
REGISTRY = ROOT / "flutter" / "lib" / "core" / "i18n" / "locale_registry.dart"
L10N_DIR = ROOT / "flutter" / "lib" / "l10n"
TEMPLATE = L10N_DIR / "app_en.arb"
INFO_PLIST = ROOT / "flutter" / "ios" / "Runner" / "Info.plist"
ANDROID_XML = ROOT / "flutter" / "android" / "app" / "src" / "main" / "res" / "xml" / "locales_config.xml"
BACKEND_I18N = ROOT / "backend" / "app" / "core" / "i18n.py"

# Values that are correct when identical to English in every locale: the brand
# and the two plan names. Anything else identical is reported, because a value
# nobody translated is the failure this gate exists for.
UNTRANSLATED_ALLOWLIST = {"FitCheck AI", "Pro", "Plus", "AI"}

# Loanwords and proper nouns that stay as they are in at least one target
# language. Reported as warnings rather than errors: German really does say
# "Orange", French really does say "Photos", and every language says Instagram.
# The hard failure is a catalog that is mostly English, caught by the ratio.
UNTRANSLATED_FAIL_RATIO = 0.25

# Languages where the English source is already the shipped copy. en-GB,
# en-AU and en-CA legitimately match English; they exist so the picker can
# name the user's own variant.
ENGLISH_FAMILY_PREFIX = "en"

# ARB files that exist for `flutter gen-l10n`, not for a storefront: a locale
# with a country code or script subtag needs its language-only base as a
# fallback, and the base is a copy of the primary variant. Value is the variant
# it mirrors.
#
# Imported rather than redeclared: this mapping used to exist here and in
# `translate_arb.py`, and when Chinese needed a `zh` base only one copy was
# updated. See `inventory.py`.
import sys as _sys

_sys.path.insert(0, str(Path(__file__).resolve().parent))
from inventory import FALLBACK_BASES as DERIVED_BASE  # noqa: E402

ICU_TYPES = ("plural", "selectordinal", "select")

# The plural categories ICU recognizes. Anything else is a hard `gen-l10n`
# failure for the whole project, so it must be an error here too.
CLDR_CATEGORIES = ("zero", "one", "two", "few", "many", "other")

# gen-l10n's own set of accepted exact cases. Narrower than ICU's.
EXACT_PLURAL_CASES = frozenset({"=0", "=1", "=2"})


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)


def base_language(tag: str) -> str:
    """`pt-BR` -> `pt`, `zh-Hans` -> `zh-Hans`, `zh_Hant` -> `zh-Hant`.

    Script subtags survive because Simplified and Traditional Chinese are
    separate languages to a reader; region subtags collapse because iOS and
    Android name locales by base language and the backend only needs to know
    which language to write in.
    """
    normalized = tag.replace("_", "-")
    parts = normalized.split("-")
    language = parts[0].lower()
    for part in parts[1:]:
        if len(part) == 4 and part[0].isupper():
            return f"{language}-{part}"
    return language


def language_only(tag: str) -> str:
    """`zh-Hant` -> `zh`, `pt-PT` -> `pt`.

    `backend/app/core/i18n.SUPPORTED_LANGUAGES` answers "which language should
    the model write in", not "which locale should the picker show", so Chinese
    collapses to one `zh` entry there while the app keeps both scripts.
    """
    return base_language(tag).split("-")[0]


def load_asc(report: Report) -> list[dict]:
    data = json.loads(ASC_FILE.read_text(encoding="utf-8"))
    locales = data["locales"]
    seen_asc: set[str] = set()
    seen_dart: set[str] = set()
    for entry in locales:
        if entry["asc"] in seen_asc:
            report.error(f"store/asc/locales.json: duplicate asc {entry['asc']}")
        if entry["dart"] in seen_dart:
            report.error(f"store/asc/locales.json: duplicate dart {entry['dart']}")
        seen_asc.add(entry["asc"])
        seen_dart.add(entry["dart"])
    return locales


def parse_registry(report: Report) -> list[dict]:
    """Read `LocaleRegistry.all` without importing Flutter.

    Each row is one `AppLocale(...)` constructor. The `locale:` argument is a
    `Locale(...)` or `Locale.fromSubtags(...)` literal, so the Dart tag is
    rebuilt from the positional and named arguments.
    """
    source = REGISTRY.read_text(encoding="utf-8")
    start = source.find("static const List<AppLocale> all")
    if start == -1:
        report.error("locale_registry.dart: cannot find `static const List<AppLocale> all`")
        return []
    body = source[start:]
    body = body[body.find("[") : body.find("];")]

    rows: list[dict] = []
    row_pattern = re.compile(r"AppLocale\((.*?)\)\s*,\s*$", re.MULTILINE)
    # `all` is written one entry per line, so split on lines instead of trying
    # to balance parens in a regex.
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("AppLocale("):
            continue
        asc = re.search(r"asc:\s*'([^']+)'", line)
        tier = re.search(r"tier:\s*(\d)", line)
        rtl = re.search(r"rtl:\s*(true|false)", line)
        named = re.search(r"languageCode:\s*'([^']+)'", line)
        if named:
            script = re.search(r"scriptCode:\s*'([^']+)'", line)
            country = re.search(r"countryCode:\s*'([^']+)'", line)
            code = named.group(1)
            if script:
                code += f"-{script.group(1)}"
            if country:
                code += f"-{country.group(1)}"
        else:
            positional = re.search(r"locale:\s*Locale\(([^)]*)\)", line)
            if not positional:
                report.error(f"locale_registry.dart: cannot parse dart locale in: {line[:80]}")
                continue
            args = [part.strip().strip("'") for part in positional.group(1).split(",") if part.strip()]
            code = "-".join(args)
        if not asc or not tier or not rtl:
            report.error(f"locale_registry.dart: incomplete entry: {line[:80]}")
            continue
        rows.append(
            {
                "asc": asc.group(1),
                "dart": code,
                "tier": int(tier.group(1)),
                "rtl": rtl.group(1) == "true",
            }
        )
    if not rows:
        report.error("locale_registry.dart: parsed zero locales from LocaleRegistry.all")
    _ = row_pattern
    return rows


def parse_plist(report: Report) -> list[str]:
    text = INFO_PLIST.read_text(encoding="utf-8")
    match = re.search(r"<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>", text, re.DOTALL)
    if not match:
        report.error("Info.plist: no CFBundleLocalizations array")
        return []
    return re.findall(r"<string>([^<]+)</string>", match.group(1))


def parse_android(report: Report) -> list[str]:
    text = ANDROID_XML.read_text(encoding="utf-8")
    values = re.findall(r'<locale\s+android:name="([^"]+)"', text)
    if not values:
        report.error("locales_config.xml: no <locale> entries")
    manifest = (ROOT / "flutter" / "android" / "app" / "src" / "main" / "AndroidManifest.xml").read_text(
        encoding="utf-8"
    )
    if "android:localeConfig=" not in manifest:
        report.error("AndroidManifest.xml: application element does not set android:localeConfig")
    return values


def parse_arb_files(report: Report) -> dict[str, Path]:
    files: dict[str, Path] = {}
    for path in sorted(L10N_DIR.glob("app_*.arb")):
        code = path.stem[len("app_") :]
        files[code] = path
    if "en" not in files:
        report.error("flutter/lib/l10n/app_en.arb is missing")
    return files


def parse_backend(report: Report) -> list[str]:
    text = BACKEND_I18N.read_text(encoding="utf-8")
    match = re.search(r"SUPPORTED_LANGUAGES[^=]*=\s*\((.*?)\n\)", text, re.DOTALL)
    if not match:
        report.error("backend/app/core/i18n.py: cannot find SUPPORTED_LANGUAGES")
        return []
    return re.findall(r'\(\s*"([^"]+)"', match.group(1))


def read_arb(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise SystemExit(f"{path.relative_to(ROOT)}: invalid JSON ({error})") from error


def messages(arb: dict) -> dict[str, str]:
    return {key: value for key, value in arb.items() if not key.startswith("@")}


def metadata(arb: dict) -> dict[str, object]:
    return {key: value for key, value in arb.items() if key.startswith("@") and key != "@@locale"}


def icu_shape(value: str) -> tuple[frozenset[str], frozenset[tuple[str, str]]]:
    """Placeholder names and plural/select blocks in a message.

    A hand-rolled scanner rather than a regex, because nested plural blocks
    (`{count, plural, =1{1 day} other{{count} days}}`) are exactly what a naive
    regex gets wrong: it stops at the first `}` and reports a placeholder
    mismatch on a perfectly good translation.
    """
    names: set[str] = set()
    blocks: set[tuple[str, str]] = set()
    index = 0
    length = len(value)
    while index < length:
        char = value[index]
        if char == "'" and index + 1 < length and value[index + 1] == "'":
            index += 2
            continue
        if char != "{":
            index += 1
            continue
        depth = 0
        start = index
        while index < length:
            if value[index] == "{":
                depth += 1
            elif value[index] == "}":
                depth -= 1
                if depth == 0:
                    break
            index += 1
        inner = value[start + 1 : index]
        index += 1
        head = inner.split(",", 1)[0].strip()
        if not re.fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", head):
            # A plural branch body such as `{1 day ago}` or `{many items}`.
            continue
        names.add(head)
        rest = inner.split(",", 1)[1] if "," in inner else ""
        kind = rest.split(",", 1)[0].strip() if rest else ""
        if kind in ICU_TYPES:
            blocks.add((head, kind))
    return frozenset(names), frozenset(blocks)


def icu_problems(value: str) -> list[str]:
    """Reasons `flutter gen-l10n` would reject this message, or an empty list.

    `icu_shape` answers "same placeholders as the English?" and is deliberately
    tolerant: it walks braces and records names. That tolerance let two broken
    plurals through — Polish `few{{{count} ulubione}}` (an extra brace the shape
    scan reads as a stray token) and Slovak `=1{…} one{…}` (a category gen-l10n
    warns is overridden) — and the whole catalog failed to build with
    "Found syntax errors." This parses instead of scanning: a plural body is a
    sequence of `selector{message}` pairs, and anything else is an error.
    """
    problems: list[str] = []

    def parse(text: str) -> None:
        index = 0
        while index < len(text):
            char = text[index]
            if char == "}":
                problems.append("unbalanced closing brace")
                index += 1
                continue
            if char != "{":
                index += 1
                continue
            depth, start = 0, index
            while index < len(text):
                if text[index] == "{":
                    depth += 1
                elif text[index] == "}":
                    depth -= 1
                    if depth == 0:
                        break
                index += 1
            if depth != 0:
                problems.append("unbalanced opening brace")
                return
            inner = text[start + 1 : index]
            index += 1
            parts = [part.strip() for part in inner.split(",", 1)]
            head = parts[0]
            if not re.fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", head):
                # Inside a message every `{` must open a placeholder. Polish
                # `few{{{count} ulubione}` is this exact mistake: an extra brace
                # made the head `{count} ulubione`, which gen-l10n rejects with
                # "Expected identifier but found {".
                problems.append(f"`{{` does not open a placeholder (found `{head[:24]}`)")
                continue
            if len(parts) == 1:
                continue  # a plain placeholder: {count}
            kind = parts[1].split(",", 1)[0].strip()
            if kind not in ICU_TYPES:
                continue
            body = parts[1].split(",", 1)
            if len(body) < 2:
                problems.append(f"{kind} block for `{head}` has no branches")
                continue
            branches = _plural_branches(body[1])
            if branches is None:
                problems.append(f"{kind} block for `{head}` is malformed")
                continue
            seen: set[str] = set()
            for selector, branch in branches:
                if selector in seen:
                    problems.append(f"{kind} block for `{head}` repeats `{selector}`")
                seen.add(selector)
                parse(branch)
            # A selector must be a CLDR category or an exact `=N`. The parser
            # above validates *shape*, so `=5{3 фото}` reads as a perfectly good
            # branch — but `=5` is not a category, and gen-l10n refuses the entire
            # project with "5 is not a valid plural case", not just this message.
            # One model slip in one Russian string therefore blocked all 50
            # locales from building, and this check reported the tree coherent.
            if kind in ("plural", "selectordinal"):
                for selector in sorted(seen):
                    if selector in CLDR_CATEGORIES:
                        continue
                    # ICU itself allows any `=N`, but Flutter's gen-l10n does
                    # not: it accepts exactly `=0`, `=1` and `=2` and errors on
                    # anything else ("5 is not a valid plural case"). Match the
                    # tool we actually build with, not the broader spec.
                    if selector in EXACT_PLURAL_CASES:
                        continue
                    problems.append(
                        f"{kind} block for `{head}` uses `{selector}`, which gen-l10n "
                        f"rejects. Allowed: {', '.join(CLDR_CATEGORIES)} and "
                        f"{', '.join(sorted(EXACT_PLURAL_CASES))}. A single invalid "
                        "selector fails the whole project, not just this message."
                    )
            # `exact` categories override the language's own; keeping both means
            # one of them is dead code and gen-l10n says so.
            for selector in seen:
                if selector.startswith("=") and selector[1:] == "1" and "one" in seen:
                    problems.append(f"{kind} block for `{head}` overrides `=1` with `one`")

    parse(value)
    return problems


def _plural_branches(body: str) -> list[tuple[str, str]] | None:
    """Split `=1{one item} other{{count} items}` into [(selector, message)]."""
    branches: list[tuple[str, str]] = []
    index = 0
    while index < len(body):
        while index < len(body) and body[index] in " \t\n,":
            index += 1
        if index >= len(body):
            break
        start = index
        while index < len(body) and body[index] not in "{ \t\n,":
            index += 1
        selector = body[start:index].strip()
        while index < len(body) and body[index] != "{":
            if body[index] not in " ,\t\n":
                return None
            index += 1
        if index >= len(body):
            return None
        depth, start = 0, index
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
        branches.append((selector, body[start + 1 : index]))
        index += 1
    return branches


def check_arb_coverage(report: Report, locales: list[dict], arb_files: dict[str, Path]) -> None:
    expected = {entry["dart"] for entry in locales}
    missing = sorted(expected - set(arb_files))
    extra = sorted(set(arb_files) - expected)
    if missing:
        report.error(
            f"ARB: {len(missing)} locale(s) have no app_<dart>.arb in flutter/lib/l10n: "
            + ", ".join(missing)
        )
    for code in extra:
        source = DERIVED_BASE.get(code)
        if source is None:
            report.error(
                f"ARB: {code} has no entry in store/asc/locales.json and is not a "
                "language fallback"
            )
            continue
        # A language fallback is required by `flutter gen-l10n` for every locale
        # that carries a country code, and must mirror its primary variant.
        if source not in arb_files:
            report.error(f"ARB: fallback {code} mirrors {source}, which does not exist")
            continue
        if messages(read_arb(arb_files[code])) != messages(read_arb(arb_files[source])):
            report.error(
                f"ARB: fallback {code} differs from {source}; it must be a copy "
                "(rerun scripts/i18n/translate_arb.py)"
            )
        else:
            report.warn(
                f"ARB: {code} is the language fallback for {source} (not an ASC locale)"
            )


def check_arb_contents(report: Report, locales: list[dict], arb_files: dict[str, Path]) -> dict:
    template = read_arb(TEMPLATE)
    english = messages(template)
    english_meta = metadata(template)
    stats = {
        "template_keys": len(english),
        "locales": {},
    }

    # Template metadata coverage, checked once. This is the only place a missing
    # @description matters: gen-l10n reads metadata from the template alone, and
    # the template is what a translator opens for context. `english_meta` holds
    # "@key" names, so strip the prefix before comparing against `english`.
    documented = {key[1:] for key in english_meta if key.startswith("@")}
    undocumented = sorted(set(english) - documented)
    if undocumented:
        report.warn(
            f"app_en.arb: {len(undocumented)} key(s) have no @description block "
            f"(translators lose context): {', '.join(undocumented[:5])}"
        )

    for code, path in sorted(arb_files.items()):
        arb = read_arb(path)
        locale_meta = arb.get("@@locale")
        if locale_meta != code:
            report.error(f"{path.name}: @@locale is {locale_meta!r}, expected {code!r}")

        rows = messages(arb)
        missing = sorted(set(english) - set(rows))
        orphan = sorted(set(rows) - set(english))
        for key in missing[:10]:
            report.error(f"{path.name}: missing key {key}")
        if len(missing) > 10:
            report.error(f"{path.name}: missing a further {len(missing) - 10} key(s)")
        for key in orphan[:10]:
            report.error(f"{path.name}: orphan key {key} (not in app_en.arb)")
        if len(orphan) > 10:
            report.error(f"{path.name}: {len(orphan) - 10} further orphan key(s)")

        # @description blocks belong in the template only. `gen-l10n` reads
        # metadata exclusively from `app_en.arb`, and `translate_arb.py` writes
        # value-only catalogs by design (it skips every "@" key), so demanding
        # metadata in all 30 catalogs flagged work that no tool would ever
        # produce. One warning per catalog saying the same thing is noise; the
        # template's own coverage is checked once, before this loop, and that is
        # the only place a missing description costs a translator context.

        identical: list[str] = []
        for key in sorted(set(english) & set(rows)):
            source = english[key]
            value = rows[key]
            if icu_shape(source) != icu_shape(value):
                report.error(
                    f"{path.name}:{key}: placeholder/ICU mismatch "
                    f"(en {sorted(icu_shape(source)[0])} {sorted(icu_shape(source)[1])}, "
                    f"{code} {sorted(icu_shape(value)[0])} {sorted(icu_shape(value)[1])})"
                )
            # A message can have the right placeholders and still be unparseable.
            for problem in icu_problems(value):
                report.error(f"{path.name}:{key}: {problem} (gen-l10n will refuse the catalog)")
            if value.strip() == source.strip() and source.strip() not in UNTRANSLATED_ALLOWLIST:
                if not code.startswith(ENGLISH_FAMILY_PREFIX):
                    identical.append(key)

        # A handful of identical values is normal: German keeps "Orange", French
        # keeps "Photos", every language keeps "Instagram". Erroring on those
        # makes the gate noise and agents learn to ignore it. What is never
        # normal is a catalog that is mostly English, so the ratio is the hard
        # failure and the individual keys are a warning naming them.
        if identical:
            ratio = len(identical) / max(1, len(set(english) & set(rows)))
            detail = (
                f"{path.name}: {len(identical)} value(s) identical to English "
                f"({ratio:.0%}): " + ", ".join(identical[:8])
                + ("..." if len(identical) > 8 else "")
            )
            if ratio >= UNTRANSLATED_FAIL_RATIO:
                report.error(detail + " — this catalog looks untranslated")
            else:
                report.warn(detail)

        stats["locales"][code] = {
            "keys": len(rows),
            "missing": len(missing),
            "orphan": len(orphan),
            "identical_to_english": len(identical),
            # Metadata is a template concern, reported once above; per-catalog
            # counts of it were the noise this replaced.
        }
    return stats


def compare_inventory(
    report: Report,
    label: str,
    source: set[str],
    other: set[str],
    *,
    normalizer,
) -> None:
    normalized_source = {normalizer(item) for item in source}
    normalized_other = {normalizer(item) for item in other}
    missing = sorted(normalized_source - normalized_other)
    extra = sorted(normalized_other - normalized_source)
    if missing:
        report.error(
            f"{label}: {len(missing)}/{len(normalized_source)} locale(s) from "
            f"store/asc/locales.json are absent: {', '.join(missing)}"
        )
    if extra:
        report.error(
            f"{label}: {len(extra)} locale(s) present but not in store/asc/locales.json: "
            + ", ".join(extra)
        )


def identity(tag: str) -> str:
    return tag.replace("_", "-")


def main() -> int:
    parser = argparse.ArgumentParser(description="Check that every locale inventory agrees.")
    parser.add_argument("--strict", action="store_true", help="treat warnings as errors")
    parser.add_argument("--json", action="store_true", help="machine-readable summary")
    args = parser.parse_args()

    report = Report()
    locales = load_asc(report)
    asc_codes = {entry["asc"] for entry in locales}
    dart_codes = {entry["dart"] for entry in locales}

    registry = parse_registry(report)
    registry_asc = {row["asc"] for row in registry}
    registry_dart = {identity(row["dart"]) for row in registry}

    plist = parse_plist(report)
    android = parse_android(report)
    arb_files = parse_arb_files(report)
    backend = parse_backend(report)

    # The registry is Dart, so it is compared on the exact Flutter locale tag.
    compare_inventory(report, "locale_registry.dart", dart_codes, registry_dart, normalizer=identity)
    if registry_asc != asc_codes:
        missing = sorted(asc_codes - registry_asc)
        extra = sorted(registry_asc - asc_codes)
        if missing:
            report.error(f"locale_registry.dart: missing asc code(s): {', '.join(missing)}")
        if extra:
            report.error(f"locale_registry.dart: unexpected asc code(s): {', '.join(extra)}")

    # Platform files are base-language lists, so both sides normalize.
    platform_base = {base_language(code) for code in dart_codes}
    compare_inventory(report, "Info.plist CFBundleLocalizations", dart_codes, plist, normalizer=base_language)
    compare_inventory(report, "android locales_config.xml", dart_codes, android, normalizer=base_language)
    compare_inventory(
        report, "backend SUPPORTED_LANGUAGES", dart_codes, backend, normalizer=language_only
    )

    # Every locale the registry advertises must have a catalog on disk. Without
    # this, a language can vanish from the picker while every other check still
    # passes: the remaining catalogs are internally consistent, `gen-l10n` is
    # happy, and the store listing still claims 43 languages. One generator run
    # deleted 46 of 50 catalogs and nothing here noticed.
    #
    # Catalog filenames use Flutter's underscore tags (`app_en_AU.arb`) while the
    # registry is compared in the hyphenated store form, so both sides normalize.
    catalog_dart = {identity(code) for code in arb_files}
    missing_catalogs = sorted(registry_dart - catalog_dart)
    if missing_catalogs:
        report.error(
            f"{len(missing_catalogs)} locale(s) in locale_registry.dart have no ARB "
            f"catalog: {', '.join(missing_catalogs)}"
        )

    for row in registry:
        source = next((item for item in locales if item["asc"] == row["asc"]), None)
        if source is None:
            continue
        if source["rtl"] != row["rtl"]:
            report.error(
                f"locale_registry.dart: {row['asc']} rtl={row['rtl']} disagrees with "
                f"store/asc/locales.json rtl={source['rtl']}"
            )
        if source["tier"] != row["tier"]:
            report.warn(
                f"locale_registry.dart: {row['asc']} tier={row['tier']} disagrees with "
                f"store/asc/locales.json tier={source['tier']}"
            )

    check_arb_coverage(report, locales, arb_files)
    stats = check_arb_contents(report, locales, arb_files)

    summary = {
        "ok": not report.errors and not (args.strict and report.warnings),
        "sources": {
            "store/asc/locales.json": {"asc": len(asc_codes), "dart": len(dart_codes)},
            "locale_registry.dart": len(registry),
            "Info.plist": {"entries": len(plist), "base_languages": len({base_language(code) for code in plist})},
            "locales_config.xml": {"entries": len(android), "base_languages": len({base_language(code) for code in android})},
            "arb_files": len(arb_files),
            "backend SUPPORTED_LANGUAGES": len(backend),
        },
        "expected_base_languages": len(platform_base),
        "arb": stats,
        "errors": report.errors,
        "warnings": report.warnings,
    }

    if args.json:
        print(json.dumps(summary, indent=2, ensure_ascii=False))
    else:
        print("Locale inventories")
        print(f"  store/asc/locales.json      {len(asc_codes):>3} asc / {len(dart_codes)} dart")
        print(f"  locale_registry.dart        {len(registry):>3} entries")
        print(f"  Info.plist                  {len(plist):>3} entries ({len({base_language(c) for c in plist})} base languages)")
        print(f"  locales_config.xml          {len(android):>3} entries ({len({base_language(c) for c in android})} base languages)")
        print(f"  ARB catalogs                {len(arb_files):>3} files, {stats['template_keys']} keys each")
        print(f"  backend SUPPORTED_LANGUAGES {len(backend):>3} base languages")
        incomplete = [
            f"{code}={row['keys']}"
            for code, row in stats["locales"].items()
            if row["missing"] or row["orphan"]
        ]
        if incomplete:
            print("  incomplete catalogs: " + ", ".join(incomplete))
        print()
        if report.errors:
            print(f"FAIL — {len(report.errors)} error(s)")
            for message in report.errors:
                print(f"  error: {message}")
        if report.warnings:
            print(f"{len(report.warnings)} warning(s)")
            for message in report.warnings:
                print(f"  warn: {message}")
        if not report.errors and not report.warnings:
            print("OK — all inventories agree.")

    if report.errors:
        return 1
    if args.strict and report.warnings:
        print("\n--strict: warnings are errors", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
