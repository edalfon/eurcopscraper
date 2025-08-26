#' Retrieve EUR to COP exchange rate from open.er-api.com
#'
#' Fetches the latest exchange rate between Euro (EUR) and Colombian Peso (COP)
#' using the free API available at https://open.er-api.com/v6/latest/EUR.
#'
#' @return Numeric exchange rate expressed as COP per EUR
#' @export
er_api <- function() {
  api_url <- "https://open.er-api.com/v6/latest/EUR"

  resp <- jsonlite::fromJSON(api_url)
  if (!identical(resp$result, "success")) {
    stop("ER API request failed: ", resp$result)
  }

  resp$rates$COP
}

