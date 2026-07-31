#!/usr/bin/env python3
"""Enforce the FitCheck dark-mode token contract for agents and CI.

Dark mode broke at the *token* layer, not the component layer: colors were
hardcoded as light hex in `tailwind.config.ts` with no `.dark` counterpart, and
`--muted-foreground` was byte-identical in `:root` and `.dark` (2.78:1 — a real
AA failure on the most-used text token in the app). Component-level `dark:`
patches then papered over the symptom. This check makes both classes of
regression fail the build.

Four rules:

  1. Var parity + non-identity — every color var in `:root` also exists in
     `.dark` with a *different* value (and vice versa). A token that is
     byte-identical across themes does not invert, which is the original defect.
     Genuinely theme-invariant colors are named in THEME_INVARIANT_VARS.

  2. Contrast arithmetic — WCAG relative luminance over the declared HSL
     channels. Text foregrounds clear 4.5:1 against the real page surfaces;
     fill-paired labels are measured against their own fill; hairlines get a
     decorative floor. Failures print the measured ratio AND the nearest
     passing lightness, so the fix needs no re-derivation.

  3. No theme literals and no `dark:` prefixes in the primitive layers
     (`components/ui|layout|sidebar|navigation`). Once the tokens invert, a
     primitive that still needs a `dark:` is patching a symptom instead of
     fixing a token — exactly the regression class this file exists to stop.

  4. No unpaired light literal anywhere in `frontend/src/` — a `bg-white` or
     `text-gray-600` with no `dark:` counterpart renders as a white slab or
     unreadable ink on a near-black page.

Why a Python script and not lint tooling: the frontend is on a legacy
`.eslintrc` with no plugin infrastructure and `scripts/` sits in
`ignorePatterns`, an ESLint rule cannot do contrast arithmetic, a Tailwind
plugin cannot fail on class *usage*, and a Vitest snapshot only reaches the
primitives it renders (missing 200+ pages). Pure stdlib, no dependencies.

Escape hatches, in order of preference:
  * Any class carrying an opacity modifier (`bg-white/10`, `bg-black/50`) is
    auto-exempt — it composites over unknown media (a garment photograph, a
    brand-red band) or is a scrim.
  * `theme-static: <reason>` on the line, or either of the two lines above it,
    exempts that line. A marker with no reason is itself an error, so it cannot
    decay into a silent mute.
  * Path-exempt files (PATH_EXEMPT) are skipped by rules 3 and 4.
  * Path-deferred directories (RULE4_BUDGETS) carry a hardcoded, decaying
    budget for rule 4 only. The budget is printed on every run and can only be
    lowered. Rules 1-3 apply everywhere with no deferral.
"""

from __future__ import annotations

import colorsys
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND_SRC = ROOT / "frontend" / "src"
INDEX_CSS = FRONTEND_SRC / "index.css"

errors: list[str] = []
notes: list[str] = []

# ---------------------------------------------------------------------------
# Rule 1 configuration
# ---------------------------------------------------------------------------

# Color vars that are *deliberately* identical in `:root` and `.dark`.
# Anything else identical is the original dark-mode defect.
THEME_INVARIANT_VARS = {
    # Chrome floating over a garment photograph — a Save pill, the select disc,
    # the favourite disc, the pin overlay. Its backdrop is the image, not the
    # page, so it must stay light-with-dark-text in both themes. This is what
    # DESIGN.md 03 `pill-on-image: bg canvas + text ink` means: canvas *white*,
    # not "whatever the page background happens to be".
    "--on-image",
    "--on-image-foreground",
    # `--destructive` stays a saturated red in BOTH themes (0 88% 33% light,
    # 0 88% 43% dark), so white is the correct label on both. Unlike
    # `--primary-foreground` — which had to invert to near-black once the brand
    # red was lightened to 62% — there is no theme in which this pair needs to
    # flip. The PAIRED_FILLS check below proves it clears 4.5:1 in both themes,
    # so the identity here is verified, not overlooked.
    #
    # NOTE for docs: frontend/DESIGN.md 09 currently says a byte-identical token
    # "is a bug unless it is `--on-image*`". That sentence is one token too
    # narrow; it should name this pair too.
    "--destructive-foreground",
}

