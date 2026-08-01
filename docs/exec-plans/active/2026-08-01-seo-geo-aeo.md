# Plan: SEO / GEO / AEO growth pass

Status: active
Started: 2026-08-01
Owner: agent

## Goal

Raise FitCheck AI's discoverability across traditional search (Google, Bing) and generative/answer engines (ChatGPT, Perplexity, Gemini, Copilot, Claude): fix technical SEO gaps, strengthen entity + structured data, add the Princeton GEO levers (statistics, citations, quotes, answer-first structure) to content, and launch new programmatic SEO surfaces (comparisons, glossary, city-wear pages, cost-per-wear calculator).

## Non-goals

- No fabricated statistics or fake reviews anywhere (brand honesty is a non-negotiable).
- No paid ads, no link schemes, no doorway pages.
- No external account setup (Search Console, GA4, YouTube upload, Wikidata, Product Hunt) — documented for humans to complete; no credentials exist in-repo.
- No backend API changes in this pass (IndexNow ping is a build-time script).

## Acceptance criteria

- [x] robots.txt covers new answer-engine crawlers (OAI-SearchBot, Perplexity-User, Meta-ExternalAgent, Applebot-Extended, Amazonbot, YouBot, Grokbot) and new route families.
- [x] Crawler soft-404s fixed: unknown public paths return 404 + noindex; missing blog posts return 404 via edge function.
- [x] Organization/WebSite schema upgraded (sameAs, SearchAction); blog articles carry Person author + speakable; landing carries VideoObject for the hosted promo.
- [x] IndexNow key file + build-time ping script (Bing/Copilot instant indexing).
- [x] Landing hero images converted to WebP (~80% smaller) and referenced.
- [x] Stats blocks (real plan limits) on landing + all five feature pages.
- [x] Cited statistics + sources rendered on key guides (NRF, WRAP, Iyengar & Lepper — real, verifiable).
- [x] llms-full.txt + per-page .md mirrors generated at build; llms.txt bumped with new pages.
- [x] Four new comparison pages (Stylebook, Indyx, Cladwell, Open Wardrobe) + two glossary pages.
- [x] Ten city "what to wear" pages (`/wear/<city>`) with unique climate/season content.
- [x] Interactive cost-per-wear calculator at `/tools/cost-per-wear-calculator`.
- [x] Guides show visible "last updated" dates.
- [x] New routes registered in App.tsx, sitemap, prerender-meta, robots.txt, llms.txt.
- [x] `npm run lint`, `npm test`, `npm run build` green.
- [x] Ops docs: measurement/monitoring + proprietary data-study blueprint.

## Context / links

- Research: Princeton GEO (arXiv:2311.09735), llmstxt.org, Google Search Central "AI features", platform quirks per seo-geo skill.
- Related code: `frontend/src/components/seo/*`, `frontend/scripts/*`, `frontend/netlify/*`, `frontend/public/{robots.txt,sitemap.xml,llms.txt}`.
- Existing SEO baseline was already strong (edge prerender, JSON-LD, intent pages, AI bot allows).

## Progress log

| Date | Note |
|------|------|
| 2026-08-01 | Started; implemented phases 1–3 (see git diff + verification section). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-01 | Keep landing JPGs in repo; switch references to WebP | Non-destructive; WebP unsupported by `sips` on this machine so conversion done via `cwebp` |
| 2026-08-01 | Video schema points at site-hosted `/video/promo.mp4` | No YouTube account in-repo; YouTube upload documented as human follow-up |
| 2026-08-01 | Soft-404 fix scoped to crawler user agents | Avoids breaking deep links/bookmarks for real users; robots.txt already gates app routes |

## Verification

```bash
cd frontend && npm run lint && npm test -- --run && npm run build
```
