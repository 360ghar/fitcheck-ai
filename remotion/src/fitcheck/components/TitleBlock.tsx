import { fonts } from '../typography'
import { colors } from '../theme'

type TitleBlockProps = {
  kicker?: string
  title: string
  subtitle?: string
  align?: 'left' | 'center' | 'right'
  maxWidth?: number
}

export const TitleBlock = ({
  kicker,
  title,
  subtitle,
  align = 'left',
  maxWidth = 520,
}: TitleBlockProps) => {
  return (
    <div
      style={{
        maxWidth,
        textAlign: align,
        display: 'flex',
        flexDirection: 'column',
        gap: 16,
      }}
    >
      {kicker ? (
        <div
          style={{
            fontFamily: fonts.body,
            fontSize: 20,
            letterSpacing: 4,
            textTransform: 'uppercase',
            color: colors.subtle,
          }}
        >
          {kicker}
        </div>
      ) : null}
      <div
        style={{
          fontFamily: fonts.display,
          fontSize: 82,
          lineHeight: 1.02,
          color: colors.ink,
        }}
      >
        {title}
      </div>
      {subtitle ? (
        <div
          style={{
            fontFamily: fonts.body,
            fontSize: 30,
            lineHeight: 1.35,
            color: colors.muted,
          }}
        >
          {subtitle}
        </div>
      ) : null}
    </div>
  )
}
