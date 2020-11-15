furrr plus EC2
================

``` r
library(furrr)
library(purrr)
library(dplyr)
```

## Remote Connections

following along with vignette at
<https://davisvaughan.github.io/furrr/articles/articles/remote-connections.html>

## Purpose: Learn how to scale furrr with AWS EC2 instances in two ways

1.  Running code remotely in a single EC2 instance
2.  Running code in parallel on multiple EC2 instances

### AWS EC2 ?

  - EC2 is Amazon’s Elastic COmpute Cloud service
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
