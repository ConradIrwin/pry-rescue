* RSpec: Fix Rescue opening after transactional tests are rolled back.
(issue #99 - PR #118)

* bin/rescue: Use realpaths (issue #109 - PR #110)

  *(Damien Robert)*

## v1.5.1 (22 May 2020)
* Make Binding#source_location polyfill. (Removes deprecation warnings
    for Ruby 2.6+)
