import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { ArrowRight, Smartphone } from 'lucide-react'
import { PLATFORM_AVAILABILITY } from '@/lib/plan-limits'

export default function Hero() {
  return (
    <section className="relative min-h-[100dvh] flex items-center pt-16 overflow-x-hidden bg-stone-50 dark:bg-stone-950">
      {/* Quiet accent wash - single indigo tint, no purple mesh orbs */}
      <div
        className="pointer-events-none absolute inset-0 opacity-70 dark:opacity-40"
        aria-hidden
        style={{
          background:
            'radial-gradient(ellipse 80% 50% at 0% 0%, rgb(99 102 241 / 0.07), transparent 55%), radial-gradient(ellipse 60% 40% at 100% 20%, rgb(120 113 108 / 0.07), transparent 50%)',
        }}
      />

      <div className="relative w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 md:py-14 pb-16 sm:pb-20">
        <div className="grid lg:grid-cols-12 gap-10 lg:gap-12 items-center">
          <div className="lg:col-span-5 text-left">
            <h1 className="landing-display text-4xl sm:text-5xl lg:text-[3.25rem] xl:text-6xl font-semibold text-stone-900 dark:text-stone-50 leading-[1.08]">
              AI virtual closet for better outfits every day
            </h1>

            <p className="mt-5 text-base sm:text-lg text-stone-600 dark:text-stone-400 max-w-md leading-relaxed">
              FitCheck AI turns photos of your clothes into a digital wardrobe, then helps you pick weather-aware outfits, try looks on, and generate photoshoot-style images from what you already own. Start free on the web.
            </p>

            <p className="mt-3 text-sm text-stone-500 dark:text-stone-500 max-w-md">
              Web + Android live · iOS waitlist
            </p>

            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <Button
                size="lg"
                className="bg-indigo-600 hover:bg-indigo-700 text-white h-12 px-6 text-base font-medium shadow-none"
                asChild
              >
                <Link to="/auth/register">
                  Start free
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="h-12 px-6 text-base font-medium border-stone-300 dark:border-stone-700 bg-white/60 dark:bg-stone-900/60"
                asChild
              >
                <a
                  href={PLATFORM_AVAILABILITY.androidStoreUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <Smartphone className="mr-2 h-4 w-4" />
                  Get the Android app
                </a>
              </Button>
            </div>
          </div>

          <div className="lg:col-span-7 relative pb-6 sm:pb-8">
            <div className="relative rounded-2xl overflow-hidden border border-stone-200/80 dark:border-stone-800 bg-stone-200 dark:bg-stone-900 aspect-[4/3] shadow-[0_24px_60px_-24px_rgba(28,25,23,0.35)]">
              <img
                src="/landing/wardrobe.jpg"
                alt="A neatly arranged wardrobe of everyday clothes"
                className="absolute inset-0 w-full h-full object-cover"
                width={1152}
                height={864}
                fetchPriority="high"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-stone-950/70 via-stone-950/10 to-transparent" />

              <div className="absolute bottom-4 left-4 right-4 sm:bottom-6 sm:left-6 sm:right-auto sm:w-[min(100%,320px)]">
                <div className="rounded-xl border border-white/15 bg-stone-950/85 backdrop-blur-md p-4 text-white shadow-xl">
                  <p className="text-[11px] uppercase tracking-[0.14em] text-stone-400 mb-2">
                    Today&apos;s outfit
                  </p>
                  <p className="font-medium text-[15px] leading-snug">
                    Navy overshirt, ecru tee, stone chinos
                  </p>
                  <div className="mt-3 flex flex-wrap items-center gap-2">
                    <span className="inline-flex h-7 items-center rounded-full bg-indigo-600 px-3 text-xs font-medium">
                      Recommended
                    </span>
                    <span className="text-xs text-stone-400">Weather-aware pick</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Secondary photo - reserved space below so it is not clipped */}
            <div className="hidden sm:block absolute bottom-0 right-0 lg:right-4 w-36 h-44 rounded-xl overflow-hidden border-4 border-stone-50 dark:border-stone-950 shadow-lg rotate-2 translate-y-2">
              <img
                src="/landing/outfit.jpg"
                alt="Styled everyday outfit"
                className="w-full h-full object-cover"
                width={864}
                height={1152}
                loading="lazy"
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
