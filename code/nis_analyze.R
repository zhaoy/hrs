input <- "code/nis_analyze.Rmd"
output_file <- "nis_result.html"
output_dir <- "result"

library(package = knitr)

# remove pound sign from out-put
# set graphics format to png

opts_chunk$set(comment = NA,
               dev = "png")

library(package = rmarkdown)

render(input = input,
       output_format = html_document(smart = FALSE,
                                     keep_md = TRUE),
       output_file = output_file,
       output_dir = output_dir)