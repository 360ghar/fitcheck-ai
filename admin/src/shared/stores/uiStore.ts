import { create } from 'zustand'
import { persist } from 'zustand/middleware'

import { STORAGE_KEYS } from '@/shared/lib/constants'

/**
 * UI preferences store — the only client-only persisted state in v1.
 * Theme itself is delegated to next-themes (its own storage key).
 */

export type Density = 'comfortable' | 'compact'

export interface UiState {
  /** Desktop sidebar collapsed (240px → 64px) */
  sidebarCollapsed: boolean
  /** Table row density, persisted */
  density: Density
  toggleSidebar: () => void
  setSidebarCollapsed: (collapsed: boolean) => void
  setDensity: (density: Density) => void
}

export const useUiStore = create<UiState>()(
  persist(
    (set) => ({
      sidebarCollapsed: false,
      density: 'comfortable',
      toggleSidebar: () => set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed })),
      setSidebarCollapsed: (collapsed) => set({ sidebarCollapsed: collapsed }),
      setDensity: (density) => set({ density }),
    }),
    {
      name: STORAGE_KEYS.ui,
      partialize: (state) => ({
        sidebarCollapsed: state.sidebarCollapsed,
        density: state.density,
      }),
    },
  ),
)
