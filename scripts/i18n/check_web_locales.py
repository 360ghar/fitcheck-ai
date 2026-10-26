#!/usr/bin/env python3
"""Fail when the web locale inventories drift apart, or a catalog breaks ICU.

The web app ships 43 base languages. That number lives in three places that can
silently disagree:

* `backend/app/core/i18n.py::SUPPORTED_LANGUAGES` — what `PUT /api/v1/users/settings`
  accepts, and therefore what the phone app can store,
* `store/asc/locales.json` — the 50 App Store storefronts the release targets,
* `frontend/src/i18n/localeMeta.ts` and `frontend/src/i18n/locales/*.json` —
  what the web client can actually render.

Any one drifting produces the same bug from a different direction: the settings
picker offers Hindi, the backend normalizes it back to English, and the user's
phone and browser disagree about which language they chose — with nothing in CI
to notice.

On top of that it checks the things a translation can silently break:

* a key missing from a catalog (that string renders English mid-screen),
* an orphan key (a translator was paid for a string nobody shows),
* a dropped `{count}` or `{year}`, or a plural block that lost its `other`
  branch (renders a literal brace, or throws inside `intl-messageformat`),
* a catalog left byte-identical to English (an untranslated file that looks
  finished),
* a `t('…')` id in the source that no catalog defines (renders the raw id).

Stdlib only, so it runs anywhere CI does. Exit 0 means the tree is coherent.

Usage:
    python3 scripts/i18n/check_web_locales.py
    python3 scripts/i18n/check_web_locales.py --strict    # warnings fail too
    python3 scripts/i18n/check_web_locales.py --json      # machine-readable
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WEB_I18N = ROOT / "frontend" / "src" / "i18n"
LOCALES_DIR = WEB_I18N / "locales"
SOURCE = LOCALES_DIR / "en.json"
CACHE = WEB_I18N / ".translations.json"
META_TS = WEB_I18N / "localeMeta.ts"
FRONTEND_SRC = ROOT / "frontend" / "src"
ASC_FILE = ROOT / "store" / "asc" / "locales.json"
BACKEND_I18N = ROOT / "backend" / "app" / "core" / "i18n.py"

# Values that are correctly identical to English in every language: the brand,
# the two plan names, and platform names. Anything else byte-identical to the
# English source is an untranslated row that looks done.
UNTRANSLATED_ALLOWLIST = {
    "FitCheck AI",
    "Pro",
    "Plus",
    "AI",
    "Google",
    "Instagram",
    "LinkedIn",
    "FitCheck",
}

# A catalog may legitimately contain a handful of identical values (a language
# that borrows a loanword is not a bug). More than this is a stall.
IDENTICAL_WARN_RATIO = 0.05

# Above this many missing keys, report the catalog's coverage as one error with
# the resume command instead of one error per key. Below it, name every key.
WIDE_GAP_MAX_KEYS = 12

ICU_TYPES = ("plural", "selectordinal", "select")

_BACKEND_ENTRY = re.compile(r'\("([a-z]{2,3})",\s*"([^"]+)"\)')
_META_ENTRY = re.compile(
    r"\{\s*code:\s*'([a-z]{2,3})',\s*"
    r"native:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"english:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"rtl:\s*(true|false)\s*\}"
)
# `t('ns.key')` / `tRich('ns.key')`, and the variable forms used where the id is
# computed (`t(tool.nameKey)`); those are checked through the `*Key` literals.
_T_CALL = re.compile(r"\bt(?:Rich)?\(\s*['\"]([A-Za-z0-9_.-]+)['\"]")
_KEY_FIELD = re.compile(r"\b\w*[Kk]ey:\s*['\"]([a-z][A-Za-z0-9_.-]*\.[A-Za-z0-9_.-]+)['\"]")


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.stats: dict = {}

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)


# `icu_shape` is defined here and imported by translate_arb.py too — one ICU
# parser for the whole repo. Keep any change to it in sync with the ARB gate.
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


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def backend_languages(report: Report) -> dict[str, str]:
    """`SUPPORTED_LANGUAGES` as {code: English name}, parsed, not imported.

    The backend lives behind a venv; a static checker must not need the API's
    dependencies installed to say what the API accepts.
    """
    if not BACKEND_I18N.exists():
        report.error(f"{rel(BACKEND_I18N)} is missing")
        return {}
    text = BACKEND_I18N.read_text(encoding="utf-8")
    start = text.find("SUPPORTED_LANGUAGES")
    if start == -1:
        report.error(f"{rel(BACKEND_I18N)} has no SUPPORTED_LANGUAGES")
        return {}
    end = text.find("\n)", start)
    body = text[start : end if end != -1 else len(text)]
    found = dict(_BACKEND_ENTRY.findall(body))
    if not found:
        report.error(f"{rel(BACKEND_I18N)}: could not parse SUPPORTED_LANGUAGES")
    return found


def asc_languages(report: Report) -> dict[str, dict]:
    """Base language -> one representative store locale row, plus rtl flags.

    `pt-BR` and `pt-PT` collapse to `pt`; the first row for a base language is
    its primary market and supplies the native name. `rtl` is OR-ed across a
    base language's rows, because a script is right-to-left or it is not.
    """
    if not ASC_FILE.exists():
        report.error(f"{rel(ASC_FILE)} is missing")
        return {}
    data = read_json(ASC_FILE)
    locales = data.get("locales") or []
    if not locales:
        report.error(f"{rel(ASC_FILE)}: no locales")
        return {}
    out: dict[str, dict] = {}
    for entry in locales:
        base = entry["dart"].split("_")[0].split("-")[0].lower()
        row = out.get(base)
        if row is None:
            out[base] = {
                "native": entry["native"] if base != "en" else "English",
                "english": entry["english"],
                "rtl": bool(entry.get("rtl")),
                "asc": entry["asc"],
            }
        elif entry.get("rtl"):
            row["rtl"] = True
    return out


def meta_rows(report: Report) -> dict[str, dict]:
    if not META_TS.exists():
        report.error(f"{rel(META_TS)} is missing")
        return {}
    text = META_TS.read_text(encoding="utf-8")
    rows: dict[str, dict] = {}
    for code, native, english, rtl in _META_ENTRY.findall(text):
        if code in rows:
            report.error(f"{rel(META_TS)}: duplicate entry for {code}")
        rows[code] = {
            "native": native.replace("\\'", "'"),
            "english": english.replace("\\'", "'"),
            "rtl": rtl == "true",
        }
    if not rows:
        report.error(f"{rel(META_TS)}: could not parse the LOCALES table")
    return rows


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def check_inventory(
    report: Report,
    backend: dict[str, str],
    asc: dict[str, dict],
    meta: dict[str, dict],
    catalogs: dict[str, Path],
) -> None:
    """The three language lists must be the same list."""
    backend_codes = set(backend)
    asc_codes = {code for code in asc if code != "en"}
    catalog_codes = {code for code in catalogs if code != "en"}
    meta_codes = {code for code in meta if code != "en"}
    expected = backend_codes - {"en"}

    for label, found in (
        ("store/asc/locales.json", asc_codes),
        ("frontend/src/i18n/locales/*.json", catalog_codes),
        ("frontend/src/i18n/localeMeta.ts", meta_codes),
    ):
        missing = sorted(expected - found)
        extra = sorted(found - expected)
        if missing:
            report.error(
                f"{label}: missing {len(missing)} language(s) the backend accepts: "
                + ", ".join(missing)
                + " — add the catalog/meta row, or remove the entry from "
                "backend/app/core/i18n.py::SUPPORTED_LANGUAGES if it is no longer shipped."
            )
        if extra:
            report.error(
                f"{label}: has {len(extra)} language(s) the backend does not accept: "
                + ", ".join(extra)
                + " — the API normalizes those to English, so a user picking one gets "
                "English with their choice silently ignored."
            )

    if not catalogs.get("en") and "en" not in catalogs:
        report.error("frontend/src/i18n/locales/en.json is the source catalog and is missing")

    # English itself must be first in the meta table and present in every list.
    if "en" not in meta:
        report.error(f"{rel(META_TS)}: no English entry")
    if "en" not in backend:
        report.error(f"{rel(BACKEND_I18N)}: no English entry")

    # Native names and RTL flags come from the store table; the web must not
    # disagree, or the picker names a language differently than the App Store.
    for code, row in sorted(meta.items()):
        if code == "en":
            continue
        source = asc.get(code)
        if not source:
            continue
        if row["native"] != source["native"]:
            report.warn(
                f"{rel(META_TS)}: {code} native name is {row['native']!r} but "
                f"store/asc/locales.json says {source['native']!r}"
            )
        if row["rtl"] != source["rtl"]:
            report.error(
                f"{rel(META_TS)}: {code} rtl is {row['rtl']} but "
                f"store/asc/locales.json says {source['rtl']}"
            )

    report.stats["languages"] = {
        "backend": len(backend),
        "asc_base": len(asc),
        "catalogs": len(catalogs),
        "meta": len(meta),
    }


def check_catalogs(report: Report, english: dict[str, str], catalogs: dict[str, Path]) -> None:
    english_keys = set(english)
    per_locale: dict[str, dict] = {}

    for code, path in sorted(catalogs.items()):
        if code == "en":
            continue
        try:
            rows = read_json(path)
        except json.JSONDecodeError as error:
            report.error(f"{rel(path)}: invalid JSON ({error})")
            continue
        if not isinstance(rows, dict):
            report.error(f"{rel(path)}: catalog must be a flat JSON object")
            continue

        # The web equivalent of a wrong `@@locale`: a catalog whose filename and
        # contents disagree about which language it is. The translator writes one
        # file per base code, so any metadata key here is a copy-paste artifact.
        meta_keys = sorted(key for key in rows if key.startswith("@"))
        if meta_keys:
            report.error(
                f"{rel(path)}: contains metadata key(s) {', '.join(meta_keys)}; "
                "web catalogs are flat id -> message objects with no @@locale."
            )

        missing = sorted(english_keys - set(rows))
        orphan = sorted(set(rows) - english_keys)

        # A catalog that is broadly incomplete is ONE problem with one fix, not
        # N problems: printing 600 "missing key" lines buries the three real
        # bugs elsewhere in the output. Anything under the threshold is small
        # enough that each key should be named (a rename that lost one string
        # is exactly what a per-key line is for).
        wide_gap = len(missing) > WIDE_GAP_MAX_KEYS
        if wide_gap:
            coverage = 100.0 * (len(english_keys) - len(missing)) / max(1, len(english_keys))
            report.error(
                f"{rel(path)}: {len(missing)} of {len(english_keys)} key(s) untranslated "
                f"({coverage:.0f}% coverage) — those strings render English in {code}. "
                f"Every missing key falls back to en.json, so the UI is readable but "
                f"only partly localized. Finish it with: "
                f"python3 scripts/i18n/translate_web.py --locale {code}"
            )
        else:
            for key in missing:
                report.error(
                    f"{rel(path)}: missing key {key} — this string renders English in "
                    f"{code}. Run: python3 scripts/i18n/translate_web.py --locale {code}"
                )
        for key in orphan[:10]:
            report.error(
                f"{rel(path)}: orphan key {key} is not in en.json — remove it from the "
                "catalog, or the string was deleted from the source and the translator "
                "will keep paying for it."
            )
        if len(orphan) > 10:
            report.error(f"{rel(path)}: {len(orphan) - 10} further orphan key(s)")

        identical: list[str] = []
        for key in sorted(english_keys & set(rows)):
            source = english[key]
            value = rows[key]
            expected_names, expected_blocks = icu_shape(source)
            names, blocks = icu_shape(value)
            if names != expected_names:
                report.error(
                    f"{rel(path)}: {key} placeholder mismatch — en has "
                    f"{sorted(expected_names)}, {code} has {sorted(names)}. A missing "
                    "placeholder renders a literal brace to the user."
                )
                continue
            if blocks != expected_blocks:
                report.error(
                    f"{rel(path)}: {key} ICU block mismatch — en has "
                    f"{sorted(expected_blocks)}, {code} has {sorted(blocks)}"
                )
                continue
            if value.count("{") != value.count("}"):
                report.error(f"{rel(path)}: {key} has unbalanced braces")
                continue
            if value == source and value not in UNTRANSLATED_ALLOWLIST:
                identical.append(key)

        if identical:
            ratio = len(identical) / max(1, len(english_keys))
            message = (
                f"{rel(path)}: {len(identical)} value(s) still byte-identical to English: "
                + ", ".join(identical[:8])
                + ("…" if len(identical) > 8 else "")
            )
            # The same string in both languages is sometimes correct (a loanword,
            # "Vintage", "Pro"). A whole catalog identical to English is not.
            if ratio >= 0.5:
                report.error(
                    message
                    + " — the catalog looks untranslated. "
                    f"Run: python3 scripts/i18n/translate_web.py --locale {code} --force"
                )
            elif ratio > IDENTICAL_WARN_RATIO:
                report.warn(message)

        per_locale[code] = {
            "keys": len(rows),
            "identical_to_english": len(identical),
        }

    report.stats["catalogs"] = per_locale
    report.stats["source_keys"] = len(english)


def check_usage(report: Report, english: dict[str, str]) -> None:
    """Every `t('…')` in the source must exist, and every key should be used.

    A missing id renders the raw id string (the `t` wrapper passes the id as the
    message key, and react-intl falls back to it), which is how a rename gets
    shipped as `settings.languageDescrption` on a settings screen.
    """
    used: set[str] = set()
    files = 0
    for path in sorted(FRONTEND_SRC.rglob("*")):
        if path.suffix not in {".ts", ".tsx"}:
            continue
        if "__tests__" in path.parts or path.name.endswith((".test.ts", ".test.tsx")):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        files += 1
        used.update(_T_CALL.findall(text))
        used.update(_KEY_FIELD.findall(text))

    # `taxonomy.<group>.<value>` ids are built from a record of known values in
    # `i18n/taxonomy.ts`; count them as used when the module is present.
    for key in english:
        if key.startswith("taxonomy."):
            used.add(key)

    unknown = sorted(key for key in used if key not in english)
    for key in unknown[:20]:
        report.error(
            f"source uses message id {key!r} which is not in "
            f"frontend/src/i18n/locales/en.json — the UI will render the raw id."
        )
    if len(unknown) > 20:
        report.error(f"a further {len(unknown) - 20} unknown message id(s) are in use")

    unused = sorted(key for key in english if key not in used)
    # A few keys are referenced through `t(...)` on a variable in code this
    # scanner cannot follow; report them, do not fail on them.
    if unused:
        report.warn(
            f"{len(unused)} key(s) in en.json are not referenced anywhere in "
            f"frontend/src: {', '.join(unused[:10])}"
            + ("…" if len(unused) > 10 else "")
        )

    report.stats["usage"] = {
        "scanned_files": files,
        "ids_used": len(used),
        "ids_defined": len(english),
        "ids_unknown": len(unknown),
        "ids_unused": len(unused),
    }


def check_cache(report: Report, english: dict[str, str]) -> None:
    """Warn when the translation cache is behind the source catalog."""
    if not CACHE.exists():
        report.warn(
            f"{rel(CACHE)} is missing — catalogs were written without a cache, so the "
            "next run re-pays for every string."
        )
        return
    try:
        cache = read_json(CACHE)
    except json.JSONDecodeError as error:
        report.error(f"{rel(CACHE)}: invalid JSON ({error})")
        return

    import hashlib

    def source_hash(value: str) -> str:
        return hashlib.sha256(value.encode("utf-8")).hexdigest()[:12]

    stale: dict[str, int] = {}
    for code, rows in cache.items():
        if code.startswith("_") or not isinstance(rows, dict):
            continue
        behind = sum(
            1
            for key, value in english.items()
            if not rows.get(key) or rows[key].get("_src") != source_hash(value)
        )
        if behind:
            stale[code] = behind
    if stale:
        total = sum(stale.values())
        report.warn(
            f"translation cache is behind en.json for {len(stale)} locale(s), "
            f"{total} string(s) total — run scripts/i18n/translate_web.py to catch up."
        )
    report.stats["cache_locales"] = len(
        [code for code in cache if not code.startswith("_")]
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="warnings fail too")
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    args = parser.parse_args()

    report = Report()

    if not SOURCE.exists():
        report.error(f"{rel(SOURCE)} is missing — it is the English source catalog")
        english: dict[str, str] = {}
    else:
        try:
            english = read_json(SOURCE)
        except json.JSONDecodeError as error:
            report.error(f"{rel(SOURCE)}: invalid JSON ({error})")
            english = {}
        if english and not isinstance(english, dict):
            report.error(f"{rel(SOURCE)}: must be a flat JSON object")
            english = {}

    catalogs: dict[str, Path] = {}
    if LOCALES_DIR.exists():
        for path in sorted(LOCALES_DIR.glob("*.json")):
            catalogs[path.stem] = path
    else:
        report.error(f"{rel(LOCALES_DIR)} is missing")

    backend = backend_languages(report)
    asc = asc_languages(report)
    meta = meta_rows(report)

    if english:
        check_inventory(report, backend, asc, meta, catalogs)
        check_catalogs(report, english, catalogs)
        check_usage(report, english)
        check_cache(report, english)

    ok = not report.errors and (not args.strict or not report.warnings)

    if args.json:
        print(
            json.dumps(
                {
                    "ok": ok,
                    "errors": report.errors,
                    "warnings": report.warnings,
                    "stats": report.stats,
                },
                indent=2,
                ensure_ascii=False,
            )
        )
        return 0 if ok else 1

    if report.errors:
        print(f"FAIL — {len(report.errors)} error(s):\n", file=sys.stderr)
        for message in report.errors:
            print(f"  ✗ {message}", file=sys.stderr)
        print("", file=sys.stderr)
    if report.warnings:
        print(f"{len(report.warnings)} warning(s):\n", file=sys.stderr)
        for message in report.warnings:
            print(f"  · {message}", file=sys.stderr)
        print("", file=sys.stderr)

    languages = report.stats.get("languages", {})
    usage = report.stats.get("usage", {})
    if ok:
        print(
            f"OK — {languages.get('catalogs', 0)} web catalogs "
            f"({languages.get('catalogs', 0) - 1} translated) agreeing with "
            f"{languages.get('backend', 0)} backend languages and "
            f"{languages.get('asc_base', 0)} App Store base locales; "
            f"{report.stats.get('source_keys', 0)} source keys, "
            f"{usage.get('ids_used', 0)} referenced in {usage.get('scanned_files', 0)} files."
        )
    else:
        print(
            "Web locale check failed. Next step: fix the errors above "
            "(a missing catalog → run scripts/i18n/translate_web.py; a missing key in "
            "en.json → add the message; an inventory mismatch → align "
            "backend/app/core/i18n.py, store/asc/locales.json and localeMeta.ts).",
            file=sys.stderr,
        )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
