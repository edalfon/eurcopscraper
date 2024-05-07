#' Scraps currency exchange information for transactions using credit cards
#' issued by a Visa Europe bank.
#'
#' Check out this link:
#' http://www.visaeurope.com/making-payments/exchange-rates
#' It assumes 0% conversion fee and a purchase amount of 100 in the card's
#' currency.
#'
#' @param exchgdate transaction date
#' @param currcard currency of the card
#' @param currtrans currency of the transaction
#'
#' @return exchange rate (numeric) in terms of 1 currcard = X currtrans
#' @export
visa <- function(exchgdate = as.Date(format(Sys.time(), tz = "US/Pacific")),
                 currcard = "EUR",
                 currtrans = "COP",
                 trans_amount = sample(1e6:9e6, 1)) {
  # Luckily, you can get the data with a properly parametrized get request
  site_url <- paste0(
    "https://www.visa.co.uk/cmsapi/fx/rates?",
    "amount=", trans_amount, "&",
    "fee=0", "&",
    "utcConvertedDate=", utils::URLencode(
      URL = format(as.Date(exchgdate), format = "%m/%d/%Y"),
      reserved = TRUE
    ), "&",
    "exchangedate=", utils::URLencode(
      URL = format(as.Date(exchgdate), format = "%m/%d/%Y"),
      reserved = TRUE
    ), "&",
    "fromCurr=", currcard, "&",
    "toCurr=", currtrans
  )

  cat(site_url, "\n", file = "logs/visa_links.txt", append = TRUE, sep = "")
  # visa_html <- system2(
  #   command = "node",
  #   args = c("JS/screenshot.js", paste0("'", site_url, "'"), "logs/visa.png"),
  #   stdout = TRUE
  # )

  # we cannot simply use jsonlite::fromJSON anymore, because it internally
  # uses base::url to fetch the data and does not let you configure much
  # of the request. And we need to change the user agent, or it would fail
  # with a 403 error
  visa_rates <- httr2::request(site_url) |>
    httr2::req_headers("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36") |>
    # httr2::req_retry(
    #   max_tries = 5,
    #   is_transient = \(x) httr2::resp_content_type(x) != "application/json"
    # ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  visa_rates$reverseAmount |>
    gsub(pattern = ",", replacement = "") |>
    as.numeric()
}





# old versions here, make it faster to check if they go back to any version of
# the web site, compared to go git my way backwards
visa_rvest <- function(exchgdate = as.Date(format(Sys.time(), tz = "US/Pacific")),
                       currcard = "EUR",
                       currtrans = "COP",
                       trans_amount = 7777777) {
  # Luckily, you can get the data with a properly parametrized get request
  site_url <- paste0(
    "https://www.visa.co.uk/support/consumer/travel-support/",
    "exchange-rate-calculator.html?",
    "amount=", trans_amount, "&",
    "fee=0", "&",
    "exchangedate=", utils::URLencode(
      URL = format(exchgdate, format = "%m/%d/%Y"),
      reserved = TRUE
    ), "&",
    "fromCurr=", currcard, "&",
    "toCurr=", currtrans, "&",
    "submitButton=Calculate+exchange+rate"
  )

  # now the page asks to authorize cookies and puts a blank canvas that
  # does not let rvest to read the contents of the page. So we need to
  # authorize the cookies.
  # Using Chrome's developer tools -> Application -> Cookies, and comparing
  # before and after authorizing, found this cookie name and value
  # (the value also included a visitor and version parameters, but still works)
  httr::set_config(httr::set_cookies(
    wscrCookieConsent = "1=true&2=true&3=true&4=true&5=true"
  ))
  rvested <- xml2::read_html(site_url)

  rate <- rvested |>
    # CSS selector found using the awesome http://selectorgadget.com/
    # rvest::html_nodes("#er_result_table") |> #whole text, would need wrangling
    rvest::html_nodes(".converted-amount-value:nth-child(6)") |>
    rvest::html_text() |> # here it looks like "5,087.215217 Colombian Peso"
    gsub(pattern = "[a-z]|,", replacement = "", ignore.case = TRUE) |>
    as.numeric()

  rate
}


visaexchange_old <- function(exchgdate = Sys.Date(),
                             currcard = "EUR", currtrans = "COP") {
  print("VISA ...")
  # Let's keep everything in this directory
  setwd("/NO_EXISTO")

  fix_exchgdate <- lubridate::`%within%`(Sys.time(), lubridate::interval(
    start = paste(Sys.Date(), "00:00:00"),
    end = paste(Sys.Date(), "04:00:00"),
    tzone = "Europe/Berlin"
  ))

  if (fix_exchgdate) {
    exchgdate <- Sys.Date() - 1
  }

  # this uses PhantomJS to download the web page via a post request
  # so, phantomjs executable must be in the working directory as well
  # as the phantomjs script designed to request (post), download and save
  # the page in a file called visa.html
  phantomjs_ex <- paste0(
    system.file("phantomjs", package = "efunc"),
    "/phantomjs"
  )

  # First, build the command following the syntaxis:
  # phantomjs_executable transaction_date currency1 currency2

  # ARREGLAR QUE SI SE HACE DESPUES DE MEDIA NOCHE NO SIRVE
  # if (Sys.time()) {
  # 	exchgdate <- exchgdate - 1
  # }
  phantomjs_args <- paste("visa.js",
    format(exchgdate, "%d/%m/%Y"),
    currcard, currtrans,
    sep = " "
  )
  # Then use the system fuction to call the phantomjs executable
  visa <- system2(
    command = phantomjs_ex, args = phantomjs_args,
    stdout = TRUE
  )

  # Now, use rvest package to read the downloaded page visa.html and
  # scrap the information
  library(rvest)
  rvested <- xml2::read_html("visa.html")
  rvested %>%
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes(".text-center:nth-child(5) strong+ strong") %>%
    rvest::html_text() %>%
    gsub(pattern = ",", replacement = "") %>%
    as.numeric()
}


