# Skills refresh (2026-10-04)

Vendored skills in `.agents/skills` had sat unchanged since Feb 2026. Checked all 15
against upstream; refreshed the outdated vendor-owned ones. Scope chosen by reader:
vendor skills only, adopting upstream names and layout.

## What changed

1. `audit-website` — pulled `squirrelscan/skills@dcf16bf` (`skills/audit-website`).
   SKILL.md rewritten (now "260+ rules" + fix-loop workflow), `agents/openai.yaml`
   updated, upstream `README.md` added. + SOURCE.md.
2. `vercel-react-best-practices/` renamed to `react-best-practices/` to match
   `vercel-labs/agent-skills@063bee9` (`skills/react-best-practices`).
   New: `metadata.json`, `README.md`, 16 new rules, `_sections.md`, `_template.md`;
   AGENTS.md, SKILL.md, and 2 rules updated. Upstream frontmatter still says
   `name: vercel-react-best-practices`; kept verbatim. + SOURCE.md.
3. `frontend-design` — pulled `anthropics/skills@8a1541c` (`skills/frontend-design`).
   SKILL.md rewritten around subject-matter-driven direction. + SOURCE.md.
4. `web-design-guidelines` — verified byte-identical to upstream. No files changed.
   + SOURCE.md recording the pin.

## Left alone (out of scope)

- `seo-geo`: current (upstream skill last changed 2026-02-15, local copy newer).
- Custom blog-system skills (`content-strategy`, `copywriting`, `marketing-psychology`,
  `programmatic-seo`, `seo-audit`): no upstream to pull from.
- `find-skills`, `systematic-debugging`, `ui-ux-pro-max`: source not resolved.
- `App Designer/`, `Motion Director/`: uncommitted vendor drops with spaced names and
  nested layout. Normalize separately if wanted.

## Verification

- `SKILL.md` frontmatter `name` checked per folder (only intentional mismatch is
  `react-best-practices/` vs upstream's `vercel-react-best-practices`, documented above).
- No stale strings: `rg "230\+ rules"` clean in `audit-website/`.
- `python scripts/check_docs_structure.py` passes.
- Backups of the 4 pre-update folders: `/tmp/skills-backup-20261004/`.
