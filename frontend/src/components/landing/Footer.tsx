import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Mail, Phone } from 'lucide-react'
import { Logo } from '@/components/brand/Logo'

import { trackLandingCta } from '@/lib/analytics'
import { PLATFORM_AVAILABILITY } from '@/lib/plan-limits'
import { scrollToSectionId } from '@/lib/scroll'

const footerLinks = {
  Product: [
    { name: 'All features', href: '/features' },
    { name: 'Try demo', href: '/#demo' },
    { name: 'Pricing', href: '/#pricing' },
    { name: 'AI Wardrobe Extraction', href: '/features/ai-wardrobe-extraction' },
    { name: 'Virtual Try-On', href: '/features/virtual-try-on' },
    { name: 'AI Photoshoot', href: '/features/ai-photoshoot-generator' },
    { name: 'Outfit Recommendations', href: '/features/outfit-recommendations' },
    { name: 'Wardrobe Analytics', href: '/features/wardrobe-analytics' },
    { name: 'FAQ', href: '/faq' },
    { name: 'iOS app', href: PLATFORM_AVAILABILITY.iosStoreUrl },
    { name: 'Android app', href: PLATFORM_AVAILABILITY.androidStoreUrl },
  ],
  Resources: [
    { name: 'Blog', href: '/blog' },
    { name: 'What to wear today', href: '/guides/what-to-wear-today' },
    { name: 'Digitize your wardrobe', href: '/guides/how-to-digitize-your-wardrobe' },
    { name: 'Cost per wear', href: '/guides/cost-per-wear-calculator-explained' },
    { name: 'Best virtual closet apps', href: '/best/virtual-closet-apps' },
    { name: 'FitCheck vs Acloset', href: '/compare/fitcheck-vs-acloset' },
    { name: 'Acloset alternatives', href: '/alternatives/acloset-alternatives' },
  ],
  Company: [
    { name: 'About', href: '/about' },
    { name: 'For professionals', href: '/for/busy-professionals' },
    { name: 'For creators', href: '/for/content-creators' },
    { name: 'Festive & wedding', href: '/for/festive-and-wedding-outfits' },
    { name: 'Support', href: '/support' },
    { name: 'Contact', href: 'mailto:info@fitcheckaiapp.com' },
  ],
  Legal: [
    { name: 'Terms of Service', href: '/terms' },
    { name: 'Privacy Policy', href: '/privacy' },
  ],
}

/**
 * Page close: the deep moss floor, torn along the top like every sheet above
 * it. Brand and contact on the left, link groups on the content grid, and an
 * oversized FitCheck wordmark anchored flush to the bottom edge. Every href,
 * the router-aware hash navigation and the trackLandingCta calls are kept.
 */
export default function Footer() {
  const location = useLocation()
  const navigate = useNavigate()

  const handleHashClick = (event: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    // Router-safe section links: same-page scroll + focus on home, client-side
    // navigation (no full reload) from anywhere else.
    event.preventDefault()
    const id = href.replace('/#', '')
    trackLandingCta(id === 'demo' ? 'footer-demo' : 'footer-pricing')
    if (location.pathname !== '/') {
      navigate(href)
      window.setTimeout(() => scrollToSectionId(id), 150)
    } else {
      scrollToSectionId(id)
    }
  }

  const linkClass =
    'inline-flex min-h-[36px] items-center py-1 text-paper-text-2 transition-colors hover:text-paper-text'

  return (
    <footer className="paper-landing paper-floor paper-section paper-tear overflow-hidden pt-16">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 gap-x-8 gap-y-10 lg:grid-cols-12">
          <div className="col-span-2 lg:col-span-4">
            <Link to="/" className="mb-4 inline-flex items-center gap-2.5 rounded-lg">
              <Logo markSize={36} wordmarkClassName="text-lg text-paper-text [&_span]:text-paper-text-2" />
            </Link>
            <p className="max-w-xs text-[15px] leading-relaxed text-paper-text-2">
              Photograph your clothes. Get outfits that fit the day.
            </p>
            <div className="mt-5 space-y-1 text-sm text-paper-text-2">
              <a
                href="mailto:info@fitcheckaiapp.com"
                className="flex min-h-[36px] items-center gap-2 py-1 transition-colors hover:text-paper-text"
              >
                <Mail className="h-4 w-4" aria-hidden="true" />
                <span>info@fitcheckaiapp.com</span>
              </a>
              <a
                href="https://wa.me/919310833204"
                target="_blank"
                rel="noopener noreferrer"
                className="flex min-h-[36px] items-center gap-2 py-1 transition-colors hover:text-paper-text"
              >
                <Phone className="h-4 w-4" aria-hidden="true" />
                <span>+91 9310833204</span>
              </a>
            </div>
          </div>

          {Object.entries(footerLinks).map(([category, links]) => (
            <div key={category} className="min-w-0 lg:col-span-2">
              <h3 className="paper-head mb-3 text-xl text-paper-text">{category}</h3>
              <ul className="space-y-0.5 text-sm">
                {links.map((link) => (
                  <li key={link.name}>
                    {link.href.startsWith('/#') ? (
                      <a
                        href={link.href}
                        onClick={(event) => handleHashClick(event, link.href)}
                        className={linkClass}
                      >
                        {link.name}
                      </a>
                    ) : link.href.startsWith('/') ? (
                      <Link to={link.href} className={linkClass}>
                        {link.name}
                      </Link>
                    ) : (
                      <a
                        href={link.href}
                        className={linkClass}
                        {...(link.href.startsWith('http')
                          ? { target: '_blank', rel: 'noopener noreferrer' }
                          : {})}
                      >
                        {link.name}
                      </a>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <p className="mt-12 text-xs text-paper-text-2">
          &copy; {new Date().getFullYear()} FitCheck AI. All rights reserved.
        </p>
      </div>
      {/* The signature wordmark: whole on top and both sides, set on the
          baseline at the floor's bottom edge. Decorative; the Logo above is
          the accessible brand mark. */}
      <p aria-hidden="true" className="footer-wordmark paper-display select-none">
        FitCheck
      </p>
    </footer>
  )
}
