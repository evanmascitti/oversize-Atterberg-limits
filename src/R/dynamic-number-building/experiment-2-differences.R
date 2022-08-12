# computing the differnces between angular and 
# round sand 

library(magrittr)
output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

all_results <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/experiment-2-atterberg-limits-cleaned-data.rds'
) %>% 
  dplyr::select(
    coarse_name, coarse_pct, test_type, water_content
  ) %>% 
  dplyr::filter(test_type != "AL")

experiment_2_diffs <- all_results %>% 
  tidyr::pivot_wider(names_from = coarse_name,
                     values_from = water_content) %>% 
  dplyr::mutate(diff = abs(Granusil_4095 - Mancino_angular)) 

max_diff <- max(experiment_2_diffs$diff, na.rm = T)

largest_experiment_2_diff <- experiment_2_diffs %>% 
  dplyr::filter(dplyr::near(diff, max_diff)) %>% 
  purrr::pluck('diff')

largest_experiment_2_diff_pct_fmt <- sprintf(largest_experiment_2_diff * 100, fmt = "%.1f")

readr::write_rds(
  x = largest_experiment_2_diff_pct_fmt,
  file = output_file_path
)
