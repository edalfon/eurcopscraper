try_and_log_error <- function(expr, msg = "-", fail_stamp = TRUE) {
  tryCatch(expr,
    error = \(e) {
      cat(
        format(Sys.time()), " ", msg, " Error: ", conditionMessage(e), "\n",
        file = "logs/errors.txt", append = TRUE
      )
      if (isTRUE(fail_stamp)) {
        cat(
          format(Sys.time()), " ", msg, "\n",
          file = "logs/failed.txt", append = TRUE
        )
      }
    }
  )
}
