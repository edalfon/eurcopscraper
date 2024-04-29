try_and_log_error <- function(expr, msg = "-") {
  tryCatch(expr,
    error = \(e) {
      cat(
        format(Sys.time()), " ", msg, " Error: ", conditionMessage(e), "\n",
        file = "logs/errors.txt", append = TRUE
      )
      cat(
        format(Sys.time()), " ", msg, "\n",
        file = "logs/failed.txt", append = TRUE
      )
    }
  )
}
