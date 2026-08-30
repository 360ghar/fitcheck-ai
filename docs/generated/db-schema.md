# Database schema (generated)

Generated: 2026-08-30

Source: `backend/db/supabase/migrations/`.
Regenerate: `python scripts/generate_db_schema_doc.py`.

## Limitations

> This file is produced by regular-expression heuristics, not a real SQL parser.
> Quoted identifiers, schema-qualified names, materialized views, statements inside
> PL/pgSQL / dollar-quoted bodies, and CREATE/ALTER TABLE calls hidden behind IF/ELSE
> or multi-line conditional blocks may be missed or misattributed. Treat this as an
> orientation index for agents; confirm DDL in the migration files or live Supabase
> before relying on it.

This is an orientation index for agents, not a substitute for reading migrations or live Supabase.

## Migration files

- `001_full_schema.sql`
- `002_astrology_profile.sql`
- `002_user_profile_trigger.sql`
- `003_remove_puter_add_ai_settings.sql`
- `004_add_user_gender.sql`
- `005_waitlist.sql`
- `006_add_embedding_columns.sql`
- `007_subscriptions_and_referrals.sql`
- `008_update_new_user_trigger_for_subscriptions.sql`
- `009_support_tickets.sql`
- `010_photoshoot_generator.sql`
- `011_shared_outfits_unique_constraint.sql`
- `012_social_import_pipeline.sql`
- `013_add_items_occasion_tags_gin_index.sql`
- `014_add_user_dob.sql`
- `015_drop_date_of_birth.sql`
- `016_extraction_jobs.sql`
- `017_blog_posts.sql`
- `018_default_ai_provider_custom.sql`
- `019_add_item_source_image.sql`
- `020_plus_plan.sql`
- `021_calendar_event_type.sql`
- `022_wave_b_hardening.sql`
- `023_durable_job_state.sql`
- `024_atomic_daily_quota_reservations.sql`
- `025_calendar_all_day_events.sql`
- `026_harden_rpc_privileges.sql`
- `027_stripe_webhook_processing_state.sql`
- `028_configurable_social_import_limit.sql`
- `029_pr9_hardening.sql`
- `030_mobile_iap.sql`
- `031_promo_codes.sql`
- `032_fix_redeem_promo_atomic_plan_type.sql`
- `033_fix_referral_credit_stacking.sql`
- `034_add_support_tickets_storage_paths.sql`
- `035_add_photoshoot_jobs_image_failures.sql`
- `036_widen_image_url_columns.sql`
- `037_admin_roles.sql`
- `038_audit_events.sql`
- `039_scope_service_policies.sql`
- `040_admin_dashboard_top_users.sql`
- `041_admin_trends.sql`
- `042_outfit_wear_history.sql`
- `043_scope_service_policies_and_harden_users.sql`
- `044_atomic_counters_and_item_images.sql`
- `045_shared_outfit_atomicity.sql`
- `046_seed_ai_settings_and_harden_storage_buckets.sql`
- `047_items_client_request_id.sql`
- `048_drop_legacy_supabase_buckets.sql`
- `049_fix_redeem_promo_atomic_null_stripe.sql`
- `050_fix_referral_credit_no_banking.sql`
- `051_add_referral_redemptions_credit_months.sql`
- `052_iap_identifier_ownership.sql`
- `053_extraction_jobs_reserved_generations.sql`
- `054_drop_overbroad_blog_manage_policy.sql`
- `055_release_job_generation_quota.sql`
- `056_gift_vouchers.sql`
- `057_mcp_oauth.sql`
- `058_mcp_oauth_atomic_token_exchange.sql`
- `059_atomic_admin_gift_revoke.sql`
- `060_atomic_admin_user_actions.sql`
- `061_gift_voucher_recipient_matching.sql`

## Tables (CREATE TABLE)

