import { Routes, Route, Navigate } from 'react-router-dom'
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

// Auth pages
import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage'
import ResetPasswordPage from './pages/auth/ResetPasswordPage'

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

// Loading spinner for hydration state
function LoadingSpinner() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600" />
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
        <Route path="/try-on" element={<TryOnPage />} />
        <Route path="/gamification" element={<GamificationPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/settings" element={<Navigate to="/profile" replace />} />
      </Route>

      {/* Catch all - redirect to dashboard or landing */}
      <Route path="*" element={<CatchAllRoute />} />
    </Routes>
    </>
  )
}

export default App
