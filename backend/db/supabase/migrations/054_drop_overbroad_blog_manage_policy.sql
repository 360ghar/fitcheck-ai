-- FitCheck AI - Forward migration: drop over-broad authenticated blog policy
--
-- Migration 017 shipped a `FOR ALL TO authenticated USING (true) WITH CHECK
-- (true)` policy on blog_posts with the comment "Admin checks are handled at
-- the application level". That is an RLS over-grant of the exact class
-- migration 043 hardened elsewhere: ANY signed-in user could INSERT/UPDATE/
-- DELETE every blog post directly through PostgREST, bypassing the backend's
-- content.write permission gate (create_post/update_post/delete_post all
-- require `content.write` and run with the service_role client, which is
-- BYPASSRLS and unaffected by this policy). Public reads are served by the
-- "Anyone can read published blog posts" FOR SELECT policy, and
-- authenticated reads by "Authenticated users can read all blog posts".
--
-- Rerunnable (DROP POLICY IF EXISTS): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

DROP POLICY IF EXISTS "Authenticated users can manage blog posts"
    ON public.blog_posts;

COMMIT;
