# matos 0.2

  - The package has a pkgdown website at [https://mhpob.github.io/matos/](https://mhpob.github.io/matos/)
  - [`act_push_summary`](https://mhpob.github.io/matos/reference/act_push_summary.html) is live! This currently only does receiver summaries, but tag summaries are coming soon.
  - Most functions have been renamed following a LIST-GET workflow.
    - LIST your files to see what you have
    - GET those files
    - and also... UPLOAD. But that didn't fit into the pithy saying.
  - A few functions, namely `list_files` and `get_file` have been split into functions with fewer options and clearer names (`list_extract_files` and `list_project_files`, e.g.). Hopefully this will make things more intuitive.
  
# matos 0.1.1
  - `get_updates`: A new function to download all files updated since a given date. Super useful after a data push!
  - `list_files` now has a `since` argument, allowing you to only list the files that have been updated since a certain date.
* Added a `NEWS.md` file to track changes to the package.
