import { lazy, Suspense, type LazyExoticComponent, type ComponentType } from 'react'
import { createBrowserRouter, Navigate, type RouteObject } from 'react-router-dom'

import { PermissionRoute, PublicOnlyGuard, RouteGuard } from '@/app/guards'
import { RootLayout } from '@/app/layout/RootLayout'
import { NotFoundPage } from '@/app/pages/NotFoundPage'
import { PageLoader } from '@/shared/ui/PageLoader'

/**
 * Typed route manifest (spec §3). Every route is lazy via React.lazy so each
 * feature page ships as its own chunk. `titleKey` drives the document title
 * (layout namespace or feature namespace); `permission` gates the route.
 */

export interface RouteMeta {
  /** i18n key for the page title (namespace included, e.g. `placeholder:users.title`) */
  titleKey: string
  /** Permission required to view the route — undefined = any signed-in admin */
  permission?: string
}

export const routeManifest = {
  login: { titleKey: 'auth:login.title' },
  dashboard: { titleKey: 'placeholder:dashboard.title', permission: 'dashboards.read' },
  trends: { titleKey: 'placeholder:trends.title', permission: 'dashboards.read' },
  users: { titleKey: 'placeholder:users.title', permission: 'users.read' },
  userDetail: { titleKey: 'placeholder:userDetail.title', permission: 'users.read' },
  subscriptions: { titleKey: 'placeholder:subscriptions.title', permission: 'subscriptions.read' },
  iap: { titleKey: 'placeholder:iap.title', permission: 'iap.read' },
  quotas: { titleKey: 'placeholder:quotas.title', permission: 'quotas.read' },
  promo: { titleKey: 'placeholder:promo.title', permission: 'promo.read' },
  feedback: { titleKey: 'placeholder:feedback.title', permission: 'feedback.read' },
  audit: { titleKey: 'placeholder:audit.title', permission: 'audit.read' },
  storage: { titleKey: 'placeholder:storage.title', permission: 'ops.read' },
  settings: { titleKey: 'placeholder:settings.title' },
  posts: { titleKey: 'placeholder:posts.title', permission: 'content.read' },
  categories: { titleKey: 'placeholder:categories.title', permission: 'content.read' },
  postNew: { titleKey: 'content:editor.newTitle', permission: 'content.read' },
  postEdit: { titleKey: 'content:editor.editTitle', permission: 'content.read' },
} as const satisfies Record<string, RouteMeta>

// ────────────────────────────────────────────────────────────────────────────
// Lazy page components (one chunk per feature page)
// ────────────────────────────────────────────────────────────────────────────

function lazyPage(loader: () => Promise<{ default: ComponentType }>): LazyExoticComponent<ComponentType> {
  return lazy(loader)
}

const LoginPage = lazyPage(() =>
  import('@/features/auth/pages/LoginPage').then((m) => ({ default: m.LoginPage })),
)
const DashboardPage = lazyPage(() =>
  import('@/features/dashboard/pages/DashboardPage').then((m) => ({ default: m.DashboardPage })),
)
const TrendsPage = lazyPage(() =>
  import('@/features/dashboard/pages/TrendsPage').then((m) => ({ default: m.TrendsPage })),
)
const UsersPage = lazyPage(() =>
  import('@/features/users/pages/UsersPage').then((m) => ({ default: m.UsersPage })),
)
const UserDetailPage = lazyPage(() =>
  import('@/features/users/pages/UserDetailPage').then((m) => ({ default: m.UserDetailPage })),
)
const SubscriptionsPage = lazyPage(() =>
  import('@/features/subscriptions/pages/SubscriptionsPage').then((m) => ({
    default: m.SubscriptionsPage,
  })),
)
const IapTransactionsPage = lazyPage(() =>
  import('@/features/subscriptions/pages/IapTransactionsPage').then((m) => ({
    default: m.IapTransactionsPage,
  })),
)
const QuotasPage = lazyPage(() =>
  import('@/features/quotas/pages/QuotasPage').then((m) => ({ default: m.QuotasPage })),
)
const PromoPage = lazyPage(() =>
  import('@/features/promo/pages/PromoPage').then((m) => ({ default: m.PromoPage })),
)
const FeedbackPage = lazyPage(() =>
  import('@/features/feedback/pages/FeedbackPage').then((m) => ({ default: m.FeedbackPage })),
)
const AuditPage = lazyPage(() =>
  import('@/features/audit/pages/AuditPage').then((m) => ({ default: m.AuditPage })),
)
const StoragePage = lazyPage(() =>
  import('@/features/ops/pages/StoragePage').then((m) => ({ default: m.StoragePage })),
)
const SettingsPage = lazyPage(() =>
  import('@/features/settings/pages/SettingsPage').then((m) => ({ default: m.SettingsPage })),
)
const PostsPage = lazyPage(() =>
  import('@/features/content/pages/PostsPage').then((m) => ({ default: m.PostsPage })),
)
const PostEditorPage = lazyPage(() =>
  import('@/features/content/pages/PostEditorPage').then((m) => ({ default: m.PostEditorPage })),
)
const CategoriesPage = lazyPage(() =>
  import('@/features/content/pages/CategoriesPage').then((m) => ({ default: m.CategoriesPage })),
)

