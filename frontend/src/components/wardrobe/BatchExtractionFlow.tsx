/**
 * BatchExtractionFlow Component
 *
 * Main orchestration component for the batch multi-image extraction flow.
 * Handles the complete pipeline: select -> upload -> extract -> generate -> review -> save.
 */

import { useState, useCallback, useEffect, useRef } from 'react';
import { Sparkles, Loader2, Upload, CheckCircle2 } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { ToastAction } from '@/components/ui/toast';
import { useToast } from '@/components/ui/use-toast';
import { useBatchExtraction } from '@/hooks';
import { createItem, uploadItemImages } from '@/api/items';
import { parallelWithRetry } from '@/lib/retry';
import { BatchImageSelector } from './BatchImageSelector';
import { BatchExtractionProgress } from './BatchExtractionProgress';
import { BatchGenerationProgress } from './BatchGenerationProgress';
import { BatchOriginalsReview } from './BatchOriginalsReview';
import { ExtractedItemsGrid } from './ExtractedItemsGrid';
import type { DetectedItem, ItemCreate } from '@/types';

// ============================================================================
// TYPES
// ============================================================================

export interface ItemUploadResult {
  success: boolean;
  item?: unknown;
  error?: string;
}

interface BatchExtractionFlowProps {
  /** Callback when upload is complete */
  onUploadComplete?: (results: ItemUploadResult[]) => void;
  /** Callback to close the dialog */
  onClose?: () => void;
  /** Callback to request opening the dialog (background completion) */
  onRequestOpen?: () => void;
  /** Whether the dialog is open */
  isOpen?: boolean;
}

// ============================================================================
// HELPERS
// ============================================================================

function generateItemName(item: DetectedItem): string {
  const parts: string[] = [];
  if (item.colors?.[0]) {
    parts.push(item.colors[0].charAt(0).toUpperCase() + item.colors[0].slice(1));
  }
  if (item.sub_category) {
    parts.push(item.sub_category.charAt(0).toUpperCase() + item.sub_category.slice(1));
  } else if (item.category) {
    parts.push(item.category.charAt(0).toUpperCase() + item.category.slice(1));
  }
  return parts.join(' ') || 'New Item';
}

function dataURLtoFile(dataUrl: string, filename: string): File {
  const arr = dataUrl.split(',');
  const mime = arr[0].match(/:(.*?);/)?.[1] || 'image/png';
  const bstr = atob(arr[1]);
  let n = bstr.length;
  const u8arr = new Uint8Array(n);
  while (n--) {
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], filename, { type: mime });
}

// ============================================================================
// COMPONENT
// ============================================================================

