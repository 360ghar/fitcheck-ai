/**
 * ExtractionDemo Component
 *
 * Handles the item extraction demo flow:
 * 1. Upload image with dropzone
 * 2. Show loading state
 * 3. Display extracted items
 * 4. CTA to save to wardrobe (prompts login)
 */

import { useState, useCallback } from 'react'
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
import { GlassCard } from './GlassCard'
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
          ? 'Daily demo limit reached. Sign up for unlimited access!'
          : demoError.message || 'Failed to analyze image'
      )
      setState('error')
    }
  }, [])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const handleReset = () => {
    if (previewUrl) URL.revokeObjectURL(previewUrl)
    setPreviewUrl(null)
    setResults(null)
    setError(null)
    setState('idle')
  }

  const handleSaveToWardrobe = () => {
    setShowLoginModal(true)
  }

  return (
    <GlassCard className="p-6 h-full flex flex-col">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-gold-400 to-gold-600 flex items-center justify-center">
          <Camera className="w-5 h-5 text-navy-900" />
        </div>
        <div>
          <h3 className="font-semibold text-navy-800 dark:text-white">
            AI Item Extraction
          </h3>
          <p className="text-sm text-navy-400 dark:text-navy-400">
            Upload a photo to detect clothing
          </p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Idle State - Dropzone */}
        {state === 'idle' && (
          <div
            {...getRootProps()}
            className={`h-full border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
              isDragActive
                ? 'border-gold-400 bg-gold-50 dark:bg-gold-900/20'
                : 'border-navy-200 dark:border-navy-600 hover:border-navy-300'
            }`}
          >
            <input {...getInputProps()} />
            <Upload className="w-10 h-10 text-navy-300 mb-4" />
            <p className="text-navy-700 dark:text-navy-200 font-medium mb-1">
              {isDragActive ? 'Drop your photo here' : 'Drop a clothing photo'}
            </p>
            <p className="text-sm text-navy-400 dark:text-navy-400">
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
            <Loader2 className="w-8 h-8 text-gold-500 animate-spin mb-2" />
            <p className="text-navy-500 dark:text-navy-300">
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
                <p className="text-sm text-navy-400 dark:text-navy-400">
                  Found {results.item_count} item
                  {results.item_count !== 1 ? 's' : ''}
                </p>
                <p className="text-xs text-navy-300">
                  {Math.round(results.overall_confidence * 100)}% confidence
                </p>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto space-y-3 mb-4">
              {results.items.map((item, idx) => (
                <ExtractedItemCard key={idx} item={item} />
              ))}
            </div>

            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                variant="gold"
                className="flex-1"
                onClick={handleSaveToWardrobe}
              >
                Save to Wardrobe
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            </div>
          </div>
        )}

        {/* Error State */}
        {state === 'error' && (
          <div className="h-full flex flex-col items-center justify-center text-center">
            <AlertCircle className="w-10 h-10 text-red-500 mb-4" />
            <p className="text-red-600 dark:text-red-400 mb-4">{error}</p>
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
    </GlassCard>
  )
}

function ExtractedItemCard({ item }: { item: DemoDetectedItem }) {
  return (
    <div className="flex items-center gap-3 p-3 bg-navy-50 dark:bg-navy-800 rounded-lg">
      <div className="w-8 h-8 rounded bg-navy-800 dark:bg-navy-700 flex items-center justify-center">
        <Shirt className="w-4 h-4 text-white" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-medium text-navy-800 dark:text-white text-sm capitalize">
          {item.sub_category || item.category}
        </p>
        <div className="flex items-center gap-2 text-xs text-navy-400 dark:text-navy-400">
          {item.colors.length > 0 && (
            <span className="capitalize">{item.colors.slice(0, 2).join(', ')}</span>
          )}
          {item.material && <span>{item.material}</span>}
        </div>
      </div>
      <span className="text-xs text-navy-300">
        {Math.round(item.confidence * 100)}%
      </span>
    </div>
  )
}
