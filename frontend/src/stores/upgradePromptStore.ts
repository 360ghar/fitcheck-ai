/**
 * Global upgrade / capacity prompt.
 *
 * Two distinct user-facing conditions funnel through here, and they must NOT be
 * conflated (the user was explicit about this):
 *
 *  - "rate_limit": the user hit THEIR OWN plan limit (backend
 *    `RATE_LIMIT_EXCEEDED`). This is where we show an "Upgrade to Pro" CTA.
 *
 *  - "capacity": the server's upstream AI provider is exhausted/overloaded
 *    (backend `error_kind: upstream_quota | transient`). This is "on us" — the
 *    UI says "try again shortly", NEVER an upgrade prompt.
 *
 * The Axios interceptor and the batch/social SSE hooks both call `open()`; a
 * single mounted <UpgradePromptDialog /> consumes the state.
 */
import { create } from 'zustand';

export type UpgradePromptReason = 'rate_limit' | 'capacity';

interface UpgradePromptState {
  isOpen: boolean;
  reason: UpgradePromptReason | null;
  message: string | null;
  open: (reason: UpgradePromptReason, message?: string | null) => void;
  close: () => void;
}

export const useUpgradePromptStore = create<UpgradePromptState>((set) => ({
  isOpen: false,
  reason: null,
  message: null,
  open: (reason, message = null) => set({ isOpen: true, reason, message }),
  close: () => set({ isOpen: false, reason: null, message: null }),
}));
