# Prepare hospital-acquired infection (HAI) data for haiexplorer.
# Source: BHAI package (Zacher et al. 2019), which contains the ECDC
# point prevalence survey 2011-12. Re-run this script to rebuild the data.

library(BHAI)
library(dplyr)
library(tidyr)

# Short codes used by BHAI, with plain-language names for the app
infection_names <- c(
  HAP = "Pneumonia",
  SSI = "Surgical site",
  BSI = "Bloodstream",
  UTI = "Urinary tract",
  CDI = "C. difficile"
)

# BHAI stores Germany as separate pieces but Europe as one ready-made
# PPS object. Load each into its own environment so objects with the
# same name do not overwrite each other, then return one PPS object.
load_pps <- function(dataset, country) {
  e <- new.env()
  data(list = dataset, package = "BHAI", envir = e)
  objs <- mget(ls(e), envir = e)

  if (length(objs) == 1 && is(objs[[1]], "PPS")) {
    return(objs[[1]])
  }
  do.call(PPS, c(objs, country = country))
}


pps <- list(
  Germany = load_pps("german_pps_2011_repr", "Germany"),
  Europe  = load_pps("eu_pps_2011", "Europe")
)


# 1. Patients with an infection on the survey day, by age and sex ---------
# BHAI stores one age-by-sex table per infection; stack them into one
# long table so the app can filter and plot by any combination
strata_to_df <- function(p, country) {
  lapply(names(p@num_hai_patients_by_stratum), function(inf) {
    m <- p@num_hai_patients_by_stratum[[inf]]
    data.frame(
      country      = country,
      infection    = infection_names[[inf]],
      age_group    = rownames(m),
      sex          = rep(colnames(m), each = nrow(m)),
      hai_patients = as.vector(m)
    )
  }) |>
    bind_rows()
}

hai_counts <- bind_rows(
  strata_to_df(pps$Germany, "Germany"),
  strata_to_df(pps$Europe, "Europe")
)

# 2. Per-patient risk: infections per 100 patients surveyed ---------------
# This is the "risk for each patient" view; it ignores how many people
# go through hospital, which the burden estimates below account for
hai_rates <- bind_rows(lapply(names(pps), function(cn) {
  p <- pps[[cn]]
  data.frame(
    country          = cn,
    infection        = unname(infection_names[names(p@num_hai_patients)]),
    hai_patients     = as.numeric(p@num_hai_patients),
    survey_patients  = p@num_survey_patients,
    per_100_patients = as.numeric(p@num_hai_patients) / p@num_survey_patients * 100
  )
}))
