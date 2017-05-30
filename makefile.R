# Load packages.

library(package = rprojroot) # find files in sub-directories
library(package = purrr)     # functional programming tools

# Locate code.

root_path <- find_root(criterion = "README.md",
                       path = ".")

# Run code.

hrs_code <- c("code/1_hrs_respondents.R",
              "code/2_hrs_variables.R",
              "code/3_hrs_interviews.R",
              "code/4_hrs.R")

map(.x = hrs_code,
    .f = source)

# Remove intermediate files.

hrs_intermediates <- c("1_hrs_respondents.tsv", # 1_hrs_respondents.R
                       "2_hrs_variables.tsv",   # 2_hrs_variables.R
                       "3_hrs_interviews.tsv")  # 3_hrs_interviews.R

file.remove(hrs_intermediates)