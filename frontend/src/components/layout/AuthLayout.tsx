/**
 * Auth Layout Component
 * Centered layout for authentication pages
 */

import { Link } from 'react-router-dom'
import { Shirt } from 'lucide-react'

interface AuthLayoutProps {
  children: React.ReactNode;
}

export default function AuthLayout({ children }: AuthLayoutProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-navy-50 via-white to-gold-50/30 dark:from-navy-950 dark:via-navy-950 dark:to-navy-900 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link to="/" className="flex justify-center items-center gap-2">
          <div className="w-12 h-12 rounded-lg bg-gold-400 flex items-center justify-center">
            <Shirt className="h-6 w-6 text-navy-900" />
          </div>
          <span className="text-3xl font-display font-semibold text-navy-800 dark:text-white">FitCheck</span>
          <span className="text-3xl font-light text-gold-500 dark:text-gold-400">AI</span>
        </Link>
        <p className="mt-6 text-center text-sm text-navy-500 dark:text-navy-400">
          Your virtual closet with AI-powered outfit visualization
        </p>
      </div>

      {/* Auth form content */}
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        {children}

        {/* Footer links */}
        <div className="mt-6 text-center">
          <p className="text-sm text-navy-400 dark:text-navy-500">
            © {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}
