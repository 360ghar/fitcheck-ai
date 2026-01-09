/**
 * Export Service
 *
 * Provides export functionality for wardrobe items, outfits, and lookbooks.
 * Supports PDF generation, image collages, and plain text exports.
 */

import type { Item, Outfit, Category } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export type ExportFormat = 'pdf' | 'html' | 'markdown' | 'json' | 'csv'

export interface ExportOptions {
  format: ExportFormat
  includeImages?: boolean
  includeStats?: boolean
  title?: string
  author?: string
  dateRange?: { start: string; end: string }
}

export interface WardrobeExportData {
  title: string
  exportDate: string
  author?: string
  items: Item[]
  outfits: Outfit[]
  stats: {
    totalItems: number
    totalOutfits: number
    categoryBreakdown: Record<Category, number>
    topColors: { color: string; count: number }[]
    mostWornItems: { item: Item; wearCount: number }[]
    averageWears: number
    totalValue: number
  }
}

export interface LookbookPage {
  title: string
  description?: string
  outfit: Outfit
  items: Item[]
  notes?: string
}

export interface Lookbook {
  title: string
  description?: string
  author?: string
  createdDate: string
  pages: LookbookPage[]
  coverImage?: string
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get base64 from image URL (for embedding in exports).
 */
async function getImageAsBase64(url: string): Promise<string | null> {
  try {
    const response = await fetch(url)
    const blob = await response.blob()
    return new Promise((resolve) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(reader.result as string)
      reader.onerror = () => resolve(null)
      reader.readAsDataURL(blob)
    })
  } catch {
    return null
  }
}

/**
 * Format currency value.
 */
function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(value)
}

/**
 * Format date for display.
 */
function formatDate(date: string | Date): string {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

// ============================================================================
// EXPORT DATA PREPARATION
// ============================================================================

/**
 * Prepare wardrobe data for export.
 */
export function prepareWardrobeExport(
  items: Item[],
  outfits: Outfit[],
  options: { title?: string; author?: string } = {}
): WardrobeExportData {
  // Category breakdown
  const categoryBreakdown: Record<Category, number> = {
    tops: 0,
    bottoms: 0,
    shoes: 0,
    outerwear: 0,
    accessories: 0,
    activewear: 0,
    swimwear: 0,
    other: 0,
  }
  for (const item of items) {
    categoryBreakdown[item.category] = (categoryBreakdown[item.category] || 0) + 1
  }

  // Top colors
  const colorCounts: Record<string, number> = {}
  for (const item of items) {
    for (const color of item.colors) {
      colorCounts[color.toLowerCase()] = (colorCounts[color.toLowerCase()] || 0) + 1
    }
  }
  const topColors = Object.entries(colorCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([color, count]) => ({ color, count }))

  // Most worn items
  const sortedByWear = [...items].sort(
    (a, b) => b.usage_times_worn - a.usage_times_worn
  )
  const mostWornItems = sortedByWear.slice(0, 5).map((item) => ({
    item,
    wearCount: item.usage_times_worn,
  }))

  // Average wears
  const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)
  const averageWears = items.length > 0 ? Math.round(totalWears / items.length) : 0

  // Total value
  const totalValue = items.reduce((sum, i) => sum + (i.purchase_price || 0), 0)

  return {
    title: options.title || 'My Wardrobe',
    exportDate: new Date().toISOString(),
    author: options.author,
    items,
    outfits,
    stats: {
      totalItems: items.length,
      totalOutfits: outfits.length,
      categoryBreakdown,
      topColors,
      mostWornItems,
      averageWears,
      totalValue,
    },
  }
}

// ============================================================================
// MARKDOWN EXPORT
// ============================================================================

/**
 * Export wardrobe to Markdown format.
 */
