import { useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { ChevronDown, Menu, Shirt } from 'lucide-react'

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

  const handleNavClick = (event: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    if (!isHashLink(href)) {
      setIsMobileMenuOpen(false)
      return
    }

    event.preventDefault()
    const id = href.replace('/#', '')
    if (location.pathname !== '/') {
      window.location.href = href
    } else {
      document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
    }
    setIsMobileMenuOpen(false)
  }

  const renderNavLink = (link: (typeof mobileLinks)[number], mobile = false) => {
    const className = mobile
      ? 'flex min-h-11 items-center text-lg font-medium text-foreground transition-colors hover:text-primary'
      : 'inline-flex min-h-11 items-center px-2 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2'

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
      >
        {link.name}
      </Link>
    )
  }

  return (
    <nav
      aria-label="Public navigation"
      className="fixed inset-x-0 top-0 z-50 border-b border-border bg-background"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          <Link
            to="/"
            className="flex shrink-0 items-center gap-2.5 rounded-2xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          >
            <span className="flex h-8 w-8 items-center justify-center rounded-2xl bg-primary">
              <Shirt className="h-4 w-4 text-primary-foreground" aria-hidden="true" />
            </span>
            <span className="text-[17px] font-semibold tracking-tight text-foreground">
              FitCheck<span className="font-normal text-muted-foreground"> AI</span>
            </span>
          </Link>

          <div className="hidden items-center gap-4 lg:flex xl:gap-6">
            {primaryLinks.map((link) => renderNavLink(link))}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="h-11 gap-1.5 px-2 text-sm font-medium text-muted-foreground hover:text-foreground data-[state=open]:text-foreground"
                >
                  Resources
                  <ChevronDown className="h-3.5 w-3.5" aria-hidden="true" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent
                align="center"
                className="w-52 rounded-2xl border-border bg-card p-2 shadow-none"
              >
                {resourceLinks.map((link) => (
                  <DropdownMenuItem key={link.name} asChild className="rounded-2xl px-3 py-2.5">
                    <Link to={link.href}>{link.name}</Link>
                  </DropdownMenuItem>
                ))}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          <div className="hidden items-center gap-2 lg:flex">
            <ThemeToggle />
            {isAuthenticated ? (
              <Button asChild>
                <Link to="/dashboard">Dashboard</Link>
              </Button>
            ) : (
              <>
                <Button variant="ghost" asChild>
                  <Link to="/auth/login">Log in</Link>
                </Button>
                <Button asChild>
                  <Link to={trialRegisterHref()}>Start free</Link>
                </Button>
              </>
            )}
          </div>

          <Sheet open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
            <SheetTrigger asChild className="lg:hidden">
              <Button variant="ghost" size="icon" aria-label="Open menu">
                <Menu className="h-5 w-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-[85vw] max-w-[360px] bg-background">
              <SheetTitle className="sr-only">Navigation menu</SheetTitle>
              <SheetDescription className="sr-only">
                Open FitCheck product, resource, account, and theme links.
              </SheetDescription>
              <div className="mt-6 flex flex-col">
                <p className="mb-2 text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">
                  Explore
                </p>
                {mobileLinks.map((link) => renderNavLink(link, true))}
                <div className="my-5 h-px bg-border" />
                <div className="flex min-h-11 items-center justify-between">
                  <span className="text-sm text-muted-foreground">Theme</span>
                  <ThemeToggle />
                </div>
                <div className="mt-5 grid gap-3">
                  {isAuthenticated ? (
                    <Button asChild className="w-full">
                      <Link to="/dashboard">Dashboard</Link>
                    </Button>
                  ) : (
                    <>
                      <Button variant="outline" asChild className="w-full">
                        <Link to="/auth/login">Log in</Link>
                      </Button>
                      <Button asChild className="w-full">
                        <Link to={trialRegisterHref()}>Start free</Link>
                      </Button>
                    </>
                  )}
                </div>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
      <div
        aria-hidden="true"
        className="scroll-progress pointer-events-none absolute bottom-0 left-0 h-px w-full origin-left scale-x-0 bg-primary/60"
      />
    </nav>
  )
}
