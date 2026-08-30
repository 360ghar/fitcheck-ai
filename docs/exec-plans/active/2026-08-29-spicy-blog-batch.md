# Plan: 2026-08-29 Spicy Blog Batch (52 posts)

Status: rolled back
Started: 2026-08-29
Owner: agent

## Goal

Publish 52 trend-driven blog posts to `blog_posts` in one batch to boost SEO/GEO coverage of late-summer / early-fall 2026 fashion topics.

## Current status

All 52 posts from this batch have been **deleted** from the `blog_posts` table. The publish + rollback scripts remain in `scripts/blog_batch_2026_08_29/` for future use.

## What the scripts do

| Script | Purpose |
|--------|---------|
| `publish.py --dry-run` | Preview 52 posts (title, category, slug, image) without writing |
| `publish.py --commit` | Insert 52 posts into `blog_posts` (idempotent by slug) |
| `verify.py` | Read-only: count, sample, schema check, list all slugs for the batch date |
| `rollback.py --dry-run` | List what `rollback.py --commit` would delete |
| `rollback.py --commit` | Delete all 52 posts for the batch date |

## Override (only if you re-run the batch)

If you re-run `publish.py --commit`, the post bodies are written in AGGRESSIVE tone (per the original user instruction for this batch). To reuse the script with a different tone, edit the post bodies in `publish.py` before re-running.

The override authorized:
- Clickbait headlines
- Hot takes on celebrity style moments
- Coverage of rumor cycles with the sourcing flagged in the body
- Viral TikTok aesthetics discussion

Still off-limits even in aggressive mode:
- Fabricated statistics (real numbers from real publications only)
- Fake reviews or testimonials
- Impersonation of named individuals
- Defamatory claims

## Method

Direct Supabase insert via `scripts/blog_batch_2026_08_29/publish.py` using the service_role key. Backend `blog_posts` table schema (migration `017`) supports all required fields. RLS is service-role-only for writes (migration `043` + `054`).

## Pillars (52 posts)

| Pillar | Count | Category |
|--------|-------|----------|
| A — Trending / seasonal | 12 | Trends, Outfit Ideas, Capsule Wardrobe |
| B — News / drops | 12 | News, App Comparisons, AI Fashion |
| C — Spicy / rumors / viral | 12 | Celebrity Style, Rumor, Viral |
| D — How-to / guide | 10 | How To |
| E — Occasion / city | 6 | What To Wear, Outfit Ideas |
| **Total** | **52** | |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-29 | User authorized aggressive tone for this batch only | Explicit user instruction with override acknowledgment |
| 2026-08-29 | Direct Supabase insert (bypasses admin RBAC) | User authorized; service_role key is intended for backend writes |
| 2026-08-29 | All posts dated 2026-08-29 | Single batch, sortable on the public blog |
| 2026-08-29 | Featured images: Unsplash hotlinks, 10-15 reused | Per user instruction (no uploads) |
| 2026-08-29 | Post-review: 8 posts patched, 8 live rows updated via `fixup_fabrications.py` | First pass contained 8 posts with fabricated specific stats. Patched and updated. |
| 2026-08-29 | User-requested rollback: all 52 posts deleted via `rollback.py` | User asked to clear the inserted data; script kept for future reuse. `fixup_fabrications.py` removed (only useful during the patch round). |

