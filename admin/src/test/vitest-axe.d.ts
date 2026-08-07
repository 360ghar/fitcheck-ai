import type { AxeMatchers } from 'vitest-axe'

/**
 * vitest-axe ships a `declare global` augmentation for the legacy `Vi`
 * namespace, which vitest 3.x no longer uses — without this local module
 * augmentation, `expect(container).toHaveNoViolations()` compiles but loses
 * its type. Runtime registration happens in src/test/setup.ts
 * (`expect.extend(axeMatchers)`).
 */
/* eslint-disable @typescript-eslint/no-empty-object-type, @typescript-eslint/no-explicit-any, @typescript-eslint/no-unused-vars */
declare module 'vitest' {
  interface Assertion<T = any> extends AxeMatchers {}
  interface AsymmetricMatchersContaining extends AxeMatchers {}
}
