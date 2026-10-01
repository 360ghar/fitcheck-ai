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
import { trackLandingCta } from '@/lib/analytics'
import { SIGNATURE_ITEMS } from './signature-data'
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
    trackLandingCta('demo-play', { demo: 'extraction' })

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
        <div className="flex shrink-0 items-center">
          <Camera className="h-5 w-5 text-paper-accent" />
        </div>
        <div>
          <h3 className="text-lg font-semibold tracking-tight text-paper-text">Item extraction</h3>
          <p className="text-sm text-paper-text-3">Upload a photo to detect clothing</p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Idle State: a real example result (the hero photo) over a drop zone
            that covers the whole area, so a click or a drop starts a run. */}
        {state === 'idle' && (
          <div
            {...getRootProps()}
            className={cn(
              'flex h-full cursor-pointer flex-col rounded-xl border border-dashed border-paper-edge bg-paper-sunk/60 p-4',
              'transition-[border-color,background-color] duration-200 hover:border-paper-accent/60 hover:bg-paper-tint',
              isDragActive && 'border-paper-accent bg-paper-tint'
            )}
          >
            <input {...getInputProps({ 'aria-label': 'Upload a clothing photo' })} />
            <div className="flex items-center gap-3">
              <img
                src="/signature/pile-160.webp"
                alt="Example photo: six clothes on a bed"
                width={160}
                height={120}
                loading="lazy"
                decoding="async"
                className="h-16 w-20 shrink-0 rounded-lg object-cover"
              />
              <div className="min-w-0">
                <p className="text-xs text-paper-text-3">Example result</p>
                <p className="text-sm font-semibold text-paper-text">
                  Found {SIGNATURE_ITEMS.length} items
                </p>
              </div>
            </div>
            <ul className="mt-3 space-y-1.5">
              {SIGNATURE_ITEMS.slice(0, 4).map((item) => (
                <li key={item.key} className="flex items-baseline justify-between gap-3 text-sm">
                  <span className="font-medium text-paper-text">{item.name}</span>
                  <span className="truncate text-xs text-paper-text-3">{item.colors}</span>
                </li>
              ))}
              <li className="text-xs text-paper-text-3">and {SIGNATURE_ITEMS.length - 4} more</li>
            </ul>
            <p className="mt-auto flex items-center justify-center gap-2 pt-5 font-semibold text-paper-text">
              <Upload
                className={cn('h-4 w-4 text-paper-accent transition-transform duration-200', isDragActive && 'scale-110')}
                aria-hidden="true"
              />
              {isDragActive ? 'Drop your photo here' : 'Try it with your photo'}
            </p>
            <p className="mt-1 text-center text-xs text-paper-text-3">Drop a clothing photo or click to browse</p>
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
            <Loader2 className="w-8 h-8 text-paper-accent animate-spin mb-2" />
            <p className="text-paper-text-2">
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
                <p className="text-sm text-paper-text-3">
                  Found {results.item_count} item
                  {results.item_count !== 1 ? 's' : ''}
                </p>
                <p className="text-xs text-paper-text-3">
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
              <Button variant="ghost" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                className="flex-1"
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
          <div className="flex h-full flex-col items-center justify-center rounded-xl bg-error-pale p-6 text-center">
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
    <div className="flex items-center gap-3 rounded-lg bg-paper-sunk p-3">
      <div className="flex shrink-0 items-center">
        <Shirt className="h-4 w-4 text-paper-accent" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-medium text-paper-text text-sm capitalize">
          {item.sub_category || item.category}
        </p>
        <div className="flex items-center gap-2 text-xs text-paper-text-3">
          {item.colors.length > 0 && (
            <span className="capitalize">{item.colors.slice(0, 2).join(', ')}</span>
          )}
          {item.material && <span>{item.material}</span>}
        </div>
      </div>
      <span className="text-xs text-paper-text-3">
        {Math.round(item.confidence * 100)}%
      </span>
    </div>
  )
}
