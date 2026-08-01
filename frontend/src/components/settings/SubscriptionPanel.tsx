/**
 * SubscriptionPanel Component
 *
 * Settings panel for managing subscription, viewing usage, and sharing referral code.
 */

import { useState, useEffect } from "react";
import { useSearchParams } from "react-router-dom";
import {
  CreditCard,
  Crown,
  BarChart3,
  Gift,
  Copy,
  Check,
  ExternalLink,
  Loader2,
  AlertCircle,
  Share2,
  Users,
  Ticket,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/components/ui/use-toast";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import {
  useSubscriptionStore,
  usePlanName,
  useIsPro,
  useIsProTier,
  useCanUpgrade,
  useIsNearLimit,
} from "@/stores/subscriptionStore";
import { PLAN_LIMITS, PLAN_PRICES } from "@/lib/plan-limits";
import { PENDING_PROMO_KEY, planDisplayName } from "@/lib/promo";
import type { PlanType, PlansResponse } from "@/types";

// Upgrade options offered to users without a paid plan. Plus and Pro unlock
// the same features - only the limits differ - so both tiers are rendered
// from one shared shape instead of hand-copied blocks. Prices come from the
// live /plans response (env-overridable on the backend) so the panel never
// shows stale compiled prices; PLAN_PRICES is only a loading fallback.
const offeredTiersFor = (
  plans: PlansResponse | null | undefined,
  currentPlan: string
) =>
  (["plus", "pro"] as const)
    .filter((tier) => !currentPlan.startsWith(tier))
    .map((tier) => {
      const fromApi = plans?.plans?.find((p) => p.id === tier);
      const prices = fromApi
        ? { monthly: fromApi.price_monthly, yearly: fromApi.price_yearly }
        : PLAN_PRICES[tier];
      return {
        tier,
        name: tier === "plus" ? "Plus" : "Pro",
        recommended: tier === "plus",
        limits: PLAN_LIMITS[tier],
        prices,
        savings: prices.monthly * 12 - prices.yearly,
        monthlyPlanType: `${tier}_monthly` as PlanType,
        yearlyPlanType: `${tier}_yearly` as PlanType,
      };
    });

// ============================================================================
// COMPONENT
// ============================================================================

