import { Link } from 'react-router-dom'
// Layout provided by parent route in App.tsx
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, HowToJsonLd } from '@/components/seo/JsonLd'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  Camera,
  Sparkles,
  Tags,
  Palette,
  Shirt,
  Check,
  ArrowRight,
  Clock,
  BarChart3,
  Zap,
  Layers,
  Search,
  Bookmark,
  Smartphone,
} from 'lucide-react'

export default function AIWardrobeExtractionPage() {
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Features', url: 'https://fitcheckaiapp.com/features' },
    { name: 'AI Wardrobe Extraction', url: 'https://fitcheckaiapp.com/features/ai-wardrobe-extraction' },
  ]

  // HowTo schema for wardrobe extraction tutorial
  const howToSchema = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: 'How to Organize Your Wardrobe with AI',
    description: 'Learn how to digitize your entire wardrobe in minutes using AI-powered clothing recognition and cataloging.',
    totalTime: 'PT15M',
    estimatedCost: {
      '@type': 'MonetaryAmount',
      currency: 'USD',
      value: '0',
    },
    supply: [
      { '@type': 'HowToSupply', name: 'Smartphone or camera' },
      { '@type': 'HowToSupply', name: 'Good lighting source' },
      { '@type': 'HowToSupply', name: 'Clean background (optional)' },
    ],
    tool: [
      { '@type': 'HowToTool', name: 'FitCheck AI app' },
    ],
    step: [
      {
        '@type': 'HowToStep',
        position: 1,
        name: 'Gather Your Clothes',
        text: 'Collect 10-20 items you want to catalog. Group similar items together for faster processing.',
        url: 'https://fitcheckaiapp.com/features/ai-wardrobe-extraction#step-1',
      },
      {
        '@type': 'HowToStep',
        position: 2,
        name: 'Photograph Your Items',
        text: 'Use natural lighting and photograph items flat on a neutral background. Include multiple angles for complex items.',
        url: 'https://fitcheckaiapp.com/features/ai-wardrobe-extraction#step-2',
      },
      {
        '@type': 'HowToStep',
        position: 3,
        name: 'Upload to FitCheck AI',
        text: 'Upload photos to the app. Our AI automatically detects items, extracts colors, identifies categories, and recognizes brands.',
        url: 'https://fitcheckaiapp.com/features/ai-wardrobe-extraction#step-3',
      },
      {
        '@type': 'HowToStep',
        position: 4,
        name: 'Review and Refine',
        text: 'Review AI-generated details and make any adjustments. Add personal notes, purchase info, and care instructions.',
        url: 'https://fitcheckaiapp.com/features/ai-wardrobe-extraction#step-4',
      },
    ],
  }

  const features = [
    {
      icon: Camera,
      title: 'Multi-Item Detection',
      description: 'Upload group photos and our AI separates individual items automatically. Perfect for flat lays and closet shots.',
    },
    {
      icon: Palette,
      title: 'Color Extraction',
      description: 'Advanced computer vision identifies primary and secondary colors across 60+ color palettes with precision accuracy.',
    },
    {
      icon: Tags,
      title: 'Smart Categorization',
      description: 'AI automatically sorts items into categories: tops, bottoms, shoes, accessories, outerwear, and more.',
    },
    {
      icon: Search,
      title: 'Brand Recognition',
      description: 'Detects visible brand logos and labels, making it easy to track your favorite designers and retailers.',
    },
    {
      icon: Sparkles,
      title: 'Style Tagging',
      description: 'Suggests style tags based on design elements, patterns, and current fashion trends.',
    },
    {
      icon: Shirt,
      title: 'Material Detection',
      description: 'Identifies fabric types like cotton, silk, denim, leather, and more from visual texture analysis.',
    },
  ]

  const benefits = [
    'Save 5+ hours compared to manual wardrobe cataloging',
    '95%+ accuracy in item recognition and categorization',
    'Automatic cost-per-wear tracking for smart shopping',
    'Discover forgotten pieces in your wardrobe',
    'Plan outfits faster with complete wardrobe visibility',
    'Identify gaps in your wardrobe for smarter purchases',
  ]

  const relatedFeatures = [
    {
      title: 'Virtual Try-On',
      description: 'See how any outfit looks on you before wearing it.',
      link: '/features/virtual-try-on',
      icon: Smartphone,
    },
    {
      title: 'Outfit Recommendations',
      description: 'Get AI-powered outfit suggestions based on your style.',
      link: '/features/outfit-recommendations',
      icon: Sparkles,
    },
    {
      title: 'Wardrobe Analytics',
      description: 'Track usage, cost-per-wear, and wardrobe insights.',
      link: '/features/wardrobe-analytics',
      icon: BarChart3,
    },
  ]

  return (
    <>
      <SEO
        title="AI Wardrobe Extraction | Digitize Your Closet in Minutes | FitCheck AI"
        description="Transform your wardrobe with AI-powered clothing recognition. Upload photos and automatically catalog items with colors, categories, brands & materials detected."
        canonicalUrl="https://fitcheckaiapp.com/features/ai-wardrobe-extraction"
        ogType="article"
        jsonLd={howToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />
      <HowToJsonLd {...howToSchema} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 dark:from-indigo-950 dark:via-purple-950 dark:to-pink-950">
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
                  AI-Powered Technology
                </div>

                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                  AI Wardrobe Extraction
                </h1>

                <p className="text-xl md:text-2xl text-indigo-100 mb-4 max-w-3xl mx-auto">
                  Transform Your Closet with AI-Powered Clothing Recognition
                </p>

                <p className="text-lg text-indigo-200 mb-10 max-w-2xl mx-auto">
                  Upload photos and automatically catalog your entire wardrobe. Our AI detects items,
                  extracts colors, identifies categories, and recognizes brands—in minutes, not hours.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    to="/auth/register"
                    className="inline-flex items-center justify-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                  >
                    Try Free
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
                { value: '95%+', label: 'AI Accuracy' },
                { value: '60+', label: 'Color Palettes' },
                { value: '5hrs', label: 'Time Saved' },
                { value: '10x', label: 'Faster Than Manual' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="text-center">
                    <div className="text-3xl md:text-4xl font-bold text-indigo-600 dark:text-indigo-400 mb-2">
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
                  Intelligent Wardrobe Recognition
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Our advanced AI does the heavy lifting, automatically identifying and cataloging every detail of your clothing.
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <div className="group p-8 bg-gray-50 dark:bg-gray-900 rounded-2xl hover:bg-indigo-50 dark:hover:bg-indigo-950/30 transition-all duration-300 hover:shadow-lg border border-gray-100 dark:border-gray-800 hover:border-indigo-200 dark:hover:border-indigo-800">
                    <div className="w-14 h-14 bg-indigo-100 dark:bg-indigo-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-indigo-600 dark:text-indigo-400" />
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

        {/* How It Works Section */}
        <section id="how-it-works" className="py-20 md:py-28 bg-gradient-to-br from-gray-50 to-indigo-50 dark:from-gray-900 dark:to-indigo-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  How AI Wardrobe Extraction Works
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  From photos to organized wardrobe in four simple steps
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              {[
                {
                  step: '01',
                  icon: Layers,
                  title: 'Gather Items',
                  description: 'Collect 10-20 items. Group similar pieces together for efficient batch processing.',
                },
                {
                  step: '02',
                  icon: Camera,
                  title: 'Take Photos',
                  description: 'Use natural light on a neutral background. Photograph items flat or hanging.',
                },
                {
                  step: '03',
                  icon: Zap,
                  title: 'AI Processing',
                  description: 'Our AI analyzes each image, extracting colors, categories, brands, and materials.',
                },
                {
                  step: '04',
                  icon: Bookmark,
                  title: 'Review & Save',
                  description: 'Review AI-generated details, make adjustments, and add to your digital wardrobe.',
                },
              ].map((item, index) => (
                <AnimatedSection key={item.title} delay={index * 150}>
                  <div className="relative">
                    <div className="text-6xl font-bold text-indigo-100 dark:text-indigo-900/30 mb-4">
                      {item.step}
                    </div>
                    <div className="w-12 h-12 bg-indigo-600 dark:bg-indigo-500 rounded-lg flex items-center justify-center mb-4 -mt-8 ml-8">
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
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <AnimatedSection>
                <div>
                  <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                    Why Use AI for Wardrobe Organization?
                  </h2>
                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                    Manual wardrobe cataloging takes hours and is prone to errors. Our AI technology makes it effortless while delivering insights you never knew you needed.
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
                <div className="bg-gradient-to-br from-indigo-500 to-purple-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <Clock className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">Time Comparison</h3>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="flex justify-between items-center mb-2">
                        <span className="text-indigo-100">Manual Entry</span>
                        <span className="text-2xl font-bold">5+ hours</span>
                      </div>
                      <div className="w-full bg-white/20 rounded-full h-2">
                        <div className="bg-white/40 rounded-full h-2 w-full" />
                      </div>
                      <p className="text-sm text-indigo-200 mt-2">For 100 items: photograph, categorize, tag, measure</p>
                    </div>

                    <div className="bg-white/20 backdrop-blur-sm rounded-xl p-6 border-2 border-white/30">
                      <div className="flex justify-between items-center mb-2">
                        <span className="font-semibold">FitCheck AI</span>
                        <span className="text-3xl font-bold">15 minutes</span>
                      </div>
                      <div className="w-full bg-white/30 rounded-full h-2">
                        <div className="bg-white rounded-full h-2 w-1/12" />
                      </div>
                      <p className="text-sm text-indigo-100 mt-2">Upload photos, AI handles everything automatically</p>
                    </div>
                  </div>

                  <div className="mt-6 text-center">
                    <span className="text-4xl font-bold">20x faster</span>
                    <p className="text-indigo-100">with AI-powered extraction</p>
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
                  Complete Your Wardrobe Experience
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  AI wardrobe extraction works seamlessly with these powerful features
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {relatedFeatures.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <Link
                    to={feature.link}
                    className="group block bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-indigo-200 dark:hover:border-indigo-800"
                  >
                    <div className="w-14 h-14 bg-indigo-100 dark:bg-indigo-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-indigo-600 dark:text-indigo-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {feature.description}
                    </p>
                    <span className="inline-flex items-center text-indigo-600 dark:text-indigo-400 font-medium">
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
        <section className="py-20 md:py-28 bg-gradient-to-br from-indigo-600 to-purple-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
                Ready to digitize your wardrobe?
              </h2>
              <p className="text-xl text-indigo-100 mb-10 max-w-2xl mx-auto">
                Join thousands who have transformed their closets with AI. Start cataloging your wardrobe in minutes, not hours.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link
                  to="/auth/register"
                  className="inline-flex items-center justify-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                >
                  Start Free Today
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
              <p className="text-indigo-200 mt-6 text-sm">
                No credit card required. Free plan includes 50 AI extractions per month.
              </p>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
