# Prompt accuracy pass

Status: code done; live-model eval pending.

## Goal
Make extraction, try-on and photoshoot prompts accurate without regressions.

## Acceptance criteria
- [x] Prompt code fixes landed (see Done).
- [ ] Live eval: 10 extraction photos (worn, flat lay, group, product) and 5 try-on pairs, before/after, with no regression in category, color or brand accuracy.
- [ ] Results recorded in the progress log.

## Verification
Run the backend prompt unit tests (`cd backend && source .venv/bin/activate && pytest -k "item_extraction or photoshoot or prompt"`). Then run the live eval: extract each of the 10 photos and run the 5 try-on pairs against the old and new prompts. Record before/after pass counts in the progress log.

## Progress log
| Date | Note |
|------|------|
| 2026-09-30 | Code done; live eval pending |

## Decision log
| Date | Decision | Why |
|------|----------|-----|
| 2026-09-30 | Extraction temperature 0.1, planner 0.2 | Deterministic parsing |

## Done
- Single-item extraction prompt raised KeyError on every call (unescaped JSON braces). Fixed.
- Gemini native path now sends `json_schema` as `response_json_schema`.
- Extraction temperature 0.1 (`EXTRACTION_TEMPERATURE`); photoshoot planner 0.2.
- Multi-item: category enum, flat-lay support, face-only profile match with 0.6 cut-off, pattern list, color rules, visible-only brand.
- Try-on and reference map no longer claim every reference shows the person. Try-on replaces only the covered garment.
- Photoshoot appendix no longer repeats locks already in `sandwich_prompt`.
- Outfit heads no longer list items a third time; logo/text conflict removed; user text is delimited.
- Planner: no `subject_description`, unique settings, mixed framing, code-assigned index, gender-aware fallback outfits.

## Open
- Items have no stored dense description, so outfit renders cannot use it. Needs a migration + save path.
- `custom_prompt` API limit 2000 vs agent cap 400. Lowering the API limit breaks clients that send more.
- Live eval: 10 extraction photos (worn, flat lay, group, product) and 5 try-on pairs, before/after.
