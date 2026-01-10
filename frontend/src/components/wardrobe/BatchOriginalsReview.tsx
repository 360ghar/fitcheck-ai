/**
 * BatchOriginalsReview Component
 *
 * Displays original images with bounding boxes for batch review.
 */

import { ZoomableImage } from '@/components/ui/zoomable-image';
import type { BatchImageInput, DetectedItem } from '@/types';

const BOX_COLORS = [
  '#3B82F6', '#10B981', '#F59E0B', '#EF4444',
  '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16',
];

const LEGEND_COLORS = [
  'bg-blue-500', 'bg-green-500', 'bg-amber-500', 'bg-red-500',
  'bg-purple-500', 'bg-pink-500', 'bg-cyan-500', 'bg-lime-500',
];

function getItemLabel(item: DetectedItem) {
  return item.name || item.sub_category || item.category;
}

interface BatchOriginalsReviewProps {
  images: BatchImageInput[];
}

export function BatchOriginalsReview({ images }: BatchOriginalsReviewProps) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      {images.map((image) => {
        const items = image.detectedItems || [];
        const hasError = image.status === 'failed';
        const itemCount = items.length;

        return (
          <div
            key={image.imageId}
            className="rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden bg-white dark:bg-gray-900"
          >
            <div className="relative aspect-square">
              <ZoomableImage
                src={image.previewUrl}
                alt={image.file.name}
                className="w-full h-full object-cover"
              />

              {/* Bounding box overlays */}
              <svg
                className="absolute inset-0 w-full h-full pointer-events-none"
                viewBox="0 0 100 100"
                preserveAspectRatio="none"
              >
                {items.map((item, index) => {
                  if (!item.boundingBox) return null;
                  const { x, y, width, height } = item.boundingBox;
                  const color = BOX_COLORS[index % BOX_COLORS.length];

                  return (
                    <g key={item.tempId}>
                      <rect
                        x={x}
                        y={y}
                        width={width}
                        height={height}
                        fill="none"
                        stroke={color}
                        strokeWidth="0.6"
                        strokeDasharray="2,1"
                      />
                      <rect
                        x={x}
                        y={y}
                        width="8"
                        height="4"
                        fill={color}
                      />
                      <text
                        x={x + 1}
                        y={y + 3}
                        fill="white"
                        fontSize="2.5"
                        fontWeight="bold"
                      >
                        {index + 1}
                      </text>
                    </g>
                  );
                })}
              </svg>

              {hasError && (
                <div className="absolute inset-0 bg-red-500/20 flex items-center justify-center">
                  <span className="text-xs font-medium text-red-700 dark:text-red-300 bg-white/80 dark:bg-gray-900/80 px-2 py-1 rounded">
                    Extraction failed
                  </span>
                </div>
              )}

              {!hasError && itemCount > 0 && (
                <div className="absolute top-2 right-2 bg-indigo-600 text-white text-xs font-medium px-2 py-1 rounded">
                  {itemCount} item{itemCount !== 1 ? 's' : ''}
                </div>
              )}
            </div>

            <div className="p-3 space-y-2">
              <div className="flex items-center justify-between gap-2">
                <p
                  className="text-sm font-medium text-gray-900 dark:text-white truncate"
                  title={image.file.name}
                >
                  {image.file.name}
                </p>
                <span className="text-xs text-gray-500 dark:text-gray-400">
                  {itemCount} found
                </span>
              </div>

              {items.length > 0 && (
                <div className="space-y-1 max-h-24 overflow-y-auto pr-1">
                  {items.map((item, index) => (
                    <div key={item.tempId} className="flex items-center gap-2 text-xs">
                      <div
                        className={`w-4 h-4 rounded-sm text-[10px] font-bold text-white flex items-center justify-center ${LEGEND_COLORS[index % LEGEND_COLORS.length]}`}
                      >
                        {index + 1}
                      </div>
                      <span className="truncate text-gray-600 dark:text-gray-300">
                        {getItemLabel(item)}
                      </span>
                    </div>
                  ))}
                </div>
              )}

              {!hasError && items.length === 0 && (
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  No items detected in this photo
                </p>
              )}

              {hasError && image.error && (
                <p className="text-xs text-red-600 dark:text-red-400">
                  {image.error}
                </p>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default BatchOriginalsReview;