# Non-color vars are not theme values at all and are never parity-checked.
# Listed explicitly so an added geometry token does not silently fall through
# the is-a-color heuristic and skip rule 1.
NON_COLOR_VARS = {
    "--radius",
    "--sidebar-width",
    "--sidebar-width-collapsed",
    "--bottom-nav-height",
    "--mobile-header-height",
    "--safe-area-top",
    "--safe-area-bottom",
    "--safe-area-left",
    "--safe-area-right",
}

# ---------------------------------------------------------------------------
# Rule 2 configuration
# ---------------------------------------------------------------------------

TEXT_MIN = 4.5

# Decorative floor for hairlines. Deliberately NOT 3:1.
#
# WCAG 2.2 SC 1.4.11 (Non-text Contrast, 3:1) covers boundaries *required to
# identify a control or its state*. A 1px row divider or column rule is not
# that, so no WCAG minimum applies to it. A floor is still worth having as a
# tripwire against a hairline collapsing into its surface (ratio -> 1.0), which
# would silently delete every edge in the app.
#
# Measured worst real pairs today: light `--border` on `--card` = 1.29, light
# `--border` on `--background` = 1.39, dark `--border` on `--card` = 1.35. The
# floor is set just below the worst of those so the existing (deliberately
# quiet) hairline passes while a collapse toward 1.0 still fails. Raising it to 3:1 would force the hard,
# high-contrast 1px outline on every box that the design law names as a slop
# tell ("Hairline light border on boxes") and that DESIGN.md 07 replaces with
# tonal edges — so a stricter floor here would push the UI toward worse design,
# not better accessibility.
DECORATIVE_MIN = 1.25

PAGE_SURFACES = ("--background", "--card", "--secondary")

# Text roles that can land on any of the three real page surfaces.
FOREGROUNDS_ON_ALL_SURFACES = (
    "--foreground",
    "--card-foreground",
    "--popover-foreground",
    "--secondary-foreground",
    "--muted-foreground",
    "--accent-foreground",
    "--body",
)

# Text roles scoped to a subset of surfaces, each with the reason it is scoped.
# This is a narrowing of *where the token actually renders*, not a relaxation of
# the 4.5:1 threshold — the threshold is identical, only the backdrop list
# differs.
FOREGROUNDS_SCOPED: dict[str, tuple[tuple[str, ...], str]] = {
    # `text-primary` never sits on `bg-secondary`: a secondary button carries
    # `text-secondary-foreground`. On that pair the brand red measures 3.95
    # dark / 3.83 light, which is the inherent limit of a 100%-saturation red
    # at any lightness that still reads as the brand — not a dark-mode defect.
    # DESIGN.md 01 requires the saturation stay at 100%, so asserting the pair
    # would demand either a desaturated brand or a permanent allowlist entry.
    "--primary": (("--background", "--card"), "text-primary never renders on bg-secondary"),
    # Placeholder / disabled tier only. Its real backdrops are `--background`
    # (input fields) and `--card` (disabled buttons). See DESIGN.md 01 note.
    "--ash": (("--background", "--card"), "placeholder/disabled tier; never on bg-secondary"),
    # Validation copy. Also fill-paired against --error-pale, checked below.
    "--error": (PAGE_SURFACES, "validation text on any page surface"),
}

# (label var, fill var) — the label sits on its own fill, not on the page.
PAIRED_FILLS = (
    ("--primary-foreground", "--primary"),
    ("--success", "--success-pale"),
    ("--error", "--error-pale"),
    ("--destructive-foreground", "--destructive"),
    ("--on-dark", "--foreground"),
    ("--on-image-foreground", "--on-image"),
)

