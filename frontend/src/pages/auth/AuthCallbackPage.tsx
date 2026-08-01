/**
 * OAuth Callback Page
 * Handles the redirect after Google OAuth authentication
 */

import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';
import { PENDING_PROMO_KEY } from '@/lib/promo';
import { Loader2 } from 'lucide-react';
import { consumeAuthReturnTo, getPostAuthDestination, withAuthContext } from './authRedirect';

export default function AuthCallbackPage() {
  const navigate = useNavigate();
  const handleOAuthCallback = useAuthStore((state) => state.handleOAuthCallback);
  const [error, setError] = useState<string | null>(null);
  // StrictMode runs effects twice in dev; a second /auth/oauth/sync would run
  // after `pending_referral_code` has already been consumed, dropping the referral.
  const hasStartedRef = useRef(false);

  useEffect(() => {
    if (hasStartedRef.current) return;
    hasStartedRef.current = true;

    let redirectTimeout: ReturnType<typeof setTimeout> | undefined;

    const processCallback = async () => {
      const pendingPlan = localStorage.getItem('pending_plan_type')
      // A promo stashed before OAuth lands the user on the plan page, where
      // the code is pre-filled and ready to redeem (consumed by the panel).
      const pendingPromo = localStorage.getItem(PENDING_PROMO_KEY)
      const pendingReturnTo = consumeAuthReturnTo()

      try {
        await handleOAuthCallback();
        // Only consume the plan intent once the OAuth round-trip actually
        // succeeded, so a failed callback can still carry the plan into the
        // login redirect below instead of dropping it.
        if (pendingPlan) localStorage.removeItem('pending_plan_type')
        navigate(
          getPostAuthDestination(pendingReturnTo, pendingPlan, pendingPromo),
          { replace: true },
        );
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : 'Authentication failed';
        setError(message);
        // Redirect to login after showing error
        redirectTimeout = setTimeout(
          () => navigate(withAuthContext('/auth/login', pendingPlan, pendingReturnTo), { replace: true }),
          3000,
        );
      }
    };

    processCallback();

    return () => {
      if (redirectTimeout) clearTimeout(redirectTimeout);
    };
  }, [handleOAuthCallback, navigate]);

  if (error) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background" role="alert">
        <div className="text-center">
          <p className="text-red-500 mb-2">Authentication failed</p>
          <p className="text-sm text-muted-foreground">{error}</p>
          <p className="text-sm text-muted-foreground mt-2">Redirecting to login…</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background" role="status" aria-live="polite">
      <div className="text-center">
        <Loader2 className="h-8 w-8 animate-spin mx-auto mb-4 text-primary" />
        <p className="text-muted-foreground">Completing sign in…</p>
      </div>
    </div>
  );
}
