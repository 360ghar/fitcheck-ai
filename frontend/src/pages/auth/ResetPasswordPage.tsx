/**
 * Reset Password Page
 * Completes password recovery using the Supabase recovery session in the URL hash.
 */

import { useEffect, useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { AlertCircle, CheckCircle, Lock } from 'lucide-react'
import { confirmPasswordReset } from '@/api/auth'

function getHashParams(): URLSearchParams {
  const raw = typeof window !== 'undefined' ? window.location.hash : ''
  const hash = raw.startsWith('#') ? raw.slice(1) : raw
  return new URLSearchParams(hash)
}

function getSearchParams(): URLSearchParams {
  const raw = typeof window !== 'undefined' ? window.location.search : ''
  const search = raw.startsWith('?') ? raw.slice(1) : raw
  return new URLSearchParams(search)
}

export default function ResetPasswordPage() {
  const navigate = useNavigate()
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  const { accessToken, refreshToken } = useMemo(() => {
    const hash = getHashParams()
    const search = getSearchParams()
    return {
      accessToken: hash.get('access_token') || search.get('access_token') || '',
      refreshToken: hash.get('refresh_token') || search.get('refresh_token') || '',
    }
  }, [])

  useEffect(() => {
    // Remove tokens from URL after we read them (avoid leaking via screenshots/history).
    try {
      window.history.replaceState(null, document.title, window.location.pathname)
    } catch {
      // no-op
    }
  }, [])

  const passwordsMatch = password === confirmPassword && password.length > 0

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setSuccess(null)

    if (!accessToken || !refreshToken) {
      setError('Missing reset session. Please re-open the link from your email.')
      return
    }

    if (!passwordsMatch) {
      setError('Passwords do not match.')
      return
    }

    setIsLoading(true)
    try {
      const resp = await confirmPasswordReset({
        access_token: accessToken,
        refresh_token: refreshToken,
        new_password: password,
      })
      setSuccess(resp.message || 'Password updated. You can sign in now.')
      setTimeout(() => navigate('/auth/login'), 800)
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Failed to reset password'
      setError(msg)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <>
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="text-2xl font-extrabold text-gray-900 dark:text-white">Choose a new password</h2>
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">Your new password must be at least 8 characters.</p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white dark:bg-gray-800 py-8 px-4 shadow sm:rounded-lg sm:px-10">
          {error && (
            <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md flex items-start">
              <AlertCircle className="h-5 w-5 text-red-400 mt-0.5 mr-2 flex-shrink-0" />
              <p className="text-sm text-red-800 dark:text-red-300">{error}</p>
            </div>
          )}

          {success && (
            <div className="mb-4 p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md flex items-start">
              <CheckCircle className="h-5 w-5 text-green-500 mt-0.5 mr-2 flex-shrink-0" />
              <p className="text-sm text-green-800 dark:text-green-300">{success}</p>
            </div>
          )}

          <form className="space-y-6" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                New password
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400 dark:text-gray-500" />
                </div>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-10 sm:text-sm border-gray-300 dark:border-gray-600 rounded-md py-2 border bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                Confirm password
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400 dark:text-gray-500" />
                </div>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-10 sm:text-sm border-gray-300 dark:border-gray-600 rounded-md py-2 border bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                  placeholder="••••••••"
                />
              </div>
              {!passwordsMatch && confirmPassword.length > 0 && (
                <p className="mt-1 text-sm text-red-600 dark:text-red-400">Passwords do not match</p>
              )}
            </div>

            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:focus:ring-offset-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {isLoading ? 'Updating…' : 'Update password'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <Link to="/auth/login" className="text-sm font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300">
              Back to sign in
            </Link>
          </div>
        </div>
      </div>
    </>
  )
}

