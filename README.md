
<!-- README.md is generated from README.Rmd. Please edit this file -->

<!-- Very likely that you'll need to run rmarkdown::render('readme.rmd') rather than the knit button. -->

<!-- readme.html will be created and is unnecessary, so delete that. -->

# matos

<!-- badges: start -->

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

## Installation

This package is still in “throw things on the wall and see what sticks”
phase (*“this package is currently undergoing heavy development”*). You
can install the most-up-to-date version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("mhpob/matos")
```

## List available files

First, `matos_projects` returns the [project
page](https://matos.asascience.com/project), which is useful to figure
out what URLs are associated with each project. You do not need MATOS
permissions in order to view this page.

``` r
library(matos)

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

I can also view the files that I’ve uploaded to my projects using
`list_files`, but that requires logging in first.

``` r
project_files <- list_files(project = 'umces boem offshore wind energy', data_type = 'project')
#> Please log in.

head(project_files)
#>                           name                                     type upload_date                                                    url
#> 1 BOEM_metadata_deployment.xls Deployed Receivers – Deployment Metadata   3/30/2020  https://matos.asascience.com/projectfile/download/375
#> 2  VR2AR_546455_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020 https://matos.asascience.com/projectfile/download/1810
#> 3  VR2AR_546456_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020 https://matos.asascience.com/projectfile/download/1811
#> 4  VR2AR_546457_20170329_1.vrl               Tag Detections - .vfl file   5/28/2020 https://matos.asascience.com/projectfile/download/1812
#> 5  VR2AR_546458_20170329_1.vrl               Tag Detections - .vfl file   5/28/2020 https://matos.asascience.com/projectfile/download/1813
#> 6  VR2AR_546459_20170328_1.vrl               Tag Detections - .vfl file   5/28/2020 https://matos.asascience.com/projectfile/download/1814
```

I can also list any of my OTN node *Data Extraction Files*.

``` r
ACT_MATOS_files <- list_files(project = 'umces boem offshore wind energy', data_type = 'extraction')

head(ACT_MATOS_files)
#>                                   name                 type upload_date                                                              url
#> 1   proj87_matched_detections_2017.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_1
#> 2   proj87_matched_detections_2018.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_2
#> 3   proj87_matched_detections_2019.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_3
#> 4   proj87_matched_detections_2020.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_4
#> 5 proj87_qualified_detections_2016.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_5
#> 6 proj87_qualified_detections_2017.zip Data Extraction File   8/28/2020 https://matos.asascience.com/projectfile/downloadExtraction/87_6
```

## Download project or data extraction files

There are a few ways to download the different types of files held by
MATOS. I can download directly if I know the URL of the file:

``` r
project_files$url[1]
#> [1] "https://matos.asascience.com/projectfile/download/375"

get_file(url = project_files$url[1])
#> File saved to C:\Users\darpa2\Analysis\matos\BOEM_metadata_deployment.xls
```

I can download by using an index from the `ACT_MATOS_files` table above,
here the file on the second row. Note that this means we have to specify
what kind of data we’re looking for when identifying by index.

``` r
get_file(file = 2, project = 'umces boem offshore wind energy', data_type = 'extraction')
#> File saved to C:\Users\darpa2\Analysis\matos\proj87_matched_detections_2018.zip
#> File unzipped to proj87_matched_detections_2018.csv
```

If I download using a file name, `get_file` will use the file extension
to figure out what kind of data I want, so explicitly identifying the
data type is not needed. Since all data extraction files are zipped, the
function assumes the correct data type.

``` r
get_file(file = 'proj87_matched_detections_2018.zip',
         project = 'umces boem offshore wind energy',
         overwrite = T)
#> File saved to C:\Users\darpa2\Analysis\matos\proj87_matched_detections_2018.zip
#> File unzipped to proj87_matched_detections_2018.csv
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

## Development

As is noted above, this package is undergoing a ton of development. If
there’s something I missed, please [open an issue on
GitHub](https://github.com/mhpob/matos/issues) or [email me (Mike
O’Brien: obrien@umces.edu) directly](mailto:obrien@umces.edu).

## Notes

  - Sessions expire more-frequently than we would like. Because of this,
    you may often be prompted to log in. Just follow the instructions
    and crunch away.
