# Load packages.

library(package = dplyr) # data manipulation
library(package = purrr) # functional programming
library(package = tidyr) # tidy data
library(package = zhaoy) # convenience functions

# Load functions.

concept <- function(x) {

  x_nchar <- nchar(x = x,
                   type = "chars",
                   allowNA = FALSE,
                   keepNA = TRUE)

  dplyr::case_when(grepl(pattern = "\\d{2}",
                         x = x,
                         ignore.case = TRUE) == TRUE ~
                   substring(text = x,
                             first = 4,
                             last = x_nchar),
                   grepl(pattern = "\\d{1}",
                         x = x,
                         ignore.case = TRUE) == TRUE ~
                   substring(text = x,
                             first = 3,
                             last = x_nchar))

}

wave <- function(x) {

  x <- dplyr::case_when(grepl(pattern = "\\d{2}",
                              x = x,
                              ignore.case = TRUE) == TRUE ~
                        substring(text = x,
                                  first = 2,
                                  last = 3),
                        grepl(pattern = "\\d{1}",
                              x = x,
                              ignore.case = TRUE) == TRUE ~
                        substring(text = x,
                                  first = 2,
                                  last = 2))

  as.integer(x = x)

}

# Import in-put data.

hrs <- zhaoy::import_feather(folder = "hrs",
                             path = "3_hrs.feather")

# Organize dependent variables.

dependent <- hrs %>%
  dplyr::select(hhidpn,
                last_interview,
                r1iwbeg:r12iwbeg,
                r2adla:r12adla,
                r2finea:r12finea,
                r2grossa:r12grossa) %>%
  tidyr::gather(key = dependent_wave,
                value = dependent_status,
                r1iwbeg:r12grossa,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  dplyr::mutate(dependent_concept = concept(x = dependent_wave)) %>%
  purrr::modify_at(.at = "dependent_wave",
                   .f = wave) %>%
  dplyr::filter(dependent_wave == last_interview) %>%
  tidyr::spread(key = dependent_concept,
                value = dependent_status,
                fill = NA,
                convert = FALSE,
                drop = TRUE,
                sep = NULL) %>%
  purrr::modify_at(.at = "iwbeg",
                   .f = as.Date,
                   origin = "1960-01-01")

# Organize independent variables.

independent <- hrs %>%
  dplyr::select(hhidpn,
                strok_interview,
                ragender,
                raracem,
                r1iwbeg:r12iwbeg,
                r1agey_b:r12agey_b,
                r1bmi:r12bmi,
                r1diab:r12diab,
                r1heart:r12heart,
                r1hibp:r12hibp,
                r1smoken:r12smoken,
                h1hhres:h12hhres,
                h1itot:h12itot) %>%
  tidyr::gather(key = independent_wave,
                value = independent_status,
                r1iwbeg:h12itot,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  dplyr::mutate(independent_concept = concept(x = independent_wave)) %>%
  purrr::modify_at(.at = "independent_wave",
                   .f = wave) %>%
  dplyr::filter(independent_wave == strok_interview) %>%
  tidyr::spread(key = independent_concept,
                value = independent_status,
                fill = NA,
                convert = FALSE,
                drop = TRUE,
                sep = NULL) %>%
  purrr::modify_at(.at = "iwbeg",
                   .f = as.Date,
                   origin = "1960-01-01")

comorbidity_range <- c(0,
                       1)

comorbidity <- independent %>%
  dplyr::select(hhidpn,
                bmi,
                diab,
                heart,
                hibp,
                smoken) %>%
  dplyr::filter(is.na(x = bmi) == FALSE,
                (diab %in% comorbidity_range) == TRUE,
                (heart %in% comorbidity_range) == TRUE,
                (hibp %in% comorbidity_range) == TRUE,
                (smoken %in% comorbidity_range) == TRUE) %>%
  dplyr::mutate(bmi_30 = case_when(bmi <= 30 ~
                                   0,
                                   bmi > 30 ~
                                   1))

comorbidity$comorbidity_score <- rowSums(x = comorbidity,
                                         na.rm = FALSE) -
                                 comorbidity$hhidpn -
                                 comorbidity$bmi

comorbidity <- comorbidity %>%
  dplyr::select(hhidpn,
                comorbidity_score)

# Join dependent and independent variables.

hrs <- dplyr::inner_join(x = dependent,
                         y = independent,
                         by = "hhidpn",
                         copy = FALSE,
                         suffix = c("_last",
                                    "_stroke")) %>%
  dplyr::filter(iwbeg_stroke < iwbeg_last) %>%
  dplyr::mutate(diff_time = as.numeric(x = difftime(time1 = iwbeg_last,
                                                    time2 = iwbeg_stroke,
                                                    units = "weeks")) /
                                                    52)

hrs <- dplyr::inner_join(x = hrs,
                         y = comorbidity,
                         by = "hhidpn",
                         copy = FALSE)

# Export data.

zhaoy::export_feather(x = hrs,
                      folder = "hrs",
                      path = "hrs.feather")