# This is a helper script to generate the values referenced 
# in the materials and methods section of the paper 

suppressPackageStartupMessages({
  library(magrittr)
})

all_atterberg_limits <- readr::read_rds("./ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds")

min_sand_pct <- min(all_atterberg_limits$coarse_pct)

shape_experiment_pure_clay_atterberg_limit_values <- all_atterberg_limits %>% 
  dplyr::filter(coarse_pct == min_sand_pct) %>% 
  tidyr::pivot_wider(names_from = 'test_type',
                     values_from = 'water_content') %>% 
  dplyr::select(test_date, LL, PL) %>% 
  dplyr::summarise(
    dplyr::across(.cols = c(LL, PL),
                  .fns = ~round(100 * mean(., na.rm = T), digits = 0))) %>% 
  dplyr::mutate(PI = LL - PL)


if(!interactive()){
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  readr::write_rds(
    x = shape_experiment_pure_clay_atterberg_limit_values,
    file = output_file_path)
    
} else{
  message("Nothing written to disk; use Make to build .rds file.")
  print(shape_experiment_pure_clay_atterberg_lims)
    }

