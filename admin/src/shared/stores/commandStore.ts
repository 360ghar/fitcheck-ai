import { create } from 'zustand'

/**
 * Command palette (⌘K) open state — lives here so both the topbar trigger
 * and the palette itself can read/write it without prop drilling.
 */
export interface CommandState {
  open: boolean
  setOpen: (open: boolean) => void
}

export const useCommandStore = create<CommandState>()((set) => ({
  open: false,
  setOpen: (open) => set({ open }),
}))
