import * as React from 'react'

import { cn } from '@/shared/lib/cn'

/** Skeleton block — pulse animation, shaped like content. */
function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('animate-pulse rounded-md bg-surface-card', className)} {...props} />
}

export { Skeleton }
