import { cn, formatUsd } from '@/lib/utils'
import { giftOccasionGreeting, giftTermLabel, type GiftDuration, type GiftOccasion } from '@/api/gifts'

interface GiftCardPreviewProps {
  fromName: string
  toName: string
  message?: string
  occasion?: GiftOccasion | null
  occasionGreeting?: string | null
  duration: GiftDuration
  retailValueCents: number
  expiresAt?: string
  className?: string
}

export function GiftCardPreview({
  fromName,
  toName,
  message,
  occasion,
  occasionGreeting,
  duration,
  retailValueCents,
  expiresAt,
  className,
}: GiftCardPreviewProps) {
  const greeting = giftOccasionGreeting(occasion, occasionGreeting)
  return (
    <article
      aria-label={`FitCheck Pro gift for ${toName || 'your recipient'}`}
      className={cn(
        'relative aspect-[4/5] w-full overflow-hidden rounded-lg border border-[#d8cfc1] bg-[#f7f2e9] p-[5%] text-[#151411]',
        className,
      )}
    >
      <div className="pointer-events-none absolute inset-0 opacity-40 [background-image:radial-gradient(#d8cfc1_0.65px,transparent_0.65px)] [background-size:5px_5px]" />
      <div className="pointer-events-none absolute -right-[22%] -top-[13%] h-[47%] w-[55%] rounded-full border-[6px] border-[#e00016]" />
      <div className="pointer-events-none absolute -bottom-[14%] -left-[22%] h-[43%] w-[55%] rounded-full border-[6px] border-[#151411]" />

      <div className="relative flex h-full flex-col rounded-md border border-[#d8cfc1] bg-[#fffdf8]/95 p-[8%]">
        <p className="font-display text-[clamp(0.52rem,1.4vw,0.72rem)] font-bold uppercase tracking-[0.26em] text-[#6b655d]">
          FitCheck AI / Private gift
        </p>

        <div className="mt-[11%] font-display text-[clamp(2rem,8.5vw,4.5rem)] font-extrabold leading-[0.82] tracking-[-0.06em]">
          <span className="block">FITCHECK</span>
          <span className="mt-[3%] block text-[#e00016]">PRO</span>
        </div>

        <div className="mt-[11%] border-t border-[#d8cfc1] pt-[8%]">
          {greeting && (
            <p className="mb-[6%] line-clamp-2 font-display text-[clamp(1rem,3.5vw,1.9rem)] font-bold leading-tight tracking-[-0.035em] text-[#e00016]">
              {greeting}
            </p>
          )}
          <p className="text-[clamp(0.5rem,1.4vw,0.7rem)] font-bold uppercase tracking-[0.2em] text-[#6b655d]">
            Created for
          </p>
          <p className="mt-[2%] line-clamp-1 font-display text-[clamp(1.2rem,4.6vw,2.5rem)] font-bold tracking-[-0.035em]">
            {toName || 'Someone special'}
          </p>
          <p className="mt-[6%] text-[clamp(0.5rem,1.4vw,0.7rem)] font-bold uppercase tracking-[0.2em] text-[#6b655d]">
            A gift from
          </p>
          <p className="mt-[1%] line-clamp-1 font-display text-[clamp(0.88rem,2.8vw,1.4rem)] font-semibold">
            {fromName || 'Your name'}
          </p>
        </div>

        {message && (
          <p className="mt-[7%] line-clamp-3 text-[clamp(0.55rem,1.6vw,0.82rem)] leading-relaxed text-[#6b655d]">
            {message}
          </p>
        )}

        <div className="mt-auto flex items-end justify-between gap-3">
          <div className="rounded-sm bg-[#151411] px-[6%] py-[4%] text-[#fffdf8]">
            <p className="font-display text-[clamp(0.7rem,2.1vw,1.05rem)] font-bold uppercase tracking-[0.08em]">
              {giftTermLabel(duration)}
            </p>
            <p className="mt-1 text-[clamp(0.52rem,1.4vw,0.7rem)] text-[#d9d1c6]">
              {formatUsd(retailValueCents)} retail value
            </p>
          </div>
          <div className="grid h-[clamp(3.1rem,10vw,5rem)] w-[clamp(3.1rem,10vw,5rem)] place-items-center border border-[#d8cfc1] bg-[#fffdf8]">
            <span className="font-display text-[clamp(0.55rem,2.2vw,1rem)] font-extrabold tracking-[-0.08em]">
              FC
            </span>
          </div>
        </div>

        <p className="mt-[5%] text-[clamp(0.42rem,1.15vw,0.6rem)] font-bold uppercase tracking-[0.12em] text-[#6b655d]">
          {expiresAt
            ? `Promotional gift · claim by ${new Date(expiresAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}`
            : 'Gift voucher · no expiry before claim'}
        </p>
      </div>
    </article>
  )
}
