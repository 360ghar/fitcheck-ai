import { Composition, Folder } from 'remotion'
import { FitCheckPromo, FITCHECK_DURATION_IN_FRAMES } from './fitcheck/FitCheckPromo'

export const RemotionRoot = () => {
  return (
    <>
      <Folder name="Marketing">
        <Folder name="Instagram">
          <Composition
            id="FitCheck-Instagram"
            component={FitCheckPromo}
            durationInFrames={FITCHECK_DURATION_IN_FRAMES}
            fps={30}
            width={1080}
            height={1920}
          />
        </Folder>
      </Folder>
    </>
  )
}
