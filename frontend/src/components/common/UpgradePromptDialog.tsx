/**
 * UpgradePromptDialog — single globally-mounted dialog driven by
 * upgradePromptStore. Renders one of two distinct messages and NEVER mixes them:
 *
 *  - rate_limit (the user's OWN plan limit): offers an "Upgrade to Pro" CTA via
 *    the existing Stripe checkout flow (subscriptionStore.startCheckout).
 *  - capacity (server's upstream AI provider exhausted/overloaded): a "try again
 *    shortly" message. This is "on us", so there is never an upgrade button.
 *
 * Mounted once next to <Toaster /> in main.tsx.
 */
import { useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { useUpgradePromptStore } from '@/stores/upgradePromptStore';
import { useSubscriptionStore, selectCanUpgrade } from '@/stores/subscriptionStore';

export function UpgradePromptDialog() {
  const { isOpen, reason, message, close } = useUpgradePromptStore();
  // Gate the upsell on "a higher tier exists", not "has paid features" - a
  // Plus user is entitled but can still move to Pro.
  const canUpgrade = useSubscriptionStore(selectCanUpgrade);
  const startCheckout = useSubscriptionStore((s) => s.startCheckout);
  const isCheckingOut = useSubscriptionStore((s) => s.isCheckingOut);
  const [checkoutError, setCheckoutError] = useState<string | null>(null);

  const isRateLimit = reason === 'rate_limit';

  async function handleUpgrade() {
    setCheckoutError(null);
    try {
      await startCheckout('pro_monthly');
    } catch {
      setCheckoutError('Could not start checkout. Please try again.');
    }
  }

  return (
    <Dialog
      open={isOpen}
      onOpenChange={(open) => {
        if (!open && !isCheckingOut) close();
      }}
    >
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>
            {isRateLimit ? "You've reached your daily limit" : 'AI service is busy'}
          </DialogTitle>
          <DialogDescription asChild>
            <div>
              {isRateLimit
                ? !canUpgrade
                  ? "You've used all your AI extractions for today. Your allowance resets tomorrow."
                  : (message ??
                    "You've used all the AI extractions on your plan for today. Upgrade for much higher daily limits, or wait for tomorrow's reset.")
                : message ??
                  "Our AI provider is experiencing heavy demand right now. Please try again in a few minutes. Your items aren't lost."}
            </div>
          </DialogDescription>
        </DialogHeader>

        {checkoutError && (
          <p className="text-sm text-destructive">{checkoutError}</p>
        )}

        <DialogFooter>
          {isRateLimit && canUpgrade ? (
            <>
              <Button variant="ghost" onClick={close} disabled={isCheckingOut}>
                Maybe later
              </Button>
              <Button onClick={handleUpgrade} disabled={isCheckingOut}>
                {isCheckingOut ? 'Redirecting…' : 'Upgrade to Pro'}
              </Button>
            </>
          ) : (
            <Button onClick={close}>Got it</Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