export function exportToMarkdown(data: WardrobeExportData): string {
  const lines: string[] = []

  // Header
  lines.push(`# ${data.title}`)
  lines.push('')
  lines.push(`Exported on ${formatDate(data.exportDate)}`)
  if (data.author) {
    lines.push(`By ${data.author}`)
  }
  lines.push('')

  // Stats summary
  lines.push('## Wardrobe Summary')
  lines.push('')
  lines.push(`- **Total Items:** ${data.stats.totalItems}`)
  lines.push(`- **Total Outfits:** ${data.stats.totalOutfits}`)
  lines.push(`- **Total Value:** ${formatCurrency(data.stats.totalValue)}`)
  lines.push(`- **Average Wears per Item:** ${data.stats.averageWears}`)
  lines.push('')

  // Category breakdown
  lines.push('### Items by Category')
  lines.push('')
  lines.push('| Category | Count |')
  lines.push('|----------|-------|')
  for (const [category, count] of Object.entries(data.stats.categoryBreakdown)) {
    if (count > 0) {
      lines.push(`| ${category.charAt(0).toUpperCase() + category.slice(1)} | ${count} |`)
    }
  }
  lines.push('')

  // Top colors
  if (data.stats.topColors.length > 0) {
    lines.push('### Top Colors')
    lines.push('')
    data.stats.topColors.forEach(({ color, count }) => {
      lines.push(`- ${color}: ${count} items`)
    })
    lines.push('')
  }

  // Most worn items
  if (data.stats.mostWornItems.length > 0) {
    lines.push('### Most Worn Items')
    lines.push('')
    data.stats.mostWornItems.forEach(({ item, wearCount }, i) => {
      lines.push(`${i + 1}. **${item.name}** - worn ${wearCount} times`)
    })
    lines.push('')
  }

  // Items list
  lines.push('## Wardrobe Items')
  lines.push('')

  const groupedItems = new Map<Category, Item[]>()
  for (const item of data.items) {
    const group = groupedItems.get(item.category) || []
    group.push(item)
    groupedItems.set(item.category, group)
  }

  groupedItems.forEach((items, category) => {
    lines.push(`### ${category.charAt(0).toUpperCase() + category.slice(1)}`)
    lines.push('')
    items.forEach((item) => {
      lines.push(`- **${item.name}**`)
      if (item.brand) lines.push(`  - Brand: ${item.brand}`)
      if (item.colors.length > 0) lines.push(`  - Colors: ${item.colors.join(', ')}`)
      if (item.purchase_price) lines.push(`  - Price: ${formatCurrency(item.purchase_price)}`)
      lines.push(`  - Worn: ${item.usage_times_worn} times`)
    })
    lines.push('')
  })

  // Outfits
  if (data.outfits.length > 0) {
    lines.push('## Outfits')
    lines.push('')
    data.outfits.forEach((outfit) => {
      lines.push(`### ${outfit.name}`)
      if (outfit.description) lines.push(`${outfit.description}`)
      lines.push('')
      if (outfit.style) lines.push(`- Style: ${outfit.style}`)
      if (outfit.season) lines.push(`- Season: ${outfit.season}`)
      if (outfit.occasion) lines.push(`- Occasion: ${outfit.occasion}`)
      lines.push(`- Items: ${outfit.item_ids.length} pieces`)
      lines.push(`- Worn: ${outfit.worn_count} times`)
      lines.push('')
    })
  }

  return lines.join('\n')
}

// ============================================================================
// HTML EXPORT
// ============================================================================

/**
 * Export wardrobe to HTML format (printable).
 */