| Table | Introduced in |
|-------|---------------|
| `apple_iap_events` | `030_mobile_iap.sql` |
| `audit_events` | `038_audit_events.sql` |
| `blog_posts` | `017_blog_posts.sql` |
| `body_profiles` | `001_full_schema.sql` |
| `calendar_connections` | `001_full_schema.sql` |
| `calendar_events` | `001_full_schema.sql` |
| `challenge_participations` | `001_full_schema.sql` |
| `challenges` | `001_full_schema.sql` |
| `extraction_jobs` | `016_extraction_jobs.sql` |
| `gift_entitlement_grants` | `056_gift_vouchers.sql` |
| `gift_voucher_allowances` | `056_gift_vouchers.sql` |
| `gift_vouchers` | `056_gift_vouchers.sql` |
| `google_rtdn_events` | `030_mobile_iap.sql` |
| `item_colors` | `001_full_schema.sql` |
| `item_images` | `001_full_schema.sql` |
| `items` | `001_full_schema.sql` |
| `mcp_oauth_auth_codes` | `057_mcp_oauth.sql` |
| `mcp_oauth_clients` | `057_mcp_oauth.sql` |
| `mcp_oauth_refresh_tokens` | `057_mcp_oauth.sql` |
| `outfit_collection_items` | `001_full_schema.sql` |
| `outfit_collections` | `001_full_schema.sql` |
| `outfit_generations` | `001_full_schema.sql` |
| `outfit_images` | `001_full_schema.sql` |
| `outfit_wear_history` | `042_outfit_wear_history.sql` |
| `outfits` | `001_full_schema.sql` |
| `photoshoot_jobs` | `023_durable_job_state.sql` |
| `promo_codes` | `031_promo_codes.sql` |
| `promo_redemptions` | `031_promo_codes.sql` |
| `recommendation_logs` | `001_full_schema.sql` |
| `referral_codes` | `007_subscriptions_and_referrals.sql` |
| `referral_redemptions` | `007_subscriptions_and_referrals.sql` |
| `share_feedback` | `001_full_schema.sql` |
| `shared_outfits` | `001_full_schema.sql` |
| `social_import_auth_sessions` | `012_social_import_pipeline.sql` |
| `social_import_events` | `012_social_import_pipeline.sql` |
| `social_import_items` | `012_social_import_pipeline.sql` |
| `social_import_jobs` | `012_social_import_pipeline.sql` |
| `social_import_photos` | `012_social_import_pipeline.sql` |
| `stripe_webhook_events` | `022_wave_b_hardening.sql` |
| `subscription_usage` | `007_subscriptions_and_referrals.sql` |
| `subscriptions` | `007_subscriptions_and_referrals.sql` |
| `support_tickets` | `009_support_tickets.sql` |
| `trip_capsule_items` | `001_full_schema.sql` |
| `trips` | `001_full_schema.sql` |
| `user_achievements` | `001_full_schema.sql` |
| `user_ai_settings` | `003_remove_puter_add_ai_settings.sql` |
| `user_preferences` | `001_full_schema.sql` |
| `user_settings` | `001_full_schema.sql` |
| `user_streaks` | `001_full_schema.sql` |
| `users` | `001_full_schema.sql` |
| `waitlist` | `005_waitlist.sql` |

## Required columns added after table creation

| Migration | Table | Column |
|-----------|-------|--------|
| `021_calendar_event_type.sql` | `calendar_events` | `event_type` |
| `025_calendar_all_day_events.sql` | `calendar_events` | `is_all_day` |
| `027_stripe_webhook_processing_state.sql` | `stripe_webhook_events` | `status` |
| `027_stripe_webhook_processing_state.sql` | `stripe_webhook_events` | `attempts` |
| `030_mobile_iap.sql` | `subscriptions` | `billing_provider` |
| `035_add_photoshoot_jobs_image_failures.sql` | `photoshoot_jobs` | `image_failures` |
| `037_admin_roles.sql` | `users` | `is_admin` |
| `037_admin_roles.sql` | `users` | `role` |
| `053_extraction_jobs_reserved_generations.sql` | `extraction_jobs` | `reserved_generations` |

These columns are added after their table's CREATE TABLE and are required (NOT NULL DEFAULT), so inserts rely on the default until a value is supplied.

## ALTER TABLE references

