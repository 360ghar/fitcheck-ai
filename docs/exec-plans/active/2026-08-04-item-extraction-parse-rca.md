# RCA: item extraction false "No items found" after parser refactor

Status: active
Started: 2026-08-04
Owner: agent

## Goal

After the 2026-08-04 JSON-parser refactor (`json_utils` extraction landing in
commit `e245da4`), valid outfit photos intermittently failed extraction with
`Failed to parse item extraction response` server-side and a misleading
"No items found. Try a clearer, well-lit photo." client-side — even though the
model response contained the detected garment(s) (the `people` array parsed,
the `items` payload did not). This RCA documents the regression, the root
cause, the fix, and the regression coverage.

## Root cause

The refactor replaced the old greedy-regex helpers with
`app/utils/json_utils.extract_json_block()`, whose top-level scan counted
`{`/`}` (or `[`/`]`) characters **without understanding JSON strings**.
Any `{` or `}` inside a quoted string value terminates or extends the
candidate block at the wrong position:

- A **lone `{` inside a string** (e.g. `"detailedDescription": "cropped
  {boxy fit"`) increments the depth so the real closing `}` never reaches 0
  → `Unterminated JSON` → parse failure.
- A **lone `}` inside a string** closes the block early → `json.loads` of the
  truncated fragment fails → parse failure.
- The scan also committed to the **first** `{`/`[` it found, so stray braces
  in surrounding prose could poison the whole extraction (no candidate
  fallback).

`ItemExtractionAgent` then converted any parse failure into
`_empty_result(...)` — an empty `items` array that the client renders as
"No items found", blaming the user's photo. Because `people` parsing is
independent of `items`, the response could still show detected people while
all items were silently dropped (exactly the mixed output reported).

A secondary tolerance gap: some provider responses skip the envelope and
return the item array at the top level; `_parse_json_object` only accepted a
dict, so a valid bare array was also converted into "no items".

## Fixes (landed)

- **`backend/app/utils/json_utils.py`** — `extract_json_block()` now scans
  quote- and escape-aware (`_scan_balanced_block`): delimiters inside JSON
  strings (including `\"` escapes) neither close nor re-open the block.
  Every `{`/`[` candidate is scanned in order and only kept when the full
  block parses via `json.loads`, so stray braces in prose and unterminated
  first candidates fall through to the real payload. Existing fence handling
  and the `ValueError` contract are unchanged.
- **`backend/app/agents/item_extraction_agent.py`** —
  `_parse_json_object()` keeps its object-or-None contract but now reaches
  the hardened `extract_json_block` (via `safe_extract_json_object`), so
  braces/escapes inside strings no longer fail it. `extract_multiple_items`
  additionally tolerates a bare top-level item array (some providers skip
  the envelope) by normalizing it to `{"items": [...]}` before processing,
  instead of failing the extraction. The parse-failure log now records
  response *shape* (length, first/last non-whitespace character, bounded
  120-char preview) rather than the full raw body.

## Code

- `backend/app/utils/json_utils.py` — quote/escape-aware block scanner +
  candidate validation
- `backend/app/agents/item_extraction_agent.py` — tolerant
  `_parse_json_object` (bare-array normalization), failure-log shape fields

## Tests

- `backend/tests/test_json_utils.py` (new) — braces/brackets inside strings,
  escaped quotes, stray braces in prose, unterminated-first-candidate
  fall-through, fence + prose wrapping, `safe_extract_*` behavior with
  string braces
- `backend/tests/test_item_extraction_agent.py` — extraction-path
  regressions: `detailedDescription` containing `{}` + quotes still yields
  the detected item; bare top-level array responses are normalized into
  items; prose-wrapped fenced JSON with string braces still yields items

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest -q
ruff check app tests
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Progress log

| Date | Note |
|------|------|
| 2026-08-04 | Root-caused to `extract_json_block`'s quote-unaware bracket scan (landed `e245da4`). Fix landed: quote/escape-aware scan with candidate fallback + bare-array normalization + shape-only failure logging. 13 new `json_utils` tests + 3 extraction-path regressions; focused suites green. |

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None new (no TD entry required; existing `safe_extract_json_object` /
  `safe_extract_json_array` remain for callers that need object-vs-array
  discrimination).
