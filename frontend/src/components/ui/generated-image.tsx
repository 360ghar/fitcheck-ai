import type { ImgHTMLAttributes, ReactEventHandler } from 'react'

/** What to hide when a generated-asset image fails to load. */
export type GeneratedImageFallback = 'hide-self' | 'hide-parent' | 'hide-figure'

export interface GeneratedImageProps extends ImgHTMLAttributes<HTMLImageElement> {
  /**
   * Default `'hide-self'` (hides the `<img>`). `'hide-parent'` hides the
   * wrapping frame, `'hide-figure'` hides the enclosing `<figure>`.
   */
  fallback?: GeneratedImageFallback
}

/**
 * Image with a built-in broken-asset fallback for the `public/generated` set.
 * Generated art lands separately from code; until an asset exists the chosen
 * target hides itself instead of showing a broken-image glyph.
 */
export function GeneratedImage({ fallback = 'hide-self', onError, ...rest }: GeneratedImageProps) {
  const handleError: ReactEventHandler<HTMLImageElement> = (event) => {
    onError?.(event)
    switch (fallback) {
      case 'hide-parent':
        event.currentTarget.parentElement?.setAttribute('hidden', '')
        break
      case 'hide-figure':
        event.currentTarget.closest('figure')?.setAttribute('hidden', '')
        break
      case 'hide-self':
        event.currentTarget.style.display = 'none'
        break
    }
  }
  return <img {...rest} onError={handleError} />
}
