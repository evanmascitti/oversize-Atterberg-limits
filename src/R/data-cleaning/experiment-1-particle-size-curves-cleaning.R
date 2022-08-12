# this generates a cleaned data file containing 
# percent passing for all the samples in experiments 1 and 2. 


if(!interactive()){
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  cat("Building file:", output_file_path, sep = "\n")
  }


suppressPackageStartupMessages({
  library(soiltestr)
  library(purrr)
})

# set options for soiltestr::psa
options(
  soiltestr.tin_tares = asi468::tin_tares,
  soiltestr.beaker_tares = asi468::psa_beaker_tares
)


# read raw data for sands; % passing was 
# already compute in another script 
# somewhere else, before I knew how to structure
# projects at my current skill level...
# it is only ancillary data and therefore I don't 
# feel compelled to track down the absolute raw data

experiment_1_sands <- readr::read_csv(
  file = './ecmdata/raw-data/experiments-1-and-2/experiment-1-sands-pct-passing.csv',
  col_types = 'idd',
  skip_empty_rows = TRUE,
  na='-'
) %>% 
  dplyr::rename(percent_passing = pct_passing)


# compute % passing for silt sample 
experiment_1_silt <- soiltestr::psa('./ecmdata/raw-data/experiments-1-and-2/silt-mixtures/psa-data_2021-01-16/') %>% 
  purrr::pluck("cumulative_percent_passing") %>% 
  dplyr::filter(sample_name == "Flint 325 Sil-co-sil 52") %>% 
  dplyr::mutate(expt_sand_number = 6) %>% 
  dplyr::select(expt_sand_number,
                microns, 
                percent_passing)


# psa for clay sample 


experiment_1_porcelain_psa <- psa(dir = "./ecmdata/raw-data/experiments-1-and-2/psa-data_2021-03-06/") 

experiment_1_porcelain_pct_passing <- experiment_1_porcelain_psa$averages$cumulative_percent_passing %>% 
  dplyr::mutate(unique_sample_ID = 'fireborn-porcelain') %>% 
  dplyr::select(unique_sample_ID, microns, percent_passing)


# bind together 
experiment_1_coarse_samples_pct_passing <- 
  dplyr::bind_rows(experiment_1_sands, experiment_1_silt) %>% 
  dplyr::mutate(unique_sample_ID = as.character(expt_sand_number))

experiment_1_samples_percent_passing <- dplyr::bind_rows(experiment_1_porcelain_pct_passing, experiment_1_coarse_samples_pct_passing) %>% 
  dplyr::select(unique_sample_ID, dplyr::everything())

# write to disk 
readr::write_rds(
  x = experiment_1_samples_percent_passing,
  file = output_file_path
)

