# Core beliefs

Status: verified  
Last reviewed: 2026-07-22

Adapted for FitCheck AI from agent-first harness engineering practice. These beliefs guide agents and humans when tradeoffs appear.

## 1. Humans steer; agents execute

Humans set priorities, acceptance criteria, and product taste. Agents implement, test, document, and iterate. When an agent fails, the fix is almost never “try harder”—it is “what capability, doc, or invariant is missing in the harness?”

## 2. The repository is the system of record

If knowledge lives only in chat, Slack, or someone’s head, it does not exist for the next agent run. Prefer versioned markdown, schemas, plans, and code. Progressive disclosure: short maps first, deep docs on demand.

## 3. Map, not encyclopedia

Root `AGENTS.md` / `CLAUDE.md` stay small. Durable rules live under `docs/` and are linked. A giant instruction file crowds out the task and rots.

## 4. Enforce invariants, not micro-style

Boundaries, validation at edges, security, and reliability are mechanical. Inside those boundaries, prefer correct and maintainable solutions over bike-shedding style—unless a golden principle or lint says otherwise.

## 5. Parse, don’t YOLO

Validate request/response and external payloads at boundaries (Pydantic, Zod, typed clients). Do not probe ad-hoc JSON shapes deep in business logic.

## 6. Thin edges, rich services

HTTP routes and UI event handlers stay thin. Domain behavior lives in services (backend) or dedicated hooks/stores with clear ownership (frontend).

## 7. Shared utilities over copy-paste helpers

When the same invariant appears twice, centralize it. Agents amplify existing patterns—including bad ones—so duplication is debt with interest.

## 8. Plans are first-class for non-trivial work

Multi-file or multi-app work gets an exec plan with goals, acceptance criteria, progress, and decisions. Trivial fixes do not need ceremony.

## 9. Verification before “done”

Run the relevant checks (`pytest`, lint/build, architecture/docs scripts, browser QA for UI). Content must remain visible without animation hacks; controls must work if they look interactive.

## 10. Garbage-collect continuously

Technical debt and doc drift compound. Prefer small cleanup PRs and updates to `QUALITY_SCORE.md` / `tech-debt-tracker.md` over quarterly archaeology. Encode human taste into docs and lints once, then reapply automatically.

## 11. Agent legibility

Prefer tools and abstractions agents can inspect in-repo: OpenAPI, migrations, structured logs with correlation IDs, explicit env templates. Opaque vendor magic is a last resort.

## 12. Product truth over aspirational docs

Documentation follows implemented behavior. When code and docs disagree, fix the wrong one in the same change—usually the docs, unless the code is the bug.

## Agent loop (default)

1. Orient via map → architecture → domain doc.  
2. Plan if non-trivial.  
3. Implement.  
4. Self-review against architecture and beliefs.  
5. Verify with commands / browser.  
6. Update docs and debt trackers.  
7. Escalate only for judgment or missing harness capability.
