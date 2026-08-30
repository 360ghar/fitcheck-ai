/**
 * OAuth Bridge Page (MCP / ChatGPT connector flows)
 *
 * The backend's OAuth gateway (`/api/v1/oauth/authorize`) redirects the user
 * here with a `state` handle for the pending authorization. This page:
 *   1. reads the Supabase session (hosted login / existing session),
 *   2. POSTs its access token to `/oauth/authorize/complete`,
 *   3. follows the returned redirect (back to ChatGPT with the code).
 *
 * Signed-in users never see anything but the spinner. Signed-out users get a
 * sign-in prompt whose `returnTo` lands back on this exact URL with state.
 */

import { useEffect, useRef, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { getSupabase } from '@/lib/supabase';
import { API_BASE_URL } from '@/lib/apiBaseUrl';
import { trackEvent } from '@/lib/analytics';
import { useAuthStore } from '@/stores/authStore';

type Phase = 'connecting' | 'needs_login' | 'error';

function tokenExpiresSoon(token: string): boolean {
  try {
    const payload = token.split('.')[1];
    if (!payload) return false;
    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/');
    const decoded = JSON.parse(atob(normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')));
    return typeof decoded.exp === 'number' && decoded.exp <= Date.now() / 1000 + 30;
  } catch {
    return false;
  }
}

export default function OAuthBridgePage() {
  const [searchParams] = useSearchParams();
  const state = searchParams.get('state') ?? '';
  const [phase, setPhase] = useState<Phase>('connecting');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const hasStartedRef = useRef(false);
  const hasHydrated = useAuthStore((auth) => auth.hasHydrated);

  useEffect(() => {
    if (!hasHydrated) return;
    if (hasStartedRef.current) return;
    hasStartedRef.current = true;

    const run = async () => {
      if (!state) {
        setErrorMessage('Missing OAuth state. Restart the connection from your AI app.');
        setPhase('error');
        return;
      }
      try {
        let accessToken: string | undefined;
        try {
          const supabase = await getSupabase();
          // detectSessionInUrl has already consumed any hash tokens from the
          // hosted login redirect by effect time.
          const { data } = await supabase.auth.getSession();
          accessToken = data.session?.access_token;
        } catch {
          // Email/password sign-in stores the same Supabase tokens in the
          // app auth store even when the SDK has no persisted session.
        }
        if (!accessToken) {
          const auth = useAuthStore.getState();
          accessToken = auth.tokens?.access_token;
          if (accessToken && tokenExpiresSoon(accessToken) && auth.tokens?.refresh_token) {
            try {
              await auth.refreshToken();
              accessToken = useAuthStore.getState().tokens?.access_token;
            } catch {
              // refreshToken clears invalid credentials. Continue to the
              // sign-in prompt instead of showing an opaque bridge error.
              accessToken = undefined;
            }
          }
        }
        if (!accessToken) {
          setPhase('needs_login');
          return;
        }
        await complete(state, accessToken);
      } catch (err) {
        setErrorMessage(err instanceof Error ? err.message : 'Authorization failed');
        setPhase('error');
      }
    };

    run();
  }, [hasHydrated, state]);

  const complete = async (stateValue: string, accessToken: string) => {
    const response = await fetch(`${API_BASE_URL}/api/v1/oauth/authorize/complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ state: stateValue, access_token: accessToken }),
    });
    const body = await response.json().catch(() => null);
    const redirect = body?.redirect;
    if (!response.ok || !redirect) {
      const description =
        body?.error_description ||
        body?.error?.error_description ||
        body?.error ||
        'Authorization failed';
      throw new Error(String(description));
    }
    trackEvent('mcp_oauth_authorized');
    // Hand the code back to the connector (ChatGPT).
    window.location.href = redirect;
  };

  const resumeAfterLogin = () => {
    // LoginPage honors returnTo; keep the state in the URL.
    const target = `/oauth/bridge${state ? `?state=${encodeURIComponent(state)}` : ''}`;
    return `/auth/login?returnTo=${encodeURIComponent(target)}`;
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        {phase === 'connecting' && (
          <div role="status" aria-live="polite">
            <Loader2 className="mx-auto mb-4 h-8 w-8 animate-spin text-primary" />
            <p className="text-muted-foreground">Connecting FitCheck to your AI app…</p>
          </div>
        )}

        {phase === 'needs_login' && (
          <div>
            <h1 className="mb-2 text-xl font-semibold">Sign in to continue</h1>
            <p className="text-muted-foreground mb-6 text-sm">
              Your AI app wants to connect to FitCheck. Sign in to approve access to
              your wardrobe, outfits, and plans.
            </p>
            <Link
              to={resumeAfterLogin()}
              className="bg-primary text-primary-foreground hover:bg-primary/90 inline-flex items-center rounded-md px-6 py-2.5 text-sm font-medium"
            >
              Sign in to FitCheck
            </Link>
          </div>
        )}

        {phase === 'error' && (
          <div role="alert">
            <h1 className="mb-2 text-xl font-semibold text-red-500">Authorization failed</h1>
            <p className="text-muted-foreground mb-6 text-sm">{errorMessage}</p>
            <p className="text-muted-foreground text-xs">
              Go back to your AI app and try connecting again.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
