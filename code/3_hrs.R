# Load packages.

library(package = dplyr) # data manipulation
library(package = purrr) # functional programming
library(package = tidyr) # tidy data
library(package = zhaoy) # convenience functions

# Load a function.

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
                             path = "2_hrs.feather")

# Include only interviews that were in same years as first-time strokes:

# 1) identify first and last interviews

# 2) identify first interviews that were in same years as strokes

# 3) exclude first and last interviews

# Identify first and last interviews.

strok_range <- hrs %>%
  dplyr::select(hhidpn,
                r1strok:r12strok) %>%
  tidyr::gather(key = strok_wave,
                value = strok_status,
                r1strok:r12strok,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  purrr::modify_at(.at = "strok_wave",
                   .f = wave)

strok_range <- strok_range %>%
  dplyr::group_by(hhidpn) %>%
  dplyr::summarize(first_interview = min(strok_wave,
                                         na.rm = FALSE),
                   last_interview = max(strok_wave,
                                        na.rm = FALSE))

# Identify first interviews that were in same years as strokes.

strok_interview <- hrs %>%
  dplyr::select(hhidpn,
                r1strok:r12strok) %>%
  tidyr::gather(key = strok_wave,
                value = strok_status,
                r1strok:r12strok,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  purrr::modify_at(.at = "strok_wave",
                   .f = wave) %>%
  dplyr::filter(strok_status == 1) %>%
  dplyr::group_by(hhidpn) %>%
  dplyr::filter(strok_wave == head(x = strok_wave,
                                   n = 1))

# Exclude first and last interviews.

hrs_3 <- dplyr::inner_join(strok_range,
                           strok_interview,
                           by = "hhidpn",
                           copy = FALSE) %>%
  purrr::modify_at(.at = c("first_interview",
                           "last_interview",
                           "strok_status"),
                   .f = as.integer) %>%
  dplyr::filter(strok_wave > first_interview &
                strok_wave < last_interview) %>%
  dplyr::select(hhidpn,
                strok_interview = strok_wave,
                last_interview)

# interviews that were in same years as first-time strokes

hrs <- dplyr::inner_join(x = hrs,
                         y = hrs_3,
                         by = "hhidpn",
                         copy = FALSE)

# Export data.

zhaoy::export_feather(x = hrs,
                      folder = "hrs",
                      path = "3_hrs.feather")