# Tech debt tracker

Last updated: 2026-07-22

| ID | Item | Severity | Domain | Notes |
|----|------|----------|--------|-------|
| TD-001 | Frontend has no formal unit/e2e test runner | high | web | Validate via lint/build only |
| TD-002 | No frontend CI workflow | medium | infra | Backend has ruff+pytest; web does not. Related: TD-011 |
| TD-003 | `docker-compose.yml` exists while local Docker is forbidden | low | infra | Clarify deploy-only vs remove/document |
| TD-004 | Curated `api-spec.md` can drift from OpenAPI | medium | docs | Prefer live OpenAPI; regen or spot-check |
| TD-005 | `docs/generated/db-schema.md` can drift from migrations | medium | docs | Run generate script when migrations change |
| TD-006 | Duplicate/overlapping product notes (specs + old feature notes) | low | docs | Consolidate over time |
| TD-007 | Flutter architecture doc still thin | medium | mobile | Expand `FLUTTER.md` as decisions accrue |
| TD-008 | DESIGN.md is draft | low | design | Flesh out tokens/patterns when brand solidifies |
| TD-009 | In-memory job stores not multi-instance safe | high | reliability | OK for single instance; document for scale-out |
| TD-010 | Optional Pinecone paths under-documented operationally | low | backend | Config-sensitive recommendations |
| TD-011 | Frontend CI (lint/build) not wired | medium | infra | Stretch / Phase D. Overlaps TD-002 (same gap: no web CI job); keep both until one workflow lands, then close both |
| TD-012 | Flutter package CLAUDE.md missing | low | mobile | Root map covers mobile via docs/FLUTTER.md |
| TD-013 | Route module LOC taste lint not mechanical | low | backend | Deferred from harness plan §6: soft “routes stay thin” guidance only; no automated LOC ceiling in `check_architecture.py` |
| TD-014 | Dead SQLAlchemy imports of missing `app.db.base_class` | medium | backend | `models/calendar.py` and `models/gamification.py` import `from app.db.base_class import Base` but the module does not exist (Supabase-first stack). Clean up or remove legacy ORM stubs |

## Process

- Add rows when you consciously defer work.  
- Remove or strike through when fixed (leave a short “fixed YYYY-MM-DD” note or delete).  
- Monthly GC: see `docs/exec-plans/README.md`.
