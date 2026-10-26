#!/usr/bin/env python3
"""Make every ARB catalog structurally complete, using English as the filler.

This exists because `check_locales.py` treats a catalog missing a key as an
error, and because a partly-filled catalog is confusing to hand to a translator.

It is worth being precise about what does *not* break: `flutter gen-l10n` falls
back to the English template for any key a catalog lacks, and records it in
`build/untranslated.json`. So a missing key compiles and renders English. What
does break is a *missing catalog file* — gen-l10n never deletes stale output, so
an orphaned `app_localizations_<lang>.dart` keeps extending `AppLocalizations`
and `flutter analyze` fails with `non_abstract_class_inherits_abstract_member`.
Clearing the generated directory fixes that, not this script.

Any value this writes is identical to English and therefore shows up in
`check_locales.py`'s "identical to English" warning until `translate_arb.py`
replaces it.

Run:

    python3 scripts/i18n/sync_arb_keys.py            # report only
    python3 scripts/i18n/sync_arb_keys.py --apply    # fill gaps with English
"""

from __future__ import annotations

import argparse
import collections
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
L10N = ROOT / "flutter" / "lib" / "l10n"
TEMPLATE = L10N / "app_en.arb"


def load(path: pathlib.Path) -> collections.OrderedDict:
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=collections.OrderedDict)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    template = load(TEMPLATE)
    # Keep the template's own ordering: gen-l10n output and review diffs are far
    # easier to read when every catalog shares one key order.
    ordered_keys = [k for k in template if not k.startswith("@")]
    catalogs = sorted(p for p in L10N.glob("app_*.arb") if p.name != TEMPLATE.name)

    total_gaps = 0
    touched = 0
    for path in catalogs:
        data = load(path)
        missing = [k for k in ordered_keys if k not in data]
        if not missing:
            continue
        total_gaps += len(missing)
        print(f"  {path.stem:20} missing {len(missing):3} key(s): "
              f"{', '.join(missing[:4])}{' …' if len(missing) > 4 else ''}")
        if not args.apply:
            continue
        for key in missing:
            # Value only. `@description` blocks live in app_en.arb — that is the
            # only place gen-l10n reads metadata from, and `translate_arb.py`
            # skips every "@" key when it writes a catalog, so copying metadata
            # here would be undone by the next translation run.
            data[key] = template[key]
        # Rebuild in template order so the file reads the same as every other.
        # Metadata is preserved if a catalog happens to carry it, but never added.
        rebuilt = collections.OrderedDict()
        if "@@locale" in data:
            rebuilt["@@locale"] = data["@@locale"]
        for key in ordered_keys:
            if key in data:
                rebuilt[key] = data[key]
            if "@" + key in data:
                rebuilt["@" + key] = data["@" + key]
        for key, value in data.items():  # preserve any stray keys
            if key not in rebuilt:
                rebuilt[key] = value
        path.write_text(json.dumps(rebuilt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        touched += 1

    if not total_gaps:
        print(f"OK — all {len(catalogs)} catalog(s) carry all {len(ordered_keys)} keys.")
        return 0

    print(f"\n{total_gaps} gap(s) across {len(catalogs)} catalog(s).")
    if not args.apply:
        print("Report only. Re-run with --apply to fill them with the English source.")
        return 0
    print(f"Filled {touched} catalog(s) with English. Run "
          "`python3 scripts/i18n/translate_arb.py` to translate them.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
