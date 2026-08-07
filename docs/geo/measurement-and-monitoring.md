# SEO / GEO / AEO measurement & monitoring

Last updated: 2026-08-08

This is the operational playbook for measuring and maintaining the growth work
in `docs/exec-plans/active/2026-08-01-seo-geo-aeo.md`. External accounts are
required — no credentials live in this repo.

## 1. Search Console & Bing (required)

1. Verify `https://fitcheckaiapp.com` in **Google Search Console** (DNS or HTML tag).
   - Submit `https://fitcheckaiapp.com/sitemap.xml`.
   - Watch the **Performance report → Web search type**: Google now reports
     traffic from AI Overviews and AI Mode inside this report (Google Search
     Central, Dec 2025 update).
2. Verify in **Bing Webmaster Tools** (imports from GSC; also enables Copilot
   discovery — Copilot only cites Bing-indexed pages).
   - IndexNow is already wired at build time (`scripts/ping-indexnow.mjs`);
     the key file lives at `public/.well-known/indexnow/<key>.txt` and the key
     at `public/indexnow-key.txt`. Confirm one successful ping in logs:
     `[indexnow] Submitted N URLs — HTTP 200`.
3. Monthly checks: index coverage (no soft-404 spikes), Core Web Vitals
   (Search Console + PageSpeed Insights on `/`, `/features`, a blog post),
   and the LLM file endpoints (`/llms.txt`, `/llms-full.txt`, `<page>.md`).

## 2. GEO visibility ritual (monthly, ~30 min)

Run the same prompts in ChatGPT (web search on), Perplexity, Gemini,
Copilot, and Claude, and record whether FitCheck AI is cited and how:

1. "What is the best virtual closet app?"
2. "Best AI outfit planner apps 2026"
3. "Acloset alternatives" / "apps like Acloset"
4. "How do I calculate cost per wear?"
5. "What should I wear in Mumbai in monsoon?" (city pages)
6. "FitCheck AI review" (brand query — reveals entity understanding)

Log results in a simple sheet (cited? link? position in list? tone?). Tools
that automate parts of this: Semrush AI Visibility, Profound, Seolyzer,
Komo. Free fallback: manual prompts above.

## 3. Content freshness (the 30-day recency lever)

- Refresh or re-publish something every ~30 days (blog post, guide, city
  page, or the llms.txt summary) — ChatGPT citations skew 3.2× toward
  recently updated content.
- Guides display "Last updated" dates; bump `lastUpdated` in
  `intent-pages.ts` / `city-wear-pages.ts` when content changes.

## 4. Follow-ups (external, needs humans)

| Item | Owner | Why |
|------|-------|-----|
| Upload `frontend/public/video/promo.mp4` to YouTube (channel `@FitCheckAI` already referenced in sameAs) | marketing | Video schema exists site-side; YouTube adds discovery + transcript citations |
| Wikidata item for FitCheck AI | marketing | Entity grounding for knowledge panels and AI engines |
| Product Hunt launch + AlternativeTo/G2/Capterra listings | marketing | Review/directory sites are cited disproportionately by Perplexity/ChatGPT search |
| Reddit presence (r/femalefashionadvice, r/capsulewardrobe, r/minimalism etc. — helpfully, not spammy) | marketing | Forums are citation magnets for AI answers |
| Run the data study blueprint (`docs/geo/data-study-blueprint.md`) | product + marketing | Proprietary data is the strongest GEO asset |
| GA4 property (optional — PostHog remains the product analytics source of truth) | marketing | Long-term cohort/SEO analysis |

## 5. Guardrails

- Never fabricate statistics, reviews, or ratings on public pages
  (repo rule; Google's AI features reward verifiability).
- Keep `scripts/seo-content.mjs` as the single source of truth for build-time
  routes; when adding a public page, also update `src/App.tsx`,
  `src/components/seo/seo-config.ts`, and the content module.
- Re-run `npm run build` locally before deploying to regenerate sitemap,
  prerendered meta, llms files, and the IndexNow ping.
