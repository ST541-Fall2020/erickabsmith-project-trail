get_bootstrap_prop_means <- function(original_dat, ntimes = 1000){
  resamples <- rsample::bootstraps(original_dat, times=ntimes) %>%
    mutate(mean_prop_completed = map_dbl(splits, ~mean(as.data.frame(.)$prop)))
}
