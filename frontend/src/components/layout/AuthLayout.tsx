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
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link to="/" className="flex justify-center items-center">
          <Shirt className="h-12 w-12 text-indigo-600 dark:text-indigo-400" />
          <span className="ml-2 text-3xl font-bold text-gray-900 dark:text-white">FitCheck</span>
          <span className="text-3xl font-light text-gray-600 dark:text-gray-300">AI</span>
        </Link>
        <p className="mt-6 text-center text-sm text-gray-600 dark:text-gray-400">
          Your virtual closet with AI-powered outfit visualization
        </p>
      </div>

      {/* Auth form content */}
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        {children}

        {/* Footer links */}
        <div className="mt-6 text-center space-y-2">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            <Link to="/privacy" className="hover:text-gray-900 dark:hover:text-gray-200">
              Privacy Policy
            </Link>
            {' · '}
            <Link to="/terms" className="hover:text-gray-900 dark:hover:text-gray-200">
              Terms of Service
            </Link>
          </p>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            © {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}
