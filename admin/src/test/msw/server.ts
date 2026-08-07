import { setupServer } from 'msw/node'

import { handlers } from './handlers'

/**
 * MSW server for Vitest — intercepts fetch at the network layer, so
 * components and stores exercise the real client code path. Tests never hit
 * the real network (spec §10).
 */
export const server = setupServer(...handlers)
