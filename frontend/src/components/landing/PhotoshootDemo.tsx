/**
 * PhotoshootDemo Component
 *
 * Landing page demo for AI Photoshoot Generator.
 * - Single photo upload
 * - Generates 2 free aesthetic-style images for anonymous users
 * - IP-based rate limiting (2 images/day)
 * - Job-based: POST returns a job_id, the card polls status every ~2.5s and
 *   shows partial images as they complete (no long-held HTTP request).
 */

import { useState, useCallback, useEffect, useRef } from 'react';
import { useDropzone } from 'react-dropzone';
import { Camera, Loader2, Download, AlertCircle, CheckCircle2, ArrowRight, AlertTriangle, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { logger } from '@/lib/logger';
import { EditorialPanel } from './EditorialPanel';
import { LoginPromptModal } from './LoginPromptModal';
import {
  demoPhotoshoot,
  getDemoPhotoshootStatus,
  DemoPhotoshootResult,
  DemoPhotoshootStatus,
  DemoApiError,
} from '@/api/demo';
import { ensureSessionRecording, trackEvent } from '@/lib/analytics';

type DemoState = 'idle' | 'processing' | 'results' | 'error';

const DEMO_POLL_INTERVAL_MS = 2500;
const DEMO_POLL_MAX_ATTEMPTS = 120; // ~5 minutes

/** True when two image lists hold the same images in the same order (id-based). */
function sameImageList(a: Array<{ id: string }>, b: Array<{ id: string }>) {
  return a.length === b.length && a.every((img, i) => img.id === b[i]?.id);
}

function isDemoApiError(err: unknown): err is DemoApiError {
  return (
    typeof err === 'object' &&
    err !== null &&
    'message' in err &&
    typeof (err as DemoApiError).message === 'string'
  );
}

async function handleDownload(imageData: string, index: number) {
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
    logger.error('Download failed:', e);
  }
}

function getImageSrc(img: { image_url?: string; image_base64?: string }) {
  if (img.image_url) return img.image_url
  if (img.image_base64) return `data:image/png;base64,${img.image_base64}`
  return ''
}

/**
 * Poll a demo job until a terminal state, streaming partial images via onProgress.
 * Pass an AbortSignal to stop polling (and the in-flight request) on unmount/reset.
 */
async function pollDemoJob(
  jobId: string,
  onProgress: (status: DemoPhotoshootStatus) => void,
  signal?: AbortSignal
): Promise<DemoPhotoshootStatus> {
  for (let attempt = 0; attempt < DEMO_POLL_MAX_ATTEMPTS; attempt++) {
    const status = await getDemoPhotoshootStatus(jobId, signal);
    onProgress(status);
    if (status.status === 'complete' || status.status === 'failed' || status.status === 'cancelled') {
      return status;
    }
    await new Promise((resolve) => setTimeout(resolve, DEMO_POLL_INTERVAL_MS));
    if (signal?.aborted) throw new DOMException('Aborted', 'AbortError');
  }
  throw new Error('Demo generation timed out. Please try again.');
}

