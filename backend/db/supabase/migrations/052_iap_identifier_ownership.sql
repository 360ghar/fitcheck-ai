-- FitCheck AI - IAP identifier ownership unique indexes
--
-- POST /api/v1/iap/transaction registers a store-verified purchase against
-- one account. The ownership check (_ensure_identifier_available) is a plain
-- SELECT with no lock, so two CONCURRENT registrations of the same verified
-- transaction from different accounts can both pass the lookup and each grant
-- a paid entitlement from the same store purchase (A1-01). These partial
-- unique indexes make the claim atomic at the database level: the loser's
-- upsert raises 23505, which the route maps to the same "already used on
-- another account" validation error.
--
-- Partial (WHERE ... IS NOT NULL AND <> '') so rows that never carried a
-- store identifier (free / Stripe-only subscriptions) never collide, and so
-- NULL identifiers (one rail's column is NULL while the other is populated)
-- never trip the constraint.
--
-- Pre-existing duplicates: the very bug this migration fixes may already
-- have materialized as TWO rows carrying one identifier in production. A
-- bare CREATE UNIQUE INDEX would fail on those (duplicate key) and block
-- every later migration. The DO block below releases the OLDER duplicate
-- (keeps the most recently updated row per identifier, mirroring the app's
-- own identifier-release path in subscription_service.sync_iap_subscription)
-- before the index is built. Both steps are guarded and idempotent, so the
-- migration is re-runnable.
--
-- Target: Supabase Postgres

BEGIN;

-- Hold an ACCESS EXCLUSIVE lock on subscriptions for the whole migration so a
-- live IAP write (sync_iap_subscription upsert) cannot re-insert a duplicate
-- store identifier in the gap between the dedupe UPDATEs and the unique-index
-- build — that window would otherwise make CREATE UNIQUE INDEX fail with a
-- duplicate-key error and abort the migration (A1-01).
LOCK TABLE public.subscriptions IN ACCESS EXCLUSIVE MODE;

DO $$
DECLARE
    dup_id TEXT;
BEGIN
    IF to_regclass('public.subscriptions') IS NULL THEN
        RAISE NOTICE 'subscriptions table not present; skipping apple dedupe';
        RETURN;
    END IF;

    FOR dup_id IN
        SELECT apple_original_transaction_id
        FROM public.subscriptions
        WHERE apple_original_transaction_id IS NOT NULL
          AND apple_original_transaction_id <> ''
        GROUP BY apple_original_transaction_id
        HAVING COUNT(*) > 1
    LOOP
        -- Release the OLDER duplicate (keep the most recently updated row per
        -- identifier) AND downgrade it to free, mirroring the app's runtime
        -- release path in subscription_service.sync_iap_subscription. A bare
        -- identifier NULL would leave the released loser fully entitled
        -- (paid plan_type, active status, current_period_end intact), so one
        -- verified purchase could keep two accounts on the paid plan.
        UPDATE public.subscriptions
        SET apple_original_transaction_id = NULL,
            plan_type = 'free',
            status = 'active',
            current_period_end = NULL,
            cancel_at_period_end = FALSE,
            billing_product_id = NULL,
            updated_at = NOW()
        WHERE apple_original_transaction_id = dup_id
          AND id NOT IN (
              SELECT id
              FROM public.subscriptions
              WHERE apple_original_transaction_id = dup_id
              ORDER BY updated_at DESC NULLS LAST, id
              LIMIT 1
          );
        RAISE NOTICE 'released duplicate apple_original_transaction_id %', dup_id;
    END LOOP;
END $$;

DO $$
DECLARE
    dup_token TEXT;
BEGIN
    IF to_regclass('public.subscriptions') IS NULL THEN
        RAISE NOTICE 'subscriptions table not present; skipping google dedupe';
        RETURN;
    END IF;

    FOR dup_token IN
        SELECT google_purchase_token
        FROM public.subscriptions
        WHERE google_purchase_token IS NOT NULL
          AND google_purchase_token <> ''
        GROUP BY google_purchase_token
        HAVING COUNT(*) > 1
    LOOP
        -- Same full downgrade as the apple branch above: release the older
        -- duplicate's identifier and revoke its entitlement so the loser
        -- cannot stay on a paid plan without a store identity (A1-01).
        UPDATE public.subscriptions
        SET google_purchase_token = NULL,
            google_order_id = NULL,
            plan_type = 'free',
            status = 'active',
            current_period_end = NULL,
            cancel_at_period_end = FALSE,
            billing_product_id = NULL,
            updated_at = NOW()
        WHERE google_purchase_token = dup_token
          AND id NOT IN (
              SELECT id
              FROM public.subscriptions
              WHERE google_purchase_token = dup_token
              ORDER BY updated_at DESC NULLS LAST, id
              LIMIT 1
          );
        RAISE NOTICE 'released duplicate google_purchase_token %', dup_token;
    END LOOP;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_apple_identifier_owner
    ON public.subscriptions (apple_original_transaction_id)
    WHERE apple_original_transaction_id IS NOT NULL
      AND apple_original_transaction_id <> '';

CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_google_token_owner
    ON public.subscriptions (google_purchase_token)
    WHERE google_purchase_token IS NOT NULL
      AND google_purchase_token <> '';

COMMIT;
