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

concept <- function(string) {
  string <- str_sub(string = string,
                    start = 3,
                    end = -1)
  sub_string <- str_sub(string = string,
                        start = 1,
                        end = 1)
  string <- ifelse(test = is.na(x = as.numeric(x = sub_string)) == TRUE,
                   yes = string,
                   no = str_sub(string = string,
                                start = 2,
                                end = -1))
  return(value = string)
}

# Locate interviews data.

root_path <- find_root(criterion = "README.md",
                       path = ".")

import_path <- paste(root_path,
                     "/3_hrs_interviews.tsv",
                     sep = "",
                     collapse = "")

# Import variables data.

hrs_interviews <- read_tsv(file = import_path,
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

# Select dependent variables.

dependent_vars <- hrs_interviews %>%
  select(hhidpn,
         last_interview,
         r1iwbeg:r12iwbeg,
         r2adla:r12adla,
         r2finea:r12finea,
         r2grossa:r12grossa) %>%
  gather(key = dependent_wave,
         value = dependent_status,
         r1iwbeg:r12grossa,
         na.rm = FALSE,
         convert = FALSE,
         factor_key = FALSE)

dependent_vars$dependent_concept <- concept(string = dependent_vars$dependent_wave)
dependent_vars$dependent_wave <- wave(string = dependent_vars$dependent_wave)

dependent_vars <- dependent_vars %>%
  filter(dependent_wave == last_interview) %>%
  spread(key = dependent_concept,
         value = dependent_status,
         fill = NA,
         convert = FALSE,
         drop = TRUE,
         sep = NULL)

dependent_vars$iwbeg <- as.Date(x = dependent_vars$iwbeg,
                                origin = "1960-01-01")

# Select independent variables.

independent_vars <- hrs_interviews %>%
  select(hhidpn,
         stroke_interview,
         ragender,
         raracem,
         r1iwbeg:r12iwbeg,
         r1agey_b:r12agey_b,
         r1bmi:r12bmi,
         r1diab:r12diab,
         r1heart:r12heart,
         r1hibp:r12hibp,
         r1smoken:r12smoken,
         ends_with(match = "hhres",
                   ignore.case = TRUE,
                   vars = current_vars()),
         ends_with(match = "itot",
                   ignore.case = TRUE,
                   vars = current_vars())) %>%
  gather(key = independent_wave,
         value = independent_status,
         r1iwbeg:h12itot,
         na.rm = TRUE,
         convert = FALSE,
         factor_key = FALSE)

independent_vars$independent_concept <- concept(string = independent_vars$independent_wave)
independent_vars$independent_wave <- wave(string = independent_vars$independent_wave)

independent_vars <- independent_vars %>%
  filter(independent_wave == stroke_interview) %>%
  spread(key = independent_concept,
         value = independent_status,
         fill = NA,
         convert = FALSE,
         drop = TRUE,
         sep = NULL)

independent_vars$iwbeg <- as.Date(x = independent_vars$iwbeg,
                                  origin = "1960-01-01")

comorbidity_range <- c(0,
                       1)

comorbidity_vars <- independent_vars %>%
  select(hhidpn,
         bmi,
         diab,
         heart,
         hibp,
         smoken) %>%
  filter(is.na(x = bmi) == FALSE,
         diab %in% comorbidity_range,
         heart %in% comorbidity_range,
         hibp %in% comorbidity_range,
         smoken %in% comorbidity_range) %>%
  mutate(bmi_30 = ifelse(test = bmi > 30,
                         yes = 1,
                         no = 0),
         bmi = NULL) %>%
  by_row(..f = sum,
         na.rm = FALSE,
         .collate = "rows",
         .to = "comorbidity",
         .labels = TRUE) %>%
  mutate(comorbidity_score = comorbidity - hhidpn) %>%
  select(hhidpn,
         comorbidity_score)

# Join variables.

hrs_variables_respondents <- inner_join(x = dependent_vars,
                                        y = independent_vars,
                                        by = "hhidpn",
                                        copy = FALSE,
                                        suffix = c("_last",
                                                   "_stroke")) %>%
  mutate(diff_time = as.numeric(x = difftime(time1 = iwbeg_last,
                                             time2 = iwbeg_stroke,
                                             units = "weeks")) /
                                             52)

hrs_variables_respondents <- inner_join(x = hrs_variables_respondents,
                                        y = comorbidity_vars,
                                        by = "hhidpn",
                                        copy = FALSE)

# Set export location.

export_path <- paste(root_path,
                     "/hrs_analysis.tsv",
                     sep = "",
                     collapse = "")

# Export transformed data to tab-separated-values (tsv) file.

write_tsv(x = hrs_variables_respondents,
          path = export_path,
          na = "",
          append = FALSE,
          col_names = TRUE)