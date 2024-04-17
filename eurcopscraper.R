# just to quickly test

lapply(list.files("./R", full.names = TRUE), source, encoding = "UTF-8")

timestamp <- Sys.time()

vancouver_df <- vancouver()
vancouver_df$timestamp <- timestamp
appendRDS("data/vancouver.rds", vancouver_df)

# there are issues with visa, basically a 403 forbidden error
# there must be some sort of rate-limit going on, that applies to the IP address
# from github servers or something (already tried user agent and other headers)
tryCatch(
  {
    visa_rate <- visa()
    visa_df <- data.frame(visa_rate = visa_rate, timestamp = timestamp)
    appendRDS("data/visa.rds", visa_df)
  },
  error = \(e) cat("Visa Error:", conditionMessage(e), "\n")
)

master_rate <- master()
master_df <- data.frame(master_rate = master_rate, timestamp = timestamp)
appendRDS("data/master.rds", master_df)

nu_rate <- 1 / master(crdhldBillCurr = "COP", transCurr = "EUR")
nu_df <- data.frame(nu_rate = nu_rate, timestamp = timestamp)
appendRDS("data/nu.rds", nu_df)

condor_df <- condor()
condor_df$timestamp <- timestamp
appendRDS("data/condor.rds", condor_df)

comdirect_df <- comdirect()
comdirect_df$timestamp <- timestamp
appendRDS("data/comdirect.rds", comdirect_df)

kapital_df <- kapital()
kapital_df$timestamp <- timestamp
appendRDS("data/kapital.rds", kapital_df)


quarto::quarto_render("quarto", as_job = FALSE, execute_dir = ".")
