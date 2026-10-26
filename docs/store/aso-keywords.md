# App Store keywords

The keyword field is the only part of a listing that exists purely to be indexed. Apple
indexes exactly three things per storefront: the **name**, the **subtitle**, and the
**keyword field**. Everything else — description, promotional text, what's new — is read
by humans and ignored by search.

That has three consequences this document exists to enforce.

## 1. A term in the subtitle is dead weight in the keyword field

The budget is 100 characters including the commas. If the subtitle reads "AI Closet,
Try-On & Outfits", then `closet`, `try`, `on` and `outfits` are already indexed, and
repeating any of them spends characters to rank for a query the listing already ranks
for under a different field.

14 locales shipped with that mistake. `ar-SA` repeated خزانة, `hi` repeated लुक, `ja`
repeated コーデ, `fi` repeated `vaatekaappi` and `digitaalinen`, `da` repeated `tøj` and
`look`. `scripts/asc/keyword_planner.py` finds all of them and the validator in
`scripts/asc/plan.mjs` fails the build if a new one appears.

## 2. Keywords are planned per locale, not translated

A keyword field is not the English field in another language. The words a Berlin shopper
types are not the words a Texas shopper types, and a literal translation of "closet
organizer" is rarely what anyone searches.

So `scripts/i18n/translate_listings.py` deliberately does **not** own `keywords`. It
translates prose only. `scripts/asc/keyword_planner.py` plans each locale's field by
asking for the search terms that storefront's users actually type, then packs them
against the real budget.

When the planner writes a field it sets `_keywords_planned: true` on that locale. The
translator sees the flag and preserves the field when it rewrites prose. Without that
marker, the next wording change to the description would silently replace a planned
keyword field with a translated one, and nobody would notice for a release.

## 3. Some terms are worse than nothing

The planner rejects, and the validator fails on:

| Rejected | Why |
|---|---|
| `app`, `application`, `تطبيق`, `应用`, `アプリ`, `앱` | Every listing is an app. It distinguishes nothing. |
| `free`, `gratis`, `kostenlos`, `無料`, `무료`, `免费` | The price label already says Free. It is not a search term users type to find a wardrobe app. |
| `Pro`, `Plus` | Brand furniture, not a query. |
| Competitor names (`Whering`, `Stylebook`, `Cladwell`) | Guideline 2.3.7. Rejection risk, and the search intent lands on their app anyway. |
| Anything already indexed by name or subtitle | See rule 1. |

Latin-script terms are matched on word boundaries. `apparel`, `appearance` and
`happy outfit` are all good keywords for this app and all contain `app` as a substring; a
substring match would reject them. Scripts without spaces (Chinese, Japanese, Korean,
Thai, Arabic, Hebrew, Devanagari) match as substrings because there is no boundary to
anchor to.

## 4. Syllables are not terms

The Vietnamese field shipped as:

```text
phối,thời,trang,tủ,đồ,cá,nhân,trang,phục,phong,cách,mặc,đẹp,chụp,ảnh
```

That is `trang phục` (outfit) split into `trang` and `phục`, `phong cách` (style) split
into `phong` and `cách`. In Vietnamese the unit of meaning is multi-syllable, so neither
fragment matches a search on its own, and the whole field matches nothing. It also
repeats `trang`, which the validator already caught as a duplicate.

Repair a locale like this with:

```bash
python3 scripts/asc/keyword_planner.py --plan --rebuild --locale vi
python3 scripts/asc/keyword_planner.py --apply --locale vi
```

`--rebuild` discards the malformed field instead of building on it. Short terms are
normal in Chinese, Japanese, Korean and Thai, which have no word spaces, so those locales
are exempt from the fragmentation check.

## Commands

```bash
python3 scripts/asc/keyword_planner.py                    # report: budget use, redundancy
python3 scripts/asc/keyword_planner.py --plan             # plan all 50 into keywords.json
python3 scripts/asc/keyword_planner.py --plan --locale ja,hi
python3 scripts/asc/keyword_planner.py --apply            # merge the plan into listings.json
node scripts/asc/check-listings.mjs                       # the gate
```

`--plan` for a subset merges into the existing plan rather than replacing it, so
repairing one locale does not discard the other 49.

## What this does not do

It does not measure ranking. Apple publishes no keyword API, so relevance is a
judgement call and the plan is a hypothesis. The way to find out is to watch
**impressions** in App Store Connect per storefront after the 1.3.0 release and compare
against the 1.2.1 baseline; a locale whose keywords are wrong shows flat impressions
despite localized metadata. See `docs/store/growth-plan.md`.

It also does not touch the name or subtitle, which are the two highest-weight fields.
Those are constrained by App Review and by what fits in 30 characters, so changing them
is a product decision, not an optimization pass.
