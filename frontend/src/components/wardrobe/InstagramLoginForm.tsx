/**
 * InstagramLoginForm Component
 *
 * Form for logging into Instagram with username and password.
 */

import { useState } from 'react';
import { Instagram, Loader2, LogOut, Eye, EyeOff, AlertCircle, CheckCircle2 } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import type { InstagramCredentialsStatus } from '@/api/instagram';

interface InstagramLoginFormProps {
  onLogin: (username: string, password: string) => Promise<{ success: boolean; error?: string }>;
  onLogout: () => Promise<void>;
  credentialsStatus: InstagramCredentialsStatus | null;
  isLoading?: boolean;
}

export function InstagramLoginForm({
  onLogin,
  onLogout,
  credentialsStatus,
  isLoading = false,
}: InstagramLoginFormProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const isLoggedIn = credentialsStatus?.has_credentials && credentialsStatus?.is_valid;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username || !password) {
      setError('Please enter both username and password');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      const result = await onLogin(username, password);
      if (!result.success) {
        setError(result.error || 'Login failed');
      } else {
        // Clear form on success
        setUsername('');
        setPassword('');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleLogout = async () => {
    setIsSubmitting(true);
    try {
      await onLogout();
    } finally {
      setIsSubmitting(false);
    }
  };

  // Show connected state
  if (isLoggedIn) {
    return (
      <div className="space-y-4">
        <div className="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
          <div className="flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 via-pink-500 to-orange-500">
            <Instagram className="h-5 w-5 text-white" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="font-medium text-foreground">Connected</span>
              <CheckCircle2 className="h-4 w-4 text-green-500" />
            </div>
            <p className="text-sm text-muted-foreground truncate">
              @{credentialsStatus.username}
            </p>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={handleLogout}
            disabled={isSubmitting}
            className="flex-shrink-0"
          >
            {isSubmitting ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <>
                <LogOut className="h-4 w-4 mr-1" />
                Disconnect
              </>
            )}
          </Button>
        </div>
        <p className="text-xs text-muted-foreground">
          Your Instagram session is active. You can now import images from any public profile.
        </p>
      </div>
    );
  }

  // Show login form
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3 p-4 bg-muted/50 rounded-lg border border-border">
        <div className="flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 via-pink-500 to-orange-500">
          <Instagram className="h-5 w-5 text-white" />
        </div>
        <div className="flex-1">
          <p className="font-medium text-foreground">Connect Instagram</p>
          <p className="text-sm text-muted-foreground">
            Login to access public profiles
          </p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-3">
        <div className="space-y-2">
          <label htmlFor="ig-username" className="text-sm font-medium text-foreground">
            Username
          </label>
          <Input
            id="ig-username"
            type="text"
            placeholder="your_username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            disabled={isSubmitting || isLoading}
            autoComplete="username"
          />
        </div>

        <div className="space-y-2">
          <label htmlFor="ig-password" className="text-sm font-medium text-foreground">
            Password
          </label>
          <div className="relative">
            <Input
              id="ig-password"
              type={showPassword ? 'text' : 'password'}
              placeholder="********"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isSubmitting || isLoading}
              autoComplete="current-password"
              className="pr-10"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 pr-3 flex items-center text-muted-foreground hover:text-foreground transition-colors"
            >
              {showPassword ? (
                <EyeOff className="h-4 w-4" />
              ) : (
                <Eye className="h-4 w-4" />
              )}
            </button>
          </div>
        </div>

        {error && (
          <div className="flex items-start gap-2 text-sm text-red-500">
            <AlertCircle className="h-4 w-4 mt-0.5 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <Button
          type="submit"
          disabled={isSubmitting || isLoading || !username || !password}
          className="w-full"
        >
          {isSubmitting ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Connecting...
            </>
          ) : (
            <>
              <Instagram className="h-4 w-4 mr-2" />
              Connect to Instagram
            </>
          )}
        </Button>
      </form>

      <div className="space-y-2">
        <p className="text-xs text-muted-foreground">
          Your credentials are encrypted and stored securely. We only use them to access public content on Instagram.
        </p>
        <p className="text-xs text-amber-600 dark:text-amber-500">
          Note: If you have 2FA enabled, you may need to use an app password or temporarily disable 2FA.
        </p>
      </div>
    </div>
  );
}

export default InstagramLoginForm;
