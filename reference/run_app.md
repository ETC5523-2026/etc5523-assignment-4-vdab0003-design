# Launch the hospital infection explorer app

Opens an interactive Shiny app that helps infection-prevention managers
decide which hospital-acquired infections to prioritise. Users can rank
infections by cases, deaths or healthy years lost (DALYs), compare
Germany with the European average, and switch between totals and rates
per 100,000 people.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `launch.browser = TRUE` to open the app in your web browser.

## Value

Called for its side effect of starting the app. Returns nothing.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
