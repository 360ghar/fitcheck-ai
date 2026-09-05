/**
 * TryOnDemo Component
 *
 * Handles the virtual try-on demo flow:
 * 1. Upload person photo
 * 2. Upload outfit/clothing photo
 * 3. Show loading state
 * 4. Display generated try-on result
 */

import { useState, useCallback, useEffect } from 'react'
import { useDropzone } from 'react-dropzone'
import {
  Wand2,
  Loader2,
  AlertCircle,
  User,
  Shirt,
  ArrowRight,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { EditorialPanel } from './EditorialPanel'
import { LoginPromptModal } from './LoginPromptModal'
import { demoTryOn, DemoTryOnResult, DemoApiError } from '@/api/demo'

type DemoState = 'person' | 'outfit' | 'processing' | 'results' | 'error'

export function TryOnDemo() {
  const [state, setState] = useState<DemoState>('person')
  const [personFile, setPersonFile] = useState<File | null>(null)
  const [personPreview, setPersonPreview] = useState<string | null>(null)
  const [outfitPreview, setOutfitPreview] = useState<string | null>(null)
  const [result, setResult] = useState<DemoTryOnResult | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [showLoginModal, setShowLoginModal] = useState(false)

  // Blob URLs leak unless revoked: revoke each preview when it is replaced
  // and on unmount. One effect per URL so replacing one never revokes the
  // other while it is still rendered.
  useEffect(() => {
    return () => {
      if (personPreview) URL.revokeObjectURL(personPreview)
    }
  }, [personPreview])
  useEffect(() => {
    return () => {
      if (outfitPreview) URL.revokeObjectURL(outfitPreview)
    }
  }, [outfitPreview])

  const onDropPerson = useCallback((acceptedFiles: File[]) => {
    if (acceptedFiles.length === 0) return

    const file = acceptedFiles[0]
    setPersonFile(file)
    setPersonPreview(URL.createObjectURL(file))
    setState('outfit')
  }, [])

  const onDropOutfit = useCallback(
    async (acceptedFiles: File[]) => {
      if (acceptedFiles.length === 0 || !personFile) return

      const file = acceptedFiles[0]
      setOutfitPreview(URL.createObjectURL(file))
      setState('processing')
      setError(null)

      try {
        const tryOnResult = await demoTryOn(personFile, file)
        setResult(tryOnResult)
        setState('results')
      } catch (err) {
        const demoError = err as DemoApiError
        setError(
          demoError.isRateLimit
            ? 'Daily demo limit reached. Sign up free to keep using try-on.'
            : demoError.message || 'Failed to generate try-on'
        )
        setState('error')
      }
    },
    [personFile]
  )

  const personDropzone = useDropzone({
    onDrop: onDropPerson,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.heic', '.heif', '.bmp', '.tif', '.tiff'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const outfitDropzone = useDropzone({
    onDrop: onDropOutfit,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.heic', '.heif', '.bmp', '.tif', '.tiff'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const handleReset = () => {
    setPersonFile(null)
    setPersonPreview(null)
    setOutfitPreview(null)
    setResult(null)
    setError(null)
    setState('person')
  }

  return (
    <EditorialPanel className="p-6 h-full flex flex-col">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-secondary flex items-center justify-center">
          <Wand2 className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="text-lg font-semibold tracking-tight text-foreground">
            Virtual try-on
          </h3>
          <p className="text-sm text-muted-foreground">
            See yourself in any outfit
          </p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Step 1: Upload Person Photo */}
        {state === 'person' && (
          <div
            {...personDropzone.getRootProps()}
            className={cn(
              'h-full rounded-xl border border-dashed bg-surface-card p-8 text-center cursor-pointer flex flex-col items-center justify-center',
              'transition-[border-color,background-color] duration-200 hover:border-ash',
              personDropzone.isDragActive ? 'border-primary bg-secondary' : 'border-ash'
            )}
          >
            <input {...personDropzone.getInputProps({ 'aria-label': 'Upload your photo' })} />
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-secondary">
              <User className={cn('h-5 w-5 text-primary transition-transform duration-200', personDropzone.isDragActive && 'scale-110')} />
            </div>
            <p className="text-body font-medium mb-1">
              Step 1: Upload your photo
            </p>
            <p className="text-sm text-muted-foreground">
              A clear full-body or half-body photo works best
            </p>
          </div>
        )}

        {/* Step 2: Upload Outfit Photo */}
        {state === 'outfit' && (
          <div className="h-full flex flex-col">
            <div className="flex items-center gap-3 mb-4 p-3 bg-success-pale rounded-lg">
              {personPreview && (
                <img
                  src={personPreview}
                  alt="You"
                  className="w-12 h-12 rounded-lg object-cover"
                />
              )}
              <div className="flex-1">
                <p className="text-sm font-medium text-success">
                  Your photo uploaded
                </p>
                <button
                  type="button"
                  className="text-xs text-success hover:underline"
                  onClick={handleReset}
                >
                  Change photo
                </button>
              </div>
            </div>

            <div
              {...outfitDropzone.getRootProps()}
              className={cn(
                'flex-1 rounded-xl border border-dashed bg-surface-card p-8 text-center cursor-pointer flex flex-col items-center justify-center',
                'transition-[border-color,background-color] duration-200 hover:border-ash',
                outfitDropzone.isDragActive ? 'border-primary bg-secondary' : 'border-ash'
              )}
            >
              <input {...outfitDropzone.getInputProps({ 'aria-label': 'Upload an outfit to try on' })} />
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-secondary">
                <Shirt className={cn('h-5 w-5 text-primary transition-transform duration-200', outfitDropzone.isDragActive && 'scale-110')} />
              </div>
              <p className="text-body font-medium mb-1">
                Step 2: Upload outfit to try on
              </p>
              <p className="text-sm text-muted-foreground">
                Drop a clothing image or outfit photo
              </p>
            </div>
          </div>
        )}

        {/* Processing State */}
        {state === 'processing' && (
          <div className="h-full flex flex-col items-center justify-center">
            <div className="flex gap-4 mb-6">
              {personPreview && (
                <img
                  src={personPreview}
                  alt="You"
                  className="w-20 h-20 rounded-lg object-cover"
                />
              )}
              <span className="text-2xl text-ash self-center">+</span>
              {outfitPreview && (
                <img
                  src={outfitPreview}
                  alt="Outfit"
                  className="w-20 h-20 rounded-lg object-cover"
                />
              )}
            </div>
            <Loader2 className="w-8 h-8 text-primary animate-spin mb-2" />
            <p className="text-body">
              Creating your look...
            </p>
            <p className="text-xs text-muted-foreground mt-1">
              Generation time can vary. You can keep exploring while this runs.
            </p>
          </div>
        )}

        {/* Results State */}
        {state === 'results' && result && (
          <div className="h-full flex flex-col">
            <div className="flex-1 flex items-center justify-center mb-4">
              <img
                src={`data:image/png;base64,${result.image_base64}`}
                alt="Try-on result"
                className="max-h-64 rounded-xl object-contain"
              />
            </div>

            <div className="flex flex-wrap gap-2">
              <Button variant="outline" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                className="flex-1 bg-primary text-primary-foreground hover:bg-primary-pressed"
                onClick={() => setShowLoginModal(true)}
              >
                Save & continue free
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
        feature="save try-ons and keep building outfits free"
      />
    </EditorialPanel>
  )
}
