/**
 * MultiItemExtractionFlow Component
 *
 * Main orchestration component for the multi-item clothing extraction flow.
 * Handles the complete pipeline: upload -> detection -> generation -> review -> save.
 */

import { useState, useCallback, useRef } from 'react'
import { useDropzone } from 'react-dropzone'
import { Upload, Sparkles } from 'lucide-react'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { extractItems, generateProductImage } from '@/api/ai'
import { createItem, uploadItemImages } from '@/api/items'
import { parallelWithRetry } from '@/lib/retry'
import { DetectionProgress } from './DetectionProgress'
import { GenerationProgress } from './GenerationProgress'
import { ExtractedItemsGrid } from './ExtractedItemsGrid'
import type {
  DetectedItem,
  MultiItemExtractionState,
  ItemCreate,
} from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface ItemUploadResult {
  success: boolean
  item?: any
  error?: string
}

interface MultiItemExtractionFlowProps {
  /** Callback when upload is complete */
  onUploadComplete?: (results: ItemUploadResult[]) => void
  /** Callback to close the dialog */
  onClose?: () => void
  /** Whether the dialog is open */
  isOpen?: boolean
}

// ============================================================================
// HELPERS
// ============================================================================

function generateItemName(item: DetectedItem): string {
  const parts: string[] = []
  if (item.colors[0]) {
    parts.push(item.colors[0].charAt(0).toUpperCase() + item.colors[0].slice(1))
  }
  if (item.sub_category) {
    parts.push(item.sub_category.charAt(0).toUpperCase() + item.sub_category.slice(1))
  } else if (item.category) {
    parts.push(item.category.charAt(0).toUpperCase() + item.category.slice(1))
  }
  return parts.join(' ') || 'New Item'
}

function dataURLtoFile(dataUrl: string, filename: string): File {
  const arr = dataUrl.split(',')
  const mime = arr[0].match(/:(.*?);/)?.[1] || 'image/png'
  const bstr = atob(arr[1])
  let n = bstr.length
  const u8arr = new Uint8Array(n)
  while (n--) {
    u8arr[n] = bstr.charCodeAt(n)
  }
  return new File([u8arr], filename, { type: mime })
}

// ============================================================================
// COMPONENT
// ============================================================================

