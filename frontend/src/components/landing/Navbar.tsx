import { useState, useEffect } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { Menu, Shirt } from 'lucide-react'
import { useIsAuthenticated } from '@/stores/authStore'
import { ThemeToggle } from '@/components/theme'

const navLinks = [
  { name: 'Features', href: '/features' },
  { name: 'How It Works', href: '/#how-it-works' },
  { name: 'Guides', href: '/guides/what-to-wear-today' },
  { name: 'Blog', href: '/blog' },
  { name: 'FAQ', href: '/faq' },
  { name: 'About', href: '/about' },
]

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false)
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const isAuthenticated = useIsAuthenticated()
  const location = useLocation()

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 50)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    if (href.startsWith('/#')) {
      e.preventDefault()
      const id = href.replace('/#', '')
      if (location.pathname !== '/') {
        window.location.href = href
      } else {
        const element = document.getElementById(id)
        if (element) {
          element.scrollIntoView({ behavior: 'smooth' })
        }
      }
      setIsMobileMenuOpen(false)
      return
    }
    // SPA routes: close mobile menu; let React Router handle navigation via Link
    setIsMobileMenuOpen(false)
  }

  const isHashLink = (href: string) => href.startsWith('/#')

  return (
    <nav
      className={cn(
        'fixed top-0 left-0 right-0 z-50 transition-all duration-300',
        isScrolled
          ? 'bg-stone-50/90 dark:bg-stone-950/90 backdrop-blur-md border-b border-stone-200/70 dark:border-stone-800/70'
          : 'bg-transparent'
      )}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <Link to="/" className="flex items-center gap-2.5 shrink-0">
            <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center">
              <Shirt className="w-4 h-4 text-white" />
            </div>
            <span className="text-[17px] font-semibold tracking-tight text-stone-900 dark:text-stone-50">
              FitCheck<span className="font-normal text-stone-500 dark:text-stone-400"> AI</span>
            </span>
          </Link>

          <div className="hidden lg:flex items-center gap-7">
            {navLinks.map((link) =>
              isHashLink(link.href) ? (
                <a
                  key={link.name}
                  href={link.href}
                  onClick={(e) => handleNavClick(e, link.href)}
                  className="text-sm font-medium text-stone-600 hover:text-stone-900 dark:text-stone-400 dark:hover:text-stone-100 transition-colors"
                >
                  {link.name}
                </a>
              ) : (
                <Link
                  key={link.name}
                  to={link.href}
                  className="text-sm font-medium text-stone-600 hover:text-stone-900 dark:text-stone-400 dark:hover:text-stone-100 transition-colors"
                >
                  {link.name}
                </Link>
              )
            )}
          </div>

          <div className="hidden lg:flex items-center gap-3">
            <ThemeToggle />
            {isAuthenticated ? (
              <Button asChild className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-none">
                <Link to="/dashboard">Dashboard</Link>
              </Button>
            ) : (
              <>
                <Button variant="ghost" asChild className="text-stone-700 dark:text-stone-300">
                  <Link to="/auth/login">Log in</Link>
                </Button>
                <Button asChild className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-none">
                  <Link to="/auth/register">Use free</Link>
                </Button>
              </>
            )}
          </div>

          <Sheet open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
            <SheetTrigger asChild className="lg:hidden">
              <Button variant="ghost" size="icon" aria-label="Open menu">
                <Menu className="w-5 h-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-[300px] sm:w-[360px] bg-stone-50 dark:bg-stone-950">
              <div className="flex flex-col gap-5 mt-6">
                {navLinks.map((link) =>
                  isHashLink(link.href) ? (
                    <a
                      key={link.name}
                      href={link.href}
                      onClick={(e) => handleNavClick(e, link.href)}
                      className="text-lg font-medium text-stone-900 dark:text-stone-50 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors"
                    >
                      {link.name}
                    </a>
                  ) : (
                    <Link
                      key={link.name}
                      to={link.href}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className="text-lg font-medium text-stone-900 dark:text-stone-50 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors"
                    >
                      {link.name}
                    </Link>
                  )
                )}
                <div className="flex items-center justify-between">
                  <span className="text-sm text-stone-500">Theme</span>
                  <ThemeToggle />
                </div>
                <hr className="border-stone-200 dark:border-stone-800" />
                {isAuthenticated ? (
                  <Button asChild className="w-full bg-indigo-600 hover:bg-indigo-700 text-white">
                    <Link to="/dashboard">Dashboard</Link>
                  </Button>
                ) : (
                  <>
                    <Button variant="outline" asChild className="w-full border-stone-300 dark:border-stone-700">
                      <Link to="/auth/login">Log in</Link>
                    </Button>
                    <Button asChild className="w-full bg-indigo-600 hover:bg-indigo-700 text-white">
                      <Link to="/auth/register">Use free</Link>
                    </Button>
                  </>
                )}
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  )
}
