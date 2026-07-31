import * as React from 'react'
import { Search } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface SearchBarProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'aria-label'> {
  /** A visible label may live outside the field; the control still needs a name. */
  'aria-label': string
  containerClassName?: string
}

export const SearchBar = React.forwardRef<HTMLInputElement, SearchBarProps>(
  ({ className, containerClassName, type: _type, ...props }, ref) => (
    <div className={cn('group relative h-12 w-full rounded-full bg-card transition-colors focus-within:bg-background focus-within:ring-1 focus-within:ring-ash', containerClassName)}>
      <Search aria-hidden="true" className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      <input
        {...props}
        ref={ref}
        type="search"
        className={cn('h-full w-full rounded-full bg-transparent py-2 pl-11 pr-4 type-body-md text-foreground placeholder:text-ash outline-none', className)}
      />
    </div>
  ),
)
SearchBar.displayName = 'SearchBar'
