# Load packages in order of use.

library(package = rprojroot) # find absolute file-path of root directory
library(package = haven)     # import SPSS file
library(package = dplyr)     # transform data
library(package = purrr)     # functional programming tools
library(package = readr)     # export data

# Locate raw data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste(root_path,
                     "/rndhrs_p.sav",
                     sep = "",
                     collapse = "")

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
         r2stroks:r12stroks) %>%
  by_row(..f = function(x) any(x == 1,
                               na.rm = FALSE) == TRUE,
         .collate = "rows",
         .to = "ever_stroke",
         .labels = TRUE) %>%
  filter(ever_stroke == TRUE) %>%
  select(-ever_stroke)

hrs_respondents <- semi_join(x = hrs_respondents,
                             y = ever_stroke,
                             by = "hhidpn",
                             copy = FALSE)

# Set export location.

export_path <- paste(root_path,
                     "/1_hrs_respondents.tsv",
                     sep = "",
                     collapse = "")

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_respondents,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)