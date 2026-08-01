import { useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Calculator } from 'lucide-react'
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, buildFaqSchema } from '@/components/seo/JsonLd'
import { SEO_CONFIG } from '@/components/seo/seo-config'
import { Button } from '@/components/ui/button'
import { AnimatedSection } from '@/components/landing/AnimatedSection'

const PATH = '/tools/cost-per-wear-calculator'
const CANONICAL = `${SEO_CONFIG.siteUrl}${PATH}`

const FAQS = [
  {
    question: 'What is cost per wear?',
    answer:
      'Cost per wear (CPW) is the item price divided by the number of times you wear it. It is the most useful number for deciding whether a purchase was worth it and what to buy next.',
  },
  {
    question: 'What is a good cost per wear?',
    answer:
      'It depends on your income and the category. A useful rule: under $1 per wear for everyday items is strong value; $1–5 is typical for quality pieces; above $10 per wear means the item is either luxury or barely worn.',
  },
  {
    question: 'How do I increase the number of wears?',
    answer:
      'Plan outfits from your real wardrobe, keep a shortlist of go-to combinations, and re-wear quality pieces before buying new ones. Wear tracking in FitCheck AI makes this automatic.',
  },
]

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value)
}

function cpwInsight(cpw: number): { label: string; tone: string } {
  if (cpw <= 0) return { label: 'Enter a price and wears to see your cost per wear.', tone: 'text-stone-500 dark:text-stone-400' }
  if (cpw < 1) return { label: 'Excellent value — this item has earned its cost.', tone: 'text-emerald-600 dark:text-emerald-400' }
  if (cpw <= 5) return { label: 'Solid value — typical for quality, well-worn pieces.', tone: 'text-stone-700 dark:text-stone-300' }
  if (cpw <= 10) return { label: 'On the higher side — wear it more to lower the number.', tone: 'text-amber-600 dark:text-amber-400' }
  return { label: 'High cost per wear — wear it more or skip similar buys.', tone: 'text-red-600 dark:text-red-400' }
}


