import { Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { useIsAuthenticated, useHasHydrated } from './stores/authStore'
import { getSafeReturnTo } from './pages/auth/authRedirect'
import { memo, lazy, Suspense } from 'react'

// Analytics
import { PostHogIdentify } from './components/analytics/PostHogIdentify'

// Error boundaries
import FeatureErrorBoundary from './components/errors/FeatureErrorBoundary'

// Build-time feature flags (Vite inlines these, so disabled branches are
// dead-code eliminated along with the pages they mount).
import { FEATURES } from './lib/feature-flags'

// Layouts. AppLayout (the signed-in shell: sidebar, bottom nav, user menu) is
// lazy — it only renders for authenticated users, so marketing visitors never
// download it. It mounts inside the <Suspense> boundary in App().
const AppLayout = lazy(() => import('./components/layout/AppLayout'))
import AuthLayout from './components/layout/AuthLayout'
import PublicLayout from './layouts/PublicLayout'

// Auth pages and the app shell are lazy: a marketing visitor never reaches
// them, and every route lives inside <Suspense>, so there is no flash cost for
// making them chunks. They were eager because a first-time visitor can land
// straight on an auth path — the Suspense fallback (a theme-aware spinner)
// covers that cold start. Everything else below is lazy too.
const LoginPage = lazy(() => import('./pages/auth/LoginPage'))
const RegisterPage = lazy(() => import('./pages/auth/RegisterPage'))

// Public marketing routes come from one shared manifest so the build-time
// prerender (src/entry-prerender.tsx) renders exactly what the client router
// mounts. `componentFor` hands back an already-resolved component for the route
// main.tsx preloaded, and a lazy one for everything else.
import { PUBLIC_ROUTES, componentFor } from './routes/publicRoutes'

// Lazy: every route the user reaches by navigating. Previously all ~40 page
// modules were static imports, so landing on "/" downloaded the blog admin
// rich-text editor, the photoshoot wizard and the try-on page before the hero
// rendered. React guarantees the Suspense fallback resolves, so no content is
// gated on an animation that might not fire.
const ForgotPasswordPage = lazy(() => import('./pages/auth/ForgotPasswordPage'))
const ResetPasswordPage = lazy(() => import('./pages/auth/ResetPasswordPage'))
const AuthCallbackPage = lazy(() => import('./pages/auth/AuthCallbackPage'))

const WardrobePage = lazy(() => import('./pages/wardrobe/WardrobePage'))
const OutfitsPage = lazy(() => import('./pages/outfits/OutfitsPage'))
const OutfitCreatePage = lazy(() => import('./pages/outfits/OutfitCreatePage'))
const RecommendationsPage = lazy(() => import('./pages/recommendations/RecommendationsPage'))
const ProfilePage = lazy(() => import('./pages/settings/ProfilePage'))
const DashboardPage = lazy(() => import('./pages/DashboardPage'))
const CalendarPage = lazy(() => import('./pages/calendar/CalendarPage'))
// Gamification is flag-gated. The ternary is not belt-and-braces — it is what
// actually removes the code. Gating only the <Route> below leaves this
// `lazy(() => import(...))` binding referenced, so Rollup still emits the
// 17.5 kB GamificationPage chunk (measured) even though nothing can navigate
// to it. Guarding the import itself drops the chunk entirely. The `() => null`
// arm is never rendered: with the flag off the route is not mounted at all.
const GamificationPage = FEATURES.gamification
  ? lazy(() => import('./pages/gamification/GamificationPage'))
  : () => null
const SharedOutfitPage = lazy(() => import('./pages/shared/SharedOutfitPage'))
const TryOnPage = lazy(() => import('./pages/try-on/TryOnPage'))
const PhotoshootPage = lazy(() => import('./pages/photoshoot/PhotoshootPage'))

// Loading spinner for hydration state (theme-aware)
function LoadingSpinner() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
    </div>
  )
}

// Protected Route wrapper - waits for hydration before checking auth
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useIsAuthenticated()
  const hasHydrated = useHasHydrated()
  const location = useLocation()

  // Wait for hydration before making auth decisions
  if (!hasHydrated) {
    return <LoadingSpinner />
  }

  if (!isAuthenticated) {
    // Preserve the requested page so a deep link (or an expired session) that
    // bounces the user to login returns them to where they were after signing
    // back in, instead of dumping them on /dashboard. Mirrors forceLogout().
    const returnTo = getSafeReturnTo(location.pathname + location.search)
    const target = returnTo
      ? `/auth/login?returnTo=${encodeURIComponent(returnTo)}`
      : '/auth/login'
    return <Navigate to={target} replace />
  }

  return <>{children}</>
}

// Public Route (redirect if already authenticated) - waits for hydration
function PublicRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useIsAuthenticated()
  const hasHydrated = useHasHydrated()
  const location = useLocation()

  // Wait for hydration before making auth decisions
  if (!hasHydrated) {
    return <LoadingSpinner />
  }

  if (isAuthenticated) {
    // Honor ?returnTo= so an already-signed-in user who lands on an auth page
    // (e.g. a "Sign in" link that carried a destination) is taken back to
    // where they were going instead of always being dumped on /dashboard.
    // /auth/* destinations are skipped to avoid bouncing between auth pages.
    const returnTo = getSafeReturnTo(new URLSearchParams(location.search).get('returnTo'))
    const target = returnTo && !returnTo.startsWith('/auth/') ? returnTo : '/dashboard'
    return <Navigate to={target} replace />
  }

  return <>{children}</>
}

