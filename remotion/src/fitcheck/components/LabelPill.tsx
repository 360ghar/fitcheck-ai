import { colors } from '../theme'
import { fonts } from '../typography'

type LabelPillProps = {
  text: string
}

export const LabelPill = ({ text }: LabelPillProps) => {
  return (
    <div
      style={{
        padding: '12px 20px',
        borderRadius: 999,
        fontFamily: fonts.body,
        fontSize: 20,
        fontWeight: 500,
        letterSpacing: 0.3,
        color: colors.ink,
        background:
          'linear-gradient(135deg, rgba(110,107,255,0.4), rgba(110,107,255,0.15))',
        border: '1px solid rgba(255,255,255,0.18)',
        boxShadow: '0 10px 24px rgba(9, 9, 20, 0.4)',
        backdropFilter: 'blur(8px)',
      }}
    >
      {text}
    </div>
  )
}
