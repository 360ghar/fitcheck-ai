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

export const FitCheckPromo = () => {
  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <SceneBrand />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <SceneHero />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <SceneWardrobe />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <ScenePhotoshoot />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <SceneTryOn />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION} premountFor={30}>
        <SceneDashboard />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={CTA_DURATION} premountFor={30}>
        <SceneCTA />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  )
}

export { FITCHECK_DURATION_IN_FRAMES }
