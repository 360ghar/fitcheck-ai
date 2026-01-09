/**
 * OAuth Callback Page
 * Handles the redirect after Google OAuth authentication
 */

import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';
import { Loader2 } from 'lucide-react';

export default function AuthCallbackPage() {
  const navigate = useNavigate();
  const handleOAuthCallback = useAuthStore((state) => state.handleOAuthCallback);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const processCallback = async () => {
      try {
        await handleOAuthCallback();
        navigate('/dashboard', { replace: true });
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : 'Authentication failed';
        setError(message);
        // Redirect to login after showing error
        setTimeout(() => navigate('/auth/login', { replace: true }), 3000);
      }
    };

    processCallback();
  }, [handleOAuthCallback, navigate]);

  if (error) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="text-center">
          <p className="text-red-500 mb-2">Authentication failed</p>
          <p className="text-sm text-muted-foreground">{error}</p>
          <p className="text-sm text-muted-foreground mt-2">Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="text-center">
        <Loader2 className="h-8 w-8 animate-spin mx-auto mb-4 text-primary" />
        <p className="text-muted-foreground">Completing sign in...</p>
      </div>
    </div>
  );
}
