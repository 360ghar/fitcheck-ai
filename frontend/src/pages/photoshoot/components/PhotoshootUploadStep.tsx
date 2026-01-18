/**
 * Upload Step - Photo upload for photoshoot generation
 */

import { useCallback, useMemo, useEffect, useRef } from 'react';
import { useDropzone } from 'react-dropzone';
import { Camera, Lightbulb, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { usePhotoshoot } from '@/stores/photoshootStore';
import { cn } from '@/lib/utils';

const MAX_PHOTOS = 4;

export function PhotoshootUploadStep() {
  const { photos, addPhotos, removePhoto, setStep } = usePhotoshoot();
  const objectUrlsRef = useRef<Map<File, string>>(new Map());

  // Create and cache object URLs for photos
  const photoUrls = useMemo(() => {
    const urls = new Map<File, string>();
    photos.forEach((photo) => {
      // Reuse existing URL if available
      const existing = objectUrlsRef.current.get(photo);
      if (existing) {
        urls.set(photo, existing);
      } else {
        const newUrl = URL.createObjectURL(photo);
        urls.set(photo, newUrl);
      }
    });
    return urls;
  }, [photos]);

  // Cleanup object URLs when photos change or component unmounts
  useEffect(() => {
    const currentUrls = objectUrlsRef.current;
    const newUrls = photoUrls;

    // Revoke URLs for removed photos
    currentUrls.forEach((url, file) => {
      if (!newUrls.has(file)) {
        URL.revokeObjectURL(url);
      }
    });

    // Update ref with current URLs
    objectUrlsRef.current = new Map(newUrls);

    // Cleanup all URLs on unmount
    return () => {
      objectUrlsRef.current.forEach((url) => {
        URL.revokeObjectURL(url);
      });
      objectUrlsRef.current.clear();
    };
  }, [photoUrls]);

  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      addPhotos(acceptedFiles);
    },
    [addPhotos]
  );

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.png', '.jpg', '.jpeg', '.webp'] },
    maxFiles: MAX_PHOTOS - photos.length,
    disabled: photos.length >= MAX_PHOTOS,
  });

  const handleNext = () => {
    if (photos.length > 0) {
      setStep('configure');
    }
  };

  return (
    <div className="space-y-6">
      {/* Photo Preview Grid - only show if photos exist */}
      {photos.length > 0 && (
        <div
          className={cn(
            'grid gap-3',
            photos.length === 1 ? 'grid-cols-1' : 'grid-cols-2'
          )}
        >
          {photos.map((photo, index) => (
            <div
              key={index}
              className="aspect-square rounded-lg border border-muted relative overflow-hidden"
            >
              <img
                src={photoUrls.get(photo) || ''}
                alt={`Photo ${index + 1}`}
                className="w-full h-full object-cover"
              />
              <button
                onClick={() => removePhoto(index)}
                className="absolute top-2 right-2 p-1 bg-black/50 rounded-full hover:bg-black/70 transition-colors"
              >
                <X className="w-4 h-4 text-white" />
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Upload Dropzone - show when not at max */}
      {photos.length < MAX_PHOTOS && (
        <div
          {...getRootProps()}
          className={cn(
            'border-2 border-dashed rounded-lg text-center cursor-pointer transition-colors',
            photos.length === 0 ? 'p-12' : 'p-6',
            isDragActive
              ? 'border-primary bg-primary/5'
              : 'border-muted-foreground/25 hover:border-muted-foreground/50'
          )}
        >
          <input {...getInputProps()} />
          <Camera
            className={cn(
              'mx-auto text-muted-foreground mb-2',
              photos.length === 0 ? 'w-12 h-12' : 'w-8 h-8'
            )}
          />
          <p className="text-sm text-muted-foreground">
            {isDragActive
              ? 'Drop photos here...'
              : photos.length === 0
                ? 'Drag & drop or click to select photos'
                : 'Add more photos'}
          </p>
          <p className="text-xs text-muted-foreground/60 mt-1">
            {photos.length === 0
              ? 'Up to 4 photos'
              : `${MAX_PHOTOS - photos.length} more allowed`}
          </p>
        </div>
      )}

      {/* Tips */}
      <div className="bg-muted/50 rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <Lightbulb className="w-4 h-4 text-primary" />
          <span className="font-medium text-sm">Tips for best results</span>
        </div>
        <ul className="text-sm text-muted-foreground space-y-1">
          <li>• Clear, well-lit face photos</li>
          <li>• Multiple angles work better</li>
          <li>• Avoid sunglasses or face obstructions</li>
          <li>• Higher quality = better results</li>
        </ul>
      </div>

      {/* Next Button */}
      <Button onClick={handleNext} disabled={photos.length === 0} className="w-full">
        {photos.length === 0
          ? 'Add Photos to Continue'
          : `Continue (${photos.length} photo${photos.length !== 1 ? 's' : ''})`}
      </Button>
    </div>
  );
}
