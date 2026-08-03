/**
 * Generating step — live wait surface.
 * Shows real progress, the scene being generated, an ETA from rolling
 * per-image latency, and thumbnails as each image completes. No fake progress.
 */

import { usePhotoshoot } from '@/stores/photoshootStore';
import { GeneratingSurface } from '@/components/jobs';
import { Button } from '@/components/ui/button';
import { useJobUiStore } from '@/stores/jobUiStore';
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

function formatEta(seconds: number): string {
  if (seconds < 60) return `~${Math.max(seconds, 5)}s left`;
  const minutes = Math.floor(seconds / 60);
  const remainder = seconds % 60;
  return remainder > 0 ? `~${minutes}m ${remainder}s left` : `~${minutes}m left`;
}

export function PhotoshootGeneratingStep() {
  const {
    progress,
    statusMessage,
    numImages,
    photoPreviewUrls,
    generatedImages,
    currentSceneLabel,
    etaSeconds,
    isGenerating,
    error,
    generate,
    cancelGeneration,
    setStep,
  } = usePhotoshoot();
  const setJob = useJobUiStore((s) => s.setJob);
  const clearJob = useJobUiStore((s) => s.clearJob);
  const navigate = useNavigate();

  useEffect(() => {
    if (isGenerating) {
      setJob({
        id: 'photoshoot',
        label: `Photoshoot · ${numImages} image${numImages === 1 ? '' : 's'}`,
        isActive: true,
        href: '/photoshoot',
        onOpen: () => navigate('/photoshoot'),
      });
      return;
    }
    // Success or failure — never leave a spinning pill stuck after the run ends.
    clearJob('photoshoot');
  }, [isGenerating, numImages, setJob, clearJob, navigate]);

  if (error && !isGenerating) {
    return (
      <div className="space-y-4">
        <GeneratingSurface
          stage="Generation failed"
          detail={error}
          isActive={false}
          previewUrls={photoPreviewUrls}
          previewLabel="Your reference photos"
        />
        <div className="flex flex-wrap gap-2 justify-center">
          <Button
            onClick={() => {
              void generate();
            }}
          >
            Try again
          </Button>
          <Button variant="outline" onClick={() => setStep('configure')}>
            Back to options
          </Button>
        </div>
      </div>
    );
  }

  const detailLines = [
    `Generating ${numImages} image${numImages === 1 ? '' : 's'} · you can leave this page and check the progress pill.`,
  ];
  if (currentSceneLabel && isGenerating) {
    detailLines.unshift(`Now: ${currentSceneLabel}`);
  }

  return (
    <GeneratingSurface
      stage={statusMessage || 'Creating your photoshoot…'}
      detail={detailLines.join(' ')}
      progress={typeof progress === 'number' ? progress : null}
      previewUrls={photoPreviewUrls}
      previewLabel="Your reference photos"
      isActive={isGenerating}
      onBackground={() => navigate('/dashboard')}
      onCancel={isGenerating ? () => void cancelGeneration() : undefined}
    >
      {/* Live gallery — fills with thumbnails as images complete */}
      {generatedImages.length > 0 && (
        <div className="pt-1">
          <div className="flex items-center justify-between mb-2">
            <p className="text-xs font-medium text-muted-foreground">
              Generated so far
            </p>
            {etaSeconds !== null && etaSeconds > 0 && (
              <p className="text-xs font-medium text-muted-foreground">
                {formatEta(etaSeconds)}
              </p>
            )}
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            {generatedImages.map((image) => (
              <div
                key={image.id}
                className="aspect-[3/4] rounded-lg overflow-hidden bg-muted border border-border"
              >
                <img
                  src={
                    image.image_url ??
                    (image.image_base64
                      ? `data:image/png;base64,${image.image_base64}`
                      : undefined)
                  }
                  alt={image.label ? `Generated: ${image.label}` : `Generated image ${image.index + 1}`}
                  className="w-full h-full object-cover"
                  loading="lazy"
                  decoding="async"
                />
              </div>
            ))}
          </div>
        </div>
      )}
    </GeneratingSurface>
  );
}
