#!/usr/bin/env python3
"""Fail when the Flutter app gains physical-direction layout code.

The App Store description promises "right-to-left layouts for Arabic, Hebrew
and Urdu", and the app ships `ar-SA`, `he` and `ur-PK`. Flutter mirrors a layout
automatically only when the code uses *directional* APIs. `EdgeInsets.only(left:)`
stays on the physical left under RTL, so padding, icons and text land on the
wrong side.

This is a ratchet, not a ban:

* `scripts/i18n/rtl_baseline.json` records the physical-direction call sites
  that exist today, keyed by file and normalised source line.
* Any call site not in the baseline fails the check, so new code cannot add
  violations.
* When a baseline entry disappears the check reports it as "cleared" so the
  baseline can be trimmed. `--write-baseline` rewrites it from the current tree.

Run:

    python3 scripts/i18n/check_rtl.py                 # gate
    python3 scripts/i18n/check_rtl.py --write-baseline # re-baseline after fixing
    python3 scripts/i18n/check_rtl.py --list          # show every site
"""

from __future__ import annotations

import argparse
import collections
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
FLUTTER_LIB = ROOT / "flutter" / "lib"
BASELINE = ROOT / "scripts" / "i18n" / "rtl_baseline.json"

# Directories that hold no renderable layout, or that are generated.
SKIP_DIRS = ("l10n/generated",)
SKIP_SUFFIXES = (".freezed.dart", ".g.dart", ".gr.dart", ".config.dart")

# Physical APIs that Flutter does *not* mirror under RTL, paired with the
# directional replacement the author should use instead.
RULES: list[tuple[str, re.Pattern[str], str]] = [
    (
        "insets",
        re.compile(r"EdgeInsets\.only\(\s*(left|right)\s*:"),
        "EdgeInsetsDirectional.only(start:|end:)",
    ),
    (
        "align",
        re.compile(r"\bAlignment\.(centerLeft|centerRight|topLeft|topRight|"
                   r"bottomLeft|bottomRight)\b"),
        "AlignmentDirectional.*",
    ),
    (
        "text-align",
        re.compile(r"\bTextAlign\.(left|right)\b"),
        "TextAlign.start / .end",
    ),
    (
        "positioned",
        re.compile(r"\bPositioned\(\s*(left|right)\s*:"),
        "Positioned.directional(textDirection:, start:, end:)",
    ),
    (
        "border",
        re.compile(r"\bBorder\.(?:only|symmetric)\([^)]*\b(left|right)\s*="),
        "BorderDirectional(... start:, end:)",
    ),
    (
        "clip",
        re.compile(r"\bClipRect\(\s*clipBehavior:[^)]*\b(antiAliasWithSaveLayer)?\b"),
        "",  # placeholder never matched; kept out of the reported rule set
    ),
]

# A comment on the same line or the line above may justify a physical value,
# e.g. an arrow that must always point right. Mark it and the check ignores it.
ALLOW_MARKER = "rtl-allow:"


def _is_skipped(path: pathlib.Path) -> bool:
    posix = path.as_posix()
    if any(d in posix for d in SKIP_DIRS):
        return True
    return path.name.endswith(SKIP_SUFFIXES)


def _normalise(line: str) -> str:
    """Strip indentation and collapse whitespace so edits above do not matter."""
    return " ".join(line.split())


# `EdgeInsets.fromLTRB(l, t, r, b)` is the most common physical inset API in
# Flutter and the per-line rules above cannot see it: it takes four positional
# arguments, so there is no `left:` label to match, and a symmetric one is
# harmless. It needs its own whole-file pass that compares the first and third
# arguments. A call whose edges differ puts the extra space on the wrong side
# under RTL, which is the single most common way an Arabic layout looks broken.
_FROM_LTRB = re.compile(r"EdgeInsets\.fromLTRB\(([^()]*(?:\([^()]*\)[^()]*)*)\)")


def _split_args(blob: str) -> list[str]:
    args: list[str] = []
    depth = 0
    current = ""
    for char in blob:
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        if char == "," and depth == 0:
            args.append(current.strip())
            current = ""
        else:
            current += char
    if current.strip():
        args.append(current.strip())
    return args


def scan_from_ltrb(lines: list[str]) -> list[dict[str, object]]:
    """Report `fromLTRB` calls whose left and right values differ."""
    source = "\n".join(lines)
    sites: list[dict[str, object]] = []
    for match in _FROM_LTRB.finditer(source):
        args = _split_args(match.group(1))
        if len(args) != 4:
            continue
        left, right = args[0], args[2]
        if left == right:
            continue
        line_no = source.count("\n", 0, match.start()) + 1
        window = lines[max(0, line_no - 2) : line_no + 4]
        if any(ALLOW_MARKER in line for line in window):
            continue
        sites.append(
            {
                "rule": "from-ltrb",
                "line": line_no,
                "code": _normalise(match.group(0).split("\n")[0]),
                "use": (
                    "EdgeInsetsDirectional.only(start:, top:, end:, bottom:) "
                    f"— left={left} right={right} are unequal"
                ),
            }
        )
    return sites


