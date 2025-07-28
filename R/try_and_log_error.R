try_and_log_error <- function(expr, msg = "-", fail_stamp = TRUE) {
  tryCatch(expr, error = function(e) {
    # Log to file
    cat(
      format(Sys.time()),
      " ",
      msg,
      " Error: ",
      conditionMessage(e),
      "\n",
      file = "logs/errors.txt",
      append = TRUE
    )
    if (isTRUE(fail_stamp)) {
      cat(
        format(Sys.time()),
        " ",
        msg,
        "\n",
        file = "logs/failed.txt",
        append = TRUE
      )
    }
    # Print full error details to console
    cat("----- ERROR OCCURRED -----\n")
    cat("Timestamp:", format(Sys.time()), "\n")
    cat("Message:", msg, "\n")
    cat("Error class:", paste(class(e), collapse = ", "), "\n")
    cat("Error message:", conditionMessage(e), "\n")
    cat("Call:", deparse(e$call), "\n")
    cat("Full error object:\n")
    print(e)
    cat("--------------------------\n")
  })
}
