import { LogOut, Settings, Moon, Sun, Monitor } from 'lucide-react'
import { useTheme } from 'next-themes'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

import { cn } from '@/shared/lib/cn'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { Avatar, AvatarFallback, AvatarImage } from '@/shared/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/shared/ui/dropdown-menu'

function useUserIdentity(): { displayName: string; initials: string; email: string; avatarUrl: string | null } {
  const user = useSessionStore((state) => state.user)
  const displayName = user?.full_name || user?.email || '—'
  const initials = user?.full_name
    ? user.full_name
        .split(' ')
        .map((part) => part[0])
        .filter(Boolean)
        .slice(0, 2)
        .join('')
        .toUpperCase()
    : user?.email?.slice(0, 2).toUpperCase() ?? '?'
  return { displayName, initials, email: user?.email ?? '', avatarUrl: user?.avatar_url ?? null }
}

/** Theme switcher (light / dark / system) via next-themes. */
function ThemeToggle() {
  const { t } = useTranslation('layout')
  const { resolvedTheme, theme, setTheme } = useTheme()
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          aria-label={t('topbar.theme.label')}
          className="flex size-11 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-surface-card hover:text-foreground focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
        >
          {resolvedTheme === 'dark' ? (
            <Moon className="size-4" aria-hidden="true" />
          ) : (
            <Sun className="size-4" aria-hidden="true" />
          )}
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-40">
        <DropdownMenuRadioGroup
          {...(theme !== undefined ? { value: theme } : {})}
          onValueChange={(value) => setTheme(value)}
        >
          <DropdownMenuRadioItem value="light">
            <Sun aria-hidden="true" />
            {t('topbar.theme.light')}
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="dark">
            <Moon aria-hidden="true" />
            {t('topbar.theme.dark')}
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="system">
            <Monitor aria-hidden="true" />
            {t('topbar.theme.system')}
          </DropdownMenuRadioItem>
        </DropdownMenuRadioGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

/** Account menu: identity, settings, sign out. */
export function UserMenu() {
  const { t } = useTranslation('layout')
  const { displayName, initials, email, avatarUrl } = useUserIdentity()
  const navigate = useNavigate()

  const handleLogout = (): void => {
    useSessionStore.getState().logout()
    void navigate('/login', { replace: true })
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          aria-label={t('topbar.userMenu.label')}
          className="flex items-center gap-2 rounded-full p-1 transition-colors hover:bg-surface-card focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
        >
          <Avatar className="size-8">
            <AvatarImage src={avatarUrl ?? undefined} alt="" />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>
          <span className="hidden text-sm font-medium text-foreground md:block">{displayName}</span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-60">
        <DropdownMenuLabel>
          <div className="flex flex-col gap-0.5">
            <span className="truncate font-medium text-foreground">{displayName}</span>
            <span className="truncate text-xs font-normal text-muted-foreground">{email}</span>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => navigate('/settings')}>
          <Settings aria-hidden="true" />
          {t('topbar.userMenu.settings')}
        </DropdownMenuItem>
        <DropdownMenuItem
          className={cn('text-destructive focus:text-destructive')}
          onClick={handleLogout}
        >
          <LogOut aria-hidden="true" />
          {t('topbar.userMenu.logout')}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

export { ThemeToggle }
