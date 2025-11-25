# Place where functions live for the make\_\*\_summary family of functions

Place where functions live for the make\_\*\_summary family of functions

## Usage

``` r
clean_otn_deployment(deployment)

convert_times(date_time)

provided_file_unzip(files, temp_dir)

write_to_tempdir(type, files, temp_dir)

extract_proj_name(detection_file)

copy_from_temp(report, code, td, out_dir, overwrite)
```

## Arguments

- deployment:

  Character. File path of deployment metadata.

- date_time:

  Character or numeric. Date-time to convert.

- files:

  Character. File paths of files to be unzipped or written to a
  directory

- temp_dir:

  Character. File path of temporary directory

- type:

  Character. Type of data (deployment, qualified, or unqualified).

- detection_file:

  Character. File path of detections.

- report:

  Character. Type of report ("tag" or "receiver").

- code:

  Character. Project code.

- out_dir:

  Character. Output directory.
