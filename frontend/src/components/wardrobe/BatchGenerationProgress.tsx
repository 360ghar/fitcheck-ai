/**
 * BatchGenerationProgress Component
 *
 * Displays real-time progress during the generation phase of batch processing.
 * Shows individual item status with batch indicators.
 */

import { Loader2, CheckCircle2, XCircle, AlertCircle, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { cn } from '@/lib/utils';
import type { DetectedItem } from '@/types';

interface BatchGenerationProgressProps {
  /** All detected items being processed */
  items: DetectedItem[];
  /** Overall generation progress (0-100) */
  progress: number;
  /** Current batch number (1-indexed) */
  currentBatch: number;
  /** Total number of batches */
  totalBatches: number;
  /** Number of items generated */
  itemsGenerated: number;
  /** Number of items failed */
  itemsFailed: number;
  /** Whether the job is currently processing */
  isProcessing: boolean;
  /** Callback to cancel the job */
  onCancel?: () => void;
  /** Error message if any */
  error?: string | null;
  /** Batch size (default 5) */
  batchSize?: number;
}

/**
 * Get status indicator for an item
 */
function getStatusIndicator(item: DetectedItem) {
  switch (item.status) {
    case 'generating':
      return (
        <div className="absolute inset-0 flex items-center justify-center bg-black/40">
          <div className="flex flex-col items-center">
            <Loader2 className="h-6 w-6 text-white animate-spin" />
            <span className="text-xs text-white mt-1">Generating...</span>
          </div>
        </div>
      );
    case 'generated':
      return (
        <div className="absolute top-1.5 right-1.5">
          <CheckCircle2 className="h-4 w-4 text-green-500 drop-shadow-lg" />
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
function getBorderStyle(item: DetectedItem, isInCurrentBatch: boolean) {
  if (item.status === 'generating') {
    return 'ring-2 ring-gold-500 ring-offset-2 dark:ring-offset-background animate-pulse';
  }
  if (item.status === 'generated') {
    return 'ring-2 ring-green-500 ring-offset-1 dark:ring-offset-background';
  }
  if (item.status === 'failed') {
    return 'ring-2 ring-red-500 ring-offset-1 dark:ring-offset-background';
  }
  if (isInCurrentBatch) {
    return 'ring-2 ring-gold-300 dark:ring-gold-700 ring-offset-1 dark:ring-offset-background';
  }
  return 'ring-1 ring-border';
}

/**
 * Get placeholder image for items without generated image
 */
function getItemPlaceholder(item: DetectedItem) {
  return (
    <div className="absolute inset-0 flex flex-col items-center justify-center bg-gradient-to-br from-muted to-muted/80 p-2">
      <Sparkles className="h-6 w-6 text-muted-foreground mb-1" />
      <span className="text-xs text-muted-foreground text-center truncate w-full px-1">
        {item.name || item.category}
      </span>
    </div>
  );
}

export function BatchGenerationProgress({
  items,
  progress,
  currentBatch,
  totalBatches,
  itemsGenerated,
  itemsFailed,
  isProcessing,
  onCancel,
  error,
  batchSize = 5,
}: BatchGenerationProgressProps) {
  const totalItems = items.length;
  const processedCount = itemsGenerated + itemsFailed;

  // Calculate which items are in the current batch
  const activeBatch = totalBatches > 0 ? Math.max(currentBatch, 1) : 0;
  const currentBatchStart = activeBatch > 0 ? (activeBatch - 1) * batchSize : 0;
  const currentBatchEnd = Math.min(currentBatchStart + batchSize, totalItems);

  const isInCurrentBatch = (index: number) => {
    return isProcessing && activeBatch > 0 && index >= currentBatchStart && index < currentBatchEnd;
  };

  return (
    <div className="flex flex-col h-full space-y-4">
      {/* Header with progress */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-foreground">
              Generating Product Images
            </h3>
            <p className="text-sm text-muted-foreground">
              Creating clean product photos for your wardrobe...
            </p>
          </div>
          {isProcessing && (
            <Sparkles className="h-5 w-5 text-gold-500 animate-pulse" />
          )}
        </div>

        {/* Batch indicator */}
        {totalBatches > 0 && (
          <div className="flex items-center gap-2 text-sm">
            <span className="px-2 py-1 bg-gold-100 dark:bg-gold-900/30 text-gold-700 dark:text-gold-300 rounded font-medium">
              Batch {activeBatch} of {totalBatches}
            </span>
            <span className="text-muted-foreground">
              (items {currentBatchStart + 1}-{currentBatchEnd})
            </span>
          </div>
        )}

        {/* Progress bar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">
              {processedCount} of {totalItems} items generated
              {itemsFailed > 0 && (
                <span className="text-red-500 ml-1">
                  ({itemsFailed} failed)
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
              Error during generation
            </p>
            <p className="text-sm text-red-700 dark:text-red-400 mt-1">
              {error}
            </p>
          </div>
        </div>
      )}

      {/* Items grid */}
      <div className="flex-1 overflow-y-auto min-h-0">
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2 sm:gap-3">
          {items.map((item, index) => (
            <div
              key={item.tempId}
              className={cn(
                'group relative aspect-square rounded-lg overflow-hidden bg-muted transition-all duration-300',
                getBorderStyle(item, isInCurrentBatch(index))
              )}
            >
              {/* Show generated image or placeholder */}
              {item.generatedImageUrl ? (
                <img
                  src={item.generatedImageUrl}
                  alt={item.name || item.category}
                  className="w-full h-full object-cover"
                />
              ) : (
                getItemPlaceholder(item)
              )}

              {getStatusIndicator(item)}

              {/* Item info overlay */}
              <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent p-1.5 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                <p className="text-xs text-white truncate font-medium">
                  {item.name || item.category}
                </p>
                {item.colors && item.colors.length > 0 && (
                  <p className="text-xs text-white/80 truncate">
                    {item.colors.join(', ')}
                  </p>
                )}
              </div>

              {/* Error tooltip on hover for failed items */}
              {item.status === 'failed' && item.generationError && (
                <div className="absolute inset-x-0 bottom-0 bg-red-500 text-white text-xs p-1.5 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity z-10">
                  <p className="truncate">{item.generationError}</p>
                </div>
              )}

              {/* Batch number badge for current batch items */}
              {isInCurrentBatch(index) && item.status !== 'generated' && item.status !== 'failed' && (
                <div className="absolute top-1.5 left-1.5 bg-gold-500 text-white text-xs font-bold px-1.5 py-0.5 rounded">
                  #{index - currentBatchStart + 1}
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
            {items.filter((i) => i.status === 'detected' || i.status === 'generating').length}
          </p>
          <p className="text-xs text-muted-foreground">Pending</p>
        </div>
        <div className="text-center">
          <p className="text-2xl font-bold text-green-600 dark:text-green-400">
            {itemsGenerated}
          </p>
          <p className="text-xs text-muted-foreground">Generated</p>
        </div>
        <div className="text-center">
          <p className="text-2xl font-bold text-red-600 dark:text-red-400">
            {itemsFailed}
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
            Cancel Generation
          </Button>
        </div>
      )}
    </div>
  );
}

export default BatchGenerationProgress;
