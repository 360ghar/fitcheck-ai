import { expect, test } from '@playwright/test'

import { authedPage } from './helpers'

/**
 * Journeys 7+8 (spec §10): ⌘K command palette opens and navigates to a
 * search hit; the theme toggle persists the dark class on <html> across
 * reloads.
 */

test.describe('command palette', () => {
  test('opens with ⌘K, searches, and navigates to a hit', async ({ page }) => {
    await authedPage(page)
    await page.goto('/dashboard')

    await page.keyboard.press('Meta+K')
    const dialog = page.getByRole('dialog')
    await expect(dialog).toBeVisible()
    await expect(dialog.getByRole('combobox')).toBeFocused()

    await dialog.getByRole('combobox').fill('alice')
    await expect(dialog.getByText('Alice Example')).toBeVisible()
    await expect(dialog.getByText('Users')).toBeVisible()

    await dialog.getByText('Alice Example').click()
    await expect(page).toHaveURL(/\/users\/user_1$/)
    // Palette closes after navigating.
    await expect(dialog).toHaveCount(0)
  })

  test('shows the empty state for an unmatched query', async ({ page }) => {
    await authedPage(page)
    await page.goto('/dashboard')

    await page.keyboard.press('Meta+K')
    const dialog = page.getByRole('dialog')
    await dialog.getByRole('combobox').fill('zz')
    await expect(dialog.getByText('No results found for “zz”.')).toBeVisible()
  })
})

test.describe('theme', () => {
  test('theme toggle persists the dark class on <html>', async ({ page }) => {
    await authedPage(page)
    await page.goto('/dashboard')

    // Headless chromium starts light.
    await expect(page.locator('html')).not.toHaveClass(/dark/)

    await page.getByRole('button', { name: 'Theme' }).click()
    await page.getByRole('menuitemradio', { name: 'Dark' }).click()
    await expect(page.locator('html')).toHaveClass(/dark/)

    // Persisted (localStorage fitcheck-admin-theme) across a reload.
    await page.reload()
    await expect(page.locator('html')).toHaveClass(/dark/)

    // And back to light.
    await page.getByRole('button', { name: 'Theme' }).click()
    await page.getByRole('menuitemradio', { name: 'Light' }).click()
    await expect(page.locator('html')).not.toHaveClass(/dark/)
  })
})
