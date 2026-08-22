# eurcopscraper

Scrapes EUR/COP exchange rates from several sources (Vancouver, Visa,
Mastercard/Nu, Condor, Comdirect, Kapital, ER API) every 3 hours via
GitHub Actions ([.github/workflows/eurcopscraper.yaml](.github/workflows/eurcopscraper.yaml)),
appends to `data/*.rds`, and renders the dashboard in [quarto/](quarto/).

## Known issue: Visa is not scraped by CI

Visa's `/cmsapi/fx/rates` endpoint is blocked by Cloudflare (HTTP 403 with
a "Just a moment..." JS-challenge page) when requested from GitHub
Actions' runner IP range — both a plain `httr2` request (`visa()`) and a
full puppeteer headless browser (`visa_puppeteer()`) get blocked the same
way. It works fine from a residential IP, so self-hosting a GitHub
Actions runner just for Visa was considered and rejected (not worth the
complexity/security tradeoffs for a public repo — see commit `f29bd821d`
for the writeup).

As a result, `eurcopscraper.R` does **not** call Visa at all anymore.
Instead:

- Gaps in `data/visa.rds` are backfilled by running `fillin_visa()`
  (defined in [R/inspect_nas.R](R/inspect_nas.R)) **locally, from home,
  every so often**. It queries the *newest* missing dates first (Visa's
  API only serves roughly the last year of history; older dates return a
  permanent 400, not a block — not recoverable, don't chase them), sleeps
  between requests, and aborts immediately on a 403 to avoid getting the
  home IP flagged too.
- After a `fillin_visa()` run, commit and push the updated
  `data/visa.rds` manually — this part isn't automated.

```r
# from an R session at the project root (after sourcing R/*.R, e.g. via
# source("eurcopscraper.R") or lapply(list.files("./R", full.names=TRUE), source))
fillin_visa()                # fills up to 15 missing dates, default politeness
fillin_visa(max_dates = 30)  # churn through the backlog faster
```

### Gotcha: `inspect_nas()` / `pivot_wider()` and the `n` column

`inspect_nas()` — which `fillin_visa()` uses to figure out what's
missing — computes a diagnostic `n = dplyr::n()` column before pivoting
wide. **That column must be dropped before `pivot_wider()`.** If it
isn't, `pivot_wider()` silently treats `n` as part of the row identity,
so any timestamp where one source has a different duplicate-count than
another (e.g. Vancouver sometimes returns 2 near-identical scraped rows)
gets fragmented into multiple rows instead of merging into one.

This previously made `fillin_visa()` look completely broken: it reported
success, but the missing-date count never went down, because every
freshly-filled Visa value landed in its own orphaned row fragment instead
of merging into the row the other sources occupied. Fixed in commit
`2d5434729`. **If `fillin_visa()` ever stops converging again, check this
first** before assuming Visa's API itself changed.
