# Tech debt tracker

Last updated: 2026-07-26

| ID | Item | Severity | Domain | Notes |
|----|------|----------|--------|-------|
| TD-001 | Frontend has no e2e test suite | medium | web | Vitest + RTL unit tests added 2026-07-25 (16 tests); e2e (Playwright/Cypress) still missing |
| TD-002 | ~~No frontend CI workflow~~ | medium | infra | **Fixed 2026-07-26** — `.github/workflows/frontend-ci.yml` added (lint + build on push/PR to `frontend/**`) |
| TD-003 | `docker-compose.yml` exists while local Docker is forbidden | low | infra | Clarify deploy-only vs remove/document |
| TD-004 | Curated `api-spec.md` can drift from OpenAPI | medium | docs | Prefer live OpenAPI; regen or spot-check |
| TD-005 | `docs/generated/db-schema.md` can drift from migrations | medium | docs | Run generate script when migrations change |
| TD-006 | Duplicate/overlapping product notes (specs + old feature notes) | low | docs | Consolidate over time |
| TD-007 | Flutter architecture doc still thin | medium | mobile | Expand `FLUTTER.md` as decisions accrue |
| TD-008 | DESIGN.md is draft | low | design | Flesh out tokens/patterns when brand solidifies |
| TD-009 | In-memory job stores not multi-instance safe | high | reliability | OK for single instance; document for scale-out |
| TD-010 | Optional Pinecone paths under-documented operationally | low | backend | Config-sensitive recommendations |
| TD-011 | ~~Frontend CI (lint/build) not wired~~ | medium | infra | **Fixed 2026-07-26** — same workflow as TD-002 (`frontend-ci.yml`) |
| TD-012 | Flutter package CLAUDE.md missing | low | mobile | Root map covers mobile via docs/FLUTTER.md |
| TD-013 | Route module LOC taste lint not mechanical | low | backend | Deferred from harness plan §6: soft “routes stay thin” guidance only; no automated LOC ceiling in `check_architecture.py` |
| TD-014 | Dead SQLAlchemy imports of missing `app.db.base_class` | medium | backend | `models/calendar.py` and `models/gamification.py` import `from app.db.base_class import Base` but the module does not exist (Supabase-first stack). Clean up or remove legacy ORM stubs |
| TD-015 | Flutter route-refresh workers are dead code | medium | mobile | `ever(Get.routing.obs, …)` in `wardrobe_controller._setupRouteListener` and `debounce(Get.routing.obs, …)` in `outfit_list_controller._setupRouteListener` each allocate a **fresh** `Rx<Routing>` around a snapshot that is never written, so neither handler can ever fire. "Refresh wardrobe/outfits after returning from add/edit" has therefore never worked; the compensating cross-controller calls in `item_add_controller` (749/850), `batch_extraction_controller` (511/1367), `outfit_creation_controller:136` and `outfit_generation_controller:121` exist to paper over it. Replace with a `NavigatorObserver` (`AppRouteObserver` already exists) or an explicit refresh signal, then reassess whether the cross-controller writes are still needed. Found 2026-07-26 while fixing the Obx markNeedsBuild-during-build class |

## Process

- Add rows when you consciously defer work.  
- Remove or strike through when fixed (leave a short “fixed YYYY-MM-DD” note or delete).  
- Monthly GC: see `docs/exec-plans/README.md`.
