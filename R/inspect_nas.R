inspect_nas <- function() {
  data_wide <- ingest_all_rds() |>
    dplyr::select(timestamp, source, rate) |>
    dplyr::summarise(
      n = dplyr::n(), rate = mean(rate, na.rm = TRUE),
      .by = c(timestamp, source)
    ) |>
    # dplyr::summarise(
    #   n = dplyr::n(), rate = paste(rate, collapse = ","),
    #   .by = c(timestamp, source)
    # ) |>
    # dplyr::filter(n > 1L)
    tidyr::pivot_wider(names_from = source, values_from = rate)

  data_wide
}


fillin_visa <- function() {
  data_wide <- inspect_nas()
  visa_na <- data_wide |>
    dplyr::select(timestamp, Visa) |>
    dplyr::filter(is.na(Visa)) |>
    dplyr::mutate(date = as.Date(timestamp))

  dates_na <- unique(visa_na$date) |> rlang::set_names(unique(visa_na$date))

  visa_to_fillin <- purrr::imap_dfr(dates_na, \(x, idx) {
    rate_to_fillin <- tryCatch(visa(idx), error = \(e) NA)
    data.frame(date = idx, rate_fillin = rate_to_fillin)
  })

  visa_df <- visa_na |>
    dplyr::left_join(visa_to_fillin |> dplyr::mutate(date = as.Date(date))) |>
    dplyr::filter(!is.na(rate_fillin)) |>
    dplyr::select(timestamp, visa_rate = rate_fillin)

  appendRDS("data/visa.rds", visa_df)
}
