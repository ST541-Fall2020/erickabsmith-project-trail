furrr plus EC2
================

``` r
library(furrr)
library(purrr)
library(dplyr)
library(future)
library(parallelly)
sessionInfo()
```

    ## R version 4.0.0 (2020-04-24)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 19042)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] parallelly_1.21.0 dplyr_0.8.5       purrr_0.3.4       furrr_0.2.1      
    ## [5] future_1.20.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.4.6     knitr_1.28       magrittr_1.5     tidyselect_1.1.0
    ##  [5] R6_2.4.1         rlang_0.4.7      stringr_1.4.0    globals_0.13.1  
    ##  [9] tools_4.0.0      parallel_4.0.0   xfun_0.13        htmltools_0.4.0 
    ## [13] ellipsis_0.3.0   yaml_2.2.1       digest_0.6.25    assertthat_0.2.1
    ## [17] lifecycle_0.2.0  tibble_3.0.1     crayon_1.3.4     vctrs_0.3.4     
    ## [21] codetools_0.2-16 glue_1.4.0       evaluate_0.14    rmarkdown_2.1   
    ## [25] stringi_1.4.6    pillar_1.4.4     compiler_4.0.0   listenv_0.8.0   
    ## [29] pkgconfig_2.0.3

## Remote Connections

following along with vignette at
<https://davisvaughan.github.io/furrr/articles/articles/remote-connections.html>

## Purpose: Learn how to scale furrr with AWS EC2 instances in two ways

1.  Running code remotely in a single EC2 instance
2.  Running code in parallel on multiple EC2 instances

