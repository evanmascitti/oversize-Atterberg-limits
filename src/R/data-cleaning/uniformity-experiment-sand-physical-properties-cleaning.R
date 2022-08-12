# compute porosity and void ratio of the sands on their own 

# setup
library(purrr)
source("./src/R/helpers/oversizeALims-utils.R")


# for air-dry sand, assume water content of 0.1% i.e. 0.001

data_path <- here::here('ecmdata/raw-data/uniformity-experiment/F1815-cylinders-data')

raw_compaction_data <-  list.files(
  path = data_path,
  pattern = 'uniformity-experiment.*\\.csv$',
  full.names = TRUE) %>%
  purrr::map(readr::read_csv, na = "-",
             col_types = 'icciiccicdddiddi') %>% 
  dplyr::bind_rows() %>% 
  dplyr::select(-experiment_number)


# the calculation has to be done differently because 
# for the max density test, the height of the soil column 
# is not the same as that of the cylinder, but it is for the 
# min density test 

max_density_results <- raw_compaction_data %>% 
  dplyr::filter(sand_configuration == 'dense') %>% 
  dplyr::left_join(asi468::pvc_perc_cylinders, by = 'cylinder_ID') %>% 
  dplyr::mutate(OD_sand_only = (filled_wt - empty_cyl_mass) / (1 + 0.001),
                dry_density = OD_sand_only / (ht_reading_corrected_mm / 10 * area_cm2)) %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::mutate(porosity = 1 - (dry_density / 2.65))



min_density_results <- raw_compaction_data %>% 
  dplyr::filter(sand_configuration == 'loose') %>% 
  dplyr::left_join(asi468::pvc_perc_cylinders, by = 'cylinder_ID') %>% 
  dplyr::mutate(OD_sand_only = (filled_wt - empty_cyl_mass) / (1 + 0.001),
                dry_density = OD_sand_only / (ht_cm * area_cm2)) %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::mutate(porosity = 1 - (dry_density / 2.65))


all_results <- dplyr::bind_rows(
  max_density_results, min_density_results
)

uniformity_experiment_sand_physical_properties <- all_results %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::summarize(
    dplyr::across(
      .cols = c(dry_density, porosity),
      .fns = mean) ,
    .groups = 'drop') %>% 
  dplyr::mutate(
    void_ratio = porosity / (1 - porosity)
  )


# write to disk

if(!interactive()){
  
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  message("Building file: \n",
          output_file_path,
          "\n - - - - - - - - - - - - - - -")
  readr::write_rds(
    x = uniformity_experiment_sand_physical_properties,
    file = output_file_path)
  
}else{
  message("Nothing written to disk, must re-run `Make`")
  print(uniformity_experiment_sand_physical_properties)
}

