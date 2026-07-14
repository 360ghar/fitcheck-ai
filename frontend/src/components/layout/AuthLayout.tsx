/**
 * Auth Layout Component
 * Centered layout for authentication pages — matches landing brand (stone + indigo mark)
 */

import { Link } from 'react-router-dom'
import { Shirt } from 'lucide-react'

interface AuthLayoutProps {
  children: React.ReactNode
}

export default function AuthLayout({ children }: AuthLayoutProps) {
  return (
    <div className="min-h-screen bg-stone-50 dark:bg-stone-950 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link to="/" className="flex justify-center items-center gap-2.5">
          <div className="w-10 h-10 rounded-lg bg-indigo-600 flex items-center justify-center">
            <Shirt className="w-5 h-5 text-white" />
          </div>
          <span className="text-2xl font-semibold tracking-tight text-stone-900 dark:text-stone-50">
            FitCheck<span className="font-normal text-stone-500 dark:text-stone-400"> AI</span>
          </span>
        </Link>
        <p className="mt-6 text-center text-sm text-stone-600 dark:text-stone-400">
          Your virtual closet with AI-powered outfit visualization
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        {children}

        <div className="mt-6 text-center space-y-2">
          <p className="text-sm text-stone-600 dark:text-stone-400">
            <Link to="/privacy" className="hover:text-stone-900 dark:hover:text-stone-100 underline-offset-4 hover:underline">
              Privacy Policy
            </Link>
            {' · '}
            <Link to="/terms" className="hover:text-stone-900 dark:hover:text-stone-100 underline-offset-4 hover:underline">
              Terms of Service
            </Link>
          </p>
          <p className="text-sm text-stone-500 dark:text-stone-500">
            © {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}
