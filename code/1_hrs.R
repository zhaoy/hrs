# Load packages.

library(package = dplyr)     # data manipulation
library(package = haven)     # import SPSS, Stata, and SAS files
library(package = rprojroot) # find files in sub-directories
library(package = zhaoy)     # convenience functions

# Locate raw data.

root_path <- rprojroot::find_root(criterion = rprojroot::has_dirname(dirname = "hrs"),
                                  path = ".")

import_path <- file.path(root_path,
                         "rndhrs_p.dta",
                         fsep = "/")

# Import raw data.

hrs <- haven::read_dta(file = import_path)

# Exclude spouses.

hrs <- hrs %>%
  dplyr::select(-starts_with(match = "s",
                             ignore.case = TRUE,
                             vars = current_vars()))

# Convert upper-case variable names to lower-case.

names(x = hrs) <- tolower(x = names(x = hrs))

# Include only non-Hispanic white and non-Hispanic black respondents.

hrs <- hrs %>%
  dplyr::filter(rahispan == 0 &
                raracem %in% c(1,
                               2) == TRUE)

# Include only respondents who, at least during interviews, are stroke survivors.

stroke_1 <- hrs %>%
  dplyr::select(hhidpn,
                r1strok:r12strok,
                r1stroke:r12stroke,
                r2stroks:r12stroks)

stroke_2 <- apply(X = stroke_1,
                  MARGIN = 1,
                  FUN = function(x) any(x == 1,
                                        na.rm = TRUE))

stroke <- cbind(stroke_1,
                stroke_2,
                deparse.level = 0,
                make.row.names = FALSE,
                stringsAsFactors = FALSE) %>%
  dplyr::filter(stroke_2 == TRUE) %>%
  dplyr::select(hhidpn:r12stroks)

hrs <- dplyr::semi_join(x = hrs,
                        y = stroke,
                        by = "hhidpn",
                        copy = FALSE)

# Export data.

zhaoy::export_feather(x = hrs,
                      folder = "hrs",
                      path = "1_hrs.feather")