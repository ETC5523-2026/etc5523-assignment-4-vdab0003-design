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


# 1. Patients with an infection on the survey day, by age and sex
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

# 2. Per-patient risk: infections per 100 patients surveyed
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


# 3. Burden estimates: cases, deaths and DALYs per year
# bhai() converts the one-day survey into yearly estimates by simulating
# 1000 times; this is slow, so it runs once here rather than in the app.
# set.seed() makes the random simulation give the same answer every run.
set.seed(2026)
results <- lapply(pps, bhai, nsim = 1000)

# BHAI returns text such as "106,171 (83,077 - 134,555)": median and a
# 95% uncertainty range. Split it into numbers so the app can plot it.
burden_to_df <- function(res, country) {
  tables <- list(
    "Total"              = bhai.prettyTable(res, pop_norm = FALSE),
    "Per 100,000 people" = bhai.prettyTable(res, pop_norm = TRUE)
  )

  bind_rows(lapply(names(tables), function(scale) {
    tab <- tables[[scale]][, c("Cases", "Deaths", "DALY")]
    data.frame(code = rownames(tab), tab, check.names = FALSE) |>
      pivot_longer(-code, names_to = "measure", values_to = "text") |>
      mutate(scale = scale)
  })) |>
    mutate(country = country)
}

# Pull the three numbers out of each piece of text.
# Remove thousands commas first so "106,171" is read as one number.
get_number <- function(text, i) {
  text <- gsub(",", "", text)
  nums <- regmatches(text, gregexpr("[0-9.]+", text))
  as.numeric(sapply(nums, `[`, i))
}

hai_burden <- bind_rows(
  burden_to_df(results$Germany, "Germany"),
  burden_to_df(results$Europe, "Europe")
) |>
  filter(code != "ALL") |>   # keep the five infections; the app sums them itself
  mutate(
    infection = unname(infection_names[code]),
    measure   = recode(measure, DALY = "DALYs"),
    median    = get_number(text, 1),
    lower     = get_number(text, 2),
    upper     = get_number(text, 3)
  ) |>
  select(country, infection, measure, scale, median, lower, upper)

# 4. Readable labels for the app -------------------------------------------
# BHAI uses "[60;64]" and "[85;Inf]"; managers expect "60-64" and "85+"
tidy_age <- function(x) {
  x <- gsub("\\[|\\]", "", x)
  x <- sub(";Inf", "+", x)
  x <- sub(";", "-", x)
  sub("^0-0$", "Under 1", x)
}

hai_counts <- hai_counts |>
  mutate(
    age_group = factor(tidy_age(age_group), levels = unique(tidy_age(age_group))),
    sex       = recode(sex, F = "Female", M = "Male")
  )

# 5. Save into the package (creates data/*.rda) ----------------------------
usethis::use_data(hai_counts, hai_rates, hai_burden, overwrite = TRUE)
