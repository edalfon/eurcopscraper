# just to quickly test 

source("R/vancouver.R")

vancouver_table <- vancouver()

vancouver_table$time <- Sys.time()

saveRDS(vancouver_table, "data/vancouver.rds")
