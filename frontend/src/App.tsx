import { Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { useIsAuthenticated, useHasHydrated } from './stores/authStore'
import { memo } from 'react'

// Analytics
import { PostHogIdentify } from './components/analytics/PostHogIdentify'

// Layouts
import AppLayout from './components/layout/AppLayout'
import AuthLayout from './components/layout/AuthLayout'
import PublicLayout from './layouts/PublicLayout'

// Public pages
import LandingPage from './pages/public/LandingPage'
import AboutPage from './pages/public/AboutPage'
import TermsPage from './pages/public/TermsPage'
import PrivacyPage from './pages/public/PrivacyPage'
import SupportPage from './pages/public/SupportPage'
import FAQPage from './pages/public/FAQPage'

// Blog pages
import BlogIndexPage from './pages/blog/BlogIndexPage'
import BlogPostPage from './pages/blog/BlogPostPage'

// Auth pages
import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage'
import ResetPasswordPage from './pages/auth/ResetPasswordPage'
import AuthCallbackPage from './pages/auth/AuthCallbackPage'

// Main pages
import WardrobePage from './pages/wardrobe/WardrobePage'
import OutfitsPage from './pages/outfits/OutfitsPage'
import RecommendationsPage from './pages/recommendations/RecommendationsPage'
import ProfilePage from './pages/settings/ProfilePage'
import DashboardPage from './pages/DashboardPage'
import CalendarPage from './pages/calendar/CalendarPage'
import GamificationPage from './pages/gamification/GamificationPage'
import SharedOutfitPage from './pages/shared/SharedOutfitPage'
import TryOnPage from './pages/try-on/TryOnPage'
import PhotoshootPage from './pages/photoshoot/PhotoshootPage'

// Admin pages
import BlogAdminLayout from './pages/admin/BlogAdminLayout'
import BlogDashboardPage from './pages/admin/BlogDashboardPage'
import BlogListPage from './pages/admin/BlogListPage'
import BlogEditorPage from './pages/admin/BlogEditorPage'
import BlogCategoriesPage from './pages/admin/BlogCategoriesPage'

// Feature landing pages
import FeaturesIndexPage from './pages/features/FeaturesIndexPage'
import AIWardrobeExtractionPage from './pages/features/AIWardrobeExtractionPage'
import VirtualTryOnPage from './pages/features/VirtualTryOnPage'
import AIPhotoshootGeneratorPage from './pages/features/AIPhotoshootGeneratorPage'
import OutfitRecommendationsPage from './pages/features/OutfitRecommendationsPage'
import WardrobeAnalyticsPage from './pages/features/WardrobeAnalyticsPage'

// Intent SEO pages (compare, best-of, personas, guides)
import IntentSeoPage from './pages/seo/IntentSeoPage'

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

  // Wait for hydration before making auth decisions
  if (!hasHydrated) {
    return <LoadingSpinner />
  }

  if (!isAuthenticated) {
    return <Navigate to="/auth/login" replace />
  }

  return <>{children}</>
}

// Public Route (redirect if already authenticated) - waits for hydration
function PublicRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useIsAuthenticated()
  const hasHydrated = useHasHydrated()

  // Wait for hydration before making auth decisions
  if (!hasHydrated) {
    return <LoadingSpinner />
  }

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />
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
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/wardrobe" element={<WardrobePage />} />
          <Route path="/wardrobe/:id" element={<WardrobePage />} />
          <Route path="/outfits" element={<OutfitsPage />} />
          <Route path="/outfits/:id" element={<OutfitsPage />} />
          <Route path="/calendar" element={<CalendarPage />} />
          <Route path="/recommendations" element={<RecommendationsPage />} />
          <Route path="/photoshoot" element={<PhotoshootPage />} />
          <Route path="/try-on" element={<TryOnPage />} />
          <Route path="/gamification" element={<GamificationPage />} />
          <Route path="/profile" element={<ProfilePage />} />
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
    </>
  )
}

export default App
