07\_timing-experiment
================

This file runs an experiment with `bench::mark()` to determine if the
sequential or parallel approach is faster in this example. It requires:

  - `results/pct_completions.rds`
  - `src/R/bootstrap-functions.R`
  - `src/R/connect-to-ec2.R`
  - `data/ssh_info.csv`

And it outputs both a plot and table png files.

``` r
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
```

    ## -- Attaching packages ---------------------------------------------------------------------------------------------------------------------------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.2     v purrr   0.3.4
    ## v tibble  3.0.1     v dplyr   0.8.5
    ## v tidyr   1.0.3     v stringr 1.4.0
    ## v readr   1.3.1     v forcats 0.5.0

    ## Warning: package 'ggplot2' was built under R version 4.0.3

    ## -- Conflicts ------------------------------------------------------------------------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(here)
```

    ## Warning: package 'here' was built under R version 4.0.3

    ## here() starts at C:/Users/erick/Documents/PCS_f2020/erickabsmith-project-trail

``` r
library(rsample)
```

    ## Warning: package 'rsample' was built under R version 4.0.3

``` r
library(ggpubr)
library(magrittr)
```

    ## 
    ## Attaching package: 'magrittr'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     set_names

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
library(purrr)
library(furrr)
```

    ## Warning: package 'furrr' was built under R version 4.0.3

    ## Loading required package: future

    ## Warning: package 'future' was built under R version 4.0.3

``` r
library(future)
library(parallelly)
```

    ## Warning: package 'parallelly' was built under R version 4.0.3

``` r
library(kableExtra)
```

    ## Warning: package 'kableExtra' was built under R version 4.0.3

    ## 
    ## Attaching package: 'kableExtra'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     group_rows

Load data and functions

``` r
pct_completions <- readRDS(here("results", "pct_completions.rds"))
source(here("src/R", "bootstrap-functions.R"))
source(here("src/R", "connect-to-ec2.R"))
ssh_info <- read_csv(here("data", "ssh_info.csv"))
```

Connect to EC2

``` r
public_ip <- ssh_info$ip
ssh_private_key_file <- ssh_info$filepath
cl <- connect_to_ec2(public_ip, ssh_private_key_file)
```

    ## [local output] Workers: [n = 1] '54.202.251.117'

    ## [local output] Base port: 11266

    ## [local output] Creating node 1 of 1 ...

    ## [local output] - setting up node

    ## [local output] - attempt #1 of 3

    ## [local output] Using 'rshcmd': 'plink', '-ssh', '-i', 'C:/Program Files/PuTTY/plink.exe' [type='<unknown>', version='<unknown>']

    ## [local output] Starting worker #1 on '54.202.251.117': "plink" "-ssh" "-i" "C:/Program Files/PuTTY/plink.exe" -R 11266:localhost:11266 -l ubuntu -i C:/Users/erick/Documents/AWS/trying-again.ppk 54.202.251.117 "\"Rscript\" --default-packages=datasets,utils,grDevices,graphics,stats,methods -e \"workRSOCK <- tryCatch(parallel:::.slaveRSOCK, error=function(e) parallel:::.workRSOCK); workRSOCK()\" MASTER=localhost PORT=11266 OUT=/dev/null TIMEOUT=2592000 XDR=TRUE"

    ## [local output] - Exit code of system() call: 0

    ## [local output] Waiting for worker #1 on '54.202.251.117' to connect back

    ## [local output] Connection with worker #1 on '54.202.251.117' established

    ## [local output] - collecting session information

    ## [local output] Creating node 1 of 1 ... done

``` r
timings <- bench::mark(
  {set.seed(72)
  plan(cluster, workers = cl)
  resamples <- future_get_bootstrap_prop_means(original_dat=pct_completions, ntimes = 1000)
  },
  {set.seed(72)
  plan(sequential)
  resamples <- compare_get_bootstrap_prop_means(original_dat=pct_completions, ntimes = 1000)
  },
  check=FALSE
)
```

``` r
timings_plot <- plot(timings, color="black")
timings_plot_polished <- timings_plot + 
  theme_light() +
  theme(axis.text.y = element_blank(),
        legend.position = "none")+
  labs(title = "Result of timing experiment",
       x = "\n") 
timings_plot_polished_annotated <- annotate_figure(timings_plot_polished,
                left = text_grob("Parallel                                       Sequential", rot=90))
  
ggsave("timing-experiment-plot.png", plot=timings_plot_polished_annotated, path="../../results")
```

    ## Saving 7 x 5 in image

``` r
names <- data.frame(Function = c("Parallel", "Sequential"))
cbind(names, timings[,1:9]) %>%
  mutate(Function = c("Parallel", "Sequential")) %>%
  kableExtra::kbl() %>%
  kable_styling(c("bordered", "condensed"), full_width = FALSE) %>%
  save_kable(file="../../results/timing-experient-table.png")
```
