# ClipGrid Pricing Recommendation

**Research date:** 1 September 2026

## Recommendation

Launch ClipGrid as a **US$9.99 paid-upfront Mac app**, with local App Store price tiers applied in other territories.

Use:

- No subscription
- No account
- No advertising
- No analytics at launch
- Manual release
- No introductory discount until the production listing and support flow are verified

This is a recommendation, not an approved commercial decision. Rudolf must approve the final tier and territories in App Store Connect.

## Evidence

Apple's U.S. catalog API returned the following live storefront data on the research date:

| Product | Catalog price | Version | Rating evidence | Store URL |
|---|---:|---:|---:|---|
| Maccy | $9.99 | 2.7.1 | Catalog returned no U.S. rating count | https://apps.apple.com/us/app/maccy/id1527619437?mt=12 |
| Paste – Limitless Clipboard | Free download | 6.6.9 | 4.19 / 1,312 ratings | https://apps.apple.com/us/app/paste-limitless-clipboard/id967805235 |
| Clipboard Manager – PastePal | Free download | 2.15.9 | 4.13 / 178 ratings | https://apps.apple.com/us/app/clipboard-manager-pastepal/id1503446680 |
| PasteNow – Instant Clipboard | Free download | 2.32 | 3.66 / 35 ratings | https://apps.apple.com/us/app/pastenow-instant-clipboard/id1552536109 |

“Free download” does not prove a competitor has no in-app purchase or subscription. Apple's search API exposes the storefront download price, not the complete commercial model. Recheck each product's current in-app purchase page before approving ClipGrid's final tier.

## Rationale

- Maccy provides a clear paid-upfront reference at $9.99.
- ClipGrid's no-account, local-only model is easier to explain as a simple purchase than as a subscription.
- A subscription would add StoreKit, restore-purchase, paywall, support, privacy, and review complexity without a recurring cloud service.
- Free-with-IAP would require a separate product and conversion design that is not part of the stable 1.0 scope.

## Post-launch experiment

After at least 30 days or enough traffic for a meaningful comparison:

1. Review App Store impressions, product-page views, downloads, refunds, ratings, and support volume.
2. Keep the feature set and listing stable during the measurement window.
3. Test only one pricing variable at a time.
4. Record the date, territories, old tier, new tier, and result in Linear.

## Approval gate

Rudolf must decide:

- [ ] Approve or change the US$9.99 recommendation.
- [ ] Confirm sale territories.
- [ ] Confirm paid-upfront, no-subscription launch.
- [ ] Confirm manual release.
