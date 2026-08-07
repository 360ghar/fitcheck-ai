import { expect, test } from '@playwright/test'

import { authedPage } from './helpers'

/**
 * Journey 5 (spec §10): refund a subscription — confirm dialog → success
 * toast with the refund id/amount/status.
 */

test.describe('subscriptions', () => {
  test('refunds a subscription after confirmation', async ({ page }) => {
    await authedPage(page)
    await page.goto('/subscriptions')

    // Fixture rows render.
    await expect(page.getByText('alice@example.com')).toBeVisible()
    await expect(page.getByText('carol@example.com')).toBeVisible()

    // Open the refund confirmation.
    await page.getByRole('button', { name: 'Refund' }).first().click()
    const dialog = page.getByRole('dialog')
    await expect(dialog.getByRole('heading', { name: 'Refund subscription' })).toBeVisible()
    await expect(dialog).toContainText('alice@example.com')

    // Confirm → success toast with the refund id from the fixture.
    await dialog.getByRole('button', { name: 'Refund $19.99' }).click()
    await expect(page.getByText('Refund re_e2e_123 issued ($19.99, succeeded).')).toBeVisible()
    // The dialog closes after success.
    await expect(dialog).toHaveCount(0)
  })
})
