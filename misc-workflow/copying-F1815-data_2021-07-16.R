# this is a mesy script; need to manually  change some of the 
# file paths to re-use 

library(magrittr)

# # for the minimum density tests
# files <- openxlsx::read.xlsx("E:/onedrive-psu/PSU2019-present/A_inf_soils_PhD/data-lab/hobby_experiments/misc_sands_characterization_June_2020/misc_sands_minimum_density_data_2020-06-18.xlsx") %>%
# 
#   tibble::as_tibble() %>%
#   dplyr::mutate(experiment_number = dplyr::case_when(
#     stringr::str_detect(sand_name, "_Cu") ~ 3,
#     stringr::str_detect(sand_name, "Mancino") ~ 1,
#     stringr::str_detect(sand_name, "Granusil") ~ 2,
#   )) %>%
#   split(~experiment_number)
# 
# 
# 
# double_sand_mancino <- files$`1` %>%
#   dplyr::filter(sand_size == "1.0-0.5 mm")
# double_sand_granusil <- files$`2` %>%
#   dplyr::filter(sand_size == "1.0-0.5 mm")
# 
# files$`2` <- dplyr::bind_rows(double_sand_granusil, double_sand_mancino)
# 
# 
# 
#   # no good way to programatically build file paths since experimentss 1 and 2 resides in sand directory .
# 
# # build file paths here
# output_files <- c(
#   paste0('ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/',
#   'experiment-', 1:2, '-minimum-density-data.csv'),
#   'ecmdata/raw-data/uniformity-experiment/F1815-cylinders-data/uniformity-experiment-minimum-density-data.csv')
# 
# writing_args <- tibble::enframe(files, name = 'experiment_number',value = 'x') %>%
#   dplyr::transmute(file = output_files, x=x)
# 
# purrr::pwalk(writing_args, readr::write_csv, na = "-")





#------------------------


# For maximum density tests (dry condition)


# # for the minimum density tests 
# files <- openxlsx::read.xlsx("E:/onedrive-psu/PSU2019-present/A_inf_soils_PhD/data-lab/hobby_experiments/misc_sands_characterization_June_2020/misc_sands_dry_compaction_data_2020-07-13.xlsx") %>%
# 
#   tibble::as_tibble() %>%
#   dplyr::mutate(experiment_number = dplyr::case_when(
#     stringr::str_detect(sand_name, "_Cu") ~ 3,
#     stringr::str_detect(sand_name, "Mancino") ~ 1,
#     stringr::str_detect(sand_name, "Granusil") ~ 2,
#   )) %>%
#   split(~experiment_number)
# 
# 
# 
# double_sand_mancino <- files$`1` %>%
#   dplyr::filter(sand_size == "1.0-0.5 mm")
# double_sand_granusil <- files$`2` %>%
#   dplyr::filter(sand_size == "1.0-0.5 mm")
# 
# files$`2` <- dplyr::bind_rows(double_sand_granusil, double_sand_mancino)
# 
# 
# 
# # no good way to programatically build file paths since experimentss 1 and 2 resides in sand directory .
# 
# # build file paths here
# output_files <- c(
#   paste0('ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/',
#          'experiment-', 1:2, '-dry-compaction-data.csv'),
#   'ecmdata/raw-data/uniformity-experiment/F1815-cylinders-data/uniformity-experiment-dry-compaction-data.csv')
# 
# writing_args <- tibble::enframe(files, name = 'experiment_number',value = 'x') %>%
#   dplyr::transmute(file = output_files, x=x)
# 
# purrr::pwalk(writing_args, readr::write_csv, na = "-")
