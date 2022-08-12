# This is a helper script to generate the values referenced 
# in the materials and methods section of the paper 

suppressPackageStartupMessages({
  library(magrittr)
})

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]


all_expt_3_atterberg_limits <- readr::read_rds("./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds")

min_sand_pct <- min(all_expt_3_atterberg_limits$sand_pct)

uniformity_experiment_pure_clay_atterberg_lims <- all_expt_3_atterberg_limits %>% 
  dplyr::filter(sand_pct == min_sand_pct) %>% 
  tidyr::pivot_wider(names_from = 'test_type',
                     values_from = 'water_content') %>% 
  dplyr::select(date, LL, PL) %>% 
  dplyr::summarise(
    dplyr::across(.cols = c(LL, PL),
                  .fns = ~round(100 * mean(., na.rm = T), digits = 0))) %>% 
  dplyr::mutate(PI = LL - PL)

readr::write_rds(
  x = uniformity_experiment_pure_clay_atterberg_lims,
  file = output_file_path
)

