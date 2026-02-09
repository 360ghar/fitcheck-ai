import type { ReactNode } from 'react'
import { AbsoluteFill } from 'remotion'
import { Background } from './Background'

type SceneShellProps = {
  children: ReactNode
}

export const SceneShell = ({ children }: SceneShellProps) => {
  return (
    <AbsoluteFill>
      <Background />
      {children}
    </AbsoluteFill>
  )
}
