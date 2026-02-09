import { useState } from 'react'
import { KeyRound, ShieldCheck } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

interface SocialImportAuthPromptProps {
  isLoading?: boolean
  error?: string | null
  onSubmitOAuth: (payload: {
    provider_access_token: string
    provider_refresh_token?: string
    provider_user_id?: string
  }) => Promise<void>
  onSubmitScraper: (payload: { username: string; password: string; otp_code?: string }) => Promise<void>
}

export function SocialImportAuthPrompt({
  isLoading = false,
  error,
  onSubmitOAuth,
  onSubmitScraper,
}: SocialImportAuthPromptProps) {
  const [oauthToken, setOauthToken] = useState('')
  const [oauthRefreshToken, setOauthRefreshToken] = useState('')
  const [oauthUserId, setOauthUserId] = useState('')

  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [otpCode, setOtpCode] = useState('')

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm text-amber-800 dark:border-amber-900/40 dark:bg-amber-950/20 dark:text-amber-300">
        This profile requires login. Choose Meta OAuth token import or scraper login fallback.
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700 dark:border-red-900/50 dark:bg-red-950/20 dark:text-red-300">
          {error}
        </div>
      )}

      <div className="grid gap-3 rounded-lg border border-border p-4">
        <div className="flex items-center gap-2">
          <ShieldCheck className="h-4 w-4 text-indigo-500" />
          <p className="text-sm font-semibold text-foreground">Meta OAuth Token</p>
        </div>
        <Input
          value={oauthToken}
          onChange={(e) => setOauthToken(e.target.value)}
          placeholder="Provider access token"
          disabled={isLoading}
          autoComplete="off"
        />
        <Input
          value={oauthRefreshToken}
          onChange={(e) => setOauthRefreshToken(e.target.value)}
          placeholder="Provider refresh token (optional)"
          disabled={isLoading}
          autoComplete="off"
        />
        <Input
          value={oauthUserId}
          onChange={(e) => setOauthUserId(e.target.value)}
          placeholder="Provider user id (optional)"
          disabled={isLoading}
          autoComplete="off"
        />
        <div className="flex justify-end">
          <Button
            variant="outline"
            disabled={isLoading || !oauthToken.trim()}
            onClick={() =>
              onSubmitOAuth({
                provider_access_token: oauthToken.trim(),
                provider_refresh_token: oauthRefreshToken.trim() || undefined,
                provider_user_id: oauthUserId.trim() || undefined,
              })
            }
          >
            Use OAuth Token
          </Button>
        </div>
      </div>

      <div className="grid gap-3 rounded-lg border border-border p-4">
        <div className="flex items-center gap-2">
          <KeyRound className="h-4 w-4 text-indigo-500" />
          <p className="text-sm font-semibold text-foreground">Scraper Login Fallback</p>
        </div>
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
