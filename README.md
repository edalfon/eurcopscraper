# eurcopscraper

Scrapes EUR/COP exchange rates from several sources (Vancouver, Visa,
Mastercard/Nu, Condor, Comdirect, Kapital, ER API) every 3 hours via
GitHub Actions ([.github/workflows/eurcopscraper.yaml](.github/workflows/eurcopscraper.yaml)),
appends to `data/*.rds`, and renders the dashboard in [quarto/](quarto/).

See [NEWS.md](NEWS.md) for known issues, operational notes, and gotchas.
