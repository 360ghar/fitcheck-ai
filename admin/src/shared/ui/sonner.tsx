import { useTheme } from 'next-themes'
import { Toaster as SonnerToaster } from 'sonner'

/**
 * Global toaster — sonner, themed to the warm-neutral token system.
 * richColors is intentionally OFF: error/success styling comes from the
 * classNames below so both themes stay consistent with DESIGN.md.
 */
export function Toaster() {
  const { resolvedTheme } = useTheme()

  return (
    <SonnerToaster
      theme={resolvedTheme === 'dark' ? 'dark' : 'light'}
      position="bottom-right"
      closeButton
      richColors={false}
      toastOptions={{
        classNames: {
          toast:
            '!rounded-md !border !border-border !bg-card !text-card-foreground !shadow-lg',
          description: '!text-muted-foreground',
          actionButton: '!bg-primary !text-primary-foreground',
          cancelButton: '!bg-secondary-bg !text-secondary-foreground',
          closeButton: '!border-border !bg-card !text-muted-foreground',
        },
      }}
    />
  )
}
