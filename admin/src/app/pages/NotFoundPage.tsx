import { FileQuestion } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

import { Button } from '@/shared/ui/button'
import { EmptyState } from '@/shared/ui/EmptyState'

/** 404 — unknown route. */
export function NotFoundPage() {
  const { t } = useTranslation('errors')
  const navigate = useNavigate()
  return (
    <div className="flex min-h-[60vh] items-center justify-center p-6">
      <EmptyState
        icon={FileQuestion}
        title={t('notFound.title')}
        message={t('notFound.message')}
        action={
          <Button variant="outline" onClick={() => navigate('/dashboard')}>
            {t('backToDashboard')}
          </Button>
        }
      />
    </div>
  )
}