# visaexchange_old2 <- function(exchgdate = Sys.Date(),
#                               currcard = "EUR", currtrans = "COP") {
#   print("VISA ...")

#   library(RSelenium)
#   library(magrittr)
#   pJS <- phantom(pjs_cmd = system.file("phantomjs", "phantomjs",
#                                        package = "efunc")) # start phantomjs
#   remDr <- remoteDriver(browserName = "phantomjs")
#   remDr$open(silent = FALSE)

#   appURL <- "https://www.visaeurope.com/making-payments/exchange-rates"
#   remDr$navigate(appURL)

#   remDr$findElement(
#     using = "xpath",
#     value = paste(
#       "//*[(@id = 'MainContent_MainContent_ctl00_ddlCardCurrency')]",
#       "/option[@value = '", currcard ,"']", sep = "")
#   )$clickElement()

#   remDr$findElement(
#     using = "xpath",
#     value = paste(
#       "//*[(@id = 'MainContent_MainContent_ctl00_ddlTransactionCurrency')]",
#       "/option[@value = '", currtrans ,"']", sep = "")
#   )$clickElement()

#   remDr$findElement(
#     using = "id",
#     value = "MainContent_MainContent_ctl00_txtDate"
#   )$sendKeysToElement(list(selKeys$control, "a", selKeys$clear))

#   remDr$findElement(
#     using = "id",
#     value = "MainContent_MainContent_ctl00_txtDate"
#   )$sendKeysToElement(list(format(exchgdate-11, "%d/%m/%Y")))

#   remDr$findElement(
#     using = "id",
#     value = "MainContent_MainContent_ctl00_btnSubmit"
#   )$clickElement()


#   #remDr$screenshot(display = TRUE, useViewer = TRUE, file = NULL)

#   exchrate_value <- remDr$findElement(
#     using = "css selector",
#     value = ".text-center:nth-child(5) strong+ strong"
#   )$getElementText() %>%
#     gsub(pattern = ",", replacement = "") %>%
#     as.numeric()

#   remDr$close()

#   exchrate_value
# }

#' Scraps currency exchange information for transactions using credit cards
#' issued by a Visa Europe bank.
#'
#' Check out this link:
#' http://www.visaeurope.com/making-payments/exchange-rates
#' It assumes 0% conversion fee and a purchase amount of 100 in the card's
#' currency.
#'
#' @param exchgdate transaction date
#' @param currcard currency of the card
#' @param currtrans currency of the transaction
#'
#' @return exchange rate (numeric) in terms of 1 currcard = X currtrans
#' @export
#' @examples later
#' later
# visaexchange_old3 <- function(exchgdate = as.Date(format(Sys.time(), tz = "US/Pacific")),
#' #                              currcard = "EUR", currtrans = "COP") {
#' #  print("VISA ...")
#' #  site_url <- "https://www.visaeurope.com/making-payments/exchange-rates"
#' #  site_session <- rvest::html_session(url = site_url)
#' #  site_form <- rvest::html_form(site_session)[[1]]
#' #  site_form$url <- site_url
#' #  site_form <- rvest::set_values(
#' #    form = site_form,
#' #    "ctl00$ctl00$MainContent$MainContent$ctl00$ddlCardCurrency" = currcard)
#' #  site_form <- rvest::set_values(
#' #    form = site_form,
#' #    "ctl00$ctl00$MainContent$MainContent$ctl00$ddlTransactionCurrency" =
#' #      currtrans)
#' #  site_form <- rvest::set_values(
#' #    form = site_form,
#' #    "ctl00$ctl00$MainContent$MainContent$ctl00$txtDate" =
#' #      format(exchgdate, "%d/%m/%Y"))
#' #  site_response <- rvest::submit_form(
#' #    session = site_session, form = site_form,
#' #    submit = "ctl00$ctl00$MainContent$MainContent$ctl00$btnSubmit")
#' #  library(magrittr)
#' #  site_response %>%
#' #    rvest::html_nodes(".text-center:nth-child(5) strong+ strong") %>%
#' #    rvest::html_text() %>%
#' #    gsub(pattern = ",", replacement = "") %>%
#' #    as.numeric() %>%
#' #    ensurer::ensure_that(length(.)>0,
#' #                         err_desc = "Something went wrong with VISA")
# }