export default function CostPerWearCalculatorPage() {
  const [price, setPrice] = useState<number>(0)
  const [wears, setWears] = useState<number>(0)

  const cpw = wears > 0 && price > 0 ? price / wears : 0
  const insight = cpwInsight(cpw)
  const breadcrumbs = [
    { name: 'Home', url: `${SEO_CONFIG.siteUrl}/` },
    { name: 'Cost per wear calculator', url: CANONICAL },
  ]

  return (
    <>
      <SEO
        title="Cost Per Wear Calculator — Free & Instant | FitCheck AI"
        description="Calculate the true cost per wear of any clothing item in seconds. Free tool with wardrobe analytics tips."
        canonicalUrl={CANONICAL}
        keywords="cost per wear calculator, cost per use calculator, clothing cost calculator"
        jsonLd={buildFaqSchema(FAQS)}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />

      <div className="pt-20 landing-surface">
        <section className="border-b border-stone-200 bg-stone-50 py-14 dark:border-stone-800 dark:bg-stone-950 md:py-20">
          <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <p className="mb-4 flex items-center gap-2 text-sm font-semibold text-primary">
                <Calculator className="h-4 w-4" aria-hidden />
                Free tool
              </p>
              <h1 className="landing-display text-3xl font-semibold leading-tight text-stone-900 dark:text-stone-50 sm:text-4xl md:text-5xl">
                Cost per wear calculator
              </h1>
              <p className="mt-5 max-w-2xl text-base leading-relaxed text-stone-600 dark:text-stone-400 md:text-lg">
                Cost per wear = price ÷ wears. It is the honest test of whether
                a purchase was worth it — and the number that makes
                “buy less, wear more” measurable.
              </p>
            </AnimatedSection>

            <div className="mt-10 rounded-2xl border border-stone-200 bg-white p-6 dark:border-stone-800 dark:bg-stone-900 md:p-8">
              <div className="grid gap-6 sm:grid-cols-2">
                <label className="block">
                  <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                    Item price (USD)
                  </span>
                  <input
                    type="number"
                    min={0}
                    step="0.01"
                    value={price || ''}
                    onChange={(e) => setPrice(Math.max(0, Number(e.target.value)))}
                    placeholder="49.99"
                    className="mt-2 w-full rounded-lg border border-stone-300 bg-white px-4 py-3 text-stone-900 outline-none focus:border-primary dark:border-stone-700 dark:bg-stone-950 dark:text-stone-50"
                    inputMode="decimal"
                  />
                </label>
                <label className="block">
                  <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                    Expected wears
                  </span>
                  <input
                    type="number"
                    min={0}
                    step="1"
                    value={wears || ''}
                    onChange={(e) => setWears(Math.max(0, Math.round(Number(e.target.value))))}
                    placeholder="30"
                    className="mt-2 w-full rounded-lg border border-stone-300 bg-white px-4 py-3 text-stone-900 outline-none focus:border-primary dark:border-stone-700 dark:bg-stone-950 dark:text-stone-50"
                    inputMode="numeric"
                  />
                </label>
              </div>


              <div className="mt-8 rounded-xl bg-stone-100 p-6 dark:bg-stone-950">
                <p className="text-sm text-stone-500 dark:text-stone-400">Cost per wear</p>
                <p className="landing-display mt-1 text-4xl font-semibold text-stone-900 dark:text-stone-50">
                  {cpw > 0 ? formatCurrency(cpw) : '—'}
                </p>
                <p className={`mt-2 text-sm ${insight.tone}`}>{insight.label}</p>
              </div>

              <p className="mt-6 text-xs leading-relaxed text-stone-500 dark:text-stone-400">
                Tip: track high-ticket and high-guilt items first. Raising wears
                on what you already own beats buying anything new. FitCheck AI
                wardrobe analytics does this automatically from your outfits.
              </p>
            </div>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Button asChild size="lg" className="h-12 px-6">
                <Link to="/auth/register">
                  Track wears automatically
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="h-12 px-6">
                <Link to="/guides/cost-per-wear-calculator-explained">
                  Read the full guide
                </Link>
              </Button>
            </div>
          </div>
        </section>

        <section className="bg-white py-14 dark:bg-stone-950 md:py-16">
          <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
            <h2 className="landing-display text-2xl font-semibold text-stone-900 dark:text-stone-50">
              Frequently asked questions
            </h2>
            <div className="mt-6 space-y-5">
              {FAQS.map((faq) => (
                <div key={faq.question} className="border-b border-stone-200 pb-5 dark:border-stone-800">
                  <h3 className="font-medium text-stone-900 dark:text-stone-50">{faq.question}</h3>
                  <p className="mt-2 text-stone-600 dark:text-stone-400">{faq.answer}</p>
                </div>
              ))}
            </div>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link to="/guides/what-is-wardrobe-utilization" className="inline-flex text-sm font-medium px-3 py-1.5 rounded-full bg-stone-100 dark:bg-stone-900 text-indigo-700 dark:text-indigo-300 hover:bg-indigo-50 dark:hover:bg-indigo-950/50">
                Wardrobe utilization
              </Link>
              <Link to="/guides/what-is-a-capsule-wardrobe" className="inline-flex text-sm font-medium px-3 py-1.5 rounded-full bg-stone-100 dark:bg-stone-900 text-indigo-700 dark:text-indigo-300 hover:bg-indigo-50 dark:hover:bg-indigo-950/50">
                Capsule wardrobes
              </Link>
              <Link to="/features/wardrobe-analytics" className="inline-flex text-sm font-medium px-3 py-1.5 rounded-full bg-stone-100 dark:bg-stone-900 text-indigo-700 dark:text-indigo-300 hover:bg-indigo-50 dark:hover:bg-indigo-950/50">
                Wardrobe analytics
              </Link>
            </div>
          </div>
        </section>
      </div>
    </>
  )
}
