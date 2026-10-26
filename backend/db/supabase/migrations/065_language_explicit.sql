-- FitCheck AI - user_settings.language_explicit
--
-- PROBLEM. `user_settings.language` ships as `VARCHAR(10) DEFAULT 'en'`
-- (migration 001). Two different facts therefore collapse into one value:
--
--   * the row was never touched, and the app should follow the device
--     (`Accept-Language`) as it does for every other unpicked preference;
--   * the user opened the picker and chose English, which must beat a phone
--     set to Japanese.
--
-- Both read back as 'en'. The backend cannot tell them apart, so it had to
-- pick one behaviour for both, and `accept-language` lost: a user who
-- deliberately picked English gets Japanese-seeded AI text. This column is the
-- missing bit.
--
-- Three states vs two. A nullable column (NULL = "not chosen", TRUE = chosen,
-- FALSE = ???) has a third state with no meaning. `BOOLEAN NOT NULL DEFAULT
-- FALSE` is the honest model: the row always knows whether the user chose, and
-- "not chosen" is the only state a fresh row can be in. Every read then
-- collapses to one non-null boolean with no `IS NULL` / `COALESCE` branch.
--
-- BACKFILL. Every existing row is set to FALSE (the column default already
-- does this for new rows). That is correct for CURRENTLY SHIPPED code, and the
-- reasoning is checkable rather than assumed:
--
--   * Nothing has ever read `language` (the column was dead until the language
--     transport layer landed), so nothing could have depended on a stored 'en'.
--   * The only shipped writes of the setting are profile-creation defaults:
--     migration 001/002/008 triggers, `api/v1/auth.py` (3 sites) and
--     `api/v1/deps.py` - all literal `"language": "en"` on insert. None of
--     them represents a selection.
--   * The one client that writes a deliberate choice
--     (`flutter/lib/core/i18n/locale_controller.dart`) is currently UNTRACKED,
--     i.e. not in any build users have. Its `setLocale(null)` path also writes
--     `'en'`, which is exactly the ambiguity this column removes - so it must
--     switch to sending `language: null` AND `language_explicit` before it
--     ships. See docs/BACKEND.md -> "Language contract".
--
-- So no row can be a deliberate English choice yet, and FALSE is right for all
-- of them. The backfill is a plain DEFAULT because the column lands on a table
-- whose row count is small (one row per user); no batching needed.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS is the whole statement, and it is
-- re-runnable on its own. There is deliberately no backfill UPDATE — the
-- DEFAULT on ADD COLUMN rewrites existing rows inside the same atomic DDL, and
-- a top-level UPDATE would break the re-runnability contract enforced by
-- `test_all_migrations_are_rerunnable`. It could not match a row anyway: NOT
-- NULL makes `IS NULL` unrepresentable after this statement runs.
--
-- Target: Supabase Postgres (apply on hosted Supabase only).
--
-- APPLY (human, one approval - NOT run by the agent):
--   psql "$SUPABASE_DB_URL" -f backend/db/supabase/migrations/065_language_explicit.sql
-- or paste the file into the hosted Supabase SQL editor.

BEGIN;

-- ADD COLUMN ... NOT NULL DEFAULT FALSE does the backfill atomically: Postgres
-- rewrites existing rows with the default, then forbids NULL. No separate
-- UPDATE is needed, and none is written - a top-level UPDATE would break the
-- re-runnability contract (docs/references/local-setup.md) and could never
-- match a row anyway, because NOT NULL makes `IS NULL` unrepresentable.
ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS language_explicit BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.user_settings.language_explicit IS
    'TRUE when the user picked a language in the app; FALSE means follow the device (Accept-Language). Guards against the DEFAULT ''en'' being mistaken for a deliberate English choice.';

COMMIT;
