import {
  Cpu,
  CreditCard,
  Database,
  FileText,
  FolderTree,
  LayoutDashboard,
  LineChart,
  MessageSquare,
  Receipt,
  ScrollText,
  Settings,
  Tag,
  Users,
  type LucideIcon,
} from 'lucide-react'

/**
 * Sidebar navigation manifest (spec §5): grouped, permission-filtered. Items
 * without the matching permission are hidden — UI shaping only, the backend
 * enforces access.
 */
export interface NavItem {
  path: string
  /** i18n key in the `layout` namespace */
  titleKey: string
  icon: LucideIcon
  /** Backend permission (see shared/lib/permissions.ts). Omit = any signed-in admin. */
  permission?: string
}

export interface NavGroup {
  /** i18n key in the `layout` namespace */
  labelKey: string
  items: NavItem[]
}

export const navGroups: NavGroup[] = [
  {
    labelKey: 'nav.overview',
    items: [
      { path: '/dashboard', titleKey: 'nav.dashboard', icon: LayoutDashboard, permission: 'dashboards.read' },
      { path: '/dashboard/trends', titleKey: 'nav.trends', icon: LineChart, permission: 'dashboards.read' },
    ],
  },
  {
    labelKey: 'nav.customers',
    items: [{ path: '/users', titleKey: 'nav.users', icon: Users, permission: 'users.read' }],
  },
  {
    labelKey: 'nav.commerce',
    items: [
      { path: '/subscriptions', titleKey: 'nav.subscriptions', icon: CreditCard, permission: 'subscriptions.read' },
      { path: '/iap', titleKey: 'nav.iap', icon: Receipt, permission: 'iap.read' },
      { path: '/promo', titleKey: 'nav.promo', icon: Tag, permission: 'promo.read' },
    ],
  },
  {
    labelKey: 'nav.ai',
    items: [{ path: '/quotas', titleKey: 'nav.quotas', icon: Cpu, permission: 'quotas.read' }],
  },
  {
    labelKey: 'nav.content',
    items: [
      { path: '/content/posts', titleKey: 'nav.posts', icon: FileText, permission: 'content.read' },
      { path: '/content/categories', titleKey: 'nav.categories', icon: FolderTree, permission: 'content.read' },
    ],
  },
  {
    labelKey: 'nav.system',
    items: [
      { path: '/audit', titleKey: 'nav.audit', icon: ScrollText, permission: 'audit.read' },
      { path: '/feedback', titleKey: 'nav.feedback', icon: MessageSquare, permission: 'feedback.read' },
      { path: '/storage', titleKey: 'nav.storage', icon: Database, permission: 'ops.read' },
      // Settings: backend gate is require_admin (any admin role) — no permission.
      { path: '/settings', titleKey: 'nav.settings', icon: Settings },
    ],
  },
]
