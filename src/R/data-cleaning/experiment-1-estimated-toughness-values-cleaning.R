# This script compiles the estimated toughness values for various coarse addition
# contents and sizes

library(magrittr)


# perform calculation 

experiment_1_estimated_toughness_values <- readr::read_rds(
  "ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds" 
) %>% 
  #dplyr::filter(coarse_pct <= 0.7) %>% 
  dplyr::select(coarse_name, coarse_size, coarse_pct, test_type, water_content) %>% 
  dplyr::distinct() %>% 
  tidyr::pivot_wider(
    names_from = test_type, 
    values_from = water_content
  ) %>% 
  dplyr::mutate(PI = LL- PL) %>% 
  ecmfuns::add_mormar_toughness_est() %>% 
  dplyr::rename(t_max = mormar_toughness_est) %>% 
  dplyr::filter(coarse_pct < 0.8) %>% 
  dplyr::select(coarse_name, coarse_size, coarse_pct, t_max)




# write to disk 

if(!interactive()){
  
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  readr::write_rds(
    x = experiment_1_estimated_toughness_values,
    file = output_file_path)
  
  
}





