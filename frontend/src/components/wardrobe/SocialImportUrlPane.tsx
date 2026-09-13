import { useState } from 'react'
import { Link2, Loader2 } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

interface SocialImportUrlPaneProps {
  isLoading?: boolean
  error?: string | null
  onStart: (url: string) => Promise<void>
}

export function SocialImportUrlPane({ isLoading = false, error, onStart }: SocialImportUrlPaneProps) {
  const [url, setUrl] = useState('')

  const handleStart = async () => {
    if (!url.trim()) return
    await onStart(url.trim())
  }

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-dashed border-tint-violet/40 bg-tint-violet-pale/30 p-4">
        <div className="flex items-start gap-3">
          <div className="rounded-md bg-tint-violet-pale p-2 text-tint-violet">
            <Link2 className="h-4 w-4" />
          </div>
          <div className="space-y-1">
            <p className="text-sm font-semibold text-foreground">Import from Instagram or Facebook URL</p>
            <p className="text-xs text-muted-foreground">
              Paste a profile URL. We will discover photos, process them one-by-one, and keep the next result ready in background.
            </p>
          </div>
        </div>
      </div>

      <div className="space-y-2">
        <label htmlFor="social-profile-url" className="text-sm font-medium text-foreground">
          Profile URL
        </label>
        <Input
          id="social-profile-url"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="https://www.instagram.com/username/"
          disabled={isLoading}
          autoComplete="off"
        />
      </div>

      {error && (
        <div className="rounded-md border border-destructive/30 bg-error-pale px-3 py-2 text-sm text-error">
          {error}
        </div>
      )}

      <div className="flex justify-end">
        <Button onClick={handleStart} disabled={isLoading || !url.trim()}>
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Starting...
            </>
          ) : (
            'Start Import'
          )}
        </Button>
      </div>
    </div>
  )
}

export default SocialImportUrlPane
