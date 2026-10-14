# Plot the geographic extent of OTN projects

Plot the geographic extent of OTN projects

## Usage

``` r
match_map(otn_tables)
```

## Arguments

- otn_tables:

  A list containing OTN's `otn_resources_metadata_points` GeoServer
  layer. Usually created using `otn_query`.

## Examples

``` r
match_map(
  otn_query("MDWEA")
)

```
