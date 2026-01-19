/**
 * Authentication store using Zustand
 * Manages user authentication state, tokens, and auth actions
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { toast } from '../components/ui/use-toast';
import type { User, AuthTokens, AuthResponse } from '../types';
import * as authApi from '../api/auth';
import { getCurrentUser } from '../api/users';
import { getApiError, resetForcedLogoutFlag, setTokens } from '../api/client';
import { supabase } from '../lib/supabase';

// ============================================================================
// AUTH STATE INTERFACE
// ============================================================================

interface AuthState {
  // State
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  hasHydrated: boolean;

  // Actions
  login: (email: string, password: string) => Promise<AuthResponse>;
  register: (email: string, password: string, fullName?: string, referralCode?: string) => Promise<AuthResponse>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  clearError: () => void;
  setUser: (user: User | null) => void;
  setHasHydrated: (hydrated: boolean) => void;
  signInWithGoogle: () => Promise<void>;
  handleOAuthCallback: () => Promise<AuthResponse & { is_new_user: boolean }>;
}

// ============================================================================
// AUTH STORE
// ============================================================================

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      tokens: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
      hasHydrated: false,

      // Login action
      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.login({ email, password });
          const hasTokens = Boolean(response.access_token && response.refresh_token);
          set({
            user: response.user,
            tokens: hasTokens
              ? {
                  access_token: response.access_token,
                  refresh_token: response.refresh_token,
                }
              : null,
            isAuthenticated: hasTokens,
            isLoading: false,
            error: null,
          });
          if (hasTokens) {
            authApi.storeUser(response.user);
            resetForcedLogoutFlag();
          }
          return response;
        } catch (error) {
          const message = getApiError(error).message || 'Login failed';
          set({
            isLoading: false,
            error: message,
            isAuthenticated: false,
            user: null,
            tokens: null,
          });
          throw error;
        }
      },

      // Register action
      register: async (email: string, password: string, fullName?: string, referralCode?: string) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.register({
            email,
            password,
            full_name: fullName,
            referral_code: referralCode,
          });
          const hasTokens = Boolean(response.access_token && response.refresh_token);
          set({
            user: response.user,
            tokens: hasTokens
              ? {
                  access_token: response.access_token,
                  refresh_token: response.refresh_token,
                }
              : null,
            isAuthenticated: hasTokens,
            isLoading: false,
            error: null,
          });
          if (hasTokens) {
            authApi.storeUser(response.user);
            resetForcedLogoutFlag();
          }
          return response;
        } catch (error) {
          const message = getApiError(error).message || 'Registration failed';
          set({
            isLoading: false,
            error: message,
            isAuthenticated: false,
            user: null,
            tokens: null,
          });
          throw error;
        }
      },

      // Logout action
      logout: async () => {
        set({ isLoading: true });
        try {
          await authApi.logout();
        } catch (error) {
          console.warn('Logout API call failed:', error);
        } finally {
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
          authApi.clearUser();
        }
      },

      // Refresh token action
      refreshToken: async () => {
        const { tokens } = get();
        if (!tokens?.refresh_token) {
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            error: 'No refresh token available',
          });
          authApi.clearUser();
          return;
        }

        try {
          const newTokens = await authApi.refreshAccessToken(tokens.refresh_token);
          set({
            tokens: newTokens,
            isAuthenticated: true,
            error: null,
          });
        } catch (error) {
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            error: 'Token refresh failed',
          });
          authApi.clearUser();
          throw error;
        }
      },

      // Clear error action
      clearError: () => {
        set({ error: null });
      },

      // Set user action (for manual updates)
      setUser: (user: User | null) => {
        set({ user });
        if (user) {
          authApi.storeUser(user);
        } else {
          authApi.clearUser();
        }
      },

      // Set hydration status (called by persist middleware)
      setHasHydrated: (hydrated: boolean) => {
        set({ hasHydrated: hydrated });
      },

      // Sign in with Google OAuth
      signInWithGoogle: async () => {
        set({ isLoading: true, error: null });
        try {
          const { error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: {
              redirectTo: `${window.location.origin}/auth/callback`,
            },
          });
          if (error) throw error;
          // User will be redirected to Google
        } catch (error: unknown) {
          const message = error instanceof Error ? error.message : 'Failed to sign in with Google';
          set({ error: message, isLoading: false });
          throw error;
        }
      },

      // Handle OAuth callback after redirect
      handleOAuthCallback: async () => {
        set({ isLoading: true, error: null });
        try {
          // Get session from Supabase (populated from URL hash after redirect)
          const { data: { session }, error } = await supabase.auth.getSession();

          if (error) throw error;
          if (!session) throw new Error('No session found');

          // Get pending referral code from localStorage (saved before OAuth redirect)
          const pendingReferralCode = localStorage.getItem('pending_referral_code');
          if (pendingReferralCode) {
            localStorage.removeItem('pending_referral_code');
          }

          // Sync profile with backend
          const { user, is_new_user, referral } = await authApi.syncOAuthProfile(
            session.access_token,
            pendingReferralCode || undefined
          );

          const tokens = {
            access_token: session.access_token,
            refresh_token: session.refresh_token,
          };

          // Store tokens in localStorage for API client
          setTokens(tokens);

          set({
            user,
            tokens,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });

          authApi.storeUser(user);
          resetForcedLogoutFlag();

          // Show toast for successful referral redemption
          if (referral?.success) {
            toast({
              title: 'Referral bonus applied!',
              description: referral.message || 'You both get 1 month of Pro free.',
            });
          }

          return { ...tokens, user, is_new_user };
        } catch (error: unknown) {
          const message = error instanceof Error ? error.message : 'OAuth callback failed';
          set({ error: message, isLoading: false });
          throw error;
        }
      },
    }),
    {
      name: 'fitcheck-auth-storage',
      partialize: (state) => ({
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
        // Note: hasHydrated is NOT persisted - it's runtime state
      }),
      onRehydrateStorage: () => (state) => {
        state?.setHasHydrated(true);

        // Sync tokens to client.ts storage on rehydration to keep both storages in sync
        if (state?.tokens?.access_token && state?.tokens?.refresh_token) {
          setTokens(state.tokens);
        }

        // Sync user data with server to ensure avatar_url and other fields are fresh
        if (state?.isAuthenticated && state?.tokens?.access_token) {
          getCurrentUser()
            .then((freshUser) => {
              useAuthStore.setState({ user: freshUser });
              authApi.storeUser(freshUser);
            })
            .catch(() => {
              // Silently fail - user data from localStorage will be used
            });
        }
      },
    }
  )
);

// ============================================================================
// SELECTORS
// ============================================================================

export const selectUser = (state: AuthState) => state.user;
export const selectIsAuthenticated = (state: AuthState) => state.isAuthenticated;
export const selectIsLoading = (state: AuthState) => state.isLoading;
export const selectAuthError = (state: AuthState) => state.error;
export const selectHasHydrated = (state: AuthState) => state.hasHydrated;

// ============================================================================
// HOOKS
// ============================================================================

/**
 * Hook to get current user
 */
