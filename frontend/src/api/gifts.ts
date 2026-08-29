import { apiClient, getApiError, skipToast } from '@/api/client'
import type { ApiEnvelope } from '@/types'

export type GiftDuration = 1 | 3 | 12
export type GiftSource = 'paid' | 'complimentary' | 'admin'
export type GiftStatus =
  | 'pending'
  | 'issued'
  | 'claimed'
  | 'expired'
  | 'voided'
  | 'revoked'
  | 'payment_failed'
  | 'payment_review'

export interface GiftCatalogOption {
  duration_months: GiftDuration
  retail_value_cents: number
  currency: 'USD'
  paid_available: boolean
}

export interface GiftAllowance {
  duration_months: GiftDuration
  granted_count: number
  used_count: number
  remaining_count: number
}

export interface GiftVoucher {
  id: string
  public_id: string
  source?: GiftSource
  duration_months: GiftDuration
  retail_value_cents: number
  currency: string
  from_name: string
  to_name: string
  message?: string
  status: GiftStatus
  payment_status?: string
  issued_at?: string
  expires_at?: string
  claimed_at?: string
  created_at: string
  artwork_version: number
  share_url?: string
  claim_code?: string
  portrait_url?: string
  og_image_url: string
  entitlement_status?: 'active' | 'queued' | 'consumed' | 'revoked'
  entitlement_starts_at?: string
  entitlement_ends_at?: string
}

export interface GiftList {
  items: GiftVoucher[]
  total: number
  page: number
  page_size: number
}

export interface GiftClaimResult {
  voucher: GiftVoucher
  entitlement_status: 'active' | 'queued'
  active_ends_at?: string
  queued_count: number
  queued_months: number
}

export interface GiftPersonalization {
  duration_months: GiftDuration
  from_name: string
  to_name: string
  message?: string
  client_request_id: string
}

export interface GiftPresentationUpdate {
  from_name?: string
  to_name?: string
  message?: string | null
}

export interface GiftCheckout {
  checkout_url: string
  session_id: string
  voucher: GiftVoucher
}

async function unwrap<T>(request: Promise<{ data: ApiEnvelope<T> }>): Promise<T> {
  try {
    const response = await request
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export function getGiftCatalog(): Promise<GiftCatalogOption[]> {
  return unwrap(apiClient.get('/api/v1/gifts/catalog', skipToast))
}

export function getPublicGift(publicId: string): Promise<GiftVoucher> {
  return unwrap(apiClient.get(`/api/v1/gifts/public/${publicId}`, skipToast))
}

export function getGiftAllowances(): Promise<GiftAllowance[]> {
  return unwrap(apiClient.get('/api/v1/gifts/allowances', skipToast))
}

export function getSentGifts(page = 1): Promise<GiftList> {
  return unwrap(apiClient.get('/api/v1/gifts/sent', { params: { page, page_size: 50 }, ...skipToast }))
}

export function getReceivedGifts(page = 1): Promise<GiftList> {
  return unwrap(apiClient.get('/api/v1/gifts/received', { params: { page, page_size: 50 }, ...skipToast }))
}

export function createComplimentaryGift(body: GiftPersonalization): Promise<GiftVoucher> {
  return unwrap(apiClient.post('/api/v1/gifts/complimentary', body, skipToast))
}

export function createPaidGiftCheckout(
  body: GiftPersonalization,
): Promise<GiftCheckout> {
  return unwrap(
    apiClient.post(
      '/api/v1/gifts/checkout',
      {
        ...body,
        success_url: '/gifts?checkout=success&session_id={CHECKOUT_SESSION_ID}',
        cancel_url: '/gifts?checkout=cancelled',
      },
      skipToast,
    ),
  )
}

export function fulfillGiftCheckout(sessionId: string): Promise<GiftVoucher> {
  return unwrap(apiClient.post('/api/v1/gifts/checkout/fulfill', { session_id: sessionId }, skipToast))
}

export function claimGift(publicId: string, secret: string): Promise<GiftClaimResult> {
  return unwrap(
    apiClient.post(
      '/api/v1/gifts/claim',
      { public_id: publicId, secret },
      skipToast,
    ),
  )
}

export function updateGift(
  voucherId: string,
  body: GiftPresentationUpdate,
): Promise<GiftVoucher> {
  return unwrap(apiClient.patch(`/api/v1/gifts/${voucherId}`, body, skipToast))
}

export function rotateGiftLink(voucherId: string): Promise<GiftVoucher> {
  return unwrap(apiClient.post(`/api/v1/gifts/${voucherId}/rotate`, null, skipToast))
}

export async function downloadGiftArtwork(voucher: GiftVoucher): Promise<void> {
  try {
    const response = await apiClient.get<Blob>(
      `/api/v1/gifts/${voucher.id}/artwork/portrait.png?v=${voucher.artwork_version}`,
      { responseType: 'blob', ...skipToast },
    )
    const objectUrl = URL.createObjectURL(response.data)
    const anchor = document.createElement('a')
    anchor.href = objectUrl
    anchor.download = `fitcheck-pro-gift-${voucher.to_name.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}.png`
    document.body.appendChild(anchor)
    anchor.click()
    anchor.remove()
    URL.revokeObjectURL(objectUrl)
  } catch (error) {
    throw getApiError(error)
  }
}

const SAFE_GIFT_MESSAGES = new Set([
  'No complimentary gift slots remain for this duration',
  'You cannot claim a gift that you created',
  'This gift has already been claimed',
  'This promotional gift has expired',
  'This gift is no longer valid',
  'This gift is not ready to claim',
  'The voucher code is invalid',
  'Verify your email before you create or claim a gift',
  'Gift voucher creation is not enabled',
  'The payment has not completed',
])

export function giftErrorMessage(error: unknown, fallback: string): string {
  const message = error instanceof Error ? error.message : ''
  return SAFE_GIFT_MESSAGES.has(message) ? message : fallback
}
