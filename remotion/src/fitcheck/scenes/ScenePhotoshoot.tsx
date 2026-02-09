import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { PhoneFrame } from '../components/PhoneFrame'
import { TitleBlock } from '../components/TitleBlock'
import { assets } from '../assets'

export const ScenePhotoshoot = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const enter = spring({
    frame: frame - 8,
    fps,
    config: { damping: 180 },
  })

  const phoneScale = interpolate(enter, [0, 1], [0.92, 1])
  const phoneY = interpolate(enter, [0, 1], [160, 0])
  const flash = interpolate(frame, [4, 10, 16], [0, 0.35, 0], {
    extrapolateRight: 'clamp',
  })

  return (
    <SceneShell>
      <AbsoluteFill
        style={{
          backgroundColor: '#FFFFFF',
          opacity: flash,
          mixBlendMode: 'screen',
          zIndex: 4,
        }}
      />
      <AbsoluteFill
        style={{
          boxShadow: 'inset 0 0 180px rgba(110,107,255,0.25)',
          opacity: 0.6,
          pointerEvents: 'none',
          zIndex: 1,
        }}
      />
      <AbsoluteFill
        style={{
          border: '1px solid rgba(255,255,255,0.08)',
          opacity: 0.6,
          zIndex: 1,
        }}
      />
      <AbsoluteFill
        style={{
          background: 'radial-gradient(circle at 70% 30%, rgba(110,107,255,0.25), transparent 45%)',
          opacity: 0.8,
          zIndex: 1,
        }}
      />
      <AbsoluteFill
        style={{
          background: 'radial-gradient(circle at 35% 60%, rgba(138,227,255,0.2), transparent 50%)',
          opacity: 0.7,
          zIndex: 1,
        }}
      />
      <AbsoluteFill
        style={{
          border: '1px solid rgba(255,255,255,0.08)',
          opacity: 0.4,
          zIndex: 1,
        }}
      />
      <AbsoluteFill
        style={{
          background: 'linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(9,9,16,0.35) 100%)',
          zIndex: 1,
        }}
      />
      <div style={{ position: 'absolute', inset: 96, zIndex: 2 }}>
        <PhoneFrame
          src={assets.photoshoot}
          x={240}
          y={200 + phoneY}
          rotate={-2}
          scale={phoneScale}
          zIndex={1}
        />
        <div
          style={{
            position: 'absolute',
            left: 0,
            top: 70,
            zIndex: 3,
          }}
        >
          <TitleBlock
            kicker="AI PHOTOSHOOT"
            title="Generate fresh looks in minutes."
            subtitle="Upload a few photos and let FitCheck AI create editorial-ready shots."
            maxWidth={440}
          />
        </div>
      </div>
    </SceneShell>
  )
}
