/**
 * InstagramImageGrid Component
 *
 * Selectable grid of scraped Instagram images.
 */

import { Check, Video, Image as ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import type { InstagramImageMeta } from '@/types';

interface InstagramImageGridProps {
  images: InstagramImageMeta[];
  selectedIds: Set<string>;
  onSelect: (imageId: string, selected: boolean) => void;
  onSelectAll: () => void;
  onClearSelection: () => void;
  onConfirm: () => void;
  maxSelectable: number;
  isLoading?: boolean;
}

export function InstagramImageGrid({
  images,
  selectedIds,
  onSelect,
  onSelectAll,
  onClearSelection,
  onConfirm,
  maxSelectable,
  isLoading,
}: InstagramImageGridProps) {
  const selectedCount = selectedIds.size;
  const canSelectMore = selectedCount < maxSelectable;
  const imageCount = images.filter(img => !img.is_video).length;

  return (
    <div className="space-y-4">
      {/* Header with selection controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="space-y-1">
          <p className="text-sm font-medium text-foreground">
            Select images to import ({selectedCount}/{maxSelectable})
          </p>
          <p className="text-xs text-muted-foreground">
            {imageCount} images found • {images.length - imageCount} videos (skipped)
          </p>
        </div>
        <div className="flex gap-2">
          {selectedCount > 0 && (
            <Button
              variant="ghost"
              size="sm"
              onClick={onClearSelection}
              disabled={isLoading}
            >
              Clear
            </Button>
          )}
          <Button
            variant="outline"
            size="sm"
            onClick={onSelectAll}
            disabled={isLoading}
          >
            Select First {Math.min(maxSelectable, imageCount)}
          </Button>
          <Button
            size="sm"
            onClick={onConfirm}
            disabled={selectedCount === 0 || isLoading}
          >
            Continue with {selectedCount} images
          </Button>
        </div>
      </div>

      {/* Image grid */}
      <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2 max-h-[400px] overflow-y-auto p-1">
        {images.map((image) => {
          const isSelected = selectedIds.has(image.image_id);
          const isDisabled = image.is_video || (!isSelected && !canSelectMore);

          return (
            <button
              key={image.image_id}
              type="button"
              className={cn(
                'relative aspect-square rounded-md overflow-hidden cursor-pointer group focus:outline-none focus:ring-2 focus:ring-gold-500 focus:ring-offset-2',
                isSelected && 'ring-2 ring-gold-500',
                isDisabled && 'opacity-50 cursor-not-allowed',
                image.is_video && 'grayscale'
              )}
              onClick={() => !isDisabled && onSelect(image.image_id, !isSelected)}
              disabled={isDisabled || isLoading}
              title={image.is_video ? 'Videos cannot be imported' : image.caption?.slice(0, 100)}
            >
              <img
                src={image.thumbnail_url || image.image_url}
                alt=""
                className="w-full h-full object-cover transition-transform group-hover:scale-105"
                loading="lazy"
              />

              {/* Hover overlay */}
              {!isDisabled && !isSelected && (
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors" />
              )}

              {/* Selection indicator */}
              <div
                className={cn(
                  'absolute top-1.5 right-1.5 w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors',
                  isSelected
                    ? 'bg-gold-500 border-gold-500'
                    : 'bg-black/30 border-white'
                )}
              >
                {isSelected && (
                  <Check className="w-3 h-3 text-white" />
                )}
              </div>

              {/* Video indicator */}
              {image.is_video && (
                <div className="absolute bottom-1.5 right-1.5 bg-black/70 rounded px-1.5 py-0.5 flex items-center gap-1">
                  <Video className="h-3 w-3 text-white" />
                  <span className="text-[10px] text-white">Video</span>
                </div>
              )}

              {/* Selected overlay */}
              {isSelected && (
                <div className="absolute inset-0 bg-gold-500/10" />
              )}
            </button>
          );
        })}
      </div>

      {/* Empty state */}
      {images.length === 0 && (
        <div className="flex flex-col items-center justify-center py-12 text-muted-foreground">
          <ImageIcon className="h-12 w-12 mb-3 opacity-50" />
          <p className="text-sm">No images found</p>
        </div>
      )}

      {/* Bottom action bar for mobile */}
      {selectedCount > 0 && (
        <div className="sm:hidden sticky bottom-0 -mx-4 -mb-4 p-4 bg-background border-t border-border">
          <Button
            className="w-full"
            onClick={onConfirm}
            disabled={isLoading}
          >
            Continue with {selectedCount} images
          </Button>
        </div>
      )}
    </div>
  );
}

export default InstagramImageGrid;