function withSuspense(page: LazyExoticComponent<ComponentType>): React.ReactNode {
  const Page = page
  return (
    <Suspense fallback={<PageLoader />}>
      <Page />
    </Suspense>
  )
}

function guardedPage(
  page: LazyExoticComponent<ComponentType>,
  permission?: string,
): React.ReactNode {
  // exactOptionalPropertyTypes: spread conditionally so `permission` is never
  // passed as an explicit `undefined`.
  return (
    <PermissionRoute {...(permission ? { permission } : {})}>
      {withSuspense(page)}
    </PermissionRoute>
  )
}

// ────────────────────────────────────────────────────────────────────────────
// Route objects
// ────────────────────────────────────────────────────────────────────────────

export const appRouteObjects: RouteObject[] = [
  {
    path: '/login',
    element: (
      <PublicOnlyGuard>
        <Suspense fallback={<PageLoader />}>
          <LoginPage />
        </Suspense>
      </PublicOnlyGuard>
    ),
    handle: { titleKey: routeManifest.login.titleKey },
  },
  {
    element: (
      <RouteGuard>
        <RootLayout />
      </RouteGuard>
    ),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      {
        path: 'dashboard',
        element: guardedPage(DashboardPage, 'dashboards.read'),
        handle: { titleKey: routeManifest.dashboard.titleKey },
      },
      {
        path: 'dashboard/trends',
        element: guardedPage(TrendsPage, 'dashboards.read'),
        handle: { titleKey: routeManifest.trends.titleKey },
      },
      {
        path: 'users',
        element: guardedPage(UsersPage, 'users.read'),
        handle: { titleKey: routeManifest.users.titleKey },
      },
      {
        path: 'users/:id',
        element: guardedPage(UserDetailPage, 'users.read'),
        handle: { titleKey: routeManifest.userDetail.titleKey },
      },
      {
        path: 'subscriptions',
        element: guardedPage(SubscriptionsPage, 'subscriptions.read'),
        handle: { titleKey: routeManifest.subscriptions.titleKey },
      },
      {
        path: 'iap',
        element: guardedPage(IapTransactionsPage, 'iap.read'),
        handle: { titleKey: routeManifest.iap.titleKey },
      },
      {
        path: 'quotas',
        element: guardedPage(QuotasPage, 'quotas.read'),
        handle: { titleKey: routeManifest.quotas.titleKey },
      },
      {
        path: 'promo',
        element: guardedPage(PromoPage, 'promo.read'),
        handle: { titleKey: routeManifest.promo.titleKey },
      },
      {
        path: 'feedback',
        element: guardedPage(FeedbackPage, 'feedback.read'),
        handle: { titleKey: routeManifest.feedback.titleKey },
      },
      {
        path: 'audit',
        element: guardedPage(AuditPage, 'audit.read'),
        handle: { titleKey: routeManifest.audit.titleKey },
      },
      {
        path: 'storage',
        element: guardedPage(StoragePage, 'ops.read'),
        handle: { titleKey: routeManifest.storage.titleKey },
      },
      {
        path: 'settings',
        element: guardedPage(SettingsPage),
        handle: { titleKey: routeManifest.settings.titleKey },
      },
      {
        path: 'content/posts',
        element: guardedPage(PostsPage, 'content.read'),
        handle: { titleKey: routeManifest.posts.titleKey },
      },
      {
        path: 'content/posts/new',
        element: guardedPage(PostEditorPage, 'content.read'),
        handle: { titleKey: routeManifest.postNew.titleKey },
      },
      {
        path: 'content/posts/edit/:slug',
        element: guardedPage(PostEditorPage, 'content.read'),
        handle: { titleKey: routeManifest.postEdit.titleKey },
      },
      {
        path: 'content/categories',
        element: guardedPage(CategoriesPage, 'content.read'),
        handle: { titleKey: routeManifest.categories.titleKey },
      },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
]

export function createAppRouter() {
  return createBrowserRouter(appRouteObjects)
}