def scan() -> tuple[dict[str, list[dict[str, object]]], int]:
    """Return {relative file: [sites]} plus the number of files scanned."""
    found: dict[str, list[dict[str, object]]] = {}
    scanned = 0
    for path in sorted(FLUTTER_LIB.rglob("*.dart")):
        if _is_skipped(path):
            continue
        scanned += 1
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue
        rel = path.relative_to(ROOT).as_posix()
        found.setdefault(rel, []).extend(scan_from_ltrb(lines))
        for index, line in enumerate(lines):
            stripped = line.lstrip()
            if stripped.startswith("//") or stripped.startswith("///"):
                continue
            code = line.split("//", 1)[0]
            for rule, pattern, suggestion in RULES:
                if not suggestion or not pattern.search(code):
                    continue
                if ALLOW_MARKER in line or (
                    index and ALLOW_MARKER in lines[index - 1]
                ):
                    continue
                found.setdefault(rel, []).append(
                    {
                        "rule": rule,
                        "line": index + 1,
                        "code": _normalise(code),
                        "use": suggestion,
                    }
                )
                break
    return found, scanned


def _keys(found: dict[str, list[dict[str, object]]]) -> collections.Counter:
    """Identity of a site is (file, rule, normalised code) — not its line number."""
    counter: collections.Counter = collections.Counter()
    for rel, sites in found.items():
        for site in sites:
            counter[(rel, str(site["rule"]), str(site["code"]))] += 1
    return counter


def load_baseline() -> collections.Counter:
    if not BASELINE.exists():
        return collections.Counter()
    raw = json.loads(BASELINE.read_text(encoding="utf-8"))
    return collections.Counter(
        {(e["file"], e["rule"], e["code"]): int(e.get("count", 1))
         for e in raw.get("sites", [])}
    )


def write_baseline(found: dict[str, list[dict[str, object]]]) -> None:
    counter = _keys(found)
    sites = [
        {"file": f, "rule": r, "code": c, "count": n}
        for (f, r, c), n in sorted(counter.items())
    ]
    BASELINE.write_text(
        json.dumps(
            {
                "_comment": (
                    "Physical-direction layout call sites that predate the RTL "
                    "gate. Fix the code, then re-run with --write-baseline to "
                    "shrink this list. Do not add entries by hand; use "
                    "'rtl-allow:' comments for genuinely physical layouts."
                ),
                "sites": sites,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write-baseline", action="store_true")
    parser.add_argument("--list", action="store_true", dest="show")
    args = parser.parse_args(argv)

    if not FLUTTER_LIB.is_dir():
        print(f"skip: {FLUTTER_LIB} not found", file=sys.stderr)
        return 0

    found, scanned = scan()
    total = sum(len(v) for v in found.values())

    if args.write_baseline:
        write_baseline(found)
        print(f"wrote {BASELINE.relative_to(ROOT)} with {total} site(s)")
        return 0

    if args.show:
        for rel, sites in found.items():
            for site in sites:
                print(f"{rel}:{site['line']}  [{site['rule']}]  {site['code']}")
                print(f"    -> use {site['use']}")
        print(f"\n{total} site(s) in {len(found)} file(s)")
        return 0

    baseline = load_baseline()
    current = _keys(found)

    added: list[tuple[str, str, str, int]] = []
    for key, count in current.items():
        allowed = baseline.get(key, 0)
        if count > allowed:
            added.append((key[0], key[1], key[2], count - allowed))

    cleared = sum(
        max(0, allowed - current.get(key, 0)) for key, allowed in baseline.items()
    )

    print(f"scanned {scanned} Dart file(s) under flutter/lib")
    if not added:
        status = f"rtl: ok — {total} known physical-direction site(s)"
        if cleared:
            status += (
                f", {cleared} cleared (run --write-baseline to shrink the baseline)"
            )
        print(status)
        return 0

    print(f"rtl: {len(added)} new physical-direction site(s)")
    for rel, rule, code, extra in sorted(added):
        print(f"  {rel}  [{rule}]  {code}")
    print(
        "\nFlutter mirrors these only for directional APIs. Use "
        "EdgeInsetsDirectional / AlignmentDirectional / TextAlign.start, or add a "
        f"'// {ALLOW_MARKER} <reason>' comment when the position is truly physical."
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
