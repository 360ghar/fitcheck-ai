/**
 * Scroll to a landing section and move keyboard focus to it so screen-reader
 * and keyboard users land where the viewport went. Shared by the Navbar,
 * Footer, Pricing, and ProofBand same-page anchors.
 */
export function scrollToSectionId(id: string) {
  const el = document.getElementById(id)
  if (!el) return
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  el.scrollIntoView({ behavior: reduced ? 'auto' : 'smooth', block: 'start' })
  if (!el.hasAttribute('tabindex')) el.setAttribute('tabindex', '-1')
  window.setTimeout(() => {
    try {
      el.focus({ preventScroll: true })
    } catch {
      // Focus is a progressive enhancement; a missed focus must not throw.
    }
  }, reduced ? 0 : 350)
}
