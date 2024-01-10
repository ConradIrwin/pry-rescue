## v1.6.0 (9 January 2024)
* Fix ruby 3.2 compatibility

## v1.5.2 (24 June 2020)
* RSpec: Fix Rescue opening after transactional tests are rolled back.
(issue #99 - PR #118) (@joallard)

* bin/rescue: Use realpaths (issue #109 - PR #110)

  *(Damien Robert)*

## v1.5.1 (22 May 2020)
* Make Binding#source_location polyfill. (Removes deprecation warnings
    for Ruby 2.6+)
