00\_data-cleaning
================

``` r
library(tidyverse)
library(here)
```

Import data

``` r
pct_completions <- readRDS("../data/pcta.rds")
```

Filter out unnecessary columns and create proportion completed variable
`prop`

``` r
pct_completions <- pct_completions %>%
  mutate(prop = completions/(northbound+southbound),
         year = factor(year)) %>%
  select(c(year, northbound, southbound, completions, prop))
```

Export new file

``` r
saveRDS(pct_completions, "../results/pct_completions.rds")
```
