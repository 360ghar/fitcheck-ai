import { Img, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { assets } from '../assets'
import { fonts } from '../typography'
import { colors } from '../theme'

export const SceneCTA = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const enter = spring({
    frame: frame - 6,
    fps,
    config: { damping: 200 },
  })

  const logoScale = interpolate(enter, [0, 1], [0.9, 1])
  const textOpacity = interpolate(enter, [0, 1], [0, 1], {
    extrapolateRight: 'clamp',
  })

  return (
    <SceneShell>
      <div
        style={{
          position: 'absolute',
          inset: 96,
          alignItems: 'center',
          justifyContent: 'center',
          display: 'flex',
          flexDirection: 'column',
          gap: 24,
        }}
      >
        <div
          style={{
            width: 210,
            height: 210,
            borderRadius: '50%',
            background:
              'linear-gradient(140deg, rgba(255,255,255,0.3), rgba(255,255,255,0.08))',
            border: '1px solid rgba(255,255,255,0.2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 35px 90px rgba(12, 12, 30, 0.65)',
            transform: `scale(${logoScale})`,
          }}
        >
          <Img
            src={assets.logo}
            style={{
              width: 150,
              height: 150,
              borderRadius: '50%',
            }}
          />
        </div>
        <div style={{ textAlign: 'center', opacity: textOpacity }}>
          <div
            style={{
              fontFamily: fonts.display,
              fontSize: 86,
              color: colors.ink,
            }}
          >
            FitCheck AI
          </div>
          <div
            style={{
              fontFamily: fonts.body,
              fontSize: 30,
              color: colors.muted,
              marginTop: 12,
            }}
          >
            Your AI wardrobe, perfected.
          </div>
        </div>
        <div
          style={{
            marginTop: 20,
            padding: '16px 38px',
            borderRadius: 999,
            fontFamily: fonts.body,
            fontSize: 24,
            fontWeight: 600,
            color: colors.ink,
            background:
              'linear-gradient(120deg, rgba(110,107,255,0.95), rgba(138,227,255,0.9))',
            boxShadow: '0 18px 40px rgba(110,107,255,0.45)',
            border: '1px solid rgba(255,255,255,0.2)',
          }}
        >
          Get FitCheck AI
        </div>
        <div
          style={{
            fontFamily: fonts.body,
            fontSize: 18,
            letterSpacing: 3,
            textTransform: 'uppercase',
            color: colors.subtle,
            marginTop: 8,
          }}
        >
          Fitcheckaiapp.com
        </div>
      </div>
    </SceneShell>
  )
}
