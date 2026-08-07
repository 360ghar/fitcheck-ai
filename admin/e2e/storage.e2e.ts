import { expect, test } from '@playwright/test'

import { authedPage } from './helpers'

/**
 * Journey 6 (spec §10): storage inventory → temp-file cleanup confirm flow →
 * success toast with the deleted count / freed bytes.
 */

test.describe('storage', () => {
  test('confirms temp-file cleanup and shows the success toast', async ({ page }) => {
    await authedPage(page)
    await page.goto('/storage')

    // Inventory metrics + rows from the fixture.
    await expect(page.getByText('Temp objects')).toBeVisible()
    await expect(page.getByText('12', { exact: true }).first()).toBeVisible()
    await expect(page.getByText('preview/tmp/oldest.jpg')).toBeVisible()

    // Cleanup confirm flow.
    await page.getByRole('button', { name: 'Clean temp files' }).click()
    const dialog = page.getByRole('dialog')
    await expect(dialog.getByRole('heading', { name: 'Clean temp files' })).toBeVisible()
    await dialog.getByRole('button', { name: 'Clean 12 files' }).click()

    // Success toast: 12 objects deleted, 3.3 MB freed (formatBytes, 1024-based).
    await expect(page.getByText('Deleted 12 objects and freed 3.3 MB.')).toBeVisible()
  })
})
