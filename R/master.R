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
master_puppeteer <- function(exchgdate = as.Date(format(Sys.time(),
                               tz = "US/Pacific"
                             )),
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

#' Scraps currency exchange information for transactions using credit cards
#' issued by a MasterCard Europe bank.
#'
#' This used to work by a simple GET request with a properly parametrized URL
#' However, it stoped to work some time ago. So I had to move to a puppeteer
#' based scraping approach.
#'
#' @param exchgdate transaction date, format YYYY-mm-dd
#' @param crdhldBillCurr currency of the card
#' @param transCurr currency of the transaction
#' @param bankFee bank fee, [0, 1]
#' @trans_amount transaction amount (integer)
#'
#' @return exchange rate (numeric) in terms of transCurr / crdhldBillCurr
#' @export
#' @examples later
#' later
master <- function(
    exchgdate = as.Date(format(Sys.time(), tz = "US/Pacific")),
    crdhldBillCurr = "EUR",
    transCurr = "COP",
    bankFee = 0,
    trans_amount = sample(1e6:9e6, 1)) {
  # Luckily, you can AGAIN get the data with a properly parametrized get request
  site_url <- paste0(
    "https://www.mastercard.co.uk/settlement/currencyrate/conversion-rate?",
    "fxDate=", exchgdate, "&",
    "transCurr=", transCurr, "&",
    "crdhldBillCurr=", crdhldBillCurr, "&",
    "bankFee=", bankFee, "&",
    "transAmt=", trans_amount
  )

  # sometimes it redirects to a maintainance page. That page is an html,
  # then `resp_body_json` would fail. So just let it retry
  master_rates <- httr2::request(site_url) |>
    httr2::req_retry(
      max_tries = 5,
      is_transient = \(x) httr2::resp_content_type(x) != "application/json"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # master_rates$data$conversionRate
  trans_amount / master_rates$data$crdhldBillAmt
}

# At some point, master apparently introduced or removed
# one currency, which ended-up breaking the scraping approach
# It ended-up pulling the data from other currency. So we need
# to fix the rates for the period between
# 2023-05-01 (the date where the change was introduced, infering it from the data) and
# 2023-09-07 (today, when I finally decided to fix the thing)
one_time_fix <- function() {
  master_data <- readRDS("data/master.rds")

  library(dplyr)

  # just want to validate. It seem reasonably close
  probe_ok <- master_data |> slice(10)
  probe_ok
  master(as.Date(probe_ok$timestamp))

  # would need to replace the value of these more than 500 obs
  master_data |>
    dplyr::filter(timestamp >= "2023-05-01")

  # I guess if I just run a loop, my IP will be blocked, so I'll take things slow
  # First I will just invalidate those obs (assign NA to the rate value)
  # And then slowly will replace some of the values
  master_data_new <- master_data |>
    mutate(master_rate = case_when(
      timestamp > "2023-05-01" & timestamp <= "2023-07-09 16:30:45" ~ NA,
      TRUE ~ master_rate
    ))

  saveRDS(master_data_new, "data/master.rds")



  # Now, with the latest data (remember to pull from github, to get the latest values updated by github actions)
  # check which date have NA's and start replacing them,
  master_data <- readRDS("data/master.rds")

  master_missing <- master_data |>
    dplyr::filter(is.na(master_rate)) |>
    count(day = as.Date(timestamp))

  # ok, they are not that many values. just 83 when you group them by date (without time)
  master_replace <- master_missing |>
    slice_sample(n = 10) |>
    mutate(new_rate = purrr::map_dbl(day, ~ master(.x)))

  master_partially_fixed <- master_data |>
    mutate(day = as.Date(timestamp)) |>
    left_join(master_replace, by = "day") |>
    mutate(master_rate = coalesce(master_rate, new_rate)) |>
    select(-day, -new_rate, -n)

  saveRDS(master_partially_fixed, "data/master.rds")
}

# we may also want to get the reverse COP - EUR and EUR - COP
# But I did not do that before, so I would need to get the data from previous periods
reverse_onetime <- function() {
  # just to try, and since it's reversed, we need to do 1/x to make it comparable
  1 / master(crdhldBillCurr = "COP", transCurr = "EUR")

  # so let's get the data for the same days we have data for master
  # using just the day, not the timestamp because the request is per day
  master_data <- readRDS("data/master.rds")

  master_days <- master_data |>
    count(day = as.Date(timestamp))

  # we are gonna call this nu, because our nu card is a master card
  # and would correspond to crdhldBillCurr = "COP", and transCurr EUR
  # let's try all in one!, not sure if it will get blocked
  master_nu <- master_days |>
    mutate(new_rate = purrr::map_dbl(day, ~ master(.x, crdhldBillCurr = "COP", transCurr = "EUR")))

  nu <- master_data |>
    mutate(day = as.Date(timestamp)) |>
    left_join(master_nu, by = "day") |>
    mutate(nu_rate = 1 / new_rate) |>
    select(-day, -new_rate, -n, -master_rate)

  saveRDS(nu, "data/nu.rds")
}