### AWS EC2 ?

  - EC2 is Amazon’s Elastic Compute Cloud service
  - AMIs are “Amazon Machine Images” and that’s what we use to get an
    instance pre-loaded with R.
      - Louis Aslett, keeps up-to-date RStudio AMIs [on his
        website](http://www.louisaslett.com/RStudio_AMI/)
  - check out [this
    site](https://blog.davisvaughan.com/2017/05/15/rstudio-shiny-aws-1/)
    further to get a hand held through setting up an AWS instance based
    on this AMI

### Running code remotely on a single EC2 instance

This example is just focused on sending the data to a single EC2
instance so that it can run things sequentially. It won’t actually run
in parallel. That’s later.

#### Modeling code

Simple example with linear models for `mtcars`

``` r
by_gear <- mtcars %>%
  group_split(gear) 

models <- map(by_gear, ~lm(mpg ~ cyl + hp + wt, data = .))

models
```

    ## [[1]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    30.48956     -0.31883     -0.02326     -2.03083  
    ## 
    ## 
    ## [[2]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    43.69353      0.05647     -0.12331     -3.20537  
    ## 
    ## 
    ## [[3]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    45.29099     -2.03268      0.02655     -6.42290

run this in parallel locally with furrr

``` r
plan(multisession, workers = 2)

models <- future_map(by_gear, ~lm(mpg ~ cyl + hp + wt, data = .))

models
```

    ## [[1]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    30.48956     -0.31883     -0.02326     -2.03083  
    ## 
    ## 
    ## [[2]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    43.69353      0.05647     -0.12331     -3.20537  
    ## 
    ## 
    ## [[3]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    45.29099     -2.03268      0.02655     -6.42290

This is NOT faster currently.

#### Connecting to an EC2 instance

``` r
# A t2.micro AWS instance
# Created from http://www.louisaslett.com/RStudio_AMI/
#public_ip <- "18.237.4.162"
public_ip <- "ec2-18-237-4-162.us-west-2.compute.amazonaws.com"

# This is where my pem file lives (password file to connect).
ssh_private_key_file <- "C:/Users/erick/Documents/AWS/trying-again.ppk"
pss <-"i-0aa818fddfc1a8419"  # paswword
```

``` r
# connect_to_ec2 <- function(public_ip, ssh_private_key_file) {
#   makeClusterPSOCK(
#     # Public IP number of EC2 instance
#     workers = public_ip,
#     # User name (always 'ubuntu')
#     user = "ubuntu",
#     rshcmd = c("plink", "-ssh", "-i", "C:/Program Files/PuTTY/plink.exe"),
#     # Use private SSH key registered with AWS
#     rshopts = c(
#       "-o", "StrictHostKeyChecking=no",
#       "-o", "IdentitiesOnly=yes",
#       #"-i", ssh_private_key_file,
#       "-pw", pss
#     ),
#     rscript_args = c(
#       # Set up .libPaths() for the 'ubuntu' user
#       "-e", shQuote(paste0(
#         "local({",
#         "p <- Sys.getenv('R_LIBS_USER'); ",
#         "dir.create(p, recursive = TRUE, showWarnings = FALSE); ",
#         ".libPaths(p)",
#         "})"
#       )),
#       # Install furrr
#       "-e", shQuote("install.packages('furrr')")
#     ),
#     # Switch this to TRUE to see the code that is run on the workers without
#     # making the connection
#     dryrun = FALSE,
#     verbose = TRUE,
#     rshlogfile=TRUE
#   )
# }
# 
# cl <- connect_to_ec2(public_ip, ssh_private_key_file)
# 
# cl
#> Socket cluster with 1 nodes where 1 node is on host ‘34.230.28.118’ (R version 3.6.0 (2019-04-26), platform x86_64-pc-linux-gnu)
```

**11/22/2018 Update:** \* Had to add `rschcmd=` arg because my computer
tries to use openSSH and there’s a bug with future and that SSH client.
\* Doesn’t work as is. Looks like `makeClusterPSOCK()` was moved to
`parallelly` this November. \* My best guess is that it’s not working
due to the password, which is why I tried running it with the password…
But the problem is actually probably that I set up my SSH Auth
incorrectly.

**12/2/2020 Update:** \* Works now \* Troubleshooting took a lot of
reading through github issues and working back and forth between command
line and function arguments \* Primary resources: +
<https://github.com/HenrikBengtsson/future/issues/242> +
<https://github.com/HenrikBengtsson/future/issues/136> +
<https://github.com/HenrikBengtsson/parallelly/issues/14#issuecomment-437568082>

A troubleshooting step:

``` r
#system('"plink" "-ssh" "-i" "C:/Program Files/PuTTY/plink.exe" -R 11930:localhost:11930 -l ubuntu -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ~/.ssh/google_compute_engine')

#system('"plink" "-ssh" "-i" "C:/Program Files/PuTTY/plink.exe" -R 11930:localhost:11930 -l ubuntu -i ~/.ssh/google_compute_engine 1.2.3.4 date')
```

Final, working:

``` r
public_ip <- "35.162.70.128"
getwd()
```

    ## [1] "C:/Users/erick/Documents/PCS_f2020/erickabsmith-project-trail/doc"

``` r
ssh_private_key_file <- "C:/Users/erick/Documents/AWS/trying-again.ppk"


connect_to_ec2 <- function(public_ip, ssh_private_key_file) {
  parallelly::makeClusterPSOCK(
    # Public IP number of EC2 instance
    workers = public_ip,
    # User name (always 'ubuntu')
    user = "ubuntu",
    rshcmd = c("plink", "-ssh", "-i", "C:/Program Files/PuTTY/plink.exe"),
    rshopts = c(
      "-i", ssh_private_key_file
    ),
    dryrun = FALSE,
    verbose = TRUE,
  )
}
cl <- connect_to_ec2(public_ip, ssh_private_key_file)
```

    ## [local output] Workers: [n = 1] '35.162.70.128'

    ## [local output] Base port: 11499

    ## [local output] Creating node 1 of 1 ...

    ## [local output] - setting up node

    ## [local output] - attempt #1 of 3

    ## [local output] Using 'rshcmd': 'plink', '-ssh', '-i', 'C:/Program Files/PuTTY/plink.exe' [type='<unknown>', version='<unknown>']

    ## [local output] Starting worker #1 on '35.162.70.128': "plink" "-ssh" "-i" "C:/Program Files/PuTTY/plink.exe" -R 11499:localhost:11499 -l ubuntu -i C:/Users/erick/Documents/AWS/trying-again.ppk 35.162.70.128 "\"Rscript\" --default-packages=datasets,utils,grDevices,graphics,stats,methods -e \"workRSOCK <- tryCatch(parallel:::.slaveRSOCK, error=function(e) parallel:::.workRSOCK); workRSOCK()\" MASTER=localhost PORT=11499 OUT=/dev/null TIMEOUT=2592000 XDR=TRUE"

    ## [local output] - Exit code of system() call: 0

    ## [local output] Waiting for worker #1 on '35.162.70.128' to connect back

    ## [local output] Connection with worker #1 on '35.162.70.128' established

    ## [local output] - collecting session information

    ## [local output] Creating node 1 of 1 ... done

``` r
cl
```

    ## Socket cluster with 1 nodes where 1 node is on host '35.162.70.128' (R version 4.0.2 (2020-06-22), platform x86_64-pc-linux-gnu)

Moving forward in vignette (direct quote follows):

"Let’s step through this a little.

  - `workers` - The public ip addresses of the workers you want to
    connect to. If you have multiple, you can list them here.

  - `user` - Because we used the RStudio AMI, this is always `"ubuntu"`.

  - `rshopts` - These are options that are run on the command line of
    your *local* computer when connecting to the instance by ssh.
    
      - `StrictHostKeyChecking=no` - This is required because by default
        when connecting to the AWS instance for the first time you are
        asked if you want to “continue connecting” because authenticity
        of the AWS instance can’t be verified. Setting this option to no
        means we won’t have to answer this question.
    
      - `IdentitiesOnly=yes` - This is not necessarily required, but
        specifies that we only want to connect using the identity we
        supply with `-i`, which ends up being the `.pem` file.

  - `rscript_args` - This very helpful argument allows you to specify R
    code to run when the command line executable `Rscript` is called on
    your *worker*. Essentially, it allows you to run “start up code” on
    each worker. In this case, it is used to create package paths for
    the `ubuntu` user and to install a few packages that are required to
    work with `furrr`.

  - `dryrun` - This is already set to `FALSE` by default, but it’s
    useful to point this argument out as setting it to `TRUE` allows you
    to verify that the code that should run on each worker is correct."

## Running the code

``` r
plan(cluster, workers = cl)
models <- future_map(by_gear, ~lm(mpg ~ cyl + hp + wt, data = .))
models
```

    ## [[1]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    30.48956     -0.31883     -0.02326     -2.03083  
    ## 
    ## 
    ## [[2]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    43.69353      0.05647     -0.12331     -3.20537  
    ## 
    ## 
    ## [[3]]
    ## 
    ## Call:
    ## lm(formula = mpg ~ cyl + hp + wt, data = .)
    ## 
    ## Coefficients:
    ## (Intercept)          cyl           hp           wt  
    ##    45.29099     -2.03268      0.02655     -6.42290

``` r
# Revert back to a sequential plan
plan(sequential)

parallel::stopCluster(cl)
```
