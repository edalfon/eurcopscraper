#' Ingest all RDS exchange rate data files and row-bind them together
#'
#' The `ingest_all_rds` function reads multiple RDS files containing exchange
#' rate data, preprocesses each data frame to set common columns and
#' identify the source, and then binds them together into
#' a single data frame.
#'
#' @return A data frame containing exchange rate data from all processed
#' RDS files, including the columns:
#' * timestamp
#' * source
#' * rate
#' * direction
#'
#' @export
ingest_all_rds <- function() {
  vancouver_df <- readRDS("data/vancouver.rds") |>
    dplyr::filter(stringr::str_detect(moneda, "EUR")) |>
    dplyr::mutate(source = paste0("Vancouver ", moneda)) |>
    dplyr::mutate(direction = "COP -> EUR") |>
    dplyr::select(timestamp, source, rate = valor_venta, direction)

  visa_df <- readRDS("data/visa.rds") |>
    dplyr::mutate(source = "Visa") |>
    dplyr::mutate(direction = "EUR -> COP") |>
    dplyr::select(timestamp, source, rate = visa_rate, direction)

  master_df <- readRDS("data/master.rds") |>
    dplyr::mutate(source = "Master") |>
    dplyr::mutate(direction = "EUR -> COP") |>
    dplyr::select(timestamp, source, rate = master_rate, direction)

  nu_df <- readRDS("data/nu.rds") |>
    dplyr::mutate(source = "Nu") |>
    dplyr::mutate(direction = "COP -> EUR") |>
    dplyr::select(timestamp, source, rate = nu_rate, direction)

  condor_df <- readRDS("data/condor.rds") |>
    dplyr::filter(stringr::str_detect(moneda, "EUR")) |>
    dplyr::mutate(source = paste0("Condor ", moneda)) |>
    dplyr::mutate(direction = "COP -> EUR") |>
    dplyr::select(timestamp, source, rate = venta, direction)

  comdirect_df <- readRDS("data/comdirect.rds") |>
    dplyr::filter(iso == "COP") |>
    dplyr::mutate(source = "Comdirect") |>
    dplyr::mutate(direction = "EUR -> COP") |>
    dplyr::select(timestamp, source, rate = geld, direction)

  kapital_df <- readRDS("data/kapital.rds") |>
    dplyr::filter(stringr::str_detect(moneda, "EUR")) |>
    dplyr::mutate(source = paste0("Kapital ", moneda)) |>
    dplyr::mutate(direction = "COP -> EUR") |>
    dplyr::select(timestamp, source, rate = venta, direction)

  eurcop_df <- dplyr::bind_rows(
    vancouver_df, visa_df, master_df, condor_df, comdirect_df, kapital_df, nu_df
  )

  eurcop_df
}
