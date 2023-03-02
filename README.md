
<!-- README.md is generated from README.Rmd. Please edit that file -->

# otndo

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/otndo)
[![R-CMD-check](https://github.com/mhpob/otndo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mhpob/otndo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*entiendo* /ˌenˈtjendo/ \[ˌẽn̪ˈt̪jẽn̪.̪o\]   
Spanish, 1st person indicative; “*I understand*”

***otndo*** /ˌoʊˈtjendo/ \[ˌoʊ̪ˈt̪jẽn̪.d̪o\]  
English, bad pun; “*I understand (OTN data)*”

## Installation

You can install the development version of otndo from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("mhpob/otndo")
```

## Example

This is a basic example:

``` r
# Download some example data
td <- file.path(tempdir(), 'otndo_test_files')
dir.create(td)

download.file(
  paste0('https://members.oceantrack.org/data/repository/pbsm/',
         'detection-extracts/pbsm_matched_detections_2018.zip'),
  destfile = file.path(td, 'pbsm_matched_detections_2018.zip')
)
unzip(file.path(td, 'pbsm_matched_detections_2018.zip'),
      exdir = td)


# Make a tag push summary
library(otndo)

make_tag_push_summary(matched = file.path(td, 'pbsm_matched_detections_2018.csv'))
#> ℹ Asking OTN GeoServer for project information...
#> ℹ Writing report...
#> 
#> 
#> processing file: make_tag_push_summary.qmd
#>   |                                                  |                                          |   0%  |                                                  |.                                         |   2%                              |                                                  |..                                        |   4% (setup)                      |                                                  |...                                       |   7%                              |                                                  |....                                      |   9% (packages)                   |                                                  |.....                                     |  11%                              |                                                  |......                                    |  13% (extraction-files-read)      |                                                  |.......                                   |  16%                              |                                                  |.......                                   |  18% (n-pis)                      |                                                  |........                                  |  20%                              |                                                  |.........                                 |  22% (otn-query)                  |                                                  |..........                                |  24%                              |                                                  |...........                               |  27% (proper-urls)                |                                                  |............                              |  29%                              |                                                  |.............                             |  31% (otn-match-table)            |                                                  |..............                            |  33%                              |                                                  |...............                           |  36% (otn-match-map)              |                                                  |................                          |  38%                              |                                                  |.................                         |  40% (temporal-distribution)      |                                                  |..................                        |  42%                              |                                                  |...................                       |  44% (abacus-plot)                |                                                  |....................                      |  47%                              |                                                  |.....................                     |  49% (station-summary-table)      |                                                  |.....................                     |  51%                              |                                                  |......................                    |  53% (station-spatial)            |                                                  |.......................                   |  56%                              |                                                  |........................                  |  58% (detection-map-leaflet)      |                                                  |.........................                 |  60%                              |                                                  |..........................                |  62% (tags-remaining)             |                                                  |...........................               |  64%                              |                                                  |............................              |  67% (unnamed-chunk-14)           |                                                  |.............................             |  69%                              |                                                  |..............................            |  71% (unnamed-chunk-15)           |                                                  |...............................           |  73%                              |                                                  |................................          |  76% (unnamed-chunk-16)           |                                                  |.................................         |  78%                              |                                                  |..................................        |  80% (new-otn-match-map)          |                                                  |...................................       |  82%                              |                                                  |...................................       |  84% (new-station-summary-table)  |                                                  |....................................      |  87%                              |                                                  |.....................................     |  89% (new-station-spatial)        |                                                  |......................................    |  91%                              |                                                  |.......................................   |  93% (new-detection-map-leaflet)  |                                                  |........................................  |  96%                              |                                                  |......................................... |  98% (unnamed-chunk-21)           |                                                  |..........................................| 100%                                                                                                                                                  
#> output file: make_tag_push_summary.knit.md
#> 
#> pandoc 
#>   to: html
#>   output-file: make_tag_push_summary.html
#>   standalone: true
#>   self-contained: true
#>   section-divs: true
#>   html-math-method: mathjax
#>   wrap: none
#>   default-image-extension: png
#>   
#> metadata
#>   document-css: false
#>   link-citations: true
#>   date-format: long
#>   lang: en
#>   title: '`r paste(''Transmitter data push summary:'', params$project_name)`'
#>   author: 'Created with the [`otndo` R package](https://otndo.obrien.page)'
#>   
#> Output created: make_tag_push_summary.html
#> ✔    Done.
```
