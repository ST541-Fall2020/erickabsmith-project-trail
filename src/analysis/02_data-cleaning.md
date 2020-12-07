02\_data-cleaning
================

This file inputs the `pcta.rds` file and creates the `prop` and `total`
variables. It outputs the new data into `results/pct_completions.rds`.

``` r
library(tidyverse)
library(here)
```

Import data

``` r
pct_completions <- readRDS(here("data", "pcta.rds"))
```

Filter out unnecessary columns and create proportion completed variable
`prop`

``` r
pct_completions <- pct_completions %>%
  mutate(prop = completions/(northbound+southbound),
         year = factor(year)) %>%
  select(c(year, prop))
```

Export new file

``` r
saveRDS(pct_completions, here("results", "pct_completions.rds"))
```