- `001_full_schema.sql` → `users`
- `001_full_schema.sql` → `user_preferences`
- `001_full_schema.sql` → `items`
- `001_full_schema.sql` → `item_images`
- `001_full_schema.sql` → `outfits`
- `001_full_schema.sql` → `outfit_images`
- `001_full_schema.sql` → `outfit_collections`
- `001_full_schema.sql` → `users`
- `001_full_schema.sql` → `user_preferences`
- `001_full_schema.sql` → `user_settings`
- `001_full_schema.sql` → `items`
- `001_full_schema.sql` → `item_images`
- `001_full_schema.sql` → `item_colors`
- `001_full_schema.sql` → `outfits`
- `001_full_schema.sql` → `outfit_images`
- `001_full_schema.sql` → `outfit_collections`
- `001_full_schema.sql` → `outfit_collection_items`
- `001_full_schema.sql` → `body_profiles`
- `001_full_schema.sql` → `outfit_generations`
- `001_full_schema.sql` → `calendar_connections`
- `001_full_schema.sql` → `calendar_events`
- `001_full_schema.sql` → `trips`
- `001_full_schema.sql` → `trip_capsule_items`
- `001_full_schema.sql` → `recommendation_logs`
- `001_full_schema.sql` → `shared_outfits`
- `001_full_schema.sql` → `share_feedback`
- `001_full_schema.sql` → `user_streaks`
- `001_full_schema.sql` → `user_achievements`
- `001_full_schema.sql` → `challenges`
- `001_full_schema.sql` → `challenge_participations`
- `002_astrology_profile.sql` → `users`
- `002_astrology_profile.sql` → `users`
- `003_remove_puter_add_ai_settings.sql` → `users`
- `003_remove_puter_add_ai_settings.sql` → `user_ai_settings`
- `004_add_user_gender.sql` → `users`
- `004_add_user_gender.sql` → `users`
- `004_add_user_gender.sql` → `users`
- `005_waitlist.sql` → `waitlist`
- `006_add_embedding_columns.sql` → `user_ai_settings`
- `006_add_embedding_columns.sql` → `user_ai_settings`
- `007_subscriptions_and_referrals.sql` → `referral_redemptions`
- `007_subscriptions_and_referrals.sql` → `users`
- `007_subscriptions_and_referrals.sql` → `subscriptions`
- `007_subscriptions_and_referrals.sql` → `subscription_usage`
- `007_subscriptions_and_referrals.sql` → `referral_codes`
- `007_subscriptions_and_referrals.sql` → `referral_redemptions`
- `009_support_tickets.sql` → `support_tickets`
- `010_photoshoot_generator.sql` → `subscription_usage`
- `010_photoshoot_generator.sql` → `subscription_usage`
- `011_shared_outfits_unique_constraint.sql` → `shared_outfits`
- `011_shared_outfits_unique_constraint.sql` → `shared_outfits`
- `012_social_import_pipeline.sql` → `social_import_jobs`
- `012_social_import_pipeline.sql` → `social_import_photos`
- `012_social_import_pipeline.sql` → `social_import_items`
- `012_social_import_pipeline.sql` → `social_import_auth_sessions`
- `012_social_import_pipeline.sql` → `social_import_events`
- `014_add_user_dob.sql` → `users`
- `014_add_user_dob.sql` → `users`
- `014_add_user_dob.sql` → `users`
- `015_drop_date_of_birth.sql` → `users`
- `016_extraction_jobs.sql` → `extraction_jobs`
- `017_blog_posts.sql` → `blog_posts`
- `018_default_ai_provider_custom.sql` → `user_ai_settings`
- `019_add_item_source_image.sql` → `items`
- `021_calendar_event_type.sql` → `calendar_events`
- `022_wave_b_hardening.sql` → `stripe_webhook_events`
- `023_durable_job_state.sql` → `extraction_jobs`
- `023_durable_job_state.sql` → `extraction_jobs`
- `023_durable_job_state.sql` → `photoshoot_jobs`
- `025_calendar_all_day_events.sql` → `calendar_events`
- `027_stripe_webhook_processing_state.sql` → `stripe_webhook_events`
- `027_stripe_webhook_processing_state.sql` → `stripe_webhook_events`
- `027_stripe_webhook_processing_state.sql` → `stripe_webhook_events`
- `029_pr9_hardening.sql` → `extraction_jobs`
- `029_pr9_hardening.sql` → `extraction_jobs`
- `030_mobile_iap.sql` → `subscriptions`
- `030_mobile_iap.sql` → `subscriptions`
- `030_mobile_iap.sql` → `subscriptions`
- `030_mobile_iap.sql` → `subscriptions`
- `030_mobile_iap.sql` → `subscriptions`
- `030_mobile_iap.sql` → `apple_iap_events`
- `030_mobile_iap.sql` → `apple_iap_events`
- `030_mobile_iap.sql` → `apple_iap_events`
- `030_mobile_iap.sql` → `google_rtdn_events`
- `030_mobile_iap.sql` → `google_rtdn_events`
- `030_mobile_iap.sql` → `google_rtdn_events`
- `031_promo_codes.sql` → `promo_codes`
- `031_promo_codes.sql` → `promo_redemptions`
- `034_add_support_tickets_storage_paths.sql` → `support_tickets`
- `035_add_photoshoot_jobs_image_failures.sql` → `photoshoot_jobs`
- `036_widen_image_url_columns.sql` → `users`
- `036_widen_image_url_columns.sql` → `item_images`
- `036_widen_image_url_columns.sql` → `outfit_images`
- `037_admin_roles.sql` → `users`
- `037_admin_roles.sql` → `users`
- `037_admin_roles.sql` → `users`
- `037_admin_roles.sql` → `support_tickets`
- `038_audit_events.sql` → `audit_events`
- `042_outfit_wear_history.sql` → `outfit_wear_history`
- `045_shared_outfit_atomicity.sql` → `shared_outfits`
- `047_items_client_request_id.sql` → `items`
- `047_items_client_request_id.sql` → `outfit_images`
- `051_add_referral_redemptions_credit_months.sql` → `referral_redemptions`
- `053_extraction_jobs_reserved_generations.sql` → `extraction_jobs`
- `056_gift_vouchers.sql` → `gift_vouchers`
- `056_gift_vouchers.sql` → `gift_voucher_allowances`
- `056_gift_vouchers.sql` → `gift_entitlement_grants`
- `057_mcp_oauth.sql` → `mcp_oauth_clients`
- `057_mcp_oauth.sql` → `mcp_oauth_auth_codes`
- `057_mcp_oauth.sql` → `mcp_oauth_refresh_tokens`
- `061_gift_voucher_recipient_matching.sql` → `gift_vouchers`

## Related

- `docs/references/data-models.md`
- `docs/BACKEND.md`
