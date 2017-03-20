# Load packages.

library(package = rprojroot)

# Locate code.

root_path <- find_root(criterion = "README.md",
                       path = ".")

setwd(dir = root_path)

source(file = "code/1_hrs_respondents.R")
source(file = "code/2_hrs_variables.R")
source(file = "code/3_hrs_interviews.R")
source(file = "code/4_hrs_variables_respondents.R")

# Remove intermediate files.

intermediates <- c("1_hrs_respondents.tsv", # 1_hrs_respondents.R
	                 "2_hrs_variables.tsv",   # 2_hrs_variables.R
	                 "3_hrs_interviews.tsv")  # 3_hrs_interviews.R

file.remove(intermediates)