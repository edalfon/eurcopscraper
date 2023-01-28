# just to quickly test 

lapply(list.files("./R", full.names = TRUE), source, encoding = "UTF-8")

timestamp <- Sys.time()

vancouver_df <- vancouver()
vancouver_df$timestamp <- timestamp
appendRDS("data/vancouver.rds", vancouver_df)

visa_rate <- visa()
visa_df <- data.frame(visa_rate = visa_rate, timestamp = timestamp)
appendRDS("data/visa.rds", visa_df)

master_rate <- master()
master_df <- data.frame(master_rate = master_rate, timestamp = timestamp)
appendRDS("data/master.rds", master_df)

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

