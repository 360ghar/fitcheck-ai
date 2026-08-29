export async function copyTextToClipboard(text: string): Promise<void> {
  if (navigator.clipboard?.writeText) {
    try {
      await navigator.clipboard.writeText(text)
      return
    } catch {
      // Browser permissions can reject this API. Use the selection fallback.
    }
  }

  const activeElement = document.activeElement instanceof HTMLElement
    ? document.activeElement
    : null
  const textarea = document.createElement('textarea')
  textarea.value = text
  textarea.readOnly = true
  textarea.setAttribute('aria-hidden', 'true')
  textarea.style.position = 'fixed'
  textarea.style.opacity = '0'
  textarea.style.pointerEvents = 'none'
  document.body.appendChild(textarea)

  let copied = false
  try {
    textarea.select()
    textarea.setSelectionRange(0, textarea.value.length)
    copied = typeof document.execCommand === 'function' && document.execCommand('copy')
  } finally {
    textarea.remove()
    activeElement?.focus()
  }
  if (!copied) throw new Error('The text could not be copied')
}
