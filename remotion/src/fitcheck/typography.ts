import { loadFont as loadPlayfair } from '@remotion/google-fonts/PlayfairDisplay'
import { loadFont as loadManrope } from '@remotion/google-fonts/Manrope'

const playfair = loadPlayfair('normal', {
  weights: ['600', '700'],
  subsets: ['latin'],
})

const manrope = loadManrope('normal', {
  weights: ['400', '500', '600'],
  subsets: ['latin'],
})

export const fonts = {
  display: playfair.fontFamily,
  body: manrope.fontFamily,
}
