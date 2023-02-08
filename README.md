
<!-- README.md is generated from README.Rmd. Please edit this file -->
<!-- Very likely that you'll need to run rmarkdown::render('readme.rmd') rather than the knit button. -->
<!-- readme.html will be created and is unnecessary, so delete that. -->

# matos

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/mhpob/matos/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mhpob/matos/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

{matos} is an attempt at an API to the [Mid-Atlantic Acoustic Telemetry
Observing System website](https://matos.asascience.com/), powered by a
suite of [httr](https://httr.r-lib.org/) and
[rvest](https://rvest.tidyverse.org/) functions. Because of this, it’s
not necessarily fast or the best way to do things – we’re just pinging
the website back and forth. Additionally, an internet connection is
needed for pretty much anything to work.

Please note that you will need a MATOS account, [which you can sign up
for here](https://matos.asascience.com/account/signup), in order to
interface with any project-specific files.

## News!

### 2023-02-02

- The package has a pkgdown website at <https://mhpob.github.io/matos/>
- [`act_push_summary`](https://mhpob.github.io/matos/reference/act_push_summary.html)
  is live! This currently only does receiver summaries, but tag
  summaries are coming soon.
- Most functions have been renamed following a LIST-GET workflow.
  - LIST your files to see what you have
  - GET those files
  - and also… UPLOAD. But that didn’t fit into the pithy saying.
- A few functions, namely `list_files` and `get_file` have been split
  into functions with fewer options and clearer names
  (`list_extract_files` and `list_project_files`, e.g.). Hopefully this
  will make things more intuitive.

### 2021-04-12

- `get_updates`: A new function to download all files updated since a
  given date. Super useful after a data push!
- `list_files` now has a `since` argument, allowing you to only list the
  files that have been updated since a certain date.

## Installation

This package is still in “throw things on the wall and see what sticks”
phase (*“this package is currently undergoing heavy development”*). You
can install the most-up-to-date version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("mhpob/matos")
```

## List available files

First, `list_projects` returns the [project
page](https://matos.asascience.com/project), which is useful to figure
out what URLs are associated with each project. You do not need MATOS
permissions in order to view this page.

``` r
library(matos)
#> By continuing, you are agreeing to the ACT Network MATOS User Agreement and
#> Data Policy, Version 1.2:
#> 
#> <]8;;https://matos.asascience.com/static/MATOS.User.Agreement.V1.1.pdfhttps://matos.asascience.com/static/MATOS.User.Agreement.V1.1.pdf]8;;>
#> 

all_projects <- list_projects()

head(all_projects)
#>                                   name number
#> 1                            ACK Array    168
#> 2  APG Atlantic and Shortnose Sturgeon    176
#> 3 ASI - White Shark Study, Montauk, NY    211
#> 4                   ASI Acoustic Array    100
#> 5              ASI Spinner Shark Study    227
#> 6   ASI White Shark Study, Southern NE    232
#>                                               url
#> 1 https://matos.asascience.com/project/detail/168
#> 2 https://matos.asascience.com/project/detail/176
#> 3 https://matos.asascience.com/project/detail/211
#> 4 https://matos.asascience.com/project/detail/100
#> 5 https://matos.asascience.com/project/detail/227
#> 6 https://matos.asascience.com/project/detail/232
```

I can also view the files that I’ve uploaded to my projects using
`list_project_files`, but that requires logging in first.

``` r
project_files <- list_project_files(project = 'umces boem offshore wind energy')
#> ! Please log in.
#> Please enter password in TK window (Alt+Tab)
#> Please enter password in TK window (Alt+Tab)
#> ✔ Login successful!

head(project_files)
#>   project                                file_type upload_date
#> 1      87 Deployed Receivers – Deployment Metadata  2020-03-30
#> 2      87               Tag Detections - .vfl file  2020-05-28
#> 3      87               Tag Detections - .vfl file  2020-05-28
#> 4      87               Tag Detections - .vfl file  2020-05-28
#> 5      87               Tag Detections - .vfl file  2020-05-28
#> 6      87               Tag Detections - .vfl file  2020-05-28
#>                      file_name
#> 1 BOEM_metadata_deployment.xls
#> 2  VR2AR_546455_20170328_1.vrl
#> 3  VR2AR_546456_20170328_1.vrl
#> 4  VR2AR_546457_20170329_1.vrl
#> 5  VR2AR_546458_20170329_1.vrl
#> 6  VR2AR_546459_20170328_1.vrl
#>                                                      url
#> 1  https://matos.asascience.com/projectfile/download/375
#> 2 https://matos.asascience.com/projectfile/download/1810
#> 3 https://matos.asascience.com/projectfile/download/1811
#> 4 https://matos.asascience.com/projectfile/download/1812
#> 5 https://matos.asascience.com/projectfile/download/1813
#> 6 https://matos.asascience.com/projectfile/download/1814
```

I can also list any of my OTN node *Data Extraction Files*.

``` r
ACT_MATOS_files <- list_extract_files(project = 'umces boem offshore wind energy',
                                      detection_type = 'all')

head(ACT_MATOS_files)
#>   project            file_type detection_type detection_year upload_date
#> 1      87 Data Extraction File        matched           2017  2022-11-02
#> 2      87 Data Extraction File        matched           2018  2022-07-13
#> 3      87 Data Extraction File        matched           2019  2022-11-02
#> 4      87 Data Extraction File        matched           2020  2022-11-02
#> 5      87 Data Extraction File        matched           2021  2022-11-02
#> 6      87 Data Extraction File        matched           2022  2022-11-02
#>                            file_name
#> 1 proj87_matched_detections_2017.zip
#> 2 proj87_matched_detections_2018.zip
#> 3 proj87_matched_detections_2019.zip
#> 4 proj87_matched_detections_2020.zip
#> 5 proj87_matched_detections_2021.zip
#> 6 proj87_matched_detections_2022.zip
#>                                                                url
#> 1 https://matos.asascience.com/projectfile/downloadExtraction/87_1
#> 2 https://matos.asascience.com/projectfile/downloadExtraction/87_2
#> 3 https://matos.asascience.com/projectfile/downloadExtraction/87_3
#> 4 https://matos.asascience.com/projectfile/downloadExtraction/87_4
#> 5 https://matos.asascience.com/projectfile/downloadExtraction/87_5
#> 6 https://matos.asascience.com/projectfile/downloadExtraction/87_6
```

## Download project or data extraction files

There are a few ways to download the different types of files held by
MATOS. I can download directly if I know the URL of the file:

``` r
project_files$url[1]
#> [1] "https://matos.asascience.com/projectfile/download/375"

get_project_file(url = project_files$url[1])
#> 
#> ── Downloading files ───────────────────────────────────────────────────────────
#> ✔ File(s) saved to:
#>    C:\Users\darpa2\Analysis\matos\BOEM_metadata_deployment.xls
#> 
#> ── Unzipping files ─────────────────────────────────────────────────────────────
#> [1] "C:\\Users\\darpa2\\Analysis\\matos\\BOEM_metadata_deployment.xls"
```

I can download by using an index from the `ACT_MATOS_files` table above,
here the file on the second row.

``` r
get_extract_file(file = 2, project = 'umces boem offshore wind energy')
#> 
#> ── Downloading files ───────────────────────────────────────────────────────────
#> ✔ File(s) saved to:
#>    C:\Users\darpa2\Analysis\matos\proj87_matched_detections_2018.zip
#> 
#> ── Unzipping files ─────────────────────────────────────────────────────────────
#> ✔ File(s) unzipped to:
#>    C:/Users/darpa2/Analysis/matos/proj87_matched_detections_2018.csv
#>    C:/Users/darpa2/Analysis/matos/data_description.txt
#> [1] "C:/Users/darpa2/Analysis/matos/proj87_matched_detections_2018.csv"
#> [2] "C:/Users/darpa2/Analysis/matos/data_description.txt"
```

## Search and download tag detections

Using the `tag_search` function, I can interface with MATOS’ [tag search
page](https://matos.asascience.com/search). Be very careful with this
function – it can take a *very*, **VERY** long time to return your
files. This function downloads the requested CSV into your working
directory, and, if `import = T` is used, reads it into your R session.

``` r
my_detections <- tag_search(tags = paste0('A69-1601-254', seq(60, 90, 1)),
                            start_date = '03/01/2016',
                            end_date = '04/01/2016', 
                            import = T)
```

## Upload files to MATOS

There are times when you want to upload new data to MATOS. The currently
accepted data types and formats are:

- newly-deployed transmitters (CSV/XLS(X))
- detection logs (CSV/VRL)
- receiver and glider deployment metadata (CSV/XLS(X))
- receiver events like temperature, tilt, etc. (CSV)
- glider GPS tracks (CSV)

A few data types use designated Ocean Tracking Network templates:

- tag metadata
- receiver deployment metadata
- glider deployment metadata

If you don’t have one of these templates downloaded, you can download it
through the package. For example:

``` r
get_otn_template('glider')
```

Then, get to uploading!

``` r
upload_file(project = 'umces boem offshore wind energy',
            file = c('this_is_a_dummy_file.csv', 'so_is_this.csv'),
            data_type = 'new_tags')
```

## Development

As is noted above, this package is undergoing a ton of development. If
there’s something I missed, please [open an issue on
GitHub](https://github.com/mhpob/matos/issues) or [email me (Mike
O’Brien: obrien@umces.edu) directly](mailto:obrien@umces.edu).

## Notes

- Sessions expire more-frequently than we would like. Because of this,
  you may often be prompted to log in. Just follow the instructions and
  crunch away.
