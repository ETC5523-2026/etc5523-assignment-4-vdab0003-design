# Yearly burden of hospital-acquired infections: cases, deaths and DALYs

Estimated new cases, deaths and disability-adjusted life years (DALYs)
per year for five hospital-acquired infections in Germany and Europe, as
national totals and per 100,000 population.

## Usage

``` r
hai_burden
```

## Format

A tibble with 60 rows and 7 variables:

- country:

  "Germany" or "Europe".

- infection:

  One of five infection types.

- measure:

  "Cases" (new infections per year), "Deaths" (deaths caused by the
  infection) or "DALYs" (healthy years lost).

- scale:

  "Total" (whole population) or "Per 100,000 people" (adjusted for
  population size, so countries can be compared).

- median:

  Best estimate: the median of 1,000 simulations.

- lower:

  Lower end of the 95% uncertainty interval.

- upper:

  Upper end of the 95% uncertainty interval.

## Source

Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R package:
<https://CRAN.R-project.org/package=BHAI>. Prepared in `data-raw/hai.R`.

## Details

A DALY is one year of healthy life lost. It adds years lost to early
death and years lived in poor health, so infections can be compared by
the harm they cause rather than by how often they occur.

Estimates were produced with `BHAI::bhai()` (1,000 simulations, seed
2026), which converts a one-day survey into yearly figures. Wide
intervals, especially for deaths and DALYs, reflect limited evidence
about the outcomes of each infection. Where the Germany and Europe
intervals overlap, the difference may not be real.
