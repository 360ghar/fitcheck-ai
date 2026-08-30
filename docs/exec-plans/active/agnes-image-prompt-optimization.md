# Agnes image prompt optimization (prompt strings only)

**Status:** done (2026-08-21) · **Branch:** `fix/full-bug-sweep-241` · **Date:** 2026-08-21

## Goal

Improve output quality and refusal rate of image generation on the production
default provider (`agnes-image-2.1-flash`, flash-tier) by editing ONLY prompt
strings, their assembly order, and the test assertions that pin them. No
provider/service/flow changes.

## Agnes facts driving each change

- Flash-tier model: long negative lists and filler dilute adherence
  (`prompt_fidelity.py` header: 5–8 negatives max).
- Content refusals arrive as HTTP 400 "Unable to generate this content"
  (`ai_provider_service._is_content_policy_rejection`) → fewer filter-bait
  tokens in person prompts = fewer hard failures.
- Image calls become ONE flat prompt (`/images/generations`) or one user
  message → whatever renders last competes with the locks. User `custom_prompt`
  currently renders last in all three outfit branches.
- Matte contract: `_FLAT_WHITE_BACKDROP` / `_MATTE_READY_BACKGROUND` stay
  byte-identical (guard thresholds depend on them).

## Changes

`backend/app/agents/prompt_fidelity.py`

1. Add `NO_PERSON_NEGATIVES` (garment-only AVOID set, ≤8 tokens).
2. Trim `PRODUCT_REFERENCE_LOCK` / `PRODUCT_CUSTOM_BACKGROUND_LOCK` AVOID
   lists (~19 → 8 tokens); keep positive body clauses.
3. Remove "wrong ethnicity" from `SHORT_NEGATIVES` (refusal surface;
   `IDENTITY_LOCK` already pins appearance positively).

`backend/app/agents/image_generation_agent.py`

4. Flat-lay branch + no-reference product path use `NO_PERSON_NEGATIVES`.
5. Compress outfit inventory: omit unspecified fields instead of printing
   "unspecified" 4× per item (item numbering unchanged).
6. Move `custom_prompt` from final line to just after TASK/opener, labelled
   lower-priority than the locks; cap at 400 chars.
7. Append one-line closing identity reminder to avatar-outfit and try-on
   prompts.

Tests: update pinned string assertions in
`tests/unit/test_agents/test_image_generation_agent*.py`.

Out of scope: extraction/vision prompts, photoshoot planner system prompt,
background/matte strings, any non-prompt code.

## Verification

```bash
cd backend && source .venv/bin/activate
pytest tests/unit/test_agents tests/integration/test_outfit_item_references.py \
       tests/integration/test_outfit_source_reference.py -q
ruff check app/agents
```
