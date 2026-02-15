import { interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { PhoneFrame } from '../components/PhoneFrame'
import { TitleBlock } from '../components/TitleBlock'
import { assets } from '../assets'

export const SceneHero = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const textIn = spring({
    frame: frame - 6,
    fps,
    config: { damping: 200 },
  })
  const phoneIn = spring({
    frame: frame - 12,
    fps,
    config: { damping: 180 },
  })

  const textOpacity = interpolate(textIn, [0, 1], [0, 1], {
    extrapolateRight: 'clamp',
  })
  const phoneY = interpolate(phoneIn, [0, 1], [120, 0])
  const phoneRotate = interpolate(phoneIn, [0, 1], [-5, -2])

  return (
    <SceneShell>
      <div style={{ position: 'absolute', inset: 96 }}>
        <div
          style={{
            position: 'absolute',
            left: 0,
            top: 70,
            opacity: textOpacity,
            zIndex: 3,
          }}
        >
          <TitleBlock
            kicker="AI WARDROBE"
            title="Your closet, curated in seconds."
            subtitle="Organize every item and plan looks with precision AI guidance."
            maxWidth={440}
          />
        </div>
        <PhoneFrame
          src={assets.landing}
          x={240}
          y={220 + phoneY}
          rotate={phoneRotate}
          scale={1}
          zIndex={1}
        />
      </div>
    </SceneShell>
  )
}