# Pre-existing sub-threshold pairs, recorded with their measured ratio so they
# ratchet instead of hiding. This is NOT a relaxed threshold: the assertion
# still runs at TEXT_MIN, and the check fails if a pair drifts WORSE than the
# value recorded here. It also prints every entry on every run. The point is
# that a known, owned, one-number defect does not block unrelated work while
# still being impossible to forget or to quietly worsen.
#
# Each entry: (theme, foreground var, background var) -> (measured, note)
# Empty on purpose. The one entry that lived here -- light `--primary` on
# `--card` at 4.46:1 -- was fixed by moving `--primary` to `354 100% 44%`
# (4.63:1). Add an entry only for a shortfall you are deliberately carrying,
# never to silence one you could fix.
RULE2_KNOWN_SHORTFALLS: dict[tuple[str, str, str], tuple[float, str]] = {}

DECORATIVE_PAIRS = (
    ("--border", "--background"),
    ("--border", "--card"),
    ("--input", "--background"),
    ("--input", "--card"),
)

# ---------------------------------------------------------------------------
# Rule 3 / 4 configuration
# ---------------------------------------------------------------------------

RULE3_DIRS = (
    "components/ui",
    "components/layout",
    "components/sidebar",
    "components/navigation",
)

# Skipped by rules 3 and 4 entirely, with the reason each earns it.
PATH_EXEMPT = {
    # Flattens alpha onto white before JPEG encoding for the vision model.
    # A canvas fillStyle is not a theme surface.
    "lib/image-compress.ts": "canvas alpha flatten for JPEG encode, not UI",
    # Pure-black media viewers: the backdrop is the photograph, and a
    # theme-following surface would tint the image.
    "components/ui/image-lightbox.tsx": "pure-black media viewer",
    "components/ui/bottom-sheet.tsx": "pure-black media viewer",
}

# Rule 4 only. Hardcoded, decaying budgets: a run that exceeds its budget
# fails; a run that comes in *under* budget prints a non-blocking stale-budget
# warning, which must be ratcheted down in the same commit that fixes a site.
# Rules 1-3 never defer.
RULE4_BUDGETS: dict[str, tuple[int, str]] = {
    "components/landing": (9, "marketing surfaces; dark mode already ~90% functional, out of active scope. Ratcheted 11 -> 9 after tokenizing shared panels and CTA surfaces; the remainder are on-color CTA pills that are correct as-is"),
    "components/seo": (2, "editorial template; same deferral as landing"),
    "pages/blog": (4, "editorial pages; same deferral as landing"),
    "pages/public": (0, "marketing/legal pages; FAQPage cleared, budget pins it at zero"),
    "pages/features": (0, "SEO feature pages; already clean, budget pins it there"),
    "layouts/PublicLayout.tsx": (0, "public shell; already clean, budget pins it there"),
    "components/gamification": (
        1,
        "gated behind a default-off flag; Leaderboard.tsx is the only survivor "
        "and its owner clears this to 0",
    ),
}

TAILWIND_PALETTES = (
    "gray|stone|slate|zinc|neutral|red|orange|amber|yellow|lime|green|emerald|"
    "teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose"
)
COLOR_PROPS = (
    "bg|text|border|ring|ring-offset|from|via|to|decoration|outline|divide|"
    "placeholder|caret|accent|shadow|fill|stroke"
)

# Rule 3: any palette literal at all is wrong in a primitive.
RULE3_LITERAL_RE = re.compile(
    r"(?<![\w-])(?<!dark:)("
    rf"(?:{COLOR_PROPS})-(?:{TAILWIND_PALETTES})-\d{{2,3}}"
    # `text-white` is deliberately NOT banned: DESIGN.md 01 requires the
    # `bg-accent-purple` label to be `text-white` (--primary-foreground inverts
    # to near-black, which is unreadable on the purple), and a white label on a
    # saturated brand fill is correct in both themes. `text-black` has no such
    # legitimate use on a theme surface — the tokens for that are
    # `text-on-image-foreground` and `text-primary-foreground`.
    rf"|(?:{COLOR_PROPS})-black"
    rf"|(?:bg|border|ring|ring-offset|divide|from|via|to|outline|shadow|fill|stroke)-white"
    r")(?![\w-])"
)

