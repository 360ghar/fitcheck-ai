/**
 * TryOnPage - Main page for "Try My Look" feature.
 *
 * Allows users to upload a clothing image and see how they would look wearing it.
 */

import { useState, useCallback, useEffect, useRef } from 'react';
import { useDropzone } from 'react-dropzone';
import { Download, Upload, RefreshCw, Loader2, Sparkles, X, Camera } from 'lucide-react';
import { useAuthStore, useCurrentUser, useUserAvatar } from '@/stores/authStore';
import { useJobUiStore } from '@/stores/jobUiStore';
import { generateTryOn, TryOnOptions, TryOnResult } from '@/api/ai';
import { uploadAvatar } from '@/api/users';
import { tryOnUsedKey } from '@/lib/activation';

/** Module-level so remount does not clear the pill while a request is in flight. */
let tryOnRequestInFlight = false;
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useToast } from '@/components/ui/use-toast';
import { ZoomableImage } from '@/components/ui/zoomable-image';
import { WizardSteps } from '@/components/ui/wizard-steps';
import { GeneratingSurface } from '@/components/jobs';
import { cn } from '@/lib/utils';

type TryOnStep = 'upload' | 'options' | 'generating' | 'result';

const STYLE_OPTIONS = [
  { value: 'casual', label: 'Casual' },
  { value: 'formal', label: 'Formal' },
  { value: 'business', label: 'Business' },
  { value: 'sporty', label: 'Sporty' },
  { value: 'streetwear', label: 'Streetwear' },
  { value: 'elegant', label: 'Elegant' },
];

const BACKGROUND_OPTIONS = [
  { value: 'studio white', label: 'Studio White' },
  { value: 'studio gray', label: 'Studio Gray' },
  { value: 'urban street', label: 'Urban Street' },
  { value: 'nature outdoor', label: 'Nature' },
  { value: 'minimal', label: 'Minimal' },
];

const POSE_OPTIONS = [
  { value: 'standing front', label: 'Standing Front' },
  { value: 'standing side', label: 'Standing Side' },
  { value: 'walking', label: 'Walking' },
  { value: 'casual pose', label: 'Casual' },
];

const STEPS = [
  { id: 'upload', label: 'Upload', shortLabel: '1' },
  { id: 'options', label: 'Options', shortLabel: '2' },
  { id: 'generating', label: 'Generate', shortLabel: '3' },
  { id: 'result', label: 'Result', shortLabel: '4' },
] as const;

