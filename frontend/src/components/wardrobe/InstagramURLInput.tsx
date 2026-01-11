/**
 * InstagramURLInput Component
 *
 * URL input with validation and profile preview for Instagram imports.
 */

import { useState, useEffect } from 'react';
import { Instagram, AlertCircle, CheckCircle, Loader2, Users } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import type { InstagramProfileInfo } from '@/types';

interface InstagramURLInputProps {
  value: string;
  onChange: (value: string) => void;
  onValidated: (urlType: 'profile' | 'post' | 'reel', identifier: string) => void;
  onProfileChecked: (profile: InstagramProfileInfo) => void;
  error: string | null;
  setError: (error: string | null) => void;
  disabled?: boolean;
  onSubmit: () => void;
  profileInfo: InstagramProfileInfo | null;
  isLoading?: boolean;
}

export function InstagramURLInput({
  value,
  onChange,
  onValidated,
  onProfileChecked,
  error,
  setError,
  disabled,
  onSubmit,
  profileInfo,
  isLoading,
}: InstagramURLInputProps) {
  const [isValidating, setIsValidating] = useState(false);
  const [urlType, setUrlType] = useState<'profile' | 'post' | 'reel' | null>(null);

  // Debounced validation
  useEffect(() => {
    if (!value.includes('instagram.com')) {
      setError(null);
      setUrlType(null);
      return;
    }

    const timeoutId = setTimeout(async () => {
      setIsValidating(true);
      try {
        const { validateInstagramUrl, checkInstagramProfile } = await import('@/api/instagram');

        const validation = await validateInstagramUrl(value);

        if (!validation.valid) {
          setError(validation.error || 'Invalid Instagram URL');
          setUrlType(null);
          setIsValidating(false);
          return;
        }

        setError(null);
        setUrlType(validation.url_type || null);
        onValidated(validation.url_type!, validation.identifier!);

        // For profile URLs, check if public and get info
        if (validation.url_type === 'profile' && validation.identifier) {
          const profile = await checkInstagramProfile(validation.identifier);

          if (!profile.is_public && !profile.error) {
            setError('This profile is private. Only public profiles can be imported.');
          } else if (profile.error) {
            setError(profile.error);
          } else {
            onProfileChecked(profile);
          }
        }
      } catch (err) {
        setError('Failed to validate URL. Please try again.');
      } finally {
        setIsValidating(false);
      }
    }, 500);

    return () => clearTimeout(timeoutId);
  }, [value, setError, onValidated, onProfileChecked]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onChange(e.target.value);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!error && !isValidating && value) {
      onSubmit();
    }
  };

  const isValid = !error && !isValidating && urlType;

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmit} className="space-y-3">
        <div className="space-y-2">
          <label htmlFor="instagram-url" className="text-sm font-medium text-foreground">
            Instagram URL
          </label>
          <div className="flex gap-2">
            <div className="relative flex-1">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Instagram className="h-5 w-5 text-muted-foreground" />
              </div>
              <Input
                id="instagram-url"
                type="url"
                placeholder="https://instagram.com/username"
                value={value}
                onChange={handleChange}
                disabled={disabled || isLoading}
                className={cn(
                  'pl-10',
                  error && 'border-red-500 focus-visible:ring-red-500',
                  isValid && 'border-green-500 focus-visible:ring-green-500'
                )}
              />
              {isValidating && (
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                </div>
              )}
              {isValid && !isValidating && (
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <CheckCircle className="h-4 w-4 text-green-500" />
                </div>
              )}
            </div>
            <Button
              type="submit"
              disabled={disabled || isLoading || !!error || isValidating || !value}
              className="min-w-[100px]"
            >
              {isLoading ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Loading
                </>
              ) : (
                'Import'
              )}
            </Button>
          </div>
        </div>

        {error && (
          <div className="flex items-start gap-2 text-sm text-red-500">
            <AlertCircle className="h-4 w-4 mt-0.5 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <p className="text-xs text-muted-foreground">
          Paste an Instagram profile URL or a post URL. Only public accounts are supported.
        </p>
      </form>

      {/* Profile preview when validated */}
      {profileInfo && !error && (
        <div className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg border border-border">
          {profileInfo.profile_pic_url ? (
            <img
              src={profileInfo.profile_pic_url}
              alt={profileInfo.username}
              className="w-12 h-12 rounded-full object-cover"
            />
          ) : (
            <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center">
              <Instagram className="h-6 w-6 text-muted-foreground" />
            </div>
          )}
          <div className="flex-1 min-w-0">
            <p className="font-medium text-foreground truncate">
              @{profileInfo.username}
              {profileInfo.full_name && (
                <span className="text-muted-foreground font-normal ml-2">
                  {profileInfo.full_name}
                </span>
              )}
            </p>
            <div className="flex items-center gap-1 text-sm text-muted-foreground">
              <Users className="h-3.5 w-3.5" />
              <span>{profileInfo.post_count.toLocaleString()} posts</span>
            </div>
          </div>
          <CheckCircle className="h-5 w-5 text-green-500 flex-shrink-0" />
        </div>
      )}

      {/* URL type indicator */}
      {urlType && !error && !profileInfo && (
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <CheckCircle className="h-4 w-4 text-green-500" />
          <span>
            Valid {urlType === 'profile' ? 'profile' : urlType === 'post' ? 'post' : 'reel'} URL detected
          </span>
        </div>
      )}
    </div>
  );
}

export default InstagramURLInput;
