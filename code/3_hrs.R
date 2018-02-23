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

# 1 identify first and last interviews that had data for "strok" variable

# 2 using 1, identify first interviews that were in same years as strokes

# 3a using 2, check that there were no strokes before interviews

# 3b exclude first and last interviews

# 1

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
                   .f = wave) %>%
  dplyr::group_by(hhidpn) %>%
  dplyr::summarize(first_interview = min(strok_wave,
                                         na.rm = FALSE),
                   last_interview = max(strok_wave,
                                        na.rm = FALSE))

# 2

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
  dplyr::arrange(strok_wave) %>%
  dplyr::filter(strok_wave == head(x = strok_wave,
                                   n = 1))

# 3a

# last "no" response to "stroke variable

stroke_no <- hrs %>%
  dplyr::select(hhidpn,
                r1stroke:r12stroke) %>%
  tidyr::gather(key = stroke_wave_no,
                value = stroke_status_no,
                r1stroke:r12stroke,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  purrr::modify_at(.at = "stroke_wave_no",
                   .f = wave) %>%
  dplyr::filter(stroke_status_no == 0) %>%
  dplyr::group_by(hhidpn) %>%
  dplyr::arrange(stroke_wave_no) %>%
  dplyr::filter(stroke_wave_no == tail(x = stroke_wave_no,
                                       n = 1))

# first "yes" response to "stroke" variable

stroke_yes <- hrs %>%
  dplyr::select(hhidpn,
                r1stroke:r12stroke) %>%
  tidyr::gather(key = stroke_wave_yes,
                value = stroke_status_yes,
                r1stroke:r12stroke,
                na.rm = TRUE,
                convert = FALSE,
                factor_key = FALSE) %>%
  purrr::modify_at(.at = "stroke_wave_yes",
                   .f = wave) %>%
  dplyr::filter(stroke_status_yes == 1) %>%
  dplyr::group_by(hhidpn) %>%
  dplyr::arrange(stroke_wave_yes) %>%
  dplyr::filter(stroke_wave_yes == head(x = stroke_wave_yes,
                                        n = 1))

# 3b

hrs_3 <- list(strok_range,
              strok_interview,
              stroke_no,
              stroke_yes) %>%
  purrr::reduce(.f = inner_join,
                by = "hhidpn",
                copy = FALSE) %>%
  purrr::modify_at(.at = "last_interview",
                   .f = as.integer) %>%
  dplyr::filter(strok_wave > stroke_wave_no &
                strok_wave <= stroke_wave_yes &
                strok_wave > first_interview &
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