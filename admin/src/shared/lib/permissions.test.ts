import { describe, expect, it } from 'vitest'

import { can, ROLE_PERMISSIONS, roleCan, type AdminRole } from './permissions'

/**
 * Vocabulary must match `backend/app/core/permissions.py` EXACTLY
 * (endpoint → permission map, surfaced via GET /api/v1/admin/me).
 */
describe('can', () => {
  it('treats * as granting everything', () => {
    expect(can(['*'], 'users.write')).toBe(true)
    expect(can(['*'], ['audit.read', 'storage.cleanup'])).toBe(true)
  })

  it('checks single permissions', () => {
    expect(can(['users.read', 'audit.read'], 'users.read')).toBe(true)
    expect(can(['audit.read'], 'users.read')).toBe(false)
  })

  it('checks any-of lists', () => {
    expect(can(['audit.read'], ['users.read', 'audit.read'])).toBe(true)
    expect(can(['storage.cleanup'], ['users.read', 'audit.read'])).toBe(false)
  })

  it('handles null/empty permission lists', () => {
    expect(can(null, 'users.read')).toBe(false)
    expect(can(undefined, 'users.read')).toBe(false)
    expect(can([], 'users.read')).toBe(false)
  })
})

describe('roleCan (mirror of backend ROLE_PERMISSIONS)', () => {
  it('super_admin and admin grant everything', () => {
    expect(roleCan('super_admin', 'anything.at.all')).toBe(true)
    expect(roleCan('admin', 'anything.at.all')).toBe(true)
  })

  it('ops has operational + read permissions but no content write', () => {
    expect(roleCan('ops', 'users.read')).toBe(true)
    expect(roleCan('ops', 'users.write')).toBe(true)
    expect(roleCan('ops', 'storage.cleanup')).toBe(true)
    expect(roleCan('ops', 'audit.read')).toBe(true)
    expect(roleCan('ops', 'subscriptions.refund')).toBe(true)
    expect(roleCan('ops', 'content.write')).toBe(false)
  })

  it('support is scoped to users/subscriptions/feedback/quotas + audit read', () => {
    expect(roleCan('support', 'users.read')).toBe(true)
    expect(roleCan('support', 'users.write')).toBe(true)
    expect(roleCan('support', 'subscriptions.read')).toBe(true)
    expect(roleCan('support', 'feedback.write')).toBe(true)
    expect(roleCan('support', 'quotas.read')).toBe(true)
    // backend grants audit.read to support (mirrors core/permissions.py)
    expect(roleCan('support', 'audit.read')).toBe(true)
    expect(roleCan('support', 'subscriptions.refund')).toBe(false)
    expect(roleCan('support', 'storage.cleanup')).toBe(false)
  })

  it('content_editor is scoped to content + promo read', () => {
    expect(roleCan('content_editor', 'content.read')).toBe(true)
    expect(roleCan('content_editor', 'content.write')).toBe(true)
    expect(roleCan('content_editor', 'promo.read')).toBe(true)
    expect(roleCan('content_editor', 'users.read')).toBe(false)
    expect(roleCan('content_editor', 'dashboards.read')).toBe(true)
  })

  it('rejects unknown/absent roles', () => {
    expect(roleCan('user', 'users.read')).toBe(false)
    expect(roleCan(undefined, 'users.read')).toBe(false)
    expect(roleCan(null, 'users.read')).toBe(false)
  })

  it('every admin role is present in the registry', () => {
    const roles: AdminRole[] = ['super_admin', 'admin', 'ops', 'support', 'content_editor']
    for (const role of roles) {
      expect(ROLE_PERMISSIONS[role]).toBeDefined()
      expect(ROLE_PERMISSIONS[role].length).toBeGreaterThan(0)
    }
  })
})
