# In this script I make a plot of the particle size distribution of 
# the silt I used for the Mancino mixes, then save it as a csv file in the
# raw data directory.

# That file is pulled in by a data cleaning script `./src/R/data-cleaning/experiment-1-coarse-particles-d50-cleaning.R`.

# The sand-size D50 values were chosen graphically in summer 2020.
library(soiltestr)

silt_psas <- soiltestr::psa(
  dir = './ecmdata/raw-data/experiment-1/silt-mixtures/psa-data_2021-01-16/',
  tin_tares = dplyr::bind_rows(asi468::tin_tares),
  beaker_tares = dplyr::bind_rows(asi468::psa_beaker_tares)
)

silt_psas$cumulative_percent_passing %>% 
  dplyr::filter(stringr::str_detect(sample_name, 'Flint.*52')) %>% 
  soiltestr::ggpsd()+
  ggplot2::geom_hline(yintercept = 0.5)+
  ggplot2::geom_vline(xintercept = 25)

# looks like the D50 is 25 microns or 0.025 mm

output_tibble <- tibble::tibble(
  expt_sand_number = 6,
  d50 = 0.025
)

# write the file 
readr::write_csv(output_tibble, file = './ecmdata/raw-data/experiment-1/experiment-1-silt-size-graphically-determined-D50-values.csv')
