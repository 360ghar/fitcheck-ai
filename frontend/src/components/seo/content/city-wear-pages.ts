import type { SeoPageContent } from '../SeoPageLayout'

/**
 * Programmatic "what to wear in <city>" pages. Each city carries its own
 * climate facts, season guidance, style notes, and FAQs — content is
 * data-driven but never thin: every section is written from the city's
 * real climate profile.
 */

interface CityProfile {
  slug: string
  city: string
  country: string
  /** Answer-first lede, ~45–70 words. */
  lede: string
  /** 2–3 climate stats for the GEO statistics lever. */
  stats: Array<{ value: string; label: string }>
  seasons: Array<{ heading: string; body: string; bullets?: string[] }>
  style: string
  occasion: string
  pack: string
  faqs: Array<{ question: string; answer: string }>
}

const CITY_PROFILES: CityProfile[] = [
  {
    slug: 'mumbai',
    city: 'Mumbai',
    country: 'India',
    lede:
      'Mumbai is hot and humid for most of the year, with a heavy southwest monsoon from June to September and a mild, pleasant winter from November to February. Breathe through it with cotton, linen, and quick-dry fabrics — and a reliable rain layer when the monsoon arrives.',
    stats: [
      { value: 'Jun–Sep', label: 'Southwest monsoon months (heavy rain)' },
      { value: '~2,400 mm', label: 'Average annual rainfall' },
      { value: '20–30 °C', label: 'Winter daytime range (the pleasant season)' },
    ],
    seasons: [
      {
        heading: 'Monsoon (June–September): rain-proof basics',
        body: 'Carry a compact umbrella and a waterproof layer at all times. Choose quick-dry fabrics over denim, and keep footwear that survives puddles — sandals or water-resistant shoes beat leather.',
        bullets: ['Quick-dry shirts and trousers over denim', 'Umbrella + waterproof layer as daily carry', 'Slip-resistant, water-friendly footwear'],
      },
      {
        heading: 'Winter (November–February): the golden season',
        body: 'Days sit around 20–30 °C with low humidity — the most comfortable time for layering. A light jacket or cardigan for evenings is enough; full coats are overkill.',
      },
      {
        heading: 'Summer (March–May): heat management',
        body: 'Light cottons and linens, loose silhouettes, and hats. Moisture-wicking fabrics help more than any amount of layering. Keep a spare outfit for post-commute changes if you travel far.',
      },
    ],
    style: 'Smart-casual rules in Mumbai offices: collared shirts, chinos, and modest hemlines. Festive dressing (Ganesh Chaturthi, Diwali) leans on bright colors and traditional silhouettes like kurtas and lehengas.',
    occasion: 'Ganesh Chaturthi, Diwali, and wedding season dominate the festive calendar — plan occasion wear in advance and keep it separate from workwear.',
    pack: 'For a week: 5–7 cotton/linen tops, 3–4 bottoms, one light layer, one rain layer, umbrella, and two pairs of water-friendly shoes.',
    faqs: [
      { question: 'What is the best season to visit Mumbai?', answer: 'November to February: 20–30 °C days, low humidity, and little rain. June–September brings heavy monsoon rain.' },
      { question: 'Do I need warm clothes for Mumbai?', answer: 'No — a light jacket for air-conditioned spaces and cool evenings is enough. Heavy winter clothing is unnecessary.' },
    ],
  },
  {
    slug: 'delhi',
    city: 'Delhi',
    country: 'India',
    lede:
      'Delhi is a city of extremes: summers that push past 40 °C, monsoon humidity from July to September, and winters that drop to single digits at night. The strategy is seasonal rotation — light breathable layers for heat, serious layers for December and January.',
    stats: [
      { value: '45 °C', label: 'Peak summer daytime temperatures' },
      { value: '2 °C', label: 'Typical January night-time lows' },
      { value: 'Jul–Sep', label: 'Monsoon months with humidity spikes' },
    ],
    seasons: [
      {
        heading: 'Summer (April–June): beat the heat',
        body: 'Loose cotton and linen, light colors, and sun protection. Avoid dark, heavy fabrics. Air-conditioned offices mean carrying a light layer for indoor temperature swings.',
      },
      {
        heading: 'Winter (December–February): actual cold',
        body: 'Daytime 10–20 °C but nights can hit 2–5 °C. You need a real jacket, sweaters, and layering — wool and fleece earn their place. Mornings are the coldest, so commute layers matter.',
        bullets: ['Warm jacket + sweater layers', 'Scarf, gloves, and closed shoes for mornings', 'Indoor heating is uneven — layer for both worlds'],
      },
      {
        heading: 'Monsoon (July–September): humidity management',
        body: 'Temperatures moderate but humidity climbs. Quick-dry fabrics and water-resistant footwear help; carry an umbrella daily.',
      },
    ],
    style: 'Delhi offices range from formal to smart-casual; collared shirts and trousers are safe. Wedding season (October–February) is heavy — festive wear, from bandhgalas to lehengas, gets real use here.',
    occasion: 'Diwali, weddings, and winter festivals dominate. Digitize your festive wear before the season so mixing outfits takes minutes.',
    pack: 'For a winter week: 2 sweaters, 1 warm jacket, 5–7 tops, 3–4 bottoms, scarf, and closed shoes. For summer: cottons, linens, and a hat.',
    faqs: [
      { question: 'When is Delhi coldest?', answer: 'December and January, with night temperatures around 2–8 °C. Daytime highs stay near 15–20 °C.' },
      { question: 'What should I pack for Delhi in summer?', answer: 'Loose cotton and linen, light colors, sun protection, and a light layer for air-conditioned offices.' },
    ],
  },

  {
    slug: 'bengaluru',
    city: 'Bengaluru',
    country: 'India',
    lede:
      'Bengaluru is famously moderate — 15–32 °C year-round with a mild, wet monsoon. There is no real summer or winter, only a permanent "spring" with occasional rain. Light layers solve everything, and a light jacket is useful for air-conditioned offices and drizzle.',
    stats: [
      { value: '15–32 °C', label: 'Year-round temperature range' },
      { value: 'Layers', label: 'The only season strategy you need' },
      { value: 'Jun–Oct', label: 'Wettest months (moderate rain)' },
    ],
    seasons: [
      {
        heading: 'Year-round basics',
        body: 'Light cotton and linen work all year. Evenings cool down enough that a light jacket or cardigan earns its place, especially from November to February.',
      },
      {
        heading: 'Monsoon (June–October)',
        body: 'Rain is frequent but rarely torrential. Carry a compact umbrella; quick-dry shoes help. Indoor spaces stay warm, so focus on the commute layer.',
      },
      {
        heading: 'Office reality',
        body: 'Bengaluru has one of the most casual tech workwear cultures in India — smart-casual is the norm, with denim widely accepted. Keep one formal outfit for client days.',
      },
    ],
    style: 'Smart-casual dominates. Denim is office-acceptable in most tech companies; festive wear for Diwali and weddings sits alongside everyday casuals.',
    occasion: 'Diwali and wedding season add festive dressing; the mild climate means light festive fabrics work year-round.',
    pack: 'A week: 5–7 light tops, 3–4 bottoms, one light jacket, one smart outfit, and an umbrella.',
    faqs: [
      { question: 'Does Bengaluru get cold?', answer: 'Not really — but winter nights (Dec–Feb) can dip toward 15 °C, so a light jacket is worth carrying.' },
      { question: 'What fabric is best for Bengaluru weather?', answer: 'Cotton and linen. The moderate humidity makes breathable fabrics comfortable year-round.' },
    ],
  },
  {
    slug: 'chennai',
    city: 'Chennai',
    country: 'India',
    lede:
      'Chennai is hot and humid all year — 25–38 °C — with its heaviest rain arriving from October to December in the northeast monsoon. Cotton is king, breathability beats layering, and rain preparedness is a way of life from late autumn.',
    stats: [
      { value: '25–38 °C', label: 'Year-round temperature range' },
      { value: 'Oct–Dec', label: 'Northeast monsoon (main rainy season)' },
      { value: 'Cotton', label: 'The fabric Chennai revolves around' },
    ],
    seasons: [
      {
        heading: 'Summer (April–July): the heat peak',
        body: 'Loose cotton, light colors, and minimal layers. Sun protection and hydration matter more than any clothing trick. Evening breezes make light cottons comfortable.',
      },
      {
        heading: 'Northeast monsoon (October–December)',
        body: 'Chennai floods with surprising speed when the monsoon is strong. Waterproof footwear, an umbrella, and quick-dry fabrics are non-negotiable. Keep a change of clothes at work if you commute far.',
        bullets: ['Waterproof footwear + umbrella daily', 'Quick-dry fabrics over denim', 'Spare outfit for flood-prone commutes'],
      },
      {
        heading: 'Festive season',
        body: 'Pongal (January) and Margazhi festival season bring traditional dressing — silks and cottons — into daily life. Light festive fabrics suit the humid climate.',
      },
    ],
    style: 'Traditional wear is far more visible in Chennai than in other metros — cotton saris, kurtas, and veshtis for men. Offices are formal-to-smart-casual.',
    occasion: 'Pongal, Margazhi, and wedding season call for light silks and cottons; avoid heavy winter-style fabrics entirely.',
    pack: 'A week: 6–7 cotton tops, 3–4 lightweight bottoms, one formal outfit, one festive outfit, umbrella, and water-friendly shoes.',
    faqs: [
      { question: 'When does it rain most in Chennai?', answer: 'October to December, during the northeast monsoon. November is typically the wettest month.' },
      { question: 'Is winter clothing ever needed in Chennai?', answer: 'No. Even "winter" (Jan–Feb) stays near 25–30 °C during the day.' },
    ],
  },
  {
    slug: 'london',
    city: 'London',
    country: 'UK',
    lede:
      'London is temperate and changeable: mild summers around 18–23 °C, cool winters of 2–8 °C, and rain in any season. The uniform is layers plus a rain-ready outer layer — a waterproof shell or trench solves more outfit problems than any other single item.',
    stats: [
      { value: '2–8 °C', label: 'Typical winter daytime range' },
      { value: '18–23 °C', label: 'Typical summer daytime range' },
      { value: '~600 mm', label: 'Annual rainfall — spread across all seasons' },
    ],
    seasons: [
      {
        heading: 'Winter (November–February)',
        body: 'Cold, grey, and damp. A warm coat, knitwear, scarf, and gloves are essential. Layering matters because the Tube and offices run warm while streets stay cold.',
        bullets: ['Warm coat + knitwear + scarf', 'Water-resistant outer layer', 'Layers for warm transit vs cold streets'],
      },
      {
        heading: 'Summer (June–August)',
        body: 'Mild rather than hot, with occasional heat spikes. Light layers, a light jacket for evenings, and always something for rain. British summer dressing is casual-to-smart-casual.',
      },
      {
        heading: 'Spring and autumn',
        body: 'The most changeable seasons — one day can swing 10 °C. A midweight jacket plus layers is the reliable system.',
      },
    ],
    style: 'London skews smart-casual with a strong tailoring tradition. Workwear ranges from suits in finance to near-casual in tech. Rain-ready outerwear is a permanent fixture.',
    occasion: 'Wedding season (May–September) and garden-party season reward light tailoring and occasion dresses; festive wear is understated compared to South Asia.',
    pack: 'A week: 5–7 tops, 3–4 bottoms, 1–2 knitwear, 1 warm coat (winter) or light jacket (summer), waterproof shell, and one smart outfit.',
    faqs: [
      { question: 'What should I pack for London in winter?', answer: 'A warm coat, knitwear, scarf, gloves, and a water-resistant layer. Indoor heating means layering, not one giant parka.' },
      { question: 'Does London get hot in summer?', answer: 'Occasionally — heat spikes reach 30 °C+ for a few days. Light layers handle both the spikes and the usual mild days.' },
    ],
  },


  {
    slug: 'new-york',
    city: 'New York',
    country: 'USA',
    lede:
      'New York has four real seasons: hot, humid summers; crisp falls; cold, snowy winters; and fast-changing springs. The wardrobe system is seasonal rotation plus a strong outerwear game — a good winter coat and a versatile mid-layer solve most of the year.',
    stats: [
      { value: '−5–5 °C', label: 'Typical winter daytime range' },
      { value: '26–32 °C', label: 'Typical summer daytime range' },
      { value: '4', label: 'Full seasons — each needs its own rotation' },
    ],
    seasons: [
      {
        heading: 'Winter (December–February)',
        body: 'Cold and windy with regular snow. A heavy coat, knitwear, hat, gloves, and insulated boots are non-negotiable. Buildings and transit run warm, so layer strategically.',
        bullets: ['Heavy coat + knitwear + accessories', 'Insulated, slip-resistant boots', 'Transit-friendly layers'],
      },
      {
        heading: 'Summer (June–August)',
        body: 'Hot, humid, and intense. Light cottons and linens, breathable footwear, and minimal layers. Air-conditioning everywhere means carrying a light layer indoors.',
      },
      {
        heading: 'Spring and fall',
        body: 'The classic "layer season" — a jacket, light knit, and adaptable pieces handle 10–20 °C swings between morning and afternoon.',
      },
    ],
    style: 'New York is fashion-forward but practical: dark neutrals and elevated basics dominate workwear, and "business casual" is broader than in London. Walking dominates — comfort matters in shoes.',
    occasion: 'Year-round event calendar: galas, weddings, and holiday parties. Occasion dressing tends to be more formal and more adventurous than daily wear.',
    pack: 'For winter: heavy coat, 2 knitwear, 5–7 tops, 3–4 bottoms, boots, hat, gloves. For summer: cottons, linens, one light layer, comfortable walking shoes.',
    faqs: [
      { question: 'How cold does New York get in winter?', answer: 'Daytime highs hover around −1 to 5 °C in January, with nights below freezing. Snowfall is common.' },
      { question: 'Is New York walkable in summer?', answer: 'Yes, but the heat and humidity are real — breathable fabrics and comfortable shoes are the priority.' },
    ],
  },

  {
    slug: 'dubai',
    city: 'Dubai',
    country: 'UAE',
    lede:
      'Dubai is desert-hot for most of the year — summers routinely pass 40 °C — with mild, pleasant winters from November to March. Breathable fabrics, strong air-conditioning, and modest dress codes shape the wardrobe more than seasons do.',
    stats: [
      { value: '40 °C+', label: 'Peak summer daytime temperatures' },
      { value: '15–25 °C', label: 'Winter daytime range (the pleasant season)' },
      { value: 'AC everywhere', label: 'Indoor temperatures swing 20 °C from the street' },
    ],
    seasons: [
      {
        heading: 'Summer (May–September)',
        body: 'Extreme heat and humidity near the coast. Loose, light, breathable fabrics; sun protection; minimal time outdoors at midday. A light layer is needed for aggressive air-conditioning indoors.',
      },
      {
        heading: 'Winter (November–March)',
        body: 'The outdoor season: 15–25 °C days, cool evenings. Light layers and a light jacket for evenings; this is when outdoor events and beach days happen.',
      },
      {
        heading: 'Dress code',
        body: 'Public dress is modest: shoulders and knees covered in malls and government areas. "Smart casual" is the default for most venues, with formal wear for business and events.',
        bullets: ['Modest public dress: covered shoulders and knees', 'Light layers for AC swings', 'Smart-casual as the baseline'],
      },
    ],
    style: 'Elegant smart-casual rules. Business dress is formal but breathable — light suits and linens in summer. Beachwear is for resorts and private beaches only.',
    occasion: 'Ramadan, Eid, and National Day shape the calendar; events skew elegant and formal. Winter wedding season is the peak for occasion wear.',
    pack: 'For winter: 5–7 smart-casual outfits, one formal outfit, light jacket, comfortable covered footwear. For summer: loose linens and cottons plus a light indoor layer.',
    faqs: [
      { question: 'Is there a dress code for tourists in Dubai?', answer: 'Modesty is expected in public spaces — shoulders and knees covered in malls and government areas. Resorts and private beaches are more relaxed.' },
      { question: 'When is the best time to visit Dubai?', answer: 'November to March, when days are 15–25 °C. Summers are extreme but indoor life is heavily air-conditioned.' },
    ],
  },

  {
    slug: 'singapore',
    city: 'Singapore',
    country: 'Singapore',
    lede:
      'Singapore is equatorial: hot and humid year-round at 25–33 °C, with rain in any month and heavy downpours most afternoons. There are no seasons — only a rotation of breathable fabrics, rain-ready shoes, and one light layer for aggressive air-conditioning.',
    stats: [
      { value: '25–33 °C', label: 'Year-round temperature range' },
      { value: '~2,300 mm', label: 'Annual rainfall — every month has rain' },
      { value: '2 p.m.', label: 'Typical start of the daily afternoon downpour' },
    ],
    seasons: [
      {
        heading: 'Year-round basics',
        body: 'Cottons, linens, and breathable wovens. Loose silhouettes beat tight fits in humidity. Rain showers are daily events from November to January and again in the middle of the year — a compact umbrella is permanent carry.',
        bullets: ['Breathable fabrics only', 'Umbrella as permanent carry', 'Rain-ready shoes'],
      },
      {
        heading: 'Indoor climate',
        body: 'Singapore air-conditioning is aggressive — offices and malls often sit 10–15 °C below the street. A light jacket or cardigan in your bag is standard practice.',
      },
      {
        heading: 'Dress code',
        body: 'Smart-casual is the office default; formal wear for client-facing roles. Modesty is appreciated in temples and government buildings.',
      },
    ],
    style: 'Crisp smart-casual dominates — light blazers over cotton shirts are common. Grooming standards are high and the heat rewards well-chosen fabrics over heavy trends.',
    occasion: 'Chinese New Year, Deepavali, Hari Raya, and wedding season bring festive dressing across cultures; light festive fabrics suit the climate.',
    pack: 'A week: 6–7 breathable tops, 3–4 bottoms, one light jacket for AC, umbrella, rain-friendly shoes, and one smart outfit.',
    faqs: [
      { question: 'Does Singapore have seasons?', answer: 'No — it is hot and humid year-round. The main variation is rain: wetter from November to January and mid-year.' },
      { question: 'What should I wear to Singapore offices?', answer: 'Smart-casual: collared shirts, chinos, and breathable fabrics. Keep a light layer for strong air-conditioning.' },
    ],
  },

  {
    slug: 'toronto',
    city: 'Toronto',
    country: 'Canada',
    lede:
      'Toronto is a four-season city with the coldest winters of this list — January days hover around −5 °C with wind chill far lower — and warm, humid summers. A serious winter coat, insulated boots, and a solid layering system are not optional.',
    stats: [
      { value: '−10–0 °C', label: 'Typical January daytime range' },
      { value: '22–28 °C', label: 'Typical July daytime range' },
      { value: 'Winter gear', label: 'The defining wardrobe investment in Toronto' },
    ],
    seasons: [
      {
        heading: 'Winter (December–February)',
        body: 'Cold, snowy, and windy. A down or wool coat rated for −20 °C, thermal layers, insulated boots, hat, gloves, and scarf are essential. Indoor heating is strong, so breathable inner layers matter.',
        bullets: ['Heavy winter coat rated for −20 °C', 'Insulated, waterproof boots', 'Thermal base layers'],
      },
      {
        heading: 'Summer (June–August)',
        body: 'Warm and humid with occasional heat waves past 30 °C. Light cottons and linens; comfortable walking shoes for a very walkable city.',
      },
      {
        heading: 'Spring and fall',
        body: 'Short and changeable — a midweight jacket, rain shell, and layers handle the swing between 5 °C and 20 °C in one week.',
      },
    ],
    style: 'Practical-smart: dark layers, good outerwear, and durable footwear dominate. Business dress is formal-smart; tech and creative roles are casual.',
    occasion: 'Year-round festivals and a busy wedding season in summer and fall. Holiday parties in December reward polished occasion wear.',
    pack: 'For winter: heavy coat, 2–3 knitwear, thermal base layer, 5–7 tops, 3–4 bottoms, insulated boots, hat, gloves. For summer: cottons, linens, light layer, walking shoes.',
    faqs: [
      { question: 'How cold does Toronto get?', answer: 'January highs are typically −5 to 0 °C, with wind chill much colder. February is similar; snow is common from December through March.' },
      { question: 'Do I need special boots for Toronto winter?', answer: 'Yes — insulated, waterproof boots with good grip handle snow, slush, and salted sidewalks.' },
    ],
  },

  {
    slug: 'sydney',
    city: 'Sydney',
    country: 'Australia',
    lede:
      'Sydney is mild and sunny: summers of 22–30 °C, winters of 8–17 °C that never really bite, and a smart-casual coastal culture. The wardrobe is light layers, breathable fabrics, and one jacket that works for evenings and the occasional cool spell.',
    stats: [
      { value: '22–30 °C', label: 'Typical summer daytime range' },
      { value: '8–17 °C', label: 'Typical winter daytime range' },
      { value: 'UV 11+', label: 'Summer UV index — sun protection is part of dressing' },
    ],
    seasons: [
      {
        heading: 'Summer (December–February)',
        body: 'Warm-to-hot with high UV. Light cottons and linens, hats, and sun protection are standard. Evenings stay warm; beachwear belongs at the beach.',
      },
      {
        heading: 'Winter (June–August)',
        body: 'Cool but mild: 8–17 °C with sunny days. A midweight jacket, knitwear, and closed shoes carry the season; heavy winter coats are rarely needed outside mountain trips.',
      },
      {
        heading: 'Spring and autumn',
        body: 'Sydney at its best: 15–25 °C, mostly sunny. Light layers and one versatile jacket handle the range.',
      },
    ],
    style: 'Relaxed smart-casual with a coastal bent — quality basics, good footwear, and less formality than northern cities. Business dress is lighter: suits in finance, smart-casual almost everywhere else.',
    occasion: 'Summer weddings (Dec–Feb) and festival season reward light occasion wear; the "semi-formal" dress code is common on invitations.',
    pack: 'A week: 5–7 light tops, 3–4 bottoms, one midweight jacket, one smart outfit, comfortable walking shoes, and sun protection.',
    faqs: [
      { question: 'Is Sydney cold in winter?', answer: 'No — winter days are typically 8–17 °C and sunny. A midweight jacket and knitwear are enough.' },
      { question: 'What is the dress code for Sydney events?', answer: '"Semi-formal" and smart-casual dominate; summer weddings often specify light, breathable occasion wear.' },
    ],
  },
]

