-- FitCheck AI - Scope remaining service-only policies; harden users / blog_posts / user_ai_settings RLS
--
-- Migration 039 fixed migrations 030/038's unscoped "Service role ..." FOR ALL
-- policies (CREATE POLICY without TO applies to PUBLIC, so any anon/authenticated
-- JWT could read/write those tables through PostgREST) but explicitly left
-- 007/009/031 "untouched". This migration closes that gap and three adjacent
-- RLS holes found in the 2026-08-09 full-sweep:
--
--   1. 007/009/031 FOR ALL "Service role can manage ..." policies have no TO
--      clause -> anon/authenticated could read/upgrade/delete subscriptions,
--      subscription_usage, referral_codes, referral_redemptions, support_tickets,
--      promo_codes, promo_redemptions directly via PostgREST.
--   2. users self-UPDATE/INSERT policies (001) plus the admin columns added in
--      037 (role/is_admin/custom_daily_quota) -> a client could escalate its own
--      row to an admin role through PostgREST (permissions.py trusts the DB row).
--   3. blog_posts "manage" policy (017) is FOR ALL TO authenticated -> any
--      logged-in user can create/update/delete posts served on the public site.
--   4. user_ai_settings self-UPDATE (003) -> users could zero their own daily
--      quota counters through PostgREST, bypassing reserve_ai_usage.
--
-- Backend API operations run with the service-role client (app/db/connection.py)
-- and bypass RLS entirely, so scoping these policies/grants cannot affect API
-- flows; it only closes direct PostgREST access using the anon/authenticated
-- keys embedded in the mobile/web apps. The backend stays the trust boundary.
--
-- Re-runnable: every policy is DROP IF EXISTS + CREATE; grants are idempotent.
-- Safe to re-run in the SQL editor.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- 1) Scope FOR ALL "Service role can manage ..." policies to service_role
-- =============================================================================

-- subscriptions (007)
REVOKE INSERT, UPDATE, DELETE ON public.subscriptions FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage subscriptions" ON public.subscriptions;
CREATE POLICY "Service role can manage subscriptions"
    ON public.subscriptions FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- subscription_usage (007)
REVOKE INSERT, UPDATE, DELETE ON public.subscription_usage FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage usage" ON public.subscription_usage;
CREATE POLICY "Service role can manage usage"
    ON public.subscription_usage FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- referral_codes (007) - the intentional PUBLIC "Anyone can validate" SELECT
-- policy is left untouched; only the FOR ALL write policy is scoped.
REVOKE INSERT, UPDATE, DELETE ON public.referral_codes FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage referral codes" ON public.referral_codes;
CREATE POLICY "Service role can manage referral codes"
    ON public.referral_codes FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- referral_redemptions (007)
REVOKE INSERT, UPDATE, DELETE ON public.referral_redemptions FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage referral redemptions" ON public.referral_redemptions;
CREATE POLICY "Service role can manage referral redemptions"
    ON public.referral_redemptions FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- support_tickets (009) - users keep the INSERT-own-ticket policy; all other
-- operations are service-role only (users never read tickets directly).
REVOKE INSERT, UPDATE, DELETE ON public.support_tickets FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage tickets" ON public.support_tickets;
CREATE POLICY "Service role can manage tickets"
    ON public.support_tickets FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- promo_codes (031) - intentional PUBLIC "Anyone can validate" SELECT stays.
REVOKE INSERT, UPDATE, DELETE ON public.promo_codes FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage promo codes" ON public.promo_codes;
CREATE POLICY "Service role can manage promo codes"
    ON public.promo_codes FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- promo_redemptions (031)
REVOKE INSERT, UPDATE, DELETE ON public.promo_redemptions FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role can manage promo redemptions" ON public.promo_redemptions;
CREATE POLICY "Service role can manage promo redemptions"
    ON public.promo_redemptions FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- 2) users: no client INSERT/DELETE; self-UPDATE limited to profile columns
-- =============================================================================
-- 037 added role/is_admin/custom_daily_quota to users; the 001 self-UPDATE
-- policy (USING auth.uid() = id) had no column restriction and the INSERT
-- policy let a client seed its own row with arbitrary values. The backend
-- (service role) is the only writer of admin columns. Column-level grants
-- keep the self-service profile columns open and close everything else.
REVOKE INSERT, UPDATE, DELETE ON public.users FROM anon, authenticated;

-- 002's "Service role can insert users" policy was FOR INSERT WITH CHECK (TRUE)
-- without TO -> any anon/authenticated client could insert a users row (with
-- admin columns, once 037 exists). Scope it to service_role like its name says.
DROP POLICY IF EXISTS "Service role can insert users" ON public.users;
CREATE POLICY "Service role can insert users"
    ON public.users FOR INSERT
    TO service_role
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

GRANT UPDATE (full_name, avatar_url, gender, birth_date, birth_time, birth_place)
    ON public.users TO authenticated;

-- =============================================================================
-- 3) blog_posts: writes are service-role only; drop authenticated read-all
-- =============================================================================
-- The marketing site reads published posts anonymously via the backend API;
-- the admin console reads/writes via the backend API (service role). No
-- first-party client needs authenticated PostgREST access to drafts.
REVOKE ALL ON public.blog_posts FROM authenticated;

DROP POLICY IF EXISTS "Authenticated users can read all blog posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Authenticated users can manage blog posts" ON public.blog_posts;

DROP POLICY IF EXISTS "Service role manages blog posts" ON public.blog_posts;
CREATE POLICY "Service role manages blog posts"
    ON public.blog_posts FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- 4) user_ai_settings: self-update limited to provider config columns
-- =============================================================================
-- Daily counters are authoritative quota state (024 reserve_ai_usage); a
-- client must not be able to zero them or backdate last_reset_date through
-- PostgREST. Users may still configure their own BYOK provider settings.
REVOKE INSERT, UPDATE, DELETE ON public.user_ai_settings FROM anon, authenticated;

DROP POLICY IF EXISTS "Users can insert own AI settings" ON public.user_ai_settings;
DROP POLICY IF EXISTS "Users can delete own AI settings" ON public.user_ai_settings;

GRANT UPDATE (provider_configs, default_provider)
    ON public.user_ai_settings TO authenticated;

COMMIT;
