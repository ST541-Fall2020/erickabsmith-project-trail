
# Bootstrapping the Pacific Crest Trail in Parallel

Ericka B. Smith

This project investigates the chance of successfully completing the Pacific Crest Trail. Data was gathered from the [Pacific Crest Trail Association](https://www.pcta.org/our-work/trail-and-land-management/pct-visitor-use-statistics/) and used to create an estimate of the mean proportion of thru-hikers who finish the trail each year.

In order to estimate this mean bootstrapping was done by using the furrr package (future and purrr) and the socket method of parallelization to create a cluster with Amazon Web Services Elastic Compute Cloud (EC2).

Find my report [here](https://github.com/ST541-Fall2020/erickabsmith-project-trail/blob/master/doc/project_summary.pdf) and my presentation slides [here.](https://github.com/ST541-Fall2020/erickabsmith-project-trail/blob/master/doc/presentation-slides.pdf)

## Getting Started 

To use this project you have two options: 

I.  Run the bootstrapping process sequentially. This can be done entirely with what is provided in this repository. 

II. Run the boostrapping process in parallel. This requires familiarity with Amazon EC2 or somewhat significant time investment (see below for instructions). 

### I. Sequential Approach

Running the project sequentially allows the following files:

* `src/analysis/01_initial-bootstrap-run.Rmd` - This file can be run entirely on it's own. 
* `src/analysis/02_data-cleaning.Rmd` - This is the preliminary step in the analysis.
* `src/analysis/03_run-bootstrap.Rmd` - This is where the sequential bootstrap is actually run.
* `src/analysis/04_make-summary-plots-and-table.Rmd` - This is where summary plots and a table are created.

`01...` only requires the `data/pcta.rds` data file. 

`02...`, `03...`, and `04...` must be run in order as each depends on the one before it, starting with `02...` which requires the `data/pcta.rds` file.
Additionally, `03...` requires `src/R/bootstrap-functions.R`.


### II. Parallel Approach

In order to run any parallel code you must first set up an EC2 instance. If this is new to you, these some resources created by [Davis Vaughan](https://davisvaughan.github.io/index.html) will assist in that:

1. [Remote connections](https://davisvaughan.github.io/furrr/articles/articles/remote-connections.html)
    * Note that the code for connecting to EC2 (under *"Connecting to an EC2 instance"*) is not entirely correct for Windows users. Use the function at `src/R/connect-to-ec2.R` if using Windows. If using another OS troubleshooting may be required that is not supported by this project. 
3. [RStudio and Shiny Servers with AWS - Part 1](https://blog.davisvaughan.com/2017/05/15/rstudio-shiny-aws-1/). 
    * Note that for this resource there is some outdated information. The default password for the recommended RStudio Server Amazon Machine Image (AMI) options has been changed. See [Louis Aslett's website](https://blog.davisvaughan.com/2017/05/15/rstudio-shiny-aws-1/)
    
Once you are set up with an EC2 instance  running you'll want to fill in your own `data/ssh_info.csv` file. This needs to have two character columns, `ip` which is the Public IPv4 address of your EC2 instance and `filepath` which is the absolute filepath of your `.ppk` file. **When you reach this point you can use the repository as designed to run the bootstrapping in parallel.** (If this sounds unfamiliar and you are unsure how to connect to your Linux instance from Windows using PuTTY, follow [this tutorial](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)).

Now, running the project in paralllel allows the following files:

* Everything from *Section I. Sequential Approach*
* `src/analysis/02_data-cleaning.Rmd` - This is the preliminary step in the analysis.
* `src/analysis/05_run-bootstrap-parallel.Rmd` - This is where the parallel bootstrap is actually run.
* `src/analysis/06_make-summary-plots-and-table-parallel.Rmd` - This is where summary plots and a table are created.
* `src/analysis/07_timing-experiment.Rmd` - This is where timing between the sequential and parallel approaches is compared.  

`02...` only requires the `data/pcta.rds` data file.
`05...` relies on `02...` and on both `src/R/boostrap-functions.R` and `src/R/connect-to-ec2.R`
`06...` relies on `05...`.
In order to run `07...` all files in sequential and parallel sections, excluding `01...` must be run. 

In addition, all files ni 

`02...`, `03...`, and `04...` must be run in order as each depends on the one before it, starting with `02...` which requires the `data/pcta.rds` file.


### III. Miscellaneous

*  Tutorials and notes written during this project are located in `doc`
*  `data-raw` is distinguished from `data` as suggested by @cwickham as convention for dealing with an input file that is a `.R` file. Since data from PCTA had to be directly copied ("by hand") from an image. Additionally, this convention allows `devtools::load_all()` to run without error. 
* `results` contains all plots, tables, and data created, including those that were not used in the report. 
* `tests` contains a test of the functioning of the repository.
* `man` contains documentation on the function.
* `src/R` contains the functions for this repository.
     * `bootstrap-functions.R` includes three functions: 
          1. `get_bootstrap_prop_means()`is the original function and is used only by `src/analysis/01__initial-bootstrap-run.Rmd`
          2. `compare_get_bootstrap_prop_means()` replaces the first function in the sequential portion of the project, in order to give a "fair" comparison between the parallel and sequential approaches. This was necessary due to minor differences in the purrr and furrr package that were accentuated by the original use of the rsample package.
          3. `future_get_bootstrap_prop_means` matches the second function but uses furrr rather than purrr. 
     * `connect-to-ec2` does exactly what the name implies, it establishes a connection to Amazon EC2. It requires the ip address and ssh key (as seen in the *II. Parallel Approach* section) 
     
The following are required packages: tidyverse, here, rsample, ggpubr, magrittr, purrr, furrr, future, parallelly, magick