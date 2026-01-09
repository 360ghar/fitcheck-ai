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
    <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 bg-black/60 backdrop-blur-sm rounded-full px-3 py-2">
      <Button
        variant="ghost"
        size="icon"
        className="h-10 w-10 text-white hover:bg-white/20 hover:text-white"
        onClick={() => zoomOut()}
        aria-label="Zoom out"
      >
        <ZoomOut className="h-5 w-5" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
        className="h-10 w-10 text-white hover:bg-white/20 hover:text-white"
        onClick={() => resetTransform()}
        aria-label="Reset zoom"
      >
        <RotateCcw className="h-5 w-5" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
        className="h-10 w-10 text-white hover:bg-white/20 hover:text-white"
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
            className="absolute top-4 right-4 z-[101] h-10 w-10 text-white hover:bg-white/20 hover:text-white"
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
                className="max-h-[90vh] max-w-[90vw] object-contain select-none"
                draggable={false}
              />
            </TransformComponent>
          </TransformWrapper>

          {/* Hint text */}
          <div className="absolute top-4 left-1/2 -translate-x-1/2 z-50 text-white/60 text-sm bg-black/40 backdrop-blur-sm rounded-full px-3 py-1">
            Double-click to zoom • Scroll or pinch to adjust
          </div>
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}
