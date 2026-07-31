/**
 * Avatar section — display, upload of the user's profile picture.
 *
 * Self-contained: owns the upload state and file input ref. Extracted from
 * ProfilePage. Rendered above the settings tabs.
 */

import { useRef, useState } from 'react'
import { Camera } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { useAuthStore, useCurrentUser, useUserDisplayName, useUserAvatar } from '../../stores/authStore'
import { uploadAvatar } from '@/api/users'
import { logger } from '@/lib/logger'

export function AvatarSection() {
  const user = useCurrentUser()
  const userDisplayName = useUserDisplayName()
  const userAvatar = useUserAvatar()
  const setUser = useAuthStore((state) => state.setUser)
  const { toast } = useToast()

  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false)
  const avatarInputRef = useRef<HTMLInputElement | null>(null)

  const handleAvatarClick = () => {
    avatarInputRef.current?.click()
  }

  const handleAvatarSelected = async (file: File | null) => {
    if (!file || !user) return
    setIsUploadingAvatar(true)
    try {
      const { avatar_url } = await uploadAvatar(file)
      // Merge against the store's CURRENT user, not the render-time snapshot:
      // an upload completing after a concurrent profile edit or logout must
      // not resurrect stale profile state.
      const current = useAuthStore.getState().user
      if (current) {
        setUser({ ...current, avatar_url })
      }
      toast({ title: 'Avatar updated' })
    } catch (err) {
      // api/client interceptor already toasts the failure for Axios errors.
      // Log non-Axios errors so they aren't invisible.
      logger.error('Avatar upload failed', err)
    } finally {
      setIsUploadingAvatar(false)
    }
  }

  return (
    <div className="px-4 py-4 md:px-6 md:py-6 lg:px-8 border-b border-border">
      <div className="flex flex-col items-center xs:flex-row xs:items-center w-full">
        <div className="relative">
          {userAvatar ? (
            <img
              src={userAvatar}
              alt={`${userDisplayName} avatar`}
              className="h-16 w-16 md:h-24 md:w-24 rounded-full object-cover"
            />
          ) : (
            <div className="h-16 w-16 md:h-24 md:w-24 rounded-full bg-primary/10 flex items-center justify-center">
              <span className="text-xl md:text-3xl font-bold text-primary">
                {userDisplayName.charAt(0).toUpperCase()}
              </span>
            </div>
          )}
          <input
            ref={avatarInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => handleAvatarSelected(e.target.files?.[0] || null)}
          />
          <button
            type="button"
            onClick={handleAvatarClick}
            disabled={isUploadingAvatar}
            className="absolute bottom-0 right-0 p-2 md:p-2.5 bg-primary rounded-full text-primary-foreground hover:bg-primary/90 disabled:opacity-60 touch-target"
            aria-label="Change avatar"
            title="Change avatar"
          >
            <Camera className="h-4 w-4 md:h-5 md:w-5" />
          </button>
        </div>
        <div className="mt-3 xs:mt-0 xs:ml-4 md:ml-6 min-w-0 text-center xs:text-left">
          <h2 className="text-lg md:text-xl font-medium text-foreground truncate">{userDisplayName}</h2>
          <p className="text-sm text-muted-foreground truncate">{user?.email}</p>
        </div>
      </div>
    </div>
  )
}
