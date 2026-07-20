// Site-wide SEO configuration and per-page metadata

export const SEO_CONFIG = {
  siteName: 'FitCheck AI',
  siteUrl: 'https://fitcheckaiapp.com',
  defaultTitle: 'AI Virtual Closet & Outfit Planner | FitCheck AI',
  defaultDescription:
    'AI virtual closet app: photograph clothes, get weather-aware outfit ideas, virtual try-on, and AI photoshoots. Free digital wardrobe on web and Android.',
  defaultOgImage: 'https://fitcheckaiapp.com/og-default.jpg',
  locale: 'en_US',
  themeColor: '#4f46e5',
  twitterHandle: '@FitCheckAI',
  positioning:
    'FitCheck AI is an AI wardrobe and outfit app that turns photos of your clothes into a digital closet, daily outfit recommendations, virtual try-on, and AI photoshoots — on web, iOS, and Android.',
}

export const PAGE_SEO = {
  landing: {
    title: 'AI Virtual Closet & Outfit Planner | FitCheck AI',
    description:
      'AI virtual closet app: photograph clothes, get weather-aware outfit ideas, virtual try-on, and AI photoshoots. Free digital wardrobe on web and Android.',
    path: '/',
  },
  about: {
    title: 'About FitCheck AI | AI Wardrobe & Style App',
    description:
      'FitCheck AI helps you digitize your closet, plan outfits, and look better with less decision fatigue. Learn our mission and product story.',
    path: '/about',
  },
  faq: {
    title: 'FAQ | FitCheck AI Virtual Closet & Outfit Planner',
    description:
      'Answers about AI wardrobe extraction, virtual try-on, photoshoots, pricing, privacy, and how FitCheck AI organizes your clothes.',
    path: '/faq',
  },
  privacy: {
    title: 'Privacy Policy | FitCheck AI',
    description: 'How FitCheck AI collects, stores, and protects your wardrobe photos and account data.',
    path: '/privacy',
  },
  terms: {
    title: 'Terms of Service | FitCheck AI',
    description: 'Terms governing use of the FitCheck AI web app, mobile apps, and related services.',
    path: '/terms',
  },
  support: {
    title: 'Support | FitCheck AI',
    description:
      'Contact FitCheck AI support, report content or abuse, and find privacy and account help.',
    path: '/support',
  },
  blog: {
    title: 'Style & Wardrobe Blog | FitCheck AI',
    description:
      'Guides on digital closets, AI outfit planning, virtual try-on, cost-per-wear, and getting more from clothes you own.',
    path: '/blog',
  },
  features: {
    title: 'Features | AI Wardrobe, Try-On & Outfit Planner | FitCheck AI',
    description:
      'Explore AI wardrobe extraction, virtual try-on, outfit recommendations, photoshoot generator, and wardrobe analytics.',
    path: '/features',
  },
  aiWardrobeExtraction: {
    title: 'AI Wardrobe Extraction | Digitize Your Closet in Minutes',
    description:
      'Upload photos of your clothes. AI detects items, colors, and categories so you build a digital wardrobe without manual tagging.',
    path: '/features/ai-wardrobe-extraction',
  },
  virtualTryOn: {
    title: 'AI Virtual Try-On | See Outfits on You Before You Wear Them',
    description:
      'Visualize any outfit from your wardrobe on your body with AI virtual try-on. Mix pieces, save looks, shop with confidence.',
    path: '/features/virtual-try-on',
  },
  aiPhotoshoot: {
    title: 'AI Photoshoot Generator | LinkedIn, Dating & Social Photos',
    description:
      'Create professional-looking photos from your selfies for LinkedIn, dating apps, and social media — without a studio.',
    path: '/features/ai-photoshoot-generator',
  },
  outfitRecommendations: {
    title: 'AI Outfit Recommendations | What to Wear Today',
    description:
      'Get daily outfit ideas from clothes you already own. Weather-aware, occasion-ready recommendations in seconds.',
    path: '/features/outfit-recommendations',
  },
  wardrobeAnalytics: {
    title: 'Wardrobe Analytics & Cost-Per-Wear | FitCheck AI',
    description:
      'See what you wear, what you ignore, and cost-per-wear for every item. Buy smarter and wear more of your closet.',
    path: '/features/wardrobe-analytics',
  },
  login: {
    title: 'Sign In | FitCheck AI',
    description: 'Sign in to your FitCheck AI account to manage your wardrobe and outfits.',
    path: '/auth/login',
  },
  register: {
    title: 'Create Free Account | FitCheck AI',
    description:
      'Create a free FitCheck AI account. Digitize your wardrobe and get AI outfit ideas in minutes.',
    path: '/auth/register',
  },
  dashboard: {
    title: 'Dashboard | FitCheck AI',
    description: 'Your FitCheck AI dashboard — wardrobe, outfits, and recommendations.',
  },
  wardrobe: {
    title: 'My Wardrobe | FitCheck AI',
    description: 'Manage your digital wardrobe with FitCheck AI.',
  },
  outfits: {
    title: 'My Outfits | FitCheck AI',
    description: 'Create and organize outfits with FitCheck AI.',
  },
  calendar: {
    title: 'Outfit Calendar | FitCheck AI',
    description: 'Plan your outfits with the FitCheck AI calendar.',
  },
  recommendations: {
    title: 'Outfit Recommendations | FitCheck AI',
    description: 'Get personalized outfit recommendations based on weather and style.',
  },
  settings: {
    title: 'Settings | FitCheck AI',
    description: 'Manage your FitCheck AI account settings.',
  },
} as const

