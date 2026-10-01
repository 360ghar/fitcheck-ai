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
import { GeneratedImage } from '@/components/ui/generated-image'
import { cn } from '@/lib/utils'
import { trackLandingCta } from '@/lib/analytics'
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
      trackLandingCta('demo-play', { demo: 'try-on' })

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
        <div className="flex shrink-0 items-center">
          <Wand2 className="h-5 w-5 text-paper-accent" />
        </div>
        <div>
          <h3 className="text-lg font-semibold tracking-tight text-paper-text">
            Virtual try-on
          </h3>
          <p className="text-sm text-paper-text-3">
            See yourself in any outfit
          </p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Step 1: Upload Person Photo */}
        {state === 'person' && (
          <div className="flex h-full flex-col gap-3">
            <figure className="flex shrink-0 items-center gap-3 rounded-xl bg-paper-sunk/60 p-3">
              <GeneratedImage
                src="/generated/demo-beforeafter-base-4x3-640.webp"
                alt=""
                aria-hidden="true"
                className="h-20 w-16 shrink-0 rounded-lg object-cover"
                loading="lazy"
                fallback="hide-figure"
              />
              <figcaption className="text-xs leading-relaxed text-paper-text-3">
                <span className="font-semibold text-paper-text">Example input.</span>{' '}
                A clear full-body photo like this works best. Your result is generated from your own
                photo.
              </figcaption>
            </figure>
            <div
              {...personDropzone.getRootProps()}
              className={cn(
                'flex min-h-0 flex-1 cursor-pointer flex-col items-center justify-center rounded-xl border border-dashed border-paper-edge bg-paper-sunk/60 p-8 text-center',
                'transition-[border-color,background-color] duration-200 hover:border-paper-accent/60 hover:bg-paper-tint',
                personDropzone.isDragActive && 'border-paper-accent bg-paper-tint'
              )}
            >
              <input {...personDropzone.getInputProps({ 'aria-label': 'Upload your photo' })} />
              <div className="mb-3 flex items-center justify-center">
                <User className={cn('h-5 w-5 text-paper-accent transition-transform duration-200', personDropzone.isDragActive && 'scale-110')} />
              </div>
              <p className="text-paper-text-2 font-medium mb-1">
                Step 1: Upload your photo
              </p>
              <p className="text-sm text-paper-text-3">
                A clear full-body or half-body photo works best
              </p>
            </div>
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
                'flex flex-1 cursor-pointer flex-col items-center justify-center rounded-xl border border-dashed border-paper-edge bg-paper-sunk/60 p-8 text-center',
                'transition-[border-color,background-color] duration-200 hover:border-paper-accent/60 hover:bg-paper-tint',
                outfitDropzone.isDragActive && 'border-paper-accent bg-paper-tint'
              )}
            >
              <input {...outfitDropzone.getInputProps({ 'aria-label': 'Upload an outfit to try on' })} />
              <div className="mb-3 flex items-center justify-center">
                <Shirt className={cn('h-5 w-5 text-paper-accent transition-transform duration-200', outfitDropzone.isDragActive && 'scale-110')} />
              </div>
              <p className="text-paper-text-2 font-medium mb-1">
                Step 2: Upload outfit to try on
              </p>
              <p className="text-sm text-paper-text-3">
                Drop a clothing image or outfit photo
              </p>
            </div>
          </div>
        )}

        {/* Processing State */}
        {state === 'processing' && (
          <div className="h-full flex flex-col items-center justify-center">
            <div className="mb-6 flex gap-4">
              {personPreview && (
                <img
                  src={personPreview}
                  alt="You"
                  className="h-20 w-20 rounded-lg object-cover shadow-slab"
                />
              )}
              <span className="self-center text-2xl text-paper-text-3">+</span>
              {outfitPreview && (
                <img
                  src={outfitPreview}
                  alt="Outfit"
                  className="h-20 w-20 rounded-lg object-cover shadow-slab"
                />
              )}
            </div>
            <Loader2 className="w-8 h-8 text-paper-accent animate-spin mb-2" />
            <p className="text-paper-text-2">
              Creating your look...
            </p>
            <p className="text-xs text-paper-text-3 mt-1">
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
                className="max-h-64 rounded-xl object-contain shadow-slab"
              />
            </div>

            <div className="flex flex-wrap gap-2">
              <Button variant="ghost" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                className="flex-1"
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
