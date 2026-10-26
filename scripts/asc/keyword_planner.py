#!/usr/bin/env python3
"""Fill the App Store keyword field in every locale without wasting characters.

Apple indexes exactly three things per storefront: the app name, the subtitle,
and the keyword field. The keyword field is capped at 100 characters including
separating commas. Two failures are common and both are silent:

* A term that already appears in the name or subtitle buys nothing. "closet" in
  keywords when the subtitle reads "AI Closet, Try-On & Outfits" is 8 characters
  of dead weight.
* A partly-used field is partly-unindexed surface. A locale sitting at 37 of 100
  characters is discoverable for roughly a third of the searches it could win.

This tool reports both, then asks Gemini for candidate search terms in the
target language and packs them against the real budget. It writes a reviewable
plan to `store/asc/keywords.json`; `--apply` merges that plan into
`store/asc/listings.json`. Nothing is written to the App Store here.

Why the model is asked rather than translated: a literal translation of "closet
organizer" is rarely what a local user types. The Russian query is "шкаф", the
Japanese is "クローゼット" or "服 管理", and a Japanese user often searches
"ootd" in Latin script. Translation produces correct words; the model is asked
for the words people actually search.

Usage:
    python3 scripts/asc/keyword_planner.py                  # report only
    python3 scripts/asc/keyword_planner.py --plan           # build keywords.json
    python3 scripts/asc/keyword_planner.py --plan --locale ja,hi,ar-SA
    python3 scripts/asc/keyword_planner.py --apply          # merge into listings
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# Set to `gemini_json` by `--provider gemini`; the default path is Agnes, whose
# signature is narrower and is therefore called directly in `plan_locale`.
MODEL_CALL = None
STORE = ROOT / "store" / "asc"
LISTINGS = STORE / "listings.json"
LOCALES = STORE / "locales.json"
PLAN_PATH = STORE / "keywords.json"

# The keyword field's cap, and the comma that joins terms. Apple counts the
# commas, so eight 12-character terms are 100 characters, not 96.
BUDGET = 100
SEPARATOR = ","

# Seconds to wait after a 429. Gemini's limit is per minute and shared by every
# call in a run, so a retry has to outlast a window rather than a moment.
QUOTA_BACKOFF = int(os.environ.get("TRANSLATE_QUOTA_BACKOFF", "45"))

MODEL = os.environ.get("KEYWORD_MODEL", "gemini-3.1-flash-lite")
ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

# Same reason as translate_listings.py: the free tier caps this model at 500
# requests per DAY, and the cap is per model rather than per key. An exhausted
# model answers 429 `per day limit exceeded` for hours, so a run that only ever
# tried one model would wait forever on a limit that is not rate-based.
MODEL_CHAIN = [MODEL] + [
    m.strip()
    for m in os.environ.get(
        "KEYWORD_MODELS", "gemini-flash-lite-latest,gemini-3-flash-preview"
    ).split(",")
    if m.strip() and m.strip() != MODEL
]

SYSTEM = """You are an App Store Optimization specialist. You propose keyword field
contents for one locale at a time.

The App Store keyword field is what Apple indexes for search, together with the app
name and subtitle. It is capped at 100 characters including commas. Your output is
converted to search rankings only if it contains the words real users type.

Rules, in priority order:

1. Output ONLY a JSON object: {"terms": [...]} where each element is
   {"term": "<search term>", "intent": "category"|"problem"|"feature"|"adjacent"}.
   No prose, no markdown fences.
2. Write the terms in the target language and its normal script. A user in Tokyo
   typing Japanese must match. Do not transliterate into Latin unless rule 6 applies.
3. Never include: the app name "FitCheck AI", the brand "Pro", the word "app",
   "free", or any competitor's product name. Never include a term that already
   appears in the provided name or subtitle — those are already indexed.
4. Use the singular form where the language distinguishes number; Apple matches
   plurals. In languages without number marking (Chinese, Japanese, Korean, Thai)
   use the natural form a searcher would type.
5. Prefer the words people search with, not the words a marketing team writes.
   "what to wear" and "closet organizer" are problem-intent; "AI" alone is not.
