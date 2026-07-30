-- =============================================================================
-- Migration 020: Plus subscription plan
-- =============================================================================
-- Introduces the $10/mo "Plus" tier (plus_monthly / plus_yearly).
--
-- NO structural change is required: subscriptions.plan_type is VARCHAR(20)
-- (migration 007, line 17) and both new values fit within 20 characters.
-- This migration only records the newly-valid values so the schema documents
-- itself and `docs/generated/db-schema.md` regenerates correctly.
--
-- Plus has the SAME feature entitlement as Pro (see
-- SubscriptionService.is_paid_plan) but lower monthly usage limits
-- (see SubscriptionService.get_plan_limits / PLAN_PLUS_* in app/core/config.py).
-- =============================================================================

COMMENT ON COLUMN public.subscriptions.plan_type IS
    'Subscription plan. One of: free, plus_monthly, plus_yearly, pro_monthly, pro_yearly. '
    'plus_* and pro_* are paid plans with identical feature entitlement; only usage limits differ.';
