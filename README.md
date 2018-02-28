instructions for reproducing the data-set of a manuscript

## Raw data

**publication date**: August 2016

**documentation**: [rand.org/labor/aging/dataprod/hrs-data.html](https://www.rand.org/labor/aging/dataprod/hrs-data.html)

**log-in**: [https://ssl.isr.umich.edu/hrs/start.php](https://ssl.isr.umich.edu/hrs/start.php)

**location**: [https://ssl.isr.umich.edu/hrs/files2.php?versid=34](https://ssl.isr.umich.edu/hrs/files2.php?versid=34)

**.zip file**: randpstata.zip

## Software

**language**: [R](https://www.r-project.org)

**version**: 3.4.3

**packages**:

[tidyverse](https://github.com/tidyverse) packages: [dplyr](https://mran.microsoft.com/package/dplyr), [haven](https://mran.microsoft.com/package/haven), [purrr](https://mran.microsoft.com/package/purrr), [tidyr](https://mran.revolutionanalytics.com/package/tidyr)

other packages: [rprojroot](https://mran.microsoft.com/package/rprojroot), [zhaoy](https://github.com/zhaoy/zhaoy)

## Reproducibility

1 Download this repository.

2 Download the raw data. From inside the raw data .zip file, copy-paste or cut-paste `rndhrs_p.dta` to the root directory of this repository.

3 In this repository, run `makefile.R` to build the manuscript data-set. After `makefile.R` runs, the manuscript data-set (`hrs.feather`) should appear in the root directory.

To run an individual R file that is in this repository, use the file browser / manager / system of the computer instead of the "File" menu in R or [RStudio](https://www.rstudio.com). Suggested methods:

* Select the file, right-click, hover over "Open With", and left-click on R or RStudio.

* Select the file, right-click, and left-click on "Open".

* Double-click on the file.