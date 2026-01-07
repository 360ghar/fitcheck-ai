import { Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { useIsAuthenticated } from './stores/authStore'
import { memo } from 'react'

// Placeholder pages - these will be created in Phase 6
import AppLayout from './components/layout/AppLayout'
import AuthLayout from './components/layout/AuthLayout'

// Auth pages
import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'

// Main pages
import WardrobePage from './pages/wardrobe/WardrobePage'
import OutfitsPage from './pages/outfits/OutfitsPage'
import RecommendationsPage from './pages/recommendations/RecommendationsPage'
import ProfilePage from './pages/settings/ProfilePage'
import DashboardPage from './pages/DashboardPage'

// Protected Route wrapper
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useIsAuthenticated()

  if (!isAuthenticated) {
    return <Navigate to="/auth/login" replace />
  }

  return <>{children}</>
}

// Public Route (redirect if already authenticated)
function PublicRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useIsAuthenticated()

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />
  }

  return <>{children}</>
}

// CatchAll Route component that uses hooks
const CatchAllRoute = memo(function CatchAllRoute() {
  const isAuthenticated = useIsAuthenticated()
  return <Navigate to={isAuthenticated ? '/dashboard' : '/auth/login'} replace />
})

function App() {
  return (
    <Routes>
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

      {/* Main app routes */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <AppLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="wardrobe" element={<WardrobePage />} />
        <Route path="wardrobe/:id" element={<WardrobePage />} />
        <Route path="outfits" element={<OutfitsPage />} />
        <Route path="outfits/:id" element={<OutfitsPage />} />
        <Route path="recommendations" element={<RecommendationsPage />} />
        <Route path="profile" element={<ProfilePage />} />
        <Route path="settings" element={<Navigate to="/profile" replace />} />
      </Route>

      {/* Catch all - redirect to dashboard or login */}
      <Route path="*" element={<CatchAllRoute />} />
    </Routes>
  )
}

export default App
