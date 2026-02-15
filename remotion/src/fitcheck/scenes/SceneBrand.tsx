import { Img, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { assets } from '../assets'
import { colors } from '../theme'
import { fonts } from '../typography'

export const SceneBrand = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const logoScale = spring({
    frame,
    fps,
    config: { damping: 200 },
  })

  const textEnter = spring({
    frame: frame - 8,
    fps,
    config: { damping: 200 },
  })

  const logoY = interpolate(logoScale, [0, 1], [40, 0])
  const textY = interpolate(textEnter, [0, 1], [30, 0])
  const glowOpacity = interpolate(frame, [0, 40], [0, 1], {
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
        }}
      >
        <div
          style={{
            position: 'relative',
            width: 280,
            height: 280,
            marginBottom: 40,
            transform: `translateY(${logoY}px) scale(${logoScale})`,
          }}
        >
          <div
            style={{
              position: 'absolute',
              inset: -40,
              background:
                'radial-gradient(circle, rgba(110,107,255,0.6), rgba(110,107,255,0))',
              opacity: glowOpacity,
              filter: 'blur(8px)',
            }}
          />
          <div
            style={{
              position: 'absolute',
              inset: 0,
              borderRadius: '50%',
              background:
                'linear-gradient(140deg, rgba(255,255,255,0.28), rgba(255,255,255,0.06))',
              border: '1px solid rgba(255,255,255,0.25)',
              boxShadow: '0 35px 80px rgba(12, 12, 30, 0.6)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Img
              src={assets.logo}
              style={{
                width: 190,
                height: 190,
                borderRadius: '50%',
              }}
            />
          </div>
        </div>
        <div
          style={{
            textAlign: 'center',
            transform: `translateY(${textY}px)`,
          }}
        >
          <div
            style={{
              fontFamily: fonts.display,
              fontSize: 96,
              color: colors.ink,
              letterSpacing: 0.5,
            }}
          >
            FitCheck AI
          </div>
          <div
            style={{
              fontFamily: fonts.body,
              fontSize: 32,
              color: colors.muted,
              marginTop: 16,
            }}
          >
            Your AI-Powered Virtual Closet
          </div>
          <div
            style={{
              fontFamily: fonts.body,
              fontSize: 20,
              color: colors.subtle,
              letterSpacing: 4,
              textTransform: 'uppercase',
              marginTop: 18,
            }}
          >
            Organize · Style · Try-On
          </div>
        </div>
      </div>
    </SceneShell>
  )
}
