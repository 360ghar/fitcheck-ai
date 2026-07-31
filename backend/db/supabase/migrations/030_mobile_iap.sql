-- FitCheck AI - Mobile In-App Purchase support (Apple App Store + Google Play)
--
-- Adds store-billing provider columns to subscriptions and dedupe ledgers for
-- the two signed webhook sources (App Store Server Notifications V2 and Play
-- Real-time Developer Notifications), mirroring the stripe_webhook_events
-- pattern from migration 022/027.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- TABLE: subscriptions - store billing columns
-- =============================================================================

-- Which billing rail owns this row: 'stripe' (web checkout, legacy default),
-- 'apple' (App Store IAP) or 'google' (Play Billing IAP). Only the owning rail
-- may mutate the row; the others fail closed (see SubscriptionService).
ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS billing_provider VARCHAR(20) NOT NULL DEFAULT 'stripe';

-- Store-billed rows also persist the transaction identity so renewals and
-- restores can be reconciled idempotently.
ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS apple_original_transaction_id VARCHAR(255);

ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS google_purchase_token VARCHAR(1024);

ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS google_order_id VARCHAR(255);

-- The store product ID currently active on this row ('plus_monthly', ...).
-- Mirrors the plan_type the store billed for; kept separate so a mismatch
-- between stored product and plan_type is visible in the row.
ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS billing_product_id VARCHAR(64);

CREATE INDEX IF NOT EXISTS idx_subscriptions_billing_provider
    ON public.subscriptions(billing_provider);
CREATE INDEX IF NOT EXISTS idx_subscriptions_apple_original_transaction_id
    ON public.subscriptions(apple_original_transaction_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_google_purchase_token
    ON public.subscriptions(google_purchase_token);

-- =============================================================================
-- TABLE: apple_iap_events - App Store Server Notification V2 dedupe ledger
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.apple_iap_events (
    notification_id TEXT PRIMARY KEY,
    event_type TEXT NOT NULL,
    signed_type TEXT,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'pending',
    attempts INTEGER NOT NULL DEFAULT 0,
    processing_started_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    last_error TEXT
);

ALTER TABLE public.apple_iap_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role manages apple iap events" ON public.apple_iap_events;
CREATE POLICY "Service role manages apple iap events"
    ON public.apple_iap_events FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

ALTER TABLE public.apple_iap_events DROP CONSTRAINT IF EXISTS apple_iap_events_status_check;
ALTER TABLE public.apple_iap_events
    ADD CONSTRAINT apple_iap_events_status_check
    CHECK (status IN ('pending', 'processing', 'processed', 'failed'));

-- =============================================================================
-- TABLE: google_rtdn_events - Play Real-time Developer Notification dedupe
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.google_rtdn_events (
    message_id TEXT PRIMARY KEY,
    event_type TEXT NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'pending',
    attempts INTEGER NOT NULL DEFAULT 0,
    processing_started_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    last_error TEXT
);

ALTER TABLE public.google_rtdn_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role manages google rtdn events" ON public.google_rtdn_events;
CREATE POLICY "Service role manages google rtdn events"
    ON public.google_rtdn_events FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

ALTER TABLE public.google_rtdn_events DROP CONSTRAINT IF EXISTS google_rtdn_events_status_check;
ALTER TABLE public.google_rtdn_events
    ADD CONSTRAINT google_rtdn_events_status_check
    CHECK (status IN ('pending', 'processing', 'processed', 'failed'));

COMMIT;
