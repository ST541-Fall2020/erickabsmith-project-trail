05\_run\_bootstrap\_parallel
================

This file creates the resamples data from the parallel approach,
`results/parallel-bootstrap-resamples.rds`, and a file with summary
statistics, `results/parallel-bootstrap-mean-and-ci.rds`

It requires: \* `results/pct_completions.rds` \*
`src/R/bootstrap-functions.R` \* `src/R/connect-to-ec2.R` \*
`data/ssh_info.csv`

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

    ## [local output] Base port: 11784

    ## [local output] Creating node 1 of 1 ...

    ## [local output] - setting up node

    ## [local output] - attempt #1 of 3

    ## [local output] Using 'rshcmd': 'plink', '-ssh', '-i', 'C:/Program Files/PuTTY/plink.exe' [type='<unknown>', version='<unknown>']

    ## [local output] Starting worker #1 on '54.202.251.117': "plink" "-ssh" "-i" "C:/Program Files/PuTTY/plink.exe" -R 11784:localhost:11784 -l ubuntu -i C:/Users/erick/Documents/AWS/trying-again.ppk 54.202.251.117 "\"Rscript\" --default-packages=datasets,utils,grDevices,graphics,stats,methods -e \"workRSOCK <- tryCatch(parallel:::.slaveRSOCK, error=function(e) parallel:::.workRSOCK); workRSOCK()\" MASTER=localhost PORT=11784 OUT=/dev/null TIMEOUT=2592000 XDR=TRUE"

    ## [local output] - Exit code of system() call: 0

    ## [local output] Waiting for worker #1 on '54.202.251.117' to connect back

    ## [local output] Connection with worker #1 on '54.202.251.117' established

    ## [local output] - collecting session information

    ## [local output] Creating node 1 of 1 ... done

``` r
cl
```

    ## Socket cluster with 1 nodes where 1 node is on host '54.202.251.117' (R version 4.0.2 (2020-06-22), platform x86_64-pc-linux-gnu)

Run Bootstrap

``` r
plan(cluster, workers = cl)
resamples <- future_get_bootstrap_prop_means(original_dat=pct_completions, ntimes = 100000)
mean(resamples)
```

    ## [1] 0.3498701

``` r
sd(resamples)
```

    ## [1] 0.1241185

Disconnect EC2

``` r
plan(sequential)
parallel::stopCluster(cl)
```

Create data frame with observed mean, bootstrap mean, and bootstrap
confidence interval

``` r
obs_mean <- mean(pct_completions$prop)
bootmean <- mean(resamples)
ci <- c("lb"=bootmean-sd(resamples),
        "ub"=bootmean+sd(resamples))

future_means_and_ci <- data.frame(
  obs_mean = obs_mean,
  bootmean  = bootmean,
  "2.5%" = ci[1],
  "97.5%" = ci[2])

rownames(future_means_and_ci) <- NULL
```

Export results

``` r
saveRDS(resamples, here("results", "parallel-bootstrap-resamples.rds"))
saveRDS(future_means_and_ci, here("results", "parallel-bootstrap-mean-and-ci.rds"))
```
