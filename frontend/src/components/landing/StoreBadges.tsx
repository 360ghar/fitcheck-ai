import { trackLandingCta } from '@/lib/analytics'
import { PLATFORM_AVAILABILITY } from '@/lib/plan-limits'
import { cn } from '@/lib/utils'

/**
 * Official App Store and Google Play badges, shown unmodified (both stores'
 * brand rules). Files live in /public/badges: Apple's SVG as downloaded, and
 * Google's PNG cropped to the badge edge so both render at the same 40 px
 * height, the App Store minimum.
 */
const BADGES = [
  {
    store: 'app_store',
    href: PLATFORM_AVAILABILITY.iosStoreUrl,
    src: '/badges/app-store.svg',
    alt: 'Download on the App Store',
    width: 120,
  },
  {
    store: 'google_play',
    href: PLATFORM_AVAILABILITY.androidStoreUrl,
    src: '/badges/google-play.png',
    alt: 'Get it on Google Play',
    width: 134,
  },
] as const

export default function StoreBadges({
  location,
  className,
}: {
  location: 'hero' | 'bottom'
  className?: string
}) {
  return (
    <div className={cn('flex flex-wrap items-center gap-3', className)}>
      {BADGES.map((badge) => (
        <a
          key={badge.store}
          href={badge.href}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackLandingCta(location, { store: badge.store })}
          className="rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        >
          <img
            src={badge.src}
            alt={badge.alt}
            width={badge.width}
            height={40}
            className="block h-10 w-auto"
            decoding="async"
          />
        </a>
      ))}
    </div>
  )
}
