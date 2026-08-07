import { expect, test } from '@playwright/test'

import { limitedAdminPage } from './helpers'

/**
 * Journey 3 (spec §10): a signed-in non-admin (support role, no users.read)
 * must hit the typed 403 page on /users — never the data or a silent
 * redirect.
 */

test.describe('role-based access', () => {
  test('blocks a permission-less admin from /users with the 403 page', async ({ page }) => {
    await limitedAdminPage(page)
    await page.goto('/users')

    await expect(
      page.getByRole('heading', { name: 'No access', exact: true }),
    ).toBeVisible()
    await expect(
      page.getByText(
        "You don't have permission to view this page. If you believe this is a mistake, contact an administrator.",
      ),
    ).toBeVisible()
    // The 403 page offers a path back to the dashboard.
    await page.getByRole('button', { name: 'Back to dashboard' }).click()
    await expect(page).toHaveURL(/\/dashboard$/)
  })

  test('allows the same role on a permitted page (feedback)', async ({ page }) => {
    await limitedAdminPage(page)
    await page.goto('/feedback')

    // feedback.read is granted — the data table renders instead of the 403.
    await expect(page.getByText('Trial not activating')).toBeVisible()
    await expect(
      page.getByRole('heading', { name: 'No access', exact: true }),
    ).toHaveCount(0)
  })
})
