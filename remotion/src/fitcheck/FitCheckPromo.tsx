import { TransitionSeries, linearTiming } from '@remotion/transitions'
import { fade } from '@remotion/transitions/fade'
import {
  CTA_DURATION,
  FITCHECK_DURATION_IN_FRAMES,
  SCENE_DURATION,
  TRANSITION_DURATION,
} from './constants'
import { SceneBrand } from './scenes/SceneBrand'
import { SceneHero } from './scenes/SceneHero'
import { SceneWardrobe } from './scenes/SceneWardrobe'
import { ScenePhotoshoot } from './scenes/ScenePhotoshoot'
import { SceneTryOn } from './scenes/SceneTryOn'
import { SceneDashboard } from './scenes/SceneDashboard'
import { SceneCTA } from './scenes/SceneCTA'

const SCENES = [
  { component: SceneBrand, durationInFrames: SCENE_DURATION },
  { component: SceneHero, durationInFrames: SCENE_DURATION },
  { component: SceneWardrobe, durationInFrames: SCENE_DURATION },
  { component: ScenePhotoshoot, durationInFrames: SCENE_DURATION },
  { component: SceneTryOn, durationInFrames: SCENE_DURATION },
  { component: SceneDashboard, durationInFrames: SCENE_DURATION },
  { component: SceneCTA, durationInFrames: CTA_DURATION },
] as const

export const FitCheckPromo = () => {
  return (
    <TransitionSeries>
      {SCENES.flatMap((scene, i) => {
        const children: React.ReactElement[] = [
          <TransitionSeries.Sequence
            key={`seq-${i}`}
            durationInFrames={scene.durationInFrames}
            premountFor={TRANSITION_DURATION}
          >
            <scene.component />
          </TransitionSeries.Sequence>,
        ]
        if (i < SCENES.length - 1) {
          children.push(
            <TransitionSeries.Transition
              key={`trans-${i}`}
              presentation={fade()}
              timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
            />
          )
        }
        return children
      })}
    </TransitionSeries>
  )
}

export { FITCHECK_DURATION_IN_FRAMES }
