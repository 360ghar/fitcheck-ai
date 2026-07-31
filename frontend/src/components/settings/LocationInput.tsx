import { useId } from 'react';
import { MapPin, Loader2 } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';

interface LocationInputProps {
  value: string;
  onChange: (value: string) => void;
  onAutoDetect?: () => Promise<void>;
  isAutoDetecting?: boolean;
  error?: string | null;
  placeholder?: string;
  showAutoDetectButton?: boolean;
  className?: string;
  id?: string;
  name?: string;
  label?: string;
}

export function LocationInput({
  value,
  onChange,
  onAutoDetect,
  isAutoDetecting = false,
  error,
  placeholder = 'City name or coordinates (e.g., 37.7749,-122.4194)',
  showAutoDetectButton = true,
  className = '',
  id,
  name = 'location',
  label = 'Location',
}: LocationInputProps) {
  const generatedId = useId();
  const inputId = id ?? `location-input-${generatedId.replace(/:/g, '')}`;
  const errorId = `${inputId}-error`;

  return (
    <div className={className}>
      <div className="flex flex-col gap-2 sm:flex-row">
        <Label htmlFor={inputId} className="sr-only">
          {label}
        </Label>
        <Input
          id={inputId}
          name={name}
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          autoComplete="address-level2"
          aria-invalid={Boolean(error)}
          aria-describedby={error ? errorId : undefined}
          className="flex-1"
        />
        {showAutoDetectButton && onAutoDetect && (
          <Button
            type="button"
            variant="outline"
            onClick={onAutoDetect}
            disabled={isAutoDetecting}
            className="min-h-11 w-full shrink-0 sm:w-auto"
          >
            {isAutoDetecting ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <MapPin className="h-4 w-4" />
            )}
            <span className="ml-2 sm:hidden">
              {isAutoDetecting ? 'Detecting…' : 'Detect'}
            </span>
            <span className="ml-2 hidden sm:inline">
              {isAutoDetecting ? 'Detecting…' : 'Use my location'}
            </span>
          </Button>
        )}
      </div>
      {error && (
        <p id={errorId} role="alert" className="mt-1 text-sm text-error">
          {error}
        </p>
      )}
    </div>
  );
}
