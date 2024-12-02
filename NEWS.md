## otndo 0.3
### v 0.3.3
* Fix bug where reports would be silently dropped if it matched a file name that already existed. [Issue #45](https://github.com/mhpob/otndo/issues/45)

### v 0.3.2
* Fix bug where `otn_query` could return multiple projects from one code, resulting in multiple identical reports being created.

### v 0.3.1
* Fix bug where internal helper functions would break if no H:M:S data was listed in deployment or recovery time metadata

### v 0.3.0
* Summarize according to species for those projects/networks which provide species information. [Issue #41](https://github.com/mhpob/otndo/issues/41)
* Update OTN URLs. [Issue #42](https://github.com/mhpob/otndo/issues/42)

## otndo 0.2
### v 0.2.2
* Fixed behavior where `clean_otn_deployment` would return different columns if there was no internal transmitter logged. [Issue #10](https://github.com/mhpob/otndo/issues/10); [d58e2d4](https://github.com/mhpob/otndo/pull/31/commits/d58e2d46e05aed7ba4acc08b8d02672b28d79804)
* Add internal function (`convert_times`) that checks for Excel-formatted date-times and converts accordingly [f13f360](https://github.com/mhpob/otndo/pull/31/commits/f13f360fe5e4438b6ba668039a6c94f04eeafe60)

### v 0.2.1

* Fleshes out tests to get to 100% coverage (for now!). Note that this is an overestimate as I can't actually get into the QMD files to test.
* Fix bug in `project_contacts` where the merge wasn't actually joing on what I thought it was. [ea26c56](https://github.com/mhpob/otndo/commit/ea26c56847645c94c4ba2bcb41c89faa0c254251)
* Fix bug in the QMD files that didn't reference new data properly, resulting in repeated summary tables. [e7d1368](https://github.com/mhpob/otndo/commit/e7d1368bba22863883e75957037a0973cab27436)
* Properly handles the situation where no new detections exist. [07d9590](https://github.com/mhpob/otndo/commit/07d9590c63706111a9b516ccec2c7400d08eaae5)
* Fixed bug where CSV deployment metadata were not actually checked for the presence of a header. [dc420e6](https://github.com/mhpob/otndo/commit/dc420e6c5bbcdcdde5cb2ef8420cbcbda8469a6e)

### v 0.2.0

* Breaks out all of the functions internal to the QMD template. Will allow for clearer errors and more-directed testing.
* As a result, there are **new functions**! But, be warned: names and arguments are likely to be going through quite a bit of flux as we figure out what each should really be doing.
  * [`deployment_gantt`](https://otndo.obrien.page/reference/deployment_gantt.html)
  * [`match_map`](https://otndo.obrien.page/reference/match_map.html)
  * [`match_table`](https://otndo.obrien.page/reference/match_table.html)
  * [`matched_abacus`](https://otndo.obrien.page/reference/matched_abacus.html)
  * [`otn_query`](https://otndo.obrien.page/reference/otn_query.html)
  * [`prep_station_spatial`](https://otndo.obrien.page/reference/prep_station_spatial.html)
  * [`project_contacts`](https://otndo.obrien.page/reference/project_contacts.html)
  * [`remaining_transmitters`](https://otndo.obrien.page/reference/remaining_transmitters.html)
  * [`station_table`](https://otndo.obrien.page/reference/station_table.html)
  * [`temporal_distribution`](https://otndo.obrien.page/reference/temporal_distribution.html)
* Added an initial suite of tests for all functions.
* Changed license to CC-BY

## otndo 0.1

* Fix issue where otndo would get lost when deployment metadata sheet wasn't labeled
* Switch to semantic versioning
* Add figure and table captions
* Runiverse!
* Miscellaneous fixes
* Combine the PIs/POCs of projects with changing staff

## otndo 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
