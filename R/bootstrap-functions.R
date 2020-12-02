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

compare_get_bootstrap_prop_means <- function(original_dat, ntimes = 1000){
  many_props <- map(1:ntimes,
                    ~sample(original_dat$prop,
                            length(original_dat$prop),
                            replace=TRUE),
                    .options = furrr_options(seed=TRUE))
  many_prop_means <- map_dbl(many_props,
                             ~mean(.x),
                             .options = furrr_options(seed=TRUE))
}

future_get_bootstrap_prop_means <- function(original_dat, ntimes = 1000){
  many_props <- future_map(1:ntimes,
                           ~sample(original_dat$prop, 
                                   length(original_dat$prop),
                                   replace=TRUE),
                           .options = furrr_options(seed=TRUE))
  many_prop_means <- future_map_dbl(many_props, 
                                    ~mean(.x),
                                    .options = furrr_options(seed=TRUE))
}