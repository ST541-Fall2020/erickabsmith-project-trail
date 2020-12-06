04\_make-summary-plots-and-table
================

``` r
library(tidyverse)
library(here)
library(ggpubr)
library(kableExtra)
library(magick)
```

Load data

``` r
pct_completions <- readRDS(here("results", "pct_completions.rds"))
resamples <- readRDS(here("results", "bootstrap-resamples.rds"))
means_and_ci <- readRDS(here("results", "bootstrap-mean-and-ci.rds"))
```

Create plot of observed proportions

``` r
obs_data_plot <- pct_completions %>% 
  ggplot(aes(x = year, 
             y=prop)) +
  geom_point(color = "darkblue", 
             size = 2) +
  geom_hline(yintercept = means_and_ci$obs_mean, 
             linetype="dashed", 
             color = "blue") +
  labs(title = "Observed proportions of thru-hikers who completed \nthe Pacific Crest Trail each year",
       caption = "\nSource: Pacific Crest Trail Association",
       x = "\nYear",
       y = "Proportion of Hikers who Finished \n")+
  theme_light()+
  annotate("text", 
           x="2018",
           y=0.5, 
           label = "Dashed line represents\nobserved mean proportion", 
           color = "darkblue")
```

Create plot of bootstrap distribution

``` r
bootstrap_dist_plot <- resamples %>% 
  ggplot(aes(x = mean_prop_completed)) +
  geom_histogram(fill = "darkblue") +
  geom_vline(xintercept = means_and_ci$bootmean) +
  geom_vline(xintercept = means_and_ci$X2.5., 
             linetype = "dashed") +
  geom_vline(xintercept = means_and_ci$X97.5., 
             linetype = "dashed") +
  labs(title = "Bootstrap distribution of mean proportion of thru-hikers to \nfinish the Pacific Crest Trail 2013-2019",
       x = "Estimate of Mean Proportion")+
  theme_light()+
  annotate("text", 
           x=0.7, 
           y=7000, 
           label = "Lines represent \nbootstrap mean and\n95% confidence interval")
```

Export plots

``` r
ggsave("observed-data-plot.png", plot = obs_data_plot, path= "../results")
```

    ## Saving 7 x 5 in image

``` r
ggsave("bootstrap-distribution-plot.png", plot=bootstrap_dist_plot, path="../results")
```

    ## Saving 7 x 5 in image

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

Create Table

``` r
names(means_and_ci) <- c("Observed Mean", 
                         "Bootstrap Mean", 
                         "Confidence Interval Lower Bound (2.5%)",
                         "Confidence Interval Upper Bound (97.5%)")
means_and_ci %>%
  kbl() %>%
  kable_styling(c("bordered", "condensed"), full_width = FALSE) %>%
  save_kable(file="../results/means-and-ci.png")
```

## Again, but with parallel bootstrap run data

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
ggsave("parallel-bootstrap-distribution-plot.png", plot=parallel_bootstrap_dist_plot, path="../results")
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
  save_kable(file="../results/parallel-means-and-ci.png")
```
