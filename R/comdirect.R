#' Scraps currency exchange information from comdirect
#'
#' Check out this link:
#' https://www.commerzbank.com/de/hauptnavigation/kunden/kursinfo/devisenk/weitere_waehrungen___indikative_kurse/indikative_kurse.html
#'
#' @return exchange rate (numeric) in terms of COP/EUR
#' @export
comdirect <- function() {
  
  puppeteer_script <- "JS/comdirect.js"
  
  comdirect_html <- system2(command = "node", args = puppeteer_script, stdout = TRUE)
  
  ratesdf <- comdirect_html |>
    paste(collapse = "") |>
    xml2::read_html() |>
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_table() |>
    dplyr::bind_rows() |> # for some reason, it gets two tables
    dplyr::distinct() |> # so let's just append them and remove duplicates
    janitor::clean_names() |>
    dplyr::filter(iso == "COP") |>
    dplyr::mutate(dplyr::across(c(mittelkurs, geld, brief), .fns = ~ .x |> 
      gsub(pattern = "\\.", replacement = "") |>
      gsub(pattern = ",", replacement = "\\.") |>
      stringr::str_trim() |>
      as.numeric()
    ))  
  
  ratesdf
}