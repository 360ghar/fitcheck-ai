/**
 * Delete Account confirmation dialog.
 *
 * Presentational component — the open state and confirm handler are owned by
 * the parent (SecurityPanel). Extracted from ProfilePage.
 */

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { useTranslation } from '@/i18n'

export interface DeleteAccountDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onConfirm: () => void
  isDeleting: boolean
}

export function DeleteAccountDialog({ open, onOpenChange, onConfirm, isDeleting }: DeleteAccountDialogProps) {
  const { t } = useTranslation()
  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!isDeleting) onOpenChange(next)
      }}
    >
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('settings.deleteAccountConfirmTitle')}</AlertDialogTitle>
          <AlertDialogDescription>
            {t('settings.deleteAccountConfirmBody')}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={isDeleting}>{t('common.cancel')}</AlertDialogCancel>
          <AlertDialogAction
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            disabled={isDeleting}
            onClick={(e) => {
              e.preventDefault()
              onConfirm()
            }}
          >
            {isDeleting ? t('settings.deleting') : t('settings.deleteAccount')}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
