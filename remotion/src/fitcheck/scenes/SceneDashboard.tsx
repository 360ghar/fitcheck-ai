import { interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion'
import { SceneShell } from '../components/SceneShell'
import { PhoneFrame } from '../components/PhoneFrame'
import { TitleBlock } from '../components/TitleBlock'
import { assets } from '../assets'

export const SceneDashboard = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const enter = spring({
    frame: frame - 6,
    fps,
    config: { damping: 200 },
  })

  const mainY = interpolate(enter, [0, 1], [140, 10])
  const secondaryX = interpolate(enter, [0, 1], [260, 200])
  const secondaryY = interpolate(enter, [0, 1], [60, 90])

  return (
    <SceneShell>
      <div style={{ position: 'absolute', inset: 96 }}>
        <div
          style={{
            position: 'absolute',
            right: 0,
            top: 70,
            zIndex: 3,
          }}
        >
          <TitleBlock
            kicker="DAILY FLOW"
            title="Track progress. Build streaks."
            subtitle="Quick actions, outfit planning, and progress insights in one view."
            maxWidth={440}
            align="right"
          />
        </div>
        <PhoneFrame
          src={assets.home}
          x={-240}
          y={240 + mainY}
          rotate={2}
          zIndex={1}
        />
        <PhoneFrame
          src={assets.profile}
          width={380}
          x={secondaryX}
          y={secondaryY}
          rotate={-6}
          scale={0.92}
          zIndex={2}
        />
      </div>
    </SceneShell>
  )
}
