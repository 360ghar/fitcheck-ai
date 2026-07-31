import * as React from 'react';
import { cn } from '@/lib/utils';
import { ImageLightbox } from './image-lightbox';

export interface ZoomableImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  /**
   * Enable zoom functionality. When true, clicking the image opens a lightbox.
   * @default true
   */
  enableZoom?: boolean;
  /**
   * Alt text for the image (also used in lightbox)
   */
  alt?: string;
  /** Optional higher-resolution source used only inside the lightbox. */
  lightboxSrc?: string;
}

/**
 * A wrapper around the standard img element that adds click-to-zoom functionality.
 * When clicked, opens a fullscreen lightbox with zoom and pan capabilities.
 */
export function ZoomableImage({
  enableZoom = true,
  className,
  src,
  alt,
  lightboxSrc,
  onClick,
  onKeyDown,
  role: _role,
  tabIndex: _tabIndex,
  decoding: _decoding,
  ['aria-label']: _ariaLabel,
  ...imgProps
}: ZoomableImageProps) {
  const [isOpen, setIsOpen] = React.useState(false);

  const handleClick = (e: React.MouseEvent<HTMLImageElement>) => {
    if (enableZoom && src) {
      setIsOpen(true);
    }
    // Call original onClick if provided
    onClick?.(e);
  };

  const isZoomable = enableZoom && !!src;

  return (
    <>
      <img
        {...imgProps}
        src={src}
        alt={alt}
        className={cn(
          className,
          isZoomable && 'cursor-zoom-in focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2'
        )}
        onClick={handleClick}
        role={isZoomable ? 'button' : undefined}
        tabIndex={isZoomable ? 0 : undefined}
        onKeyDown={(e) => {
          if (isZoomable) {
                if (e.key === 'Enter' || e.key === ' ') {
                  e.preventDefault();
                  setIsOpen(true);
                }
          }
          onKeyDown?.(e)
        }}
        aria-label={isZoomable ? `Open image preview: ${alt || 'image'}` : undefined}
        decoding="async"
      />
      {enableZoom && src && (
        <ImageLightbox
          src={lightboxSrc || src}
          alt={alt}
          open={isOpen}
          onClose={() => setIsOpen(false)}
        />
      )}
    </>
  );
}
