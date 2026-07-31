/**
 * Security panel — password reset and account deletion (Danger Zone).
 *
 * Self-contained: owns the delete-account dialog state and renders the
 * DeleteAccountDialog. Extracted from ProfilePage.
 */

import { useState } from 'react'
import { Shield } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useToast } from '@/components/ui/use-toast'
import { useAuthStore, useCurrentUser } from '../../stores/authStore'
import { deleteAccount } from '@/api/users'
import { requestPasswordReset } from '@/api/auth'
import { logger } from '@/lib/logger'
import { DeleteAccountDialog } from './DeleteAccountDialog'

export function SecurityPanel() {
  const user = useCurrentUser()
  const logout = useAuthStore((state) => state.logout)
  const { toast } = useToast()

  const [isDeleteAccountOpen, setIsDeleteAccountOpen] = useState(false)
  const [isDeletingAccount, setIsDeletingAccount] = useState(false)

  const handleSendPasswordReset = async () => {
    if (!user?.email) return
    try {
      await requestPasswordReset(user.email)
      toast({
        title: 'Password reset email sent',
        description: 'Check your inbox for a reset link.',
      })
    } catch (err) {
      // api/client interceptor already toasts the failure for Axios errors.
      logger.error('Password reset request failed', err)
    }
  }

  const handleDeleteAccount = async () => {
    setIsDeletingAccount(true)
    try {
      await deleteAccount()
      await logout()
      window.location.href = '/auth/login'
    } catch (err) {
      // api/client interceptor already toasts the failure for Axios errors.
      logger.error('Account deletion failed', err)
      setIsDeletingAccount(false)
    }
  }

  return (
    <div className="border-t border-border pt-6 space-y-4">
      <div className="flex items-center gap-2">
        <Shield className="h-5 w-5 text-muted-foreground" />
        <h3 className="text-base md:text-lg font-medium text-foreground">Security</h3>
      </div>
      <div className="p-4 border border-border rounded-md">
        <h4 className="text-sm font-medium text-foreground">Password</h4>
        <p className="text-sm text-muted-foreground mt-1">
          Change your password to keep your account secure
        </p>
        <Button
          variant="outline"
          onClick={handleSendPasswordReset}
          className="mt-3 w-full md:w-auto"
        >
          Send Password Reset Email
        </Button>
      </div>
      <div className="p-4 border border-destructive/30 rounded-md bg-destructive/5">
        <h4 className="text-sm font-medium text-destructive">Danger Zone</h4>
        <p className="text-sm text-destructive/80 mt-1">
          Once you delete your account, there is no going back
        </p>
        <Button
          variant="destructive"
          onClick={() => setIsDeleteAccountOpen(true)}
          className="mt-3 w-full md:w-auto"
        >
          Delete Account
        </Button>
      </div>

      <DeleteAccountDialog
        open={isDeleteAccountOpen}
        onOpenChange={setIsDeleteAccountOpen}
        onConfirm={() => {
          void handleDeleteAccount()
        }}
        isDeleting={isDeletingAccount}
      />
    </div>
  )
}
