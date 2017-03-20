# Load packages in order of use.

library(package = rprojroot) # find absolute file-path of root directory
library(package = readr)     # import and export data
library(package = stringr)   # string operations
library(package = dplyr)     # transform data
library(package = tidyr)     # transform data
library(package = purrr)     # functional programming tools

# Load functions.

wave <- function(string) {
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

# Locate variables data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste(root_path,
                     "/2_hrs_variables.tsv",
                     sep = "",
                     collapse = "")

# Import variables data.

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
# 1) stroke in current interviews
# 2) no history of stroke per previous interviews
# 3) exclude first or last interviews

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

# stroke in current interviews

strok_interviews <- hrs_variables %>%
  select(hhidpn,
         r1strok:r12strok) %>%
  gather(key = strok_wave,
         value = strok_status,
         r1strok:r12strok,
         na.rm = FALSE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(strok_status == 1) %>%
  group_by(hhidpn) %>%
  filter(strok_wave == head(strok_wave,
                            n = 1))

# first yes response to ever had stroke

ever_stroke_yes <- hrs_variables %>%
  select(hhidpn,
         r1stroke:r12stroke) %>%
  gather(key = stroke_wave_yes,
         value = stroke_status_yes,
         r1stroke:r12stroke,
         na.rm = FALSE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(stroke_status_yes == 1) %>%
  group_by(hhidpn) %>%
  filter(stroke_wave_yes == head(stroke_wave_yes,
                                 n = 1))

# last no response to ever had stroke

ever_stroke_no <- hrs_variables %>%
  select(hhidpn,
         r1stroke:r12stroke) %>%
  gather(key = stroke_wave_no,
         value = stroke_status_no,
         r1stroke:r12stroke,
         na.rm = FALSE,
         convert = FALSE,
         factor_key = FALSE) %>%
  filter(stroke_status_no == 0) %>%
  group_by(hhidpn) %>%
  filter(stroke_wave_no == tail(stroke_wave_no,
                                n = 1))

# not first or last interviews

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
  mutate(compare = ifelse(test = (strok_wave > stroke_wave_no) &
                                 (strok_wave <= stroke_wave_yes),
                          yes = TRUE,
                          no = FALSE)) %>%
  filter(compare == TRUE) %>%
  select(hhidpn,
         stroke_interview = strok_wave,
         last_interview)

# first-time-stroke interviews

hrs_interviews <- inner_join(x = hrs_variables,
                             y = hrs_interviews,
                             by = "hhidpn",
                             copy = FALSE)

# Set export location.

export_path <- paste(root_path,
                     "/3_hrs_interviews.tsv",
                     sep = "",
                     collapse = "")

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_interviews,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)