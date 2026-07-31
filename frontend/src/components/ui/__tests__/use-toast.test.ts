import { describe, it, expect } from 'vitest'
import { reducer, type Action, type State } from '@/components/ui/use-toast'

const initial: State = { toasts: [] }

function addToast(
  patch: {
    id?: string
    title?: string
    description?: string
    variant?: 'default' | 'destructive' | null
    open?: boolean
  } = {}
): Action {
  return {
    type: 'ADD_TOAST',
    toast: {
      id: patch.id ?? `t-${Math.random().toString(36).slice(2)}`,
      title: 'Same title',
      description: 'Same description',
      variant: 'destructive',
      open: true,
      ...patch,
    },
  }
}

describe('use-toast reducer duplicate suppression', () => {
  it('adds the toast normally when the state is empty', () => {
    const state = reducer(initial, addToast())
    expect(state.toasts).toHaveLength(1)
  })

  it('does not stack a second toast with identical content while the first is open', () => {
    const first = reducer(initial, addToast())
    const second = reducer(first, addToast())
    expect(second.toasts).toHaveLength(1)
  })

  it('keeps toasts with different content separate', () => {
    const first = reducer(initial, addToast())
    const second = reducer(first, addToast({ description: 'A different message' }))
    expect(second.toasts).toHaveLength(2)
  })

  it('keeps toasts with identical content but a different variant separate', () => {
    const first = reducer(initial, addToast({ variant: 'default' }))
    const second = reducer(first, addToast({ variant: 'destructive' }))
    expect(second.toasts).toHaveLength(2)
  })

  it('allows the same content again once the original has been dismissed', () => {
    const first = reducer(initial, addToast())
    const dismissed = reducer(first, {
      type: 'DISMISS_TOAST',
      toastId: first.toasts[0].id,
    })
    expect(dismissed.toasts[0].open).toBe(false)

    const again = reducer(dismissed, addToast())
    expect(again.toasts).toHaveLength(2)
  })

  it('still enforces the toast limit for distinct toasts', () => {
    let state = initial
    for (let i = 0; i < 8; i++) {
      state = reducer(state, addToast({ id: `t-${i}`, title: `Title ${i}` }))
    }
    expect(state.toasts).toHaveLength(5)
  })
})