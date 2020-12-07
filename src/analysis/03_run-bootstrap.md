03\_run-bootstrap
================

This file runs the sequential bootstrap described in `README.md` *I.
Sequential*. It requires the `bootstrap_functions.R` file and the
`results/pct_completions.rds` data. It outputs two files, the
`results/bootstrap-resamples.rds` which includes all of the resamples,
and the `results/mean-and-ci.rds` file which just contains those summary
statistics.

``` r
library(tidyverse)
library(here)
library(rsample)
library(ggpubr)
library(magrittr)
library(purrr)
```

Load data and functions

``` r
pct_completions <- readRDS(here("results", "pct_completions.rds"))
source(here("src/R", "bootstrap-functions.R"))
```

Do bootstrap resampling

``` r
resamples <- data.frame(mean_prop_completed=compare_get_bootstrap_prop_means(original_dat=pct_completions, ntimes = 100000))
```

Create data frame with observed mean, bootstrap mean, and bootstrap
confidence interval

``` r
obs_mean <- mean(pct_completions$prop)

ci <- resamples %>% 
  pull(mean_prop_completed) %>% 
  quantile(probs = c(0.025, 0.975))

bootmean <- resamples %>%
  pull(mean_prop_completed) %>%
  mean()

means_and_ci <- data.frame(
  obs_mean = obs_mean,
  bootmean  = bootmean,
  "2.5%" = ci[1],
  "97.5%" = ci[2])

rownames(means_and_ci) <- NULL
```

Export results

``` r
saveRDS(resamples, here("results", "bootstrap-resamples.rds"))
saveRDS(means_and_ci, here("results", "bootstrap-mean-and-ci.rds"))
```
