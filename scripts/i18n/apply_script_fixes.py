#!/usr/bin/env python3
"""Validate and land corrected strings produced outside the repo.

`repair_scripts.py` repairs with the model. When the strings are being rewritten
elsewhere — by a subagent, or by hand — the corrections arrive as flat JSON files
and still have to clear the same bar before they touch a catalog. This script is
that gate: it accepts a directory of `<surface>_<locale>.json` files, checks every
value, writes only the ones that pass, and reports the rest by reason.

Acceptance is deliberately strict, because the whole point is that a plausible
looking value is how the wrong-script defect got in:

* every character belongs to the locale's script (`check_scripts.scan_text`)
* the ICU placeholders and plural selectors are unchanged (`icu_shape`)
* the value is not empty, and is not the English source verbatim
* plural selectors are the ones `flutter gen-l10n` accepts (never `=5`)

Nothing is written unless at least one value is accepted, so a bad batch is a
no-op rather than a partial overwrite.

Usage
-----
    python3 scripts/i18n/apply_script_fixes.py --from /tmp/scriptfix/out
    python3 scripts/i18n/apply_script_fixes.py --from /tmp/scriptfix/out --apply
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from check_scripts import scan_text  # noqa: E402
from repair_scripts import icu_shape  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
ARB_DIR = ROOT / "flutter" / "lib" / "l10n"
WEB_DIR = ROOT / "frontend" / "src" / "i18n" / "locales"
STORE = ROOT / "store" / "asc" / "listings.json"


def plural_selectors(value: str) -> set[str]:
    """Every explicit `=N` selector. Only `=0`, `=1`, `=2` are legal in gen-l10n.

    This is the TD-138 failure mode: ICU itself accepts `=5`, Flutter's
    `gen-l10n` rejects the whole project, so one bad selector in one locale stops
    every locale from generating. CLDR keywords (one/few/many/other) are always
    fine and need no checking.
    """
    return set(re.findall(r"=\d+", value))


def validate(value: str, current: str, english: str, locale: str) -> list[str]:
    problems: list[str] = []
    if not isinstance(value, str) or not value.strip():
        return ["empty"]
    if english and value.strip() == english.strip():
        problems.append("identical to English")
    foreign = scan_text(value, locale)
    if foreign:
        scripts = sorted({hit["script"] for hit in foreign})
        problems.append(f"wrong script ({', '.join(scripts)}): "
                        + ", ".join(sorted({hit['char'] for hit in foreign}))[:60])
    if icu_shape(value) != icu_shape(current):
        problems.append(f"placeholder shape {icu_shape(current)} -> {icu_shape(value)}")
    bad = plural_selectors(value) - {"=0", "=1", "=2"}
    if bad:
        problems.append(f"invalid plural selector(s) {', '.join(sorted(bad))}")
    return problems


def target_for(surface: str, locale: str) -> Path | None:
    if surface == "arb":
        return ARB_DIR / f"app_{locale.replace('-', '_')}.arb"
    if surface == "web":
        return WEB_DIR / f"{locale}.json"
    if surface == "listings":
        return STORE
    return None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--from", dest="source", default="/tmp/scriptfix/out")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args(argv)

    source = Path(args.source)
    if not source.is_dir():
        print(f"no such directory: {source}")
        return 1

    english_arb = json.loads((ARB_DIR / "app_en.arb").read_text(encoding="utf-8"))
    english_web = json.loads((WEB_DIR / "en.json").read_text(encoding="utf-8"))
    listings = json.loads(STORE.read_text(encoding="utf-8")) if STORE.exists() else {}
    english_listings = listings.get("en-US", {})

    accepted: dict[Path, dict] = defaultdict(dict)
    listing_accepts: list[tuple[str, str, str]] = []
    rejected: list[str] = []
    total_ok = 0

    for path in sorted(source.glob("*.json")):
        stem = path.stem
        if "_" not in stem:
            continue
        surface, locale = stem.split("_", 1)
        target = target_for(surface, locale)
        if target is None:
            rejected.append(f"{path.name}: unknown surface")
            continue
        if surface == "arb":
            current = json.loads(target.read_text(encoding="utf-8"))
            english = english_arb
        elif surface == "web":
            current = json.loads(target.read_text(encoding="utf-8"))
            english = english_web
        else:
            current = listings.get(locale, {})
            english = english_listings

        incoming = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(incoming, dict):
            rejected.append(f"{path.name}: not an object")
            continue

        ok = 0
        for key, value in incoming.items():
            if key not in current:
                rejected.append(f"{path.name}/{key}: key not in the catalog")
                continue
            problems = validate(value, current[key], english.get(key, ""), locale)
            if problems:
                rejected.append(f"{path.name}/{key}: {', '.join(problems)}")
                continue
            if surface == "listings":
                listing_accepts.append((locale, key, value))
            else:
                accepted[target][key] = value
            ok += 1
        total_ok += ok
        print(f"  {path.name:<28} accepted {ok:>2}/{len(incoming)}")

    print(f"\naccepted {total_ok} value(s), rejected {len(rejected)}")
    if rejected:
        for row in rejected[:25]:
            print(f"  REJECT {row}")
        if len(rejected) > 25:
            print(f"  … and {len(rejected) - 25} more")

    if not args.apply:
        print("\nDry run. Add --apply to write.")
        return 0 if not rejected else 1

    written = 0
    for target, updates in accepted.items():
        data = json.loads(target.read_text(encoding="utf-8"))
        data.update(updates)
        target.write_text(
            json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        written += len(updates)
        print(f"  wrote {len(updates):>2} into {target.relative_to(ROOT)}")
    if listing_accepts:
        for locale, key, value in listing_accepts:
            listings.setdefault(locale, {})[key] = value
        STORE.write_text(json.dumps(listings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        written += len(listing_accepts)
        print(f"  wrote {len(listing_accepts)} into store/asc/listings.json")

    print(f"\nwrote {written} value(s)")
    return 0 if not rejected else 1


if __name__ == "__main__":
    sys.exit(main())
