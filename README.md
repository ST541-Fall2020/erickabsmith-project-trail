
## Bootstrapping the Pacific Crest Trail in Parallel

Ericka B. Smith

This project investigates the chance of successfully completing the Pacific Crest Trail. Data was gathered from the [Pacific Crest Trail Association](https://www.pcta.org/our-work/trail-and-land-management/pct-visitor-use-statistics/) and used to create an estimate of the mean proportion of thru-hikers who finish the trail each year.

In order to estimate this mean bootstrapping was done by using the furrr package (future and purrr) and the socket method of parallelization to create a cluster with Amazon Web Services Elastic Compute Cloud (EC2).

Find my presentation slides [here.](https://github.com/ST541-Fall2020/erickabsmith-project-trail/blob/master/doc/presentation-slides.pdf)