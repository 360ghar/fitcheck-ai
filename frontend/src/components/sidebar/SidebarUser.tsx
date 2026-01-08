import { Link } from 'react-router-dom'
import { User, LogOut, Settings } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import {
  useAuthStore,
  useUserDisplayName,
  useUserInitials,
  useUserAvatar,
} from '@/stores/authStore'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import { ThemeToggle } from '@/components/theme'

export function SidebarUser() {
  const { isCollapsed, closeMobile } = useSidebar()
  const logout = useAuthStore((state) => state.logout)
  const userDisplayName = useUserDisplayName()
  const userInitials = useUserInitials()
  const userAvatar = useUserAvatar()

  const handleLogout = async () => {
    await logout()
    window.location.href = '/auth/login'
  }

  const handleProfileClick = () => {
    closeMobile()
  }

  const avatarElement = userAvatar ? (
    <img
      src={userAvatar}
      alt=""
      className="h-8 w-8 rounded-full object-cover ring-2 ring-border"
    />
  ) : (
    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-sm font-medium text-primary-foreground ring-2 ring-border">
      {userInitials}
    </div>
  )

  const userContent = (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="ghost"
          className={cn(
            'w-full justify-start gap-3 px-3 py-2 h-auto',
            isCollapsed && 'justify-center px-2'
          )}
        >
          {avatarElement}
          <div
            className={cn(
              'flex flex-col items-start overflow-hidden transition-all duration-200',
              isCollapsed ? 'w-0 opacity-0' : 'w-auto opacity-100'
            )}
          >
            <span className="truncate text-sm font-medium">
              {userDisplayName}
            </span>
            <span className="text-xs text-muted-foreground">View profile</span>
          </div>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        side={isCollapsed ? 'right' : 'top'}
        align={isCollapsed ? 'start' : 'center'}
        className="w-56"
      >
        <div className="flex items-center gap-2 px-2 py-1.5">
          {avatarElement}
          <div className="flex flex-col">
            <span className="text-sm font-medium">{userDisplayName}</span>
          </div>
        </div>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link
            to="/profile"
            onClick={handleProfileClick}
            className="flex items-center gap-2"
          >
            <User className="h-4 w-4" />
            Profile
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <Link
            to="/profile"
            onClick={handleProfileClick}
            className="flex items-center gap-2"
          >
            <Settings className="h-4 w-4" />
            Settings
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={handleLogout}
          className="flex items-center gap-2 text-destructive focus:text-destructive"
        >
          <LogOut className="h-4 w-4" />
          Log out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )

  if (isCollapsed) {
    return (
      <div className="border-t border-border px-2 py-3">
        <div className="flex flex-col items-center gap-2">
          <Tooltip delayDuration={0}>
            <TooltipTrigger asChild>{userContent}</TooltipTrigger>
            <TooltipContent side="right" sideOffset={10}>
              <p>{userDisplayName}</p>
            </TooltipContent>
          </Tooltip>
          <ThemeToggle />
        </div>
      </div>
    )
  }

  return (
    <div className="border-t border-border px-3 py-3">
      <div className="flex items-center justify-between">
        <div className="flex-1">{userContent}</div>
        <ThemeToggle />
      </div>
    </div>
  )
}
