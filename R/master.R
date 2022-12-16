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
master <- function(exchgdate = as.Date(format(Sys.time(), 
                   tz = "US/Pacific")),
                   currcard = "EUR", 
                   currtrans = "COP") {
  
  print("I need node js installed (node in path) and puppeteer installed (npm i puppeteer) in the currency_scraping directory")
  
  puppeteer_script <- "JS/master.js"
  
  # TODO: pass parameters
  master_conv <- system2(command = "node", args = puppeteer_script, stdout = TRUE) # , timeout = 120
  # TODO: let them fail

  print(master_conv)

  master_conv <- master_conv |>
    paste(collapse = " ") |>
    gsub(pattern = "[a-z]|,", replacement = "", ignore.case = TRUE) |>
    as.numeric()

  master_rate <- 7777777 / master_conv # this is hard coded in master.js

  master_rate
}
