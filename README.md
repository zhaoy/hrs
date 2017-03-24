Computer code for a JAHA manuscript.

## Raw Data

**Publication date**: August 2016

**Documentation**: [rand.org/labor/aging/dataprod/hrs-data.html](https://www.rand.org/labor/aging/dataprod/hrs-data.html)

**Log-in**: [https://ssl.isr.umich.edu/hrs/start.php](https://ssl.isr.umich.edu/hrs/start.php)

**Location**: [https://ssl.isr.umich.edu/hrs/files2.php?versid=34](https://ssl.isr.umich.edu/hrs/files2.php?versid=34)

**File name**: randpspss.zip

## Software

**Language**: [R](https://www.r-project.org)

**Version**: 3.3.3

**Packages**:

[tidyverse](https://mran.microsoft.com/package/tidyverse) packages: [dplyr](https://mran.microsoft.com/package/dplyr), [haven](https://mran.microsoft.com/package/haven), [purrr](https://mran.microsoft.com/package/purrr), [readr](https://mran.revolutionanalytics.com/package/readr), [stringr](https://mran.microsoft.com/package/stringr), [tidyr](https://mran.revolutionanalytics.com/package/tidyr)

Other packages: [knitr](https://mran.microsoft.com/package/knitr), [rmarkdown](https://mran.microsoft.com/package/rmarkdown), [rprojroot](https://mran.microsoft.com/package/rprojroot)

## Reproducibility

1. Download this repository.

2. Download the raw data. From inside the raw data folder, copy-paste or cut-paste `rndhrs_p.sav` to the root directory of this repository.

3. Run `makefile.R` to generate the analysis data-set. If you want to open it before running it, use the file browser / manager / system of the computer instead of the "File" menu in R or [RStudio](https://www.rstudio.com). Suggested methods:

* Double-click on `makefile.R`.
* Select `makefile.R`, right-click, and left-click on "Open".
* Select `makefile.R`, right-click, hover over "Open With", and left-click on R or RStudio.

As `makefile.R` runs, ignore these warning messages if they appear:

```
Warning: 1 parsing failure.
row  col     expected   actual
2267 ravetrn an integer NaN
```

```
Warning messages:

In ifelse(test = is.na(x = as.numeric(x = string)) == TRUE,
yes = str_sub(string = string, :
NAs introduced by coercion

In ifelse(test = is.na(x = as.numeric(x = sub_string)) == TRUE, :
NAs introduced by coercion
```

The analysis data-set should appear in the root directory of this repository.