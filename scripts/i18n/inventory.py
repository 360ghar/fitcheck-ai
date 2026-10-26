"""Shared locale inventory facts.

Facts that more than one tool needs to agree on live here rather than being
declared twice. They were declared twice once, and when Chinese needed a `zh`
base only one copy was updated, which is how two validators end up disagreeing
about whether the same tree is valid.

Each tool imports from this module in one direction only. `check_locales` imports
ICU helpers into `translate_arb`, so `translate_arb` cannot import back from
`check_locales`; anything both need belongs here instead.
"""

from __future__ import annotations

# ARB files that exist for `flutter gen-l10n`, not for a storefront.
#
# gen-l10n refuses a locale that carries a country code or a script subtag unless
# the language-only base also exists: it needs a fallback for a device that
# reports `pt` without a region, or `zh` without a script. The base is a copy of
# its primary variant — Brazilian Portuguese because it is the larger market,
# Simplified Chinese because it covers more speakers. The value is the variant
# that gets copied.
FALLBACK_BASES: dict[str, str] = {"pt": "pt_BR", "zh": "zh_Hans"}
