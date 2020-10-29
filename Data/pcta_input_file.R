pcta <- data.frame(
  year <- seq(2013, 2019, by=1),
  total <- c(7888,7313,6069,5657,4453,2655,1879),
  northbound <- c(4748,4500,3490,3159,2486,1367,988),
  southbound <- c(693,491,438,334,322,94,53),
  sectionhike <- c(2437,2304,2132,2151,1633,1179,834),
  thruride <- c(6,6,6,5,4,7,1),
  sectionride <- c(4,12,3,8,8,8,3),
  completions <- c(276,495,666,759,539,1179,953),
  horsecompletions <- c(1,0,0,0,0,0,0)
)
write.csv(pcta, "Data/pcta.csv")
