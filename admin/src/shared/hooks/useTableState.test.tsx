import { act, renderHook } from '@testing-library/react'
import type { ReactNode } from 'react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { useTableState } from './useTableState'

function wrapper({ children }: { children: ReactNode }) {
  return (
    <MemoryRouter initialEntries={['/table?page=2&sortBy=name&sortDir=desc&q=shirt&status=active&tab=keep']}>
      <Routes>
        <Route path="/table" element={children} />
      </Routes>
    </MemoryRouter>
  )
}

describe('useTableState', () => {
  it('parses page/pageSize/sort/q/filters from the URL', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status'] }), { wrapper })
    expect(result.current.page).toBe(2)
    expect(result.current.pageSize).toBe(20)
    expect(result.current.sortBy).toBe('name')
    expect(result.current.sortDir).toBe('desc')
    expect(result.current.q).toBe('shirt')
    expect(result.current.filters.status).toBe('active')
    expect(result.current.params).toEqual({
      page: 2,
      page_size: 20,
      q: 'shirt',
      sort_by: 'name',
      sort_dir: 'desc',
      filters: { status: 'active' },
    })
  })

  it('setPage updates the URL without clobbering unrelated params', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status'] }), { wrapper })
    act(() => result.current.setPage(3))
    expect(result.current.page).toBe(3)
    expect(result.current.searchParams.get('tab')).toBe('keep')
    expect(result.current.searchParams.get('q')).toBe('shirt')
    // params object stays in sync
    expect(result.current.params.page).toBe(3)
  })

  it('setSort updates sortBy/sortDir and resets page', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status'] }), { wrapper })
    act(() => result.current.setSort({ id: 'created_at', desc: true }))
    expect(result.current.sortBy).toBe('created_at')
    expect(result.current.sortDir).toBe('desc')
    expect(result.current.page).toBe(1)
    expect(result.current.searchParams.get('tab')).toBe('keep')

    act(() => result.current.setSort(null))
    expect(result.current.sortBy).toBeUndefined()
    expect(result.current.sortDir).toBeUndefined()
  })

  it('setQ sets the search param and resets page', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status'] }), { wrapper })
    act(() => result.current.setQ('jeans'))
    expect(result.current.q).toBe('jeans')
    expect(result.current.page).toBe(1)
    act(() => result.current.setQ(''))
    expect(result.current.q).toBe('')
  })

  it('setFilter sets/deletes extra filter keys and resets page', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status', 'plan'] }), {
      wrapper,
    })
    act(() => result.current.setFilter('plan', 'pro'))
    expect(result.current.filters.plan).toBe('pro')
    expect(result.current.searchParams.get('tab')).toBe('keep')
    act(() => result.current.setFilter('plan', undefined))
    expect(result.current.filters.plan).toBeUndefined()
    expect(result.current.searchParams.get('plan')).toBeNull()
  })

  it('reset clears managed params only', () => {
    const { result } = renderHook(() => useTableState({ filterKeys: ['status'] }), { wrapper })
    act(() => result.current.reset())
    expect(result.current.page).toBe(1)
    expect(result.current.sortBy).toBeUndefined()
    expect(result.current.q).toBe('')
    expect(result.current.filters.status).toBeUndefined()
    expect(result.current.searchParams.get('tab')).toBe('keep')
  })

  it('round-trips: a fresh mount re-parses the exact URL the setters wrote', () => {
    const { result, unmount } = renderHook(() => useTableState({ filterKeys: ['status'] }), {
      wrapper,
    })
    act(() => result.current.setSort({ id: 'name', desc: false }))
    act(() => result.current.setPage(4))
    // The written URL must fully encode the table state (source of truth).
    const url = result.current.searchParams.toString()
    expect(url).toContain('sortBy=name')
    expect(url).toContain('sortDir=asc')
    expect(url).toContain('page=4')
    unmount()

    function remountWrapper({ children }: { children: ReactNode }) {
      return (
        <MemoryRouter initialEntries={[`/table?${url}`]}>
          <Routes>
            <Route path="/table" element={children} />
          </Routes>
        </MemoryRouter>
      )
    }
    const { result: fresh } = renderHook(
      () => useTableState({ filterKeys: ['status'] }),
      { wrapper: remountWrapper },
    )
    expect(fresh.current.page).toBe(4)
    expect(fresh.current.sortBy).toBe('name')
    expect(fresh.current.sortDir).toBe('asc')
    expect(fresh.current.q).toBe('shirt')
    expect(fresh.current.filters.status).toBe('active')
  })
})
