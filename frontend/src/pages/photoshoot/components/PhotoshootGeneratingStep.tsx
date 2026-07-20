/**
 * Generating step — honest wait surface with source previews.
 * No fake percentage progress.
 */

import { usePhotoshoot } from '@/stores/photoshootStore';
import { GeneratingSurface } from '@/components/jobs';
import { Button } from '@/components/ui/button';
import { useJobUiStore } from '@/stores/jobUiStore';
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export function PhotoshootGeneratingStep() {
  const {
    progress,
    statusMessage,
    numImages,
    photoPreviewUrls,
    isGenerating,
    error,
    generate,
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

  return (
    <GeneratingSurface
      stage={statusMessage || 'Creating your photoshoot…'}
      detail={`Often 1–2 minutes for ${numImages} image${numImages === 1 ? '' : 's'}. You can leave this page — check the progress pill.`}
      progress={typeof progress === 'number' && progress >= 100 ? 100 : null}
      previewUrls={photoPreviewUrls}
      previewLabel="Your reference photos"
      isActive={isGenerating}
      onBackground={() => navigate('/dashboard')}
    />
  );
}
