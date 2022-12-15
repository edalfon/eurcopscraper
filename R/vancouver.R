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
  exchangetable <- rvest::html_table(rvested, convert = FALSE) |>
    dplyr::bind_rows() |> # for some reason, it gets two tables
    dplyr::distinct() |> # so let's just append them and remove duplicates
    dplyr::mutate(dplyr::across(.fns = ~ .x |> 
      gsub(.x, pattern = ",", replacement = "") |> 
      gsub(pattern = "\\.", replacement = "") |>
      gsub(pattern = "\\$", replacement = "") |>
      stringr::str_trim()
    )) |>
    dplyr::mutate(dplyr::across(dplyr::contains("Valor"), .fns = as.numeric)) |>
    janitor::clean_names()
  
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


