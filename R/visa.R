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
visaexchange <- function(exchgdate = as.Date(format(Sys.time(),
                         tz = "US/Pacific")),
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
  
  rvested <- xml2::read_html(site_url)
  
  card_amount <- rvested |>
    # CSS selector found using the awesome http://selectorgadget.com/
    rvest::html_nodes(".converted-amount-value") |>
    rvest::html_text() |>
    readr::parse_number() #last or something
  
  rate <- trans_amount / card_amount
  
  rate
}
