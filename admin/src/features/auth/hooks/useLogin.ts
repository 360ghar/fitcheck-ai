import { useMutation } from '@tanstack/react-query'
import type { TFunction } from 'i18next'
import { z } from 'zod'

import { useSessionStore } from '@/shared/stores/sessionStore'

/**
 * Login form contract + mutation. The store performs the actual auth (POST
 * /api/v1/auth/login → bootstrap /admin/me); this hook only wraps it in a
 * mutation so the page can render loading/error states.
 */

export interface LoginFormValues {
  email: string
  password: string
}

/** Zod schema built with i18n messages (no inline literals). */
export function loginSchema(t: TFunction) {
  return z.object({
    email: z
      .string()
      .trim()
      .min(1, t('validation.emailRequired'))
      .email(t('validation.emailInvalid')),
    password: z.string().min(1, t('validation.passwordRequired')),
  })
}

export type LoginSchema = ReturnType<typeof loginSchema>

export function useLogin() {
  return useMutation({
    mutationFn: ({ email, password }: LoginFormValues) =>
      useSessionStore.getState().login(email, password),
  })
}
