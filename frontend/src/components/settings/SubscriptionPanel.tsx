/**
 * SubscriptionPanel Component
 *
 * Settings panel for managing subscription, viewing usage, and sharing referral code.
 */

import { useState, useEffect } from "react";
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
import { useSubscriptionStore, usePlanName, useIsPro, useIsNearLimit } from "@/stores/subscriptionStore";
import type { PlanType } from "@/types";

// ============================================================================
// COMPONENT
// ============================================================================

export function SubscriptionPanel() {
  const [copied, setCopied] = useState(false);
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
    fetchSubscription,
    fetchReferralCode,
    fetchReferralStats,
    fetchPlans,
    startCheckout,
    openBillingPortal,
    cancelSubscription,
    copyReferralLink,
  } = useSubscriptionStore();

  const planName = usePlanName();
  const isPro = useIsPro();
  const nearLimit = useIsNearLimit();

  // Load data on mount
  useEffect(() => {
    fetchSubscription();
    fetchReferralCode();
    fetchReferralStats();
    fetchPlans();
  }, [fetchSubscription, fetchReferralCode, fetchReferralStats, fetchPlans]);

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
                {isPro && (
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

      {/* Pricing Plans (show only for free users) */}
      {!isPro && plans?.plans && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5 text-indigo-500" />
              Upgrade to Pro
            </CardTitle>
            <CardDescription>
              Unlock more extractions and generations
            </CardDescription>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
            <div className="grid gap-4 md:grid-cols-2">
              {/* Monthly Plan */}
              <div className="border rounded-lg p-4 dark:border-gray-700 hover:border-indigo-300 dark:hover:border-indigo-700 transition-colors">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="font-semibold text-lg">Pro Monthly</h3>
                    <p className="text-3xl font-bold mt-1">
                      $20<span className="text-base font-normal text-gray-500">/mo</span>
                    </p>
                  </div>
                </div>
                <ul className="space-y-2 text-sm text-gray-600 dark:text-gray-400 mb-4">
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    200 item extractions/month
                  </li>
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    1,000 outfit visualizations/month
                  </li>
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    Priority support
                  </li>
                </ul>
                <Button
                  onClick={() => handleUpgrade("pro_monthly")}
                  disabled={isCheckingOut}
                  className="w-full"
                  variant="outline"
                >
                  {isCheckingOut ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    "Choose Monthly"
                  )}
                </Button>
              </div>

              {/* Yearly Plan */}
              <div className="border-2 border-indigo-500 rounded-lg p-4 relative">
                <Badge className="absolute -top-2.5 left-4 bg-indigo-500">
                  Save $40/year
                </Badge>
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="font-semibold text-lg">Pro Yearly</h3>
                    <p className="text-3xl font-bold mt-1">
                      $200<span className="text-base font-normal text-gray-500">/yr</span>
                    </p>
                    <p className="text-sm text-gray-500">~$16.67/month</p>
                  </div>
                </div>
                <ul className="space-y-2 text-sm text-gray-600 dark:text-gray-400 mb-4">
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    200 item extractions/month
                  </li>
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    1,000 outfit visualizations/month
                  </li>
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    Priority support
                  </li>
                  <li className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-green-500" />
                    Early access to new features
                  </li>
                </ul>
                <Button
                  onClick={() => handleUpgrade("pro_yearly")}
                  disabled={isCheckingOut}
                  className="w-full bg-indigo-600 hover:bg-indigo-700"
                >
                  {isCheckingOut ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    "Choose Yearly"
                  )}
                </Button>
              </div>
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
                {nearLimit.extractions && !isPro && (
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
                {nearLimit.generations && !isPro && (
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
