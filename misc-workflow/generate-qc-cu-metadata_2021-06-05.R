# This experiment is designed to shed light on how particle packing affects the liquid and plastic limits of sand-clay mixtures. 
# I have generated two sands from the same source material via washing, sieving, and re-blending. This produced two sands having nearly identical D~50~ values but very different grading curves, and therefore different values of the coefficient of uniformity (hereafter referred to as Cu).
# 
# The first step is to generate a table of mix masses, accounting for the mass of sand-size particles in the "clay" component and the <53 &mu;m particles in the "sand" component. Additionally, the water contents of both components must be accounted for if precise mixtures are to be made on an oven-dry basis while using air-dry masses to actually make the mixes. 
# 
# This script creates a table which has all the mixture metadata and randomizes 
# the order in which the samples are to be tested, to help eliminate any 
# possible systematic bias in the testing.

# The metadata is written to disk; it will be later joined with
# results during data analysis.
# 
# Originally this was done with an R Markdown document which was alot longer
# and had some other outputs, such as a formatted
# Excel file....when I started this project I had not yet adopted some of 
# the habits I now use. I copied out the relevant code and stuck it here.

# Now I would use the mix_calcs() function in soiltestr rather than 
# this long tibble construction which is mostly duplicated code, but 
# it does work and I need to leave it this way because of the random
# number generation that is used. 

# The mixes are already made and tested so there is no need to ever re-run this # script once the metadata is saved. 


suppressPackageStartupMessages({
  library(tidyverse)
})


# Enter some constants for the % by mass >53 um (i.e. sand + gravel) in each component , measured from a PSA.
# Also calculate and enter as the air-dry water content of each component. Finally, enter the desired final oven-dry mass of the mixture.
# For Atterberg limit tests, this is 150 g. 


# Enter these values manually; there are only two water contents and the particle size data are elsewhwere. For this experiment I am going 
# to assume the Casselman clay (about equal parts upper and lower red clay strata) has 6.6% sand in it, which was determined on July 20. If I get the ultrasonicator probe I will re-do the PSA on the "pure" clay and perhaps re-evaulate the mix masses, because the PSD curves for the mixes can be easily re-calculated from the known distribution of the sand sizes and the % of each component by OD mass.
# When I did an actual particle size analysis on the two sands (see June 2020 misc sands characterization files), the high Cu sand was 0.7% passing the #270 sieve and the low Cu sand was 0.5% passing the #270.
# So I am going to just take the average and say both sands are 99.4% sand.

mix_date <- "2020-09-04"
sand_sand_pct <- 0.994
fines_sand_pct <- 0.066
sand_w <- 0.001
fines_w <- 0.026820
g_mix_needed <- 150


# Now make a tibble containing all the desired information. You need to enter the desired sand percentage for each mix as a decimal, 
#listed in a character vector. The column "test sequence" is a randomly generated sequence to ensure there is no
#  systematic bias induced by testing mixes with steadily increasing sand %. 

# set the random number generator so that if I re-run the code the test sequence will not change. 
set.seed(1)
mix_calcs_low_Cu <- tibble(
  sand_pct = c(0.066, 0.1, 0.15, 
               0.2, 0.25, 0.3, 0.35,
               0.4, 0.45, 0.5, 0.55, 
               0.575, 0.6, 0.625, 0.65, 
               0.675, 0.7, 0.725, 0.75, 
               0.775, 0.8),
  expt_mix_num = c(sample(seq(from=1, to= length(sand_pct), by=1), size =  length(sand_pct))) , 
  mix_date= mix_date,
  final_OD_wt = g_mix_needed,
  sand_name = 'low_Cu_Quickcrete',
  fines_name = 'Casselman_red_clay')


# re-set the random number generator so the mix orders will differ for the high Cu sand but are still repeatably generable. 
set.seed(2)
mix_calcs_high_Cu <- tibble(
  sand_pct = c(0.066, 0.1, 0.15, 
               0.2, 0.25, 0.3, 0.35,
               0.4, 0.45, 0.5, 0.55, 
               0.575, 0.6, 0.625, 0.65, 
               0.675, 0.7, 0.725, 0.75, 
               0.775, 0.8),
  expt_mix_num = c(sample(seq(from=22, to= (21+length(sand_pct)), by=1), size =  length(sand_pct))) , 
  mix_date= mix_date,
  final_OD_wt = g_mix_needed,
  sand_name = 'high_Cu_Quickcrete',
  fines_name = 'Casselman_red_clay')
  

# combine the two tibbles and select only the relevant columns 

mix_calcs <- rbind(mix_calcs_low_Cu, mix_calcs_high_Cu) %>%
  dplyr::rename(sample_name = expt_mix_num,
                coarse_pct = sand_pct) %>% 
  arrange(sample_name) %>% 
  dplyr::select(sample_name, sand_name, coarse_pct)



#write the table to disk so I can print / reference it later:
mix_calcs %>%
  readr::write_csv(
    file = 'ecmdata/metadata/experiments-1-and-2-mixtures-metadata.csv')
