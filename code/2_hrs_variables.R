# Load packages in order of use.

library(package = rprojroot) # find absolute file-path of root directory
library(package = readr)     # import and export data
library(package = dplyr)     # transform data
library(package = purrr)     # functional programming tools

# Locate respondents data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste(root_path,
                     "/1_hrs_respondents.tsv",
                     sep = "",
                     collapse = "")

# Import respondents data.

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
                            guess_max = 1000,
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
                          r2mobila:r12mobila,
                          r2lgmusa:r12lgmusa,
                          r2adla:r12adla,
                          r2adlwa:r12adlwa,
                          r2iadla:r12iadla,
                          ends_with(match = "iadlza",
                                    ignore.case = TRUE,
                                    vars = current_vars()),
                          r2grossa:r12grossa,
                          r2finea:r12finea)

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
                           r1iwbeg:r12iwbeg,
                           r1agey_b:r12agey_b,
                           ragender,
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

export_path <- paste(root_path,
                     "/2_hrs_variables.tsv",
                     sep = "",
                     collapse = "")

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_variables,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)