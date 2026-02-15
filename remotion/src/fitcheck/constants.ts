export const VIDEO = {
  width: 1080,
  height: 1920,
  fps: 30,
}

export const SCENE_DURATION = 90
export const CTA_DURATION = 75
export const TRANSITION_DURATION = 15
export const SCENE_COUNT = 6

export const FITCHECK_DURATION_IN_FRAMES =
  SCENE_DURATION * SCENE_COUNT + CTA_DURATION - TRANSITION_DURATION * SCENE_COUNT

export const PHONE_WIDTH = 640
export const PHONE_HEIGHT = Math.round(PHONE_WIDTH * (1204 / 540))
