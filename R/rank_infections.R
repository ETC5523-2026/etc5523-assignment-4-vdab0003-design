#' Rank hospital-acquired infections by their burden
#'
#' Orders the five infections from largest to smallest burden for one
#' country, measure and scale, and gives each infection's share of the
#' total. Use it to see whether the priority order changes when harm is
#' measured by cases, deaths or healthy years lost (DALYs).
#'
#' @param data A data frame shaped like [hai_burden], with columns
#'   `country`, `infection`, `measure`, `scale`, `median`, `lower` and
#'   `upper`.
#' @param measure How to measure burden: `"Cases"`, `"Deaths"` or
#'   `"DALYs"`. Defaults to `"DALYs"` because it combines deaths and
#'   illness into one measure of harm.
#' @param country `"Germany"` or `"Europe"`.
#' @param scale `"Total"` for whole-population numbers, or
#'   `"Per 100,000 people"` to compare countries of different sizes.
#' @param infections Optional character vector of infections to include.
#'   `NULL` (the default) keeps all five.
#'
#' @return A tibble with one row per infection, ordered from largest to
#'   smallest burden:
#'   \describe{
#'     \item{rank}{1 = largest burden.}
#'     \item{infection}{Infection type.}
#'     \item{median, lower, upper}{Best estimate and 95% uncertainty
#'       interval.}
#'     \item{share}{Percentage of the total burden of the selected
#'       infections.}
#'   }
#'   If `infections` is empty, a tibble with zero rows is returned.
#'
#' @examples
#' # Ranked by healthy years lost, bloodstream infections are 3rd
#' rank_infections(hai_burden, measure = "DALYs")
#'
#' # Ranked by number of cases, they drop to last
#' rank_infections(hai_burden, measure = "Cases")
#'
#' # Compare Germany with Europe fairly, per 100,000 people
#' rank_infections(hai_burden, country = "Europe", scale = "Per 100,000 people")
#'
#' @importFrom dplyr filter arrange desc mutate row_number select
#' @importFrom rlang .data .env
#' @export
rank_infections <- function(data,
                            measure = "DALYs",
                            country = "Germany",
                            scale = "Total",
                            infections = NULL) {
  # Stop early with a clear message rather than returning an empty table
  measure <- match.arg(measure, c("Cases", "Deaths", "DALYs"))
  scale <- match.arg(scale, c("Total", "Per 100,000 people"))
  if (!country %in% data$country) {
    stop("`country` must be one of: ",
         paste(unique(data$country), collapse = ", "), call. = FALSE)
  }
  if (is.null(infections)) {
    infections <- unique(data$infection)
  }

  data |>
    filter(
      .data$country == .env$country,
      .data$measure == .env$measure,
      .data$scale == .env$scale,
      .data$infection %in% .env$infections
    ) |>
    arrange(desc(.data$median)) |>
    # Share is of the selected infections, so it always adds to 100%
    mutate(
      rank  = row_number(),
      share = .data$median / sum(.data$median) * 100
    ) |>
    select("rank", "infection", "median", "lower", "upper", "share")
}
