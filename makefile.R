# Load packages.

library(package = rprojroot) # find files in sub-directories
library(package = purrr)     # functional programming

# Locate code.

root_path <- rprojroot::find_root(criterion = rprojroot::has_dirname(dirname = "hrs"),
                                  path = ".")

# Run code.

hrs_code <- c("1_hrs.R",
              "2_hrs.R",
              "3_hrs.R",
              "4_hrs.R") %>%
  purrr::map(.f = function(x) file.path(root_path,
                                        "code",
                                        x,
                                        fsep = "/"))

purrr::map(.x = hrs_code,
           .f = source)

# Remove intermediate files.

hrs_intermediate <- c("1_hrs.feather",
                      "2_hrs.feather",
                      "3_hrs.feather") %>%
  purrr::map(.f = function(x) file.path(root_path,
                                        x,
                                        fsep = "/")) %>%
  unlist

file.remove(hrs_intermediate)