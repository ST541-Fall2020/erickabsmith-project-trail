#' run bootstrap and return list of bootstraps with their corresponding mean
#' 
#' @param original_dat A tibble or data frame with \code{prop} variable
#' @param ntimes A number
#' @return \code{ntimes} bootstrap resamples and means of \code{original_dat}
#' @examples
#' get_bootstrap_prop_means(original_dat = data.frame(x = rnorm(10), prop=rbeta(10,2,2)))
#' get_bootstrap_prop_means(original_dat = data.frame(x = rexp(5), prop= rbeta(5,1,1), names=letters(seq(from = 1, to=5)))

get_bootstrap_prop_means <- function(original_dat, ntimes = 1000){
  resamples <- rsample::bootstraps(original_dat, times=ntimes) %>%
    mutate(mean_prop_completed = map_dbl(splits, ~mean(as.data.frame(.)$prop)))
}