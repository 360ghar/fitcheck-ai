# Execution plans

Active and completed work plans for agents and humans. Policy: `docs/PLANS.md`.

## Layout

- `active/` — in-progress plans  
- `completed/` — finished plans (keep for history and onboarding)  
- `tech-debt-tracker.md` — known debt and golden-principle gaps  
- `active/_TEMPLATE.md` — copy this to start  

## Monthly garbage collection (lightweight)

On a regular cadence (or when quality grades slip):

1. Scan `QUALITY_SCORE.md` for domains graded C or below.  
2. Scan `tech-debt-tracker.md` for items without owners or dates.  
3. Open small cleanup PRs (docs freshness, import violations, dead helpers).  
4. Mark design-doc index statuses if anything went stale.  
5. Prefer many tiny PRs over a big-bang rewrite.

No scheduled agent is required for v1; humans or ad-hoc agent runs perform this checklist.
