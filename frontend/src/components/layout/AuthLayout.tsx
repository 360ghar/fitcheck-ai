/**
 * Auth Layout Component
 * Centered layout for authentication pages. Surfaces and text run on theme tokens
 * so the page inverts with the app theme (see frontend/DESIGN.md 01).
 */

import { Link } from 'react-router-dom'
import { Shirt } from 'lucide-react'

interface AuthLayoutProps {
  children: React.ReactNode
}

export default function AuthLayout({ children }: AuthLayoutProps) {
  return (
    <div className="min-h-screen bg-background flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        {/* The mark is bare. It used to sit in a filled rounded tile, which is
            the icon-in-a-coloured-box tell — and it is no less a tell for a
            brand mark than for any other glyph. The mark carries itself with
            weight and colour instead of a container, and losing the box also
            loses a white-on-primary label that measured ~3.5:1 in dark. */}
        <Link to="/" className="flex items-center justify-center gap-2.5">
          <Shirt className="h-7 w-7 shrink-0 text-primary" strokeWidth={2.25} aria-hidden="true" />
          <span className="text-2xl font-semibold tracking-tight text-foreground">
            FitCheck<span className="font-normal text-muted-foreground"> AI</span>
          </span>
        </Link>
        <p className="mt-6 text-center text-sm text-muted-foreground">
          Your virtual closet with AI-powered outfit visualization
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        {children}

        <div className="mt-6 text-center space-y-2">
          <p className="text-sm text-muted-foreground">
            <Link to="/privacy" className="hover:text-foreground underline-offset-4 hover:underline">
              Privacy Policy
            </Link>
            {' · '}
            <Link to="/terms" className="hover:text-foreground underline-offset-4 hover:underline">
              Terms of Service
            </Link>
          </p>
          <p className="text-sm text-muted-foreground">
            © {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}
