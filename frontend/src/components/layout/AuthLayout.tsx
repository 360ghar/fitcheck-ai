/**
 * Auth Layout Component
 * Centered layout for authentication pages
 */

import { Link } from 'react-router-dom'
import { Shirt } from 'lucide-react'
import { Outlet } from 'react-router-dom'

export default function AuthLayout() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link to="/" className="flex justify-center items-center">
          <Shirt className="h-12 w-12 text-indigo-600" />
          <span className="ml-2 text-3xl font-bold text-gray-900">FitCheck</span>
          <span className="text-3xl font-light text-gray-600">AI</span>
        </Link>
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          <Outlet />
        </h2>
        <p className="mt-2 text-center text-sm text-gray-600">
          Your virtual closet with AI-powered outfit visualization
        </p>
      </div>

      {/* Auth form content */}
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          {/* This is where the actual auth form will be rendered */}
          <div id="auth-content">
            <Outlet />
          </div>
        </div>

        {/* Footer links */}
        <div className="mt-6 text-center">
          <p className="text-sm text-gray-600">
            © {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}
