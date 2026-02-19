import { Link } from 'react-router-dom'
// Layout provided by parent route in App.tsx
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, HowToJsonLd } from '@/components/seo/JsonLd'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  Smartphone,
  Sparkles,
  User,
  Eye,
  Shirt,
  Check,
  ArrowRight,
  Layers,
  Zap,
  RefreshCw,
  Clock,
  ShoppingBag,
  Heart,
  Camera,
  Palette,
  Wand2,
} from 'lucide-react'

export default function VirtualTryOnPage() {
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Features', url: 'https://fitcheckaiapp.com/features' },
    { name: 'Virtual Try-On', url: 'https://fitcheckaiapp.com/features/virtual-try-on' },
  ]

  // HowTo schema for virtual try-on tutorial
  const howToSchema = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: 'How to Use Virtual Try-On to See Outfits on Yourself',
    description: 'Learn how to visualize any outfit on your body using AI-powered virtual try-on technology before getting dressed or buying new clothes.',
    totalTime: 'PT5M',
    estimatedCost: {
      '@type': 'MonetaryAmount',
      currency: 'USD',
      value: '0',
    },
    supply: [
      { '@type': 'HowToSupply', name: 'Reference photos of yourself' },
      { '@type': 'HowToSupply', name: 'Clothing items to try on' },
    ],
    tool: [
      { '@type': 'HowToTool', name: 'FitCheck AI app' },
    ],
    step: [
      {
        '@type': 'HowToStep',
        position: 1,
        name: 'Upload Your Photos',
        text: 'Upload 1-4 clear photos of yourself. Use good lighting and show your full body or upper body clearly.',
        url: 'https://fitcheckaiapp.com/features/virtual-try-on#step-1',
      },
      {
        '@type': 'HowToStep',
        position: 2,
        name: 'Select Clothing Items',
        text: 'Choose items from your digital wardrobe or upload new pieces you want to try on virtually.',
        url: 'https://fitcheckaiapp.com/features/virtual-try-on#step-2',
      },
      {
        '@type': 'HowToStep',
        position: 3,
        name: 'AI Generates Visualization',
        text: 'Our AI analyzes your body shape, skin tone, and features, then generates realistic images of you wearing the selected outfit.',
        url: 'https://fitcheckaiapp.com/features/virtual-try-on#step-3',
      },
      {
        '@type': 'HowToStep',
        position: 4,
        name: 'Review and Decide',
        text: 'See how the outfit looks on your actual body. Save favorites, mix and match, or decide what to purchase with confidence.',
        url: 'https://fitcheckaiapp.com/features/virtual-try-on#step-4',
      },
    ],
  }

  const features = [
    {
      icon: User,
      title: 'Identity Preservation',
      description: 'Advanced AI maintains your face, hair, and unique features while changing only your clothing.',
    },
    {
      icon: Layers,
      title: 'Realistic Fabric Draping',
      description: 'See how fabrics actually drape and fold on your specific body shape with physics-accurate rendering.',
    },
    {
      icon: Palette,
      title: 'Accurate Color Representation',
      description: 'True-to-life color rendering shows exactly how garments will look in different lighting conditions.',
    },
    {
      icon: Eye,
      title: 'Multiple Angles',
      description: 'Generate front, side, and back views to see outfits from every perspective before deciding.',
    },
    {
      icon: Zap,
      title: 'Instant Results',
      description: 'Get virtual try-on images in seconds. No waiting for slow rendering or complex setup.',
    },
    {
      icon: Sparkles,
      title: 'Style Mixing',
      description: 'Combine tops, bottoms, and accessories from your wardrobe to create complete looks virtually.',
    },
  ]

  const benefits = [
    'Reduce return rates by up to 40% when shopping online',
    'Save time trying on multiple physical outfits',
    'Visualize new purchases with clothes you already own',
    'Plan outfits for special events with confidence',
    'Discover new combinations from your existing wardrobe',
    'Share virtual looks with friends for instant feedback',
  ]

  const useCases = [
    {
      title: 'Online Shopping',
      description: 'See how items will look on you before buying. Reduce returns and shop with confidence.',
      icon: ShoppingBag,
    },
    {
      title: 'Daily Outfit Planning',
      description: 'Plan your look for the day without changing clothes multiple times.',
      icon: Clock,
    },
    {
      title: 'Special Events',
      description: 'Perfect your outfit for weddings, interviews, dates, and important meetings.',
      icon: Sparkles,
    },
    {
      title: 'Wardrobe Optimization',
      description: 'Identify which pieces work together and spot gaps in your wardrobe.',
      icon: Heart,
    },
  ]

  const relatedFeatures = [
    {
      title: 'AI Wardrobe Extraction',
      description: 'Digitize your closet so you can try on anything you own virtually.',
      link: '/features/ai-wardrobe-extraction',
      icon: Camera,
    },
    {
      title: 'Outfit Recommendations',
      description: 'Get AI-suggested outfits tailored to your style and occasion.',
      link: '/features/outfit-recommendations',
      icon: Wand2,
    },
    {
      title: 'AI Photoshoot Generator',
      description: 'Create professional photos of yourself in various outfits.',
      link: '/features/ai-photoshoot-generator',
      icon: Sparkles,
    },
  ]

  return (
    <>
      <SEO
        title="Virtual Try-On | See Clothes on Yourself Before Buying | FitCheck AI"
        description="Experience AI-powered virtual try-on technology. See how any outfit looks on your body before purchasing or getting dressed. Save time and reduce returns."
        canonicalUrl="https://fitcheckaiapp.com/features/virtual-try-on"
        ogType="article"
        jsonLd={howToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />
      <HowToJsonLd {...howToSchema} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-violet-600 via-purple-600 to-fuchsia-500 dark:from-violet-950 dark:via-purple-950 dark:to-fuchsia-950">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-20 right-10 w-72 h-72 bg-white rounded-full blur-3xl" />
            <div className="absolute bottom-20 left-10 w-96 h-96 bg-white rounded-full blur-3xl" />
          </div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
            <AnimatedSection>
              <div className="text-center max-w-4xl mx-auto">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium mb-6">
                  <Smartphone className="w-4 h-4" />
                  Virtual Fitting Room
                </div>

                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                  Virtual Try-On
                </h1>

                <p className="text-xl md:text-2xl text-purple-100 mb-4 max-w-3xl mx-auto">
                  See How Any Outfit Looks on You Before Getting Dressed
                </p>

                <p className="text-lg text-purple-200 mb-10 max-w-2xl mx-auto">
                  AI-powered virtual fitting room technology lets you visualize clothes on your body.
                  Try before you buy, plan outfits effortlessly, and never wonder "what if" again.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    to="/auth/register"
                    className="inline-flex items-center justify-center gap-2 bg-white text-purple-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                  >
                    Try It Free
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
                { value: '40%', label: 'Fewer Returns' },
                { value: '3x', label: 'Faster Decisions' },
                { value: '95%', label: 'Accuracy' },
                { value: '24/7', label: 'Available' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="text-center">
                    <div className="text-3xl md:text-4xl font-bold text-purple-600 dark:text-purple-400 mb-2">
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
                  Advanced Virtual Fitting Technology
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Our AI doesn't just overlay clothes—it understands your body, preserves your identity, and generates photorealistic visualizations.
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <div className="group p-8 bg-gray-50 dark:bg-gray-900 rounded-2xl hover:bg-purple-50 dark:hover:bg-purple-950/30 transition-all duration-300 hover:shadow-lg border border-gray-100 dark:border-gray-800 hover:border-purple-200 dark:hover:border-purple-800">
                    <div className="w-14 h-14 bg-purple-100 dark:bg-purple-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-purple-600 dark:text-purple-400" />
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

        {/* How It Works */}
        <section id="how-it-works" className="py-20 md:py-28 bg-gradient-to-br from-purple-50 to-pink-50 dark:from-gray-900 dark:to-purple-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  How Virtual Try-On Works
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  From photo to virtual fitting room in four simple steps
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              {[
                {
                  step: '01',
                  icon: Camera,
                  title: 'Upload Photos',
                  description: 'Upload clear photos of yourself. Good lighting helps the AI understand your features better.',
                },
                {
                  step: '02',
                  icon: Shirt,
                  title: 'Select Items',
                  description: 'Choose clothing from your wardrobe or upload new items you want to try on virtually.',
                },
                {
                  step: '03',
                  icon: RefreshCw,
                  title: 'AI Generation',
                  description: 'Our AI creates realistic images showing how the clothes look on your specific body.',
                },
                {
                  step: '04',
                  icon: Check,
                  title: 'View Results',
                  description: 'See yourself in the outfit from multiple angles. Save, share, or shop with confidence.',
                },
              ].map((item, index) => (
                <AnimatedSection key={item.title} delay={index * 150}>
                  <div className="relative">
                    <div className="text-6xl font-bold text-purple-100 dark:text-purple-900/30 mb-4">
                      {item.step}
                    </div>
                    <div className="w-12 h-12 bg-purple-600 dark:bg-purple-500 rounded-lg flex items-center justify-center mb-4 -mt-8 ml-8">
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

        {/* Use Cases */}
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Perfect For Every Situation
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Virtual try-on helps you make better fashion decisions in countless scenarios
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 gap-8">
              {useCases.map((useCase, index) => (
                <AnimatedSection key={useCase.title} delay={index * 100}>
                  <div className="flex gap-6 p-8 bg-gray-50 dark:bg-gray-900 rounded-2xl border border-gray-100 dark:border-gray-800">
                    <div className="w-16 h-16 bg-purple-100 dark:bg-purple-900/50 rounded-xl flex items-center justify-center flex-shrink-0">
                      <useCase.icon className="w-8 h-8 text-purple-600 dark:text-purple-400" />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                        {useCase.title}
                      </h3>
                      <p className="text-gray-600 dark:text-gray-400">
                        {useCase.description}
                      </p>
                    </div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Benefits Section */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-gray-50 to-purple-50 dark:from-gray-900 dark:to-purple-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <AnimatedSection>
                <div>
                  <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                    Why Virtual Try-On Changes Everything
                  </h2>
                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                    Stop guessing how clothes will look. Our AI-powered virtual fitting room gives you confidence in every fashion decision.
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
                <div className="bg-gradient-to-br from-purple-500 to-pink-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <ShoppingBag className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">Shopping Impact</h3>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">40%</div>
                      <p className="text-purple-100">Reduction in return rates when using virtual try-on</p>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">3x</div>
                      <p className="text-purple-100">Faster purchase decisions with confidence</p>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">$200+</div>
                      <p className="text-purple-100">Average annual savings from fewer returns</p>
                    </div>
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
                  Explore More Features
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Virtual try-on works seamlessly with these powerful tools
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {relatedFeatures.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <Link
                    to={feature.link}
                    className="group block bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-purple-200 dark:hover:border-purple-800"
                  >
                    <div className="w-14 h-14 bg-purple-100 dark:bg-purple-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-purple-600 dark:text-purple-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {feature.description}
                    </p>
                    <span className="inline-flex items-center text-purple-600 dark:text-purple-400 font-medium">
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
        <section className="py-20 md:py-28 bg-gradient-to-br from-purple-600 to-pink-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
                Try before you dress
              </h2>
              <p className="text-xl text-purple-100 mb-10 max-w-2xl mx-auto">
                Join thousands using virtual try-on to shop smarter, dress better, and save time. Your personal fitting room is just a click away.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link
                  to="/auth/register"
                  className="inline-flex items-center justify-center gap-2 bg-white text-purple-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                >
                  Start Free Trial
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
              <p className="text-purple-200 mt-6 text-sm">
                Try 5 virtual outfits free. No credit card required.
              </p>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
