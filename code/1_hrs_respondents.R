# Load packages in order of use.

library(package = rprojroot) # find files in project sub-directories
library(package = haven)     # import SPSS file
library(package = dplyr)     # data manipulation
library(package = purrr)     # functional programming tools
library(package = readr)     # read tabular data

# Locate raw data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste0(root_path,
                      "/rndhrs_p.sav",
                      collapse = NULL)

# Import raw data.

hrs_respondents <- read_sav(file = import_path,
                            user_na = FALSE)

# Exclude spouses.

hrs_respondents <- select(.data = hrs_respondents,
                          -starts_with(match = "s",
                                       ignore.case = TRUE,
                                       vars = current_vars()))

# Lower-case the variable names.

names(x = hrs_respondents) <- tolower(x = names(x = hrs_respondents))

# Filter for non-Hispanic Whites and non-Hispanic Blacks.

hrs_respondents <- filter(.data = hrs_respondents,
                          rahispan == 0,
                          raracem %in% c(1,
                                         2))

# Filter for respondents who have ever had stroke.

ever_stroke <- hrs_respondents %>%
  select(hhidpn,
         r1strok:r12strok,
         r1stroke:r12stroke,
         r2stroks:r12stroks)

ever_stroke$ever_stroke <- apply(X = ever_stroke,
                                 MARGIN = 1,
                                 FUN = function(x) any(x == 1) == TRUE)

ever_stroke <- ever_stroke %>%
  filter(ever_stroke == TRUE) %>%
  select(-ever_stroke)

hrs_respondents <- semi_join(x = hrs_respondents,
                             y = ever_stroke,
                             by = "hhidpn",
                             copy = FALSE)

# Set export location.

export_path <- paste0(root_path,
                      "/1_hrs_respondents.tsv",
                      collapse = NULL)

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_respondents,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)