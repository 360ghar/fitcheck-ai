/**
 * TryOnDemo Component
 *
 * Handles the virtual try-on demo flow:
 * 1. Upload person photo
 * 2. Upload outfit/clothing photo
 * 3. Show loading state
 * 4. Display generated try-on result
 */

import { useState, useCallback } from 'react'
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
import { GlassCard } from './GlassCard'
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
            ? 'Daily demo limit reached. Sign up for unlimited access!'
            : demoError.message || 'Failed to generate try-on'
        )
        setState('error')
      }
    },
    [personFile]
  )

  const personDropzone = useDropzone({
    onDrop: onDropPerson,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const outfitDropzone = useDropzone({
    onDrop: onDropOutfit,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp'] },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  const handleReset = () => {
    if (personPreview) URL.revokeObjectURL(personPreview)
    if (outfitPreview) URL.revokeObjectURL(outfitPreview)
    setPersonFile(null)
    setPersonPreview(null)
    setOutfitPreview(null)
    setResult(null)
    setError(null)
    setState('person')
  }

  return (
    <GlassCard className="p-6 h-full flex flex-col">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
          <Wand2 className="w-5 h-5 text-white" />
        </div>
        <div>
          <h3 className="font-semibold text-gray-900 dark:text-white">
            Virtual Try-On
          </h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            See yourself in any outfit
          </p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Step 1: Upload Person Photo */}
        {state === 'person' && (
          <div
            {...personDropzone.getRootProps()}
            className={`h-full border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
              personDropzone.isDragActive
                ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/20'
                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400'
            }`}
          >
            <input {...personDropzone.getInputProps()} />
            <User className="w-10 h-10 text-gray-400 mb-4" />
            <p className="text-gray-700 dark:text-gray-300 font-medium mb-1">
              Step 1: Upload your photo
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              A clear full-body or half-body photo works best
            </p>
          </div>
        )}

        {/* Step 2: Upload Outfit Photo */}
        {state === 'outfit' && (
          <div className="h-full flex flex-col">
            <div className="flex items-center gap-3 mb-4 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg">
              {personPreview && (
                <img
                  src={personPreview}
                  alt="You"
                  className="w-12 h-12 rounded-lg object-cover"
                />
              )}
              <div className="flex-1">
                <p className="text-sm font-medium text-green-700 dark:text-green-300">
                  Your photo uploaded
                </p>
                <button
                  className="text-xs text-green-600 hover:underline"
                  onClick={handleReset}
                >
                  Change photo
                </button>
              </div>
            </div>

            <div
              {...outfitDropzone.getRootProps()}
              className={`flex-1 border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
                outfitDropzone.isDragActive
                  ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/20'
                  : 'border-gray-300 dark:border-gray-600 hover:border-gray-400'
              }`}
            >
              <input {...outfitDropzone.getInputProps()} />
              <Shirt className="w-10 h-10 text-gray-400 mb-4" />
              <p className="text-gray-700 dark:text-gray-300 font-medium mb-1">
                Step 2: Upload outfit to try on
              </p>
              <p className="text-sm text-gray-500 dark:text-gray-400">
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
              <span className="text-2xl text-gray-400 self-center">+</span>
              {outfitPreview && (
                <img
                  src={outfitPreview}
                  alt="Outfit"
                  className="w-20 h-20 rounded-lg object-cover"
                />
              )}
            </div>
            <Loader2 className="w-8 h-8 text-purple-500 animate-spin mb-2" />
            <p className="text-gray-600 dark:text-gray-400">
              Creating your look...
            </p>
            <p className="text-xs text-gray-400 mt-1">
              This may take 20-30 seconds
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
                className="max-h-64 rounded-xl shadow-lg object-contain"
              />
            </div>

            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={handleReset}>
                Try Another
              </Button>
              <Button
                size="sm"
                className="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
                onClick={() => setShowLoginModal(true)}
              >
                Get Unlimited Access
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
        feature="get unlimited try-ons"
      />
    </GlassCard>
  )
}
