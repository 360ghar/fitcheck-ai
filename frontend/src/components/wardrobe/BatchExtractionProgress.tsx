/**
 * BatchExtractionProgress Component
 *
 * Displays real-time progress during the extraction phase of batch processing.
 * Shows individual image status and overall progress.
 */

import { Loader2, CheckCircle2, XCircle, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { cn } from '@/lib/utils';
import type { BatchImageInput } from '@/types';

interface BatchExtractionProgressProps {
  /** All images being processed */
  images: BatchImageInput[];
  /** Overall extraction progress (0-100) */
  progress: number;
  /** Number of images completed */
  imagesCompleted: number;
  /** Number of images failed */
  imagesFailed: number;
  /** Whether the job is currently processing */
  isProcessing: boolean;
  /** Callback to cancel the job */
  onCancel?: () => void;
  /** Error message if any */
  error?: string | null;
}

/**
 * Get status indicator for an image
 */
function getStatusIndicator(status: BatchImageInput['status']) {
  switch (status) {
    case 'extracting':
      return (
        <div className="absolute inset-0 flex items-center justify-center bg-black/30">
          <Loader2 className="h-6 w-6 text-white animate-spin" />
        </div>
      );
    case 'completed':
      return (
        <div className="absolute top-2 right-2">
          <CheckCircle2 className="h-5 w-5 text-green-500 drop-shadow-lg" />
        </div>
      );
    case 'failed':
      return (
        <div className="absolute inset-0 flex items-center justify-center bg-red-500/30">
          <XCircle className="h-6 w-6 text-red-500 drop-shadow-lg" />
        </div>
      );
    default:
      return null;
  }
}

/**
 * Get border style based on status
 */
function getBorderStyle(status: BatchImageInput['status']) {
  switch (status) {
    case 'extracting':
      return 'ring-2 ring-gold-500 ring-offset-2 dark:ring-offset-background animate-pulse';
    case 'completed':
      return 'ring-2 ring-green-500 ring-offset-1 dark:ring-offset-background';
    case 'failed':
      return 'ring-2 ring-red-500 ring-offset-1 dark:ring-offset-background';
    default:
      return 'ring-1 ring-border';
  }
}

export function BatchExtractionProgress({
  images,
  progress,
  imagesCompleted,
  imagesFailed,
  isProcessing,
  onCancel,
  error,
}: BatchExtractionProgressProps) {
  const totalImages = images.length;
  const processedCount = imagesCompleted + imagesFailed;

  return (
    <div className="flex flex-col h-full space-y-4">
      {/* Header with progress */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-foreground">
              Analyzing Images
            </h3>
            <p className="text-sm text-muted-foreground">
              Detecting clothing items in your photos...
            </p>
          </div>
          {isProcessing && (
            <Loader2 className="h-5 w-5 text-gold-500 animate-spin" />
          )}
        </div>

        {/* Progress bar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">
              {processedCount} of {totalImages} images processed
              {imagesFailed > 0 && (
                <span className="text-red-500 ml-1">
                  ({imagesFailed} failed)
                </span>
              )}
            </span>
            <span className="font-medium text-foreground">
              {Math.round(progress)}%
            </span>
          </div>
          <Progress value={progress} className="h-2" />
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="flex items-start gap-3 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
          <AlertCircle className="h-5 w-5 text-red-500 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-red-800 dark:text-red-300">
              Error during extraction
            </p>
            <p className="text-sm text-red-700 dark:text-red-400 mt-1">
              {error}
            </p>
          </div>
        </div>
      )}

      {/* Images grid */}
      <div className="flex-1 overflow-y-auto min-h-0">
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2 sm:gap-3">
          {images.map((image) => (
            <div
              key={image.imageId}
              className={cn(
                'group relative aspect-square rounded-lg overflow-hidden bg-muted transition-all duration-300',
                getBorderStyle(image.status)
              )}
            >
              <img
                src={image.previewUrl}
                alt={image.file.name}
                className="w-full h-full object-cover"
              />
              {getStatusIndicator(image.status)}

              {/* Error tooltip on hover for failed images */}
              {image.status === 'failed' && image.error && (
                <div className="absolute inset-x-0 bottom-0 bg-red-500 text-white text-xs p-1.5 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                  <p className="truncate">{image.error}</p>
                </div>
              )}

              {/* Items count badge for completed images */}
              {image.status === 'completed' && image.detectedItems && image.detectedItems.length > 0 && (
                <div className="absolute bottom-2 left-2 bg-gold-500 text-white text-xs font-medium px-1.5 py-0.5 rounded">
                  {image.detectedItems.length} item{image.detectedItems.length !== 1 ? 's' : ''}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Status summary */}
      <div className="grid grid-cols-3 gap-4 py-3 border-t border-border">
        <div className="text-center">
          <p className="text-2xl font-bold text-foreground">
            {images.filter((i) => i.status === 'pending' || i.status === 'uploading').length}
          </p>
          <p className="text-xs text-muted-foreground">Pending</p>
        </div>
        <div className="text-center">
          <p className="text-2xl font-bold text-green-600 dark:text-green-400">
            {imagesCompleted}
          </p>
          <p className="text-xs text-muted-foreground">Completed</p>
        </div>
        <div className="text-center">
          <p className="text-2xl font-bold text-red-600 dark:text-red-400">
            {imagesFailed}
          </p>
          <p className="text-xs text-muted-foreground">Failed</p>
        </div>
      </div>

      {/* Cancel button */}
      {isProcessing && onCancel && (
        <div className="flex justify-center pt-2 border-t border-border">
          <Button
            variant="outline"
            onClick={onCancel}
            className="text-red-600 hover:text-red-700 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/20"
          >
            Cancel Extraction
          </Button>
        </div>
      )}
    </div>
  );
}

export default BatchExtractionProgress;