export function BatchExtractionFlow({
  onUploadComplete,
  onClose,
  onRequestOpen,
  isOpen = true,
}: BatchExtractionFlowProps) {
  // Use the batch extraction hook
  const {
    state,
    isConnected,
    addImages,
    removeImage,
    clearImages,
    startExtraction,
    connectToExistingJob,
    cancel,
    reset,
    updateItem,
    deleteItem,
    proceedToSaving,
  } = useBatchExtraction();

  const { toast } = useToast();
  const backgroundedRef = useRef(false);

  // Local state for saving
  const [savingProgress, setSavingProgress] = useState(0);
  const [regeneratingItemId, setRegeneratingItemId] = useState<string | null>(null);
  const isProcessing = ['uploading', 'extracting', 'generating', 'saving'].includes(state.step);

  useEffect(() => {
    if (isOpen) {
      backgroundedRef.current = false;
    }
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen && state.step === 'review' && backgroundedRef.current) {
      backgroundedRef.current = false;
      onRequestOpen?.();
    }
  }, [isOpen, onRequestOpen, state.step]);

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  const handleImagesSelected = useCallback(
    (files: File[]) => {
      addImages(files);
    },
    [addImages]
  );

  const handleInstagramBatchReady = useCallback(
    (batchJobId: string, _sseUrl: string) => {
      // The SSE URL format gives us the image count from the path
      // For now, we use a placeholder count that will be updated by SSE events
      connectToExistingJob(batchJobId, 0);
    },
    [connectToExistingJob]
  );

  const handleContinue = useCallback(async () => {
    await startExtraction();
  }, [startExtraction]);

  const handleCancel = useCallback(async () => {
    await cancel();
  }, [cancel]);

  const handleBack = useCallback(() => {
    reset();
  }, [reset]);

  const handleClose = useCallback(() => {
    if (isProcessing) {
      backgroundedRef.current = true;
      onClose?.();
      toast({
        title: 'Processing in background',
        description: 'We will reopen this when your items are ready.',
        action: onRequestOpen ? (
          <ToastAction altText="View progress" onClick={() => onRequestOpen()}>
            View
          </ToastAction>
        ) : undefined,
      });
      return;
    }

    reset();
    onClose?.();
  }, [isProcessing, onClose, onRequestOpen, reset, toast]);

  // ============================================================================
  // REGENERATE ITEM
  // ============================================================================

  const regenerateItem = useCallback(
    async (tempId: string) => {
      // For batch flow, regeneration would need a separate API call
      // For now, mark the item for retry in review
      setRegeneratingItemId(tempId);

      const item = state.allDetectedItems.find((i) => i.tempId === tempId);
      if (!item) {
        setRegeneratingItemId(null);
        return;
      }

      try {
        // Import dynamically to avoid circular deps
        const { generateProductImage } = await import('@/api/ai');

        const result = await generateProductImage({
          item_description:
            item.detailedDescription ||
            `${item.colors?.[0] || ''} ${item.sub_category || item.category}`.trim(),
          category: item.category,
          sub_category: item.sub_category,
          colors: item.colors,
          material: item.material,
          background: 'white',
          view_angle: 'front',
          include_shadows: false,
          save_to_storage: false,
        });

        const imageUrl = `data:image/png;base64,${result.image_base64}`;

        updateItem(tempId, {
          status: 'generated',
          generatedImageUrl: imageUrl,
          generationError: undefined,
        });
      } catch (error) {
        updateItem(tempId, {
          status: 'failed',
          generationError: error instanceof Error ? error.message : 'Regeneration failed',
        });
      } finally {
        setRegeneratingItemId(null);
      }
    },
    [state.allDetectedItems, updateItem]
  );

  // ============================================================================
  // SAVE PHASE
  // ============================================================================

  const saveAllItems = useCallback(async () => {
    // Get items that are ready to save (generated and not deleted)
    const itemsToSave = state.allDetectedItems.filter(
      (item) => item.status === 'generated' && item.generatedImageUrl
    );

    if (itemsToSave.length === 0) {
      reset();
      onUploadComplete?.([]);
      return;
    }

    proceedToSaving();
    setSavingProgress(0);

    // Track completed count using ref pattern
    const completedRef = { current: 0 };

    // Process all items in parallel with retry
    const parallelResults = await parallelWithRetry(
      itemsToSave,
      async (item) => {
        // Convert generated image to File
        const imageFile = dataURLtoFile(item.generatedImageUrl!, `${item.tempId}.png`);

        // Upload image to Supabase
        const formData = new FormData();
        formData.append('files', imageFile, imageFile.name);

        const upload = await uploadItemImages(formData);
        const uploadedImage = upload.images?.[0];

        if (!uploadedImage?.image_url) {
          throw new Error('Image upload failed');
        }

        // Create item record
        const itemData: ItemCreate = {
          name: item.name || generateItemName(item),
          category: item.category,
          sub_category: item.sub_category,
          brand: item.brand,
          colors: item.colors,
          material: item.material,
          pattern: item.pattern,
          tags: [],
          condition: 'clean',
          is_favorite: false,
          images: [
            {
              image_url: uploadedImage.image_url,
              thumbnail_url: uploadedImage.thumbnail_url,
              storage_path: uploadedImage.storage_path,
              is_primary: true,
            },
          ],
        };

        const savedItem = await createItem(itemData);
        return savedItem;
      },
      {
        maxRetries: 3,
        initialDelayMs: 1000,
        backoffFactor: 2,
        onRetry: (attempt, error, delayMs) => {
          console.log(`Retrying item save, attempt ${attempt}, waiting ${delayMs}ms`, error);
        },
        onItemComplete: () => {
          completedRef.current += 1;
          const progress = (completedRef.current / itemsToSave.length) * 100;
          setSavingProgress(progress);
        },
      }
    );

    // Convert results to ItemUploadResult format
    const results: ItemUploadResult[] = parallelResults.map((result) => {
      if (result.success) {
        return { success: true, item: result.data };
      } else {
        return {
          success: false,
          error: result.error?.message || 'Failed to save item',
        };
      }
    });

    // Cleanup and notify
    reset();
    onUploadComplete?.(results);
  }, [state.allDetectedItems, proceedToSaving, reset, onUploadComplete]);

  // ============================================================================
  // RENDER HELPERS
  // ============================================================================

  const getStepTitle = () => {
    switch (state.step) {
      case 'select':
        return 'Select Images';
      case 'uploading':
        return 'Uploading Images';
      case 'extracting':
        return 'Analyzing Images';
      case 'generating':
        return 'Generating Product Images';
      case 'review':
        return 'Review Items';
      case 'saving':
        return 'Saving to Wardrobe';
      default:
        return 'Batch Upload';
    }
  };

  const getStepDescription = () => {
    switch (state.step) {
      case 'select':
        return 'Upload up to 50 clothing photos and our AI will extract all visible items.';
      case 'uploading':
        return 'Preparing your images for processing...';
      case 'extracting':
        return 'AI is detecting clothing items in your photos...';
      case 'generating':
        return 'Creating clean product images for each detected item...';
      case 'review':
        return 'Review and edit extracted items before saving to your wardrobe.';
      case 'saving':
        return 'Saving items to your wardrobe...';
      default:
        return '';
    }
  };

  // Calculate stats for review phase
  const generatedCount = state.allDetectedItems.filter(
    (i) => i.status === 'generated'
  ).length;
  const failedCount = state.allDetectedItems.filter((i) => i.status === 'failed').length;
  const deletedCount = state.allDetectedItems.filter((i) => i.status === 'deleted').length;
  const activeItems = state.allDetectedItems.filter((i) => i.status !== 'deleted');

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <DialogContent className="sm:max-w-[95vw] lg:max-w-6xl max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-gold-500" />
            {getStepTitle()}
            {isConnected && (
              <span className="inline-flex items-center gap-1 text-xs font-normal text-green-600 dark:text-green-400 ml-2">
                <span className="h-2 w-2 rounded-full bg-green-500 animate-pulse" />
                Live
              </span>
            )}
          </DialogTitle>
          <DialogDescription>{getStepDescription()}</DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto min-h-[400px] min-w-0">
          {/* Step 1: Select Images */}
          {state.step === 'select' && (
            <BatchImageSelector
              selectedImages={state.images}
              onImagesSelected={handleImagesSelected}
              onImageRemove={removeImage}
              onClearAll={clearImages}
              maxImages={50}
              disabled={false}
              error={state.error}
              onContinue={handleContinue}
              onInstagramBatchReady={handleInstagramBatchReady}
            />
          )}

          {/* Step 2: Uploading */}
          {state.step === 'uploading' && (
            <div className="flex flex-col items-center justify-center py-16 space-y-6">
              <div className="relative">
                <Upload className="h-16 w-16 text-gold-500" />
                <Loader2 className="absolute -right-2 -bottom-2 h-8 w-8 text-gold-400 animate-spin" />
              </div>
              <div className="text-center space-y-2">
                <p className="text-lg font-medium text-foreground">
                  Preparing {state.images.length} images...
                </p>
                <p className="text-sm text-muted-foreground">
                  Converting images for AI processing
                </p>
              </div>
              <Progress value={30} className="w-64 h-2" />
            </div>
          )}

          {/* Step 3: Extracting */}
          {state.step === 'extracting' && (
            <BatchExtractionProgress
              images={state.images}
              progress={state.extractionProgress}
              imagesCompleted={state.imagesCompleted}
              imagesFailed={state.imagesFailed}
              isProcessing={true}
              onCancel={handleCancel}
              error={state.error}
            />
          )}

          {/* Step 4: Generating */}
          {state.step === 'generating' && (
            <BatchGenerationProgress
              items={state.allDetectedItems}
              progress={state.generationProgress}
              currentBatch={state.currentBatch}
              totalBatches={state.totalBatches}
              itemsGenerated={state.itemsGenerated}
              itemsFailed={state.itemsFailed}
              isProcessing={true}
              onCancel={handleCancel}
              error={state.error}
              batchSize={5}
            />
          )}

          {/* Step 5: Review */}
          {state.step === 'review' && (
            <div className="space-y-4">
              {/* Summary banner */}
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-4 bg-muted/50 rounded-lg">
                <div className="flex flex-wrap items-center gap-4">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-foreground">
                      {state.images.length}
                    </p>
                    <p className="text-xs text-muted-foreground">Images</p>
                  </div>
                  <div className="hidden sm:block h-8 w-px bg-border" />
                  <div className="text-center">
                    <p className="text-2xl font-bold text-gold-600 dark:text-gold-400">
                      {state.allDetectedItems.length}
                    </p>
                    <p className="text-xs text-muted-foreground">Items Found</p>
                  </div>
                  <div className="hidden sm:block h-8 w-px bg-border" />
                  <div className="text-center">
                    <p className="text-2xl font-bold text-green-600 dark:text-green-400">
                      {generatedCount}
                    </p>
                    <p className="text-xs text-muted-foreground">Ready</p>
                  </div>
                  {failedCount > 0 && (
                    <>
                      <div className="hidden sm:block h-8 w-px bg-border" />
                      <div className="text-center">
                        <p className="text-2xl font-bold text-red-600 dark:text-red-400">
                          {failedCount}
                        </p>
                        <p className="text-xs text-muted-foreground">Failed</p>
                      </div>
                    </>
                  )}
                  {deletedCount > 0 && (
                    <>
                      <div className="hidden sm:block h-8 w-px bg-border" />
                      <div className="text-center">
                        <p className="text-2xl font-bold text-muted-foreground">
                          {deletedCount}
                        </p>
                        <p className="text-xs text-muted-foreground">Removed</p>
                      </div>
                    </>
                  )}
                </div>
              </div>

              {/* Original photos with bounding boxes */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-foreground">
                    Original Photos
                  </h3>
                  <p className="text-xs text-muted-foreground">
                    Tap any photo to zoom
                  </p>
                </div>
                <BatchOriginalsReview images={state.images} />
              </div>

              {/* Items grid */}
              <ExtractedItemsGrid
                items={activeItems}
                originalImageUrl={null}
                onItemUpdate={updateItem}
                onItemDelete={deleteItem}
                onItemRegenerate={regenerateItem}
                onSaveAll={saveAllItems}
                onBack={handleBack}
                isSaving={false}
                regeneratingItemId={regeneratingItemId}
                backLabel="Upload Different Images"
              />
            </div>
          )}

          {/* Step 6: Saving */}
          {state.step === 'saving' && (
            <div className="flex flex-col items-center justify-center py-16 space-y-6">
              <div className="relative">
                <CheckCircle2 className="h-16 w-16 text-green-500" />
                <Loader2 className="absolute -right-2 -bottom-2 h-8 w-8 text-green-400 animate-spin" />
              </div>
              <div className="text-center space-y-2">
                <p className="text-lg font-medium text-foreground">
                  Saving items to wardrobe...
                </p>
                <p className="text-sm text-muted-foreground">
                  {Math.round(savingProgress)}% complete
                </p>
              </div>
              <Progress value={savingProgress} className="w-64 h-2" />
              <p className="text-xs text-muted-foreground">
                Uploading {generatedCount} items
              </p>
            </div>
          )}
        </div>

        {/* Footer actions for select step */}
        {state.step === 'select' && state.images.length === 0 && (
          <div className="flex justify-end pt-4 border-t border-border">
            <Button variant="outline" onClick={handleClose}>
              Cancel
            </Button>
          </div>
        )}

        {/* Back button for review step is handled by ExtractedItemsGrid */}
      </DialogContent>
    </Dialog>
  );
}

export default BatchExtractionFlow;
