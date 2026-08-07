import { expect, test } from '@playwright/test'

import { mockApi } from './helpers'

/**
 * Journey 1+2 (spec §10): login success renders the dashboard metric cards;
 * invalid credentials surface the error banner and stay on /login.
 */

test.describe('auth', () => {
  test('signs in and renders dashboard metric cards', async ({ page }) => {
    await mockApi(page)
    await page.goto('/login')

    await page.getByLabel('Email').fill('admin@fitcheckaiapp.com')
    await page.getByLabel('Password').fill('correct-horse')
    await page.getByRole('button', { name: 'Sign in' }).click()

    await expect(page).toHaveURL(/\/dashboard$/)
    // Metric cards from the overview fixture.
    await expect(page.getByText('Signups (7 days)')).toBeVisible()
    await expect(page.getByText('Signups (30 days)')).toBeVisible()
    await expect(page.getByText('Paid subscriptions')).toBeVisible()
    await expect(page.getByText('AI jobs (7 days)')).toBeVisible()
    // Fixture values: 42 signups (7d), 47 paid subscriptions.
    await expect(page.getByText('42', { exact: true }).first()).toBeVisible()
    await expect(page.getByText('47', { exact: true })).toBeVisible()
  })

  test('shows an error banner for invalid credentials', async ({ page }) => {
    await mockApi(page)
    await page.goto('/login')

    await page.getByLabel('Email').fill('admin@fitcheckaiapp.com')
    await page.getByLabel('Password').fill('wrong-password')
    await page.getByRole('button', { name: 'Sign in' }).click()

    await expect(page.getByRole('alert')).toContainText(
      'Incorrect email or password. Try again.',
    )
    // Still on the login screen.
    await expect(page.getByRole('button', { name: 'Sign in' })).toBeVisible()
    await expect(page).toHaveURL(/\/login/)
  })

  test('signs out from the account menu back to /login', async ({ page }) => {
    await mockApi(page)
    await page.goto('/login')
    await page.getByLabel('Email').fill('admin@fitcheckaiapp.com')
    await page.getByLabel('Password').fill('correct-horse')
    await page.getByRole('button', { name: 'Sign in' }).click()
    await expect(page).toHaveURL(/\/dashboard$/)

    await page.getByRole('button', { name: 'Account menu' }).click()
    await page.getByRole('menuitem', { name: 'Sign out' }).click()
    await expect(page).toHaveURL(/\/login/)
  })
})
