# just to quickly test 

source("R/vancouver.R")

vancouver_table <- vancouver()
vancouver_table$timestamp <- Sys.time()

curr_data <- readRDS("data/vancouver.rds")

vancouver_table <- dplyr::bind_rows(vancouver_table, curr_data)

saveRDS(vancouver_table, "data/vancouver.rds")

