import { expect, test, type Page } from '@playwright/test'

import { authedPage, mockApi } from './helpers'

/**
 * Mobile-shell journeys (responsive sweep): the admin console is used on
 * phones, so the critical paths must work at a phone viewport with the
 * drawer navigation, the mobile-only search trigger, and the horizontally
 * scrollable DataTable with its pinned identity column.
 *
 * Runs only on the `mobile-chromium` project (iPhone 13, 390×664) —
 * see playwright.config.ts. No document-level horizontal overflow is the
 * core regression guard: the shell must never blow out the page width.
 */

function expectNoDocumentOverflow(page: Page) {
  return expect
    .poll(() =>
      page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth),
    )
    .toBe(true)
}

test.describe('mobile shell', () => {
  test('signs in and renders the dashboard without page overflow', async ({ page }) => {
    await mockApi(page)
    await page.goto('/login')

    await expect(page.getByRole('button', { name: 'Sign in' })).toBeVisible()
    await expectNoDocumentOverflow(page)

    await page.getByLabel('Email').fill('admin@fitcheckaiapp.com')
    await page.getByLabel('Password').fill('correct-horse')
    await page.getByRole('button', { name: 'Sign in' }).click()

    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText('Signups (7 days)')).toBeVisible()
    await expectNoDocumentOverflow(page)

    // Trends charts share the chart-in-grid pattern that blew out the
    // dashboard cards — the same guard must hold on the trends route.
    await page.goto('/dashboard/trends')
    await expect(page.getByRole('img', { name: 'Signups' })).toBeVisible()
    await expectNoDocumentOverflow(page)
  })

  test('navigates via the drawer and the users table scrolls with email pinned', async ({
    page,
  }) => {
    await authedPage(page)
    await page.goto('/dashboard')

    // Desktop sidebar is hidden below lg; the hamburger opens the drawer.
    await page.getByRole('button', { name: 'Open navigation' }).click()
    await page.getByRole('link', { name: 'Users' }).click()
    await expect(page).toHaveURL(/\/users$/)

    // List loads: email column is pinned on mobile.
    await expect(page.getByText('alice@example.com')).toBeVisible()
    await expect(page.getByText('bob@example.com')).toBeVisible()

    // The table is wider than a phone viewport and scrolls inside its
    // container — never the document. Pan it horizontally and report the
    // resulting scroll positions in one evaluate (DOM nodes can't cross).
    const scroll = await page
      .getByRole('table')
      .evaluate((table) => {
        let el = table.parentElement
        while (el && getComputedStyle(el).overflowX === 'visible') {
          el = el.parentElement
        }
        if (!el || el.scrollWidth <= el.clientWidth) {
          return { scrollable: false, containerScrollLeft: 0 }
        }
        el.scrollLeft = 400
        return { scrollable: true, containerScrollLeft: el.scrollLeft }
      })
    expect(scroll.scrollable).toBe(true)
    expect(scroll.containerScrollLeft).toBe(400)

    // The pinned email column stays in view after the container pans.
    await expect(page.getByText('alice@example.com')).toBeInViewport()
    await expectNoDocumentOverflow(page)
  })

  test('mobile search trigger opens the command palette', async ({ page }) => {
    await authedPage(page)
    await page.goto('/dashboard')

    // Desktop input is hidden below sm; the icon trigger takes its place.
    await page.getByRole('button', { name: 'Search' }).click()
    const dialog = page.getByRole('dialog')
    await expect(dialog).toBeVisible()
    await expect(dialog.getByRole('combobox')).toBeFocused()

    await dialog.getByRole('combobox').fill('alice')
    await expect(dialog.getByText('Alice Example')).toBeVisible()
    await dialog.getByText('Alice Example').click()
    await expect(page).toHaveURL(/\/users\/user_1$/)
  })
})
