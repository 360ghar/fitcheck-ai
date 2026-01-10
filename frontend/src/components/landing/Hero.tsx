import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { GlassCard } from './GlassCard'
import { ArrowRight, Play, Sparkles, Camera, Wand2, Calendar } from 'lucide-react'

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center pt-20 overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950" />

      {/* Animated gradient orbs */}
      <div className="absolute top-1/4 -left-20 w-72 h-72 md:w-96 md:h-96 bg-indigo-400/30 rounded-full blur-3xl animate-pulse-slow" />
      <div className="absolute bottom-1/4 -right-20 w-72 h-72 md:w-96 md:h-96 bg-purple-400/30 rounded-full blur-3xl animate-pulse-slow [animation-delay:2s]" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-gradient-to-r from-indigo-300/20 to-purple-300/20 rounded-full blur-3xl" />

      {/* Grid pattern overlay */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#8882_1px,transparent_1px),linear-gradient(to_bottom,#8882_1px,transparent_1px)] bg-[size:14px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-20">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left: Text content */}
          <div className="text-center lg:text-left">
            <Badge className="mb-6 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0 px-4 py-1.5">
              <Sparkles className="w-3 h-3 mr-2" />
              AI-Powered Fashion
            </Badge>

            <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight">
              <span className="text-gray-900 dark:text-white">Your AI-Powered</span>
              <br />
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                Virtual Closet
              </span>
            </h1>

            <p className="mt-6 text-lg md:text-xl text-gray-600 dark:text-gray-300 max-w-xl mx-auto lg:mx-0">
              Transform how you dress with intelligent outfit recommendations, virtual try-on
              visualization, and smart wardrobe analytics. Never wonder what to wear again.
            </p>

            <div className="mt-10 flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <Button
                size="lg"
                className="bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-lg px-8 py-6 shadow-lg shadow-indigo-500/25"
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
                    className="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 border-2 border-white dark:border-gray-900 flex items-center justify-center text-white text-xs font-bold"
                  >
                    {String.fromCharCode(64 + i)}
                  </div>
                ))}
              </div>
              <div className="text-sm text-gray-600 dark:text-gray-400">
                <span className="font-semibold text-gray-900 dark:text-white">10,000+</span>{' '}
                fashion-forward users
              </div>
            </div>
          </div>

          {/* Right: App mockup */}
          <div className="relative">
            {/* Main mockup */}
            <div className="relative z-10">
              <GlassCard className="p-3 rounded-3xl">
                <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-2xl p-6 aspect-[4/3] flex items-center justify-center">
                  <div className="text-center">
                    <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center">
                      <Wand2 className="w-10 h-10 text-white" />
                    </div>
                    <h3 className="text-white text-xl font-semibold mb-2">AI Outfit Generator</h3>
                    <p className="text-gray-400 text-sm max-w-xs">
                      See how your outfits look before you wear them
                    </p>
                  </div>
                </div>
              </GlassCard>
            </div>

            {/* Floating badges */}
            <div className="absolute -left-4 md:-left-8 top-1/4 animate-float z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-yellow-400 to-orange-500 flex items-center justify-center">
                  <Sparkles className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm font-medium text-gray-900 dark:text-white pr-2">
                  AI Recommendations
                </span>
              </GlassCard>
            </div>

            <div className="absolute -right-4 md:-right-8 top-1/2 animate-float [animation-delay:1s] z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-400 to-cyan-500 flex items-center justify-center">
                  <Camera className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm font-medium text-gray-900 dark:text-white pr-2">
                  Auto-Extract Items
                </span>
              </GlassCard>
            </div>

            <div className="absolute -left-4 md:-left-8 bottom-1/4 animate-float [animation-delay:2s] z-20">
              <GlassCard className="p-3 flex items-center gap-2 shadow-lg">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-green-400 to-teal-500 flex items-center justify-center">
                  <Calendar className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm font-medium text-gray-900 dark:text-white pr-2">
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
