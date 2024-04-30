# just to quickly test

lapply(list.files("./R", full.names = TRUE), source, encoding = "UTF-8")

timestamp <- Sys.time()

file.remove("logs/failed.txt", showWarnings = FALSE)

try_and_log_error(msg = "Vancouver", {
  vancouver_df <- vancouver()
  vancouver_df$timestamp <- timestamp
  appendRDS("data/vancouver.rds", vancouver_df)
})

# there are issues with visa, basically a 403 forbidden error
# there must be some sort of rate-limit going on, that applies to the IP address
# from github servers or something (already tried user agent and other headers)
try_and_log_error(msg = "Visa", fail_stamp = FALSE, {
  visa_rate <- visa()
  visa_df <- data.frame(visa_rate = visa_rate, timestamp = timestamp)
  appendRDS("data/visa.rds", visa_df)
})

try_and_log_error(msg = "Master", {
  master_rate <- master()
  master_df <- data.frame(master_rate = master_rate, timestamp = timestamp)
  appendRDS("data/master.rds", master_df)
})

try_and_log_error(msg = "Nu", {
  nu_rate <- 1 / master(crdhldBillCurr = "COP", transCurr = "EUR")
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

quarto::quarto_render("quarto", as_job = FALSE, execute_dir = ".")
