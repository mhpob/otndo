
<!-- README.md is generated from README.Rmd. Please edit this file -->

<!-- Very likely that you'll need to run rmarkdown::render('readme.rmd') rather than the knit button. -->

# matos

<!-- badges: start -->

<!-- badges: end -->

{matos} is a wrapper over a suite of [httr](https://httr.r-lib.org/) and
[rvest](https://rvest.tidyverse.org/) functions made to interact with
the [Mid-Atlantic Acoustic Telemetry Observing System
website](https://matos.asascience.com/). Because of this, it’s not
necessarily fast or the best way to do things – we’re just pinging the
website back and forth. Additionally, an internet connection is needed
for pretty much anything to work.

Please note that you will need a MATOS account, [which you can sign up
for here](https://matos.asascience.com/account/signup), in order to
interface with any project-specific files.

## Installation

This package is still in “throw things on the wall and see what sticks”
phase. You can install the most-up-to-date version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("mhpob/matos")
```

## Quick start

The first thing you should do is log into your MATOS account. This can
be done through the package, using the [RStudio
API](https://rstudio.github.io/rstudio-extensions/rstudioapi.html). This
probably won’t work if you’re not using RStudio, so it will be changed
in the future. A pop up will appear asking for your username and
password. If everything works out, your credentials will be kept in the
sessions’ cookies. Your username/password will not be saved – this was
done intentionally so that you don’t accidentally save credentials in a
public script.

``` r
library(matos)

matos_login()
#> NULL
```

In addition to the above, there are/will be a few fucntions that take no
arguments – their sole function is to ping the website and return the
data to you. `matos_projects` returns the [project
page](https://matos.asascience.com/project), which is useful to figure
out what URLs are associated with each project. You do not need MATOS
permissions in order to view this page.

``` r
all_projects <- matos_projects()

head(all_projects)
#>                                      name number                                             url
#> 1                apg: sturgeon monitoring     88  https://matos.asascience.com/project/detail/88
#> 2             artificial reef habitat use    128 https://matos.asascience.com/project/detail/128
#> 3 boem-de offshore wind energy area study     85  https://matos.asascience.com/project/detail/85
#> 4      btwaves caribbean acoustic tagging     94  https://matos.asascience.com/project/detail/94
#> 5                    cfcc marine tech cfr     98  https://matos.asascience.com/project/detail/98
#> 6              cff black sea bass tagging     91  https://matos.asascience.com/project/detail/91
```

Since I’m logged in, I can view the files that I’ve uploaded to my
projects.

``` r
files <- list_files(project = 'umces boem offshore wind energy', data_type = 'project')

head(files)
#>                      File.Name                                File.Type Upload.Date
#> 1 BOEM_metadata_deployment.xls Deployed Receivers – Deployment Metadata   3/30/2020
#> 2  VR2AR_546455_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020
#> 3  VR2AR_546456_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020
#> 4  VR2AR_546457_20170329_1.vrl               Tag Detections - .vfl file   5/28/2020
#> 5  VR2AR_546458_20170329_1.vrl               Tag Detections - .vfl file   5/28/2020
#> 6  VR2AR_546459_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020
#>                                                      url
#> 1  https://matos.asascience.com/projectfile/download/375
#> 2 https://matos.asascience.com/projectfile/download/1810
#> 3 https://matos.asascience.com/projectfile/download/1811
#> 4 https://matos.asascience.com/projectfile/download/1812
#> 5 https://matos.asascience.com/projectfile/download/1813
#> 6 https://matos.asascience.com/projectfile/download/1814
```

And, I can download any of my choosing.

``` r
files$url[1]
#> [1] "https://matos.asascience.com/projectfile/download/375"

get_file(url = files$url[1])
#> File saved to C:\Users\darpa2\Analysis\matos\BOEM_metadata_deployment.xls
```

I can also locate, download, and unzip *Data Extraction Files*.

``` r
ACT_MATOS_files <- list_files(project = 'umces boem offshore wind energy', data_type = 'extraction')

head(ACT_MATOS_files)
#>                              File.Name            File.Type Upload.Date
#> 1   proj87_matched_detections_2017.zip Data Extraction File   8/28/2020
#> 2   proj87_matched_detections_2018.zip Data Extraction File   8/28/2020
#> 3   proj87_matched_detections_2019.zip Data Extraction File   8/28/2020
#> 4   proj87_matched_detections_2020.zip Data Extraction File   8/28/2020
#> 5 proj87_qualified_detections_2016.zip Data Extraction File   8/28/2020
#> 6 proj87_qualified_detections_2017.zip Data Extraction File   8/28/2020
#>                                                                url
#> 1 https://matos.asascience.com/projectfile/downloadExtraction/87_1
#> 2 https://matos.asascience.com/projectfile/downloadExtraction/87_2
#> 3 https://matos.asascience.com/projectfile/downloadExtraction/87_3
#> 4 https://matos.asascience.com/projectfile/downloadExtraction/87_4
#> 5 https://matos.asascience.com/projectfile/downloadExtraction/87_5
#> 6 https://matos.asascience.com/projectfile/downloadExtraction/87_6
```

We can download by using an index from the table above, here the file on
the second row. Note that this means we have to specify what kind of
data we’re looking for.

``` r
get_file(file = 2, project = 'umces boem offshore wind energy', data_type = 'extraction')
#> File saved to C:\Users\darpa2\Analysis\matos\proj87_matched_detections_2018.zip
#> File unzipped to proj87_matched_detections_2018.csv
```

I can also download using a file name. Since all data extraction files
are zipped, the function assumes the correct data type.

``` r
get_file(file = 'proj87_matched_detections_2018.zip',
         project = 'umces boem offshore wind energy',
         overwrite = T)
#> File saved to C:\Users\darpa2\Analysis\matos\proj87_matched_detections_2018.zip
#> File unzipped to proj87_matched_detections_2018.csv
```
