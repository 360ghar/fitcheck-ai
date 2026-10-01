import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { ChevronDown, Menu } from 'lucide-react'
import { Logo } from '@/components/brand/Logo'

import { ThemeToggle } from '@/components/theme'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet'
import { trialRegisterHref } from '@/lib/trial-offer'
import { scrollToSectionId } from '@/lib/scroll'
import { trackLandingCta } from '@/lib/analytics'
import { useIsAuthenticated } from '@/stores/authStore'

const primaryLinks = [
  { name: 'Features', href: '/features' },
  { name: 'Live demo', href: '/#demo' },
  { name: 'Pricing', href: '/#pricing' },
]

const resourceLinks = [
  { name: 'Guides', href: '/guides/what-to-wear-today' },
  { name: 'Blog', href: '/blog' },
  { name: 'FAQ', href: '/faq' },
  { name: 'About', href: '/about' },
]

const mobileLinks = [...primaryLinks, ...resourceLinks]

const isHashLink = (href: string) => href.startsWith('/#')

export default function Navbar() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const isAuthenticated = useIsAuthenticated()
  const location = useLocation()
  const navigate = useNavigate()

  const handleNavClick = (event: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    if (!isHashLink(href)) {
      setIsMobileMenuOpen(false)
      return
    }

    event.preventDefault()
    const id = href.replace('/#', '')
    trackLandingCta(id === 'demo' ? 'nav-demo' : 'nav-pricing')
    setIsMobileMenuOpen(false)
    if (location.pathname !== '/') {
      // Router navigation: no full-page reload. The landing page remounts,
      // so scroll + focus after it paints.
      navigate(href)
      window.setTimeout(() => scrollToSectionId(id), 150)
    } else {
      scrollToSectionId(id)
    }
  }

  const renderNavLink = (link: (typeof mobileLinks)[number], mobile = false) => {
    // Paper nav: bare text on the stone strip. Hover is a tone step; the
    // current page reads through weight, never a dot or an underline.
    const current = !isHashLink(link.href) && location.pathname.startsWith(link.href)
    const className = mobile
      ? `flex min-h-12 items-center paper-head text-2xl text-paper-text transition-colors hover:text-paper-accent ${current ? 'font-bold' : ''}`
      : `inline-flex min-h-11 items-center rounded-lg px-3 text-[15px] transition-colors hover:text-paper-text ${current ? 'font-semibold text-paper-text' : 'font-medium text-paper-text-2'}`

    return isHashLink(link.href) ? (
      <a
        key={link.name}
        href={link.href}
        onClick={(event) => handleNavClick(event, link.href)}
        className={className}
      >
        {link.name}
      </a>
    ) : (
      <Link
        key={link.name}
        to={link.href}
        onClick={() => setIsMobileMenuOpen(false)}
        className={className}
        aria-current={current ? 'page' : undefined}
      >
        {link.name}
      </Link>
    )
  }

  return (
    <nav
      aria-label="Public navigation"
      className="paper-landing stock-stone paper-section paper-tear-bottom fixed inset-x-0 top-0 z-50"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          <Link
            to="/"
            className="flex shrink-0 items-center gap-2.5 rounded-2xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          >
            <Logo markSize={34} wordmarkClassName="text-[17px]" />
          </Link>

          <div className="hidden items-center gap-2 lg:flex xl:gap-4">
            {primaryLinks.map((link) => renderNavLink(link))}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="h-11 gap-1.5 rounded-lg px-3 text-[15px] font-medium text-paper-text-2 hover:bg-transparent hover:text-paper-text data-[state=open]:text-paper-text"
                >
                  Resources
                  <ChevronDown className="h-3.5 w-3.5" aria-hidden="true" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent
                align="center"
                className="stock-stone paper-landing paper-sheet w-52 border-0 p-2"
              >
                {resourceLinks.map((link) => (
                  <DropdownMenuItem
                    key={link.name}
                    asChild
                    className="rounded-lg px-3 py-2.5 text-[15px] text-paper-text-2 focus:bg-paper-tint focus:text-paper-text"
                  >
                    <Link to={link.href}>{link.name}</Link>
                  </DropdownMenuItem>
                ))}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          <div className="hidden items-center gap-2 lg:flex">
            <ThemeToggle />
            {isAuthenticated ? (
              <Link to="/dashboard" className="paper-btn min-h-10 px-4 text-[15px]">
                Dashboard
              </Link>
            ) : (
              <>
                <Link
                  to="/auth/login"
                  className="inline-flex min-h-11 items-center rounded-lg px-3 text-[15px] font-medium text-paper-text-2 transition-colors hover:text-paper-text"
                >
                  Log in
                </Link>
                <Link to={trialRegisterHref()} className="paper-btn min-h-10 px-4 text-[15px]">
                  Start free
                </Link>
              </>
            )}
          </div>

          <Sheet open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
            <SheetTrigger asChild className="lg:hidden">
              <Button
                variant="ghost"
                size="icon"
                aria-label="Open menu"
                className="text-paper-text hover:bg-paper-tint"
              >
                <Menu className="h-5 w-5" />
              </Button>
            </SheetTrigger>
            <SheetContent
              side="right"
              className="paper-landing stock-stone paper-section w-[85vw] max-w-[360px] overflow-y-auto border-0"
            >
              <SheetTitle className="sr-only">Navigation menu</SheetTitle>
              <SheetDescription className="sr-only">
                Open FitCheck product, resource, account, and theme links.
              </SheetDescription>
              <div className="mt-8 flex flex-col">
                {mobileLinks.map((link) => renderNavLink(link, true))}
                {!isAuthenticated && (
                  <Link
                    to="/auth/login"
                    onClick={() => setIsMobileMenuOpen(false)}
                    className="flex min-h-12 items-center paper-head text-2xl text-paper-text transition-colors hover:text-paper-accent"
                  >
                    Log in
                  </Link>
                )}
                <div className="mt-8 flex min-h-11 items-center justify-between">
                  <span className="text-[15px] text-paper-text-2">Theme</span>
                  <ThemeToggle />
                </div>
                <Link
                  to={isAuthenticated ? '/dashboard' : trialRegisterHref()}
                  onClick={() => setIsMobileMenuOpen(false)}
                  className="paper-btn mt-6 w-full"
                >
                  {isAuthenticated ? 'Dashboard' : 'Start free'}
                </Link>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  )
}
