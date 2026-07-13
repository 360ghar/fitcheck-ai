import type { SeoPageContent } from '../SeoPageLayout'

export const INTENT_PAGES: Record<string, SeoPageContent> = {
  'best-virtual-closet-apps': {
    path: '/best/virtual-closet-apps',
    title: 'Best Virtual Closet Apps in 2026 | FitCheck AI',
    description:
      'Compare the best virtual closet and digital wardrobe apps. See which AI outfit planners help you wear more of what you own.',
    h1: 'Best virtual closet apps in 2026',
    lede:
      'A virtual closet app turns photos of your clothes into a searchable digital wardrobe so you can plan outfits, track what you wear, and stop buying duplicates. The best options combine easy cataloging, useful outfit ideas, and privacy you can trust — FitCheck AI is built for that full loop.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Virtual closet apps', path: '/best/virtual-closet-apps' },
    ],
    keywords:
      'best virtual closet apps, digital wardrobe app, AI closet organizer, virtual wardrobe',
    sections: [
      {
        heading: 'What makes a virtual closet app worth using?',
        body: [
          'Most people abandon closet apps after a weekend of manual tagging. The apps that stick reduce upload friction, make outfit decisions faster, and show clear value within the first session.',
          'Prioritize photo-based item capture, smart categories, outfit recommendations from your real clothes, and optional try-on — not a static inventory spreadsheet.',
        ],
        bullets: [
          'Fast digitization (AI extraction beats hand-entry)',
          'Outfit planning from items you already own',
          'Wear tracking / cost-per-wear for smarter buys',
          'Mobile + web access and clear privacy defaults',
        ],
      },
      {
        heading: 'How leading virtual closet apps compare',
        body: [
          'Category apps typically fall into three buckets: manual digital closets, social styling communities, and AI-first wardrobe systems. Manual apps are flexible but slow. Social apps inspire but may not map to your actual hangers. AI-first apps aim to close that gap.',
          'FitCheck AI focuses on AI wardrobe extraction from photos, daily outfit recommendations, virtual try-on, AI photoshoots, and wardrobe analytics — so cataloging is the start of a daily habit, not the whole product.',
        ],
        bullets: [
          'FitCheck AI — best for AI digitization + try-on + recommendations in one product',
          'Acloset — strong digital wardrobe UX; compare feature depth for try-on and photoshoots',
          'Whering — solid organizer positioning; compare AI generation and analytics depth',
          'Brand AR try-on tools — great for shopping one retailer, weak as your personal closet',
        ],
      },
      {
        heading: 'Who should choose FitCheck AI',
        body: 'Choose FitCheck AI if you want to photograph clothes once, then get ongoing outfit help without building a fashion spreadsheet. It fits busy professionals, creators planning looks, and anyone trying to wear more of what they own — including festive and formal pieces that rarely make it into “capsule” apps.',
      },
      {
        heading: 'How to evaluate any virtual closet in 15 minutes',
        body: 'Upload 10–20 real items. Time how long cataloging takes. Generate one outfit for “work” and one for “weekend.” Check whether recommendations use only your items. Review privacy settings and export options before committing a full wardrobe.',
      },
    ],
    faqs: [
      {
        question: 'What is the best free virtual closet app?',
        answer:
          'Look for a free plan that lets you digitize real items and generate a few outfits monthly. FitCheck AI includes a free tier with wardrobe and AI limits so you can validate value before upgrading.',
      },
      {
        question: 'Do virtual closet apps work for ethnic and formal wear?',
        answer:
          'They do if cataloging supports varied silhouettes and occasions. FitCheck AI is designed for mixed wardrobes — office, casual, festive, and wedding-guest pieces — not only Western basics.',
      },
      {
        question: 'Is a virtual closet better than a capsule wardrobe spreadsheet?',
        answer:
          'A spreadsheet tracks theory; a virtual closet reflects what you own with photos and wear history. Photos plus AI recommendations usually beat static lists for daily decisions.',
      },
    ],
    relatedLinks: [
      { label: 'Best AI outfit planners', href: '/best/ai-outfit-planners' },
      { label: 'FitCheck vs Acloset', href: '/compare/fitcheck-vs-acloset' },
      { label: 'AI wardrobe extraction', href: '/features/ai-wardrobe-extraction' },
      { label: 'How to digitize your wardrobe', href: '/guides/how-to-digitize-your-wardrobe' },
    ],
  },

  'best-ai-outfit-planners': {
    path: '/best/ai-outfit-planners',
    title: 'Best AI Outfit Planners in 2026 | FitCheck AI',
    description:
      'A practical comparison of AI outfit planners and stylists — free options, try-on, wardrobe digitization, and daily recommendations.',
    h1: 'Best AI outfit planners in 2026',
    lede:
      'An AI outfit planner suggests complete looks from context — weather, occasion, and your actual clothes — instead of generic Pinterest mood boards. The strongest products start from a real digital wardrobe, not only a style quiz.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'AI outfit planners', path: '/best/ai-outfit-planners' },
    ],
    keywords: 'AI outfit planner, AI stylist app, what to wear app, outfit generator from wardrobe',
    sections: [
      {
        heading: 'What an AI outfit planner should do',
        body: 'Good planners propose wearable combinations from inventory you own, respect season and dress codes, and learn preferences over time. Great planners also let you visualize the look (try-on) and schedule it on a calendar so mornings stay calm.',
        bullets: [
          'Uses your wardrobe photos, not only trend templates',
          'Explains or filters by occasion and weather when available',
          'Lets you save, tweak, and rewear winning outfits',
          'Reduces decision time without forcing a single aesthetic',
        ],
      },
      {
        heading: 'FitCheck AI’s approach',
        body: [
          'FitCheck AI builds recommendations after you digitize items with AI extraction. Suggestions can factor style history, weather, and calendar context so “what to wear today” maps to real hangers.',
          'You can then virtual try-on top options or generate photoshoot-style images when you need a polished reference for work or content.',
        ],
      },
      {
        heading: 'When a pure chat stylist is not enough',
        body: 'Text-only stylists can be fun but often invent pieces you do not own. Inventory-grounded planners prevent “great outfit, zero of it in your closet.” If your pain is morning decisions, start with wardrobe truth, then AI.',
      },
    ],
    faqs: [
      {
        question: 'Is there a free AI outfit planner?',
        answer:
          'Yes — several apps offer free tiers. FitCheck AI’s free plan includes limited AI outfit generations so you can test recommendations from your real wardrobe.',
      },
      {
        question: 'Can AI outfit planners use weather?',
        answer:
          'FitCheck AI can incorporate weather context into recommendations so suggestions stay practical for temperature and conditions, not only aesthetics.',
      },
    ],
    relatedLinks: [
      { label: 'Outfit recommendations feature', href: '/features/outfit-recommendations' },
      { label: 'What to wear today guide', href: '/guides/what-to-wear-today' },
      { label: 'For busy professionals', href: '/for/busy-professionals' },
    ],
  },

  'fitcheck-vs-acloset': {
    path: '/compare/fitcheck-vs-acloset',
    title: 'FitCheck AI vs Acloset | Virtual Closet Comparison',
    description:
      'Side-by-side comparison of FitCheck AI and Acloset: wardrobe extraction, try-on, recommendations, pricing, and who each app is for.',
    h1: 'FitCheck AI vs Acloset',
    lede:
      'Both FitCheck AI and Acloset help you run a digital wardrobe. The practical difference is how much AI you want after the closet is digitized: FitCheck AI emphasizes photo extraction, generative try-on, AI photoshoots, and analytics-driven outfit planning in one product.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'FitCheck vs Acloset', path: '/compare/fitcheck-vs-acloset' },
    ],
    keywords: 'FitCheck vs Acloset, Acloset alternative, Acloset comparison, virtual closet comparison',
    sections: [
      {
        heading: 'Quick comparison',
        body: 'Use this as a decision guide, not a scorecard. Feature sets change; always verify in-app. FitCheck AI is strongest when you want AI to catalog, recommend, visualize, and photograph looks from your own clothes. Acloset is often chosen for established digital wardrobe workflows and community/styling patterns depending on region and release.',
        bullets: [
          'Wardrobe capture: FitCheck AI prioritizes multi-item AI extraction from photos',
          'Try-on: FitCheck AI includes generative virtual try-on flows',
          'Photos: FitCheck AI AI photoshoot generator for profile/content use cases',
          'Analytics: FitCheck AI cost-per-wear and utilization insights',
          'Pricing: both typically freemium — compare current free limits before migrating a full closet',
        ],
      },
      {
        heading: 'Who should pick FitCheck AI',
        body: 'Pick FitCheck AI if your bottleneck is digitizing a messy real closet quickly and then getting daily, visual outfit help — including try-on and photoshoot generation. It is a fit for professionals, creators, and mixed wardrobes (work + festive + casual).',
      },
      {
        heading: 'Migration tip',
        body: 'Whichever app you choose, start with 20 core items (tops, bottoms, shoes) before uploading everything. Confirm export/privacy options. On FitCheck AI you can begin free and expand once recommendations feel accurate.',
      },
    ],
    faqs: [
      {
        question: 'Is FitCheck AI a good Acloset alternative?',
        answer:
          'Yes if you want stronger AI generation (try-on, photoshoots) tied to a photo-based wardrobe. See also our Acloset alternatives page for a wider shortlist.',
      },
      {
        question: 'Can I use both apps?',
        answer:
          'You can, but dual cataloging is costly. Most people should pick one system of record for the wardrobe inventory.',
      },
    ],
    relatedLinks: [
      { label: 'Acloset alternatives', href: '/alternatives/acloset-alternatives' },
      { label: 'FitCheck vs Whering', href: '/compare/fitcheck-vs-whering' },
      { label: 'Virtual try-on', href: '/features/virtual-try-on' },
    ],
  },

  'fitcheck-vs-whering': {
    path: '/compare/fitcheck-vs-whering',
    title: 'FitCheck AI vs Whering | Digital Wardrobe Comparison',
    description:
      'Compare FitCheck AI and Whering for digital wardrobes, outfit planning, analytics, and AI features.',
    h1: 'FitCheck AI vs Whering',
    lede:
      'Whering and FitCheck AI both target digital wardrobe organization. FitCheck AI leans into AI extraction, generative try-on, photoshoot creation, and recommendation loops designed to shrink morning decisions — not only to inventory clothes.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'FitCheck vs Whering', path: '/compare/fitcheck-vs-whering' },
    ],
    keywords: 'FitCheck vs Whering, Whering alternative, digital wardrobe comparison',
    sections: [
      {
        heading: 'Where the products diverge',
        body: [
          'Organization-first apps excel at structure and sustainability narratives. AI-first apps excel at speed-to-decision after structure exists.',
          'FitCheck AI is built so photographing clothes feeds recommendations, try-on, and photos — a closed loop from closet to look.',
        ],
        bullets: [
          'Digitization speed with AI multi-item detection',
          'Virtual try-on for outfit confidence',
          'AI photoshoot generator for polished images',
          'Weather/calendar-aware outfit suggestions',
          'Cost-per-wear style analytics',
        ],
      },
      {
        heading: 'Choosing for sustainability goals',
        body: 'If your goal is wearing more of what you own, measure success by rewear rate and unused-item visibility — not by how many mood boards you save. FitCheck AI’s analytics help surface neglected pieces and cost-per-wear so purchases slow down with data, not guilt alone.',
      },
    ],
    faqs: [
      {
        question: 'Which is better for beginners?',
        answer:
          'Beginners should prioritize the app that gets 15 items cataloged fastest. FitCheck AI’s photo extraction is designed for that first win.',
      },
    ],
    relatedLinks: [
      { label: 'Wardrobe analytics', href: '/features/wardrobe-analytics' },
      { label: 'Best virtual closet apps', href: '/best/virtual-closet-apps' },
      { label: 'Cost per wear guide', href: '/guides/cost-per-wear-calculator-explained' },
    ],
  },

  'acloset-alternatives': {
    path: '/alternatives/acloset-alternatives',
    title: 'Best Acloset Alternatives in 2026 | FitCheck AI',
    description:
      'Looking for Acloset alternatives? Compare virtual closet apps with AI try-on, photoshoots, and smarter outfit recommendations.',
    h1: 'Best Acloset alternatives',
    lede:
      'People search for Acloset alternatives when they want different AI depth, pricing, platforms, or visualization features. FitCheck AI is a strong alternative if you want photo-based wardrobe AI plus try-on and photoshoot tools in one place.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Acloset alternatives', path: '/alternatives/acloset-alternatives' },
    ],
    keywords: 'Acloset alternatives, apps like Acloset, Acloset free alternative',
    sections: [
      {
        heading: 'What to look for in an Acloset alternative',
        body: 'List your must-haves before switching: AI auto-tagging, outfit calendar, try-on, social features, offline use, or analytics. Switching costs are mostly re-photographing — so optimize for the app you will still open on Tuesday morning.',
        bullets: [
          'True inventory of your clothes (photos + categories)',
          'Outfit generation that respects that inventory',
          'Privacy defaults you understand',
          'Free tier enough to validate the habit',
        ],
      },
      {
        heading: 'Why FitCheck AI is on the shortlist',
        body: 'FitCheck AI combines AI wardrobe extraction, recommendations, virtual try-on, AI photoshoot generation, and cost-per-wear analytics. That stack is aimed at decision-making, not only catalog beauty.',
      },
      {
        heading: 'How to switch without losing momentum',
        body: 'Export or screenshot key outfits if needed, then rebuild with your top 30 items first. Validate one week of daily recommendations before uploading the entire archive of shoes you never wear.',
      },
    ],
    faqs: [
      {
        question: 'Is there a free Acloset alternative?',
        answer:
          'FitCheck AI offers a free plan with limits on items and AI generations. Use it to test digitization and outfit quality before paying for Pro.',
      },
    ],
    relatedLinks: [
      { label: 'FitCheck vs Acloset', href: '/compare/fitcheck-vs-acloset' },
      { label: 'Features overview', href: '/features' },
      { label: 'Register free', href: '/auth/register' },
    ],
  },

  'busy-professionals': {
    path: '/for/busy-professionals',
    title: 'Outfit Planner for Busy Professionals | FitCheck AI',
    description:
      'Spend less time deciding what to wear. AI outfits from your real wardrobe, planned around weather and your calendar.',
    h1: 'Outfit planning for busy professionals',
    lede:
      'If mornings disappear into “nothing to wear,” you do not need more clothes — you need a faster system. FitCheck AI digitizes your work wardrobe, suggests outfits for the day, and helps you plan the week so meetings are one less decision.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Busy professionals', path: '/for/busy-professionals' },
    ],
    keywords: 'outfit planner for work, professional wardrobe app, what to wear to office',
    sections: [
      {
        heading: 'A 10-minute setup that pays for itself',
        body: 'Photograph your core office rotation: shirts, trousers, shoes, layers. Let AI catalog them. Generate outfits for “office,” “client meeting,” and “smart casual.” Save winners. That library becomes your weekday autopilot.',
        bullets: [
          'Weather-aware suggestions when you need them',
          'Calendar-minded planning for big days',
          'Try-on before you commit to a look',
          'Travel packing from the same wardrobe',
        ],
      },
      {
        heading: 'Look polished without a stylist retainer',
        body: 'Professionals often under-wear half their wardrobe. Analytics surface neglected pieces; recommendations remix them with reliable anchors (blazers, clean sneakers, formal shoes). Optional AI photoshoots help when you need a fresh LinkedIn image without booking a studio.',
      },
    ],
    faqs: [
      {
        question: 'Can FitCheck AI handle formal office dress codes?',
        answer:
          'Yes — tag items by occasion and preferences. Recommendations can lean formal when you select work or meeting contexts.',
      },
    ],
    relatedLinks: [
      { label: 'Outfit recommendations', href: '/features/outfit-recommendations' },
      { label: 'AI photoshoot', href: '/features/ai-photoshoot-generator' },
      { label: 'What to wear today', href: '/guides/what-to-wear-today' },
    ],
  },

  'content-creators': {
    path: '/for/content-creators',
    title: 'AI Wardrobe & Try-On for Content Creators | FitCheck AI',
    description:
      'Plan looks, visualize outfits, and generate photoshoot-style images for content calendars — from clothes you already own.',
    h1: 'AI wardrobe tools for content creators',
    lede:
      'Creators burn time repeating “what should I wear on camera?” FitCheck AI keeps a visual inventory of your pieces, lets you try combinations before shooting, and can generate reference photos so planning is faster than a closet floor pile.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Content creators', path: '/for/content-creators' },
    ],
    keywords: 'content creator wardrobe app, outfit planning for influencers, AI try-on for creators',
    sections: [
      {
        heading: 'Plan a content week in one sitting',
        body: 'Digitize hero pieces and rotating basics. Build outfits per shoot theme. Virtual try-on reduces mid-shoot outfit changes. Share outfit links when collaborators need alignment.',
      },
      {
        heading: 'Photoshoot generator as a creative utility',
        body: 'When you need concept frames or profile refreshes, AI photoshoot flows can produce polished images from selfies — useful for thumbnails, bios, or testing a vibe before a real set.',
      },
    ],
    faqs: [
      {
        question: 'Does try-on replace a real photoshoot?',
        answer:
          'No — it accelerates planning and reduces wrong-outfit days. Use real shoots when brand quality demands it; use FitCheck AI to arrive prepared.',
      },
    ],
    relatedLinks: [
      { label: 'Virtual try-on', href: '/features/virtual-try-on' },
      { label: 'AI photoshoot', href: '/features/ai-photoshoot-generator' },
      { label: 'Share outfits', href: '/features' },
    ],
  },

  'festive-and-wedding-outfits': {
    path: '/for/festive-and-wedding-outfits',
    title: 'Festive & Wedding Guest Outfit Planner | FitCheck AI',
    description:
      'Plan festive, wedding guest, and occasion looks from your wardrobe. Digitize ethnic and formal wear, then mix outfits with AI.',
    h1: 'Festive and wedding guest outfit planning',
    lede:
      'Occasion dressing is high stakes and high clutter: multiple events, dress codes, jewelry, and footwear. FitCheck AI helps you digitize ethnic and formal pieces, then plan guest and festive outfits from what you already own — before you buy a last-minute duplicate.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Festive & wedding', path: '/for/festive-and-wedding-outfits' },
    ],
    keywords:
      'wedding guest outfit planner, festive outfit ideas from wardrobe, ethnic wear digital closet',
    sections: [
      {
        heading: 'Why occasion wardrobes need a digital system',
        body: 'Festive pieces are worn rarely, stored carefully, and forgotten until the next invite. A photo inventory surfaces color palettes, reuse opportunities, and gaps (only one pair of formal shoes) early enough to avoid panic shopping.',
      },
      {
        heading: 'A simple event workflow',
        body: '1) Photograph outfits and separates. 2) Tag occasions (wedding guest, festive, formal dinner). 3) Generate options and try-on favorites. 4) Save a shortlist per event day. 5) Pack or prep the night before.',
        bullets: [
          'Reuse statement pieces across multiple functions',
          'Balance comfort for long ceremonies with dress-code polish',
          'Coordinate with family color themes using your actual inventory',
        ],
      },
    ],
    faqs: [
      {
        question: 'Does FitCheck AI work for Indian festive wear?',
        answer:
          'Yes — digitize sarees, suits, kurtas, sherwanis, and accessories like any other category. Use occasion tags so recommendations can prioritize festive and wedding-guest looks.',
      },
    ],
    relatedLinks: [
      { label: 'AI wardrobe extraction', href: '/features/ai-wardrobe-extraction' },
      { label: 'Virtual try-on', href: '/features/virtual-try-on' },
      { label: 'Outfit recommendations', href: '/features/outfit-recommendations' },
    ],
  },

  'how-to-digitize-your-wardrobe': {
    path: '/guides/how-to-digitize-your-wardrobe',
    title: 'How to Digitize Your Wardrobe (Step-by-Step) | FitCheck AI',
    description:
      'A practical guide to photographing and cataloging your clothes into a digital closet — faster with AI extraction.',
    h1: 'How to digitize your wardrobe',
    lede:
      'Digitizing your wardrobe means photographing each wearable item and storing it in a searchable digital closet. Done well, it takes one focused session for core pieces — and AI extraction can cut hours of manual tagging. Here is a practical method that sticks.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Digitize your wardrobe', path: '/guides/how-to-digitize-your-wardrobe' },
    ],
    keywords: 'digitize wardrobe, digital closet how to, catalog clothes app, photo wardrobe inventory',
    sections: [
      {
        heading: 'Step 1: Define the minimum viable closet',
        body: 'Do not start with seasonal storage boxes. Start with what you wear in the next 30 days: daily tops, bottoms, shoes, outer layers, and 5–10 occasion pieces. Momentum beats perfection.',
      },
      {
        heading: 'Step 2: Photograph for AI success',
        body: 'Use bright, even light. Lay items flat or hang them. Avoid heavy shadows and cluttered backgrounds. Group small accessories only if your app supports multi-item detection cleanly.',
        bullets: [
          'One clear subject beats artistic mess',
          'Include shoes and bags — they complete outfits',
          'Retake blurry shots; AI cannot invent fabric detail from noise',
        ],
      },
      {
        heading: 'Step 3: Let AI catalog, then correct',
        body: 'In FitCheck AI, upload photos and let extraction propose category, colors, and attributes. Spot-check brands and occasions. Corrections teach a cleaner wardrobe graph for recommendations later.',
      },
      {
        heading: 'Step 4: Generate your first outfits the same day',
        body: 'If you stop at inventory, the project dies. Generate three outfits (work, casual, occasion). Save them. That is the habit loop that justifies finishing the rest of the closet next weekend.',
      },
    ],
    faqs: [
      {
        question: 'How long does digitizing a wardrobe take?',
        answer:
          'A focused core wardrobe (30–50 items) can take under an hour with AI extraction and good lighting. Full archives take longer — batch by category.',
      },
      {
        question: 'Should I include clothes that do not fit?',
        answer:
          'Only if you will wear them within a season. Otherwise archive offline; a digital closet should reflect wearable reality.',
      },
    ],
    relatedLinks: [
      { label: 'AI wardrobe extraction', href: '/features/ai-wardrobe-extraction' },
      { label: 'Best virtual closet apps', href: '/best/virtual-closet-apps' },
      { label: 'Start free', href: '/auth/register' },
    ],
  },

  'what-to-wear-today': {
    path: '/guides/what-to-wear-today',
    title: 'What to Wear Today: A Simple System | FitCheck AI',
    description:
      'Stop staring at a full closet. Use weather, occasion, and your real clothes to decide what to wear in minutes.',
    h1: 'What to wear today: a simple system',
    lede:
      '“What to wear today” is not a fashion problem — it is a decision problem under time pressure. The fix is a short checklist (context → constraints → 2 options → commit) backed by a digital wardrobe that already knows what you own.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'What to wear today', path: '/guides/what-to-wear-today' },
    ],
    keywords: 'what to wear today, daily outfit ideas, outfit decision system, AI outfit suggestion',
    sections: [
      {
        heading: 'The 4-question checklist',
        body: '1) Where am I going (work, casual, event)? 2) What is the weather? 3) What must be clean and comfortable for the day’s length? 4) What did I wear yesterday (avoid accidental uniforms)? Answer those before opening shopping apps.',
      },
      {
        heading: 'Use AI when the checklist stalls',
        body: 'When you still freeze, generate two complete outfits from your digitized wardrobe and pick one. FitCheck AI is built for that moment: recommendations grounded in inventory, with optional try-on if you need visual confidence.',
      },
      {
        heading: 'Build “default formulas” for weekdays',
        body: 'Pros do not invent a new identity daily. They rotate formulas: blazer + tee + trousers; kurta + jeans + sneakers; dress + layer + flats. Save formulas as outfits so AI remixes within a structure you already like.',
      },
    ],
    faqs: [
      {
        question: 'How do I stop buying duplicates when I feel I have nothing to wear?',
        answer:
          'Digitize first. Duplicate buys usually mean invisible inventory. Once photos exist, search by color/category before shopping.',
      },
    ],
    relatedLinks: [
      { label: 'AI outfit recommendations', href: '/features/outfit-recommendations' },
      { label: 'For busy professionals', href: '/for/busy-professionals' },
      { label: 'Virtual try-on', href: '/features/virtual-try-on' },
    ],
  },

  'cost-per-wear-explained': {
    path: '/guides/cost-per-wear-calculator-explained',
    title: 'Cost Per Wear Explained (+ How to Track It) | FitCheck AI',
    description:
      'What cost-per-wear means, how to calculate it, and how wardrobe analytics help you buy less and wear more.',
    h1: 'Cost per wear explained',
    lede:
      'Cost per wear (CPW) is purchase price divided by times worn. A $200 coat worn 100 times costs $2 per wear; a $40 top worn twice costs $20 per wear. Tracking CPW turns “expensive” into “value” — and exposes cheap mistakes.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Cost per wear', path: '/guides/cost-per-wear-calculator-explained' },
    ],
    keywords: 'cost per wear, cost per wear calculator, wardrobe analytics, cost per use fashion',
    sections: [
      {
        heading: 'The formula',
        body: 'CPW = Price ÷ Number of wears. Optionally include cleaning or tailoring. Update wears honestly — the metric is only useful if the log is real.',
      },
      {
        heading: 'How to use CPW without becoming a spreadsheet hobbyist',
        body: 'Track high-ticket and high-guilt items first. Celebrate rising wears on quality pieces. Before buying, estimate expected wears for the next year. If the number is tiny, skip or rent.',
      },
      {
        heading: 'FitCheck AI’s role',
        body: 'Wardrobe analytics can surface utilization and cost-per-wear style insights so you see neglected items and better purchase ROI without manual ledgers for every sock.',
      },
    ],
    faqs: [
      {
        question: 'What is a “good” cost per wear?',
        answer:
          'It depends on income and category. Compare within your wardrobe: prioritize lowering CPW on items you already bought by wearing them more before shopping again.',
      },
    ],
    relatedLinks: [
      { label: 'Wardrobe analytics', href: '/features/wardrobe-analytics' },
      { label: 'Best virtual closet apps', href: '/best/virtual-closet-apps' },
    ],
  },

  'reduce-returns-virtual-try-on': {
    path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on',
    title: 'Reduce Clothing Returns with Virtual Try-On | FitCheck AI',
    description:
      'How AI virtual try-on helps you visualize purchases with clothes you own — and cut return-prone shopping mistakes.',
    h1: 'Reduce clothing returns with virtual try-on',
    lede:
      'Clothing returns often come from fit surprises, color mismatches with your wardrobe, and “it looked different online.” AI virtual try-on will not replace a tape measure, but it helps you visualize a piece with your existing clothes and body reference before you buy.',
    breadcrumbs: [
      { name: 'Home', path: '/' },
      { name: 'Reduce returns', path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on' },
    ],
    keywords: 'virtual try-on reduce returns, AI try on clothes, online shopping outfit check',
    sections: [
      {
        heading: 'Where try-on helps most',
        body: 'Color harmony with your wardrobe, silhouette balance (oversized vs tailored), and full-outfit context beat product-page hero shots. Use try-on after shortlisting, not as the first shopping step.',
      },
      {
        heading: 'A lower-return shopping workflow',
        body: '1) Digitize core wardrobe. 2) Shortlist purchases. 3) Virtually pair new pieces with what you own. 4) Check size charts still. 5) Buy only if at least two real outfits appear. FitCheck AI is built for steps 1–3 and 5.',
      },
      {
        heading: 'Limits to respect',
        body: 'Fabric stretch, exact sizing, and tailoring still need human judgment. Treat AI images as decision support, not a guarantee. When in doubt, choose retailers with clear size data and flexible return policies.',
      },
    ],
    faqs: [
      {
        question: 'Can virtual try-on eliminate returns?',
        answer:
          'No tool eliminates returns. It can reduce avoidable mistakes by improving visualization and outfit context before purchase.',
      },
    ],
    relatedLinks: [
      { label: 'Virtual try-on feature', href: '/features/virtual-try-on' },
      { label: 'AI wardrobe extraction', href: '/features/ai-wardrobe-extraction' },
    ],
  },
}

export const INTENT_PAGE_SLUGS = Object.keys(INTENT_PAGES)

export function getIntentPageByPath(path: string): SeoPageContent | undefined {
  return Object.values(INTENT_PAGES).find((p) => p.path === path)
}
