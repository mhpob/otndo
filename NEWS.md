## otndo 0.2
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
