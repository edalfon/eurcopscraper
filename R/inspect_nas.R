#' Build a wide (timestamp x source) view of all scraped rates
#'
#' See NEWS.md ("Gotcha: inspect_nas() / pivot_wider() and the n column")
#' before touching the summarise/pivot_wider pipeline below -- it has
#' already broken fillin_visa() once in a very confusing way.
inspect_nas <- function() {
  data_wide <- ingest_all_rds() |>
    dplyr::select(timestamp, source, rate) |>
    dplyr::summarise(
      n = dplyr::n(),
      rate = mean(rate, na.rm = TRUE),
      .by = c(timestamp, source)
    ) |>
    # dplyr::summarise(
    #   n = dplyr::n(), rate = paste(rate, collapse = ","),
    #   .by = c(timestamp, source)
    # ) |>
    # dplyr::filter(n > 1L)
    # `n` must be dropped before pivoting: pivot_wider() treats any column
    # not in names_from/values_from as part of the row identity, so leaving
    # it in silently fragments a timestamp into multiple rows whenever one
    # source has a different duplicate-count than another at that instant
    # (e.g. a source that returned 2 near-identical scraped rows) -- which
    # is exactly what made freshly-filled Visa rows look "still missing".
    dplyr::select(-n) |>
    tidyr::pivot_wider(names_from = source, values_from = rate)

  data_wide
}


#' Backfill missing Visa rates, a few dates at a time
#'
#' See NEWS.md ("Visa disabled in CI, backfilled locally via fillin_visa()") for the full
#' story. Visa is disabled in the CI scraper (Cloudflare blocks the GitHub
#' Actions runner IP), so gaps in data/visa.rds have to be filled in by
#' running this locally, from home, every so often. Run it repeatedly (e.g.
#' once a day) to gradually work through the backlog. Two things it does
#' to stay polite, learned by testing directly against the API:
#' - Tries the *newest* missing dates first. Visa's API only serves roughly
#'   the last year of history; older dates come back with a permanent 400
#'   (not a block), so oldest-first would waste every single run retrying
#'   the same unrecoverable dates instead of catching up on ones that can
#'   actually still be fetched.
#' - Sleeps a random pause between requests, and stops the run immediately
#'   on a 403 (rather than ploughing through the rest of `max_dates`) since
#'   that's Cloudflare signalling this IP got flagged too -- better to back
#'   off than dig that hole deeper.
#'
#' @param max_dates maximum number of missing dates to query in this run
#' @param min_sleep,max_sleep bounds (seconds) for the random pause between requests
fillin_visa <- function(max_dates = 15, min_sleep = 8, max_sleep = 20) {
  data_wide <- inspect_nas()
  visa_na <- data_wide |>
    dplyr::select(timestamp, Visa) |>
    dplyr::filter(is.na(Visa)) |>
    dplyr::mutate(date = as.Date(timestamp))

  dates_na <- sort(unique(visa_na$date), decreasing = TRUE)
  n_missing <- length(dates_na)
  cat("Found", n_missing, "missing Visa date(s)\n")
  dates_na <- utils::head(dates_na, max_dates)

  cat(
    "Filling in up to",
    length(dates_na),
    "of",
    n_missing,
    "missing Visa date(s)\n"
  )

  rows <- vector("list", length(dates_na))
  for (i in seq_along(dates_na)) {
    d <- dates_na[i]
    cat(" -", as.character(d), "... ")

    result <- tryCatch(
      list(rate = visa(d), status = NA_integer_, msg = NA_character_),
      error = function(e) {
        list(
          rate = NA_real_,
          status = if (!is.null(e$resp)) {
            httr2::resp_status(e$resp)
          } else {
            NA_integer_
          },
          msg = conditionMessage(e)
        )
      }
    )

    if (!is.na(result$rate)) {
      cat("ok:", result$rate, "\n")
    } else {
      cat("failed (status", result$status, "):", result$msg, "\n")
    }
    rows[[i]] <- data.frame(date = d, rate_fillin = result$rate)

    if (!is.na(result$status) && result$status == 403L) {
      cat(
        "Got a 403 (blocked) -- stopping this run early rather than pushing through more requests.\n"
      )
      break
    }
    Sys.sleep(stats::runif(1, min_sleep, max_sleep))
  }

  visa_to_fillin <- dplyr::bind_rows(rows)

  visa_df <- visa_na |>
    dplyr::left_join(
      visa_to_fillin |> dplyr::mutate(date = as.Date(date)),
      by = "date"
    ) |>
    dplyr::filter(!is.na(rate_fillin)) |>
    dplyr::select(timestamp, visa_rate = rate_fillin)

  if (nrow(visa_df) > 0) {
    appendRDS("data/visa.rds", visa_df)
    cat(
      "Filled in",
      nrow(visa_df),
      "Visa rate(s) and appended to data/visa.rds\n"
    )
  } else {
    cat(
      "Nothing fetched successfully this run, data/visa.rds left untouched.\n"
    )
  }

  invisible(visa_df)
}