/** Static public routes included in sitemap + prerender meta injection */
export const STATIC_PUBLIC_ROUTES: Array<{
  path: string
  title: string
  description: string
  priority: number
  changefreq: 'weekly' | 'monthly' | 'yearly'
}> = [
  { path: '/', title: PAGE_SEO.landing.title, description: PAGE_SEO.landing.description, priority: 1.0, changefreq: 'weekly' },
  { path: '/features', title: PAGE_SEO.features.title, description: PAGE_SEO.features.description, priority: 0.9, changefreq: 'monthly' },
  { path: '/features/ai-wardrobe-extraction', title: PAGE_SEO.aiWardrobeExtraction.title, description: PAGE_SEO.aiWardrobeExtraction.description, priority: 0.9, changefreq: 'monthly' },
  { path: '/features/virtual-try-on', title: PAGE_SEO.virtualTryOn.title, description: PAGE_SEO.virtualTryOn.description, priority: 0.9, changefreq: 'monthly' },
  { path: '/features/ai-photoshoot-generator', title: PAGE_SEO.aiPhotoshoot.title, description: PAGE_SEO.aiPhotoshoot.description, priority: 0.9, changefreq: 'monthly' },
  { path: '/features/outfit-recommendations', title: PAGE_SEO.outfitRecommendations.title, description: PAGE_SEO.outfitRecommendations.description, priority: 0.9, changefreq: 'monthly' },
  { path: '/features/wardrobe-analytics', title: PAGE_SEO.wardrobeAnalytics.title, description: PAGE_SEO.wardrobeAnalytics.description, priority: 0.8, changefreq: 'monthly' },
  { path: '/about', title: PAGE_SEO.about.title, description: PAGE_SEO.about.description, priority: 0.7, changefreq: 'monthly' },
  { path: '/faq', title: PAGE_SEO.faq.title, description: PAGE_SEO.faq.description, priority: 0.8, changefreq: 'monthly' },
  { path: '/blog', title: PAGE_SEO.blog.title, description: PAGE_SEO.blog.description, priority: 0.8, changefreq: 'weekly' },
  { path: '/support', title: PAGE_SEO.support.title, description: PAGE_SEO.support.description, priority: 0.5, changefreq: 'monthly' },
  { path: '/privacy', title: PAGE_SEO.privacy.title, description: PAGE_SEO.privacy.description, priority: 0.4, changefreq: 'yearly' },
  { path: '/terms', title: PAGE_SEO.terms.title, description: PAGE_SEO.terms.description, priority: 0.4, changefreq: 'yearly' },
  // Intent pages
  { path: '/best/virtual-closet-apps', title: 'Best Virtual Closet Apps in 2026 | FitCheck AI', description: 'Compare the best virtual closet and digital wardrobe apps. See which AI outfit planners help you wear more of what you own.', priority: 0.9, changefreq: 'monthly' },
  { path: '/best/ai-outfit-planners', title: 'Best AI Outfit Planners in 2026 | FitCheck AI', description: 'A practical comparison of AI outfit planners and stylists — free options, try-on, wardrobe digitization, and daily recommendations.', priority: 0.9, changefreq: 'monthly' },
  { path: '/compare/fitcheck-vs-acloset', title: 'FitCheck AI vs Acloset | Virtual Closet Comparison', description: 'Side-by-side comparison of FitCheck AI and Acloset: wardrobe extraction, try-on, recommendations, pricing, and who each app is for.', priority: 0.85, changefreq: 'monthly' },
  { path: '/compare/fitcheck-vs-whering', title: 'FitCheck AI vs Whering | Digital Wardrobe Comparison', description: 'Compare FitCheck AI and Whering for digital wardrobes, outfit planning, analytics, and AI features.', priority: 0.85, changefreq: 'monthly' },
  { path: '/alternatives/acloset-alternatives', title: 'Best Acloset Alternatives in 2026 | FitCheck AI', description: 'Looking for Acloset alternatives? Compare virtual closet apps with AI try-on, photoshoots, and smarter outfit recommendations.', priority: 0.85, changefreq: 'monthly' },
  { path: '/for/busy-professionals', title: 'Outfit Planner for Busy Professionals | FitCheck AI', description: 'Spend less time deciding what to wear. AI outfits from your real wardrobe, planned around weather and your calendar.', priority: 0.85, changefreq: 'monthly' },
  { path: '/for/content-creators', title: 'AI Wardrobe & Try-On for Content Creators | FitCheck AI', description: 'Plan looks, visualize outfits, and generate photoshoot-style images for content calendars — from clothes you already own.', priority: 0.85, changefreq: 'monthly' },
  { path: '/for/festive-and-wedding-outfits', title: 'Festive & Wedding Guest Outfit Planner | FitCheck AI', description: 'Plan festive, wedding guest, and occasion looks from your wardrobe. Digitize ethnic and formal wear, then mix outfits with AI.', priority: 0.85, changefreq: 'monthly' },
  { path: '/guides/how-to-digitize-your-wardrobe', title: 'How to Digitize Your Wardrobe (Step-by-Step) | FitCheck AI', description: 'A practical guide to photographing and cataloging your clothes into a digital closet — faster with AI extraction.', priority: 0.85, changefreq: 'monthly' },
  { path: '/guides/what-to-wear-today', title: 'What to Wear Today: A Simple System | FitCheck AI', description: 'Stop staring at a full closet. Use weather, occasion, and your real clothes to decide what to wear in minutes.', priority: 0.85, changefreq: 'monthly' },
  { path: '/guides/cost-per-wear-calculator-explained', title: 'Cost Per Wear Explained (+ How to Track It) | FitCheck AI', description: 'What cost-per-wear means, how to calculate it, and how wardrobe analytics help you buy less and wear more.', priority: 0.8, changefreq: 'monthly' },
  { path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on', title: 'Reduce Clothing Returns with Virtual Try-On | FitCheck AI', description: 'How AI virtual try-on helps you visualize purchases with clothes you own — and cut return-prone shopping mistakes.', priority: 0.8, changefreq: 'monthly' },
]
