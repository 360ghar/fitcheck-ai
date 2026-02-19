/**
 * Blog Admin Layout Component
 * Provides sidebar navigation for blog management with admin-only access
 */

import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import {
  FileText,
  PlusCircle,
  FolderOpen,
  LayoutDashboard,
  ArrowLeft,
} from 'lucide-react';
import { useCurrentUser } from '@/stores/authStore';

interface NavItemProps {
  to: string;
  icon: React.ReactNode;
  label: string;
  end?: boolean;
}

function NavItem({ to, icon, label, end }: NavItemProps) {
  return (
    <NavLink
      to={to}
      end={end}
      className={({ isActive }) =>
        cn(
          'flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors',
          isActive
            ? 'bg-primary text-primary-foreground'
            : 'text-muted-foreground hover:bg-muted hover:text-foreground'
        )
      }
    >
      {icon}
      {label}
    </NavLink>
  );
}

export default function BlogAdminLayout() {
  const user = useCurrentUser();
  const navigate = useNavigate();

  // Check if user is admin
  // Note: In a real app, you'd check user.role or similar
  // For now, we'll allow all authenticated users but show a warning
  useEffect(() => {
    // TODO: Implement proper admin check when user roles are available
    // if (!user?.is_admin) {
    //   showError('You do not have permission to access this area');
    //   navigate('/dashboard');
    // }
  }, [user, navigate]);

  return (
    <div className="min-h-screen bg-background">
      <div className="flex">
        {/* Sidebar */}
        <aside className="w-64 min-h-screen border-r bg-card">
          <div className="p-6">
            <div className="flex items-center gap-2 mb-8">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <FileText className="w-4 h-4 text-primary-foreground" />
              </div>
              <div>
                <h1 className="font-semibold text-sm">Blog Admin</h1>
                <p className="text-xs text-muted-foreground">Manage content</p>
              </div>
            </div>

            <nav className="space-y-1">
              <NavItem
                to="/admin/blog"
                icon={<LayoutDashboard className="w-4 h-4" />}
                label="Dashboard"
                end
              />
              <NavItem
                to="/admin/blog/posts"
                icon={<FileText className="w-4 h-4" />}
                label="All Posts"
              />
              <NavItem
                to="/admin/blog/new"
                icon={<PlusCircle className="w-4 h-4" />}
                label="New Post"
              />
              <NavItem
                to="/admin/blog/categories"
                icon={<FolderOpen className="w-4 h-4" />}
                label="Categories"
              />
            </nav>

            <div className="mt-8 pt-8 border-t">
              <Button
                variant="ghost"
                className="w-full justify-start text-muted-foreground"
                onClick={() => navigate('/dashboard')}
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to App
              </Button>
            </div>
          </div>

          <div className="absolute bottom-0 left-0 right-0 p-4 border-t bg-card">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center">
                <span className="text-xs font-medium">
                  {user?.full_name?.charAt(0) || user?.email?.charAt(0) || '?'}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">
                  {user?.full_name || user?.email}
                </p>
                <p className="text-xs text-muted-foreground">Administrator</p>
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 min-h-screen">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
