library(testthat)
library(erickabsmith-project-trail)

test_check("erickabsmith-project-trail")

test_that("correct number of resamples",
          expect_length(
            compare_get_bootstrap_prop_means(
              original_dat = c(1,2,3,4,5), 
              ntimes=100),
            100))