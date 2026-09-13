import * as React from 'react';
import * as DialogPrimitive from '@radix-ui/react-dialog';
import { TransformWrapper, TransformComponent, useControls } from 'react-zoom-pan-pinch';
import { X, ZoomIn, ZoomOut, RotateCcw } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';

export interface ImageLightboxProps {
  src: string;
  alt?: string;
  open: boolean;
  onClose: () => void;
}

function ZoomControls() {
  const { zoomIn, zoomOut, resetTransform } = useControls();

  return (
    <div className="absolute bottom-[calc(1rem+var(--safe-area-bottom))] left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 rounded-full border border-white/20 bg-black/80 px-3 py-2">
      <Button
        variant="ghost"
        size="icon"
          className="h-11 w-11 text-white hover:bg-white/20 hover:text-white"
        onClick={() => zoomOut()}
        aria-label="Zoom out"
      >
        <ZoomOut className="h-5 w-5" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
          className="h-11 w-11 text-white hover:bg-white/20 hover:text-white"
        onClick={() => resetTransform()}
        aria-label="Reset zoom"
      >
        <RotateCcw className="h-5 w-5" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
          className="h-11 w-11 text-white hover:bg-white/20 hover:text-white"
        onClick={() => zoomIn()}
        aria-label="Zoom in"
      >
        <ZoomIn className="h-5 w-5" />
      </Button>
    </div>
  );
}

export function ImageLightbox({ src, alt, open, onClose }: ImageLightboxProps) {
  // Handle keyboard shortcuts
  React.useEffect(() => {
    if (!open) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [open, onClose]);

  return (
    <DialogPrimitive.Root open={open} onOpenChange={(isOpen) => !isOpen && onClose()}>
      <DialogPrimitive.Portal>
        <DialogPrimitive.Overlay
          className={cn(
            'fixed inset-0 z-[100] bg-black/95',
            'data-[state=open]:animate-in data-[state=closed]:animate-out',
            'data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0'
          )}
        />
        <DialogPrimitive.Content
          className={cn(
            'fixed inset-0 z-[100] flex items-center justify-center',
            'data-[state=open]:animate-in data-[state=closed]:animate-out',
            'data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0'
          )}
          aria-describedby={undefined}
        >
          {/* Hidden title for accessibility */}
          <DialogPrimitive.Title className="sr-only">
            {alt || 'Image preview'}
          </DialogPrimitive.Title>

          {/* Close button */}
          <Button
            variant="ghost"
            size="icon"
            className="absolute top-[calc(1rem+var(--safe-area-top))] right-4 z-[101] h-11 w-11 text-white hover:bg-white/20 hover:text-white"
            onClick={onClose}
            aria-label="Close"
          >
            <X className="h-6 w-6" />
          </Button>

          {/* Zoomable image container */}
          <TransformWrapper
            initialScale={1}
            minScale={0.5}
            maxScale={5}
            centerOnInit
            wheel={{ step: 0.1 }}
            pinch={{ step: 5 }}
            doubleClick={{ mode: 'toggle', step: 2 }}
          >
            <ZoomControls />
            <TransformComponent
              wrapperClass="!w-full !h-full"
              contentClass="!w-full !h-full !flex !items-center !justify-center"
            >
              <img
                src={src}
                alt={alt || 'Preview image'}
                className="max-h-[90dvh] max-w-[90vw] object-contain select-none"
                draggable={false}
                decoding="async"
              />
            </TransformComponent>
          </TransformWrapper>

          {/* Hint text — short touch label on phones; full pointer hint from sm up
              (the full pill overlaps the close button below ~430px) */}
          <div className="absolute top-[calc(1rem+var(--safe-area-top))] left-1/2 -translate-x-1/2 z-50 hidden sm:block text-white/60 text-sm bg-black/40 backdrop-blur-sm rounded-full px-3 py-1">
            Double-click to zoom • Scroll or pinch to adjust
          </div>
          <div className="absolute top-[calc(1rem+var(--safe-area-top))] left-1/2 -translate-x-1/2 z-50 sm:hidden text-white/60 text-xs bg-black/40 backdrop-blur-sm rounded-full px-3 py-1">
            Pinch to zoom
          </div>
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}
