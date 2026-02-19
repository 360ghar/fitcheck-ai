import { Link } from 'react-router-dom'
// Layout provided by parent route in App.tsx
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, HowToJsonLd } from '@/components/seo/JsonLd'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  Camera,
  User,
  Briefcase,
  Heart,
  Star,
  Check,
  ArrowRight,
  DollarSign,
  Zap,
  Shield,
  Palette,
  Share2,
  Download,
  Wand2,
  Smartphone,
} from 'lucide-react'

export default function AIPhotoshootGeneratorPage() {
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Features', url: 'https://fitcheckaiapp.com/features' },
    { name: 'AI Photoshoot Generator', url: 'https://fitcheckaiapp.com/features/ai-photoshoot-generator' },
  ]

  // HowTo schema for LinkedIn photos
  const linkedinHowToSchema = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: 'How to Create Professional LinkedIn Photos with AI',
    description: 'Create studio-quality professional headshots for LinkedIn using AI photoshoot technology. No expensive photographer needed.',
    totalTime: 'PT10M',
    estimatedCost: {
      '@type': 'MonetaryAmount',
      currency: 'USD',
      value: '0',
    },
    supply: [
      { '@type': 'HowToSupply', name: 'Smartphone with camera' },
      { '@type': 'HowToSupply', name: 'Good lighting (natural light or lamp)' },
      { '@type': 'HowToSupply', name: 'Professional attire' },
    ],
    tool: [
      { '@type': 'HowToTool', name: 'FitCheck AI Photoshoot Generator' },
    ],
    step: [
      {
        '@type': 'HowToStep',
        position: 1,
        name: 'Take Reference Photos',
        text: 'Take 1-4 clear selfies with good lighting facing your face. Use a plain background and wear professional attire.',
        url: 'https://fitcheckaiapp.com/features/ai-photoshoot-generator#step-1',
      },
      {
        '@type': 'HowToStep',
        position: 2,
        name: 'Select LinkedIn Style',
        text: 'Choose the "LinkedIn Professional" style option for optimized professional headshot settings.',
        url: 'https://fitcheckaiapp.com/features/ai-photoshoot-generator#step-2',
      },
      {
        '@type': 'HowToStep',
        position: 3,
        name: 'AI Generates Headshots',
        text: 'Our AI creates multiple professional headshot variations with different backgrounds, lighting, and compositions.',
        url: 'https://fitcheckaiapp.com/features/ai-photoshoot-generator#step-3',
      },
      {
        '@type': 'HowToStep',
        position: 4,
        name: 'Download and Use',
        text: 'Select your favorite headshot, download in high resolution, and update your LinkedIn profile.',
        url: 'https://fitcheckaiapp.com/features/ai-photoshoot-generator#step-4',
      },
    ],
  }

  const photoshootStyles = [
    {
      icon: Briefcase,
      title: 'LinkedIn Professional',
      description: 'Studio-quality headshots with neutral backgrounds perfect for professional networking.',
      color: 'blue',
    },
    {
      icon: Heart,
      title: 'Dating Profile',
      description: 'Natural, approachable photos that show your authentic self for dating apps.',
      color: 'pink',
    },
    {
      icon: Star,
      title: 'Instagram Influencer',
      description: 'Trendy, aesthetic shots with stylish backgrounds and professional lighting.',
      color: 'purple',
    },
    {
      icon: Camera,
      title: 'Model Portfolio',
      description: 'High-fashion editorial looks with dramatic lighting and artistic compositions.',
      color: 'amber',
    },
  ]

  const features = [
    {
      icon: User,
      title: 'Identity Preservation',
      description: 'Advanced AI keeps your face, features, and expressions authentic while enhancing the overall image.',
    },
    {
      icon: Palette,
      title: 'Professional Backgrounds',
      description: 'Choose from office settings, gradients, or keep it simple with neutral professional backdrops.',
    },
    {
      icon: Zap,
      title: 'Instant Generation',
      description: 'Get multiple professional photos in minutes, not days. No waiting for photographer editing.',
    },
    {
      icon: Shield,
      title: 'Privacy Protected',
      description: 'Your photos are processed securely and never shared. Full control over your images.',
    },
    {
      icon: Share2,
      title: 'Social Ready',
      description: 'Optimized dimensions and quality for LinkedIn, Instagram, dating apps, and more.',
    },
    {
      icon: Download,
      title: 'High Resolution',
      description: 'Download photos in high resolution suitable for print and all digital platforms.',
    },
  ]

  const benefits = [
    'Save $200-500 compared to traditional professional headshots',
    'Get results in minutes instead of days of waiting',
    'Multiple style options from one photo session',
    'No scheduling or traveling to a studio',
    'Unlimited retakes until you get the perfect shot',
    'Update your look anytime without another photoshoot',
  ]

  const relatedFeatures = [
    {
      title: 'Virtual Try-On',
      description: 'See how different outfits look on you before your photoshoot.',
      link: '/features/virtual-try-on',
      icon: Smartphone,
    },
    {
      title: 'Outfit Recommendations',
      description: 'Get AI suggestions for what to wear for your professional photos.',
      link: '/features/outfit-recommendations',
      icon: Wand2,
    },
    {
      title: 'Wardrobe Analytics',
      description: 'Track which pieces photograph best and get the most value.',
      link: '/features/wardrobe-analytics',
      icon: Camera,
    },
  ]

  return (
    <>
      <SEO
        title="AI Photoshoot Generator | Professional Headshots | FitCheck AI"
        description="Create professional LinkedIn photos, dating profile pictures, and Instagram-worthy shots with AI. Studio-quality results in minutes for free."
        canonicalUrl="https://fitcheckaiapp.com/features/ai-photoshoot-generator"
        ogType="article"
        jsonLd={linkedinHowToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />
      <HowToJsonLd {...linkedinHowToSchema} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-amber-500 via-orange-500 to-pink-500 dark:from-amber-950 dark:via-orange-950 dark:to-pink-950">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-20 left-1/4 w-72 h-72 bg-white rounded-full blur-3xl" />
            <div className="absolute bottom-20 right-1/4 w-96 h-96 bg-white rounded-full blur-3xl" />
          </div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
            <AnimatedSection>
              <div className="text-center max-w-4xl mx-auto">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium mb-6">
                  <Camera className="w-4 h-4" />
                  Professional AI Photography
                </div>

                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                  AI Photoshoot Generator
                </h1>

                <p className="text-xl md:text-2xl text-orange-100 mb-4 max-w-3xl mx-auto">
                  Studio-Quality Professional Photos Without the Studio Price
                </p>

                <p className="text-lg text-orange-200 mb-10 max-w-2xl mx-auto">
                  Create stunning LinkedIn headshots, dating profile photos, and Instagram-worthy shots
                  using just your phone. Professional results in minutes, completely free.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    to="/auth/register"
                    className="inline-flex items-center justify-center gap-2 bg-white text-orange-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                  >
                    Create Free Photos
                    <ArrowRight className="w-5 h-5" />
                  </Link>
                  <Link
                    to="#photoshoot-styles"
                    className="inline-flex items-center justify-center gap-2 bg-white/10 backdrop-blur-sm text-white px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/20 transition-all"
                  >
                    See Styles
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
                { value: '$500', label: 'Average Savings' },
                { value: '5min', label: 'To Generate' },
                { value: '4 Styles', label: 'Available' },
                { value: '21x', label: 'More LinkedIn Views' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="text-center">
                    <div className="text-3xl md:text-4xl font-bold text-orange-600 dark:text-orange-400 mb-2">
                      {stat.value}
                    </div>
                    <div className="text-gray-600 dark:text-gray-400">{stat.label}</div>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Photoshoot Styles */}
        <section id="photoshoot-styles" className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Choose Your Perfect Style
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Four professional photoshoot styles designed for different platforms and purposes
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 gap-8">
              {photoshootStyles.map((style, index) => (
                <AnimatedSection key={style.title} delay={index * 100}>
                  <div className={`group p-8 rounded-2xl border-2 transition-all duration-300 hover:shadow-lg ${
                    style.color === 'blue' ? 'bg-blue-50 dark:bg-blue-950/30 border-blue-200 dark:border-blue-800 hover:border-blue-400' :
                    style.color === 'pink' ? 'bg-pink-50 dark:bg-pink-950/30 border-pink-200 dark:border-pink-800 hover:border-pink-400' :
                    style.color === 'purple' ? 'bg-purple-50 dark:bg-purple-950/30 border-purple-200 dark:border-purple-800 hover:border-purple-400' :
                    'bg-amber-50 dark:bg-amber-950/30 border-amber-200 dark:border-amber-800 hover:border-amber-400'
                  }`}>
                    <div className={`w-14 h-14 rounded-xl flex items-center justify-center mb-6 ${
                      style.color === 'blue' ? 'bg-blue-100 dark:bg-blue-900/50' :
                      style.color === 'pink' ? 'bg-pink-100 dark:bg-pink-900/50' :
                      style.color === 'purple' ? 'bg-purple-100 dark:bg-purple-900/50' :
                      'bg-amber-100 dark:bg-amber-900/50'
                    }`}>
                      <style.icon className={`w-7 h-7 ${
                        style.color === 'blue' ? 'text-blue-600 dark:text-blue-400' :
                        style.color === 'pink' ? 'text-pink-600 dark:text-pink-400' :
                        style.color === 'purple' ? 'text-purple-600 dark:text-purple-400' :
                        'text-amber-600 dark:text-amber-400'
                      }`} />
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-3">
                      {style.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {style.description}
                    </p>
                    <Link
                      to="/auth/register"
                      className={`inline-flex items-center font-medium ${
                        style.color === 'blue' ? 'text-blue-600 dark:text-blue-400' :
                        style.color === 'pink' ? 'text-pink-600 dark:text-pink-400' :
                        style.color === 'purple' ? 'text-purple-600 dark:text-purple-400' :
                        'text-amber-600 dark:text-amber-400'
                      }`}
                    >
                      Try this style
                      <ArrowRight className="w-4 h-4 ml-2 transform group-hover:translate-x-1 transition-transform" />
                    </Link>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Features Grid */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-gray-50 to-orange-50 dark:from-gray-900 dark:to-orange-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Professional Results, Zero Hassle
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  Advanced AI technology delivers studio-quality photos with features designed for perfect results
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <div className="group p-8 bg-white dark:bg-gray-800 rounded-2xl hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-orange-200 dark:hover:border-orange-800">
                    <div className="w-14 h-14 bg-orange-100 dark:bg-orange-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-orange-600 dark:text-orange-400" />
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

        {/* Comparison Section */}
        <section className="py-20 md:py-28 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <AnimatedSection>
                <div>
                  <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                    Why Choose AI Over Traditional Photoshoots?
                  </h2>
                  <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                    Professional photos used to require expensive studio sessions. Now you can get better results in minutes for free.
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
                <div className="bg-gradient-to-br from-orange-500 to-pink-600 rounded-3xl p-8 text-white">
                  <div className="flex items-center gap-3 mb-6">
                    <DollarSign className="w-8 h-8" />
                    <h3 className="text-2xl font-bold">Cost Comparison</h3>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                      <div className="flex justify-between items-center mb-2">
                        <span className="text-orange-100">Traditional Studio</span>
                        <span className="text-2xl font-bold">$200-500</span>
                      </div>
                      <div className="w-full bg-white/20 rounded-full h-2">
                        <div className="bg-white/40 rounded-full h-2 w-full" />
                      </div>
                      <p className="text-sm text-orange-200 mt-2">Plus travel, scheduling, and waiting for edits</p>
                    </div>

                    <div className="bg-white/20 backdrop-blur-sm rounded-xl p-6 border-2 border-white/30">
                      <div className="flex justify-between items-center mb-2">
                        <span className="font-semibold">FitCheck AI</span>
                        <span className="text-3xl font-bold">FREE</span>
                      </div>
                      <div className="w-full bg-white/30 rounded-full h-2">
                        <div className="bg-white rounded-full h-2 w-0" />
                      </div>
                      <p className="text-sm text-orange-100 mt-2">Results in 5 minutes, unlimited retakes</p>
                    </div>
                  </div>

                  <div className="mt-6 pt-6 border-t border-white/20">
                    <div className="flex justify-between items-center">
                      <span className="text-orange-100">Your Savings</span>
                      <span className="text-3xl font-bold">$200-500</span>
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            </div>
          </div>
        </section>

        {/* LinkedIn Impact Section */}
        <section className="py-20 md:py-28 bg-gradient-to-br from-blue-600 to-indigo-700 text-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <Briefcase className="w-12 h-12 mx-auto mb-6 text-blue-200" />
                <h2 className="text-3xl md:text-4xl font-bold mb-4">
                  Boost Your Professional Presence
                </h2>
                <p className="text-xl text-blue-100">
                  LinkedIn profiles with professional photos get dramatically more engagement
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {[
                { value: '21x', label: 'More Profile Views', description: 'Profiles with professional photos receive 21 times more views' },
                { value: '9x', label: 'More Connections', description: 'Get 9 times more connection requests with a great headshot' },
                { value: '36x', label: 'More Messages', description: 'Receive 36 times more messages from recruiters' },
              ].map((stat, index) => (
                <AnimatedSection key={stat.label} delay={index * 100}>
                  <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 text-center">
                    <div className="text-5xl font-bold mb-2">{stat.value}</div>
                    <div className="text-xl font-semibold mb-2">{stat.label}</div>
                    <p className="text-blue-200">{stat.description}</p>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        {/* Related Features */}
        <section className="py-20 md:py-28 bg-gray-50 dark:bg-gray-900">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto mb-16">
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  Complete Your Photo Experience
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400">
                  AI photoshoot generator works seamlessly with these features
                </p>
              </div>
            </AnimatedSection>

            <div className="grid md:grid-cols-3 gap-8">
              {relatedFeatures.map((feature, index) => (
                <AnimatedSection key={feature.title} delay={index * 100}>
                  <Link
                    to={feature.link}
                    className="group block bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 hover:border-orange-200 dark:hover:border-orange-800"
                  >
                    <div className="w-14 h-14 bg-orange-100 dark:bg-orange-900/50 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                      <feature.icon className="w-7 h-7 text-orange-600 dark:text-orange-400" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-orange-600 dark:group-hover:text-orange-400 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">
                      {feature.description}
                    </p>
                    <span className="inline-flex items-center text-orange-600 dark:text-orange-400 font-medium">
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
        <section className="py-20 md:py-28 bg-gradient-to-br from-orange-500 to-pink-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
                Ready for your close-up?
              </h2>
              <p className="text-xl text-orange-100 mb-10 max-w-2xl mx-auto">
                Create professional photos in minutes. No studio, no expensive photographer, no waiting. Just stunning results.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link
                  to="/auth/register"
                  className="inline-flex items-center justify-center gap-2 bg-white text-orange-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
                >
                  Generate Free Photos
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
              <p className="text-orange-200 mt-6 text-sm">
                5 free photoshoots included. No credit card required.
              </p>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
