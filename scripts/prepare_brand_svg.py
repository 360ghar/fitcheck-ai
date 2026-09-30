#!/usr/bin/env python3
"""Derive app, favicon and monochrome SVGs from the Facet F vector master."""

from copy import deepcopy
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / "docs/brand"
NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)


def node(tag, **attrs):
    return ET.Element(f"{{{NS}}}{tag}", attrs)


def write(name, root):
    ET.indent(root, space="  ")
    (BRAND / name).write_text(ET.tostring(root, encoding="unicode") + "\n")


def main():
    master = ET.parse(BRAND / "mark.svg").getroot()
    mark = master.find(f"{{{NS}}}g")
    defs = master.find(f"{{{NS}}}defs")
    if mark is None or defs is None:
        raise SystemExit("mark.svg must contain the vector definitions and mark group")

    icon = node("svg", viewBox="0 0 1024 1024")
    ET.SubElement(icon, f"{{{NS}}}title").text = "FitCheck AI app icon — Facet F"
    icon.append(deepcopy(defs))
    icon.append(node("rect", width="1024", height="1024", fill="#111916"))
    placement = node("g", transform="translate(512 512) scale(.84) translate(-640 -635)")
    placement.append(deepcopy(mark))
    icon.append(placement)
    write("app-icon.svg", icon)

    simple = node("svg", viewBox="240 225 800 800")
    ET.SubElement(simple, f"{{{NS}}}title").text = "FitCheck AI — Facet F"
    ET.SubElement(simple, f"{{{NS}}}style").text = (
        ".stem,.top{fill:#078675}.crease{fill:#065B50}.arm{fill:#39B99A}"
        "@media(prefers-color-scheme:dark){.stem,.top{fill:#30C3A5}"
        ".crease{fill:#159E85}.arm{fill:#92E9D0}}"
    )
    flat = deepcopy(mark)
    for path in flat:
        path.set("class", path.attrib.pop("id"))
        path.attrib.pop("fill", None)
    simple.append(flat)
    write("mark-simple.svg", simple)

    mono = node("svg", viewBox="240 225 800 800")
    # One continuous outer contour prevents seams where the four faces meet.
    mono.append(node("path", fill="#FFFFFF", d=(
        "M376 367 L470 266 Q483 252 502 252 H901 Q917 252 917 268 V379 "
        "Q917 392 907 402 L871 437 Q863 445 851 445 H543 V594 L576 570 "
        "Q591 558 610 558 H844 Q860 558 860 574 V662 Q860 678 849 689 "
        "L829 709 Q816 722 798 722 H654 L543 770 V1003 Q543 1018 529 1018 "
        "H400 Q363 1018 363 982 V389 Q363 376 376 367Z"
    )))
    write("mark-monochrome.svg", mono)


if __name__ == "__main__":
    main()
