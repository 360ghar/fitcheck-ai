# Prompt accuracy pass

Status: code done; live-model eval pending.

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
