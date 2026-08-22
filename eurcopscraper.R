lapply(list.files("./R", full.names = TRUE), source, encoding = "UTF-8")

timestamp <- Sys.time()

file.remove("logs/failed.txt", showWarnings = FALSE)

try_and_log_error(msg = "Vancouver", {
  vancouver_df <- vancouver()
  vancouver_df$timestamp <- timestamp
  appendRDS("data/vancouver.rds", vancouver_df)
})

# Visa is disabled here: Cloudflare 403-blocks (JS challenge page) both a
# plain httr2 request and a puppeteer headless browser when they come from
# the GitHub Actions runner IP range, while both work fine from a residential
# IP (confirmed 2026-08-22, CI run 32581446115 got HTTP 403 + "Just a
# moment..." challenge body from visa(), and a 400 from visa_puppeteer()).
# Self-hosting a runner just for this wasn't worth the complexity, so instead
# gaps are backfilled locally, from home, via fillin_visa() in
# R/inspect_nas.R -- run that manually/periodically instead of relying on CI.
# See NEWS.md ("Visa disabled in CI, backfilled locally via fillin_visa()") for the full story.

try_and_log_error(msg = "Master", {
  master_rate <- master_puppeteer()
  master_df <- data.frame(master_rate = master_rate, timestamp = timestamp)
  appendRDS("data/master.rds", master_df)
})

try_and_log_error(msg = "Nu", {
  nu_rate <- master_puppeteer_nu()
  nu_df <- data.frame(nu_rate = nu_rate, timestamp = timestamp)
  appendRDS("data/nu.rds", nu_df)
})

try_and_log_error(msg = "Condor", {
  condor_df <- condor()
  condor_df$timestamp <- timestamp
  appendRDS("data/condor.rds", condor_df)
})

try_and_log_error(msg = "Comdirect", {
  comdirect_df <- comdirect()
  comdirect_df$timestamp <- timestamp
  appendRDS("data/comdirect.rds", comdirect_df)
})

try_and_log_error(msg = "Kapital", {
  kapital_df <- kapital()
  kapital_df$timestamp <- timestamp
  appendRDS("data/kapital.rds", kapital_df)
})
try_and_log_error(msg = "ER API", {
  er_rate <- er_api()
  er_df <- data.frame(er_rate = er_rate, timestamp = timestamp)
  appendRDS("data/erapi.rds", er_df)
})


quarto::quarto_render("quarto", as_job = FALSE, execute_dir = ".")
