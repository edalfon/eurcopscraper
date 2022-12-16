
#' Scraps currency exchange information from https://cambioskapital.com/
#'
#' Check out this link:
#' https://cambioskapital.com/
#'
#' @return exchange rate (numeric) in terms of COP/EUR
#' @export
kapital <- function() {
  
  # scrap the information
  rvested <- xml2::read_html("https://cambioskapital.com/")

  compra <- rvested |> 
    rvest::html_nodes(".banderpre1:nth-child(2) b") |>
    rvest::html_text() |>
    stringr::str_remove("\\.") |>
    stringr::str_remove("\\$") |> 
    as.numeric()

  venta <- rvested |> 
    rvest::html_nodes("br~ .banderpre1 b") |>
    rvest::html_text() |>
    stringr::str_remove("\\.") |>
    stringr::str_remove("\\$") |> 
    as.numeric()

  moneda <- rvested |> 
    rvest::html_nodes("#eluidd9ec0bb1 strong") |>
    rvest::html_text()  

  ratesdf <- data.frame(moneda = moneda, compra = compra, venta = venta)

  ratesdf
}
