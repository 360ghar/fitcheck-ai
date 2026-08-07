import { expect, test } from '@playwright/test'

import { authedPage } from './helpers'

/**
 * Journey 4 (spec §10): users list → search → open detail → suspend with
 * the confirm dialog → success toast.
 */

test.describe('users', () => {
  test('lists, searches, opens a detail, and suspends via confirmation', async ({ page }) => {
    await authedPage(page)
    await page.goto('/users')

    // List renders both fixture rows.
    await expect(page.getByText('alice@example.com')).toBeVisible()
    await expect(page.getByText('carol@example.com')).toBeVisible()

    // Search narrows the list (debounced 300ms).
    await page.getByRole('searchbox', { name: 'Filter results' }).fill('carol')
    await expect(page.getByText('carol@example.com')).toBeVisible()
    await expect(page.getByText('alice@example.com')).toHaveCount(0)

    // Open the detail page.
    await page.getByRole('link', { name: 'carol@example.com' }).click()
    await expect(page).toHaveURL(/\/users\/user_3$/)
    await expect(page.getByRole('heading', { name: 'Carol Example' })).toBeVisible()

    // Suspend flow: confirm dialog → success toast.
    await page.getByRole('button', { name: 'Suspend user', exact: true }).click()
    const dialog = page.getByRole('dialog')
    await expect(dialog.getByRole('heading', { name: 'Suspend this user?' })).toBeVisible()
    await dialog.getByRole('button', { name: 'Suspend user', exact: true }).click()
    await expect(page.getByText('Carol Example was suspended')).toBeVisible()
  })
})
