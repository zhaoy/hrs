# Load packages.

library(package = rprojroot) # find absolute file-path of root directory
library(package = rmarkdown) # dynamic documents

# Locate code.

root_path <- find_root(criterion = "README.md",
                       path = ".")

# Run code.

render(input = "5_hrs.Rmd",
       output_format = NULL,
       output_file = NULL,
       output_dir = root_path,
       intermediates_dir = NULL,
       knit_root_dir = root_path,
       runtime = "auto",
       clean = TRUE,
       quiet = TRUE)