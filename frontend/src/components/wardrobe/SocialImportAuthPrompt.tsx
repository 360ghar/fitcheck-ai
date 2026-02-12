import { useState } from 'react'
import { KeyRound, Link2, ShieldCheck } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { SocialPlatform } from '@/types'

interface SocialImportAuthPromptProps {
  platform: SocialPlatform
  isLoading?: boolean
  error?: string | null
  onStartOAuthConnect: () => Promise<void>
  onSubmitScraper: (payload: { username: string; password: string; otp_code?: string }) => Promise<void>
}

export function SocialImportAuthPrompt({
  platform,
  isLoading = false,
  error,
  onStartOAuthConnect,
  onSubmitScraper,
}: SocialImportAuthPromptProps) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [otpCode, setOtpCode] = useState('')
  const platformLabel = platform === 'instagram' ? 'Instagram' : 'Facebook'

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm text-amber-800 dark:border-amber-900/40 dark:bg-amber-950/20 dark:text-amber-300">
        This profile requires login. Connect your {platformLabel} account to continue automatically.
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700 dark:border-red-900/50 dark:bg-red-950/20 dark:text-red-300">
          {error}
        </div>
      )}

      <div className="grid gap-3 rounded-lg border border-border p-4">
        <div className="flex items-center gap-2">
          <ShieldCheck className="h-4 w-4 text-indigo-500" />
          <p className="text-sm font-semibold text-foreground">Direct Meta OAuth (Recommended)</p>
        </div>
        <p className="text-xs text-muted-foreground">
          We will open Meta login so you can securely authorize {platformLabel} access. No manual token copy-paste required.
        </p>
        <div className="flex justify-end">
          <Button variant="outline" disabled={isLoading} onClick={onStartOAuthConnect}>
            <Link2 className="mr-2 h-4 w-4" />
            Connect {platformLabel}
          </Button>
        </div>
      </div>

      <div className="grid gap-3 rounded-lg border border-border p-4">
        <div className="flex items-center gap-2">
          <KeyRound className="h-4 w-4 text-indigo-500" />
          <p className="text-sm font-semibold text-foreground">Manual Login Fallback</p>
        </div>
        <p className="text-xs text-muted-foreground">
          Only use this if OAuth is unavailable for your account.
        </p>
        <Input
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Instagram/Facebook username"
          disabled={isLoading}
          autoComplete="username"
        />
        <Input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          disabled={isLoading}
          autoComplete="current-password"
        />
        <Input
          value={otpCode}
          onChange={(e) => setOtpCode(e.target.value)}
          placeholder="OTP code (optional)"
          disabled={isLoading}
          autoComplete="one-time-code"
        />
        <div className="flex justify-end">
          <Button
            disabled={isLoading || !username.trim() || !password.trim()}
            onClick={() =>
              onSubmitScraper({
                username: username.trim(),
                password,
                otp_code: otpCode.trim() || undefined,
              })
            }
          >
            Continue Import
          </Button>
        </div>
      </div>
    </div>
  )
}

export default SocialImportAuthPrompt
