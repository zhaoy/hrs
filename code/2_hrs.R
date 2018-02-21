# Load packages.

library(package = dplyr) # data manipulation
library(package = purrr) # functional programming
library(package = zhaoy) # convenience functions

# Import in-put data.

hrs <- zhaoy::import_feather(folder = "hrs",
                             path = "1_hrs.feather")

# Include stroke variables.

stroke <- hrs %>%
  dplyr::select(hhidpn,
                r1strok:r12strok,
                r1stroke:r12stroke,
                r2stroks:r12stroks)

# Include certain variables about difficulty in:

# activities of daily living

# fine motor activities

# gross motor activities

# instrumental activities of daily living

# large muscle activities

# mobility activities

difficulty <- hrs %>%
  dplyr::select(hhidpn,
                r2adla:r12adla,
                r2finea:r12finea,
                r2grossa:r12grossa,
                r2iadla:r12iadla,
                ends_with(match = "iadlza",
                          ignore.case = TRUE,
                          vars = current_vars()),
                r2lgmusa:r12lgmusa,
                r2mobila:r12mobila)

# Include certain other health variables.

other_health <- hrs %>%
  dplyr::select(hhidpn,
                r1bmi:r12bmi,
                r1diab:r12diab,
                r1heart:r12heart,
                r1hibp:r12hibp,
                r1smoken:r12smoken)

# Include certain demographic variables.

demographics <- hrs %>%
  dplyr::select(hhidpn,
                r1agey_b:r12agey_b,
                r1iwbeg:r12iwbeg,
                ragender,
                raracem)

# Include certain wealth variables.

wealth <- hrs %>%
  dplyr::select(hhidpn,
                ends_with(match = "atotb",
                          ignore.case = TRUE,
                          vars = current_vars()))

# Include certain income variables.

income <- hrs %>%
  dplyr::select(hhidpn,
                ends_with(match = "itot",
                          ignore.case = TRUE,
                          vars = current_vars()))

# Include certain family variables.

family <- hrs %>%
  dplyr::select(hhidpn,
                ends_with(match = "hhres",
                          ignore.case = TRUE,
                          vars = current_vars()))

# Join variables.

hrs <- list(stroke,
            difficulty,
            other_health,
            demographics,
            wealth,
            income,
            family) %>%
  purrr::reduce(.f = dplyr::full_join,
                by = "hhidpn",
                copy = FALSE)

# Export data.

zhaoy::export_feather(x = hrs,
                      folder = "hrs",
                      path = "2_hrs.feather")