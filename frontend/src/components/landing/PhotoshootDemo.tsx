/**
 * PhotoshootDemo Component
 *
 * Landing page demo for AI Photoshoot Generator.
 * - Single photo upload
 * - Generates 2 free aesthetic-style images for anonymous users
 * - IP-based rate limiting (2 images/day)
 */

import { useState, useCallback, useEffect } from 'react';
import { useDropzone } from 'react-dropzone';
import { Camera, Loader2, Download, AlertCircle, CheckCircle2, ArrowRight, AlertTriangle, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { GlassCard } from './GlassCard';
import { LoginPromptModal } from './LoginPromptModal';
import { demoPhotoshoot, DemoPhotoshootResult, DemoApiError } from '@/api/demo';

type DemoState = 'idle' | 'processing' | 'results' | 'error';

function isDemoApiError(err: unknown): err is DemoApiError {
  return (
    typeof err === 'object' &&
    err !== null &&
    'message' in err &&
    typeof (err as DemoApiError).message === 'string'
  );
}

export function PhotoshootDemo() {
  const [state, setState] = useState<DemoState>('idle');
  const [photo, setPhoto] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [result, setResult] = useState<DemoPhotoshootResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [retryingFailedIndex, setRetryingFailedIndex] = useState<number | null>(null);

  // Cleanup object URL when photo changes or component unmounts
  useEffect(() => {
    return () => {
      if (photoPreview) {
        URL.revokeObjectURL(photoPreview);
      }
    };
  }, [photoPreview]);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      // Revoke previous URL if exists
      if (photoPreview) {
        URL.revokeObjectURL(photoPreview);
      }
      setPhoto(file);
      setPhotoPreview(URL.createObjectURL(file));
      setError(null);
    }
  }, [photoPreview]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp'] },
    maxFiles: 1,
    disabled: state === 'processing',
  });

  const handleGenerate = async () => {
    if (!photo) return;

    setState('processing');
    setError(null);

    try {
      const response = await demoPhotoshoot(photo);
      setResult(response);
      setState('results');
    } catch (err) {
      const errorMessage = isDemoApiError(err)
        ? err.isRateLimit
          ? 'Daily demo limit reached. Sign up for 10 free images per day!'
          : err.message || 'Failed to generate images'
        : 'Failed to generate images';
      setError(errorMessage);
      setState('error');
    }
  };

  const handleDownload = async (imageData: string, index: number) => {
    try {
      const response = await fetch(imageData);
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `photoshoot_demo_${index + 1}.png`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (e) {
      console.error('Download failed:', e);
    }
  };

  const getImageSrc = (img: DemoPhotoshootResult['images'][number]) => {
    if (img.image_url) return img.image_url
    if (img.image_base64) return `data:image/png;base64,${img.image_base64}`
    return ''
  }

  const handleReset = () => {
    // Revoke object URL before clearing
    if (photoPreview) {
      URL.revokeObjectURL(photoPreview);
    }
    setState('idle');
    setPhoto(null);
    setPhotoPreview(null);
    setResult(null);
    setError(null);
    setRetryingFailedIndex(null);
  };

  const failedIndices = result?.image_failures?.map((f) => f.index).sort((a, b) => a - b) ?? [];
  const failedCount = result?.failed_count ?? 0;

  const retryFailedSlot = async (failedIndex: number) => {
    if (!photo) return;

    setRetryingFailedIndex(failedIndex);
    setError(null);

    try {
      const retryResult = await demoPhotoshoot(photo);
      const replacement = retryResult.images[0];

      if (replacement && result) {
        const nextImages = [...result.images, { ...replacement, index: failedIndex }]
          .filter((img, i, arr) => arr.findIndex((x) => x.index === img.index) === i)
          .sort((a, b) => a.index - b.index);

        const nextFailed = failedIndices.filter((i) => i !== failedIndex);

        setResult({
          ...result,
          images: nextImages,
          failed_count: nextFailed.length,
          partial_success: nextFailed.length > 0,
          image_failures: nextFailed.map((index) => ({ index, error: '' })),
          remaining_today: retryResult.remaining_today,
        });
      }
    } catch (err) {
      const errorMessage = isDemoApiError(err)
        ? err.isRateLimit
          ? 'Daily demo limit reached. Sign up for 10 free images per day!'
          : err.message || 'Retry failed'
        : 'Retry failed';
      setError(errorMessage);
      setState('error');
    } finally {
      setRetryingFailedIndex(null);
    }
  };

  return (
    <GlassCard className="p-6 h-full flex flex-col">
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
          <Camera className="w-5 h-5 text-white" />
        </div>
        <div>
          <h3 className="font-semibold text-gray-900 dark:text-white">AI Photoshoot</h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">2 free images</p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Idle State - No Photo */}
        {state === 'idle' && !photo && (
          <div
            {...getRootProps()}
            className={`h-full border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
              isDragActive
                ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/20'
                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400'
            }`}
          >
            <input {...getInputProps()} />
            <Camera className="w-10 h-10 text-gray-400 mb-4" />
            <p className="text-gray-700 dark:text-gray-300 font-medium mb-1">
              {isDragActive ? 'Drop your photo here' : 'Upload your photo'}
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Clear face photo for best results
            </p>
          </div>
        )}

        {/* Idle State - With Photo */}
        {state === 'idle' && photo && photoPreview && (
          <div className="h-full flex flex-col">
            {/* Success banner showing uploaded photo */}
            <div className="flex items-center gap-3 mb-4 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg">
              <img
                src={photoPreview}
                alt="Your photo"
                className="w-12 h-12 rounded-lg object-cover"
              />
              <div className="flex-1">
                <p className="text-sm font-medium text-green-700 dark:text-green-300">
                  Photo uploaded
                </p>
                <button
                  className="text-xs text-green-600 hover:underline"
                  onClick={handleReset}
                >
                  Change photo
                </button>
              </div>
            </div>

            {/* Generate Button - centered in remaining space */}
            <div className="flex-1 flex flex-col items-center justify-center">
              <p className="text-gray-600 dark:text-gray-400 mb-4 text-center">
                Ready to generate 2 AI-styled photos
              </p>
              <Button
                onClick={handleGenerate}
                className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
              >
                Generate 2 Images
              </Button>
            </div>
          </div>
        )}

      {/* Processing State */}
      {state === 'processing' && (
        <div className="h-full flex flex-col items-center justify-center">
          {photoPreview && (
            <img
              src={photoPreview}
              alt="Preview"
              className="max-h-48 rounded-lg mb-4 object-contain"
            />
          )}
          <Loader2 className="w-8 h-8 text-purple-500 animate-spin mb-2" />
          <p className="text-gray-600 dark:text-gray-400">
            Creating your AI photos...
          </p>
          <p className="text-xs text-gray-400 mt-1">
            This may take 20-30 seconds
          </p>
        </div>
      )}

      {/* Results State */}
      {state === 'results' && result && (
        <div className="space-y-4">
          <div className="flex items-center gap-2 text-green-600">
            <CheckCircle2 className="w-5 h-5" />
            <span className="text-sm font-medium">{result.images.length} images generated!</span>
          </div>

          {result.partial_success && failedCount > 0 && (
            <div className="flex items-start gap-2 rounded-lg border border-amber-300 bg-amber-50 p-3 text-amber-900">
              <AlertTriangle className="mt-0.5 h-4 w-4" />
              <p className="text-xs">
                {failedCount} slot{failedCount > 1 ? 's' : ''} failed. Retry each failed slot.
              </p>
            </div>
          )}

          {/* Image Grid */}
          <div className="grid grid-cols-2 gap-3">
            {result.images.map((img, idx) => (
              <div key={img.id} className="relative group">
                <img
                  src={getImageSrc(img)}
                  alt={`Generated ${idx + 1}`}
                  className="w-full aspect-[3/4] object-cover rounded-lg"
                />
                <button
                  onClick={() => handleDownload(getImageSrc(img), idx)}
                  className="absolute bottom-2 right-2 p-2 bg-white/90 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <Download className="w-4 h-4 text-gray-700" />
                </button>
              </div>
            ))}

            {failedIndices.map((failedIndex) => (
              <div
                key={`demo-failed-${failedIndex}`}
                className="aspect-[3/4] rounded-lg border border-dashed border-amber-300 bg-amber-50/60 p-3 flex flex-col justify-between"
              >
                <div>
                  <div className="mb-2 inline-flex rounded-full bg-amber-100 px-2 py-1 text-xs font-medium text-amber-800">
                    Failed #{failedIndex + 1}
                  </div>
                  <p className="text-xs text-amber-800">Retry to generate this slot.</p>
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  className="border-amber-300"
                  disabled={retryingFailedIndex !== null}
                  onClick={() => void retryFailedSlot(failedIndex)}
                >
                  <RotateCcw className="w-4 h-4 mr-2" />
                  {retryingFailedIndex === failedIndex ? 'Retrying...' : 'Retry'}
                </Button>
              </div>
            ))}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={handleReset}>
              Try Another
            </Button>
            <Button
              size="sm"
              className="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
              onClick={() => setShowLoginModal(true)}
            >
              Get More Images
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

      {/* Login Modal */}
      <LoginPromptModal
        isOpen={showLoginModal}
        onClose={() => setShowLoginModal(false)}
        feature="get 10 free AI photoshoot images per day"
      />
    </GlassCard>
  );
}
