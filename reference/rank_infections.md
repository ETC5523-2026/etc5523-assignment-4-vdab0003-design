# Rank hospital-acquired infections by their burden

Orders the five infections from largest to smallest burden for one
country, measure and scale, and gives each infection's share of the
total. Use it to see whether the priority order changes when harm is
measured by cases, deaths or healthy years lost (DALYs).

## Usage

``` r
rank_infections(
  data,
  measure = "DALYs",
  country = "Germany",
  scale = "Total",
  infections = NULL
)
```

## Arguments

- data:

  A data frame shaped like
  [hai_burden](https://etc5523-2026.github.io/etc5523-assignment-4-vdab0003-design/reference/hai_burden.md),
  with columns `country`, `infection`, `measure`, `scale`, `median`,
  `lower` and `upper`.

- measure:

  How to measure burden: `"Cases"`, `"Deaths"` or `"DALYs"`. Defaults to
  `"DALYs"` because it combines deaths and illness into one measure of
  harm.

- country:

  `"Germany"` or `"Europe"`.

- scale:

  `"Total"` for whole-population numbers, or `"Per 100,000 people"` to
  compare countries of different sizes.

- infections:

  Optional character vector of infections to include. `NULL` (the
  default) keeps all five.

## Value

A tibble with one row per infection, ordered from largest to smallest
burden:

- rank:

  1 = largest burden.

- infection:

  Infection type.

- median, lower, upper:

  Best estimate and 95% uncertainty interval.

- share:

  Percentage of the total burden of the selected infections.

If `infections` is empty, a tibble with zero rows is returned.

## Examples

``` r
# Ranked by healthy years lost, bloodstream infections are 3rd
rank_infections(hai_burden, measure = "DALYs")
#> # A tibble: 5 × 6
#>    rank infection     median lower  upper share
#>   <int> <chr>          <dbl> <dbl>  <dbl> <dbl>
#> 1     1 Pneumonia      69900 32642 113617 28.5 
#> 2     2 Urinary tract  66373 28197 127111 27.0 
#> 3     3 Bloodstream    59428 30829 100661 24.2 
#> 4     4 Surgical site  28845 22902  35772 11.7 
#> 5     5 C. difficile   20977  1886  47794  8.54

# Ranked by number of cases, they drop to last
rank_infections(hai_burden, measure = "Cases")
#> # A tibble: 5 × 6
#>    rank infection     median  lower  upper share
#>   <int> <chr>          <dbl>  <dbl>  <dbl> <dbl>
#> 1     1 Urinary tract 213525 177470 259600 44.8 
#> 2     2 Pneumonia     106171  83077 134555 22.3 
#> 3     3 Surgical site  93650  74062 116669 19.7 
#> 4     4 C. difficile   36253  24824  50927  7.61
#> 5     5 Bloodstream    26767  17435  40243  5.62

# Compare Germany with Europe fairly, per 100,000 people
rank_infections(hai_burden, country = "Europe", scale = "Per 100,000 people")
#> # A tibble: 5 × 6
#>    rank infection     median lower upper share
#>   <int> <chr>          <dbl> <dbl> <dbl> <dbl>
#> 1     1 Pneumonia      112.   60   174   38.7 
#> 2     2 Bloodstream     75.8  51.2 104   26.1 
#> 3     3 Urinary tract   57    24.9 104.  19.7 
#> 4     4 Surgical site   35    33.2  36.7 12.1 
#> 5     5 C. difficile    10.1   1    19.1  3.48
```
