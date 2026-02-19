import { Link } from 'react-router-dom'
// Layout provided by parent route in App.tsx
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, HowToJsonLd } from '@/components/seo/JsonLd'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  BarChart3,
  DollarSign,
  TrendingUp,
  PieChart,
  Clock,
  Target,
  Check,
  ArrowRight,
  Shirt,
  Calendar,
  Wallet,
  ShoppingBag,
  AlertCircle,
  Smartphone,
  Camera,
  Wand2,
} from 'lucide-react'

export default function WardrobeAnalyticsPage() {
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Features', url: 'https://fitcheckaiapp.com/features' },
    { name: 'Wardrobe Analytics', url: 'https://fitcheckaiapp.com/features/wardrobe-analytics' },
  ]

  // HowTo schema for calculating cost-per-wear
  const howToSchema = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: 'How to Calculate and Track Cost-Per-Wear',
    description: 'Learn how to calculate cost-per-wear for your clothing items and use wardrobe analytics to make smarter purchasing decisions.',
    totalTime: 'PT10M',
    estimatedCost: {
      '@type': 'MonetaryAmount',
      currency: 'USD',
      value: '0',
    },
    supply: [
      { '@type': 'HowToSupply', name: 'Purchase prices of your clothing items' },
      { '@type': 'HowToSupply', name: 'Wear tracking data' },
    ],
    tool: [
      { '@type': 'HowToTool', name: 'FitCheck AI Wardrobe Analytics' },
    ],
    step: [
      {
        '@type': 'HowToStep',
        position: 1,
        name: 'Catalog Your Wardrobe',
        text: 'Upload your clothes to FitCheck AI with purchase information including price and date.',
        url: 'https://fitcheckaiapp.com/features/wardrobe-analytics#step-1',
      },
      {
        '@type': 'HowToStep',
        position: 2,
        name: 'Track Your Wears',
        text: 'Log each time you wear an item using the app. This can be done manually or automatically.',
        url: 'https://fitcheckaiapp.com/features/wardrobe-analytics#step-2',
      },
      {
        '@type': 'HowToStep',
        position: 3,
        name: 'View Analytics Dashboard',
        text: 'Access your personal dashboard showing cost-per-wear, wear frequency, and wardrobe insights.',
        url: 'https://fitcheckaiapp.com/features/wardrobe-analytics#step-3',
      },
      {
        '@type': 'HowToStep',
        position: 4,
        name: 'Make Data-Driven Decisions',
        text: 'Use insights to identify best value pieces, underutilized items, and smart future purchases.',
        url: 'https://fitcheckaiapp.com/features/wardrobe-analytics#step-4',
      },
    ],
  }

  const features = [
    {
      icon: DollarSign,
      title: 'Cost-Per-Wear Tracking',
      description: 'Automatically calculate CPW for every item. Understand the true value of your clothing investments.',
    },
    {
      icon: BarChart3,
      title: 'Wear Frequency Analysis',
      description: 'See which items you wear most and which are just taking up space in your closet.',
    },
    {
      icon: PieChart,
      title: 'Category Breakdown',
      description: 'Visualize your wardrobe composition by category, color, style, and season.',
    },
    {
      icon: TrendingUp,
      title: 'Spending Insights',
      description: 'Track your clothing expenses over time and identify shopping patterns.',
    },
    {
      icon: Target,
      title: 'Wardrobe Goals',
      description: 'Set targets for cost-per-wear and get alerts when items reach optimal value.',
    },
    {
      icon: Clock,
      title: 'Seasonal Analytics',
      description: 'Analyze seasonal usage patterns to optimize your year-round wardrobe.',
    },
  ]

  const benefits = [
    'Identify which pieces give you the best value per dollar spent',
    'Discover forgotten items you should wear more often',
    'Make informed decisions before purchasing new clothes',
    'Reduce impulse purchases by understanding your patterns',
    'Optimize your closet space by identifying unworn items',
    'Build a more sustainable wardrobe with data-driven choices',
  ]

  const insights = [
    {
      title: 'Top Value Pieces',
      description: 'Items with the lowest cost-per-wear that should be your go-to favorites.',
      icon: TrendingUp,
      example: 'Your black blazer at $0.50 per wear',
    },
    {
      title: 'Underutilized Items',
      description: 'Pieces you own but rarely wear that deserve more attention.',
      icon: AlertCircle,
      example: 'That dress you have worn only once',
    },
    {
      title: 'Shopping Recommendations',
      description: 'Data-driven suggestions for what would add the most value to your wardrobe.',
      icon: ShoppingBag,
      example: 'You need more navy pieces to balance your wardrobe',
    },
    {
      title: 'Wardrobe Efficiency',
      description: 'Overall metrics on how well you utilize your existing clothing.',
      icon: Target,
      example: 'You wear 20% of your wardrobe 80% of the time',
    },
  ]

  const relatedFeatures = [
    {
      title: 'AI Wardrobe Extraction',
      description: 'Digitize your closet so analytics can track every item you own.',
      link: '/features/ai-wardrobe-extraction',
      icon: Camera,
    },
    {
      title: 'Virtual Try-On',
      description: 'Test potential purchases to maximize value before buying.',
      link: '/features/virtual-try-on',
      icon: Smartphone,
    },
    {
      title: 'Outfit Recommendations',
      description: 'Get suggestions that help you wear underutilized items more.',
      link: '/features/outfit-recommendations',
      icon: Wand2,
    },
  ]

  return (
    <>
      <SEO
        title="Wardrobe Analytics | Cost-Per-Wear Tracker | FitCheck AI"
        description="Track cost-per-wear, analyze wardrobe usage, and get data-driven insights to build a smarter, more valuable closet. Make informed fashion decisions."
        canonicalUrl="https://fitcheckaiapp.com/features/wardrobe-analytics"
        ogType="article"
        jsonLd={howToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />
      <HowToJsonLd {...howToSchema} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-sky-600 via-blue-600 to-indigo-600 dark:from-sky-950 dark:via-blue-950 dark:to-indigo-950">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-20 right-10 w-72 h-72 bg-white rounded-full blur-3xl" />
            <div className="absolute bottom-20 left-10 w-96 h-96 bg-white rounded-full blur-3xl" />
          </div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
            <AnimatedSection>
              <div className="text-center max-w-4xl mx-auto">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium mb-6">
                  <BarChart3 className="w-4 h-4" />
                  Data-Driven Fashion
                </div>

                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                  Wardrobe Analytics
                </h1>

                <p className="text-xl md:text-2xl text-blue-100 mb-4 max-w-3xl mx-auto">
                  Understand Your Closet Like Never Before
                </p>

                <p className="text-lg text-blue-200 mb-10 max-w-2xl mx-auto">
                  Track cost-per-wear, analyze usage patterns, and get actionable insights to build a smarter,
                  more valuable wardrobe. Turn your closet into a data-driven investment.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    to="/auth/register"
                    className="inline-flex items-center justify-center gap-2 bg-white text-blue-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                  >
                    Analyze My Wardrobe
                    <ArrowRight className="w-5 h-5" />
                  </Link>
                  <Link
                    to="#how-it-works"
                    className="inline-flex items-center justify-center gap-2 bg-white/10 backdrop-blur-sm text-white px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/20 transition-all"
                  >
                    Learn How It Works
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
                { value: '$0.50', label: 'Avg. CPW Goal' },
                { value: '80/20', label: 'Rule Visible' },
                { value: '$2,400', label: 'Potential Savings' },
                { value: '100%', label: 'Your Data' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="text-center">
                    <div className="text-3xl md:text-4xl font-bold text-blue-600 dark:text-blue-400 mb-2">
                      {stat.value}
                    </div>
                    <div className="text-gray-600 dark:text-gray-400">{stat.label}</div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* What is Cost-Per-Wear */}
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <AnimatedSection>
                <div>
                  <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-100 dark:bg-blue-900/30 rounded-full text-blue-700 dark:text-blue-300 text-sm font-medium mb-4">
                    <DollarSign className="w-4 h-4" />
                    Smart Shopping Metric
                  </div>

                  <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                    What is Cost-Per-Wear?
                  </h2>

                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-6">
                    Cost-per-wear (CPW) is a simple formula that reveals the true value of your clothing:
                    <strong> Purchase Price ÷ Number of Wears</strong>.
                  </p>

                  <div className="bg-gray-50 dark:bg-gray-900 rounded-2xl p-6 mb-6">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-4">Example Comparison:</h3>
                    <div className="space-y-4">
                      <div className="flex justify-between items-center p-4 bg-red-50 dark:bg-red-900/20 rounded-xl">
                        <div>
                          <p className="font-medium text-gray-900 dark:text-white">$25 fast fashion top</p>
                          <p className="text-sm text-gray-600 dark:text-gray-400">Worn 3 times</p>
                        </div>
                        <div className="text-right">
                          <p className="text-xl font-bold text-red-600 dark:text-red-400">$8.33</p>
                          <p className="text-xs text-gray-500">per wear</p>
                        </div>
                      </div>

                      <div className="flex justify-between items-center p-4 bg-green-50 dark:bg-green-900/20 rounded-xl">
                        <div>
                          <p className="font-medium text-gray-900 dark:text-white">$150 quality blazer</p>
                          <p className="text-sm text-gray-600 dark:text-gray-400">Worn 100 times</p>
                        </div>
                        <div className="text-right">
                          <p className="text-xl font-bold text-green-600 dark:text-green-400">$1.50</p>
                          <p className="text-xs text-gray-500">per wear</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <p className="text-gray-600 dark:text-gray-400">
                    The &quot;expensive&quot; blazer actually costs 5x less per wear than the &quot;cheap&quot; top.
                    Wardrobe analytics helps you identify these patterns and make smarter investments.
                  </p>
                </div>
              </AnimatedSection>

              <AnimatedSection delay={200}>
                <div className="bg-gradient-to-br from-blue-500 to-indigo-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <Calculator className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">CPW Calculator</h3>
                  </div>

                  <div className="space-y-6">
                    <div>
                      <label className="block text-blue-100 text-sm mb-2">Purchase Price</label>
                      <div className="text-3xl font-bold">$150</div>
                    </div>

                    <div>
                      <label className="block text-blue-100 text-sm mb-2">Times Worn</label>
                      <div className="text-3xl font-bold">100</div>
                    </div>

                    <div className="pt-6 border-t border-white/20">
                      <label className="block text-blue-100 text-sm mb-2">Cost Per Wear</label>
                      <div className="text-5xl font-bold">$1.50</div>
                      <p className="text-blue-200 mt-2">Excellent value! Under $2 per wear.</p>
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            </div>
          </div>
        </section>

        {/* Features Grid */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-gray-50 to-blue-50 dark:from-gray-900 dark:to-blue-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Powerful Wardrobe Insights
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Comprehensive analytics to help you understand, optimize, and improve your wardrobe
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <div className="group p-8 bg-white dark:bg-gray-800 rounded-2xl hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-blue-200 dark:hover:border-blue-800">
                    <div className="w-14 h-14 bg-blue-100 dark:bg-blue-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-blue-600 dark:text-blue-400" />
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

        {/* Insights Preview */}
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Insights That Transform Your Wardrobe
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Discover actionable intelligence about your clothing habits and wardrobe value
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 gap-8">
              {insights.map((insight, index) => (
                <AnimatedSection key={insight.title} delay={index * 100}>
                  <div className="flex gap-6 p-8 bg-gray-50 dark:bg-gray-900 rounded-2xl border border-gray-100 dark:border-gray-800">
                    <div className="w-16 h-16 bg-blue-100 dark:bg-blue-900/50 rounded-xl flex items-center justify-center flex-shrink-0">
                      <insight.icon className="w-8 h-8 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                        {insight.title}
                      </h3>
                      <p className="text-gray-600 dark:text-gray-400 mb-3">
                        {insight.description}
                      </p>
                      <p className="text-sm text-blue-600 dark:text-blue-400 font-medium">
                        Example: {insight.example}
                      </p>
                    </div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* How It Works */}
        <section id="how-it-works" className="py-20 md:py-28 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-900 dark:to-blue-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  How Wardrobe Analytics Works
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  From data collection to actionable insights in four simple steps
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              {[
                {
                  step: '01',
                  icon: Shirt,
                  title: 'Catalog Items',
                  description: 'Add your clothes with purchase details like price, date, and store.',
                },
                {
                  step: '02',
                  icon: Calendar,
                  title: 'Track Wears',
                  description: 'Log each wear or let our AI estimate based on your usage patterns.',
                },
                {
                  step: '03',
                  icon: BarChart3,
                  title: 'View Dashboard',
                  description: 'Access real-time analytics showing CPW, trends, and insights.',
                },
                {
                  step: '04',
                  icon: Target,
                  title: 'Optimize Wardrobe',
                  description: 'Make data-driven decisions to improve your closet value over time.',
                },
              ].map((item, index) => (
                <AnimatedSection key={item.title} delay={index * 150}>
                  <div className="relative">
                    <div className="text-6xl font-bold text-blue-100 dark:text-blue-900/30 mb-4">
                      {item.step}
                    </div>
                    <div className="w-12 h-12 bg-blue-600 dark:bg-blue-500 rounded-lg flex items-center justify-center mb-4 -mt-8 ml-8">
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
                    Why Track Wardrobe Analytics?
                  </h2>
                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                    Knowledge is power. Understanding your wardrobe data helps you shop smarter, dress better, and save money.
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
                <div className="bg-gradient-to-br from-blue-500 to-indigo-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <Wallet className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">Real User Savings</h3>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">$2,400/year</div>
                      <p className="text-blue-100">Average savings by reducing impulse purchases</p>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">30%</div>
                      <p className="text-blue-100">Reduction in wardrobe spending with data insights</p>
                    </div>

                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="text-4xl font-bold mb-2">2x</div>
                      <p className="text-blue-100">More wears per item after optimization</p>
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
                  Complete Your Wardrobe Toolkit
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Analytics works seamlessly with these powerful features
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {relatedFeatures.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <Link
                    to={feature.link}
                    className="group block bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-blue-200 dark:hover:border-blue-800"
                  >
                    <div className="w-14 h-14 bg-blue-100 dark:bg-blue-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-blue-600 dark:text-blue-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {feature.description}
                    </p>
                    <span className="inline-flex items-center text-blue-600 dark:text-blue-400 font-medium">
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
        <section className="py-20 md:py-28 bg-gradient-to-br from-blue-600 to-indigo-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
                Turn your closet into a data-driven investment
              </h2>
              <p className="text-xl text-blue-100 mb-10 max-w-2xl mx-auto">
                Join thousands using wardrobe analytics to shop smarter, save money, and build a more valuable closet.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link
                  to="/auth/register"
                  className="inline-flex items-center justify-center gap-2 bg-white text-blue-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                >
                  Start Tracking Analytics
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
              <p className="text-blue-200 mt-6 text-sm">
                Free plan includes full analytics dashboard. No credit card required.
              </p>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}

// Calculator icon component
function Calculator({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="4" y="2" width="16" height="20" rx="2" />
      <line x1="8" y1="6" x2="16" y2="6" />
      <line x1="8" y1="10" x2="8" y2="10.01" />
      <line x1="12" y1="10" x2="12" y2="10.01" />
      <line x1="16" y1="10" x2="16" y2="10.01" />
      <line x1="8" y1="14" x2="8" y2="14.01" />
      <line x1="12" y1="14" x2="12" y2="14.01" />
      <line x1="16" y1="14" x2="16" y2="14.01" />
      <line x1="8" y1="18" x2="8" y2="18.01" />
      <line x1="12" y1="18" x2="12" y2="18.01" />
      <line x1="16" y1="18" x2="16" y2="18.01" />
    </svg>
  )
}
