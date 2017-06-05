# Load packages in order of use.

library(package = rprojroot) # find files in sub-directories
library(package = readr)     # read tabular data
library(package = stringr)   # string operations
library(package = dplyr)     # data manipulation
library(package = tidyr)     # tidy data
library(package = purrr)     # functional programming tools

# Load function.

wave <- function(string) {
  string <- as.character(x = string)
  string <- str_sub(string = string,
                    start = 2,
                    end = 3)
  string <- ifelse(test = is.na(x = as.numeric(x = string)) == TRUE,
                   yes = str_sub(string = string,
                                 start = 1,
                                 end = 1),
                   no = string)
  string <- as.numeric(x = string)
  return(value = string)
}

# Locate in-put data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste0(root_path,
                      "/2_hrs_variables.tsv",
                      collapse = NULL)

# Import in-put data.

hrs_variables <- read_tsv(file = import_path,
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

# Select first-time-stroke interviews:
# 1) identify first and last interviews
# 2) first interview with stroke in that interview
# 3) no history of stroke per previous interviews
# 4) exclude first and last interviews

# Identify first and last interviews.

strok_range <- hrs_variables %>%
  select(hhidpn,
         r1strok:r12strok) %>%
  gather(key = strok_wave,
         value = strok_status,
         r1strok:r12strok,
         na.rm = TRUE,
         convert = FALSE,
         factor_key = FALSE)

strok_range$strok_wave <- wave(string = strok_range$strok_wave)

strok_range <- strok_range %>%
  group_by(hhidpn) %>%
  summarize(first_interview = min(strok_wave,
                                  na.rm = FALSE),
            last_interview = max(strok_wave,
                                 na.rm = FALSE))

# first interview with stroke in that interview

strok_interviews <- hrs_variables %>%
  select(hhidpn,
         r1strok:r12strok) %>%
  gather(key = strok_wave,
         value = strok_status,
         r1strok:r12strok,
         na.rm = TRUE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(strok_status == 1) %>%
  group_by(hhidpn) %>%
  filter(strok_wave == head(x = strok_wave,
                            n = 1,
                            addrownums = FALSE))

# no history of stroke per previous interviews: first yes response to ever had stroke

ever_stroke_yes <- hrs_variables %>%
  select(hhidpn,
         r1stroke:r12stroke) %>%
  gather(key = stroke_wave_yes,
         value = stroke_status_yes,
         r1stroke:r12stroke,
         na.rm = TRUE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(stroke_status_yes == 1) %>%
  group_by(hhidpn) %>%
  filter(stroke_wave_yes == head(x = stroke_wave_yes,
                                 n = 1,
                                 addrownums = FALSE))

# no history of stroke per previous interviews: last no response to ever had stroke

ever_stroke_no <- hrs_variables %>%
  select(hhidpn,
         r1stroke:r12stroke) %>%
  gather(key = stroke_wave_no,
         value = stroke_status_no,
         r1stroke:r12stroke,
         na.rm = TRUE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(stroke_status_no == 0) %>%
  group_by(hhidpn) %>%
  filter(stroke_wave_no == tail(x = stroke_wave_no,
                                n = 1,
                                addrownums = FALSE))

# Exclude first and last interviews.

hrs_interviews <- list(strok_range,
                       strok_interviews,
                       ever_stroke_yes,
                       ever_stroke_no) %>%
  reduce(.f = inner_join,
         by = "hhidpn",
         copy = FALSE)

hrs_interviews$strok_wave <- wave(string = hrs_interviews$strok_wave)

hrs_interviews$stroke_wave_yes <- wave(string = hrs_interviews$stroke_wave_yes)

hrs_interviews$stroke_wave_no <- wave(string = hrs_interviews$stroke_wave_no)

hrs_interviews <- hrs_interviews %>%
  filter(strok_wave > first_interview,
         strok_wave < last_interview) %>%
  mutate(compare_wave = ifelse(test = (strok_wave >= stroke_wave_no) &
                                      (strok_wave <= stroke_wave_yes),
                               yes = TRUE,
                               no = FALSE)) %>%
  filter(compare_wave == TRUE) %>%
  select(hhidpn,
         stroke_interview = strok_wave,
         last_interview)

# first-time-stroke interviews

hrs_interviews <- inner_join(x = hrs_variables,
                             y = hrs_interviews,
                             by = "hhidpn",
                             copy = FALSE)

# Set export location.

export_path <- paste0(root_path,
                      "/3_hrs_interviews.tsv",
                      collapse = NULL)

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_interviews,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)