
<!-- README.md is generated from README.Rmd. Please edit that file -->

# predmark

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
status](https://www.r-pkg.org/badges/version/predmark)](https://CRAN.R-project.org/package=predmark)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/predmark/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/predmark?branch=master)
[![R build
status](https://github.com/kiernann/predmark/workflows/R-CMD-check/badge.svg)](https://github.com/kiernann/predmark/actions)
<!-- badges: end -->

This package contains data and documentation from prediction markets and
forecasting models for the 2018 and 2020 U.S. elections. The data is
formatted in ways to facilitate statistical comparison. This package was
built to both hold the data and make for easy installation, including
package dependencies needed to completely replicate the data formatting.

The [original repository](https://github.com/kiernann/models-markets)
for this project was not formatted as a package.

## Installation

You can install the development version of predmark from
[GitHub](https://github.com/kiernann/predmark) with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/predmark")
```

## Data

``` r
library(tidyverse)
library(predmark)
```

The package contains daily predictions from PredictIt and
FiveThirtyEight.

``` r
markets18
#> # A tibble: 41,933 x 9
#>    date       mid   race  party  open   low  high close volume
#>    <date>     <chr> <chr> <chr> <dbl> <dbl> <dbl> <dbl>  <dbl>
#>  1 2017-01-27 2918  MA-S1 D      0.79  0.71  0.86  0.74   1102
#>  2 2017-01-28 2918  MA-S1 D      0.74  0.74  0.78  0.78   1010
#>  3 2017-01-29 2918  MA-S1 D      0.78  0.76  0.78  0.77    581
#>  4 2017-01-30 2918  MA-S1 D      0.77  0.76  0.78  0.78    631
#>  5 2017-01-31 2918  MA-S1 D      0.78  0.77  0.81  0.81   1378
#>  6 2017-02-01 2918  MA-S1 D      0.81  0.79  0.82  0.8     768
#>  7 2017-02-02 2918  MA-S1 D      0.8   0.79  0.8   0.79     50
#>  8 2017-02-03 2918  MA-S1 D      0.79  0.78  0.8   0.78    592
#>  9 2017-02-04 2918  MA-S1 D      0.78  0.78  0.79  0.79     10
#> 10 2017-02-05 2918  MA-S1 D      0.79  0.79  0.8   0.8       6
#> # … with 41,923 more rows
```

``` r
model18
#> # A tibble: 1,049 x 11
#>    date       race  name       party chamber special incumbent   prob voteshare min_share max_share
#>    <date>     <chr> <chr>      <chr> <chr>   <lgl>   <lgl>      <dbl>     <dbl>     <dbl>     <dbl>
#>  1 2018-09-25 VA-04 A. Donald… D     house   FALSE   TRUE      0.999     0.632     0.579     0.684 
#>  2 2018-09-25 GA-03 A. Drew F… R     house   FALSE   TRUE      1.00      0.676     0.627     0.725 
#>  3 2018-09-25 LA-03 Aaron And… L     house   FALSE   FALSE     0.0002    0.0254    0.0071    0.0486
#>  4 2018-09-25 ID-02 Aaron Swi… D     house   FALSE   FALSE     0.002     0.364     0.309     0.418 
#>  5 2018-09-25 IA-01 Abby Fink… D     house   FALSE   FALSE     0.971     0.554     0.506     0.600 
#>  6 2018-09-25 VA-07 Abigail S… D     house   FALSE   FALSE     0.352     0.474     0.431     0.517 
#>  7 2018-09-25 IL-16 Adam Kinz… R     house   FALSE   TRUE      0.984     0.590     0.538     0.642 
#>  8 2018-09-25 CA-28 Adam Schi… D     house   FALSE   TRUE      1         0.812     0.766     0.857 
#>  9 2018-09-25 WA-09 Adam Smith D     house   FALSE   TRUE      0.982     0.613     0.544     0.683 
#> 10 2018-09-25 NE-03 Adrian Sm… R     house   FALSE   TRUE      1         0.716     0.664     0.768 
#> # … with 1,039 more rows
```

<!-- refs: start -->

<!-- refs: end -->
