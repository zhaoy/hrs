# Load packages in order of use.

library(package = rprojroot) # find files in sub-directories
library(package = readr)     # read tabular data
library(package = dplyr)     # data manipulation
library(package = purrr)     # functional programming tools

# Locate in-put data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste0(root_path,
                      "/1_hrs_respondents.tsv",
                      collapse = NULL)

# Import in-put data.

hrs_respondents <- read_tsv(file = import_path,
                            col_names = TRUE,
                            col_types = NULL,
                            locale = default_locale(),
                            na = "",
                            quoted_na = TRUE,
                            comment = "",
                            trim_ws = TRUE,
                            skip = 0,
                            n_max = Inf,
                            guess_max = 2300,
                            progress = TRUE)

# Select stroke variables.

stroke_vars <- select(.data = hrs_respondents,
                      hhidpn,
                      r1strok:r12strok,
                      r1stroke:r12stroke,
                      r2stroks:r12stroks)

# Select functional limitations variables.

functional_vars <- select(.data = hrs_respondents,
                          hhidpn,
                          r2adla:r12adla,
                          r2adlwa:r12adlwa,
                          r2finea:r12finea,
                          r2grossa:r12grossa,
                          r2iadla:r12iadla,
                          ends_with(match = "iadlza",
                                    ignore.case = TRUE,
                                    vars = current_vars()),
                          r2lgmusa:r12lgmusa,
                          r2mobila:r12mobila)

# Select other health variables.

health_vars <- select(.data = hrs_respondents,
                      hhidpn,
                      r1bmi:r12bmi,
                      r1diab:r12diab,
                      r1heart:r12heart,
                      r1hibp:r12hibp,
                      r1smoken:r12smoken)

# Select demographic variables.

demographic_vars <- select(.data = hrs_respondents,
                           hhidpn,
                           r1agey_b:r12agey_b,
                           ragender,
                           r1iwbeg:r12iwbeg,
                           raracem)

# Select financial and housing wealth variables.

wealth_vars <- select(.data = hrs_respondents,
                      hhidpn,
                      ends_with(match = "atotb",
                                ignore.case = TRUE,
                                vars = current_vars()))

# Select income variables.

income_vars <- select(.data = hrs_respondents,
                      hhidpn,
                      ends_with(match = "itot",
                                ignore.case = TRUE,
                                vars = current_vars()))

# Select family structure variables.

family_vars <- select(.data = hrs_respondents,
                      hhidpn,
                      ends_with(match = "hhres",
                                ignore.case = TRUE,
                                vars = current_vars()))

# Join variables.

hrs_variables <- list(stroke_vars,
                      functional_vars,
                      health_vars,
                      demographic_vars,
                      wealth_vars,
                      income_vars,
                      family_vars) %>%
  reduce(.f = full_join,
         by = "hhidpn",
         copy = FALSE)

# Set export location.

export_path <- paste0(root_path,
                      "/2_hrs_variables.tsv",
                      collapse = NULL)

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_variables,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)