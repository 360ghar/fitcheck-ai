import type { SupabaseClient } from '@supabase/supabase-js'

/**
 * Lazily-created Supabase client.
 *
 * This module used to call `createClient` at module scope and export the
 * instance. `authStore` imports it, and `Navbar` imports `authStore` for
 * `useIsAuthenticated()`, so `@supabase/supabase-js` was pulled into the entry
 * chunk and sat on the critical path of every marketing pageview — despite
 * being needed at exactly two call sites, both inside async auth actions
 * (Google OAuth sign-in and the OAuth callback).
 *
 * `getSupabase()` dynamic-imports the SDK on first use and memoizes it, so the
 * chunk is fetched only when someone actually signs in with Google.
 */

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || 'placeholder'

let clientPromise: Promise<SupabaseClient> | null = null

export function getSupabase(): Promise<SupabaseClient> {
  if (!clientPromise) {
    clientPromise = import('@supabase/supabase-js').then(({ createClient }) =>
      createClient(supabaseUrl, supabaseKey)
    )
  }
  return clientPromise
}
