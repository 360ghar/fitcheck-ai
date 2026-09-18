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

    // Generations explorer: switch to the Items tab (URL state), then open
    // the full-page viewer for the batch extraction run.
    await page.getByRole('tab', { name: 'Items' }).click()
    await expect(page).toHaveURL(/gen_tab=item/)
    await page.getByRole('button', { name: 'Open batch', exact: true }).click()
    await expect(page).toHaveURL(/\/users\/user_3\/generations\/item\/job_1$/)
    // Title is the page h1; the extracted-items section is asserted through
    // its list row. (A plain li has no accessible name in Chromium, so a
    // getByRole name filter never matches — scope structurally instead. The
    // 'Extracted items' CardTitle is a div and the label echoes in the meta
    // rows, so neither bare text nor heading works for the section.)
    await expect(page.getByRole('heading', { name: 'batch' })).toBeVisible()
    await expect(page.locator('li', { hasText: 'Linen Shirt' })).toContainText('Linen Shirt')

    // Back to the detail page for the rest of the journey.
    await page.goBack()
    // Anchored: the viewer URL (/users/user_3/generations/...) contains the
    // same substring, so an unanchored match would pass even when goBack()
    // never leaves the viewer.
    await expect(page).toHaveURL(/\/users\/user_3(\?|$)/)

    // Suspend flow: confirm dialog → success toast.
    await page.getByRole('button', { name: 'Suspend user', exact: true }).click()
    const dialog = page.getByRole('dialog')
    await expect(dialog.getByRole('heading', { name: 'Suspend this user?' })).toBeVisible()
    await dialog.getByRole('button', { name: 'Suspend user', exact: true }).click()
    await expect(page.getByText('Carol Example was suspended')).toBeVisible()
  })
})
