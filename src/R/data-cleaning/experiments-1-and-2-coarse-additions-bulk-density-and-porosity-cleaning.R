# this calculates total porosity, bulk density, etc. from
# the F1815 cylinders data 

library(purrr)
library(soiltestr)

# for now assume Gs of 2.65. Maybe test later to confirm but I feel 
# confident this sand is relatively pure quartz so not essential

# Also note that for the sands the data were collected in 2020, while for 
# the sil-co-sil material the data were collected in 2022. 

# I used a different file structure in 2022 as I was also doing this test 
# for materials in the sandClay1 experiment. Therefore the sil-co-sil-75 data
# actually have their own sub-directory and I wrangle these data separately below,
# before combining into a single table to output with GNU Make.

# used cylinder 1 for all data collection

empty_cylinder_w_rubber_band_and_cheesecloth_mass <- 107.50


Gs <- 2.65

f1815_max_density_data_2020 <- readr::read_csv(
  file = "./ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/experiment-1-dry-compaction-data.csv",
  col_types = readr::cols(tin_tare_set = readr::col_character()),
  na=  "-") %>% 
  # dplyr::left_join(asi468::tin_tares, by = c("tin_tare_set", "tin_number")  ) %>% 
  # add_w() %>% 
  dplyr::left_join(asi468::pvc_perc_cylinders, by = 'cylinder_ID') %>% 
  dplyr::mutate(
    soil_vol_cm3 = (ht_reading_corrected_mm/10) * area_cm2,
    OD_soil_only = (filled_wt - empty_cyl_mass) / (1 + 0.001), # assume soil was at water content of 0.1% gravimetric
    dry_density = OD_soil_only / soil_vol_cm3,
    total_porosity = 1 - (dry_density / .env$Gs ),
    test_type = "max_density",
  ) %>% 
  dplyr::select(
    expt_sand_number, sand_name, sand_size, test_type, 
    dry_density,
    total_porosity
  )


f1815_min_density_data_2020 <- "./ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/experiment-1-minimum-density-data.csv" %>% 
  readr::read_csv(
    col_types = readr::cols(
      tin_tare_set = readr::col_character()
    ),
    lazy = FALSE,
    na = "-"
  ) %>% 
  dplyr::left_join(asi468::pvc_perc_cylinders,
                   by = 'cylinder_ID') %>% 
  dplyr::mutate(
    soil_vol_cm3 = (ht_cm) * area_cm2,
    OD_soil_only = (filled_wt - .env$empty_cylinder_w_rubber_band_and_cheesecloth_mass) / (1 + 0.001),
    dry_density = OD_soil_only / soil_vol_cm3,
    total_porosity = 1 - (dry_density / .env$Gs ) ,
    test_type = 'min_density'
  ) %>% 
  dplyr::select(
    expt_sand_number, sand_name, sand_size, test_type, dry_density, total_porosity
  )

cleaned_data_2020 <- dplyr::bind_rows(
  f1815_max_density_data_2020, f1815_min_density_data_2020
)


  
# --------------  old data wrangling; code copied from sandClay1 project 
  




max_density_data_2022 <- "./ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/sil-co-sil-75/ASTM-F1815-sil-co-sil-75-max-density-data_2022-04-04.csv" %>% 
  readr::read_csv(
    col_types = readr::cols(
      tin_tare_set = readr::col_character()),
    lazy = FALSE
  ) %>%
  dplyr::mutate(
    height_cm_corrected = 2.54*(height_uncorrected  - 1.57),
    expt_sand_number = 6,
      sand_size = "0.05-0.002 mm",
      test_type  = "max_density") %>% 
  dplyr::left_join(asi468::tin_tares, by = c("tin_tare_set", "tin_number")) %>% 
  soiltestr::add_w()# technically there are particles outside this range but it is pretty clean )


# need to measure height for min density test from top of cylinder, then subtract
# based on cylinder dimensions

pvc_cylinder_height_cm <- unlist(asi468::pvc_perc_cylinders[asi468::pvc_perc_cylinders$cylinder_ID == 1L, 'ht_cm'])

pvc_diameter_cm <- unlist(asi468::pvc_perc_cylinders[asi468::pvc_perc_cylinders$cylinder_ID == 1L, 'diameter_cm'])

pvc_radius_cm <- pvc_diameter_cm / 2

min_density_data_2022 <- "./ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data/sil-co-sil-75/ASTM-F1815-sil-co-sil-75-min-density-data_2022-04-04.csv" %>% 
  readr::read_csv(
    col_types = readr::cols(
      tin_tare_set = readr::col_character()
    ),
    lazy = FALSE
  ) %>% dplyr::mutate(
    height_cm_corrected = pvc_cylinder_height_cm - depth_from_cylinder_rim_cm
  ) %>%
  dplyr::left_join(asi468::tin_tares, by = c('tin_number', 'tin_tare_set')) %>%
  soiltestr::add_w() %>% 
  dplyr::mutate(
    expt_sand_number = 6,
    sand_size = "0.05-0.002 mm",
    test_type  = "min_density")  # technically there are particles outside this range but it is pretty clean 

cleaned_data_2022 <- dplyr::bind_rows(max_density_data_2022, min_density_data_2022) %>% 
  dplyr::mutate(
    soil_volume = (pvc_radius_cm^2) * pi * height_cm_corrected,
    soil_only_mass = filled_mold_g  - empty_cylinder_w_rubber_band_and_cheesecloth_mass,
    OD_soil_only = soil_only_mass / (1 + water_content),
    dry_density = OD_soil_only / soil_volume,
    Gs = .env$Gs,
    total_porosity = 1 - (dry_density / Gs)) %>% 
  dplyr::rename(sand_name = sample_name) %>%
  dplyr::select(sand_name, sand_size, expt_sand_number, test_type, dry_density, total_porosity) 
  
  
  # -------------- end of silt data wrangling 
  

# leaving this alone for now. Probably not necessary. If desired, 
# fit a linear model and then use pooled standard deviation 
# to assess unvertainty. For now I am going to just use ggplot2 to 
# compute the mean and sd

fit_model <- function(x, variable){
  model <- lm(
    
  )
}

combined_years_f1815_data <- dplyr::bind_rows(
  cleaned_data_2020, cleaned_data_2022
)

summarized_f1815_data <- combined_years_f1815_data %>%
  # dplyr::mutate(
  #   test_type = dplyr::if_else(
  #     is.na(test_type), #  != 'max_density',
  #     "min_density",
  #     "max_density")) %>% 
  dplyr::group_by(expt_sand_number, test_type, sand_name, sand_size) %>% 
  dplyr::summarise(
    dplyr::across(
      .cols = c(dry_density, total_porosity),
      #.fns = ggplot2::mean_se
      .fns = list(mean = mean, sd_2 = ~ 2 * sd(.))
    ),
    .groups = 'drop'
  ) 



# write to disk 

if(!interactive()){
  
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  message("Building output file:\n",
          output_file_path,
          "\n",
          "- - - - - - - - - - - - - - - -")
  
  readr::write_rds(
    x = summarized_f1815_data,
    file = output_file_path
  )
  
  }
