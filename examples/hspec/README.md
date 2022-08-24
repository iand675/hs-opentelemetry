# hspec instrumentation example

This directory contains a project demonstrating instrumenting a test suite with
the hspec instrumentation.

Note that this uses `cabal run`: `cabal test` doesn't allow owning the test
entry point.

Sample output:

```
$ cabal run hspec-example:test
....
Target
  adds two
    adds 2 to 2 [✔]

Finished in 0.0001 seconds
1 example, 0 failures
Done
Trace link: (some service)/504136ca94f41ab5f9afda25612280ea
"504136ca94f41ab5f9afda25612280ea" "8794b7b2dba28bbf" Timestamp (TimeSpec {sec = 1661367581, nsec = 198794000}) adds 2 to 2
"504136ca94f41ab5f9afda25612280ea" "4e6d6ccd2ccd0369" Timestamp (TimeSpec {sec = 1661367581, nsec = 197769000}) Run tests
```
