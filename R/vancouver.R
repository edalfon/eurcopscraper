#' Scraps currency exchange information from Cambios Vancouver
#'
#' Check out this link:
#' http://www.cambiosvancouver.com/tasa-de-cambio-del-dia/
#'
#' @return exchange rate (numeric) in terms of COP/EUR
#' @export
vancouver <- function() {
  rvested <- xml2::read_html("https://cambiosvancouver.com")

  # I used to do this using html_nodes() using selectors obtained via
  # selectorgadget.com, but it ends up being less mantainable
  # (e.g. new currency changes the order of the table), so let's scrape
  # now the whole table
  # exchangetable <- rvest::html_table(rvested, convert = FALSE) |>
  #   dplyr::bind_rows() |> # for some reason, it gets two tables
  #   dplyr::distinct() |> # so let's just append them and remove duplicates
  #   dplyr::mutate(dplyr::across(
  #     .cols = dplyr::everything(),
  #     .fns = ~ .x |>
  #       gsub(.x, pattern = ",", replacement = "") |>
  #       gsub(pattern = "\\.", replacement = "") |>
  #       gsub(pattern = "\\$", replacement = "") |>
  #       stringr::str_trim()
  #   )) |>
  #   dplyr::mutate(dplyr::across(dplyr::contains("Valor"), .fns = as.numeric)) |>
  #   janitor::clean_names()

  # gotta go back to using selectors, because the whole table, there is always
  # like a placeholder table there that never changes values
  exchangetable <- rvested |>
    rvest::html_nodes(".e-con-inner .e-grid") |>
    rvest::html_text2() |>
    unique() |>
    stringr::str_replace("País\nMoneda", "País-Moneda") |>
    stringr::str_replace_all(pattern = "\n", replacement = "\t") |>
    paste0(collapse = "\n") |>
    readr::read_tsv(
      col_names = c("moneda", "valor_compra", "valor_venta"),
      skip = 1
    ) |>
    dplyr::mutate(
      moneda = dplyr::case_when(
        moneda == "Euro 100 (EUR)" ~ "Euro  (EUR) 100",
        moneda == "Euro 200 (US)" ~ "Euro (EUR) 200",
        moneda == "Euro 50 (EUR)" ~ "Euro (EUR) 50",
        moneda == "Euro 500 (US)" ~ "Euro (EUR) 500",
        TRUE ~ moneda
      )
    )

  # Ths would be based on pupetteer
  # vancouver_html <- system2(
  #   command = "node",
  #   args = c(
  #     "JS/screenshot.js",
  #     "https://cambiosvancouver.com/#tab",
  #     "logs/vancouver.png"
  #   ),
  #   stdout = TRUE
  # )

  # rvest::html_table(
  #   xml2::read_html(paste(vancouver_html, collapse = "")),
  #   convert = FALSE
  # )

  exchangetable
}


#' OLD version Scraps currency exchange information from Cambios Vancouver
#'
#' Check out this link:
#' http://www.cambiosvancouver.com/tasa-de-cambio-del-dia/
#'
#' @return exchange rate (numeric) in terms of COP/EUR
#' @export
#' @examples later
#' later
vancouverexchange <- function() {
  print("VANCOUVER ...")

  # scrap the information
  rvested <- xml2::read_html("https://cambiosvancouver.com/tasas-del-dia/")

  ratesdf <- NULL
  ratesdf$vancouver <- rvested |>
    # CSS selector found using the awesome http://selectorgadget.com/
    # rvest::html_nodes("#page89_container54") |> OLD THEY UPDATE THE PAGE
    rvest::html_nodes("tr:nth-child(3) td:nth-child(4)") |>
    rvest::html_text() |>
    gsub(pattern = ",", replacement = "") |>
    gsub(pattern = "\\.", replacement = "") |>
    gsub(pattern = "\\$", replacement = "") |>
    stringr::str_trim() |>
    as.numeric()
  ratesdf$vancouver5 <- rvested |>
    # CSS selector found using the awesome http://selectorgadget.com/
    # rvest::html_nodes("#page89_container55") |>
    rvest::html_nodes(".animated , tr:nth-child(4) td:nth-child(4)") |>
    rvest::html_text() |>
    gsub(pattern = ",", replacement = "") |>
    gsub(pattern = "\\.", replacement = "") |>
    gsub(pattern = "\\$", replacement = "") |>
    stringr::str_trim() |>
    as.numeric()

  ratesdf
}
