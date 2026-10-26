/**
 * Auth Layout Component
 * Centered layout for authentication pages. Surfaces and text run on theme tokens
 * so the page inverts with the app theme (see frontend/DESIGN.md 01).
 */

import { Link } from 'react-router-dom'
import { Logo } from '@/components/brand/Logo'
import { useTranslation } from '@/i18n'

interface AuthLayoutProps {
  children: React.ReactNode
}

export default function AuthLayout({ children }: AuthLayoutProps) {
  const { t } = useTranslation()
  return (
    <div className="min-h-svh bg-background flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link to="/" className="flex justify-center">
          <Logo markSize={48} className="gap-3" wordmarkClassName="text-2xl" />
        </Link>
        <p className="mt-6 text-center text-sm text-muted-foreground">
          {t('layout.authTagline')}
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        {children}

        <div className="mt-6 text-center space-y-2">
          <p className="text-sm text-muted-foreground">
            <Link to="/privacy" className="hover:text-foreground underline-offset-4 hover:underline">
              {t('common.privacyPolicy')}
            </Link>
            {' · '}
            <Link to="/terms" className="hover:text-foreground underline-offset-4 hover:underline">
              {t('common.termsOfService')}
            </Link>
          </p>
          <p className="text-sm text-muted-foreground">
            {t('common.copyright', { year: new Date().getFullYear() })}
          </p>
        </div>
      </div>
    </div>
  )
}
