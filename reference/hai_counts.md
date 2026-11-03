# Patients with a hospital-acquired infection, by age and sex

The number of patients who had each of five hospital-acquired infections
on the day of the point prevalence survey, split by age group and sex,
for Germany and for the European average.

## Usage

``` r
hai_counts
```

## Format

A data frame with 380 rows and 5 variables:

- country:

  "Germany" (representative sample of 46 hospitals) or "Europe" (ECDC
  survey across EU/EEA countries).

- infection:

  One of five infection types: Pneumonia, Surgical site, Bloodstream,
  Urinary tract or C. difficile.

- age_group:

  Patient age group in years, e.g. "60-64"; "Under 1" for infants and
  "85+" for the oldest group.

- sex:

  "Female" or "Male".

- hai_patients:

  Number of surveyed patients with that infection on the survey day.

## Source

Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI R package:
<https://CRAN.R-project.org/package=BHAI>. Prepared in `data-raw/hai.R`.

## Details

These are raw survey counts, not national estimates. Many age and sex
groups have counts of 0 to 5, so differences between small groups should
not be over-interpreted.