6. For non-Latin-script locales, add at most 2 Latin-script terms only if users in
   that storefront genuinely search in Latin (fashion terms like ootd, tryon,
   outfit are common in Japanese, Korean and Chinese storefronts). Otherwise omit.
   Never pad with Latin terms for a Latin-script locale.
7. Return 16 to 22 terms. Order them most valuable first. Keep each term under 24
   characters; a term longer than that rarely fits the budget and is rarely typed.
8. A term may contain spaces, and must when the language needs them. In Vietnamese
   and Thai the unit of meaning is multi-syllable: write "trang phục" as one term,
   never "trang" and "phục" as two. The same applies to any multi-word phrase a
   user types as one idea. Breaking a phrase into fragments is the single worst
   outcome, because the fragments match nothing on their own.
9. `intent` means: "category" = names the product category (closet, wardrobe);
   "problem" = the need a user is trying to solve (what to wear, outfit ideas);
   "feature" = a capability (virtual try on, headshot); "adjacent" = related
   interest (capsule wardrobe, fashion, style, ootd).
"""

INTENT_ORDER = {"category": 0, "problem": 1, "feature": 2, "adjacent": 3}

# Scripts that do not put spaces between words, so a short term is normal and
# says nothing about phrase boundaries.
NO_WORD_SPACES = {"zh-Hans", "zh-Hant", "ja", "ko", "th"}

# Terms that must never reach the keyword field, whatever the model proposes.
#
# "app" and "free" are the two the App Store discourages: every listing is an
# app, and the store's own price label is where "free" belongs, so both spend
# characters without distinguishing this app from the one beside it. A
# competitor's name is a rejection risk under guideline 2.3.7. The model was
# told all of this in the prompt and still proposed `تطبيق` for Arabic, which is
# why this is a filter and not an instruction.
#
# Latin-script tokens are matched on word boundaries, not as substrings:
# "apparel" and "appearance" are good keywords for this app and both contain
# "app". Scripts without spaces are matched as substrings because there is no
# boundary to anchor to.
FORBIDDEN_WORDS = {
    "app", "apps", "application", "applications", "apk",
    "free", "gratis", "gratuit", "gratuite", "gratuits", "kostenlos", "gratuito",
    "gratuita", "ücretsiz", "ucretsiz", "aplikasi", "aplikacja", "aplikacija",
    "aplikacije", "aplicacion", "aplicación", "aplicativo", "pro",
    # Finnish. `check-listings.mjs` rejects these through FORBIDDEN_LATIN, but
    # this set did not contain them, so `--strip` left `sovellus` in place and
    # the gate kept failing on a term the planner believed was fine. The gate is
    # the authority; keep the two lists in step.
    "sovellus", "ilmainen",
    "fitcheck", "fitcheckai", "whering", "stylebook", "cladwell", "smartcloset",
}

FORBIDDEN_SUBSTRINGS = [
    "تطبيق", "应用", "應用", "アプリ", "앱", "ứng dụng", "แอป", "एप", "ऐप",
    "अॅप", "అప్లికేషన్", "ಅಪ್ಲಿಕೇಶನ್", "ആപ്പ്", "એપ", "ਐਪ", "ଆପ୍", "אפליקציה",
    "аппликация", "εφαρμογ",
    "無料", "무료", "免费", "免費", "मुफ़", "मुफ", "مجان", "חינם", "ฟรี",
    "percuma", "miễn phí", "бесплат", "безкоштовн", "bezplatn", "besplatn",
    "bezmaksas", "nemokam", "ilmainen", "ilmaiseksi",
]

WORDS = re.compile(r"[\w]+", re.UNICODE)


def is_forbidden(term: str) -> bool:
    folded = unicodedata.normalize("NFKC", term).casefold()
    if any(token in folded for token in FORBIDDEN_SUBSTRINGS):
        return True
    return any(word in FORBIDDEN_WORDS for word in WORDS.findall(folded))


# ---------------------------------------------------------------- env / gemini


def load_env() -> list[str]:
    """Every Gemini key in the workspace, best first. Keys are never printed.

    Only one of the keys present in this workspace is live, so the caller
    rotates on an "API key not valid" response instead of assuming the first
    name it finds is the right one.
    """
    keys: list[str] = []

    def add(value: str | None) -> None:
        if value and value not in keys:
            keys.append(value)

    add(os.environ.get("AI_GEMINI_API_KEY"))
    add(os.environ.get("GEMINI_API_KEY"))
    for path in (ROOT / "backend" / ".env", ROOT / ".env"):
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            match = re.match(r"^(AI_GEMINI_API_KEY|GEMINI_API_KEY)=(.+)$", line.strip())
            if match:
                add(match.group(2).strip().strip("'\""))
    return keys


def agnes_json(prompt: str, retries: int = 3) -> dict:
    """Same contract as `gemini_json`, on the Agnes transport.

    The Gemini free tier is 500 requests per day across every model, which does
    not cover a 50-locale planning run that retries. Agnes allows 1,500 per 5
    hours. Kept as a sibling rather than folded into `gemini_json` so the Gemini
    path stays readable — the two providers disagree on auth, envelope and
    retry shape, and merging them produces a function no one can review.
    """
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "i18n"))
    from agnes_client import call_agnes  # noqa: PLC0415 - optional transport

    last = ""
    for attempt in range(retries + 1):
        try:
            return _decode_object(call_agnes(None, prompt, system=SYSTEM))
        except (RuntimeError, ValueError) as error:
            last = str(error)
            if attempt < retries:
                time.sleep(min(60, 5 * (2**attempt)))
    raise RuntimeError(last or "agnes keyword call failed")


def gemini_json(keys: list[str], prompt: str, retries: int = 3) -> dict:
    body = {
        "system_instruction": {"parts": [{"text": SYSTEM}]},
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.4,
            "responseMimeType": "application/json",
            "maxOutputTokens": 4096,
        },
    }
    data = json.dumps(body).encode("utf-8")
    # Keep the most informative failure, not the last one. The workspace holds
    # two Gemini keys and only one is live: when the live key is rate-limited the
    # dead key answers 400 "API key not valid" immediately, and last-write-wins
    # reporting turned a quota problem into an authentication problem. That made
    # six locales fail with a misleading message and skipped the 429 backoff.
    best_error = ""
    for key in keys:
        if key in _DEAD_KEYS:
            continue
        quota_hit = False
        model_index = 0
        for attempt in range(max(retries, len(MODEL_CHAIN) + 2)):
            model = MODEL_CHAIN[model_index]
            request = urllib.request.Request(
                ENDPOINT.format(model=model),
                data=data,
                headers={"Content-Type": "application/json", "x-goog-api-key": key},
                method="POST",
            )
            try:
                with urllib.request.urlopen(request, timeout=120) as response:
                    payload = json.loads(response.read().decode("utf-8"))
                candidates = payload.get("candidates") or []
                if not candidates:
                    best_error = f"no candidates: {json.dumps(payload)[:200]}"
                    continue
                parts = (candidates[0].get("content") or {}).get("parts", [])
                text = "".join(part.get("text", "") for part in parts).strip()
                if text:
                    return _decode_object(text)
                best_error = f"empty text, finishReason={candidates[0].get('finishReason')}"
            except urllib.error.HTTPError as error:
                # Classify on the whole body: Gemini's daily-quota marker
                # ("requests per day") sits past character 460, so a 300-char
                # prefix cannot tell a per-day cap from a per-minute one and the
                # rotation below never fires. Keep a short slice for display only.
                body_text = error.read().decode("utf-8", errors="ignore")
                detail = body_text[:300]
                daily_exhausted = (
                    "per day" in body_text.lower() or "perday" in body_text.lower()
                )
                if error.code in (400, 403, 404) and "API key not valid" in body_text:
                    # This key will never work. Drop it for the rest of the run
                    # so every later locale does not pay for the discovery.
                    _DEAD_KEYS.add(key)
                    print("    one API key is not valid; skipping it", file=sys.stderr, flush=True)
                    break
                if error.code == 429:
                    quota_hit = True
                    best_error = f"HTTP 429 on {model}: {detail}"
                    # A per-day cap is per model, so rotate instead of sleeping;
                    # a per-minute cap is shared and needs the clock.
                    if daily_exhausted:
                        if model_index + 1 < len(MODEL_CHAIN):
                            model_index += 1
                            print(
                                f"    daily quota exhausted on {model}; "
                                f"switching to {MODEL_CHAIN[model_index]}",
                                file=sys.stderr,
                                flush=True,
                            )
                            continue
                        break
                    wait = QUOTA_BACKOFF * (attempt + 1)
                    try:
                        announced = int(error.headers.get("Retry-After", 0))
                        wait = max(wait, announced)
                    except (TypeError, ValueError, AttributeError):
                        pass
                    print(f"    429 quota hit, waiting {wait}s", file=sys.stderr, flush=True)
                    time.sleep(wait)
                    continue
                best_error = f"HTTP {error.code}: {detail}"
                if error.code in (400, 403, 404):
                    break
                time.sleep(1.5 * (attempt + 1))
            except Exception as error:  # noqa: BLE001 - retried, then reported
                best_error = str(error)
                time.sleep(1.5 * (attempt + 1))
        if quota_hit:
            raise RuntimeError(f"keyword planning failed: {best_error}")
    raise RuntimeError(f"keyword planning failed: {best_error}")


# Keys proven invalid during this run. Process-wide because a dead key stays
# dead, and because rediscovering it per locale wasted a request every time.
_DEAD_KEYS: set[str] = set()


def _decode_object(raw: str) -> dict:
    """Decode exactly one JSON object from a model reply.

    A bare `json.loads` assumes the reply is nothing but JSON. Models sometimes
    wrap it in a fence, or repeat the answer as `{...}\\n{...}`, and both fail —
    the second with `Extra data: line N column 1`. `raw_decode` stops at the end
    of the first complete value and ignores whatever trails it.
    """
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```[a-zA-Z]*\n?", "", cleaned)
        cleaned = re.sub(r"```$", "", cleaned).strip()
    start = cleaned.find("{")
    if start == -1:
        raise ValueError("response is not a JSON object")
    value, _end = json.JSONDecoder().raw_decode(cleaned[start:])
    if not isinstance(value, dict):
        raise ValueError(f"expected a JSON object, got {type(value).__name__}")
    return value


# ------------------------------------------------------------------ text rules


def _is_word_char(char: str) -> bool:
    """A letter, a digit, or a combining mark that belongs to the letter before it.

    `\\w` is wrong here. It classifies every combining mark as a non-word
    character, so Thai and Devanagari text — where the vowel sign and tone mark
    are not optional decoration but the character itself — fragments at each
    mark. Splitting `ตู้เสื้อผ้า` that way produced the junk tokens `ต`, `เส`,
    `า`, which is why a Thai keyword repeating the subtitle went undetected.
    Marks are always part of the word they follow.
    """
    return char.isalnum() or unicodedata.category(char).startswith("M")


def _tokens(value: str) -> list[str]:
    """Split on whitespace and punctuation while keeping marks attached."""
    tokens: list[str] = []
    current: list[str] = []
    for char in unicodedata.normalize("NFKC", value).casefold():
        if _is_word_char(char):
            current.append(char)
        elif current:
            tokens.append("".join(current))
            current = []
    if current:
        tokens.append("".join(current))
    return tokens


def normalize(term: str) -> str:
    """Fold a term to a comparison key.

    Case, width and diacritics are noise for the duplicate check: "T-Shirt",
    "ｔ-ｓｈｉｒｔ" and "t shirt" are the same search, and counting them as two
    terms spends budget twice for one query.

    Diacritics are only folded for Latin text. Elsewhere the mark is the letter:
    dropping it turned Thai `ตู้เสื้อผ้า` into `ตเสอผา`, so the same wardrobe
    term could be paid for twice in one field.
    """
    folded = unicodedata.normalize("NFKC", term.casefold())
    non_ascii = [char for char in folded if ord(char) > 127]
    if non_ascii and any("LATIN" not in unicodedata.name(char, "") for char in non_ascii if not unicodedata.category(char).startswith("M")):
        return "".join(char for char in folded if _is_word_char(char))
    decomposed = unicodedata.normalize("NFKD", folded)
    stripped = "".join(char for char in decomposed if not unicodedata.combining(char))
    return "".join(char for char in unicodedata.normalize("NFKC", stripped) if _is_word_char(char))


def words(value: str) -> set[str]:
    """The distinct words of the name and subtitle, folded for comparison."""
    return {normalize(word) for word in _tokens(value) if normalize(word)}


def is_covered(term: str, indexed: set[str]) -> bool:
    """True when a term is fully indexed already by the name or subtitle.

    A multi-word term survives a partial overlap: "outfit planner" still earns
    a ranking for "planner" even if "outfit" is in the subtitle. A single word
    has nothing left to win. A script with no spaces between words — Thai,
    Chinese, Japanese — is checked by substring instead, because its "words"
    are not separable without a dictionary and `_tokens` returns the whole run.
    """
    key_words = [normalize(part) for part in _tokens(term) if normalize(part)]
    if not key_words:
        return True
    if len(key_words) == 1:
        folded = key_words[0]
        return any(folded in indexed_word for indexed_word in indexed) or folded in indexed
    return all(word in indexed for word in key_words)


def length(terms: list[str]) -> int:
    if not terms:
        return 0
    return sum(len(term) for term in terms) + len(SEPARATOR) * (len(terms) - 1)


def split_keywords(value: str) -> list[str]:
    return [term.strip() for term in value.split(SEPARATOR) if term.strip()]


# ------------------------------------------------------------------- the plan


def rules_version() -> str:
    """Fingerprint the rules that decide what may enter a keyword field.

    The plan is cached across runs, so an entry written before a rule existed
    outlives the rule. Three locales planned before the forbidden-term filter was
    added kept `تطبيق` ("app") and a subtitle duplicate in the final plan, because
    resume saw an entry and moved on. Stamping every entry with this hash makes a
    rule change invalidate only the entries it could affect.
    """
    payload = json.dumps(
        {
            "budget": BUDGET,
            "model": MODEL,
            "forbidden_words": sorted(FORBIDDEN_WORDS),
            "forbidden_substrings": FORBIDDEN_SUBSTRINGS,
            "intent_order": INTENT_ORDER,
            # The folding and tokenizing rules decide whether a proposal is a
            # duplicate or is already indexed, so a change there invalidates a
            # plan exactly like a change to the forbidden list. Bump this by hand
            # whenever `normalize`, `_tokens` or `is_covered` change: without it a
            # plan built on the old rules survives the fix, which is how Thai kept
            # paying for a term its own subtitle already indexed.
            "tokenizer": "marks-attached-v2",
        },
        sort_keys=True,
        ensure_ascii=False,
    )
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:16]


def basis_hash(english: dict) -> str:
    """Fingerprint the source copy a plan was derived from.

    Apple indexes the name and subtitle alongside the keyword field, so the
    planner spends its 100 characters avoiding terms those two already contain.
    That makes the plan a function of the subtitle — but the plan only recorded
    `_rules`, so when a retranslation rewrote 35 of 49 subtitles the entries
    still read as current while their redundancy check was against text that no
    longer existed. Four locales kept a keyword the checker then rejected for
    exactly that reason. Hashing the basis invalidates the entries a copy change
    actually invalidates, without touching the rest.
    """
    payload = json.dumps(
        {field: english.get(field, "") for field in ("name", "subtitle")},
        sort_keys=True,
        ensure_ascii=False,
    )
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:16]


def is_stale(entry: dict, english: dict | None = None) -> bool:
    if entry.get("_rules") != rules_version():
        return True
    if english is not None and entry.get("_basis") != basis_hash(english):
        return True
    return False


def load_plan() -> dict:
    if not PLAN_PATH.exists():
        return {}
    try:
        return {entry["locale"]: entry for entry in json.loads(PLAN_PATH.read_text(encoding="utf-8")).get("locales", [])}
    except (json.JSONDecodeError, KeyError):
        return {}


def write_plan(plan: dict, by_asc: dict) -> None:
    merged = [
        plan[code]
        for code in sorted(plan, key=lambda c: (by_asc[c]["tier"], c) if c in by_asc else (9, c))
    ]
    PLAN_PATH.write_text(
        json.dumps({"model": MODEL, "budget": BUDGET, "locales": merged},
                   ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def plan_locale(
    locale: dict, listing: dict, indexed: set[str], keys: list[str], rebuild: bool = False
) -> dict:
    current = [] if rebuild else split_keywords(listing.get("keywords", ""))
    seen: set[str] = set()
    kept: list[str] = []
    dropped: list[dict] = []
    for term in current:
        key = normalize(term)
        if not key:
            continue
        if key in seen:
            dropped.append({"term": term, "reason": "duplicate"})
            continue
        if is_covered(term, indexed):
            dropped.append({"term": term, "reason": "already in name or subtitle"})
            continue
        if is_forbidden(term):
            dropped.append({"term": term, "reason": "discouraged or infringing term"})
            continue
        seen.add(key)
        kept.append(term)

    prompt = (
        f"Locale: {locale['asc']} ({locale['native']}).\n"
        f"App name as shown in this storefront: {listing.get('name', '')}\n"
        f"Subtitle as shown in this storefront: {listing.get('subtitle', '')}\n"
        f"Terms already present in the keyword field: {', '.join(kept) or '(none)'}\n\n"
        "The app is an AI wardrobe: photograph your clothes, get a searchable "
        "digital closet, weather-aware outfit suggestions, virtual try-on, and "
        "AI photoshoot/headshot images. There is a free month of Pro, then a "
        "permanent free tier.\n\n"
        "Propose search terms for this storefront's keyword field. Never repeat "
        "a term or a word from the name or subtitle above."
    )
    proposal = MODEL_CALL(keys, prompt) if MODEL_CALL is not None else agnes_json(prompt)
    candidates = [
        item for item in proposal.get("terms", []) if isinstance(item, dict) and item.get("term")
    ]
    candidates.sort(key=lambda item: INTENT_ORDER.get(item.get("intent", "adjacent"), 3))

    added: list[str] = []
    rejected: list[dict] = []
    for item in candidates:
        term = item["term"].strip().replace(SEPARATOR, "").strip()
        key = normalize(term)
        if not key or key in seen:
            rejected.append({"term": term, "reason": "duplicate"})
            continue
        if is_covered(term, indexed):
            rejected.append({"term": term, "reason": "already in name or subtitle"})
            continue
        if is_forbidden(term):
            rejected.append({"term": term, "reason": "discouraged or infringing term"})
            continue
        if len(term) > 24:
            rejected.append({"term": term, "reason": f"{len(term)} chars"})
            continue
        if length(kept + added + [term]) > BUDGET:
            rejected.append({"term": term, "reason": "does not fit the remaining budget"})
            continue
        seen.add(key)
        added.append(term)

    final = kept + added
    return {
        "locale": locale["asc"],
        "native": locale["native"],
        "tier": locale["tier"],
        "keywords": SEPARATOR.join(final),
        "characters": length(final),
        "kept": kept,
        "added": added,
        "dropped": dropped,
        "rejected": rejected,
        "_rules": rules_version(),
        "_basis": basis_hash(listing),
    }


def load() -> tuple[dict, dict]:
    listings = json.loads(LISTINGS.read_text(encoding="utf-8"))
    locales = json.loads(LOCALES.read_text(encoding="utf-8"))
    by_asc = {entry["asc"]: entry for entry in locales["locales"]}
    return listings, by_asc


def looks_fragmented(code: str, terms: list[str]) -> bool:
    """True when a keyword string has been shredded into syllables.

    The Vietnamese field `phối,thời,trang,tủ,đồ,cá,nhân,...` is the failure this
    catches: "trang phục" (outfit) split into "trang" and "phục", where neither
    fragment matches a search on its own. Short terms are normal in CJK and Thai,
    which have no word spaces, so those are exempt; in every other script a
    median term length of four characters or less, across ten or more terms,
    means phrase boundaries were lost.
    """
    if code in NO_WORD_SPACES or len(terms) < 10:
        return False
    lengths = sorted(len(term) for term in terms)
    median = lengths[len(lengths) // 2]
    return median <= 4


def report(listings: dict, by_asc: dict, limit: list[str] | None) -> list[dict]:
    rows = []
    for code, listing in listings.items():
        if code.startswith("_") or code not in by_asc:
            continue
        if limit and code not in limit:
            continue
        indexed = words(listing.get("name", "")) | words(listing.get("subtitle", ""))
        current = split_keywords(listing.get("keywords", ""))
        wasted = [term for term in current if is_covered(term, indexed)]
        rows.append(
            {
                "locale": code,
                "tier": by_asc[code]["tier"],
                "used": length(current),
                "terms": len(current),
                "wasted": wasted,
                "room": BUDGET - length(current),
                "fragmented": looks_fragmented(code, current),
            }
        )
    rows.sort(key=lambda row: (row["tier"], -row["room"]))
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", action="store_true", help="ask the model and write keywords.json")
    parser.add_argument(
        "--provider",
        choices=("agnes", "gemini"),
        default="agnes",
        help="text model transport; Agnes allows 1500 requests per 5 hours, "
             "Gemini's free tier only 500 per day",
    )
    parser.add_argument("--apply", action="store_true", help="merge keywords.json into listings.json")
    parser.add_argument("--locale", help="comma-separated ASC codes")
    parser.add_argument(
        "--rebuild",
        action="store_true",
        help="discard the existing keyword string instead of building on it; "
             "use for a locale whose keywords are malformed",
    )
    parser.add_argument("--sleep", type=float, default=0.3, help="seconds between locales")
    parser.add_argument(
        "--force",
        action="store_true",
        help="re-plan locales already present in keywords.json",
    )
    parser.add_argument(
        "--strip",
        action="store_true",
        help="remove forbidden terms from listings.json with no model call; a "
             "stopgap that makes the gate pass without spending quota",
    )
    args = parser.parse_args()

    listings, by_asc = load()
    limit = [code.strip() for code in args.locale.split(",")] if args.locale else None

    if args.strip:
        # Replacing a banned term with a good one is a judgement call and needs
        # the model. DELETING one is not: Apple already indexes the app name and
        # subtitle, so a keyword of "app" was never earning its characters. This
        # path exists so the listing gate can go green while the quota that
        # `--plan` needs is spent on the ARB migration instead.
        removed_total = 0
        for code, listing in sorted(listings.items()):
            if code.startswith("_") or code not in by_asc or (limit and code not in limit):
                continue
            terms = split_keywords(listing.get("keywords", ""))
            kept, removed = [], []
            for term in terms:
                (removed if is_forbidden(term) else kept).append(term)
            if not removed:
                continue
            listing["keywords"] = SEPARATOR.join(kept)
            removed_total += len(removed)
            print(
                f"  {code:<9} -{len(removed)} term(s) "
                f"({', '.join(removed)}) -> {len(listing['keywords'])} char(s)"
            )
        if not removed_total:
            print("No forbidden term in any keyword field.")
            return 0
        LISTINGS.write_text(
            json.dumps(listings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"\nremoved {removed_total} forbidden term(s) from {LISTINGS.relative_to(ROOT)}")
        print("Run --plan and --apply once quota allows, to refill the reclaimed space.")
        return 0

    if args.apply:
        if not PLAN_PATH.exists():
            print(f"No plan at {PLAN_PATH}. Run --plan first.", file=sys.stderr)
            return 1
        plan = json.loads(PLAN_PATH.read_text(encoding="utf-8"))
        changed = 0
        for entry in plan["locales"]:
            code = entry["locale"]
            if limit and code not in limit:
                continue
            listing = listings.get(code)
            if listing is None:
                print(f"  SKIP {code}: not in listings.json", file=sys.stderr)
                continue
            if listing.get("keywords") == entry["keywords"]:
                continue
            listing["keywords"] = entry["keywords"]
            # Tells `scripts/i18n/translate_listings.py` to keep this field when
            # it rewrites the prose. Without the marker, the next prose change
            # would overwrite a planned keyword field with a translated one.
            listing["_keywords_planned"] = True
            changed += 1
        if changed:
            LISTINGS.write_text(
                json.dumps(listings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )
        print(f"Updated {changed} locale(s) in {LISTINGS.relative_to(ROOT)}")
        return 0

    if args.plan:
        global MODEL_CALL
        if args.provider == "gemini":
            MODEL_CALL = gemini_json
            keys = load_env()
            if not keys:
                print("No Gemini key found in the environment or backend/.env", file=sys.stderr)
                return 1
        else:
            # Agnes reads AGNES_AI_API_KEY itself (env, then ~/.zshrc). The key
            # list is unused on that path but the signature is shared.
            keys = ["agnes"]
        targets = [
            code
            for code in listings
            if not code.startswith("_") and code in by_asc and (not limit or code in limit)
        ]
        targets.sort(key=lambda code: (by_asc[code]["tier"], code))

        # Resume across runs. A 50-locale plan costs 50 API calls and several
        # minutes, and an interruption that discarded the finished locales made
        # the tool pay for the same work twice.
        existing = load_plan()
        stale = [
            code for code in targets
            if code in existing and is_stale(existing[code], listings[code])
        ]
        if stale:
            print(
                f"{len(stale)} cached entr(y/ies) predate the current rules or copy and "
                f"will be re-planned: {', '.join(stale[:8])}{'…' if len(stale) > 8 else ''}"
            )
        todo = [
            code for code in targets
            if args.rebuild
            or code not in existing
            or is_stale(existing[code], listings[code])
            or args.force
        ]
        if not todo:
            print(f"Plan is already complete for {len(targets)} locale(s). "
                  "Pass --force to re-plan.")
            return 0
        print(f"{len(todo)} of {len(targets)} locale(s) to plan, "
              f"{len(targets) - len(todo)} already present")

        failures = 0
        for index, code in enumerate(todo, start=1):
            listing = listings[code]
            indexed = words(listing.get("name", "")) | words(listing.get("subtitle", ""))
            print(f"[{index}/{len(todo)}] {code} ({by_asc[code]['native']})", flush=True)
            try:
                entry = plan_locale(by_asc[code], listing, indexed, keys, rebuild=args.rebuild)
            except Exception as error:  # noqa: BLE001 - one locale must not sink the run
                failures += 1
                print(f"  FAILED: {error}", file=sys.stderr, flush=True)
                continue
            existing[code] = entry
            # Written after every locale, so an interrupted run resumes instead
            # of repeating calls the account has already paid for.
            write_plan(existing, by_asc)
            print(
                f"  {entry['characters']}/{BUDGET} chars, +{len(entry['added'])} added, "
                f"-{len(entry['dropped'])} dropped",
                flush=True,
            )
            time.sleep(args.sleep)

        print(f"\nWrote {PLAN_PATH.relative_to(ROOT)} for {len(existing)} locale(s)")
        if failures:
            print(f"{failures} locale(s) failed; re-run to retry only those", file=sys.stderr)
            return 1
        return 0

    rows = report(listings, by_asc, limit)
    total_room = 0
    total_wasted = 0
    fragmented = []
    print(f"{'locale':10} {'tier':>4} {'used':>5} {'terms':>6} {'room':>5}  notes")
    for row in rows:
        total_room += max(row["room"], 0)
        total_wasted += sum(len(term) + 1 for term in row["wasted"])
        notes = []
        if row["wasted"]:
            notes.append(f"redundant: {', '.join(row['wasted'][:4])}")
        if row["fragmented"]:
            notes.append("looks fragmented into syllables")
            fragmented.append(row["locale"])
        print(
            f"{row['locale']:10} {row['tier']:>4} {row['used']:>5} "
            f"{row['terms']:>6} {row['room']:>5}  {'; '.join(notes)}"
        )
    print(
        f"\n{len(rows)} locale(s). {total_room} unused character(s), "
        f"{total_wasted} character(s) spent on terms the subtitle already indexes."
    )
    if fragmented:
        print(
            f"Fragmented: {', '.join(fragmented)}. "
            "Repair with: --plan --rebuild --locale " + ",".join(fragmented)
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