export default function TryOnPage() {
  const userAvatar = useUserAvatar();
  const setUser = useAuthStore((s) => s.setUser);
  const user = useCurrentUser();
  const { toast } = useToast();
  const setJob = useJobUiStore((s) => s.setJob);
  const clearJob = useJobUiStore((s) => s.clearJob);

  const [step, setStep] = useState<TryOnStep>('upload');
  const clothingFileRef = useRef<File | null>(null);
  const [clothingPreview, setClothingPreview] = useState<string | null>(null);
  const [clothingDescription, setClothingDescription] = useState('');
  const [style, setStyle] = useState('casual');
  const [background, setBackground] = useState('studio white');
  const [pose, setPose] = useState('standing front');
  const [isGenerating, setIsGenerating] = useState(false);
  const [result, setResult] = useState<TryOnResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const previewUrlRef = useRef<string | null>(null);
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const revokePreviewUrl = useCallback(() => {
    if (previewUrlRef.current) {
      URL.revokeObjectURL(previewUrlRef.current);
      previewUrlRef.current = null;
    }
  }, []);

  useEffect(() => {
    return () => {
      revokePreviewUrl();
    };
  }, [revokePreviewUrl]);

  useEffect(() => {
    // Prefer module flag over local state so remount mid-request does not clear the pill.
    if (isGenerating || tryOnRequestInFlight) {
      setJob({
        id: 'try-on',
        label: 'Generating try-on…',
        isActive: true,
        href: '/try-on',
      });
      if (tryOnRequestInFlight && !isGenerating) {
        setIsGenerating(true);
        setStep('generating');
      }
    } else {
      clearJob('try-on');
    }
  }, [isGenerating, setJob, clearJob]);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      revokePreviewUrl();
      const url = URL.createObjectURL(file);
      previewUrlRef.current = url;
      clothingFileRef.current = file;
      setClothingPreview(url);
      setStep('options');
      setError(null);
    }
  }, [revokePreviewUrl]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.gif'],
    },
    multiple: false,
    maxSize: 10 * 1024 * 1024, // 10MB
  });

  const handleAvatarUpload = async (file: File) => {
    setIsUploadingAvatar(true);
    try {
      const { avatar_url } = await uploadAvatar(file);
      if (user) {
        setUser({ ...user, avatar_url });
      }
      toast({ title: 'Photo added', description: 'You can generate a try-on now.' });
    } catch (err) {
      toast({
        title: 'Upload failed',
        description: err instanceof Error ? err.message : 'Could not upload photo',
        variant: 'destructive',
      });
    } finally {
      setIsUploadingAvatar(false);
    }
  };

  const handleGenerate = async () => {
    if (!clothingFileRef.current) return;
    if (!userAvatar) {
      toast({
        title: 'Photo of you required',
        description: 'Add a clear photo of yourself first.',
        variant: 'destructive',
      });
      return;
    }

    setIsGenerating(true);
    tryOnRequestInFlight = true;
    setStep('generating');
    setError(null);
    setJob({
      id: 'try-on',
      label: 'Generating try-on…',
      isActive: true,
      href: '/try-on',
    });

    try {
      const options: TryOnOptions = {
        clothing_description: clothingDescription || undefined,
        style,
        background,
        pose,
      };

      const tryOnResult = await generateTryOn(clothingFileRef.current, options);
      setResult(tryOnResult);
      setStep('result');
      try {
        localStorage.setItem(tryOnUsedKey(user?.id), '1');
      } catch {
        // ignore
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to generate try-on image';
      setError(errorMessage);
      toast({
        title: 'Generation Failed',
        description: errorMessage,
        variant: 'destructive',
      });
      setStep('options');
    } finally {
      tryOnRequestInFlight = false;
      setIsGenerating(false);
      // Always clear — user may have left the page mid-request.
      clearJob('try-on');
    }
  };

  const handleReset = () => {
    revokePreviewUrl();
    clothingFileRef.current = null;
    setClothingPreview(null);
    setClothingDescription('');
    setResult(null);
    setError(null);
    setStep('upload');
  };

  const handleDownload = () => {
    if (!result) return;

    const link = document.createElement('a');
    link.href = result.image_url || `data:image/png;base64,${result.image_base64}`;
    link.download = `try-on-${Date.now()}.png`;
    link.click();
  };

  const handleRegenerate = () => {
    setResult(null);
    void handleGenerate();
  };


  return (
    <div className="max-w-4xl mx-auto px-4 py-4 md:py-8">
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-2xl font-bold text-foreground">Try My Look</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload a picture of clothes to see how you would look wearing them.
        </p>
      </div>

      {/* Inline avatar gate — stay on page instead of hard redirect to profile */}
      {!userAvatar && (
        <Card className="mb-4 md:mb-6 border-border">
          <CardHeader className="px-4 py-3 md:px-6 md:py-4">
            <CardTitle className="text-base md:text-lg flex items-center gap-2">
              <Camera className="h-5 w-5" />
              Add a photo of you
            </CardTitle>
            <CardDescription>
              A clear full-body or waist-up photo is required for try-on. Good lighting, face and
              torso visible.
            </CardDescription>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6 flex flex-wrap gap-2">
            <input
              ref={avatarInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) void handleAvatarUpload(file);
                e.target.value = '';
              }}
            />
            <Button
              onClick={() => avatarInputRef.current?.click()}
              disabled={isUploadingAvatar}
            >
              {isUploadingAvatar ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Uploading…
                </>
              ) : (
                <>
                  <Upload className="h-4 w-4 mr-2" />
                  Upload photo
                </>
              )}
            </Button>
          </CardContent>
        </Card>
      )}

      <WizardSteps
        steps={[...STEPS]}
        currentStepId={step}
        onStepClick={(id) => {
          const order: TryOnStep[] = ['upload', 'options', 'generating', 'result'];
          const target = order.indexOf(id as TryOnStep);
          const current = order.indexOf(step);
          if (target >= 0 && target < current && id !== 'generating') {
            setStep(id as TryOnStep);
          }
        }}
      />

      {step === 'upload' && (
        <Card>
          <CardHeader className="px-4 py-3 md:px-6 md:py-4">
            <CardTitle className="text-base md:text-lg">Upload Clothing Image</CardTitle>
            <CardDescription>
              Upload a photo of the clothes you want to try on. Works best with clear, well-lit images.
            </CardDescription>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
            <div
              {...getRootProps()}
              className={cn(
                'border-2 border-dashed rounded-lg p-6 md:p-12 text-center cursor-pointer transition-colors touch-target',
                isDragActive
                  ? 'border-primary bg-primary/10'
                  : 'border-border hover:border-primary/50'
              )}
            >
              <input {...getInputProps()} />
              <Upload className="mx-auto h-10 w-10 md:h-12 md:w-12 text-muted-foreground" />
              <p className="mt-4 text-base md:text-lg font-medium text-foreground">
                {isDragActive ? 'Drop the image here' : 'Drag & drop a clothing image'}
              </p>
              <p className="mt-2 text-sm text-muted-foreground">
                or tap to browse
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {step === 'options' && clothingPreview && (
        <div className="grid gap-4 md:gap-6 md:grid-cols-2">
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="flex items-center justify-between text-base md:text-lg">
                Clothing Preview
                <Button variant="ghost" size="sm" onClick={handleReset}>
                  <X className="h-4 w-4 mr-1" />
                  Change
                </Button>
              </CardTitle>
            </CardHeader>
            <CardContent className="px-4 pb-4 md:px-6 md:pb-6 space-y-3">
              <ZoomableImage
                src={clothingPreview}
                alt="Clothing preview"
                className="w-full h-48 md:h-64 object-contain rounded-lg bg-muted"
              />
              {userAvatar && (
                <div className="flex items-center gap-3">
                  <img
                    src={userAvatar}
                    alt="You"
                    className="h-12 w-12 rounded-full object-cover border border-border"
                  />
                  <p className="text-xs text-muted-foreground">Using this photo of you</p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Generation Options</CardTitle>
              <CardDescription>
                Customize how your try-on image will look.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              <div className="space-y-2">
                <Label htmlFor="description">Description (optional)</Label>
                <Input
                  id="description"
                  placeholder="e.g., Blue denim jacket with brass buttons"
                  value={clothingDescription}
                  onChange={(e) => setClothingDescription(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  Adding a description helps improve accuracy.
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="tryon-style">Style</Label>
                <Select value={style} onValueChange={setStyle}>
                  <SelectTrigger id="tryon-style">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {STYLE_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="tryon-background">Background</Label>
                <Select value={background} onValueChange={setBackground}>
                  <SelectTrigger id="tryon-background">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {BACKGROUND_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="tryon-pose">Pose</Label>
                <Select value={pose} onValueChange={setPose}>
                  <SelectTrigger id="tryon-pose">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {POSE_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {error && (
                <p className="text-sm text-destructive">{error}</p>
              )}

              <Button
                className="w-full mt-4"
                onClick={() => void handleGenerate()}
                disabled={isGenerating || !userAvatar}
              >
                <Sparkles className="h-4 w-4 mr-2" />
                Generate Try-On
              </Button>
            </CardContent>
          </Card>
        </div>
      )}

      {step === 'generating' && (
        <GeneratingSurface
          stage="Generating your try-on…"
          detail="Often under a minute. Combining your photo with the clothing."
          isActive
          previewUrls={[clothingPreview, userAvatar].filter(Boolean) as string[]}
          previewLabel="Clothing + your photo"
        />
      )}

      {step === 'result' && result && (
        <div className="space-y-4 md:space-y-6">
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between text-base md:text-lg">
                Your Try-On Result
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" onClick={handleRegenerate}>
                    <RefreshCw className="h-4 w-4 mr-1" />
                    <span className="hidden xs:inline">Regenerate</span>
                    <span className="xs:hidden">Retry</span>
                  </Button>
                  <Button variant="outline" size="sm" onClick={handleDownload}>
                    <Download className="h-4 w-4 mr-1" />
                    <span className="hidden xs:inline">Download</span>
                    <span className="xs:hidden">Save</span>
                  </Button>
                </div>
              </CardTitle>
            </CardHeader>
            <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
              <ZoomableImage
                src={result.image_url || `data:image/png;base64,${result.image_base64}`}
                alt="Try-on result"
                className="w-full max-h-[50vh] md:max-h-[600px] object-contain rounded-lg bg-muted"
              />
            </CardContent>
          </Card>

          <div className="flex justify-center">
            <Button onClick={handleReset} className="w-full sm:w-auto">
              <Upload className="h-4 w-4 mr-2" />
              Try Another Look
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
