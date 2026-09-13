/**
 * ExtractionDemo Component
 *
 * Handles the item extraction demo flow:
 * 1. Upload image with dropzone
 * 2. Show loading state
 * 3. Display extracted items
 * 4. CTA to save to wardrobe (prompts login)
 */

import { useEffect, useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import {
  Camera,
  Upload,
  Loader2,
  AlertCircle,
  ArrowRight,
  Shirt,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { EditorialPanel } from './EditorialPanel'
import { LoginPromptModal } from './LoginPromptModal'
import {
  demoExtractItems,
  DemoDetectedItem,
  DemoExtractItemsResult,
  DemoApiError,
} from '@/api/demo'

type DemoState = 'idle' | 'processing' | 'results' | 'error'

export function ExtractionDemo() {
  const [state, setState] = useState<DemoState>('idle')
  const [previewUrl, setPreviewUrl] = useState<string | null>(null)
  const [results, setResults] = useState<DemoExtractItemsResult | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [showLoginModal, setShowLoginModal] = useState(false)

  // Blob URLs leak unless revoked: revoke the previous preview whenever it is
  // replaced (including reset to null) and on unmount.
  useEffect(() => {
    return () => {
      if (previewUrl) URL.revokeObjectURL(previewUrl)
    }
  }, [previewUrl])

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    if (acceptedFiles.length === 0) return

    const file = acceptedFiles[0]
    const url = URL.createObjectURL(file)
    setPreviewUrl(url)
    setState('processing')
    setError(null)

    try {
      const result = await demoExtractItems(file)
      setResults(result)
      setState('results')
    } catch (err) {
      const demoError = err as DemoApiError
      setError(
        demoError.isRateLimit
          ? 'Daily demo limit reached. Sign up free to keep using extraction.'
          : demoError.message || 'Failed to analyze image'
      )
      setState('error')
    }
  }, [])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.heic', '.heif', '.bmp', '.tif', '.tiff'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const handleReset = () => {
    // Revocation is centralized in the previewUrl cleanup effect above.
    setPreviewUrl(null)
    setResults(null)
    setError(null)
    setState('idle')
  }

  const handleSaveToWardrobe = () => {
    setShowLoginModal(true)
  }

  return (
    <EditorialPanel className="p-6 h-full flex flex-col">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-secondary flex items-center justify-center">
          <Camera className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="text-lg font-semibold tracking-tight text-foreground">Item extraction</h3>
          <p className="text-sm text-muted-foreground">Upload a photo to detect clothing</p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Idle State - Dropzone */}
        {state === 'idle' && (
          <div
            {...getRootProps()}
            className={cn(
              'h-full rounded-xl border border-dashed bg-surface-card p-8 text-center cursor-pointer flex flex-col items-center justify-center',
              'transition-[border-color,background-color] duration-200 hover:border-ash',
              isDragActive ? 'border-primary bg-secondary' : 'border-ash'
            )}
          >
            <input {...getInputProps({ 'aria-label': 'Upload a clothing photo' })} />
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-secondary">
              <Upload className={cn('h-5 w-5 text-primary transition-transform duration-200', isDragActive && 'scale-110')} />
            </div>
            <p className="text-body font-medium mb-1">
              {isDragActive ? 'Drop your photo here' : 'Drop a clothing photo'}
            </p>
            <p className="text-sm text-muted-foreground">
              or click to browse
            </p>
          </div>
        )}

        {/* Processing State */}
        {state === 'processing' && previewUrl && (
          <div className="h-full flex flex-col items-center justify-center">
            <img
              src={previewUrl}
              alt="Preview"
              className="max-h-48 rounded-lg mb-4 object-contain"
            />
            <Loader2 className="w-8 h-8 text-primary animate-spin mb-2" />
            <p className="text-body">
              Analyzing clothing items...
            </p>
          </div>
        )}

        {/* Results State */}
        {state === 'results' && results && (
          <div className="h-full flex flex-col">
            <div className="flex gap-4 mb-4">
              {previewUrl && (
                <img
                  src={previewUrl}
                  alt="Original"
                  className="w-20 h-20 rounded-lg object-cover"
                />
              )}
              <div>
                <p className="text-sm text-muted-foreground">
                  Found {results.item_count} item
                  {results.item_count !== 1 ? 's' : ''}
                </p>
                <p className="text-xs text-ash">
                  {Math.round(results.overall_confidence * 100)}% confidence
                </p>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto space-y-3 mb-4">
              {results.items.map((item, idx) => (
                <ExtractedItemCard key={idx} item={item} />
              ))}
            </div>

            <div className="flex flex-wrap gap-2">
              <Button variant="outline" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                className="flex-1 bg-primary hover:bg-primary-pressed text-white"
                onClick={handleSaveToWardrobe}
              >
                Save to Closet
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            </div>
          </div>
        )}

        {/* Error State */}
        {state === 'error' && (
          <div className="h-full flex flex-col items-center justify-center text-center rounded-xl bg-error-pale p-6">
            <AlertCircle className="w-10 h-10 text-error mb-4" />
            <p className="text-error mb-4">{error}</p>
            <Button variant="outline" onClick={handleReset}>
              Try Again
            </Button>
          </div>
        )}
      </div>

      <LoginPromptModal
        isOpen={showLoginModal}
        onClose={() => setShowLoginModal(false)}
        feature="save items to your wardrobe"
      />
    </EditorialPanel>
  )
}

function ExtractedItemCard({ item }: { item: DemoDetectedItem }) {
  return (
    <div className="flex items-center gap-3 p-3 bg-secondary rounded-lg">
      <div className="w-8 h-8 rounded bg-surface-card flex items-center justify-center shrink-0">
        <Shirt className="h-4 w-4 text-primary" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-medium text-foreground text-sm capitalize">
          {item.sub_category || item.category}
        </p>
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          {item.colors.length > 0 && (
            <span className="capitalize">{item.colors.slice(0, 2).join(', ')}</span>
          )}
          {item.material && <span>{item.material}</span>}
        </div>
      </div>
      <span className="text-xs text-ash">
        {Math.round(item.confidence * 100)}%
      </span>
    </div>
  )
}
