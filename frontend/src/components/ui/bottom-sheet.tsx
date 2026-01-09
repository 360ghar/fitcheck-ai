/**
 * Bottom Sheet Component
 * Mobile-optimized sheet that slides up from the bottom with drag indicator
 * Built on top of Radix Dialog for accessibility
 */

import * as React from 'react'
import * as SheetPrimitive from '@radix-ui/react-dialog'
import { cn } from '@/lib/utils'

const BottomSheet = SheetPrimitive.Root

const BottomSheetTrigger = SheetPrimitive.Trigger

const BottomSheetClose = SheetPrimitive.Close

const BottomSheetPortal = SheetPrimitive.Portal

const BottomSheetOverlay = React.forwardRef<
  React.ElementRef<typeof SheetPrimitive.Overlay>,
  React.ComponentPropsWithoutRef<typeof SheetPrimitive.Overlay>
>(({ className, ...props }, ref) => (
  <SheetPrimitive.Overlay
    className={cn(
      'fixed inset-0 z-50 bg-black/60 backdrop-blur-sm',
      'data-[state=open]:animate-in data-[state=closed]:animate-out',
      'data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0',
      className
    )}
    {...props}
    ref={ref}
  />
))
BottomSheetOverlay.displayName = 'BottomSheetOverlay'

interface BottomSheetContentProps
  extends React.ComponentPropsWithoutRef<typeof SheetPrimitive.Content> {
  /** Height of the sheet - 'auto', 'half', 'full', or percentage string like '85%' */
  height?: 'auto' | 'half' | 'full' | string
  /** Whether to show the drag indicator handle */
  showDragIndicator?: boolean
}

const BottomSheetContent = React.forwardRef<
  React.ElementRef<typeof SheetPrimitive.Content>,
  BottomSheetContentProps
>(({ className, children, height = '85%', showDragIndicator = true, ...props }, ref) => {
  const getHeightClass = () => {
    switch (height) {
      case 'auto':
        return 'max-h-[90vh]'
      case 'half':
        return 'h-[50vh]'
      case 'full':
        return 'h-[95vh]'
      default:
        return ''
    }
  }

  const heightStyle = typeof height === 'string' && !['auto', 'half', 'full'].includes(height)
    ? { height }
    : undefined

  return (
    <BottomSheetPortal>
      <BottomSheetOverlay />
      <SheetPrimitive.Content
        ref={ref}
        className={cn(
          // Base styles
          'fixed z-50 inset-x-0 bottom-0',
          'flex flex-col',
          'bg-background',
          'rounded-t-3xl shadow-elevated-lg',
          // Safe area padding
          'pb-[var(--safe-area-bottom)]',
          // Animation
          'transition ease-out',
          'data-[state=open]:animate-in data-[state=closed]:animate-out',
          'data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom',
          'data-[state=closed]:duration-200 data-[state=open]:duration-300',
          // Height
          getHeightClass(),
          className
        )}
        style={heightStyle}
        {...props}
      >
        {/* Drag Indicator */}
        {showDragIndicator && (
          <div className="flex justify-center pt-3 pb-2">
            <div className="w-10 h-1 rounded-full bg-muted-foreground/30" />
          </div>
        )}

        {/* Content */}
        <div className="flex-1 overflow-y-auto overscroll-contain px-4">
          {children}
        </div>
      </SheetPrimitive.Content>
    </BottomSheetPortal>
  )
})
BottomSheetContent.displayName = 'BottomSheetContent'

const BottomSheetHeader = ({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) => (
  <div
    className={cn(
      'flex flex-col space-y-1.5 px-2 pb-4',
      className
    )}
    {...props}
  />
)
BottomSheetHeader.displayName = 'BottomSheetHeader'

const BottomSheetTitle = React.forwardRef<
  React.ElementRef<typeof SheetPrimitive.Title>,
  React.ComponentPropsWithoutRef<typeof SheetPrimitive.Title>
>(({ className, ...props }, ref) => (
  <SheetPrimitive.Title
    ref={ref}
    className={cn('text-lg font-semibold text-foreground', className)}
    {...props}
  />
))
BottomSheetTitle.displayName = 'BottomSheetTitle'

const BottomSheetDescription = React.forwardRef<
  React.ElementRef<typeof SheetPrimitive.Description>,
  React.ComponentPropsWithoutRef<typeof SheetPrimitive.Description>
>(({ className, ...props }, ref) => (
  <SheetPrimitive.Description
    ref={ref}
    className={cn('text-sm text-muted-foreground', className)}
    {...props}
  />
))
BottomSheetDescription.displayName = 'BottomSheetDescription'

const BottomSheetFooter = ({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) => (
  <div
    className={cn(
      'flex flex-col gap-2 px-4 py-4 mt-auto border-t border-border bg-background',
      className
    )}
    {...props}
  />
)
BottomSheetFooter.displayName = 'BottomSheetFooter'

export {
  BottomSheet,
  BottomSheetPortal,
  BottomSheetOverlay,
  BottomSheetTrigger,
  BottomSheetClose,
  BottomSheetContent,
  BottomSheetHeader,
  BottomSheetFooter,
  BottomSheetTitle,
  BottomSheetDescription,
}
