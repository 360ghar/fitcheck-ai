# Plan: Harness engineering migration

Status: completed  
Started: 2026-07-22  
Completed: 2026-07-22  

## Goal

Adopt OpenAI-style harness engineering for FitCheck AI: progressive agent maps, docs as system of record, architecture checks, quality/debt tracking, and agent-first workflow—without requiring zero human-written code.

## Non-goals

- Dockerized local observability stack  
- Automerge / full agent PR farms  
- Rewriting application features  

## Acceptance criteria

- [x] Root `AGENTS.md` and `CLAUDE.md` identical short maps  
- [x] `docs/` article-style layout (design-docs, exec-plans, product-specs, generated, references, store)  
- [x] Old `1-product` … `5-development` tree removed  
- [x] `ARCHITECTURE.md` + `scripts/check_architecture.py`  
- [x] `scripts/check_docs_structure.py` + docs CI  
- [x] QUALITY_SCORE + tech-debt tracker  
- [x] Package CLAUDE files slimmed to pointers  

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-22 | Full harness ambition on existing monorepo | User preference; not greenfield zero-code |
| 2026-07-22 | Migrate docs (not dual-tree) | Avoid two systems of record |
| 2026-07-22 | Root maps identical only; package CLAUDE thin | Claude Code package context + single deep docs |

## Verification

```bash
python3 scripts/check_docs_structure.py
python3 scripts/check_architecture.py
cmp AGENTS.md CLAUDE.md
```

Logged re-check after orchestrated review fix-up (2026-07-22):

- `check_architecture.py` → pass  
- `check_docs_structure.py` → pass (now also scans backtick `` `docs/...` `` paths + requires store files)  
- `AGENTS.md` ≡ `CLAUDE.md`  
- `rg 'docs/app-store-|docs/play-store-aso'` → zero hits  
- Reference docs un-indented; store path rewrites complete  

## Post-review residuals fixed in same initiative

- Store path strings rewritten to `docs/store/*` (docs, flutter metadata, seed script, capture script)  
- Leading-space corruption fixed on error-handling / validation / launch-checklist  
- Docs checker hardened; architecture checker enforces `db ↛ services` and `utils` bans  
- Verification matrix + UI QA path documented  
