import { Sun, Moon, Monitor, Check } from 'lucide-react';
import { useTheme } from './ThemeProvider';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import type { Theme } from '@/lib/theme';

const themeOptions: { value: Theme; label: string; Icon: typeof Sun }[] = [
  { value: 'light', label: 'Light', Icon: Sun },
  { value: 'dark', label: 'Dark', Icon: Moon },
  { value: 'system', label: 'System', Icon: Monitor },
];

interface ThemeToggleProps {
  className?: string;
}

export function ThemeToggle({ className }: ThemeToggleProps) {
  const { theme, setTheme, resolvedTheme } = useTheme();

  // Show current resolved icon
  const CurrentIcon = resolvedTheme === 'dark' ? Moon : Sun;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          className={cn(
            // inline-flex + centering is load-bearing: `touch-target` only sets
            // min-h/min-w, so without it the 20px icon sits top-left of the
            // 44px box instead of dead-centre.
            'inline-flex items-center justify-center p-2 touch-target text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors',
            className
          )}
          title="Toggle theme"
        >
          <CurrentIcon className="h-5 w-5" />
          <span className="sr-only">Toggle theme</span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        {themeOptions.map(({ value, label, Icon }) => (
          <DropdownMenuItem
            key={value}
            onClick={() => setTheme(value)}
            className={cn(
              'flex items-center gap-2 cursor-pointer',
              // `bg-accent` alone is the same fill as the hover state, so the
              // selected row was indistinguishable. Weight + a trailing check
              // carry the state instead.
              theme === value && 'bg-accent font-semibold text-foreground'
            )}
          >
            <Icon className="h-4 w-4" />
            <span>{label}</span>
            {theme === value && <Check className="ml-auto h-4 w-4" />}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
