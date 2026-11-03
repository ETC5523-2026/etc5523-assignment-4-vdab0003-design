# Infections per 100 hospital patients

The share of surveyed patients who had each infection on the survey day.
This measures the risk for an individual patient, regardless of how many
people a country admits to hospital.

## Usage

``` r
hai_rates
```

## Format

A data frame with 10 rows and 5 variables:

- country:

  "Germany" or "Europe".

- infection:

  One of five infection types.

- hai_patients:

  Number of surveyed patients with the infection.

- survey_patients:

  Total number of patients surveyed.

- per_100_patients:

  `hai_patients / survey_patients * 100`: out of every 100 patients in
  hospital on the survey day, how many had this infection.

## Source

Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R package:
<https://CRAN.R-project.org/package=BHAI>. Prepared in `data-raw/hai.R`.

## Details

This is prevalence (patients infected on one day), not the number of new
infections per year. It is the "per patient" view used to compare how
safe hospitals are for each person treated.
