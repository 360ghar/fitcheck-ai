/**
 * BatchImageSelector Component
 *
 * Multi-image selection component with drag-and-drop.
 * Allows users to select up to 50 images for batch processing.
 */

import { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Upload, X, ImagePlus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import type { BatchImageInput } from '@/types';

interface BatchImageSelectorProps {
  /** Currently selected images */
  selectedImages: BatchImageInput[];
  /** Callback when images are added */
  onImagesSelected: (files: File[]) => void;
  /** Callback to remove an image */
  onImageRemove: (imageId: string) => void;
  /** Callback to clear all images */
  onClearAll?: () => void;
  /** Maximum number of images allowed */
  maxImages?: number;
  /** Whether the selector is disabled */
  disabled?: boolean;
  /** Error message to display */
  error?: string | null;
  /** Callback when user wants to proceed */
  onContinue?: () => void;
}

export function BatchImageSelector({
  selectedImages,
  onImagesSelected,
  onImageRemove,
  onClearAll,
  maxImages = 50,
  disabled = false,
  error,
  onContinue,
}: BatchImageSelectorProps) {
  const remainingSlots = maxImages - selectedImages.length;

  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      if (disabled) return;
      // Only take as many files as we have remaining slots
      const filesToAdd = acceptedFiles.slice(0, remainingSlots);
      if (filesToAdd.length > 0) {
        onImagesSelected(filesToAdd);
      }
    },
    [disabled, remainingSlots, onImagesSelected]
  );

  const { getRootProps, getInputProps, isDragActive, open } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.webp'],
    },
    multiple: true,
    maxSize: 10 * 1024 * 1024, // 10MB per file
    disabled,
  });

  const hasImages = selectedImages.length > 0;
  const isFull = selectedImages.length >= maxImages;
  const handleOpen = () => {
    if (!disabled) {
      open();
    }
  };

  return (
    <div className="flex flex-col h-full space-y-4">
      {/* Error message */}
      {error && (
        <div className="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-800 dark:text-red-300">
          {error}
        </div>
      )}

      {/* Drop zone */}
      {!isFull && (
        <div
          {...getRootProps()}
          className={cn(
            'border-2 border-dashed rounded-lg p-8 text-center transition-colors cursor-pointer flex flex-col items-center justify-center',
            isDragActive
              ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
              : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500',
            disabled && 'opacity-50 cursor-not-allowed',
            hasImages ? 'min-h-[120px]' : 'min-h-[200px]'
          )}
        >
          <input {...getInputProps()} />
          <Upload
            className={cn(
              'mx-auto text-gray-400 dark:text-gray-500 mb-3',
              hasImages ? 'h-8 w-8' : 'h-12 w-12'
            )}
          />
          <p className={cn('font-medium text-gray-900 dark:text-white', hasImages ? 'text-sm' : 'text-lg')}>
            {isDragActive ? 'Drop images here' : 'Drop clothing photos here'}
          </p>
          <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
            or click to browse
          </p>
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
            Supports PNG, JPG, WEBP up to 10MB each
          </p>
          {hasImages && (
            <p className="text-xs text-gray-400 dark:text-gray-500 mt-1">
              {remainingSlots} more {remainingSlots === 1 ? 'image' : 'images'} allowed
            </p>
          )}
        </div>
      )}

      {/* Selected images grid */}
      {hasImages && (
        <div className="flex-1 overflow-y-auto min-h-0">
          <div className="flex items-center justify-between mb-3">
            <p className="text-sm font-medium text-gray-700 dark:text-gray-300">
              {selectedImages.length} of {maxImages} images selected
            </p>
            {onClearAll && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onClearAll}
                className="text-red-600 hover:text-red-700 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/20"
              >
                <Trash2 className="h-4 w-4 mr-1" />
                Clear all
              </Button>
            )}
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
            {selectedImages.map((image) => (
              <div
                key={image.imageId}
                className="relative aspect-square rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800 group"
              >
                <img
                  src={image.previewUrl}
                  alt={image.file.name}
                  className="w-full h-full object-cover"
                />
                {/* Overlay with file name */}
                <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent p-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                  <p className="text-xs text-white truncate">
                    {image.file.name}
                  </p>
                </div>
                {/* Remove button */}
                <button
                  type="button"
                  onClick={() => onImageRemove(image.imageId)}
                  className="absolute top-2 right-2 p-1.5 rounded-full bg-black/60 text-white opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity hover:bg-black/70"
                  disabled={disabled}
                  aria-label={`Remove ${image.file.name}`}
                >
                  <X className="h-4 w-4" />
                </button>
                {/* Status indicator */}
                {image.status === 'failed' && (
                  <div className="absolute inset-0 bg-red-500/20 flex items-center justify-center">
                    <div className="bg-red-500 text-white text-xs px-2 py-1 rounded">
                      Failed
                    </div>
                  </div>
                )}
              </div>
            ))}

            {/* Add more button when there are images but not full */}
            {!isFull && (
              <button
                type="button"
                onClick={handleOpen}
                className={cn(
                  'aspect-square rounded-lg border-2 border-dashed flex flex-col items-center justify-center cursor-pointer transition-colors',
                  isDragActive
                    ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500',
                  disabled && 'opacity-50 cursor-not-allowed'
                )}
                disabled={disabled}
                aria-label="Add more images"
              >
                <ImagePlus className="h-8 w-8 text-gray-400 dark:text-gray-500 mb-1" />
                <span className="text-xs text-gray-500 dark:text-gray-400">
                  Add more
                </span>
              </button>
            )}
          </div>
        </div>
      )}

      {/* Action buttons */}
      {hasImages && onContinue && (
        <div className="flex justify-end pt-4 border-t dark:border-gray-700">
          <Button
            onClick={onContinue}
            disabled={disabled || selectedImages.length === 0}
            className="min-w-[120px]"
          >
            Continue
          </Button>
        </div>
      )}
    </div>
  );
}

export default BatchImageSelector;