export const CITY_WEAR_PAGES: Record<string, SeoPageContent> = Object.fromEntries(
  CITY_PROFILES.map((p) => [
    `wear-${p.slug}`,
    {
      path: `/wear/what-to-wear-in-${p.slug}`,
      lastUpdated: '2026-08-01',
      title: `What to Wear in ${p.city}: Season-by-Season Guide | FitCheck AI`,
      description: `What to wear in ${p.city} all year: season-by-season outfit formulas, weather notes, and packing tips — built on clothes you already own.`,
      h1: `What to wear in ${p.city}`,
      lede: p.lede,
      breadcrumbs: [
        { name: 'Home', path: '/' },
        { name: `What to wear in ${p.city}`, path: `/wear/what-to-wear-in-${p.slug}` },
      ],
      keywords: `what to wear in ${p.city}, ${p.city} outfit guide, ${p.city} packing list, ${p.city} weather clothes`,
      stats: p.stats,
      sections: [
        ...p.seasons,
        {
          heading: `Style notes for ${p.city}`,
          body: p.style,
        },
        {
          heading: `Occasions and festive wear`,
          body: p.occasion,
        },
        {
          heading: `A ${p.city} packing list`,
          body: p.pack,
        },
      ],
      faqs: p.faqs,
      relatedLinks: [
        { label: 'What to wear today', href: '/guides/what-to-wear-today' },
        { label: 'Best AI outfit planners', href: '/best/ai-outfit-planners' },
        { label: 'How to digitize your wardrobe', href: '/guides/how-to-digitize-your-wardrobe' },
      ],
    },
  ])
)

export function getCityWearPageByPath(path: string): SeoPageContent | undefined {
  return Object.values(CITY_WEAR_PAGES).find((p) => p.path === path)
}

