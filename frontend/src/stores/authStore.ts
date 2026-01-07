/**
 * Authentication store using Zustand
 * Manages user authentication state, tokens, and auth actions
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { User, AuthTokens } from '../types';
import * as authApi from '../api/auth';

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

  // Actions
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, fullName?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  clearError: () => void;
  setUser: (user: User | null) => void;
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

      // Login action
      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.login({ email, password });
          set({
            user: response.user,
            tokens: {
              access_token: response.access_token,
              refresh_token: response.refresh_token,
            },
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
          authApi.storeUser(response.user);
        } catch (error) {
          const message = error instanceof Error ? error.message : 'Login failed';
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
      register: async (email: string, password: string, fullName?: string) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.register({
            email,
            password,
            full_name: fullName,
          });
          set({
            user: response.user,
            tokens: {
              access_token: response.access_token,
              refresh_token: response.refresh_token,
            },
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
          authApi.storeUser(response.user);
        } catch (error) {
          const message = error instanceof Error ? error.message : 'Registration failed';
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
    }),
    {
      name: 'fitcheck-auth-storage',
      partialize: (state) => ({
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
      }),
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
