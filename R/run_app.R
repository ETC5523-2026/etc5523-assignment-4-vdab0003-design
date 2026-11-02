#' Launch the hospital infection explorer app
#'
#' Opens an interactive Shiny app that helps infection-prevention managers
#' decide which hospital-acquired infections to prioritise. Users can rank
#' infections by cases, deaths or healthy years lost (DALYs), compare
#' Germany with the European average, and switch between totals and rates
#' per 100,000 people.
#'
#' @param ... Arguments passed to [shiny::runApp()], for example
#'   `launch.browser = TRUE` to open the app in your web browser.
#'
#' @return Called for its side effect of starting the app. Returns nothing.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#'
#' @importFrom bslib page_sidebar
#' @importFrom ggplot2 ggplot
#' @export
run_app <- function(...) {
  # Find the app folder inside the installed package, wherever it is
  app_dir <- system.file("app", package = "haiexplorer")
  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling haiexplorer.",
         call. = FALSE)
  }
  shiny::runApp(app_dir, ...)
}
