import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig } from 'remotion'
import { colors, gradients } from '../theme'

export const Background = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()
  const drift = Math.sin(frame / fps / 2) * 24
  const driftSlow = Math.sin(frame / fps / 3 + 1.4) * 18
  const gridOpacity = interpolate(frame, [0, 30], [0, 0.2], {
    extrapolateRight: 'clamp',
  })

  return (
    <AbsoluteFill
      style={{
        background: gradients.base,
        overflow: 'hidden',
        color: colors.ink,
      }}
    >
      <div
        style={{
          position: 'absolute',
          width: 900,
          height: 900,
          left: -200 + drift,
          top: -220,
          background: 'radial-gradient(circle, rgba(110,107,255,0.6), rgba(110,107,255,0))',
          filter: 'blur(10px)',
          opacity: 0.9,
        }}
      />
      <div
        style={{
          position: 'absolute',
          width: 720,
          height: 720,
          right: -200,
          top: 80 + driftSlow,
          background: 'radial-gradient(circle, rgba(246,199,165,0.45), rgba(246,199,165,0))',
          filter: 'blur(10px)',
          opacity: 0.8,
        }}
      />
      <div
        style={{
          position: 'absolute',
          width: 780,
          height: 780,
          left: -120,
          bottom: -320 + drift,
          background: 'radial-gradient(circle, rgba(138,227,255,0.35), rgba(138,227,255,0))',
          filter: 'blur(12px)',
          opacity: 0.7,
        }}
      />
      <div
        style={{
          position: 'absolute',
          inset: 0,
          backgroundImage:
            'radial-gradient(circle at 1px 1px, rgba(255,255,255,0.07) 1px, transparent 0)',
          backgroundSize: '44px 44px',
          opacity: gridOpacity,
          mixBlendMode: 'screen',
        }}
      />
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'radial-gradient(circle at center, rgba(0,0,0,0) 40%, rgba(7,7,12,0.7) 90%)',
        }}
      />
    </AbsoluteFill>
  )
}
