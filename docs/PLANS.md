# Plans policy

Last updated: 2026-07-22

Execution plans are first-class repository artifacts. They replace tribal memory for multi-step work.

## When to write a plan

| Change type | Plan required? |
|-------------|----------------|
| Typo, one-liner, single-file obvious fix | No |
| Multi-file change in one app | Yes if > ~half day or unclear acceptance criteria |
| Cross-app (backend + frontend/flutter) | Yes |
| Schema / auth / billing / AI provider behavior | Yes |
| Harness, CI, architecture rules | Yes |

## Where plans live

```text
docs/exec-plans/
├── README.md
├── tech-debt-tracker.md
├── active/           # work in flight
│   └── _TEMPLATE.md
└── completed/        # finished plans (dated)
```

## Lifecycle

1. Copy `active/_TEMPLATE.md` to `active/<short-name>.md`.  
2. Fill goal, non-goals, acceptance criteria, verification commands.  
3. Keep a **progress log** and **decision log** as you work.  
4. When done, move to `completed/YYYY-MM-DD-<short-name>.md`.  
5. Link related tech debt in `tech-debt-tracker.md` if anything was deferred.

## Lightweight vs full plans

- **Lightweight:** goal + acceptance + verification bullets (small multi-file work).  
- **Full:** template sections including risks, rollout, and decision log (cross-cutting).

## Rules for agents

- Do not keep the only plan in chat history.  
- Update the plan file in the same branch as the code.  
- Prefer linking to code paths and docs over pasting large code blocks into the plan.
