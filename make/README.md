
<!-- README.md is generated from README.Rmd. Please edit this file -->
<!-- Very likely that you'll need to run rmarkdown::render('readme.rmd') rather than the knit button. -->
<!-- readme.html will be created and is unnecessary, so delete that. -->

# matos

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
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

## Installation

This package is still in “throw things on the wall and see what sticks”
phase (*“this package is currently undergoing heavy development”*). You
can install the most-up-to-date version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("mhpob/matos")
```

## Development

As is noted above, this package is undergoing a ton of development. If
there’s something I missed, please [open an issue on
GitHub](https://github.com/mhpob/matos/issues) or [email me (Mike
O’Brien: obrien@umces.edu) directly](mailto:obrien@umces.edu).
