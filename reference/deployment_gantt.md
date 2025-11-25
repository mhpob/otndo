# Create a Gantt-like chart of receiver deployments and recoveries

Create a Gantt-like chart of receiver deployments and recoveries

## Usage

``` r
deployment_gantt(deployment)
```

## Arguments

- deployment:

  Cleaned deployment metadata sheet(s). Assumes it was cleaned with the
  internal `otndo:::clean_otn_deployment` function, read in, and
  converted to a data.table.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download a deployment metadata file
td <- file.path(tempdir(), "matos_test_files")
dir.create(td)

download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/pbsm/",
    "data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls/",
    "@download/file"
  ),
  destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
  mode = "wb"
)

# Use internal function to clean
deployment_filepath <- otndo:::write_to_tempdir(
  type = "deployment",
  files = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
  temp_dir = td
)

# Make the Gantt chart
deployment_gantt(
  data.table::fread(deployment_filepath)
)
} # }
```
