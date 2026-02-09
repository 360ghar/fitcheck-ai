import { interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { PhoneFrame } from '../components/PhoneFrame'
import { TitleBlock } from '../components/TitleBlock'
import { assets } from '../assets'
import { colors } from '../theme'
import { fonts } from '../typography'

export const SceneWardrobe = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const enter = spring({
    frame: frame - 6,
    fps,
    config: { damping: 200 },
  })

  const phoneX = interpolate(enter, [0, 1], [-320, -240])
  const phoneY = interpolate(enter, [0, 1], [180, 140])
  const textY = interpolate(enter, [0, 1], [40, 0])

  return (
    <SceneShell>
      <div style={{ position: 'absolute', inset: 96 }}>
        <PhoneFrame
          src={assets.wardrobe}
          x={phoneX}
          y={phoneY}
          rotate={3}
          zIndex={1}
        />
        <div
          style={{
            position: 'absolute',
            right: 0,
            top: 170 + textY,
            maxWidth: 360,
            zIndex: 3,
          }}
        >
          <TitleBlock
            kicker="WARDROBE SNAPSHOT"
            title="Every item, beautifully organized."
            subtitle="Build your digital closet and see your wardrobe at a glance."
            maxWidth={360}
          />
          <div
            style={{
              marginTop: 26,
              display: 'grid',
              gap: 12,
            }}
          >
            {['Add items fast', 'Smart categories', 'Outfit-ready'].map((line) => (
              <div
                key={line}
                style={{
                  fontFamily: fonts.body,
                  fontSize: 22,
                  color: colors.muted,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                }}
              >
                <span
                  style={{
                    width: 8,
                    height: 8,
                    borderRadius: 999,
                    background: colors.accent,
                    boxShadow: '0 0 12px rgba(110,107,255,0.8)',
                  }}
                />
                {line}
              </div>
            ))}
          </div>
        </div>
      </div>
    </SceneShell>
  )
}
