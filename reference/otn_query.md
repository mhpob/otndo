# Query the OTN Geoserver

Query the OTN Geoserver

## Usage

``` r
otn_query(projects)
```

## Arguments

- projects:

  Character vector of OTN project codes for which you'd like project
  metadata. Prepended networks can be provided, but are not necessary.

## Value

list of the "otn_resources_metadata_points" and "project_metadata" for
the given projects

## Examples

``` r
otn_query(c("EST", "FACT.SCDNRDFP", "ACT.MDBSB", "MDBSB"))
#> $otn_resources_metadata_points
#>                                                            FID collectioncode
#>                                                         <char>         <char>
#> 1: otn_resources_metadata_points.fid-14821727_19abbbbb2bd_47b7            EST
#> 2: otn_resources_metadata_points.fid-14821727_19abbbbb2bd_48db       SCDNRDFP
#> 3: otn_resources_metadata_points.fid-14821727_19abbbbb2bd_4a72          MDBSB
#>    report
#>    <lgcl>
#> 1:     NA
#> 2:     NA
#> 3:     NA
#>                                                                                                               resource_full_name
#>                                                                                                                           <char>
#> 1:                                                                        Shedd Aquarium Bahamas Sharks and Ray Research Program
#> 2:                                                                                    Diadromous Fishes statewide movement in SC
#> 3: Influence of Turbine Construction Noise on Black Sea Bass Displacement and Physiological Condition in the MD Wind Energy Area
#>          ocean seriescode    status collaborationtype totalrecords    id
#>         <char>     <char>    <char>            <char>       <lgcl> <int>
#> 1: NW ATLANTIC  OTNGlobal   ongoing              Data           NA   391
#> 2: NW ATLANTIC       FACT   ongoing        Deployment           NA   692
#> 3: NW ATLANTIC        ACT completed              Data           NA  1100
#>                                                                          the_geom
#>                                                                            <char>
#> 1: POLYGON ((-76.85 23.62, -76.85 24.83, -75.9 24.83, -75.9 23.62, -76.85 23.62))
#> 2:     POLYGON ((-82.46 25.41, -82.46 35.99, -78 35.99, -78 25.41, -82.46 25.41))
#> 3: POLYGON ((-79.53 33.88, -79.53 42.26, -68.1 42.26, -68.1 33.88, -79.53 33.88))
#> 
#> $project_metadata
#> Empty data.table (0 rows and 29 cols): FID,collectioncode,id,seriescode,collaborationtype,shortname...
#> 
```
