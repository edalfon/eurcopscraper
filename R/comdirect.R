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


#' Scraps currency exchange information for transactions using VISA credit card
#' issued by Comdirect
#'
#' Check out this link:
#' https://www.commerzbank.de/de/hauptnavigation/kunden/kursinfo/devisenk/weitere_waehrungen___indikative_kurse/indikative_kurse.jsp
#'
#' @param exchgdate transaction date (leave NULL for the latest data available)
#'
#' @return exchange rate (numeric) in terms of 1 currcard = X currtrans

#' @export
#' @examples later
#' later
comdirectexchange <- function(exchgdate = NULL) {
  
  print("COMDIRECT ...")
  
  if (is.null(exchgdate)) {
    exchgdate <- ""
  } else {
    exchgdate <- format(exchgdate, "%d.%m.%Y")
  }
  
  # need to get a handle to PhantomJS executable to download the web page via a post request
  phantomjs_ex <- paste0(system.file("phantomjs", package = "efunc"),
                         "/phantomjs")
  
  # build the args like [script exchange date]
  phantomjs_args <- paste0(system.file("currency_scraping/comdirect.js", package = "efunc"),
                           " ", exchgdate)
  
  # Then use the system fuction to call the phantomjs executable
  comdirect <- system2(command = phantomjs_ex, args = phantomjs_args, stdout = TRUE)
  
  # Do it again for the currencies (not the weitere)
  phantomjs_args <- paste0(system.file("currency_scraping/comdirect2.js", package = "efunc"),
                           " ", exchgdate)
  
  # Then use the system fuction to call the phantomjs executable
  comdirect <- system2(command = phantomjs_ex, args = phantomjs_args, stdout = TRUE)
  
  # Now, use rvest package to read the downloaded page visa.html and
  # scrap the information
  rvested <- xml2::read_html("comdirect.html")
  ratesdf <- rvested %>%
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes("table") %>%
    rvest::html_table() %>%
    purrr::pluck(1) # could've simply used .[[1]], but purrr let you give default value
  
  rvested <- xml2::read_html("comdirect2.html")
  ratesdf <- rvested %>%
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes("table") %>%
    rvest::html_table() %>%
    purrr::pluck(1) %>%
    rbind(ratesdf)
  
  ratesdf$Brief <- ratesdf$Brief %>%
    gsub(pattern = "\\.", replacement = "") %>%
    gsub(pattern = ",", replacement = "\\.") %>%
    as.numeric()
  
  ratesdf$Geld <- ratesdf$Geld %>%
    gsub(pattern = "\\.", replacement = "") %>%
    gsub(pattern = ",", replacement = "\\.") %>%
    as.numeric()
  
  ratesdf$Mittelkurs <- ratesdf$Mittelkurs %>%
    gsub(pattern = "\\.", replacement = "") %>%
    gsub(pattern = ",", replacement = "\\.") %>%
    as.numeric()
  
  ratesdf
}
