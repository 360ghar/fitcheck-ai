# Database schema (generated)

Generated: 2026-07-22

Source: `backend/db/supabase/migrations/`.
Regenerate: `python scripts/generate_db_schema_doc.py`.

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

## Tables (CREATE TABLE)

| Table | Introduced in |
|-------|---------------|
| `blog_posts` | `017_blog_posts.sql` |
| `body_profiles` | `001_full_schema.sql` |
| `calendar_connections` | `001_full_schema.sql` |
| `calendar_events` | `001_full_schema.sql` |
| `challenge_participations` | `001_full_schema.sql` |
| `challenges` | `001_full_schema.sql` |
| `extraction_jobs` | `016_extraction_jobs.sql` |
| `item_colors` | `001_full_schema.sql` |
| `item_images` | `001_full_schema.sql` |
| `items` | `001_full_schema.sql` |
| `outfit_collection_items` | `001_full_schema.sql` |
| `outfit_collections` | `001_full_schema.sql` |
| `outfit_generations` | `001_full_schema.sql` |
| `outfit_images` | `001_full_schema.sql` |
| `outfits` | `001_full_schema.sql` |
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
- `005_waitlist.sql` → `waitlist`
- `006_add_embedding_columns.sql` → `user_ai_settings`
- `006_add_embedding_columns.sql` → `user_ai_settings`
- `007_subscriptions_and_referrals.sql` → `users`
- `007_subscriptions_and_referrals.sql` → `subscriptions`
- `007_subscriptions_and_referrals.sql` → `subscription_usage`
- `007_subscriptions_and_referrals.sql` → `referral_codes`
- `007_subscriptions_and_referrals.sql` → `referral_redemptions`
- `009_support_tickets.sql` → `support_tickets`
- `010_photoshoot_generator.sql` → `subscription_usage`
- `010_photoshoot_generator.sql` → `subscription_usage`
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

## Related

- `docs/references/data-models.md`
- `docs/BACKEND.md`
