# Which infections should we prioritise?

## The problem

Infection-prevention teams have limited budgets and must decide which
hospital-acquired infections to target first. A natural starting point
is to count cases. But one infection is not equal to another: a
bloodstream infection is far more likely to be fatal than a urinary
tract infection. Ranking by case numbers alone can therefore direct
resources away from the infections that cause the most harm.

This guide shows how to use **haiexplorer** to answer one question:

> Which hospital-acquired infections cause the most harm, and does the
> priority order change depending on how harm is measured?

It is written for an infection-prevention manager or analyst who has not
used the package before.

## Key terms

- **Hospital-acquired infection (HAI):** an infection a patient develops
  during a hospital stay that was not present on admission.
- **Cases:** estimated new infections per year.
- **Deaths:** estimated deaths caused by the infection per year.
- **DALY (disability-adjusted life year):** one year of healthy life
  lost, counting both early death and time lived in poor health. DALYs
  allow infections to be compared by the harm they cause, not only by
  how often they occur.
- **Per 100,000 people:** a rate that removes the effect of population
  size, so Germany and the European average can be compared fairly.
- **Uncertainty range:** the range within which the true value lies with
  95% probability.

## Step 1: Install and load the package

Install the package from GitHub, then load it:

``` r

# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-vdab0003-design")
```

``` r

library(haiexplorer)
```

## Step 2: Launch the app

``` r

run_app()
```

The app opens in a new window. It has a sidebar of controls on the left
and the results on the right.

## Step 3: Use the controls

| Control | What it does | When to use it |
|----|----|----|
| **Rank infections by** | Switches between number of cases, deaths and healthy years lost (DALYs) | Compare *Number of cases* with *Healthy years lost* to see whether the priority order changes |
| **Country** | Switches between Germany and the European average | Check whether priorities differ by setting |
| **Show per 100,000 people** | Converts totals into rates | Turn on when comparing Germany with Europe, because totals depend on population size |
| **Infections to compare** | Selects which infections are included | Focus on the infections your hospital can act on; shares are recalculated for the selection |

The **Key terms** panel at the bottom of the sidebar explains each
measure and infection type.

## Step 4: Read the outputs

The app shows four linked outputs, all calculated from the same
selection:

1.  **Summary boxes** name the infection with the highest burden, its
    share of the total, and where it would rank by number of cases. If
    the last box shows anything other than “1st”, the priority order
    changes when harm is measured instead of frequency.
2.  **The headline** states the main finding in one sentence.
3.  **The bar chart** ranks the infections. The red bar is the largest,
    and the percentage under each name is its share of the total. The
    thin line across each bar is the 95% uncertainty range. **Where the
    lines of two infections overlap, the data cannot show with
    confidence which is larger**, so treat those infections as similar
    priorities.
4.  **The table** gives the exact estimate, uncertainty range and share
    for each infection.

If no infections are ticked, the app shows a message asking you to
select at least one. If only one is ticked, it explains that there is
nothing to rank it against.

## Step 5: Interpret the results

The same ranking that powers the app is available as a function,
[`rank_infections()`](https://etc5523-2026.github.io/etc5523-assignment-4-vdab0003-design/reference/rank_infections.md),
so the findings can be checked or reused in your own analysis.

### The most common infections are not the most harmful

Ranked by number of cases, urinary tract infections are the most
frequent in Germany, and bloodstream infections are the least frequent:

``` r

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

Ranked by healthy years lost, the order changes. Bloodstream infections
rise from fifth to third, accounting for about a quarter of the total,
because they are much more likely to be fatal:

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

**What this means for prioritisation:** a prevention plan based only on
case counts would place bloodstream infections last, even though they
cause almost as much harm as the most common infection. Pneumonia,
urinary tract and bloodstream infections should be considered together
as the leading priorities when harm is the goal.

### Comparing Germany with Europe

Totals cannot be compared directly, because Europe’s population is much
larger. Using rates per 100,000 people:

``` r

germany <- rank_infections(hai_burden, country = "Germany",
                           scale = "Per 100,000 people")
europe  <- rank_infections(hai_burden, country = "Europe",
                           scale = "Per 100,000 people")

c(Germany = sum(germany$median), Europe = sum(europe$median))
#> Germany  Europe 
#>     304     290
```

Germany loses slightly more healthy years per 100,000 people than the
European average. However, the individual uncertainty ranges are wide,
so this difference may not be real. In Europe, pneumonia is clearly the
largest burden, while in Germany the top three infections are close.

## Limitations

- The estimates are scaled up from a **one-day survey** in 2011-12 and
  may not reflect current conditions.
- Deaths and DALYs rely on **limited evidence about the outcomes** of
  each infection, so their uncertainty ranges are wide. Rankings between
  infections whose ranges overlap should be treated with caution.
- The German estimates are based on **46 hospitals**, so they are less
  precise than the European figures.

## Data source

Zacher B, Haller S, Willrich N, et al. (2019). Application of a new
methodology and R package reveals a high burden of healthcare-associated
infections (HAI) in Germany compared to the average in the European
Union/ European Economic Area, 2011 to 2012. *Eurosurveillance*, 24(46),
1900135. Data distributed in the
[BHAI](https://CRAN.R-project.org/package=BHAI) R package. See
[`?hai_burden`](https://etc5523-2026.github.io/etc5523-assignment-4-vdab0003-design/reference/hai_burden.md)
for details of how the data were prepared.
