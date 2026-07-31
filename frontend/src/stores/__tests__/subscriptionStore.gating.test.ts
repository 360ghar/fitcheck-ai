import { describe, it, expect } from 'vitest'
import { selectCanUpgrade, selectIsPro } from '@/stores/subscriptionStore'

const s = (plan_type: string) => ({ subscription: { plan_type } }) as never

describe('plan gating for the middle tier', () => {
  it('treats Plus as paid AND still upgradeable', () => {
    expect(selectIsPro(s('plus_monthly'))).toBe(true)
    expect(selectCanUpgrade(s('plus_monthly'))).toBe(true)
    expect(selectIsPro(s('plus_yearly'))).toBe(true)
    expect(selectCanUpgrade(s('plus_yearly'))).toBe(true)
  })
  it('offers no further upgrade to Pro users', () => {
    expect(selectCanUpgrade(s('pro_monthly'))).toBe(false)
    expect(selectCanUpgrade(s('pro_yearly'))).toBe(false)
  })
  it('treats Free as unpaid and upgradeable', () => {
    expect(selectIsPro(s('free'))).toBe(false)
    expect(selectCanUpgrade(s('free'))).toBe(true)
  })
})