export function MultiItemExtractionFlow({
  onUploadComplete,
  onClose,
  isOpen = true,
}: MultiItemExtractionFlowProps) {
  // State
  const [state, setState] = useState<MultiItemExtractionState>({
    step: 'upload',
    originalFile: null,
    originalPreviewUrl: null,
    detectedItems: [],
    detectionProgress: 0,
    generationProgress: 0,
    savingProgress: 0,
    error: null,
  })

  const [regeneratingItemId, setRegeneratingItemId] = useState<string | null>(null)
  const [processingItems, setProcessingItems] = useState<Set<string>>(new Set())

  const abortControllerRef = useRef<AbortController | null>(null)

  // ============================================================================
  // FILE HANDLING
  // ============================================================================

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    if (acceptedFiles.length === 0) return

    // Only process the first file for multi-item extraction
    const file = acceptedFiles[0]
    const previewUrl = URL.createObjectURL(file)

    setState((prev) => ({
      ...prev,
      step: 'detecting',
      originalFile: file,
      originalPreviewUrl: previewUrl,
      detectedItems: [],
      error: null,
    }))

    // Start detection
    await runDetection(file, previewUrl)
  }, [])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.gif'],
    },
    multiple: false,
    maxSize: 10 * 1024 * 1024,
  })

  // ============================================================================
  // DETECTION PHASE
  // ============================================================================

  const runDetection = async (file: File, _previewUrl: string) => {
    try {
      setState((prev) => ({ ...prev, detectionProgress: 10 }))

      // Extract multiple items from the image using backend API
      const result = await extractItems(file)

      setState((prev) => ({ ...prev, detectionProgress: 100 }))

      if (result.items.length === 0) {
        setState((prev) => ({
          ...prev,
          step: 'upload',
          error: 'No clothing items detected in this image. Please try a different photo.',
        }))
        return
      }

      // Map API response to component format and add default names
      const itemsWithNames: DetectedItem[] = result.items.map((item) => ({
        tempId: item.temp_id,
        category: item.category as any,
        sub_category: item.sub_category,
        colors: item.colors,
        material: item.material,
        pattern: item.pattern,
        brand: item.brand,
        confidence: item.confidence,
        boundingBox: item.bounding_box,
        detailedDescription: item.detailed_description || '',
        status: 'detected' as const,
        name: generateItemName({
          tempId: item.temp_id,
          category: item.category as any,
          sub_category: item.sub_category,
          colors: item.colors,
          confidence: item.confidence,
          status: 'detected',
          detailedDescription: '',
        }),
      }))

      setState((prev) => ({
        ...prev,
        detectedItems: itemsWithNames,
        step: 'generating',
        generationProgress: 0,
      }))

      // Start generation
      await runGeneration(itemsWithNames, file)
    } catch (error) {
      console.error('Detection failed:', error)
      setState((prev) => ({
        ...prev,
        step: 'upload',
        error: error instanceof Error ? error.message : 'Failed to analyze image',
      }))
    }
  }

  // ============================================================================
  // GENERATION PHASE
  // ============================================================================

  const runGeneration = async (items: DetectedItem[], _originalFile: File) => {
    // Create abort controller for cancellation
    abortControllerRef.current = new AbortController()

    // Track which items are being processed
    setProcessingItems(new Set(items.map((item) => item.tempId)))

    // Mark all items as generating initially
    const initialItems = items.map((item) => ({ ...item, status: 'generating' as const }))
    setState((prev) => ({
      ...prev,
      detectedItems: initialItems,
    }))

    // Track completed count for progress (using ref to avoid stale closures)
    const completedRef = { current: 0 }

    // Process all items in parallel with retry
    await parallelWithRetry(
      items,
      async (item, index) => {
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
        })

        return {
          index,
          tempId: item.tempId,
          imageUrl: `data:image/png;base64,${result.image_base64}`,
        }
      },
      {
        maxRetries: 3,
        initialDelayMs: 1000,
        backoffFactor: 2,
        signal: abortControllerRef.current.signal,
        onRetry: (attempt, error, delayMs) => {
          console.log(`Retrying item generation, attempt ${attempt}, waiting ${delayMs}ms`, error)
        },
        onItemComplete: (index, result) => {
          // Update individual item state when it completes
          setState((prev) => {
            const newItems = [...prev.detectedItems]

            if (result.success && result.data) {
              newItems[index] = {
                ...newItems[index],
                status: 'generated' as const,
                generatedImageUrl: result.data.imageUrl,
              }
            } else {
              newItems[index] = {
                ...newItems[index],
                status: 'failed' as const,
                generationError: result.error?.message || 'Image generation failed',
              }
            }

            // Calculate progress based on completed items
            completedRef.current += 1
            const progress = (completedRef.current / items.length) * 100

            return {
              ...prev,
              detectedItems: newItems,
              generationProgress: progress,
            }
          })

          // Remove from processing set
          setProcessingItems((prev) => {
            const newSet = new Set(prev)
            newSet.delete(items[index].tempId)
            return newSet
          })
        },
      }
    )

    // Transition to review step
    setState((prev) => ({
      ...prev,
      step: 'review',
    }))

    // Clean up
    abortControllerRef.current = null
    setProcessingItems(new Set())
  }

  // ============================================================================
  // ITEM MANAGEMENT
  // ============================================================================

  const updateItem = (tempId: string, updates: Partial<DetectedItem>) => {
    setState((prev) => ({
      ...prev,
      detectedItems: prev.detectedItems.map((item) =>
        item.tempId === tempId ? { ...item, ...updates } : item
      ),
    }))
  }

  const deleteItem = (tempId: string) => {
    setState((prev) => ({
      ...prev,
      detectedItems: prev.detectedItems.map((item) =>
        item.tempId === tempId ? { ...item, status: 'deleted' as const } : item
      ),
    }))
  }

  const regenerateItem = async (tempId: string) => {
    if (!state.originalFile) return

    setRegeneratingItemId(tempId)

    const item = state.detectedItems.find((i) => i.tempId === tempId)
    if (!item) return

    try {
      // Generate product image using backend API
      const result = await generateProductImage({
        item_description: item.detailedDescription || `${item.colors?.[0] || ''} ${item.sub_category || item.category}`.trim(),
        category: item.category,
        sub_category: item.sub_category,
        colors: item.colors,
        material: item.material,
        background: 'white',
        view_angle: 'front',
        include_shadows: false,
        save_to_storage: false,
      })

      // Convert base64 to data URL for display
      const imageUrl = `data:image/png;base64,${result.image_base64}`

      updateItem(tempId, {
        status: 'generated',
        generatedImageUrl: imageUrl,
        generationError: undefined,
      })
    } catch (error) {
      updateItem(tempId, {
        status: 'failed',
        generationError: error instanceof Error ? error.message : 'Regeneration failed',
      })
    } finally {
      setRegeneratingItemId(null)
    }
  }

  // ============================================================================
  // SAVE PHASE
  // ============================================================================

  const saveAllItems = async () => {
    setState((prev) => ({ ...prev, step: 'saving', savingProgress: 0 }))

    const itemsToSave = state.detectedItems.filter(
      (item) => item.status === 'generated' && item.generatedImageUrl
    )

    if (itemsToSave.length === 0) {
      // No items to save, reset state
      resetAndCleanup()
      onUploadComplete?.([])
      return
    }

    // Create abort controller for cancellation
    abortControllerRef.current = new AbortController()

    // Track completed count using ref to avoid stale closures
    const completedRef = { current: 0 }

    // Process all items in parallel with retry
    const parallelResults = await parallelWithRetry(
      itemsToSave,
      async (item) => {
        // Convert generated image to File
        const imageFile = dataURLtoFile(item.generatedImageUrl!, `${item.tempId}.png`)

        // Upload image to Supabase
        const formData = new FormData()
        formData.append('files', imageFile, imageFile.name)

        const upload = await uploadItemImages(formData)
        const uploadedImage = upload.images?.[0]

        if (!uploadedImage?.image_url) {
          throw new Error('Image upload failed')
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
          tags: item.tags || [],
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
        }

        const savedItem = await createItem(itemData)
        return savedItem
      },
      {
        maxRetries: 3,
        initialDelayMs: 1000,
        backoffFactor: 2,
        signal: abortControllerRef.current.signal,
        onRetry: (attempt, error, delayMs) => {
          console.log(`Retrying item save, attempt ${attempt}, waiting ${delayMs}ms`, error)
        },
        onItemComplete: () => {
          // Update progress after each completion
          completedRef.current += 1
          const progress = (completedRef.current / itemsToSave.length) * 100
          setState((prev) => ({ ...prev, savingProgress: progress }))
        },
      }
    )

    // Convert results to ItemUploadResult format
    const results: ItemUploadResult[] = parallelResults.map((result) => {
      if (result.success) {
        return { success: true, item: result.data }
      } else {
        return {
          success: false,
          error: result.error?.message || 'Failed to save item',
        }
      }
    })

    // Cleanup and reset
    resetAndCleanup()
    onUploadComplete?.(results)
  }

  const resetAndCleanup = () => {
    if (state.originalPreviewUrl) {
      URL.revokeObjectURL(state.originalPreviewUrl)
    }

    setState({
      step: 'upload',
      originalFile: null,
      originalPreviewUrl: null,
      detectedItems: [],
      detectionProgress: 0,
      generationProgress: 0,
      savingProgress: 0,
      error: null,
    })

    abortControllerRef.current = null
    setProcessingItems(new Set())
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  const handleCancel = () => {
    // Cancel any in-progress operations
    if (abortControllerRef.current) {
      abortControllerRef.current.abort()
      abortControllerRef.current = null
    }
  }

  const handleBack = () => {
    handleCancel()
    resetAndCleanup()
  }

  const handleClose = () => {
    handleCancel()
    if (state.originalPreviewUrl) {
      URL.revokeObjectURL(state.originalPreviewUrl)
    }
    onClose?.()
  }

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <DialogContent className="sm:max-w-[90vw] lg:max-w-6xl max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-indigo-500" />
            Add Items to Wardrobe
          </DialogTitle>
          <DialogDescription>
            {state.step === 'upload' &&
              'Upload a clothing photo and our AI will extract all visible items.'}
            {state.step === 'detecting' && 'Analyzing your image...'}
            {state.step === 'generating' && 'Creating product images...'}
            {state.step === 'review' && 'Review and edit extracted items before saving.'}
            {state.step === 'saving' && 'Saving items to your wardrobe...'}
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto min-h-[400px] min-w-0">
          {/* Upload Phase */}
          {state.step === 'upload' && (
            <div className="h-full flex flex-col">
              {state.error && (
                <div className="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-800 dark:text-red-300">
                  {state.error}
                </div>
              )}

              <div
                {...getRootProps()}
                className={`flex-1 border-2 border-dashed rounded-lg p-12 text-center transition-colors cursor-pointer flex flex-col items-center justify-center ${
                  isDragActive
                    ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500'
                }`}
              >
                <input {...getInputProps()} />
                <Upload className="h-12 w-12 mx-auto text-gray-400 dark:text-gray-500 mb-4" />
                <p className="text-lg font-medium text-gray-900 dark:text-white mb-2">
                  {isDragActive ? 'Drop image here' : 'Drop a clothing photo here'}
                </p>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">or click to browse</p>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  AI will detect and extract all visible clothing items
                </p>
                <p className="text-xs text-gray-400 dark:text-gray-500 mt-2">
                  Supports PNG, JPG, WEBP up to 10MB
                </p>
              </div>
            </div>
          )}

          {/* Detection Phase */}
          {state.step === 'detecting' && state.originalPreviewUrl && (
            <DetectionProgress
              progress={state.detectionProgress}
              imageUrl={state.originalPreviewUrl}
              statusMessage="Identifying clothing items..."
            />
          )}

          {/* Generation Phase */}
          {state.step === 'generating' && (
            <GenerationProgress
              items={state.detectedItems}
              completedCount={
                state.detectedItems.filter(
                  (i) => i.status === 'generated' || i.status === 'failed'
                ).length
              }
              processingItems={processingItems}
              progress={state.generationProgress}
            />
          )}

          {/* Review Phase */}
          {state.step === 'review' && state.originalPreviewUrl && (
            <ExtractedItemsGrid
              items={state.detectedItems}
              originalImageUrl={state.originalPreviewUrl}
              onItemUpdate={updateItem}
              onItemDelete={deleteItem}
              onItemRegenerate={regenerateItem}
              onSaveAll={saveAllItems}
              onBack={handleBack}
              isSaving={false}
              regeneratingItemId={regeneratingItemId}
            />
          )}

          {/* Saving Phase */}
          {state.step === 'saving' && (
            <div className="flex flex-col items-center justify-center py-12 space-y-4">
              <div className="h-12 w-12 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" />
              <p className="text-lg font-medium text-gray-900 dark:text-white">Saving items to wardrobe...</p>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                {Math.round(state.savingProgress)}% complete
              </p>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}

export default MultiItemExtractionFlow
