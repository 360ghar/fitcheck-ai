import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { GlassCard } from './GlassCard'
import { ArrowRight, Play, Sparkles, Camera, Wand2, Calendar } from 'lucide-react'

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center pt-20 overflow-hidden">
      {/* Background - refined luxury gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-navy-50 via-white to-gold-50/30 dark:from-navy-950 dark:via-navy-900 dark:to-navy-950" />

      {/* Subtle texture overlay */}
      <div className="absolute inset-0 opacity-[0.015] dark:opacity-[0.03]" style={{ backgroundImage: "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 400 400' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E\")" }} />

      {/* Refined gradient accents - subtle and elegant */}
      <div className="absolute top-1/4 -left-20 w-72 h-72 md:w-96 md:h-96 bg-navy-200/20 dark:bg-navy-700/20 rounded-full blur-3xl" />
      <div className="absolute bottom-1/4 -right-20 w-72 h-72 md:w-96 md:h-96 bg-gold-200/20 dark:bg-gold-700/10 rounded-full blur-3xl" />

      {/* Subtle grid pattern */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#1A365D08_1px,transparent_1px),linear-gradient(to_bottom,#1A365D08_1px,transparent_1px)] dark:bg-[linear-gradient(to_right,#C9A96210_1px,transparent_1px),linear-gradient(to_bottom,#C9A96210_1px,transparent_1px)] bg-[size:14px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-20">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left: Text content */}
          <div className="text-center lg:text-left">
            <Badge variant="gold" className="mb-6 px-4 py-1.5">
              <Sparkles className="w-3 h-3 mr-2" />
              AI-Powered Fashion
            </Badge>

            <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-display font-semibold tracking-tight">
              <span className="text-navy-800 dark:text-white">Your AI-Powered</span>
              <br />
              <span className="text-gold-500 dark:text-gold-400">
                Virtual Closet
              </span>
            </h1>

            <p className="mt-6 text-lg md:text-xl text-navy-500 dark:text-navy-300 max-w-xl mx-auto lg:mx-0">
              Transform how you dress with intelligent outfit recommendations, virtual try-on
              visualization, and smart wardrobe analytics. Never wonder what to wear again.
            </p>

            <div className="mt-10 flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <Button
                size="lg"
                className="text-lg px-8 py-6 shadow-lg"
                asChild
              >
                <Link to="/auth/register">
                  Use It Free
                  <ArrowRight className="ml-2 h-5 w-5" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" className="text-lg px-8 py-6">
                <Play className="mr-2 h-5 w-5" />
                Watch Demo
              </Button>
            </div>

            {/* Social proof */}
            <div className="mt-10 flex items-center gap-4 justify-center lg:justify-start">
              <div className="flex -space-x-3">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div
                    key={i}
                    className="w-10 h-10 rounded-full bg-gradient-to-br from-navy-600 to-navy-800 dark:from-gold-400 dark:to-gold-600 border-2 border-white dark:border-navy-900 flex items-center justify-center text-white dark:text-navy-900 text-xs font-bold"
                  >
                    {String.fromCharCode(64 + i)}
                  </div>
                ))}
              </div>
              <div className="text-sm text-navy-500 dark:text-navy-400">
                <span className="font-semibold text-navy-800 dark:text-white">10,000+</span>{' '}
                fashion-forward users
              </div>
            </div>
          </div>

          {/* Right: App mockup */}
          <div className="relative">
            {/* Main mockup */}
            <div className="relative z-10">
              <GlassCard className="p-3 rounded-3xl">
                <div className="bg-gradient-to-br from-navy-900 to-navy-950 rounded-2xl p-6 aspect-[4/3] flex items-center justify-center">
                  <div className="text-center">
                    <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-600 flex items-center justify-center">
                      <Wand2 className="w-10 h-10 text-navy-900" />
                    </div>
                    <h3 className="text-white text-xl font-display font-semibold mb-2">AI Outfit Generator</h3>
                    <p className="text-navy-300 text-sm max-w-xs">
                      See how your outfits look before you wear them
                    </p>
                  </div>
                </div>
              </GlassCard>
            </div>

            {/* Floating badges */}
            <div className="absolute -left-4 md:-left-8 top-1/4 animate-float z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-gold-400 to-gold-600 flex items-center justify-center">
                  <Sparkles className="w-4 h-4 text-navy-900" />
                </div>
                <span className="text-sm font-medium text-navy-800 dark:text-white pr-2">
                  AI Recommendations
                </span>
              </GlassCard>
            </div>

            <div className="absolute -right-4 md:-right-8 top-1/2 animate-float [animation-delay:1s] z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-navy-700 dark:bg-navy-600 flex items-center justify-center">
                  <Camera className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm font-medium text-navy-800 dark:text-white pr-2">
                  Auto-Extract Items
                </span>
              </GlassCard>
            </div>

            <div className="absolute -left-4 md:-left-8 bottom-1/4 animate-float [animation-delay:2s] z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-navy-800 dark:bg-gold-500 flex items-center justify-center">
                  <Calendar className="w-4 h-4 text-white dark:text-navy-900" />
                </div>
                <span className="text-sm font-medium text-navy-800 dark:text-white pr-2">
                  Plan Outfits
                </span>
              </GlassCard>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