export function SubscriptionPanel() {
  const [searchParams] = useSearchParams();
  const requestedPlan = searchParams.get("plan_type");
  const [copied, setCopied] = useState(false);
  const [isLoadingReferral, setIsLoadingReferral] = useState(false);
  const [promoInput, setPromoInput] = useState("");
  const { toast } = useToast();

  const {
    subscription,
    usage,
    referralCode,
    referralStats,
    plans,
    isLoading,
    isCheckingOut,
    error,
    promoValidation,
    isPromoValidating,
    isRedeemingPromo,
    promoError,
    fetchSubscription,
    fetchReferralCode,
    fetchReferralStats,
    fetchPlans,
    startCheckout,
    openBillingPortal,
    cancelSubscription,
    copyReferralLink,
    validatePromo,
    redeemPromo,
    clearPromo,
  } = useSubscriptionStore();

  const planName = usePlanName();
  const isPro = useIsPro();
  // The PRO badge is a top-tier claim: a Plus user is paid but not Pro-tier.
  const isProTier = useIsProTier();
  const canUpgrade = useCanUpgrade();
  // Never offer the tier the user is already on: a Plus subscriber sees Pro
  // only, a free user sees both.
  const currentPlan = subscription?.plan_type ?? "free";
  const offeredTiers = offeredTiersFor(plans, currentPlan);
  const nearLimit = useIsNearLimit();

  // Load data on mount
  useEffect(() => {
    fetchSubscription();
    fetchReferralCode();
    fetchReferralStats();
    fetchPlans();
  }, [fetchSubscription, fetchReferralCode, fetchReferralStats, fetchPlans]);

  useEffect(() => {
    if (!requestedPlan) return;
    const target = document.getElementById(`plan-${requestedPlan.split("_")[0]}`);
    target?.scrollIntoView({ behavior: "smooth", block: "center" });
    // plans?.plans gates the upgrade cards' render: for a free user the tier
    // list is empty until /plans resolves, so the scroll must re-fire then.
  }, [requestedPlan, offeredTiers.length, plans?.plans]);

  // Consume a shared promo link: `?promo=CODE` in the URL or a code stashed
  // by the register/login page (survives the Google OAuth round-trip via
  // localStorage). Only free users can redeem, so a paid user never sees it.
  const isFreePlan = currentPlan === "free";
  useEffect(() => {
    if (!isFreePlan || promoValidation) return;
    const urlCode = searchParams.get("promo");
    const storedCode = localStorage.getItem(PENDING_PROMO_KEY);
    const code = (urlCode || storedCode || "").trim();
    if (code.length < 3) return;
    // Consumed once: the URL/param stays in the address bar (harmless), but a
    // stale localStorage key must not re-validate on every page visit.
    if (storedCode) localStorage.removeItem(PENDING_PROMO_KEY);
    setPromoInput(code);
    void validatePromo(code);
    // Run once on mount per plan state; `promoValidation` gates re-entry.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isFreePlan]);

  // Handle promo code validation (manual entry)
  const handleValidatePromo = async () => {
    const code = promoInput.trim();
    if (code.length < 3) {
      toast({
        title: "Enter a promo code",
        description: "Promo codes are at least 3 characters long.",
        variant: "destructive",
      });
      return;
    }
    await validatePromo(code);
  };

  // Handle promo code redemption
  const handleRedeemPromo = async () => {
    const code = promoInput.trim();
    if (!code) return;
    const result = await redeemPromo(code);
    if (result?.success) {
      localStorage.removeItem(PENDING_PROMO_KEY);
      toast({
        title: `You're on ${planDisplayName(result.plan_type)}! 🎉`,
        description: result.message,
      });
    }
  };

  // Handle copy referral link
  const handleCopyLink = async () => {
    const success = await copyReferralLink();
    if (success) {
      setCopied(true);
      toast({
        title: "Link copied!",
        description: "Share this link with friends to earn free Pro months.",
      });
      setTimeout(() => setCopied(false), 2000);
    } else {
      toast({
        title: "Failed to copy",
        description: "Please try again.",
        variant: "destructive",
      });
    }
  };

  // Handle upgrade
  const handleUpgrade = async (planType: PlanType) => {
    try {
      await startCheckout(planType);
    } catch {
      toast({
        title: "Checkout failed",
        description: "Please try again or contact support.",
        variant: "destructive",
      });
    }
  };

  // Handle cancel
  const handleCancel = async () => {
    try {
      await cancelSubscription();
      toast({
        title: "Subscription cancelled",
        description: "You'll retain access until the end of your billing period.",
      });
    } catch {
      toast({
        title: "Failed to cancel",
        description: "Please try again or contact support.",
        variant: "destructive",
      });
    }
  };

  // Handle manage billing
  const handleManageBilling = async () => {
    try {
      await openBillingPortal();
    } catch {
      toast({
        title: "Failed to open billing portal",
        description: "Please try again or contact support.",
        variant: "destructive",
      });
    }
  };

  // ============================================================================
  // RENDER
  // ============================================================================

  if (isLoading && !subscription) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Error Display */}
      {error && (
        <div className="p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400 shrink-0 mt-0.5" />
          <div>
            <p className="text-red-800 dark:text-red-200 font-medium">Error</p>
            <p className="text-red-600 dark:text-red-300 text-sm">{error}</p>
          </div>
        </div>
      )}

      {/* Current Plan */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <Crown className={`h-5 w-5 ${isPro ? "text-amber-500" : "text-gray-400"}`} />
            Current Plan
          </CardTitle>
          <CardDescription>
            Manage your subscription and billing
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-2xl font-bold text-gray-900 dark:text-white">
                  {planName}
                </span>
                {isProTier && (
                  <Badge className="bg-amber-500 text-white">PRO</Badge>
                )}
              </div>
              {subscription?.cancel_at_period_end && (
                <p className="text-sm text-amber-600 dark:text-amber-400 mt-1">
                  Cancels at end of period ({new Date(subscription.current_period_end!).toLocaleDateString()})
                </p>
              )}
              {subscription?.referral_credit_months && subscription.referral_credit_months > 0 && (
                <p className="text-sm text-green-600 dark:text-green-400 mt-1">
                  {subscription.referral_credit_months} referral credit month{subscription.referral_credit_months > 1 ? 's' : ''} active
                </p>
              )}
            </div>

            <div className="flex flex-col gap-2 sm:flex-row">
              {isPro ? (
                <>
                  <Button
                    variant="outline"
                    onClick={handleManageBilling}
                    disabled={isLoading}
                  >
                    <CreditCard className="h-4 w-4 mr-2" />
                    Manage Billing
                  </Button>
                  {!subscription?.cancel_at_period_end && (
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button variant="ghost" className="text-red-600 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-900/30">
                          Cancel Subscription
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>Cancel subscription?</AlertDialogTitle>
                          <AlertDialogDescription>
                            You'll retain access to Pro features until the end of your current billing period.
                            After that, you'll be downgraded to the Free plan.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Keep Subscription</AlertDialogCancel>
                          <AlertDialogAction
                            onClick={handleCancel}
                            className="bg-red-600 hover:bg-red-700"
                          >
                            Cancel Subscription
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  )}
                </>
              ) : (
                <Button
                  onClick={() => handleUpgrade("pro_monthly")}
                  disabled={isCheckingOut}
                  className="bg-indigo-600 hover:bg-indigo-700"
                >
                  {isCheckingOut ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Loading...
                    </>
                  ) : (
                    <>
                      <Crown className="h-4 w-4 mr-2" />
                      Upgrade to Pro
                    </>
                  )}
                </Button>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Promo Code - free users only: a promo grant replaces a paid checkout
          (paid subscribers are never overwritten, so Plus/Pro users don't see
          the input at all). */}
      {isFreePlan && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <Ticket className="h-5 w-5 text-indigo-500" />
              Have a promo code?
            </CardTitle>
            <CardDescription>
              Redeem a code to get Plus or Pro free for a limited time.
            </CardDescription>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
            {/* The banner requires a non-empty input: a stale validation result
                from a previous session must not render a redeem button that
                has no code to redeem. */}
            {promoValidation?.valid && promoInput.trim() ? (
              <div className="rounded-lg border border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20 p-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex items-start gap-3">
                  <Gift className="h-5 w-5 text-green-600 dark:text-green-400 shrink-0 mt-0.5" />
                  <div>
                    <p className="font-medium text-green-800 dark:text-green-200">
                      {promoValidation.message}
                    </p>
                    <p className="text-sm text-green-700 dark:text-green-300">
                      Code{" "}
                      <code className="font-mono">{promoInput.trim()}</code> — apply it
                      and skip the checkout.
                    </p>
                  </div>
                </div>
                <Button
                  onClick={handleRedeemPromo}
                  disabled={isRedeemingPromo}
                  className="bg-green-600 hover:bg-green-700 shrink-0"
                >
                  {isRedeemingPromo ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Applying...
                    </>
                  ) : (
                    <>
                      <Gift className="h-4 w-4 mr-2" />
                      Get {promoValidation.plan_name} free
                    </>
                  )}
                </Button>
              </div>
            ) : (
              <>
                <div className="flex flex-col gap-2 sm:flex-row">
                  <input
                    type="text"
                    value={promoInput}
                    onChange={(e) => {
                      setPromoInput(e.target.value);
                      // New input invalidates the previous validation result.
                      if (promoValidation || promoError) clearPromo();
                    }}
                    placeholder="Enter promo code"
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault();
                        void handleValidatePromo();
                      }
                    }}
                    className="flex-1 h-11 px-3 border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                    aria-label="Promo code"
                  />
                  <Button
                    onClick={handleValidatePromo}
                    disabled={isPromoValidating}
                    className="h-11"
                  >
                    {isPromoValidating ? (
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    ) : (
                      <Ticket className="h-4 w-4 mr-2" />
                    )}
                    {isPromoValidating ? "Checking..." : "Apply"}
                  </Button>
                </div>
                {promoError && (
                  <p className="mt-2 text-sm text-destructive">{promoError}</p>
                )}
                {promoValidation && !promoValidation.valid && (
                  <p className="mt-2 text-sm text-destructive">
                    {promoValidation.message}
                  </p>
                )}
              </>
            )}
          </CardContent>
        </Card>
      )}

      {/* Upgrade options - shown whenever a higher tier exists, so a Plus
          subscriber still has a path to Pro (gating this on !isPro stranded
          them, since Plus counts as paid). */}
      {canUpgrade && plans?.plans && offeredTiers.length > 0 && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5 text-indigo-500" />
              {isPro ? "Upgrade your plan" : "Choose a plan"}
            </CardTitle>
            <CardDescription>
              {offeredTiers.length > 1
                ? "Plus and Pro unlock the same features — pick the limits you need"
                : "Same features, higher limits"}
            </CardDescription>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
            <div
              className={
                offeredTiers.length > 1
                  ? "grid items-stretch gap-4 md:grid-cols-2"
                  : "grid items-stretch gap-4"
              }
            >
              {offeredTiers.map(
                ({
                  tier,
                  name,
                  recommended,
                  limits,
                  prices,
                  savings,
                  monthlyPlanType,
                  yearlyPlanType,
                }) => (
                  <div
                    key={tier}
                    id={`plan-${tier}`}
                    className={
                      recommended
                        ? "relative flex h-full flex-col rounded-lg border-2 border-indigo-500 p-4"
                        : "relative flex h-full flex-col rounded-lg border p-4 transition-colors hover:border-indigo-300 dark:hover:border-indigo-700"
                    }
                  >
                    {recommended && (
                      <Badge className="absolute -top-2.5 left-4 bg-indigo-500">
                        Most popular
                      </Badge>
                    )}
                    <div className="mb-4">
                      <h3 className="font-semibold text-lg">{name}</h3>
                      <p className="text-3xl font-bold mt-1">
                        ${prices.monthly}
                        <span className="text-base font-normal text-muted-foreground">/mo</span>
                      </p>
                      <p className="text-sm text-muted-foreground">
                        or ${prices.yearly}/yr — saves ${savings}
                      </p>
                    </div>
                    <ul className="space-y-2 text-sm text-gray-600 dark:text-gray-400 mb-4 flex-1">
                      <li className="flex items-center gap-2">
                        <Check className="h-4 w-4 text-green-500 shrink-0" />
                        {limits.monthlyExtractions} item extractions/month
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-4 w-4 text-green-500 shrink-0" />
                        {limits.monthlyGenerations.toLocaleString()} outfit
                        visualizations/month
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-4 w-4 text-green-500 shrink-0" />
                        {limits.dailyPhotoshootImages} AI photoshoot images/day
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-4 w-4 text-green-500 shrink-0" />
                        Virtual try-on, analytics &amp; priority support
                      </li>
                    </ul>
                    <div className="mt-auto grid grid-cols-2 gap-2">
                      <Button
                        onClick={() => handleUpgrade(monthlyPlanType)}
                        disabled={isCheckingOut}
                        variant="outline"
                        className="w-full"
                      >
                        {isCheckingOut ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          "Monthly"
                        )}
                      </Button>
                      <Button
                        onClick={() => handleUpgrade(yearlyPlanType)}
                        disabled={isCheckingOut}
                        className="w-full bg-indigo-600 hover:bg-indigo-700"
                      >
                        {isCheckingOut ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          "Yearly"
                        )}
                      </Button>
                    </div>
                  </div>
                )
              )}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Usage Statistics */}
      {usage && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5 text-indigo-500" />
              Monthly Usage
            </CardTitle>
            <CardDescription>
              {new Date(usage.period_start).toLocaleDateString()} - {new Date(usage.period_end).toLocaleDateString()}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6 px-4 pb-4 md:px-6 md:pb-6">
            {/* Extractions */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-medium">Item Extractions</span>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {usage.monthly_extractions} / {usage.monthly_extractions_limit}
                </span>
              </div>
              <Progress
                value={(usage.monthly_extractions / usage.monthly_extractions_limit) * 100}
                className={`h-2 ${nearLimit.extractions ? "[&>div]:bg-amber-500" : ""}`}
              />
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {usage.monthly_extractions_remaining} remaining this month
                {nearLimit.extractions && canUpgrade && (
                  <span className="text-amber-600 dark:text-amber-400 ml-2">
                    - Consider upgrading!
                  </span>
                )}
              </p>
            </div>

            {/* Generations */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-medium">Outfit Visualizations</span>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {usage.monthly_generations} / {usage.monthly_generations_limit}
                </span>
              </div>
              <Progress
                value={(usage.monthly_generations / usage.monthly_generations_limit) * 100}
                className={`h-2 ${nearLimit.generations ? "[&>div]:bg-amber-500" : ""}`}
              />
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {usage.monthly_generations_remaining} remaining this month
                {nearLimit.generations && canUpgrade && (
                  <span className="text-amber-600 dark:text-amber-400 ml-2">
                    - Consider upgrading!
                  </span>
                )}
              </p>
            </div>

            {/* Embeddings (if applicable) */}
            {usage.monthly_embeddings_limit > 0 && (
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-medium">Similarity Searches</span>
                  <span className="text-sm text-gray-500 dark:text-gray-400">
                    {usage.monthly_embeddings} / {usage.monthly_embeddings_limit}
                  </span>
                </div>
                <Progress
                  value={(usage.monthly_embeddings / usage.monthly_embeddings_limit) * 100}
                  className="h-2"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {usage.monthly_embeddings_remaining} remaining this month
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Referral Program */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <Gift className="h-5 w-5 text-indigo-500" />
            Refer a Friend
          </CardTitle>
          <CardDescription>
            Share your code and both of you get 1 month of Pro free!
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          {!referralCode && (
            <div className="space-y-3">
              <p className="text-sm text-muted-foreground">
                Could not load your referral link. Check your connection and try again.
              </p>
              <Button
                variant="outline"
                size="sm"
                onClick={async () => {
                  setIsLoadingReferral(true)
                  try {
                    await fetchReferralCode()
                  } finally {
                    setIsLoadingReferral(false)
                  }
                }}
                disabled={isLoadingReferral}
              >
                {isLoadingReferral ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Loading…
                  </>
                ) : (
                  'Retry'
                )}
              </Button>
            </div>
          )}
          {referralCode && (
            <div className="space-y-4">
              {/* Referral Link */}
              <div className="flex flex-col gap-2 sm:flex-row">
                <div className="flex-1 bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 font-mono text-sm truncate">
                  {referralCode.share_url}
                </div>
                <Button
                  variant="outline"
                  onClick={handleCopyLink}
                  className="shrink-0"
                >
                  {copied ? (
                    <>
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      Copied!
                    </>
                  ) : (
                    <>
                      <Copy className="h-4 w-4 mr-2" />
                      Copy Link
                    </>
                  )}
                </Button>
              </div>

              {/* Referral Code Display */}
              <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                <span>Your code:</span>
                <code className="bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded font-mono">
                  {referralCode.code}
                </code>
              </div>

              {/* Share Buttons */}
              <div className="flex flex-wrap gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const text = `Check out FitCheck AI - the smart wardrobe app! Use my referral link to get 1 month of Pro free: ${referralCode.share_url}`;
                    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`, '_blank');
                  }}
                >
                  <Share2 className="h-4 w-4 mr-2" />
                  Share on X
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const text = `Check out FitCheck AI - the smart wardrobe app! Use my referral link to get 1 month of Pro free: ${referralCode.share_url}`;
                    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, '_blank');
                  }}
                >
                  <ExternalLink className="h-4 w-4 mr-2" />
                  WhatsApp
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const subject = "Try FitCheck AI!";
                    const body = `Hey! I've been using FitCheck AI to organize my wardrobe and create outfit visualizations. Use my referral link and we both get 1 month of Pro free!\n\n${referralCode.share_url}`;
                    window.location.href = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
                  }}
                >
                  <ExternalLink className="h-4 w-4 mr-2" />
                  Email
                </Button>
              </div>

              {/* Referral Stats */}
              {referralStats && (
                <div className="pt-4 border-t dark:border-gray-700">
                  <div className="flex items-center gap-4 text-sm">
                    <div className="flex items-center gap-2">
                      <Users className="h-4 w-4 text-gray-400" />
                      <span>
                        <span className="font-semibold">{referralStats.times_used}</span>{" "}
                        friend{referralStats.times_used !== 1 ? "s" : ""} referred
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Gift className="h-4 w-4 text-gray-400" />
                      <span>
                        <span className="font-semibold">{referralStats.credits_earned}</span>{" "}
                        month{referralStats.credits_earned !== 1 ? "s" : ""} earned
                      </span>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default SubscriptionPanel;
