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

// Layouts
import AppLayout from './components/layout/AppLayout'
import AuthLayout from './components/layout/AuthLayout'
import PublicLayout from './layouts/PublicLayout'

// Eager: the cold-start paths. A first-time visitor lands on one of these, so
// putting them behind a chunk fetch would only add a round-trip before the
// first paint. Everything else is lazy -- see the block below.
import LandingPage from './pages/public/LandingPage'
import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'

// Lazy: every route the user reaches by navigating. Previously all ~40 page
// modules were static imports, so landing on "/" downloaded the blog admin
// rich-text editor, the photoshoot wizard and the try-on page before the hero
// rendered. React guarantees the Suspense fallback resolves, so no content is
// gated on an animation that might not fire.
const AboutPage = lazy(() => import('./pages/public/AboutPage'))
const TermsPage = lazy(() => import('./pages/public/TermsPage'))
const PrivacyPage = lazy(() => import('./pages/public/PrivacyPage'))
const SupportPage = lazy(() => import('./pages/public/SupportPage'))
const FAQPage = lazy(() => import('./pages/public/FAQPage'))

const BlogIndexPage = lazy(() => import('./pages/blog/BlogIndexPage'))
const BlogPostPage = lazy(() => import('./pages/blog/BlogPostPage'))

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

const BlogAdminLayout = lazy(() => import('./pages/admin/BlogAdminLayout'))
const BlogDashboardPage = lazy(() => import('./pages/admin/BlogDashboardPage'))
const BlogListPage = lazy(() => import('./pages/admin/BlogListPage'))
const BlogEditorPage = lazy(() => import('./pages/admin/BlogEditorPage'))
const BlogCategoriesPage = lazy(() => import('./pages/admin/BlogCategoriesPage'))

const FeaturesIndexPage = lazy(() => import('./pages/features/FeaturesIndexPage'))
const AIWardrobeExtractionPage = lazy(() => import('./pages/features/AIWardrobeExtractionPage'))
const VirtualTryOnPage = lazy(() => import('./pages/features/VirtualTryOnPage'))
const AIPhotoshootGeneratorPage = lazy(() => import('./pages/features/AIPhotoshootGeneratorPage'))
const OutfitRecommendationsPage = lazy(() => import('./pages/features/OutfitRecommendationsPage'))
const WardrobeAnalyticsPage = lazy(() => import('./pages/features/WardrobeAnalyticsPage'))

// Intent SEO pages (compare, best-of, personas, guides)
const IntentSeoPage = lazy(() => import('./pages/seo/IntentSeoPage'))
const CostPerWearCalculatorPage = lazy(
  () => import('./pages/tools/CostPerWearCalculatorPage')
)

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
          {/* Public marketing routes */}
          <Route element={<PublicLayout />}>
            <Route path="/" element={<LandingPage />} />
            <Route path="/about" element={<AboutPage />} />
            <Route path="/terms" element={<TermsPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
            <Route path="/support" element={<SupportPage />} />
            <Route path="/faq" element={<FAQPage />} />
            <Route path="/blog" element={<BlogIndexPage />} />
            <Route path="/blog/category/:category" element={<BlogIndexPage />} />
            <Route path="/blog/:slug" element={<BlogPostPage />} />

            {/* Feature landing pages */}
            <Route path="/features" element={<FeaturesIndexPage />} />
            <Route path="/features/ai-wardrobe-extraction" element={<AIWardrobeExtractionPage />} />
            <Route path="/features/virtual-try-on" element={<VirtualTryOnPage />} />
            <Route path="/features/ai-photoshoot-generator" element={<AIPhotoshootGeneratorPage />} />
            <Route path="/features/outfit-recommendations" element={<OutfitRecommendationsPage />} />
            <Route path="/features/wardrobe-analytics" element={<WardrobeAnalyticsPage />} />

            {/* SEO intent pages: best-of, comparisons, personas, guides */}
            <Route path="/best/virtual-closet-apps" element={<IntentSeoPage />} />
            <Route path="/best/ai-outfit-planners" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-acloset" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-whering" element={<IntentSeoPage />} />
            <Route path="/alternatives/acloset-alternatives" element={<IntentSeoPage />} />
            <Route path="/for/busy-professionals" element={<IntentSeoPage />} />
            <Route path="/for/content-creators" element={<IntentSeoPage />} />
            <Route path="/for/festive-and-wedding-outfits" element={<IntentSeoPage />} />
            <Route path="/guides/how-to-digitize-your-wardrobe" element={<IntentSeoPage />} />
            <Route path="/guides/what-to-wear-today" element={<IntentSeoPage />} />
            <Route path="/guides/cost-per-wear-calculator-explained" element={<IntentSeoPage />} />
            <Route path="/guides/how-to-reduce-clothing-returns-with-virtual-try-on" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-stylebook" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-indyx" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-cladwell" element={<IntentSeoPage />} />
            <Route path="/compare/fitcheck-vs-open-wardrobe" element={<IntentSeoPage />} />
            <Route path="/guides/what-is-a-capsule-wardrobe" element={<IntentSeoPage />} />
            <Route path="/guides/what-is-wardrobe-utilization" element={<IntentSeoPage />} />
            <Route path="/wear/:citySlug" element={<IntentSeoPage />} />
            <Route path="/tools/cost-per-wear-calculator" element={<CostPerWearCalculatorPage />} />
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

          {/* Admin routes - protected */}
          <Route
            element={
              <ProtectedRoute>
                <BlogAdminLayout />
              </ProtectedRoute>
            }
          >
            <Route path="/admin/blog" element={<BlogDashboardPage />} />
            <Route path="/admin/blog/posts" element={<BlogListPage />} />
            <Route path="/admin/blog/new" element={<BlogEditorPage />} />
            <Route path="/admin/blog/edit/:slug" element={<BlogEditorPage />} />
            <Route path="/admin/blog/categories" element={<BlogCategoriesPage />} />
          </Route>

          {/* Catch all - redirect to dashboard or landing */}
          <Route path="*" element={<CatchAllRoute />} />
        </Routes>
      </Suspense>
    </>
  )
}

export default App