// CatchAll Route component that uses hooks - waits for hydration
const CatchAllRoute = memo(function CatchAllRoute() {
  const isAuthenticated = useIsAuthenticated()
  const hasHydrated = useHasHydrated()

  if (!hasHydrated) {
    return <LoadingSpinner />
  }

  return <Navigate to={isAuthenticated ? '/dashboard' : '/'} replace />
})

/** Preserve query string when redirecting /settings → /profile (Stripe, deep links). */
function SettingsRedirect() {
  const location = useLocation()
  return <Navigate to={{ pathname: '/profile', search: location.search }} replace />
}

function App() {
  return (
    <>
      {/* PostHog user identification - syncs auth state with analytics */}
      <PostHogIdentify />

      {/* One boundary around all routes: React guarantees it resolves, so a
          lazy chunk can never leave a page blank the way a JS-gated reveal can. */}
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          {/* Public marketing routes, generated from the shared manifest in
              routes/publicRoutes.ts so the build-time prerender and the client
              router can never disagree about what "/" renders. */}
          <Route element={<PublicLayout />}>
            {PUBLIC_ROUTES.map(({ path }) => {
              const Page = componentFor(path)
              return <Route key={path} path={path} element={<Page />} />
            })}
          </Route>

          {/* Auth routes */}
          <Route
            path="/auth/login"
            element={
              <PublicRoute>
                <AuthLayout>
                  <LoginPage />
                </AuthLayout>
              </PublicRoute>
            }
          />
          <Route
            path="/auth/register"
            element={
              <PublicRoute>
                <AuthLayout>
                  <RegisterPage />
                </AuthLayout>
              </PublicRoute>
            }
          />
          <Route
            path="/auth/forgot-password"
            element={
              <AuthLayout>
                <ForgotPasswordPage />
              </AuthLayout>
            }
          />
          <Route
            path="/auth/reset-password"
            element={
              <AuthLayout>
                <ResetPasswordPage />
              </AuthLayout>
            }
          />
          <Route
            path="/auth/callback"
            element={<AuthCallbackPage />}
          />

          {/* Public share routes */}
          <Route path="/shared/outfits/:id" element={<SharedOutfitPage />} />

          {/* Main app routes - protected */}
          <Route
            element={
              <ProtectedRoute>
                <AppLayout />
              </ProtectedRoute>
            }
          >
            <Route path="/dashboard" element={<FeatureErrorBoundary featureName="Dashboard"><DashboardPage /></FeatureErrorBoundary>} />
            <Route path="/wardrobe" element={<FeatureErrorBoundary featureName="Wardrobe"><WardrobePage /></FeatureErrorBoundary>} />
            <Route path="/wardrobe/:id" element={<FeatureErrorBoundary featureName="Wardrobe"><WardrobePage /></FeatureErrorBoundary>} />
            <Route path="/outfits" element={<FeatureErrorBoundary featureName="Outfits"><OutfitsPage /></FeatureErrorBoundary>} />
            {/* Static segment outranks /outfits/:id in the router's own ranking. */}
            <Route path="/outfits/new" element={<FeatureErrorBoundary featureName="Create outfit"><OutfitCreatePage /></FeatureErrorBoundary>} />
            <Route path="/outfits/:id" element={<FeatureErrorBoundary featureName="Outfits"><OutfitsPage /></FeatureErrorBoundary>} />
            <Route path="/calendar" element={<FeatureErrorBoundary featureName="Calendar"><CalendarPage /></FeatureErrorBoundary>} />
            <Route path="/recommendations" element={<FeatureErrorBoundary featureName="Recommendations"><RecommendationsPage /></FeatureErrorBoundary>} />
            <Route path="/photoshoot" element={<FeatureErrorBoundary featureName="Photoshoot"><PhotoshootPage /></FeatureErrorBoundary>} />
            <Route path="/try-on" element={<FeatureErrorBoundary featureName="Virtual Try-On"><TryOnPage /></FeatureErrorBoundary>} />
            {/* Gamification is flag-gated (FEATURES.gamification, default off:
                nothing on the backend writes streaks or achievements, so the
                page can only ever show zeros). With the flag off the route is
                simply absent, so a bookmarked /gamification falls through to
                CatchAllRoute → /dashboard. Deliberately NOT a "feature
                disabled" page — that would advertise unfinished work. */}
            {FEATURES.gamification && (
              <Route
                path="/gamification"
                element={
                  <FeatureErrorBoundary featureName="Gamification">
                    <GamificationPage />
                  </FeatureErrorBoundary>
                }
              />
            )}
            <Route path="/profile" element={<FeatureErrorBoundary featureName="Profile & settings"><ProfilePage /></FeatureErrorBoundary>} />
            <Route path="/settings" element={<SettingsRedirect />} />
          </Route>

          {/* Catch all - redirect to dashboard or landing */}
          <Route path="*" element={<CatchAllRoute />} />
        </Routes>
      </Suspense>
    </>
  )
}

export default App
