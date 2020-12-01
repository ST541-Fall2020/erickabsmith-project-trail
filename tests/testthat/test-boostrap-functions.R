test_that("boostrap works", {
  expect_equal(
    {set.seed(721)
      original_dat = data.frame(x = rnorm(10), prop=rbeta(10,2,2))
      }, 
    {set.seed(721)
      original_dat = data.frame(x = rnorm(10), prop=rbeta(10,2,2))
      }
    )
})