# Rule 4: the light-side literals that actively break dark mode.
RULE4_LITERAL_RE = re.compile(
    r"(?<![\w-])(?<!dark:)("
    r"bg-white"
    r"|bg-(?:gray|stone|slate|zinc|neutral)-(?:50|100|200|300)"
    r"|bg-indigo-(?:50|100)"
    r"|text-(?:gray|stone)-(?:500|600|700|800|900)"
    r"|border-(?:gray|stone)-(?:200|300)"
    r")(?![\w-])"
)

# An opacity modifier means the class composites over something unknown.
ALPHA_MODIFIER_RE = re.compile(r"/(?:\d{1,3}|\[[^\]]+\])")

DARK_PREFIX_RE = re.compile(r"(?<![\w-])dark:")

MARKER_RE = re.compile(r"theme-static:[ \t]*(.*)$")

# A reason has to survive stripping the comment terminators it is embedded in,
# or `{/* theme-static: */}` would read `*/}` as its own justification and the
# marker would silently become the no-op mute it is designed not to be.
_COMMENT_NOISE_RE = re.compile(r"(\*/|-->|\}|\{|/\*|//|\*|\s)+")
MIN_REASON_CHARS = 8


def _reason_is_real(raw: str | None) -> bool:
    if not raw:
        return False
    return len(_COMMENT_NOISE_RE.sub(" ", raw).strip()) >= MIN_REASON_CHARS

# `dark:` may be followed by further variants: dark:hover:text-…, dark:md:bg-…
def _dark_counterpart_re(family: str) -> re.Pattern[str]:
    return re.compile(rf"dark:(?:[a-z0-9-]+:)*{re.escape(family)}-[\w./\[\]-]+")


# ---------------------------------------------------------------------------
# Color math
# ---------------------------------------------------------------------------

_HSL_RE = re.compile(r"^(-?[\d.]+)\s+([\d.]+)%\s+([\d.]+)%$")


def parse_hsl(value: str) -> tuple[float, float, float] | None:
    """Parse shadcn-style bare HSL channels, e.g. `354 100% 62%`."""
    m = _HSL_RE.match(value.strip())
    if not m:
        return None
    return float(m.group(1)), float(m.group(2)), float(m.group(3))


def hsl_to_rgb(h: float, s: float, lightness: float) -> tuple[float, float, float]:
    # colorsys takes hue, LIGHTNESS, saturation — in that order.
    return colorsys.hls_to_rgb((h % 360) / 360.0, lightness / 100.0, s / 100.0)


