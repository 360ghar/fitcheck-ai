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
  onClick,
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

  return (
    <>
      <img
        src={src}
        alt={alt}
        className={cn(
          className,
          enableZoom && src && 'cursor-zoom-in'
        )}
        onClick={handleClick}
        {...imgProps}
      />
      {enableZoom && src && (
        <ImageLightbox
          src={src}
          alt={alt}
          open={isOpen}
          onClose={() => setIsOpen(false)}
        />
      )}
    </>
  );
}
