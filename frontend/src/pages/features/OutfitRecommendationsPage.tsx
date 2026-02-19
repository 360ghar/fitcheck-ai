import { Link } from 'react-router-dom'
// Layout provided by parent route in App.tsx
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, HowToJsonLd } from '@/components/seo/JsonLd'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  Sparkles,
  Wand2,
  CloudSun,
  Calendar,
  Heart,
  Check,
  ArrowRight,
  Zap,
  Shirt,
  Umbrella,
  Sun,
  Smartphone,
  Camera,
  BarChart3,
  Clock,
} from 'lucide-react'

export default function OutfitRecommendationsPage() {
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Features', url: 'https://fitcheckaiapp.com/features' },
    { name: 'Outfit Recommendations', url: 'https://fitcheckaiapp.com/features/outfit-recommendations' },
  ]

  // HowTo schema for getting outfit recommendations
  const howToSchema = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: 'How to Get AI-Powered Daily Outfit Recommendations',
    description: 'Learn how to use AI to get personalized outfit suggestions based on your wardrobe, weather, calendar, and personal style preferences.',
    totalTime: 'PT5M',
    estimatedCost: {
      '@type': 'MonetaryAmount',
      currency: 'USD',
      value: '0',
    },
    supply: [
      { '@type': 'HowToSupply', name: 'Digital wardrobe in FitCheck AI' },
      { '@type': 'HowToSupply', name: 'Location for weather data' },
    ],
    tool: [
      { '@type': 'HowToTool', name: 'FitCheck AI app' },
    ],
    step: [
      {
        '@type': 'HowToStep',
        position: 1,
        name: 'Build Your Digital Wardrobe',
        text: 'Upload photos of your clothes or use AI wardrobe extraction to catalog your items with colors, categories, and styles.',
        url: 'https://fitcheckaiapp.com/features/outfit-recommendations#step-1',
      },
      {
        '@type': 'HowToStep',
        position: 2,
        name: 'Set Your Preferences',
        text: 'Tell us your style preferences, favorite colors, and any items or combinations you prefer to avoid.',
        url: 'https://fitcheckaiapp.com/features/outfit-recommendations#step-2',
      },
      {
        '@type': 'HowToStep',
        position: 3,
        name: 'Connect Calendar & Location',
        text: 'Link your calendar and set your location so AI can factor in your schedule and local weather.',
        url: 'https://fitcheckaiapp.com/features/outfit-recommendations#step-3',
      },
      {
        '@type': 'HowToStep',
        position: 4,
        name: 'Get Daily Recommendations',
        text: 'Each morning, receive personalized outfit suggestions perfect for your day, weather, and style.',
        url: 'https://fitcheckaiapp.com/features/outfit-recommendations#step-4',
      },
    ],
  }

  const features = [
    {
      icon: CloudSun,
      title: 'Weather Integration',
      description: 'AI considers temperature, precipitation, and conditions to suggest weather-appropriate outfits.',
    },
    {
      icon: Calendar,
      title: 'Calendar Awareness',
      description: 'Connect your calendar for occasion-appropriate suggestions—meetings, dates, workouts, and more.',
    },
    {
      icon: Heart,
      title: 'Style Learning',
      description: 'The more you use it, the better it gets. AI learns your preferences and improves recommendations.',
    },
    {
      icon: Sparkles,
      title: 'Color Coordination',
      description: 'Advanced color theory ensures every suggested outfit has harmonious, flattering color combinations.',
    },
    {
      icon: Zap,
      title: 'Smart Matching',
      description: 'AI understands which items in your wardrobe work well together based on style, fit, and occasion.',
    },
    {
      icon: Wand2,
      title: 'Complete Looks',
      description: 'Get full outfit suggestions including shoes, accessories, and jewelry that complete the look.',
    },
  ]

  const benefits = [
    'Save 10+ minutes every morning deciding what to wear',
    'Discover new combinations from clothes you already own',
    'Never be underdressed or overdressed for any occasion',
    'Get weather-appropriate suggestions automatically',
    'Reduce decision fatigue and morning stress',
    'Maximize the use of your existing wardrobe',
  ]

  const weatherExamples = [
    {
      condition: 'Hot & Sunny',
      temp: '85°F',
      icon: Sun,
      suggestion: 'Light cotton sundress, sandals, sun hat',
      colors: 'White, pastels, light blues',
    },
    {
      condition: 'Rainy Day',
      temp: '65°F',
      icon: Umbrella,
      suggestion: 'Waterproof jacket, dark jeans, boots',
      colors: 'Navy, charcoal, deep green',
    },
    {
      condition: 'Business Meeting',
      temp: '72°F',
      icon: Calendar,
      suggestion: 'Blazer, tailored pants, loafers',
      colors: 'Navy, charcoal, white',
    },
    {
      condition: 'Date Night',
      temp: '68°F',
      icon: Heart,
      suggestion: 'Silk blouse, dark jeans, heels',
      colors: 'Burgundy, black, cream',
    },
  ]

  const relatedFeatures = [
    {
      title: 'AI Wardrobe Extraction',
      description: 'Digitize your closet so AI can make recommendations from what you own.',
      link: '/features/ai-wardrobe-extraction',
      icon: Camera,
    },
    {
      title: 'Virtual Try-On',
      description: 'See recommended outfits on yourself before getting dressed.',
      link: '/features/virtual-try-on',
      icon: Smartphone,
    },
    {
      title: 'Wardrobe Analytics',
      description: 'See which items you wear most and get suggestions for unworn pieces.',
      link: '/features/wardrobe-analytics',
      icon: BarChart3,
    },
  ]

  return (
    <>
      <SEO
        title="AI Outfit Recommendations | Daily Style Suggestions | FitCheck AI"
        description="Get personalized daily outfit recommendations powered by AI. Considers your wardrobe, weather, calendar, and style preferences for perfect suggestions every day."
        canonicalUrl="https://fitcheckaiapp.com/features/outfit-recommendations"
        ogType="article"
        jsonLd={howToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />
      <HowToJsonLd {...howToSchema} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-emerald-500 via-teal-500 to-cyan-500 dark:from-emerald-950 dark:via-teal-950 dark:to-cyan-950">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-20 left-10 w-72 h-72 bg-white rounded-full blur-3xl" />
            <div className="absolute bottom-20 right-10 w-96 h-96 bg-white rounded-full blur-3xl" />
          </div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
            <AnimatedSection>
              <div className="text-center max-w-4xl mx-auto">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium mb-6">
                  <Sparkles className="w-4 h-4" />
                  AI Style Assistant
                </div>

                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                  Outfit Recommendations
                </h1>

                <p className="text-xl md:text-2xl text-emerald-100 mb-4 max-w-3xl mx-auto">
                  Your Personal AI Stylist for Every Day
                </p>

                <p className="text-lg text-emerald-200 mb-10 max-w-2xl mx-auto">
                  Get personalized outfit suggestions based on your wardrobe, local weather, calendar events,
                  and unique style preferences. Never wonder what to wear again.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    to="/auth/register"
                    className="inline-flex items-center justify-center gap-2 bg-white text-emerald-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                  >
                    Get Style Recommendations
                    <ArrowRight className="w-5 h-5" />
                  </Link>
                  <Link
                    to="#how-it-works"
                    className="inline-flex items-center justify-center gap-2 bg-white/10 backdrop-blur-sm text-white px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/20 transition-all"
                  >
                    See How It Works
                  </Link>
                </div>
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Stats Section */}
        <section className="py-16 bg-gray-50 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
              {[
                { value: '10min', label: 'Saved Daily' },
                { value: '3-5', label: 'Daily Suggestions' },
                { value: '100%', label: 'Your Clothes' },
                { value: '24/7', label: 'Availability' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="text-center">
                    <div className="text-3xl md:text-4xl font-bold text-emerald-600 dark:text-emerald-400 mb-2">
                      {stat.value}
                    </div>
                    <div className="text-gray-600 dark:text-gray-400">{stat.label}</div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Features Grid */}
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Smart Recommendations That Understand You
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Our AI considers multiple factors to suggest outfits perfectly tailored to your day
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <div className="group p-8 bg-gray-50 dark:bg-gray-900 rounded-2xl hover:bg-emerald-50 dark:hover:bg-emerald-950/30 transition-all duration-300 hover:shadow-lg border border-gray-100 dark:border-gray-800 hover:border-emerald-200 dark:hover:border-emerald-800">
                    <div className="w-14 h-14 bg-emerald-100 dark:bg-emerald-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-emerald-600 dark:text-emerald-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Weather-Aware Section */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-emerald-50 to-cyan-50 dark:from-gray-900 dark:to-emerald-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Weather-Aware Outfit Planning
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Never get caught unprepared. AI factors in real-time weather for perfect recommendations.
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {weatherExamples.map((example, index) => (
                <AnimatedSection key={example.condition} delay={index * 100}>
                  <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-gray-700">
                    <div className="flex items-center justify-between mb-4">
                      <div className="w-12 h-12 bg-emerald-100 dark:bg-emerald-900/50 rounded-xl flex items-center justify-center">
                        <example.icon className="w-6 h-6 text-emerald-600 dark:text-emerald-400" />
                      </div>
                      <span className="text-2xl font-bold text-emerald-600 dark:text-emerald-400">
                        {example.temp}
                      </span>
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                      {example.condition}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 text-sm mb-3">
                      {example.suggestion}
                    </p>
                    <div className="text-xs text-emerald-600 dark:text-emerald-400">
                      Colors: {example.colors}
                    </div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* How It Works */}
        <section id="how-it-works" className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  How AI Outfit Recommendations Work
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  From wardrobe to daily suggestions in four simple steps
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              {[
                {
                  step: '01',
                  icon: Shirt,
                  title: 'Digitize Wardrobe',
                  description: 'Upload your clothes to create a digital inventory the AI can work with.',
                },
                {
                  step: '02',
                  icon: Heart,
                  title: 'Set Preferences',
                  description: 'Tell us your style, favorite colors, and items you love or want to avoid.',
                },
                {
                  step: '03',
                  icon: CloudSun,
                  title: 'Connect Data',
                  description: 'Link your calendar and location for weather-aware, occasion-appropriate suggestions.',
                },
                {
                  step: '04',
                  icon: Sparkles,
                  title: 'Get Suggestions',
                  description: 'Receive personalized outfit recommendations every morning for your day ahead.',
                },
              ].map((item, index) => (
                <AnimatedSection key={item.title} delay={index * 150}>
                  <div className="relative">
                    <div className="text-6xl font-bold text-emerald-100 dark:text-emerald-900/30 mb-4">
                      {item.step}
                    </div>
                    <div className="w-12 h-12 bg-emerald-600 dark:bg-emerald-500 rounded-lg flex items-center justify-center mb-4 -mt-8 ml-8">
                      <item.icon className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                      {item.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400">
                      {item.description}
                    </p>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Benefits Section */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-gray-50 to-emerald-50 dark:from-gray-900 dark:to-emerald-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <AnimatedSection>
                <div>
                  <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                    Why Use AI for Outfit Recommendations?
                  </h2>
                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                    Stop staring at your closet every morning. Let AI do the thinking and start your day with confidence.
                  </p>

                  <div className="space-y-4">
                    {benefits.map((benefit, index) => (
                      <div key={index} className="flex items-start gap-4">
                        <div className="w-6 h-6 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <Check className="w-4 h-4 text-green-600 dark:text-green-400" />
                        </div>
                        <span className="text-gray-700 dark:text-gray-300">{benefit}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </AnimatedSection>

              <AnimatedSection delay={200}>
                <div className="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <Clock className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">Morning Routine</h3>
                  </div>

                  <div className="space-y-4">
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 flex items-center gap-4">
                      <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center font-bold">
                        1
                      </div>
                      <div>
                        <p className="font-semibold">Open FitCheck AI</p>
                        <p className="text-sm text-emerald-100">30 seconds</p>
                      </div>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 flex items-center gap-4">
                      <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center font-bold">
                        2
                      </div>
                      <div>
                        <p className="font-semibold">View AI Suggestions</p>
                        <p className="text-sm text-emerald-100">1 minute</p>
                      </div>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 flex items-center gap-4">
                      <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center font-bold">
                        3
                      </div>
                      <div>
                        <p className="font-semibold">Get Dressed</p>
                        <p className="text-sm text-emerald-100">5 minutes</p>
                      </div>
                    </div>
                  </div>

                  <div className="mt-6 pt-6 border-t border-white/20 text-center">
                    <span className="text-4xl font-bold">6.5 minutes</span>
                    <p className="text-emerald-100">Total morning routine vs. 15+ minutes without AI</p>
                  </div>
                </div>
              </AnimatedSection>
            </div>
          </div>
        </section>

        {/* Related Features */}
        <section className="py-20 md:py-28 bg-gray-50 dark:bg-gray-900">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Complete Your Style Experience
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Outfit recommendations work seamlessly with these powerful features
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {relatedFeatures.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <Link
                    to={feature.link}
                    className="group block bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-emerald-200 dark:hover:border-emerald-800"
                  >
                    <div className="w-14 h-14 bg-emerald-100 dark:bg-emerald-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-emerald-600 dark:text-emerald-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-emerald-600 dark:group-hover:text-emerald-400 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {feature.description}
                    </p>
                    <span className="inline-flex items-center text-emerald-600 dark:text-emerald-400 font-medium">
                      Learn more
                      <ArrowRight className="w-4 h-4 ml-2 transform group-hover:translate-x-1 transition-transform" />
                    </span>
                  </Link>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-emerald-600 to-teal-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
                Never wonder what to wear again
              </h2>
              <p className="text-xl text-emerald-100 mb-10 max-w-2xl mx-auto">
                Join thousands who start their day with AI-powered outfit suggestions. Save time, reduce stress, and look your best every day.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link
                  to="/auth/register"
                  className="inline-flex items-center justify-center gap-2 bg-white text-emerald-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                >
                  Get Free Recommendations
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
              <p className="text-emerald-200 mt-6 text-sm">
                Free plan includes 10 AI recommendations per day. No credit card required.
              </p>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
