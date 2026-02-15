import { interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { PhoneFrame } from '../components/PhoneFrame'
import { TitleBlock } from '../components/TitleBlock'
import { LabelPill } from '../components/LabelPill'
import { assets } from '../assets'

export const SceneTryOn = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const enter = spring({
    frame: frame - 6,
    fps,
    config: { damping: 200 },
  })

  const phoneY = interpolate(enter, [0, 1], [140, 10])
  const textOpacity = interpolate(enter, [0, 1], [0, 1], {
    extrapolateRight: 'clamp',
  })
  const floatA = Math.sin(frame / fps / 2) * 14
  const floatB = Math.sin(frame / fps / 2 + 1.1) * 12
  const floatC = Math.sin(frame / fps / 2 + 2.3) * 10

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
            kicker="VIRTUAL TRY-ON"
            title="See the fit before you commit."
            subtitle="Preview outfits with AI-powered styling controls."
            maxWidth={440}
          />
        </div>
        <PhoneFrame
          src={assets.tryOn}
          x={230}
          y={220 + phoneY}
          rotate={-3}
          zIndex={1}
        />
        <div
          style={{
            position: 'absolute',
            right: 0,
            top: 520,
            display: 'grid',
            gap: 12,
            zIndex: 3,
          }}
        >
          <div style={{ transform: `translateY(${floatA}px)` }}>
            <LabelPill text="Style presets" />
          </div>
          <div style={{ transform: `translateY(${floatB}px)` }}>
            <LabelPill text="Studio backgrounds" />
          </div>
          <div style={{ transform: `translateY(${floatC}px)` }}>
            <LabelPill text="Pose control" />
          </div>
        </div>
      </div>
    </SceneShell>
  )
}
