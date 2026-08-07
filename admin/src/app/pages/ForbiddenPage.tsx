import { ShieldX } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

import { Button } from '@/shared/ui/button'
import { EmptyState } from '@/shared/ui/EmptyState'

/**
 * Typed 403 page — never a silent redirect (spec §4): the user is signed in
 * but lacks the permission for this route.
 */
export function ForbiddenPage() {
  const { t } = useTranslation('errors')
  const navigate = useNavigate()
  return (
    <div className="flex min-h-[60vh] items-center justify-center p-6">
      <EmptyState
        icon={ShieldX}
        title={t('forbidden.title')}
        message={t('forbidden.message')}
        action={
          <Button variant="outline" onClick={() => navigate('/dashboard')}>
            {t('backToDashboard')}
          </Button>
        }
      />
    </div>
  )
}
