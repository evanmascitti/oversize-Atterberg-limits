# This script simply subsets the already-cleaned data into that for 
# a single experiment. It is identical for experiments 1 and 2 except 
# for the subset which it chooses. 

library(magrittr)

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

expt_1_data <- readr::read_rds(file = 'ecmdata/derived-data/cleaned-rds-files/both-experiments-1-and-2-atterberg-limits-cleaned-data.rds') %>% 
  dplyr::filter(coarse_name != 'Granusil_4095')

readr::write_rds(expt_1_data, output_file_path)

