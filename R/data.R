#' Patients with a hospital-acquired infection, by age and sex
#'
#' The number of patients who had each of five hospital-acquired infections
#' on the day of the point prevalence survey, split by age group and sex,
#' for Germany and for the European average.
#'
#' @format A data frame with 380 rows and 5 variables:
#' \describe{
#'   \item{country}{"Germany" (representative sample of 46 hospitals) or
#'     "Europe" (ECDC survey across EU/EEA countries).}
#'   \item{infection}{One of five infection types: Pneumonia, Surgical site,
#'     Bloodstream, Urinary tract or C. difficile.}
#'   \item{age_group}{Patient age group in years, e.g. "60-64"; "Under 1"
#'     for infants and "85+" for the oldest group.}
#'   \item{sex}{"Female" or "Male".}
#'   \item{hai_patients}{Number of surveyed patients with that infection on
#'     the survey day.}
#' }
#'
#' @details These are raw survey counts, not national estimates. Many age
#'   and sex groups have counts of 0 to 5, so differences between small
#'   groups should not be over-interpreted.
#'
#' @source Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R
#'   package: <https://CRAN.R-project.org/package=BHAI>.
#'   Prepared in `data-raw/hai.R`.
"hai_counts"

#' Infections per 100 hospital patients
#'
#' The share of surveyed patients who had each infection on the survey day.
#' This measures the risk for an individual patient, regardless of how many
#' people a country admits to hospital.
#'
#' @format A data frame with 10 rows and 5 variables:
#' \describe{
#'   \item{country}{"Germany" or "Europe".}
#'   \item{infection}{One of five infection types.}
#'   \item{hai_patients}{Number of surveyed patients with the infection.}
#'   \item{survey_patients}{Total number of patients surveyed.}
#'   \item{per_100_patients}{`hai_patients / survey_patients * 100`: out of
#'     every 100 patients in hospital on the survey day, how many had this
#'     infection.}
#' }
#'
#' @details This is prevalence (patients infected on one day), not the
#'   number of new infections per year. It is the "per patient" view used
#'   to compare how safe hospitals are for each person treated.
#'
#' @source Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R
#'   package: <https://CRAN.R-project.org/package=BHAI>.
#'   Prepared in `data-raw/hai.R`.
"hai_rates"

#' Yearly burden of hospital-acquired infections: cases, deaths and DALYs
#'
#' Estimated new cases, deaths and disability-adjusted life years (DALYs)
#' per year for five hospital-acquired infections in Germany and Europe,
#' as national totals and per 100,000 population.
#'
#' A DALY is one year of healthy life lost. It adds years lost to early
#' death and years lived in poor health, so infections can be compared
#' by the harm they cause rather than by how often they occur.
#'
#' @format A tibble with 60 rows and 7 variables:
#' \describe{
#'   \item{country}{"Germany" or "Europe".}
#'   \item{infection}{One of five infection types.}
#'   \item{measure}{"Cases" (new infections per year), "Deaths"
#'     (deaths caused by the infection) or "DALYs" (healthy years lost).}
#'   \item{scale}{"Total" (whole population) or "Per 100,000 people"
#'     (adjusted for population size, so countries can be compared).}
#'   \item{median}{Best estimate: the median of 1,000 simulations.}
#'   \item{lower}{Lower end of the 95% uncertainty interval.}
#'   \item{upper}{Upper end of the 95% uncertainty interval.}
#' }
#'
#' @details Estimates were produced with `BHAI::bhai()` (1,000 simulations,
#'   seed 2026), which converts a one-day survey into yearly figures.
#'   Wide intervals, especially for deaths and DALYs, reflect limited
#'   evidence about the outcomes of each infection. Where the Germany and
#'   Europe intervals overlap, the difference may not be real.
#'
#' @source Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R
#'   package: <https://CRAN.R-project.org/package=BHAI>.
#'   Prepared in `data-raw/hai.R`.
"hai_burden"
