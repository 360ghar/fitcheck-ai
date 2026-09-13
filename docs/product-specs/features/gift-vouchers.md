# FitCheck Pro gift vouchers

Status: code complete behind launch flags. Production launch is gated by hosted
Supabase migration deployment, Stripe setup, restricted-account smoke tests,
and legal review.

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
- Every new web, mobile, and admin voucher requires recipient name and email.
  The stored email is lowercased and trimmed.
- A new named voucher can be claimed only by the verified account with the
  matching recipient email. The private link credential is still required for
  public-link claims. Legacy vouchers with no recipient email keep their
  link-only claim behavior.
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

Recipient email is private matching data. It is not returned by public,
owner, recipient, or dashboard-summary responses. It is not rendered in
artwork, analytics, or logs. Admin detail may show it to a user with the
existing gift permission.

Portrait artwork is 1080 by 1350 pixels and contains no claim credential.
Social artwork is 1200 by 630 pixels and also contains no claim credential.
Both show the sender, recipient, term, and retail value. The secure link is
shared separately. Public gift pages use `noindex, nofollow`.

## Surfaces

- Customer web: protected `/gifts`; public `/gift/:publicId`.
- Public API: catalog, safe public detail, and versioned social artwork.
- Account API: allowances, sent/received history, complimentary creation,
  paid checkout, fulfillment, edits, rotation, public claim, assigned claim,
  dashboard summary, and portrait artwork.
- Admin API and SPA: metrics, filters, CSV, details, manual issue, edit,
  rotate, assign, allowance adjustment, and eligible void/revoke actions.
  Commerce → Gift Vouchers is visible by default and requires gifts.read.
  Set VITE_ENABLE_GIFT_VOUCHERS=false only for a UI rollback.
- Dashboard: one non-dismissible card uses incoming gift, then free invitation,
  then referral. Multiple incoming gifts open the inbox.
- Flutter: native /gifts route, binding, repository, models, and controller.
  It supports free invitation creation, sharing, incoming review, and
  completion of named claims. It has no paid purchase CTA or external Checkout.

## Launch gates

1. Apply migrations 056 and 061 to hosted Supabase. Verify the gift tables,
   RPCs, incoming-recipient index, and RLS before enabling traffic. If
   migration 056 portrait objects were ever served, remove those old cache
   objects after deploying the credential-free artwork layout.
2. Create the three one-time Stripe Prices and configure Checkout,
   asynchronous payment, refund, and dispute webhook events.
3. Set the three STRIPE_GIFT_PRO_*_PRICE_ID values and a dedicated
   GIFT_TOKEN_SECRET. Creation is enabled by default.
4. Create a staging admin build. Verify /gifts with a gifts.read account before
   production deployment.
5. Rebuild and deploy both Vite apps and the Flutter release build. Do not set
   a gift-voucher flag to false unless performing a rollback.
6. Complete legal review and restricted-account paid, complimentary, web, and
   mobile claim smoke tests.
