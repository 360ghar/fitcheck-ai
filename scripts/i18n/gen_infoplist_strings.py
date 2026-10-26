#!/usr/bin/env python3
"""Generate `InfoPlist.strings` for every shipped language from the ARB catalogs.

iOS does not read the app's ARB catalogs. A permission prompt's text comes from
`NSCameraUsageDescription` in `Info.plist`, and the only way to show it in another
language is a `Resources/<lang>.lproj/InfoPlist.strings` file. Without one, a user
who picks Hindi gets a Hindi app and then an English camera prompt — in the first
minute of use, which is worse than a stray English label deeper in the app.

The ARB catalogs are the single source of truth for these three strings:
`permissionCameraUsage`, `permissionPhotoLibraryUsage` and
`permissionPhotoLibraryAddUsage` carry the same wording as `Info.plist`, and the
translator pipeline already maintains them across all 49 locales. This script
projects them into the format Xcode expects.

Run:

    python3 scripts/i18n/gen_infoplist_strings.py            # report
    python3 scripts/i18n/gen_infoplist_strings.py --apply    # write .lproj files
"""

from __future__ import annotations

import argparse
import json
import pathlib
import plistlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
L10N = ROOT / "flutter" / "lib" / "l10n"
INFO_PLIST = ROOT / "flutter" / "ios" / "Runner" / "Info.plist"
RESOURCES = ROOT / "flutter" / "ios" / "Runner"

# ARB key -> the Info.plist key it must match, and the .strings key.
MAPPING = [
    ("permissionCameraUsage", "NSCameraUsageDescription"),
    ("permissionPhotoLibraryUsage", "NSPhotoLibraryUsageDescription"),
    ("permissionPhotoLibraryAddUsage", "NSPhotoLibraryAddUsageDescription"),
]

# Flutter's Dart locale codes are not always Xcode's .lproj names.
# gen-l10n uses an underscore (`zh_Hans`, `en_GB`); Apple uses a hyphen.
LPROJ_NAME = {
    "zh_Hans": "zh-Hans",
    "zh_Hant": "zh-Hant",
    "en_GB": "en-GB",
    "en_AU": "en-AU",
    "en_CA": "en-CA",
    "es_MX": "es-MX",
    "fr_CA": "fr-CA",
    "pt_BR": "pt-BR",
    "pt_PT": "pt-PT",
}


def lproj(code: str) -> str:
    return LPROJ_NAME.get(code, code)


def escape(value: str) -> str:
    """`.strings` is a quoted C-string format: quotes and backslashes escape."""
    return value.replace("\\", "\\\\").replace('"', '\\"')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    if not INFO_PLIST.exists():
        print(f"missing {INFO_PLIST}", file=sys.stderr)
        return 1

    with INFO_PLIST.open("rb") as handle:
        plist = plistlib.load(handle)
    english = json.loads((L10N / "app_en.arb").read_text(encoding="utf-8"))

    # The ARB must agree with Info.plist, or the app would show one wording in
    # English and a different one in translation. Fail loudly instead of writing
    # a mismatch, because nobody reads a permission string until a user is
    # staring at a dialog they did not expect.
    mismatched = []
    for key, plist_key in MAPPING:
        source = plist.get(plist_key)
        if source is None:
            mismatched.append(f"{plist_key} missing from Info.plist")
            continue
        if source != english.get(key):
            mismatched.append(
                f"{key} does not match {plist_key}:\n"
                f"    Info.plist: {source!r}\n"
                f"    app_en.arb: {english.get(key)!r}"
            )
    if mismatched:
        print("Refusing to generate — source of truth disagrees:", file=sys.stderr)
        for item in mismatched:
            print(f"  {item}", file=sys.stderr)
        return 1

    catalogs = sorted(p for p in L10N.glob("app_*.arb") if p.name != "app_en.arb")
    written = 0
    missing = []
    for path in catalogs:
        code = path.stem.replace("app_", "")
        data = json.loads(path.read_text(encoding="utf-8"))
        entries = [(plist_key, data[key]) for key, plist_key in MAPPING if data.get(key)]
        if len(entries) != len(MAPPING):
            missing.append(code)
            continue
        target = RESOURCES / f"{lproj(code)}.lproj" / "InfoPlist.strings"
        body = "".join(
            f'"{plist_key}" = "{escape(value)}";\n' for plist_key, value in entries
        )
        if args.apply:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(body, encoding="utf-8")
        written += 1
        print(f"  {code:9} -> {target.relative_to(ROOT)}")

    print(
        f"\n{len(MAPPING)} string(s) x {written} locale(s)"
        + (f", {len(missing)} skipped (missing ARB keys)" if missing else "")
    )
    if missing:
        print(f"  skipped: {', '.join(missing)}")
    if not args.apply:
        print("Report only. Re-run with --apply to write the .lproj files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
