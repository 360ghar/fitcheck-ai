/**
 * Single source of truth for public marketing/SEO routes used by the build-time
 * scripts: generate-sitemap.mjs, prerender-meta.mjs, generate-llms.mjs.
 *
 * Keep in sync with:
 * - src/App.tsx public routes
 * - src/components/seo/seo-config.ts STATIC_PUBLIC_ROUTES
 * - src/components/seo/content/intent-pages.ts (+ city-wear-pages.ts)
 */
export const SITE = 'https://fitcheckaiapp.com'

/** @type {Array<{path:string,title:string,description:string,priority:string,changefreq:string,keyPoints?:string[]}>} */
export const SEO_ROUTES = [
  {
    path: '/',
    title: 'AI Virtual Closet & Outfit Planner | FitCheck AI',
    description:
      'AI virtual closet app: photograph clothes, get weather-aware outfit ideas, virtual try-on, and AI photoshoots. Free digital wardrobe on web and Android.',
    priority: '1.0',
    changefreq: 'weekly',
    keyPoints: [
      'Turns photos of your clothes into a digital wardrobe with AI item extraction.',
      'Provides weather-aware outfit recommendations, virtual try-on, and AI photoshoots from clothes you already own.',
      'Free tier: 25 item extractions/month, 50 outfit visualizations/month, 10 photoshoot images/day. Web + Android live; iOS waitlist.',
    ],
  },
  { path: '/features', title: 'Features | AI Wardrobe, Try-On & Outfit Planner | FitCheck AI', description: 'Explore AI wardrobe extraction, virtual try-on, outfit recommendations, photoshoot generator, and wardrobe analytics.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Five capabilities: AI wardrobe extraction, virtual try-on, outfit recommendations, AI photoshoot generator, wardrobe analytics.'] },
  { path: '/features/ai-wardrobe-extraction', title: 'AI Wardrobe Extraction | Digitize Your Closet in Minutes', description: 'Upload photos of your clothes. AI detects items, colors, and categories so you build a digital wardrobe without manual tagging.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Photograph single items, flat lays, or multi-item photos.', 'AI extracts categories, colors, and style tags for review before saving.', 'Free plan: 25 extractions/month; Pro raises the limit to 200/month.'] },
  { path: '/features/virtual-try-on', title: 'AI Virtual Try-On | See Outfits on You Before You Wear Them', description: 'Visualize any outfit from your wardrobe on your body with AI virtual try-on. Mix pieces, save looks, shop with confidence.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Visualizes outfits from clothes you actually own using an avatar or photo.', 'Free plan: 50 outfit visualizations/month; Plus 350; Pro 1,000.', 'Output is a visual reference, not a fit or sizing guarantee.'] },
  { path: '/features/ai-photoshoot-generator', title: 'AI Photoshoot Generator | LinkedIn, Dating & Social Photos', description: 'Create professional-looking photos from your selfies for LinkedIn, dating apps, and social media — without a studio.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Generates photoshoot-style images from a phone selfie using your own clothes.', 'Free plan: 10 images/day; Plus 30/day; Pro 50/day.', 'Use cases: LinkedIn, dating apps, social media, festive occasions.'] },
  { path: '/features/outfit-recommendations', title: 'AI Outfit Recommendations | What to Wear Today', description: 'Get daily outfit ideas from clothes you already own with weather and occasion context.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Recommendations are grounded in your real wardrobe, weather, and calendar.', 'Explains why each look was suggested and lets you save or plan it.', 'Free plan includes 50 outfit visualizations/month for AI-generated looks.'] },
  { path: '/features/wardrobe-analytics', title: 'Wardrobe Analytics & Cost-Per-Wear | FitCheck AI', description: 'See what you wear, what you ignore, and cost-per-wear for every item. Buy smarter and wear more of your closet.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Tracks wear patterns, planning history, and item context.', 'Computes cost-per-wear to guide buying decisions.', 'Insights come from data you record; no fabricated savings claims.'] },
  { path: '/about', title: 'About FitCheck AI | AI Wardrobe & Style App', description: 'FitCheck AI helps you digitize your closet, plan outfits, and look better with less decision fatigue. Learn our mission and product story.', priority: '0.7', changefreq: 'monthly' },
  { path: '/faq', title: 'FAQ | FitCheck AI Virtual Closet & Outfit Planner', description: 'Answers about AI wardrobe extraction, virtual try-on, photoshoots, pricing, privacy, and how FitCheck AI organizes your clothes.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Free plan: 25 extractions/month, 50 visualizations/month, 10 photoshoot images/day.', 'Plus ($10/month or $100/year): 100 extractions, 350 visualizations, 30 photoshoot images/day.', 'Pro ($20/month or $200/year): 200 extractions, 1,000 visualizations, 50 photoshoot images/day.', 'Wardrobe data is private by default and not sold to third parties.'] },
  { path: '/blog', title: 'Style & Wardrobe Blog | FitCheck AI', description: 'Guides on digital closets, AI outfit planning, virtual try-on, cost-per-wear, and getting more from clothes you own.', priority: '0.8', changefreq: 'weekly' },
  { path: '/support', title: 'Support | FitCheck AI', description: 'Contact FitCheck AI support, report content or abuse, and find privacy and account help.', priority: '0.5', changefreq: 'monthly' },
  { path: '/privacy', title: 'Privacy Policy | FitCheck AI', description: 'How FitCheck AI collects, stores, and protects your wardrobe photos and account data.', priority: '0.4', changefreq: 'yearly' },
  { path: '/terms', title: 'Terms of Service | FitCheck AI', description: 'Terms governing use of the FitCheck AI web app, mobile apps, and related services.', priority: '0.4', changefreq: 'yearly' },
  { path: '/best/virtual-closet-apps', title: 'Best Virtual Closet Apps in 2026 | FitCheck AI', description: 'Compare the best virtual closet and digital wardrobe apps. See which AI outfit planners help you wear more of what you own.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Evaluate apps on digitization speed, outfit planning from real clothes, wear tracking, and privacy.', 'FitCheck AI is positioned for AI digitization + try-on + recommendations in one product.', 'Free tiers let you validate value before upgrading.'] },
  { path: '/best/ai-outfit-planners', title: 'Best AI Outfit Planners in 2026 | FitCheck AI', description: 'A practical comparison of AI outfit planners and stylists — free options, try-on, wardrobe digitization, and daily recommendations.', priority: '0.9', changefreq: 'monthly', keyPoints: ['Good AI planners use your actual wardrobe, not only trend templates.', 'Look for weather/occasion context, try-on visualization, and calendar planning.', 'Text-only stylists often invent pieces you do not own — prefer inventory-grounded apps.'] },
  { path: '/compare/fitcheck-vs-stylebook', title: 'FitCheck AI vs Stylebook | Digital Closet Comparison', description: 'Compare FitCheck AI and Stylebook for digital wardrobes: manual cataloging vs AI extraction, try-on, outfit planning, and pricing.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Stylebook is a manual, offline-first closet organizer with outfit logging.', 'FitCheck AI auto-catalogs clothes from photos with AI, adds virtual try-on, recommendations, and photoshoots.', 'Manual apps give fine-grained control but high entry effort; AI-first apps trade control for speed.'] },
  { path: '/compare/fitcheck-vs-indyx', title: 'FitCheck AI vs Indyx | Wardrobe App Comparison', description: 'Compare FitCheck AI and Indyx: AI wardrobe cataloging, stylist services, try-on, analytics, and who each app suits.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Indyx combines cataloging with optional stylist services and community.', 'FitCheck AI is product-led: AI extraction, generative try-on, photoshoots, and analytics in one plan.', 'Choose Indyx for human styling input; FitCheck for automated, self-serve AI wardrobe workflows.'] },
  { path: '/compare/fitcheck-vs-cladwell', title: 'FitCheck AI vs Cladwell | AI Wardrobe & Outfit Comparison', description: 'Compare FitCheck AI and Cladwell: daily outfit math, wardrobe utilization, try-on, and AI generation.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Cladwell calculates daily outfit combinations from your items.', 'FitCheck AI adds AI extraction, virtual try-on, AI photoshoots, and weather/calendar-aware planning.', 'Cladwell suits minimalists; FitCheck suits mixed wardrobes including festive and formal wear.'] },
  { path: '/compare/fitcheck-vs-open-wardrobe', title: 'FitCheck AI vs Open Wardrobe | Virtual Closet Comparison', description: 'Compare FitCheck AI and Open Wardrobe: open-source cataloging vs AI extraction, try-on, and outfit recommendations.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Open Wardrobe is a free open-source closet organizer.', 'FitCheck AI is a hosted product with AI photo extraction, generative try-on, and photoshoots.', 'Self-hosters may prefer Open Wardrobe; casual users get faster value from FitCheck AI.'] },

  { path: '/alternatives/acloset-alternatives', title: 'Best Acloset Alternatives in 2026 | FitCheck AI', description: 'Looking for Acloset alternatives? Compare virtual closet apps with AI try-on, photoshoots, and smarter outfit recommendations.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Alternatives to Acloset include FitCheck AI, Whering, Stylebook, Indyx, Cladwell, and Open Wardrobe.', 'FitCheck AI differentiates with AI photo-to-wardrobe extraction and generative visualization.', 'Free tiers on most apps let you test digitization speed before committing.'] },
  { path: '/for/busy-professionals', title: 'Outfit Planner for Busy Professionals | FitCheck AI', description: 'Spend less time deciding what to wear. AI outfits from your real wardrobe, planned around weather and your calendar.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Designed to cut morning decision time with weather- and calendar-aware recommendations.', 'Digitize once with AI extraction; reuse outfits and plan the week ahead.', 'Works with office, casual, and festive pieces in one closet.'] },
  { path: '/for/content-creators', title: 'AI Wardrobe & Try-On for Content Creators | FitCheck AI', description: 'Plan looks, visualize outfits, and generate photoshoot-style images for content calendars — from clothes you already own.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Plan looks in advance and generate photoshoot-style images for content calendars.', 'Virtual try-on lets you preview a look before shooting.', 'Reuse the same wardrobe across outfits for consistent, budget-friendly content.'] },
  { path: '/for/festive-and-wedding-outfits', title: 'Festive & Wedding Guest Outfit Planner | FitCheck AI', description: 'Plan festive, wedding guest, and occasion looks from your wardrobe. Digitize ethnic and formal wear, then mix outfits with AI.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Digitize ethnic, formal, and occasion wear that capsule apps ignore.', 'Mix and match festive pieces into new combinations with AI.', 'Generate photoshoot-style images for festive occasions from your real clothes.'] },

  { path: '/guides/how-to-digitize-your-wardrobe', title: 'How to Digitize Your Wardrobe (Step-by-Step) | FitCheck AI', description: 'A practical guide to photographing and cataloging your clothes into a digital closet — faster with AI extraction.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Start with your most-worn 20–30 items, not the whole closet.', 'Use flat lays and good lighting; AI extraction handles multi-item photos.', 'Catalog in sessions and update as seasons change to keep the closet useful.'] },
  { path: '/guides/what-to-wear-today', title: 'What to Wear Today: A Simple System | FitCheck AI', description: 'Stop staring at a full closet. Use weather, occasion, and your real clothes to decide what to wear.', priority: '0.85', changefreq: 'monthly', keyPoints: ['Decide in three inputs: weather, occasion, and a shortlist of go-to items.', 'Keep 80% of decisions on repeat outfits; reserve novelty for the rest.', 'Weather-aware recommendations reduce morning decision time.'] },
  { path: '/guides/cost-per-wear-calculator-explained', title: 'Cost Per Wear Explained (+ How to Track It) | FitCheck AI', description: 'What cost-per-wear means, how to calculate it, and how wardrobe analytics help you buy less and wear more.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Cost per wear = item price ÷ number of wears.', 'A “good” CPW is relative to your income and category — compare within your own wardrobe.', 'Track high-ticket items first; wear more before buying more.', 'Try the free calculator: /tools/cost-per-wear-calculator'] },
  { path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on', title: 'Reduce Clothing Returns with Virtual Try-On | FitCheck AI', description: 'How AI virtual try-on helps you visualize purchases with clothes you own — and cut return-prone shopping mistakes.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Online apparel returns are far higher than in-store returns (industry estimates put online apparel returns around 25–40%).', 'Virtual try-on helps with color harmony, silhouette balance, and outfit context before purchase.', 'It supports, not replaces, size charts and return policies.'] },
  { path: '/guides/what-is-a-capsule-wardrobe', title: 'What Is a Capsule Wardrobe? Definition, Checklist & Apps | FitCheck AI', description: 'A capsule wardrobe definition, how to build one from clothes you own, checklists, and which apps help.', priority: '0.8', changefreq: 'monthly', keyPoints: ['A capsule wardrobe is a small set of interchangeable pieces that mix into many outfits.', 'Typical capsule sizes: 20–40 items, often 30–33 pieces for a season.', 'Build it from your existing wardrobe first; buy only to fill genuine gaps.'] },
  { path: '/guides/what-is-wardrobe-utilization', title: 'Wardrobe Utilization: What It Is and How to Measure It | FitCheck AI', description: 'Wardrobe utilization explained — the share of your closet you actually wear — plus how to measure and improve it.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Utilization = items worn in a period ÷ total items owned.', 'Most closets concentrate wear on a small share of items; analytics reveal the rest.', 'Improve utilization by planning outfits and re-wearing quality pieces before buying.'] },
  { path: '/tools/cost-per-wear-calculator', title: 'Cost Per Wear Calculator — Free & Instant | FitCheck AI', description: 'Calculate the true cost per wear of any clothing item in seconds. Free tool with wardrobe analytics tips.', priority: '0.8', changefreq: 'monthly', keyPoints: ['Free interactive tool: price ÷ expected wears = cost per wear.', 'Compare items to see which purchases earn their cost.', 'Pairs with FitCheck AI wardrobe analytics for automatic tracking.'] },
  ...CITY_ROUTES(),
]

export function CITY_ROUTES() {
  const cities = [
    ['mumbai', 'Mumbai'],
    ['delhi', 'Delhi'],
    ['bengaluru', 'Bengaluru'],
    ['chennai', 'Chennai'],
    ['london', 'London'],
    ['new-york', 'New York'],
    ['dubai', 'Dubai'],
    ['singapore', 'Singapore'],
    ['toronto', 'Toronto'],
    ['sydney', 'Sydney'],
  ]
  return cities.map(([slug, city]) => ({
    path: `/wear/what-to-wear-in-${slug}`,
    title: `What to Wear in ${city}: Season-by-Season Guide | FitCheck AI`,
    description: `What to wear in ${city} all year: season-by-season outfit formulas, weather notes, and packing tips — built on clothes you already own.`,
    priority: '0.7',
    changefreq: 'monthly',
    keyPoints: [
      `Season-by-season outfit guidance for ${city}.`,
      'Formulas built on clothing categories, not specific brand items.',
      'Pairs with FitCheck AI weather-aware recommendations from your real wardrobe.',
    ],
  }))
}

export function urlForPath(path) {
  return path === '/' ? `${SITE}/` : `${SITE}${path}`
}

