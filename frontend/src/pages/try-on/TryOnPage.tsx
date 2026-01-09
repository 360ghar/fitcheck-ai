/**
 * TryOnPage - Main page for "Try My Look" feature.
 *
 * Allows users to upload a clothing image and see how they would look wearing it.
 */

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Download, Upload, RefreshCw, Loader2, Sparkles, X, Check } from 'lucide-react';
import { useUserAvatar } from '@/stores/authStore';
import { generateTryOn, TryOnOptions, TryOnResult } from '@/api/ai';
import { AvatarRequiredPrompt } from '@/components/try-on';
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

function StepIndicator({ currentStep }: { currentStep: TryOnStep }) {
  const currentIndex = STEPS.findIndex((s) => s.id === currentStep);

  return (
    <div className="flex items-center justify-center gap-2 md:gap-4 mb-4 md:mb-6 px-2 overflow-x-auto">
      {STEPS.map((step, index) => {
        const isCompleted = index < currentIndex;
        const isCurrent = index === currentIndex;
        const isPending = index > currentIndex;

        return (
          <div key={step.id} className="flex items-center gap-2 md:gap-4">
            <div className="flex flex-col items-center">
              <div
                className={cn(
                  'w-8 h-8 md:w-10 md:h-10 rounded-full flex items-center justify-center text-sm font-medium transition-colors shrink-0',
                  isCompleted && 'bg-primary text-primary-foreground',
                  isCurrent && 'bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2 ring-offset-background',
                  isPending && 'bg-muted text-muted-foreground'
                )}
              >
                {isCompleted ? (
                  <Check className="h-4 w-4" />
                ) : (
                  <span className="md:hidden">{step.shortLabel}</span>
                )}
                <span className="hidden md:inline">{index + 1}</span>
              </div>
              <span
                className={cn(
                  'mt-1 text-[10px] md:text-xs',
                  isCurrent ? 'text-foreground font-medium' : 'text-muted-foreground'
                )}
              >
                {step.label}
              </span>
            </div>
            {index < STEPS.length - 1 && (
              <div
                className={cn(
                  'w-4 md:w-12 h-0.5 transition-colors',
                  index < currentIndex ? 'bg-primary' : 'bg-muted'
                )}
              />
            )}
          </div>
        );
      })}
    </div>
  );
}

export default function TryOnPage() {
  const userAvatar = useUserAvatar();
  const { toast } = useToast();

  const [step, setStep] = useState<TryOnStep>('upload');
  const [clothingFile, setClothingFile] = useState<File | null>(null);
  const [clothingPreview, setClothingPreview] = useState<string | null>(null);
  const [clothingDescription, setClothingDescription] = useState('');
  const [style, setStyle] = useState('casual');
  const [background, setBackground] = useState('studio white');
  const [pose, setPose] = useState('standing front');
  const [isGenerating, setIsGenerating] = useState(false);
  const [result, setResult] = useState<TryOnResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Check for avatar - show prompt if missing
  if (!userAvatar) {
    return <AvatarRequiredPrompt />;
  }

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      setClothingFile(file);
      setClothingPreview(URL.createObjectURL(file));
      setStep('options');
      setError(null);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.gif'],
    },
    multiple: false,
    maxSize: 10 * 1024 * 1024, // 10MB
  });

  const handleGenerate = async () => {
    if (!clothingFile) return;

    setIsGenerating(true);
    setStep('generating');
    setError(null);

    try {
      const options: TryOnOptions = {
        clothing_description: clothingDescription || undefined,
        style,
        background,
        pose,
      };

      const tryOnResult = await generateTryOn(clothingFile, options);
      setResult(tryOnResult);
      setStep('result');
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
      setIsGenerating(false);
    }
  };

  const handleReset = () => {
    setClothingFile(null);
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
    handleGenerate();
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-4 md:py-8">
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-2xl font-bold text-foreground">Try My Look</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload a picture of clothes to see how you would look wearing them.
        </p>
      </div>

      {/* Step Indicator */}
      <StepIndicator currentStep={step} />

      {/* Upload Step */}
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
              <Button variant="outline" className="mt-4 md:hidden w-full">
                Select Image
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Options Step */}
      {step === 'options' && clothingPreview && (
        <div className="grid gap-4 md:gap-6 md:grid-cols-2">
          {/* Preview */}
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
            <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
              <img
                src={clothingPreview}
                alt="Clothing preview"
                className="w-full h-48 md:h-64 object-contain rounded-lg bg-muted"
              />
            </CardContent>
          </Card>

          {/* Options */}
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
                <Label>Style</Label>
                <Select value={style} onValueChange={setStyle}>
                  <SelectTrigger>
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
                <Label>Background</Label>
                <Select value={background} onValueChange={setBackground}>
                  <SelectTrigger>
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
                <Label>Pose</Label>
                <Select value={pose} onValueChange={setPose}>
                  <SelectTrigger>
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
                onClick={handleGenerate}
                disabled={isGenerating}
              >
                <Sparkles className="h-4 w-4 mr-2" />
                Generate Try-On
              </Button>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Generating Step */}
      {step === 'generating' && (
        <Card>
          <CardContent className="py-12 md:py-16">
            <div className="flex flex-col items-center justify-center">
              <Loader2 className="h-10 w-10 md:h-12 md:w-12 text-primary animate-spin" />
              <p className="mt-4 text-base md:text-lg font-medium text-foreground">
                Generating your try-on image...
              </p>
              <p className="mt-2 text-sm text-muted-foreground text-center">
                This may take a minute. We're combining your profile picture with the clothing.
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Result Step */}
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
              <img
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
