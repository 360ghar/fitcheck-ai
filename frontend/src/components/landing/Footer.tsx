import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Shirt, Mail, Phone } from 'lucide-react'

import { trackLandingCta } from '@/lib/analytics'
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
    {
      name: 'Android app',
      href: 'https://play.google.com/store/apps/details?id=com.fitcheckaiapp.fitcheckai&hl=en_IN',
    },
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
 * Page close — warm cream, per the clay rebuild's revocation of the dark
 * stone-950 footer. The tinted room (`bg-surface-room`, the deeper cream)
 * layers a rounded top over the canvas so the page ends like a stamped
 * clay slab, not a dark slab. Every href, the router-aware hash navigation,
 * and the trackLandingCta calls are unchanged from the previous footer.
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
    'inline-flex min-h-[36px] items-center py-1.5 text-muted-foreground transition-colors hover:text-primary'

  return (
    <footer className="rounded-t-[2.5rem] bg-surface-room pb-8 pt-14 text-body shadow-pressed">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mb-10 grid grid-cols-1 gap-x-8 gap-y-10 sm:grid-cols-2 lg:grid-cols-6">
          <div className="col-span-2 lg:col-span-2">
            <Link to="/" className="mb-4 flex items-center gap-2.5">
              <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-primary shadow-pressed">
                <Shirt className="h-4 w-4 text-primary-foreground" aria-hidden="true" />
              </div>
              <span className="text-lg font-semibold tracking-tight text-foreground">
                FitCheck<span className="font-normal text-muted-foreground"> AI</span>
              </span>
            </Link>
            <p className="max-w-xs text-sm leading-relaxed">
              Photograph your clothes. Get outfits that fit the day. A quieter way to use what you own.
            </p>
            <div className="mt-6 space-y-2 text-sm">
              <a
                href="mailto:info@fitcheckaiapp.com"
                className="flex min-h-[36px] items-center gap-2 py-1.5 transition-colors hover:text-primary"
              >
                <Mail className="h-4 w-4" aria-hidden="true" />
                <span>info@fitcheckaiapp.com</span>
              </a>
              <a
                href="https://wa.me/919310833204"
                target="_blank"
                rel="noopener noreferrer"
                className="flex min-h-[36px] items-center gap-2 py-1.5 transition-colors hover:text-primary"
              >
                <Phone className="h-4 w-4" aria-hidden="true" />
                <span>+91 9310833204</span>
              </a>
            </div>
          </div>

          {Object.entries(footerLinks).map(([category, links]) => (
            <div key={category} className="border-t border-border pt-5">
              <h3 className="mb-4 text-sm font-semibold text-foreground">{category}</h3>
              <ul className="space-y-2.5 text-sm">
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

        <div className="flex flex-col items-start justify-between gap-3 border-t border-border pt-6 md:flex-row md:items-center">
          <p className="text-xs text-muted-foreground">
            &copy; {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}
