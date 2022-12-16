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
        URL = format(exchgdate, format = "%m/%d/%Y"),
        reserved = TRUE
    ), "&",
    "exchangedate=", utils::URLencode(
        URL = format(exchgdate, format = "%m/%d/%Y"),
        reserved = TRUE
    ), "&",
    "fromCurr=", currcard, "&",
    "toCurr=", currtrans
  )
  
  # now it's easier, just get a json
  visa_rates <- jsonlite::fromJSON(site_url)
  
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
