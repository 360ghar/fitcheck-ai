import { Img } from 'remotion'
import { PHONE_HEIGHT, PHONE_WIDTH } from '../constants'

type PhoneFrameProps = {
  src: string
  width?: number
  x?: number
  y?: number
  rotate?: number
  scale?: number
  opacity?: number
  zIndex?: number
}

export const PhoneFrame = ({
  src,
  width = PHONE_WIDTH,
  x = 0,
  y = 0,
  rotate = 0,
  scale = 1,
  opacity = 1,
  zIndex = 1,
}: PhoneFrameProps) => {
  const height = Math.round(width * (PHONE_HEIGHT / PHONE_WIDTH))

  return (
    <div
      style={{
        position: 'absolute',
        left: '50%',
        top: '50%',
        width,
        height,
        marginLeft: -width / 2,
        marginTop: -height / 2,
        transform: `translate(${x}px, ${y}px) rotate(${rotate}deg) scale(${scale})`,
        opacity,
        zIndex,
      }}
    >
      <div
        style={{
          position: 'absolute',
          inset: 0,
          padding: 12,
          borderRadius: 58,
          background:
            'linear-gradient(145deg, rgba(255,255,255,0.25), rgba(255,255,255,0.05))',
          boxShadow:
            '0 40px 120px rgba(5,5,18,0.65), 0 25px 60px rgba(83, 85, 255, 0.35)',
          border: '1px solid rgba(255,255,255,0.15)',
        }}
      >
        <div
          style={{
            position: 'absolute',
            inset: 6,
            borderRadius: 48,
            overflow: 'hidden',
            background: '#0B0B12',
          }}
        >
          <Img
            src={src}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
            }}
          />
          <div
            style={{
              position: 'absolute',
              inset: 0,
              background:
                'linear-gradient(135deg, rgba(255,255,255,0.18) 0%, rgba(255,255,255,0) 35%)',
              opacity: 0.7,
              mixBlendMode: 'screen',
            }}
          />
        </div>
      </div>
    </div>
  )
}
