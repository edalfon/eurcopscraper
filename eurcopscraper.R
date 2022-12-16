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
appendRDS("data/master.rds", visa_df)
print(master_rate)
print("master_rate")

