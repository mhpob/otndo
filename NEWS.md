# matos 0.2.1

  - The website has moved to [https://matos.obrien.page/](https://matos.obrien.page/).
  - [`set_matos_credentials`](https://matos.obrien.page/reference/set_matos_credentials.html) 
    - *NEW* function!
    - Allows you to store your MATOS credentials in your [.Renviron](https://rstats.wtf/r-startup.html#renviron) for seamless log in.
  - [`make_tag_push_summary`](https://matos.obrien.page/reference/make_tag_push_summary.html)
    - *NEW* function!
    - Undergoing heavy development, so please file issues with bugs and suggestions.
    - Summarize your your TON returns of tagged fish!
  - [`make_tag_push_summary`](https://matos.obrien.page/reference/make_tag_push_summary.html) and [`make_receiver_push_summary`](https://matos.obrien.page/reference/make_receiver_push_summary.html) now accept zipped folders as input.

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
