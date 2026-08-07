#!/usr/bin/env python3
"""Enforce the iOS minimum deployment target (>= 15.0) for agents and CI.

App Store Connect warns on every upload when the app's MinimumOSVersion is too
low: "Starting in Spring 2027, all iOS apps must have a MinimumOSVersion of
15.0 or later in order to be uploaded to App Store Connect or submitted for
distribution." The value shipped at 13.0 from the app's first commit and every
CI-built IPA re-triggered the warning.

The minimum lives in two files and BOTH must stay in lock-step:

  1. `flutter/ios/Runner.xcodeproj/project.pbxproj` — the `IPHONEOS_DEPLOYMENT_
     TARGET` build setting (one per Runner build configuration: Debug, Release,
     Profile). This is what the built IPA's Info.plist `MinimumOSVersion`
     comes from.
  2. `flutter/ios/Podfile` — the `platform :ios, 'X.Y'` line. Pods built with a
     lower floor than the app would silently drag the deployment target back
     down (CocoaPods applies the pod minimum to the app when it is lower).

Rules:

  * Every `IPHONEOS_DEPLOYMENT_TARGET` in the pbxproj must be >= 15.0, and at
    least one must exist (a missing setting defaults low in Xcode).
  * The Podfile `platform :ios` must be >= 15.0 and must exist.

Why a Python script and not a YAML grep in CI: the same check runs in three
places (local harness, PR CI, and the iOS build workflow before producing an
IPA), and a single stdlib script keeps the three invocations byte-identical so
a check cannot drift. It is deliberately simple — no dependencies, no config.
There is no escape hatch: Apple's deadline is not a preference.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIN_IOS = 15.0

PBXPROJ = ROOT / "flutter" / "ios" / "Runner.xcodeproj" / "project.pbxproj"
PODFILE = ROOT / "flutter" / "ios" / "Podfile"

errors: list[str] = []


def _version_of(value: str) -> float | None:
    m = re.fullmatch(r"\s*(\d+)\.(\d+)\s*", value)
    if not m:
        return None
    return float(f"{m.group(1)}.{m.group(2)}")


def check_pbxproj() -> None:
    if not PBXPROJ.is_file():
        errors.append(
            f"missing {PBXPROJ.relative_to(ROOT)}. REMEDIATE: the iOS project file "
            f"is required to verify the deployment target."
        )
        return

    text = PBXPROJ.read_text(encoding="utf-8")
    matches = list(
        re.finditer(r"IPHONEOS_DEPLOYMENT_TARGET\s*=\s*([^;]+);", text)
    )
    if not matches:
        errors.append(
            f"{PBXPROJ.relative_to(ROOT)}: no `IPHONEOS_DEPLOYMENT_TARGET` found. "
            f"REMEDIATE: set it to {MIN_IOS:g} in every Runner build "
            f"configuration (Xcode -> Build Settings -> iOS Deployment Target)."
        )
        return

    for m in matches:
        raw = m.group(1)
        version = _version_of(raw)
        if version is None:
            errors.append(
                f"{PBXPROJ.relative_to(ROOT)}: unparseable deployment target "
                f"`{raw.strip()}`. REMEDIATE: use a `X.Y` version >= {MIN_IOS:g}."
            )
        elif version < MIN_IOS:
            errors.append(
                f"{PBXPROJ.relative_to(ROOT)}: `IPHONEOS_DEPLOYMENT_TARGET = "
                f"{raw.strip()}` is below {MIN_IOS:g}. REMEDIATE: raise it to "
                f"{MIN_IOS:g} in every Runner build configuration. App Store "
                f"Connect rejects uploads below {MIN_IOS:g} starting Spring 2027."
            )


def check_podfile() -> None:
    if not PODFILE.is_file():
        errors.append(
            f"missing {PODFILE.relative_to(ROOT)}. REMEDIATE: the Podfile is "
            f"required to verify the CocoaPods platform floor."
        )
        return

    text = PODFILE.read_text(encoding="utf-8")
    m = re.search(r"platform\s*:\s*ios\s*,\s*'([^']+)'", text)
    if not m:
        errors.append(
            f"{PODFILE.relative_to(ROOT)}: no `platform :ios, 'X.Y'` line found. "
            f"REMEDIATE: declare it at {MIN_IOS:g} or later so pods build with "
            f"the same floor as the app."
        )
        return

    raw = m.group(1)
    version = _version_of(raw)
    if version is None:
        errors.append(
            f"{PODFILE.relative_to(ROOT)}: unparseable platform version `{raw}`. "
            f"REMEDIATE: use `platform :ios, '{MIN_IOS:g}'`."
        )
    elif version < MIN_IOS:
        errors.append(
            f"{PODFILE.relative_to(ROOT)}: `platform :ios, '{raw}'` is below "
            f"{MIN_IOS:g}. REMEDIATE: raise it to '{MIN_IOS:g}' so pods do not "
            f"drag the app's MinimumOSVersion back down."
        )


def main() -> int:
    check_pbxproj()
    check_podfile()

    if errors:
        print(
            f"iOS deployment target check failed ({len(errors)} issue(s)):\n",
            file=sys.stderr,
        )
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("iOS deployment target check passed (minimum 15.0).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
