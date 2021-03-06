furrr Introduction
================

``` r
library(tidyverse)
library(furrr)
library(purrr)
library(tictoc)
#library(future)
```

## furrr Introduction

Follows along with <https://davisvaughan.github.io/furrr/>

furrr combines purrr’s mapping functions with futures parallel
processing capabilities

This gives a lot of functions that are nearly the same as the purrr
version, but with futures. For example: \* `map()` to `future_map()` \*
`map2_dbl()` to `future_map2_dbl()` \* `map_at()` to `future_map_at()`

Example:

``` r
map(c("hello", "world"), ~.x)
```

    ## [[1]]
    ## [1] "hello"
    ## 
    ## [[2]]
    ## [1] "world"

``` r
future_map(c("hello", "world"), ~.x)
```

    ## [[1]]
    ## [1] "hello"
    ## 
    ## [[2]]
    ## [1] "world"

Default “backend” for furrr is sequential. The above code runs but is
not in parallel. To change this, use future.

``` r
plan(multisession, workers=2)
future_map(c("hello", "world"), ~.x)
```

    ## [[1]]
    ## [1] "hello"
    ## 
    ## [[2]]
    ## [1] "world"

That did run in parallel. Here’s proof:

``` r
plan(sequential)
tic()
nothingness <- future_map(c(2,2,2), ~Sys.sleep(.x))
toc()
```

    ## 6.13 sec elapsed

``` r
plan(multisession, workers = 3)
tic()
nothingness <- future_map(c(2,2,2), ~Sys.sleep(.x))
toc()
```

    ## 2.45 sec elapsed

:open\_mouth:

### Data transfer

  - Since data has to be passed back and forth between the workers you
    have to be careful that your performance gain from parallelization
    isn’t lost by moving large amounts of data around.
  - This is especially true when using `future_pmap()` to iterate over
    rows and return large objects at each iteration
