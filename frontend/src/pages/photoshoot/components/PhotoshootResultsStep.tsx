/**
 * Results Step - Display and download generated images
 */

import { useState } from 'react';
import { Download, CheckCircle, RefreshCw, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogTitle } from '@/components/ui/dialog';
import { usePhotoshoot } from '@/stores/photoshootStore';
import { useToast } from '@/components/ui/use-toast';

// Transparent 1x1 pixel as placeholder for missing images
const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

export function PhotoshootResultsStep() {
  const { generatedImages, sessionId, usage, reset } = usePhotoshoot();
  const { toast } = useToast();
  const [previewIndex, setPreviewIndex] = useState<number | null>(null);

  const getImageSrc = (index: number) => {
    const image = generatedImages[index]
    if (!image) return null
    if (image.image_url) return image.image_url
    if (image.image_base64) return `data:image/png;base64,${image.image_base64}`
    return null
  }

  const downloadImage = async (index: number, showToast = true) => {
    const src = getImageSrc(index)
    if (!src) return

    try {
      // Convert base64 to blob
      const response = await fetch(src);
      const blob = await response.blob();

      // Create download link
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `photoshoot_${sessionId}_${index + 1}.png`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);

      if (showToast) {
        toast({ title: 'Downloaded', description: 'Image saved successfully' });
      }
    } catch (error) {
      if (showToast) {
        toast({ title: 'Error', description: 'Failed to download image', variant: 'destructive' });
      }
    }
  };

  const downloadAll = async () => {
    // Download all without individual toasts
    for (let i = 0; i < generatedImages.length; i++) {
      await downloadImage(i, false);
      // Small delay between downloads
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
    // Show single summary toast
    toast({
      title: 'Downloaded',
      description: `${generatedImages.length} images saved successfully`,
    });
  };

  return (
    <div className="space-y-6">
      {/* Action Bar */}
      <div className="flex gap-3">
        <Button onClick={downloadAll} className="flex-1">
          <Download className="w-4 h-4 mr-2" />
          Download All ({generatedImages.length})
        </Button>
        <Button variant="outline" onClick={reset}>
          <RefreshCw className="w-4 h-4 mr-2" />
          New
        </Button>
      </div>

      {/* Image Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
        {generatedImages.map((image, index) => (
          <div
            key={image.id}
            className="relative aspect-[3/4] rounded-lg overflow-hidden bg-muted cursor-pointer group"
            onClick={() => setPreviewIndex(index)}
          >
            <img
              src={getImageSrc(index) || PLACEHOLDER_IMAGE}
              alt={`Generated ${index + 1}`}
              className="w-full h-full object-cover"
            />

            {/* Index Badge */}
            <div className="absolute top-2 left-2 px-2 py-1 bg-black/50 rounded-full">
              <span className="text-xs text-white font-medium">{index + 1}</span>
            </div>

            {/* Download Button */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                downloadImage(index, true);
              }}
              className="absolute bottom-2 right-2 p-2 bg-primary rounded-full text-white opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <Download className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

      {/* Usage Summary */}
      {usage && (
        <div className="flex items-center justify-center gap-2 p-4 bg-muted/30 rounded-lg text-sm">
          <CheckCircle className="w-4 h-4 text-green-500" />
          <span className="text-muted-foreground">
            {generatedImages.length} images generated • {usage.remaining} remaining today
          </span>
        </div>
      )}

      {/* Fullscreen Preview Dialog */}
      <Dialog open={previewIndex !== null} onOpenChange={() => setPreviewIndex(null)}>
        <DialogContent className="max-w-4xl p-0 bg-black/95 border-none">
          <DialogTitle className="sr-only">Image Preview</DialogTitle>
          {previewIndex !== null && generatedImages[previewIndex] && (
            <div className="relative">
              <img
                src={getImageSrc(previewIndex) || PLACEHOLDER_IMAGE}
                alt={`Preview ${previewIndex + 1}`}
                className="w-full h-auto max-h-[80vh] object-contain"
              />
              <button
                onClick={() => setPreviewIndex(null)}
                className="absolute top-4 right-4 p-2 bg-black/50 rounded-full text-white hover:bg-black/70"
              >
                <X className="w-5 h-5" />
              </button>
              <div className="absolute bottom-4 left-1/2 -translate-x-1/2">
                <Button
                  onClick={() => {
                    downloadImage(previewIndex, true);
                    setPreviewIndex(null);
                  }}
                >
                  <Download className="w-4 h-4 mr-2" />
                  Download
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