export function useCurrentUser(): User | null {
  return useAuthStore(selectUser);
}

/**
 * Hook to check if user is authenticated
 */
export function useIsAuthenticated(): boolean {
  return useAuthStore(selectIsAuthenticated);
}

/**
 * Hook to check if auth store has hydrated from storage
 */
export function useHasHydrated(): boolean {
  return useAuthStore(selectHasHydrated);
}

/**
 * Hook to get auth loading state
 */
export function useAuthLoading(): boolean {
  return useAuthStore(selectIsLoading);
}

/**
 * Hook to get auth error
 */
export function useAuthError(): string | null {
  return useAuthStore(selectAuthError);
}

/**
 * Hook to get user display name
 */
export function useUserDisplayName(): string {
  const user = useCurrentUser();
  return user?.full_name || user?.email || 'User';
}

/**
 * Hook to get user initials
 */
export function useUserInitials(): string {
  const user = useCurrentUser();
  if (!user?.full_name) return '?';
  const parts = user.full_name.trim().split(' ');
  if (parts.length === 1) {
    return parts[0].charAt(0).toUpperCase();
  }
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}

/**
 * Hook to get user avatar URL
 */
export function useUserAvatar(): string | undefined {
  const user = useCurrentUser();
  return user?.avatar_url;
}
