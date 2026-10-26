#!/usr/bin/env python3
"""Map a store capture run's goldens onto the store screen sources.

Reads `build/store_capture/<locale>/*.png` (written by
`flutter test --dart-define=STORE_CAPTURE_LOCALE=<locale>`) and writes the six
screen sources the Node renderer expects:

    store/creative/source/screens/<locale>/{closet,today,more,tryon,photoshoot,matches}.png

Geometry matches the hand-captured English set exactly - 760x1643 - so the
device bezel in `scripts/creative/render.mjs` composites it unchanged.

Usage:  python3 scripts/store_capture_post.py <locale>
        python3 scripts/store_capture_post.py <locale> --size 2064x2752 \
            --out ../store/creative/source/screens-ipad
"""
import sys
from pathlib import Path

from PIL import Image

# Which golden feeds which store screen. Each name is a fixture-backed render of
# the current paper UI with the demo wardrobe, so every locale shows identical
# content and the sets stay comparable.
GOLDEN_BY_SCREEN = {
    "closet": "closet_grid_light",
    "today": "dashboard_light",
    "more": "more_light",
    "tryon": "tryon_light",
    "photoshoot": "photoshoot_results_light",
    "matches": "plan_matches_light",
}

WIDTH, HEIGHT = 760, 1643


def main() -> int:
    argv = sys.argv[1:]
    if not argv:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    locale = argv[0]
    width, height = WIDTH, HEIGHT
    dst_root = Path("../store/creative/source/screens")
    rest = argv[1:]
    while rest:
        flag = rest.pop(0)
        if flag == "--size":
            width, height = (int(part) for part in rest.pop(0).lower().split("x"))
        elif flag == "--out":
            dst_root = Path(rest.pop(0))
        else:
            print(f"unknown option {flag}", file=sys.stderr)
            return 2
    src = Path("build/store_capture") / locale
    if not src.is_dir():
        print(f"no capture for {locale} at {src}", file=sys.stderr)
        return 1

    dst = dst_root / locale
    dst.mkdir(parents=True, exist_ok=True)

    for screen, golden in GOLDEN_BY_SCREEN.items():
        path = src / f"{golden}.png"
        if not path.is_file():
            print(f"missing golden {path}", file=sys.stderr)
            return 1
        with Image.open(path) as raw:
            # Goldens are fully opaque RGBA; dropping the channel is lossless and
            # matches the existing sources, which carry no alpha.
            image = raw.convert("RGB").resize((width, height), Image.LANCZOS)
        out = dst / f"{screen}.png"
        image.save(out, optimize=True)
        print(f"  {out}  {width}x{height}  {out.stat().st_size // 1024} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
