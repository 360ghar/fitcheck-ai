import type { SupabaseClient } from '@supabase/supabase-js'

import { env } from '@/config/env'

/**
 * Lazily-created Supabase client for Google OAuth sign-in.
 *
 * Mirrors the main frontend pattern (frontend/src/lib/supabase.ts): the SDK
 * is dynamic-imported on first use and memoized, so @supabase/supabase-js
 * never lands in the entry chunk — it is fetched only when someone actually
 * clicks "Continue with Google". The login page hides the Google button
 * entirely when the env vars are missing (see isGoogleAuthConfigured).
 */

let clientPromise: Promise<SupabaseClient> | null = null

export function getSupabase(): Promise<SupabaseClient> {
  if (!clientPromise) {
    clientPromise = import('@supabase/supabase-js').then(({ createClient }) =>
      createClient(env.VITE_SUPABASE_URL ?? '', env.VITE_SUPABASE_PUBLISHABLE_KEY ?? ''),
    )
  }
  return clientPromise
}