export function PhotoshootDemo() {
  const [state, setState] = useState<DemoState>('idle');
  const [photo, setPhoto] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [result, setResult] = useState<DemoPhotoshootResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [retryingFailedIndex, setRetryingFailedIndex] = useState<number | null>(null);
  // Live progress while the job runs: partial images + count.
  const [partialImages, setPartialImages] = useState<DemoPhotoshootStatus['images']>([]);
  // Guards a stale poll from overwriting a newer run's state.
  const runIdRef = useRef(0);
  // Aborts the in-flight poll's network requests on reset/unmount.
  const abortRef = useRef<AbortController | null>(null);

  // Cleanup object URL + stop any in-flight poll when photo changes or component unmounts
  useEffect(() => {
    return () => {
      abortRef.current?.abort();
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
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.heic', '.heif', '.bmp', '.tif', '.tiff'] },
    maxFiles: 1,
    disabled: state === 'processing',
  });

  const handleGenerate = async () => {
    if (!photo) return;

    const runId = ++runIdRef.current;
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;
    setState('processing');
    setError(null);
    setPartialImages([]);
    ensureSessionRecording();
    trackEvent('photoshoot_session_started', {
      use_case: 'aesthetic',
      num_images: 2,
      photo_count: 1,
      source: 'web_demo',
    });

    try {
      const start = await demoPhotoshoot(photo);

      const final = await pollDemoJob(start.job_id, (status) => {
        if (runIdRef.current !== runId) return; // stale run
        // Skip no-op updates so unchanged ticks don't re-render the card.
        setPartialImages((prev) => {
          const next = status.images ?? [];
          return sameImageList(prev, next) ? prev : next;
        });
      }, controller.signal);

      if (runIdRef.current !== runId) return;

      if (final.status === 'failed') {
        throw new Error(final.error ?? 'Generation failed');
      }

      const failedIndices = final.failed_indices ?? [];
      const response: DemoPhotoshootResult = {
        session_id: final.job_id,
        status: final.status === 'complete' ? 'complete' : 'failed',
        images: (final.images ?? []).sort((a, b) => a.index - b.index),
        generated_count: final.generated_count,
        failed_count: final.failed_count,
        image_failures: failedIndices.map((index) => ({ index, error: '' })),
        partial_success: final.partial_success,
        remaining_today: start.remaining_today,
        signup_cta: start.signup_cta,
      };

      setResult(response);
      setState('results');
      trackEvent('photoshoot_session_completed', {
        session_id: response.session_id,
        use_case: 'aesthetic',
        num_images: 2,
        generated_count: response.generated_count ?? response.images?.length ?? 0,
        failed_count: response.failed_count ?? 0,
        partial_success: Boolean(response.partial_success),
        source: 'web_demo',
      });
    } catch (err) {
      if (runIdRef.current !== runId || controller.signal.aborted) return;
      const errorMessage = isDemoApiError(err)
        ? err.isRateLimit
          ? 'Daily demo limit reached. Sign up for 10 free images per day!'
          : err.message || 'Failed to generate images'
        : 'Failed to generate images';
      setError(errorMessage);
      setState('error');
      trackEvent('photoshoot_session_failed', {
        use_case: 'aesthetic',
        num_images: 2,
        error_message: errorMessage,
        is_rate_limit: isDemoApiError(err) ? Boolean(err.isRateLimit) : false,
        source: 'web_demo',
      });
    }
  };

  const handleReset = () => {
    runIdRef.current++; // invalidate any in-flight poll
    abortRef.current?.abort(); // ...and stop its network requests
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
    setPartialImages([]);
  };

  const failedIndices = result?.image_failures?.map((f) => f.index).sort((a, b) => a - b) ?? [];
  const failedCount = result?.failed_count ?? 0;

  const retryFailedSlot = async (failedIndex: number) => {
    if (!photo) return;

    const runId = ++runIdRef.current;
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;
    setRetryingFailedIndex(failedIndex);
    setError(null);

    try {
      const start = await demoPhotoshoot(photo);

      const final = await pollDemoJob(
        start.job_id,
        () => {
          // No live progress needed for the single-slot retry.
        },
        controller.signal
      );

      if (runIdRef.current !== runId) return;

      const replacement = (final.images ?? []).sort((a, b) => a.index - b.index)[0];

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
          remaining_today: start.remaining_today,
        });
      } else {
        setError('Could not generate replacement image');
      }
    } catch (err) {
      if (runIdRef.current !== runId || controller.signal.aborted) return;
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
    <EditorialPanel className="p-6 h-full flex flex-col">
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-primary flex items-center justify-center">
          <Camera className="w-5 h-5 text-white" />
        </div>
        <div>
          <h3 className="font-semibold text-stone-900 dark:text-stone-50">AI photoshoot</h3>
          <p className="text-sm text-stone-500 dark:text-stone-400">2 free images</p>
        </div>
      </div>

      <div className="flex-1 min-h-[300px]">
        {/* Idle State - No Photo */}
        {state === 'idle' && !photo && (
          <div
            {...getRootProps()}
            className={`h-full border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
              isDragActive
                ? 'border-primary bg-secondary'
                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400'
            }`}
          >
            <input {...getInputProps({ 'aria-label': 'Upload your photo' })} />
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
            <div className="flex items-center gap-3 mb-4 p-3 bg-success/10 rounded-lg">
              <img
                src={photoPreview}
                alt=""
                className="w-12 h-12 rounded-lg object-cover"
              />
              <div className="flex-1">
                <p className="text-sm font-medium text-success">
                  Photo uploaded
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

            {/* Generate Button - centered in remaining space */}
            <div className="flex-1 flex flex-col items-center justify-center">
              <p className="text-gray-600 dark:text-gray-400 mb-4 text-center">
                Ready to generate 2 AI-styled photos
              </p>
              <Button
                onClick={handleGenerate}
                className="bg-primary hover:bg-primary-pressed text-white"
              >
                Generate 2 Images
              </Button>
            </div>
          </div>
        )}

      {/* Processing State — live progress + partial images */}
      {state === 'processing' && (
        <div className="h-full flex flex-col items-center justify-center">
          {photoPreview && (
            <img
              src={photoPreview}
              alt="Preview"
              className="max-h-40 rounded-lg mb-4 object-contain"
            />
          )}
          <Loader2 className="w-8 h-8 text-primary animate-spin mb-2" />
          <p className="text-gray-600 dark:text-gray-400">
            {partialImages.length > 0 ? `${partialImages.length}/2 images ready…` : 'Creating your AI photos...'}
          </p>
          <p className="text-xs text-gray-400 mt-1">
            Generation time can vary. You can keep exploring while this runs.
          </p>

          {partialImages.length > 0 && (
            <div className="grid grid-cols-2 gap-2 mt-4 w-full max-w-xs">
              {partialImages.map((img) => (
                <img
                  key={img.id}
                  src={getImageSrc(img)}
                  alt="Generated preview"
                  className="w-full aspect-[3/4] object-cover rounded-lg"
                />
              ))}
            </div>
          )}
        </div>
      )}

      {/* Results State */}
      {state === 'results' && result && (
        <div className="space-y-4">
          <div className="flex items-center gap-2 text-success">
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
                  type="button"
                  onClick={() => handleDownload(getImageSrc(img), idx)}
                  aria-label={`Download image ${idx + 1}`}
                  className="absolute bottom-2 right-2 p-2 bg-on-image/90 rounded-full opacity-0 transition-opacity group-hover:opacity-100 focus-visible:opacity-100"
                >
                  <Download className="w-4 h-4 text-on-image-foreground" />
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
              className="flex-1 bg-primary hover:bg-primary-pressed text-white"
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
    </EditorialPanel>
  );
}
