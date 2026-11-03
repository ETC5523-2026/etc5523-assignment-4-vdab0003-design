
<!-- README.md is generated from README.Rmd. Please edit README.Rmd. -->

# haiexplorer

**haiexplorer** helps infection-prevention managers decide which
hospital-acquired infections to prioritise. It packages estimates of the
yearly burden of five common hospital-acquired infections in Germany and
across Europe, a function to rank them, and an interactive Shiny app.

The central question is: **which infections cause the most harm, and
does the priority order change depending on how harm is measured?** The
most common infection is not always the most harmful. In Germany,
urinary tract infections are the most frequent, but bloodstream
infections, which are the least frequent, cause almost a quarter of all
healthy years lost.

Documentation website:
<https://etc5523-2026.github.io/etc5523-assignment-4-vdab0003-design/>

## Installation

Install the package from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-vdab0003-design")
```

## Launch the app

``` r
library(haiexplorer)
run_app()
```

The app opens in a new window. Use the sidebar to choose how to rank
infections (cases, deaths or healthy years lost), the country, and
whether to show totals or rates per 100,000 people. The headline,
summary boxes and chart update to show which infection ranks first and
how its position compares with a ranking by number of cases.

## Example

`rank_infections()` orders infections by their burden and gives each
one’s share of the total. Ranked by number of cases, bloodstream
infections come last in Germany:

``` r
library(haiexplorer)
rank_infections(hai_burden, measure = "Cases")
#> # A tibble: 5 × 6
#>    rank infection     median  lower  upper share
#>   <int> <chr>          <dbl>  <dbl>  <dbl> <dbl>
#> 1     1 Urinary tract 213525 177470 259600 44.8 
#> 2     2 Pneumonia     106171  83077 134555 22.3 
#> 3     3 Surgical site  93650  74062 116669 19.7 
#> 4     4 C. difficile   36253  24824  50927  7.61
#> 5     5 Bloodstream    26767  17435  40243  5.62
```

Ranked by healthy years lost (DALYs), they rise to third and account for
almost a quarter of the total:

``` r
rank_infections(hai_burden, measure = "DALYs")
#> # A tibble: 5 × 6
#>    rank infection     median lower  upper share
#>   <int> <chr>          <dbl> <dbl>  <dbl> <dbl>
#> 1     1 Pneumonia      69900 32642 113617 28.5 
#> 2     2 Urinary tract  66373 28197 127111 27.0 
#> 3     3 Bloodstream    59428 30829 100661 24.2 
#> 4     4 Surgical site  28845 22902  35772 11.7 
#> 5     5 C. difficile   20977  1886  47794  8.54
```

## What is in the package

| Component | Description |
|----|----|
| `hai_burden` | Yearly cases, deaths and DALYs for five infections in Germany and Europe, as totals and per 100,000 people, with 95% uncertainty intervals |
| `hai_rates` | Infections per 100 hospital patients on the survey day (the risk for each patient) |
| `hai_counts` | Patients with each infection on the survey day, by age group and sex |
| `rank_infections()` | Ranks infections by a chosen measure and returns each one’s share of the total |
| `run_app()` | Launches the interactive Shiny app |

A **DALY** (disability-adjusted life year) is one year of healthy life
lost, counting both early death and time lived in poor health.

## Data source

The data come from the ECDC point prevalence survey of hospital-acquired
infections (2011-12), as analysed by Zacher et al. (2019) and
distributed in the [BHAI](https://CRAN.R-project.org/package=BHAI) R
package (GPL-3). The script in `data-raw/hai.R` imports the survey data
from BHAI, runs 1,000 simulations to estimate cases, deaths and DALYs,
and saves the tidy datasets included in this package.

Zacher B, Haller S, Willrich N, et al. (2019). Application of a new
methodology and R package reveals a high burden of healthcare-associated
infections (HAI) in Germany compared to the average in the European
Union/ European Economic Area, 2011 to 2012. *Eurosurveillance*, 24(46),
1900135.

**Limitation:** the estimates are scaled up from a one-day survey and
rely on limited evidence about the outcomes of each infection, so deaths
and DALYs have wide uncertainty ranges. Where the ranges of two
infections overlap, their order may not be reliable.

## Generative AI declaration

I used generative AI tool while preparing this assignment:

- **Claude (Anthropic):** to help write and refine parts of the Shiny
  app (`inst/app/app.R`) and to help diagnose and fix bugs and notes
  reported by `devtools::check()`. Also, draft the roxygen2
  documentation and this README

I checked, tested and revised all generated code and text, and I
understand how each part of the package works.
