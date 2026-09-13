/**
 * No-account demo quotas shown in marketing copy (proof-bar, demo strip).
 *
 * Keep in sync with backend/app/core/ip_rate_limit.py DEMO_RATE_LIMITS:
 * 3 extraction, 2 try-on, 1 photoshoot demo runs per IP per day.
 */

export const DEMO_RATE_LIMITS = {
  extraction: 3,
  tryOn: 2,
  photoshoot: 1,
} as const
