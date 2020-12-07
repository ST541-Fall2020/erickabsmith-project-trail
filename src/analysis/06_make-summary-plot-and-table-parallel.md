06\_make-summary-plot-and-table-parallel
================

This file creates a plot and a table from the resamples data from the
parallel approach which are saved at
`results/parallel-bootstrap-distribution-plot.png` and
`results/parallel-means-and-ci.png"`

It requires: \* `results/parallel-bootstrap-resamples.rds` \*
`results/parallel-bootstrap-mean-and-ci.rds`

``` r
library(tidyverse)
library(here)
library(ggpubr)
library(kableExtra)
library(magick)
```

Load Data

``` r
mean_prop_completed <- readRDS(here("results", "parallel-bootstrap-resamples.rds"))
parallel_resamples <- as.data.frame(mean_prop_completed)
parallel_means_and_ci <- readRDS(here("results", "parallel-bootstrap-mean-and-ci.rds"))
```

Create plot of (parallel) bootstrap distribution

``` r
parallel_bootstrap_dist_plot <- parallel_resamples %>% 
  ggplot(aes(x = mean_prop_completed)) +
  geom_histogram(fill = "darkblue") +
  geom_vline(xintercept = parallel_means_and_ci$bootmean) +
  geom_vline(xintercept = parallel_means_and_ci$X2.5., 
             linetype = "dashed") +
  geom_vline(xintercept = parallel_means_and_ci$X97.5., 
             linetype = "dashed") +
  labs(title = "Bootstrap distribution of mean proportion of thru-hikers to \nfinish the Pacific Crest Trail 2013-2019",
       x = "Estimate of Mean Proportion")+
  theme_light()+
  annotate("text", 
           x=0.7, 
           y=7000, 
           label = "Lines represent \nbootstrap mean and\n95% confidence interval")
```

Export plot

``` r
ggsave("parallel-bootstrap-distribution-plot.png", plot=parallel_bootstrap_dist_plot, path="../../results")
```

    ## Saving 7 x 5 in image

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

Create and export table

``` r
names(parallel_means_and_ci) <- c("Observed Mean", 
                         "Parallel Bootstrap Mean", 
                         "Boostrap Confidence Interval Lower Bound (2.5%)",
                         "Boostrap Confidence Interval Upper Bound (97.5%)")
parallel_means_and_ci %>%
  kbl() %>%
  kable_styling(c("bordered", "condensed"), full_width = FALSE, font_size = 12) %>%
  save_kable(file="../../results/parallel-means-and-ci.png")
```
