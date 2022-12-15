appendRDS <- function(rdsfile, newdata) {

  curdata <- tryCatch(
    expr = readRDS(rdsfile),
    error = function(e) data.frame()
  )

  appended <- dplyr::bind_rows(curdata, newdata)

  saveRDS(appended, rdsfile)
  
  invisible(appended)
}