# FitCheck Pro gift vouchers

Status: implemented behind creation flags; production launch is gated by
Stripe setup, migration deployment, internal redemption tests, and legal
review.

## Offer

| Term | Retail value | Complimentary allowance | Claim deadline |
|------|-------------:|------------------------:|----------------|
| 1 month | $20 USD | 3 | Paid: none; complimentary: 6 months after issue |
| 3 months | $60 USD | 1 | Paid: none; complimentary: 6 months after issue |
| 12 months | $200 USD | 1 | Paid: none; complimentary: 6 months after issue |

Every voucher grants non-renewing Pro access. The artwork uses the same
truthful retail value and “A gift from” language for paid, complimentary, and
admin-issued vouchers. It does not state that a complimentary voucher was
purchased.

## Issuance and claim rules

- A verified account can issue each complimentary allowance once. Expiry,
  voiding, or revocation does not restore a slot. An audited admin adjustment
  can add exceptional slots.
- The first verified account that submits the current claim secret or printed
  code receives the voucher. The displayed recipient name is ceremonial.
- The sender cannot claim their own voucher. Different accounts can exchange
  and stack any number of complimentary vouchers.
- Paid vouchers are issued only after repeat-safe Stripe webhook fulfillment
  verifies the Checkout owner, Price, quantity, amount, and USD currency.
- Paid value cannot be voided in the app. A confirmed external refund, lost
  dispute, or chargeback makes the voucher ineligible.

## Entitlement behavior

Gift time is stored in `gift_entitlement_grants`; it does not replace the
billing row. Free and Plus accounts receive gift Pro immediately. Plus billing
continues. Existing Pro access queues gifts in claim order. If paid, store,
promo, or referral Pro access starts while a gift is active, the gift pauses
and banks its exact unused seconds. The resolver activates the next eligible
gift atomically.

Existing clients continue to receive `plan_type=pro_monthly` while a gift is
active. New clients can also use `entitlement_source`, `active_gift_ends_at`,
`queued_gift_count`, and `queued_gift_months`.

## Privacy and sharing

The public identifier and claim credential are separate. The share URL stores
the credential in its fragment, which browsers do not send in HTTP requests.
The web client removes the fragment before analytics starts and keeps it for
the login, OAuth, and verification return flow. Claim credentials are never
returned by public APIs or logged.

Portrait artwork is 1080 by 1350 pixels and includes the private printed code
and QR code. Social artwork is 1200 by 630 pixels and contains no claim
credential. Both show the sender, recipient, term, and retail value. Public
gift pages use `noindex, nofollow`.

## Surfaces

- Customer web: protected `/gifts`; public `/gift/:publicId`.
- Public API: catalog, safe public detail, and versioned social artwork.
- Account API: allowances, sent/received history, complimentary creation,
  paid checkout, fulfillment, edits, rotation, claim, and portrait artwork.
- Admin API and SPA: metrics, filters, CSV, details, manual issue, edit,
  rotate, assign, allowance adjustment, and eligible void/revoke actions.
- Flutter: no native release-one screens. Gift links open the web experience.

## Launch gates

1. Apply `backend/db/supabase/migrations/056_gift_vouchers.sql` to hosted
   Supabase.
2. Create the three one-time Stripe Prices and configure the required Checkout,
   asynchronous payment, refund, and dispute webhook events.
3. Set the three `STRIPE_GIFT_PRO_*_PRICE_ID` values and a dedicated
   `GIFT_TOKEN_SECRET`; leave creation disabled until readiness is green.
4. Complete legal review for expiry, no-refund, cash-value, and tax terms.
5. Complete internal paid and complimentary claims, then enable the backend,
   web, and admin creation flags.
