# Railway Infrastructure as Code

`railway.ts` is the single source for the Railway backend service
(backend only; frontend stays on Netlify). Railway CLI evaluates it —
Railway never reads this directory during deploys.

```bash
npm install -g @railway/cli
railway login
railway link                 # connect this repo to the Railway project
railway config plan          # read-only preview, secrets stay redacted
railway config apply         # confirm prompt, then applies
```

CI (`.github/workflows/railway-config.yml`, needs the `RAILWAY_TOKEN` repo
secret — a project token scoped to the target env):

| Trigger | Behavior |
|---------|----------|
| PR touches `.railway/**` | Plan + comment on the PR. Nothing applied. |
| PR merges | Applies the **pinned plan** a human reviewed on the PR. |
| Direct push to `main` | Plans, then applies — non-destructive only. |

A merge also fires a `push` event, so the direct-push job skips any commit
belonging to a merged PR; the PR apply owns those.

Direct pushes deliberately apply without `--confirm-destructive`, so a
destructive change (deleting a service or variable) fails instead of
running unreviewed. Apply those locally with `railway config apply` and
confirm the prompt.

Rules: service/project names must match the dashboard. `apply` deletes
services omitted from `railway.ts`, so check `plan` for deletes first.
Variables stay dashboard-managed via `preserve()` — values never enter git.
The CLI is pinned in the workflow; bump the pin deliberately.
