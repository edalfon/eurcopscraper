#' Scraps currency exchange information from Cambios Condor
#'
#' Check out this link:
#' http://www.elcondorcambios.com/
#'
#' @return exchange rate (numeric) in terms of COP/EUR
#' @export
condor <- function() {
  
  puppeteer_script <- "JS/condor.js"
  
  condor_html <- system2(command = "node", args = puppeteer_script, stdout = TRUE)
  
  ratesdf <- condor_html |>
    paste(collapse = "") |>
    xml2::read_html() |>
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes("#tasas") |>
    rvest::html_table() |>
    dplyr::bind_rows() |> # for some reason, it gets two tables
    dplyr::distinct() |> # so let's just append them and remove duplicates
    janitor::clean_names() |>
    dplyr::mutate(dplyr::across(c(compra, venta), .fns = ~ .x |> 
      gsub(.x, pattern = ",", replacement = "") |> 
      gsub(pattern = "\\$", replacement = "") |>
      stringr::str_trim() |>
      as.numeric()
    ))  
  
  ratesdf
}


condorexchange <- function() {
  
  print("CONDOR ...")
  
  puppeteer_script <- system.file("currency_scraping/condor.js", package = "efunc")
  
  condor <- system2(command = "node", args = puppeteer_script,
                    stdout = TRUE) # , timeout = 120
  
  ratesdf <- condor %>%
    paste(collapse = "") %>%
    xml2::read_html() %>%
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes("tr~ tr+ tr .tasas~ td+ td b") %>%
    rvest::html_text() %>%
    readr::parse_number()
  
  # scrap the information
  # rvested <- xml2::read_html("http://www.elcondorcambios.com/")
  # ratesdf <- rvested %>%
  # 	# CSS selector found using the awesome http://selectorgadget.com/
  #   rvest::html_nodes("tr~ tr+ tr .tasas~ td+ td b") %>%
  #   rvest::html_text() %>%
  # 	paste(collapse = "") %>% #porque el cero queda separado, .., raro pero
  # 	readr::parse_number()
  
  ratesdf
  
}