def relative_luminance(rgb: tuple[float, float, float]) -> float:
    def channel(c: float) -> float:
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = (channel(max(0.0, min(1.0, c))) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def luminance_of_hsl(hsl: tuple[float, float, float]) -> float:
    return relative_luminance(hsl_to_rgb(*hsl))


def contrast(fg: tuple[float, float, float], bg: tuple[float, float, float]) -> float:
    l1, l2 = luminance_of_hsl(fg), luminance_of_hsl(bg)
    if l1 < l2:
        l1, l2 = l2, l1
    return (l1 + 0.05) / (l2 + 0.05)


def nearest_passing_lightness(
    fg: tuple[float, float, float], bg: tuple[float, float, float], target: float
) -> float | None:
    """Closest L (whole %) at this hue+saturation that reaches `target`.

    Returned so an error message is directly actionable: the fix is one number,
    not a re-derivation of the WCAG formula.
    """
    h, s, current = fg
    best: tuple[float, float] | None = None
    for step in range(0, 101):
        candidate = float(step)
        if contrast((h, s, candidate), bg) >= target:
            distance = abs(candidate - current)
            if best is None or distance < best[0]:
                best = (distance, candidate)
    return None if best is None else best[1]


def hex_of(hsl: tuple[float, float, float]) -> str:
    r, g, b = hsl_to_rgb(*hsl)
    return "#{:02x}{:02x}{:02x}".format(round(r * 255), round(g * 255), round(b * 255))


# ---------------------------------------------------------------------------
# index.css parsing
# ---------------------------------------------------------------------------

_VAR_DECL_RE = re.compile(r"(--[a-z0-9-]+)\s*:\s*([^;]+);")


def _extract_block(css: str, selector: str) -> str | None:
    """Return the body of the first `selector { ... }` block, brace-balanced."""
    match = re.search(re.escape(selector) + r"\s*\{", css)
    if not match:
        return None
    depth, start = 1, match.end()
    for i in range(start, len(css)):
        if css[i] == "{":
            depth += 1
        elif css[i] == "}":
            depth -= 1
            if depth == 0:
                return css[start:i]
    return None


def load_theme_vars() -> tuple[dict[str, str], dict[str, str]] | None:
    if not INDEX_CSS.is_file():
        errors.append(
            f"missing {INDEX_CSS.relative_to(ROOT)}. "
            f"REMEDIATE: theme tokens live in `:root` / `.dark` there; the guard "
            f"cannot verify anything without it."
        )
        return None
    css = INDEX_CSS.read_text(encoding="utf-8")
    root_body = _extract_block(css, ":root")
    dark_body = _extract_block(css, ".dark")
    if root_body is None or dark_body is None:
        errors.append(
            f"{INDEX_CSS.relative_to(ROOT)}: could not find both a `:root` and a "
            f"`.dark` block. REMEDIATE: keep both blocks in `@layer base` with "
            f"literal `:root {{` / `.dark {{` selectors."
        )
        return None
    root = {m.group(1): m.group(2).strip() for m in _VAR_DECL_RE.finditer(root_body)}
    dark = {m.group(1): m.group(2).strip() for m in _VAR_DECL_RE.finditer(dark_body)}
    return root, dark


# ---------------------------------------------------------------------------
# Rule 1 — var parity + non-identity
# ---------------------------------------------------------------------------


def check_var_parity(root: dict[str, str], dark: dict[str, str]) -> None:
    rel = INDEX_CSS.relative_to(ROOT)

    for name, value in sorted(root.items()):
        if name in NON_COLOR_VARS:
            continue
        if parse_hsl(value) is None:
            continue  # not an HSL color token (env(), px, rem, …)

        if name not in dark:
            errors.append(
                f"{rel}: color var `{name}` is declared in `:root` but missing from "
                f"`.dark`, so it does not invert. "
                f"REMEDIATE: add `{name}` to the `.dark` block with a dark-theme "
                f"value, or add it to THEME_INVARIANT_VARS in "
                f"scripts/check_theme_tokens.py with a written reason."
            )
            continue

        if dark[name] == value and name not in THEME_INVARIANT_VARS:
            errors.append(
                f"{rel}: color var `{name}` is byte-identical in `:root` and "
                f"`.dark` (`{value}`), so it does not invert. This is the exact "
                f"defect that shipped `--muted-foreground` at 2.78:1. "
                f"REMEDIATE: give `{name}` a real dark value in the `.dark` block, "
                f"or add it to THEME_INVARIANT_VARS with a written reason if it is "
                f"genuinely theme-invariant (as `--on-image` is)."
            )

    for name, value in sorted(dark.items()):
        if name in NON_COLOR_VARS or parse_hsl(value) is None:
            continue
        if name not in root:
            errors.append(
                f"{rel}: color var `{name}` is declared in `.dark` but has no "
                f"`:root` counterpart, so light mode falls back to whatever the "
                f"cascade provides. "
                f"REMEDIATE: declare `{name}` in `:root` too."
            )


# ---------------------------------------------------------------------------
# Rule 2 — contrast arithmetic
# ---------------------------------------------------------------------------


def _assert_contrast(
    theme: str,
    vars_: dict[str, str],
    fg_name: str,
    bg_name: str,
    minimum: float,
    kind: str,
) -> None:
    fg_raw, bg_raw = vars_.get(fg_name), vars_.get(bg_name)
    if fg_raw is None or bg_raw is None:
        return
    fg, bg = parse_hsl(fg_raw), parse_hsl(bg_raw)
    if fg is None or bg is None:
        return

    ratio = contrast(fg, bg)
    known = RULE2_KNOWN_SHORTFALLS.get((theme, fg_name, bg_name))

    if known is not None:
        recorded, note = known
        if ratio >= minimum:
            notes.append(
                f"RULE2 STALE: [{theme}] `{fg_name}` on `{bg_name}` now measures "
                f"{ratio:.2f}:1 and clears {minimum:g}:1. REMEDIATE: delete the "
                f"RULE2_KNOWN_SHORTFALLS entry in scripts/check_theme_tokens.py."
            )
            return
        if ratio < recorded - 0.005:
            errors.append(
                f"{INDEX_CSS.relative_to(ROOT)} [{theme}]: {kind} `{fg_name}` on "
                f"`{bg_name}` regressed from a recorded {recorded:.2f}:1 to "
                f"{ratio:.2f}:1. REMEDIATE: this pair is a tracked shortfall, not a "
                f"licence to make it worse. Restore at least {recorded:.2f}:1, or fix "
                f"it outright — {note}"
            )
            return
        notes.append(
            f"RULE2 KNOWN SHORTFALL: [{theme}] `{fg_name}` on `{bg_name}` = "
            f"{ratio:.2f}:1 (floor {minimum:g}:1). {note}"
        )
        return

    if ratio >= minimum:
        return

    target = nearest_passing_lightness(fg, bg, minimum)
    if target is None:
        fix = (
            f"no lightness at hue {fg[0]:g} / saturation {fg[1]:g}% reaches "
            f"{minimum:g}:1 on this backdrop — the hue or saturation has to move, "
            f"or the backdrop does"
        )
    else:
        fix = (
            f"nearest passing lightness is {target:g}% "
            f"(i.e. `{fg_name}: {fg[0]:g} {fg[1]:g}% {target:g}%` -> "
            f"{contrast((fg[0], fg[1], target), bg):.2f}:1)"
        )

    errors.append(
        f"{INDEX_CSS.relative_to(ROOT)} [{theme}]: {kind} `{fg_name}` "
        f"({hex_of(fg)}) on `{bg_name}` ({hex_of(bg)}) measures "
        f"{ratio:.2f}:1, below the {minimum:g}:1 floor. "
        f"REMEDIATE: {fix}. See DESIGN.md 09."
    )


def check_contrast(root: dict[str, str], dark: dict[str, str]) -> None:
    for theme, vars_ in (("light", root), ("dark", dark)):
        for fg in FOREGROUNDS_ON_ALL_SURFACES:
            for bg in PAGE_SURFACES:
                _assert_contrast(theme, vars_, fg, bg, TEXT_MIN, "text token")

        for fg, (surfaces, _reason) in FOREGROUNDS_SCOPED.items():
            for bg in surfaces:
                _assert_contrast(theme, vars_, fg, bg, TEXT_MIN, "text token")

        for label, fill in PAIRED_FILLS:
            _assert_contrast(theme, vars_, label, fill, TEXT_MIN, "fill-paired label")

        for line, surface in DECORATIVE_PAIRS:
            _assert_contrast(theme, vars_, line, surface, DECORATIVE_MIN, "hairline")


# ---------------------------------------------------------------------------
# Source scanning shared helpers
# ---------------------------------------------------------------------------


def _scan_targets() -> list[Path]:
    out: list[Path] = []
    for path in sorted(FRONTEND_SRC.rglob("*")):
        if path.suffix not in {".ts", ".tsx"}:
            continue
        rel_parts = path.relative_to(FRONTEND_SRC).parts
        if "__tests__" in rel_parts:
            continue
        if path.name.endswith((".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx", ".d.ts")):
            continue
        out.append(path)
    return out


def _rel(path: Path) -> str:
    return path.relative_to(FRONTEND_SRC).as_posix()


def _marker_reason(lines: list[str], index: int) -> tuple[bool, bool]:
    """(has_marker, has_reason) looking at this line and the two above it."""
    found = False
    for offset in (0, 1, 2):
        i = index - offset
        if i < 0:
            break
        m = MARKER_RE.search(lines[i])
        if m:
            found = True
            if _reason_is_real(m.group(1)):
                return True, True
    return found, False


def _alpha_exempt(line: str, end: int) -> bool:
    return bool(ALPHA_MODIFIER_RE.match(line[end : end + 10]))


_BLOCK_COMMENT_RE = re.compile(r"/\*.*?\*/")
_LINE_COMMENT_RE = re.compile(r"(?<!:)//.*$")


def _strip_comments(line: str) -> str:
    """Blank out comment text so prose about a token is not read as a usage.

    A class name inside a comment is never applied, and migration notes very
    reasonably *name* the thing they removed ("the dropped `dark:border-x` half
    …"). Scanning raw lines makes every such note a false positive, which is how
    a guard trains people to stop writing the notes. Markers are read from the
    raw line before this runs, so `theme-static:` still works from a comment.
    The `(?<!:)` guard keeps `https://` from truncating a line.
    """
    line = _BLOCK_COMMENT_RE.sub(" ", line)
    return _LINE_COMMENT_RE.sub(" ", line)


# ---------------------------------------------------------------------------
# Rule 3 — primitives stay token-pure
# ---------------------------------------------------------------------------


def check_primitives(paths: list[Path]) -> None:
    for path in paths:
        rel = _rel(path)
        if rel in PATH_EXEMPT:
            continue
        if not any(rel.startswith(d + "/") for d in RULE3_DIRS):
            continue

        lines = path.read_text(encoding="utf-8", errors="replace").split("\n")
        for idx, line in enumerate(lines):
            has_marker, has_reason = _marker_reason(lines, idx)
            if has_marker and not has_reason:
                errors.append(
                    f"frontend/src/{rel}:{idx + 1}: bare `theme-static:` marker with "
                    f"no reason. REMEDIATE: write `theme-static: <why this stays "
                    f"fixed across themes>`. A marker without a reason is a silent "
                    f"mute, not a decision."
                )
                continue
            if has_marker:
                continue

            code = _strip_comments(line)

            for m in RULE3_LITERAL_RE.finditer(code):
                if _alpha_exempt(code, m.end(1)):
                    continue
                errors.append(
                    f"frontend/src/{rel}:{idx + 1}: primitive uses the palette "
                    f"literal `{m.group(1)}`. REMEDIATE: primitives must consume "
                    f"semantic tokens only (bg-background / bg-card / bg-muted / "
                    f"text-foreground / text-muted-foreground / border-border / "
                    f"bg-on-image + text-on-image-foreground for chrome over "
                    f"photography). A hex-locked palette step has no `.dark` "
                    f"counterpart. See frontend/DESIGN.md 01."
                )

            for m in DARK_PREFIX_RE.finditer(code):
                errors.append(
                    f"frontend/src/{rel}:{idx + 1}: primitive uses a `dark:` prefix. "
                    f"REMEDIATE: fix the token in frontend/src/index.css so it "
                    f"inverts, instead of patching the component. A `dark:` in "
                    f"{' | '.join(RULE3_DIRS)} is a symptom patch, and "
                    f"symptom patches are how dark mode broke. If the surface is "
                    f"genuinely theme-invariant, use the `on-image` token pair or "
                    f"mark the line `theme-static: <reason>`."
                )
                break


# ---------------------------------------------------------------------------
# Rule 4 — no unpaired light literal
# ---------------------------------------------------------------------------


def _deferred_bucket(rel: str) -> str | None:
    for prefix in RULE4_BUDGETS:
        if rel == prefix or rel.startswith(prefix + "/"):
            return prefix
    return None


def check_unpaired_literals(paths: list[Path]) -> None:
    deferred_counts: dict[str, int] = {k: 0 for k in RULE4_BUDGETS}
    deferred_sites: dict[str, list[str]] = {k: [] for k in RULE4_BUDGETS}

    for path in paths:
        rel = _rel(path)
        if rel in PATH_EXEMPT:
            continue

        lines = path.read_text(encoding="utf-8", errors="replace").split("\n")
        bucket = _deferred_bucket(rel)

        for idx, line in enumerate(lines):
            has_marker, has_reason = _marker_reason(lines, idx)
            if has_marker and not has_reason:
                errors.append(
                    f"frontend/src/{rel}:{idx + 1}: bare `theme-static:` marker with "
                    f"no reason. REMEDIATE: write `theme-static: <why this stays "
                    f"fixed across themes>`."
                )
                continue
            if has_marker:
                continue

            # A multi-line className can carry its `dark:` half on a neighbouring
            # line, so pairing is looked for on the line first and then in a small
            # window around it.
            code = _strip_comments(line)
            window = "\n".join(
                _strip_comments(l) for l in lines[max(0, idx - 2) : idx + 3]
            )

            for m in RULE4_LITERAL_RE.finditer(code):
                cls = m.group(1)
                if _alpha_exempt(code, m.end(1)):
                    continue
                family = cls.split("-", 1)[0]
                pattern = _dark_counterpart_re(family)
                if pattern.search(code) or pattern.search(window):
                    continue

                site = f"frontend/src/{rel}:{idx + 1} `{cls}`"
                if bucket is not None:
                    deferred_counts[bucket] += 1
                    deferred_sites[bucket].append(site)
                    continue

                errors.append(
                    f"{site}: light literal with no `dark:` counterpart. "
                    f"REMEDIATE: use a semantic token — page/shell root -> "
                    f"`bg-background`; panel/card inside a page -> `bg-card`; "
                    f"raised layer -> `bg-popover` or `bg-surface-elevated`; wash "
                    f"or image letterbox -> `bg-muted` (`bg-secondary` when it "
                    f"needs a visible step off a card); ink -> `text-foreground`; "
                    f"metadata -> `text-muted-foreground`; drop "
                    f"`border-gray-*`/`border-stone-*` entirely (index.css already "
                    f"applies a global `border-border`). If the surface really must "
                    f"stay fixed across themes (a light pill on a brand-red band, "
                    f"chrome over photography), use `bg-on-image` + "
                    f"`text-on-image-foreground`, or mark the line "
                    f"`theme-static: <reason>`."
                )

    print("Rule 4 deferred budgets (hardcoded; ratchet down, never up):")
    for prefix, (budget, reason) in RULE4_BUDGETS.items():
        found = deferred_counts[prefix]
        status = "ok" if found == budget else ("OVER" if found > budget else "UNDER")
        print(f"  {prefix:<34} {found:>3} / {budget:<3} {status}   ({reason})")
        if found > budget:
            errors.append(
                f"rule 4 budget exceeded for `frontend/src/{prefix}`: found {found} "
                f"unpaired light literal(s), budget is {budget}. "
                f"REMEDIATE: fix the new site(s) — do not raise the budget. "
                f"Sites: {'; '.join(deferred_sites[prefix])}"
            )
        elif found < budget:
            # Deliberately a warning, not an error. The contract this mechanism
            # has to enforce is "cannot grow"; failing on UNDER would also mean
            # that any agent who fixes one deferred site breaks the build for
            # everyone else until the number is edited, which in a parallel tree
            # turns a good change into a merge conflict. It is printed on every
            # run to stderr so it cannot be forgotten.
            notes.append(
                f"RULE4 BUDGET STALE for `frontend/src/{prefix}`: found {found} "
                f"unpaired light literal(s) but the budget still says {budget}. "
                f"REMEDIATE: lower RULE4_BUDGETS['{prefix}'] to {found} in "
                f"scripts/check_theme_tokens.py so the ratchet cannot slip back."
            )


# ---------------------------------------------------------------------------


def main() -> int:
    loaded = load_theme_vars()
    if loaded is not None:
        root, dark = loaded
        check_var_parity(root, dark)
        check_contrast(root, dark)

    if FRONTEND_SRC.is_dir():
        paths = _scan_targets()
        check_primitives(paths)
        check_unpaired_literals(paths)
    else:
        errors.append(f"missing {FRONTEND_SRC.relative_to(ROOT)}")

    if notes:
        print("\nTracked, non-blocking items (ratchet these down):", file=sys.stderr)
        for n in notes:
            print(f"  ! {n}", file=sys.stderr)

    if errors:
        print(f"\nTheme token check failed ({len(errors)} issue(s)):\n", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("Theme token check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