export async function exportToHTML(
  data: WardrobeExportData,
  options: { includeImages?: boolean } = {}
): Promise<string> {
  const { includeImages = true } = options

  // Prepare image data if needed
  const imageCache = new Map<string, string>()
  if (includeImages) {
    for (const item of data.items.slice(0, 50)) {
      // Limit for performance
      if (item.image_url) {
        const base64 = await getImageAsBase64(item.image_url)
        if (base64) imageCache.set(item.id, base64)
      }
    }
  }

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${data.title}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }
    h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
    h2 { font-size: 1.75rem; margin: 2rem 0 1rem; border-bottom: 2px solid #e5e5e5; padding-bottom: 0.5rem; }
    h3 { font-size: 1.25rem; margin: 1.5rem 0 0.75rem; color: #555; }
    .meta { color: #666; margin-bottom: 2rem; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; margin: 1rem 0; }
    .stat-card {
      background: #f9fafb;
      border-radius: 8px;
      padding: 1rem;
      text-align: center;
      border: 1px solid #e5e5e5;
    }
    .stat-value { font-size: 2rem; font-weight: 700; color: #111; }
    .stat-label { font-size: 0.875rem; color: #666; }
    .items-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; }
    .item-card {
      border: 1px solid #e5e5e5;
      border-radius: 8px;
      overflow: hidden;
      background: #fff;
    }
    .item-image {
      width: 100%;
      height: 150px;
      object-fit: cover;
      background: #f3f4f6;
    }
    .item-info { padding: 0.75rem; }
    .item-name { font-weight: 600; margin-bottom: 0.25rem; }
    .item-meta { font-size: 0.75rem; color: #666; }
    .color-dot {
      display: inline-block;
      width: 12px;
      height: 12px;
      border-radius: 50%;
      margin-right: 4px;
      border: 1px solid #ddd;
    }
    .outfits-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 1rem; }
    .outfit-card {
      border: 1px solid #e5e5e5;
      border-radius: 8px;
      padding: 1rem;
      background: #fff;
    }
    .outfit-name { font-weight: 600; font-size: 1.1rem; }
    .outfit-desc { color: #666; font-size: 0.875rem; margin: 0.5rem 0; }
    .tag {
      display: inline-block;
      background: #e5e5e5;
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
      font-size: 0.75rem;
      margin: 0.25rem 0.25rem 0 0;
    }
    table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
    th, td { padding: 0.5rem; text-align: left; border-bottom: 1px solid #e5e5e5; }
    th { background: #f9fafb; font-weight: 600; }
    @media print {
      body { padding: 0; }
      .item-card, .outfit-card { break-inside: avoid; }
    }
  </style>
</head>
<body>
  <header>
    <h1>${data.title}</h1>
    <p class="meta">
      Exported on ${formatDate(data.exportDate)}
      ${data.author ? ` by ${data.author}` : ''}
    </p>
  </header>

  <section>
    <h2>Wardrobe Summary</h2>
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-value">${data.stats.totalItems}</div>
        <div class="stat-label">Total Items</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${data.stats.totalOutfits}</div>
        <div class="stat-label">Outfits</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${formatCurrency(data.stats.totalValue)}</div>
        <div class="stat-label">Total Value</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${data.stats.averageWears}</div>
        <div class="stat-label">Avg Wears</div>
      </div>
    </div>

    <h3>Items by Category</h3>
    <table>
      <tr>
        ${Object.entries(data.stats.categoryBreakdown)
          .filter(([, count]) => count > 0)
          .map(([cat]) => `<th>${cat.charAt(0).toUpperCase() + cat.slice(1)}</th>`)
          .join('')}
      </tr>
      <tr>
        ${Object.entries(data.stats.categoryBreakdown)
          .filter(([, count]) => count > 0)
          .map(([, count]) => `<td>${count}</td>`)
          .join('')}
      </tr>
    </table>

    ${data.stats.topColors.length > 0 ? `
    <h3>Top Colors</h3>
    <p>
      ${data.stats.topColors
        .map(({ color, count }) => `<span class="color-dot" style="background: ${color};"></span>${color} (${count})`)
        .join(' &nbsp; ')}
    </p>
    ` : ''}
  </section>

  <section>
    <h2>Wardrobe Items</h2>
    <div class="items-grid">
      ${data.items.map((item) => `
        <div class="item-card">
          ${includeImages && imageCache.has(item.id)
            ? `<img class="item-image" src="${imageCache.get(item.id)}" alt="${item.name}">`
            : `<div class="item-image" style="display:flex;align-items:center;justify-content:center;color:#999;">No image</div>`
          }
          <div class="item-info">
            <div class="item-name">${item.name}</div>
            <div class="item-meta">
              ${item.brand ? `${item.brand} · ` : ''}
              ${item.category}
              ${item.purchase_price ? ` · ${formatCurrency(item.purchase_price)}` : ''}
            </div>
            <div class="item-meta">Worn ${item.usage_times_worn} times</div>
          </div>
        </div>
      `).join('')}
    </div>
  </section>

  ${data.outfits.length > 0 ? `
  <section>
    <h2>Outfits</h2>
    <div class="outfits-grid">
      ${data.outfits.map((outfit) => `
        <div class="outfit-card">
          <div class="outfit-name">${outfit.name}</div>
          ${outfit.description ? `<div class="outfit-desc">${outfit.description}</div>` : ''}
          <div>
            ${outfit.style ? `<span class="tag">${outfit.style}</span>` : ''}
            ${outfit.season ? `<span class="tag">${outfit.season}</span>` : ''}
            ${outfit.occasion ? `<span class="tag">${outfit.occasion}</span>` : ''}
          </div>
          <div class="item-meta" style="margin-top: 0.5rem;">
            ${outfit.item_ids.length} items · Worn ${outfit.worn_count} times
          </div>
        </div>
      `).join('')}
    </div>
  </section>
  ` : ''}

</body>
</html>
`

  return html
}

// ============================================================================
// CSV EXPORT
// ============================================================================

/**
 * Export items to CSV format.
 */
export function exportItemsToCSV(items: Item[]): string {
  const headers = [
    'Name',
    'Category',
    'Sub-Category',
    'Brand',
    'Colors',
    'Size',
    'Price',
    'Condition',
    'Times Worn',
    'Last Worn',
    'Tags',
    'Favorite',
    'Created At',
  ]

  const rows = items.map((item) => [
    `"${item.name.replace(/"/g, '""')}"`,
    item.category,
    item.sub_category || '',
    item.brand || '',
    `"${item.colors.join(', ')}"`,
    item.size || '',
    item.purchase_price?.toString() || '',
    item.condition,
    item.usage_times_worn.toString(),
    item.usage_last_worn || '',
    `"${item.tags.join(', ')}"`,
    item.is_favorite ? 'Yes' : 'No',
    item.created_at,
  ])

  return [headers.join(','), ...rows.map((row) => row.join(','))].join('\n')
}

/**
 * Export outfits to CSV format.
 */
export function exportOutfitsToCSV(outfits: Outfit[]): string {
  const headers = [
    'Name',
    'Description',
    'Style',
    'Season',
    'Occasion',
    'Item Count',
    'Times Worn',
    'Last Worn',
    'Tags',
    'Favorite',
    'Public',
    'Created At',
  ]

  const rows = outfits.map((outfit) => [
    `"${outfit.name.replace(/"/g, '""')}"`,
    `"${(outfit.description || '').replace(/"/g, '""')}"`,
    outfit.style || '',
    outfit.season || '',
    outfit.occasion || '',
    outfit.item_ids.length.toString(),
    outfit.worn_count.toString(),
    outfit.last_worn_at || '',
    `"${outfit.tags.join(', ')}"`,
    outfit.is_favorite ? 'Yes' : 'No',
    outfit.is_public ? 'Yes' : 'No',
    outfit.created_at,
  ])

  return [headers.join(','), ...rows.map((row) => row.join(','))].join('\n')
}

// ============================================================================
// JSON EXPORT
// ============================================================================

/**
 * Export wardrobe data to JSON format.
 */
export function exportToJSON(data: WardrobeExportData): string {
  return JSON.stringify(
    {
      title: data.title,
      exportDate: data.exportDate,
      author: data.author,
      stats: data.stats,
      items: data.items.map((item) => ({
        id: item.id,
        name: item.name,
        category: item.category,
        sub_category: item.sub_category,
        brand: item.brand,
        colors: item.colors,
        size: item.size,
        price: item.purchase_price,
        condition: item.condition,
        times_worn: item.usage_times_worn,
        last_worn: item.usage_last_worn,
        tags: item.tags,
        is_favorite: item.is_favorite,
        created_at: item.created_at,
      })),
      outfits: data.outfits.map((outfit) => ({
        id: outfit.id,
        name: outfit.name,
        description: outfit.description,
        style: outfit.style,
        season: outfit.season,
        occasion: outfit.occasion,
        item_ids: outfit.item_ids,
        times_worn: outfit.worn_count,
        last_worn: outfit.last_worn_at,
        tags: outfit.tags,
        is_favorite: outfit.is_favorite,
        is_public: outfit.is_public,
        created_at: outfit.created_at,
      })),
    },
    null,
    2
  )
}

// ============================================================================
// LOOKBOOK GENERATION
// ============================================================================

/**
 * Create a lookbook from selected outfits.
 */
export function createLookbook(
  outfits: Outfit[],
  items: Item[],
  options: {
    title?: string
    description?: string
    author?: string
  } = {}
): Lookbook {
  const itemsMap = new Map(items.map((item) => [item.id, item]))

  const pages: LookbookPage[] = outfits.map((outfit) => ({
    title: outfit.name,
    description: outfit.description,
    outfit,
    items: outfit.item_ids
      .map((id) => itemsMap.get(id))
      .filter((item): item is Item => !!item),
  }))

  return {
    title: options.title || 'My Lookbook',
    description: options.description,
    author: options.author,
    createdDate: new Date().toISOString(),
    pages,
  }
}

/**
 * Export lookbook to HTML format.
 */
export async function exportLookbookToHTML(lookbook: Lookbook): Promise<string> {
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${lookbook.title}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Georgia', serif;
      line-height: 1.8;
      color: #333;
    }
    .cover {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 2rem;
    }
    .cover h1 { font-size: 4rem; font-weight: 300; letter-spacing: 0.2em; text-transform: uppercase; }
    .cover .subtitle { font-size: 1.25rem; margin-top: 1rem; opacity: 0.8; }
    .cover .meta { margin-top: 3rem; font-size: 0.875rem; opacity: 0.6; }
    .page {
      min-height: 100vh;
      padding: 4rem;
      display: flex;
      flex-direction: column;
      justify-content: center;
      page-break-after: always;
    }
    .page:nth-child(even) { background: #fafafa; }
    .page-number {
      font-size: 0.875rem;
      color: #999;
      margin-bottom: 2rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }
    .page h2 { font-size: 2.5rem; font-weight: 300; margin-bottom: 1rem; }
    .page .description { font-size: 1.125rem; color: #666; margin-bottom: 2rem; max-width: 600px; }
    .items-list { display: flex; flex-wrap: wrap; gap: 1.5rem; margin-top: 2rem; }
    .item-pill {
      background: white;
      border: 1px solid #e5e5e5;
      padding: 0.75rem 1.25rem;
      border-radius: 50px;
      font-size: 0.875rem;
    }
    .item-pill .brand { color: #999; font-size: 0.75rem; }
    .tags { display: flex; gap: 0.5rem; margin-top: 1rem; }
    .tag {
      background: #333;
      color: white;
      padding: 0.25rem 0.75rem;
      border-radius: 4px;
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    @media print {
      .page { page-break-after: always; }
    }
  </style>
</head>
<body>
  <div class="cover">
    <h1>${lookbook.title}</h1>
    ${lookbook.description ? `<p class="subtitle">${lookbook.description}</p>` : ''}
    <p class="meta">
      ${lookbook.author ? `By ${lookbook.author} · ` : ''}
      ${formatDate(lookbook.createdDate)}
    </p>
  </div>

  ${lookbook.pages.map((page, i) => `
    <div class="page">
      <div class="page-number">Look ${i + 1} of ${lookbook.pages.length}</div>
      <h2>${page.title}</h2>
      ${page.description ? `<p class="description">${page.description}</p>` : ''}

      <div class="tags">
        ${page.outfit.style ? `<span class="tag">${page.outfit.style}</span>` : ''}
        ${page.outfit.season ? `<span class="tag">${page.outfit.season}</span>` : ''}
        ${page.outfit.occasion ? `<span class="tag">${page.outfit.occasion}</span>` : ''}
      </div>

      <div class="items-list">
        ${page.items.map((item) => `
          <div class="item-pill">
            <strong>${item.name}</strong>
            ${item.brand ? `<span class="brand"> by ${item.brand}</span>` : ''}
          </div>
        `).join('')}
      </div>
    </div>
  `).join('')}
</body>
</html>
`

  return html
}

// ============================================================================
// DOWNLOAD HELPERS
// ============================================================================

/**
 * Trigger a file download.
 */
export function downloadFile(content: string, filename: string, mimeType: string): void {
  const blob = new Blob([content], { type: mimeType })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

/**
 * Export and download wardrobe data.
 */
export async function exportAndDownload(
  items: Item[],
  outfits: Outfit[],
  format: ExportFormat,
  options: ExportOptions = { format }
): Promise<void> {
  const data = prepareWardrobeExport(items, outfits, {
    title: options.title,
    author: options.author,
  })

  const timestamp = new Date().toISOString().split('T')[0]
  let content: string
  let filename: string
  let mimeType: string

  switch (format) {
    case 'markdown':
      content = exportToMarkdown(data)
      filename = `wardrobe-export-${timestamp}.md`
      mimeType = 'text/markdown'
      break

    case 'html':
      content = await exportToHTML(data, { includeImages: options.includeImages })
      filename = `wardrobe-export-${timestamp}.html`
      mimeType = 'text/html'
      break

    case 'json':
      content = exportToJSON(data)
      filename = `wardrobe-export-${timestamp}.json`
      mimeType = 'application/json'
      break

    case 'csv':
      content = exportItemsToCSV(items)
      filename = `wardrobe-items-${timestamp}.csv`
      mimeType = 'text/csv'
      break

    case 'pdf':
      // For PDF, we generate HTML and open print dialog
      content = await exportToHTML(data, { includeImages: options.includeImages })
      const printWindow = window.open('', '_blank')
      if (printWindow) {
        printWindow.document.write(content)
        printWindow.document.close()
        printWindow.focus()
        setTimeout(() => printWindow.print(), 500)
      }
      return

    default:
      throw new Error(`Unsupported format: ${format}`)
  }

  downloadFile(content, filename, mimeType)
}

/**
 * Export lookbook and download.
 */
export async function exportLookbookAndDownload(
  outfits: Outfit[],
  items: Item[],
  options: { title?: string; description?: string; author?: string; format?: 'html' | 'pdf' } = {}
): Promise<void> {
  const lookbook = createLookbook(outfits, items, options)
  const html = await exportLookbookToHTML(lookbook)
  const timestamp = new Date().toISOString().split('T')[0]

  if (options.format === 'pdf') {
    const printWindow = window.open('', '_blank')
    if (printWindow) {
      printWindow.document.write(html)
      printWindow.document.close()
      printWindow.focus()
      setTimeout(() => printWindow.print(), 500)
    }
  } else {
    downloadFile(html, `lookbook-${timestamp}.html`, 'text/html')
  }
}
