# This script wrangles all the data from the mixes made with 
# Mancino sand, quartz silt, round sand, and the Fireborn porcelain clay

# It outputs an rds file containing the data for both for experiment 1 (sand/silt size) and experiment 2 (sand angularity)

# Subsequent scripts subset this by experiment....it's not the most concise way,
# but it is very modular and explicit, and requires changes to be made 
# only where requried. 


# most of this is not very-elegant (a lot of _almost_ duplicated code and names) but I was just learning R when I collected 
# most of the data, and the organization of the sheets and naming scheme is 
# not very consistent. 
# Therefore I will just do these operations individually 
# and then combine them, putting the data in a nice tidy tibble 

# For the silt-size mixes, I can use the functions in soiltestr because 
# they are built for batch analysis.
# For the sand-size mixes, I have to use a more traditional group_by, nest, map
# approach


library(magrittr)

# set tin tares variable 
options(soiltestr.tin_tares = asi468::tin_tares)

# read metadata -----------------------------------------------------------

metadata <- readr::read_csv(
  './ecmdata/metadata/experiments-1-and-2-mixtures-metadata.csv',
  col_types = 'iccddcDD'
  ) %>%
  dplyr::mutate(sample_name = as.integer(sample_name))

# read LL data for sand-size mixes and calculate LL----------------------------

sand_size_LL_data <- readr::read_csv(
  file = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/liquid_limit_raw_data.csv',
  col_types = 'icidddc', na = ''
)

sand_size_LL_values <- sand_size_LL_data %>%
  dplyr::rename(sample_name = expt_mix_num) %>% 
  soiltestr::add_w() %>%
  dplyr::group_by(sample_name) %>%
  tidyr::nest() %>%
  dplyr::mutate(LL = purrr::map_dbl(data, soiltestr::compute_LL)) %>%
  dplyr::select(sample_name, LL) %>% 
  dplyr::arrange(sample_name)




# do the same for silt-size mixes -----------------------------------------

# create a case for the no-silt added mix, number 49, then add it at the end

# don't really need to do all the extra changes because they are 
# just selected off, but doing anyway for extra safety
silt_size_pure_clay_LL_value <- sand_size_LL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'sil-co-sil crushed qz',
                coarse_size_max_particle_size = '<0.05',
                sample_name = 49L) %>% 
  dplyr::select(sample_name, LL)



silt_size_LL_values <-  soiltestr::LL_batch_analysis(dir = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/silt_mixes/atterberg_limits_2021-02-09/') %>% 
  purrr::pluck('LL_results') %>% 
  dplyr::select(sample_name, water_content ) %>% 
  dplyr::mutate(sample_name = as.integer(
    stringr::str_remove(
      string = as.character(sample_name), pattern = "mix_") )) %>% 
  dplyr::rename(LL = water_content) %>% 
  dplyr::bind_rows(silt_size_pure_clay_LL_value)


# bind the LL data sets together (after filtering for the correct sand values)

mancino_sand_mixes_LL_values <- sand_size_LL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(stringr::str_detect(coarse_name, 'Mancino')) %>% 
  dplyr::select(sample_name, LL)

all_expt_1_LL_values <- dplyr::bind_rows(
  mancino_sand_mixes_LL_values,
  silt_size_LL_values)

# copy the values for the pure clay so there is a single 
# matching row for 0% sand but for the rounded sand 

round_sand_pure_clay_LL_values <- sand_size_LL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'Granusil_4095',
                sample_name = 42L)

all_expt_2_LL_values <- sand_size_LL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(coarse_size == '1.0-0.5') %>% 
  dplyr::bind_rows(round_sand_pure_clay_LL_values) %>% 
  dplyr::select(sample_name, LL)

#-----------------------------------------------------------------------------


# plastic limit data wrangling --------------------------------------------

# sand size mixes
sand_size_PL_data <- readr::read_csv(
  file = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/plastic_limit_raw_data.csv',
  col_types = 'icidddc', na = c('NA', '', '-')
) %>% 
  dplyr::rename(sample_name = expt_mix_num)

sand_size_PL_values <- sand_size_PL_data %>% 
  soiltestr::add_w() %>% 
  dplyr::group_by(sample_name) %>% 
  dplyr::summarise(PL = mean(water_content, na.rm = TRUE))

# silt size mixes 
# create a case for the no-silt added mix, number 49, then add it at the end

# don't really need to do all the extra changes because they are 
# just selected off, but doing anyway for extra safety
silt_size_pure_clay_PL_value <- sand_size_PL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'sil-co-sil crushed qz',
                coarse_size_max_particle_size = '<0.05',
                sample_name = 49L) %>% 
  dplyr::select(sample_name, PL)

silt_size_PL_values <- soiltestr::PL_batch_analysis(
  dir = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/silt_mixes/atterberg_limits_2021-02-09/') %>% 
  purrr::pluck("PL_avg_values") %>% 
  dplyr::select(sample_name, water_content) %>% 
  dplyr::mutate(
    sample_name = as.integer(
      stringr::str_remove(
        as.character(sample_name), "mix_"))) %>% 
  dplyr::rename(PL = water_content) %>% 
  dplyr::bind_rows(silt_size_pure_clay_PL_value)



# again filter as above, making two tibbles: one for expt 1 and 
# one for expt 2

mancino_sand_mixes_PL_values <- sand_size_PL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(coarse_name == "Mancino_angular") %>% 
  dplyr::select(sample_name, PL)

all_expt_1_PL_values <- dplyr::bind_rows(
  mancino_sand_mixes_PL_values,
  silt_size_PL_values
)

# for experiment 2
round_sand_pure_clay_PL_values <- sand_size_PL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'Granusil_4095',
                sample_name = 42L)

all_expt_2_PL_values <- sand_size_PL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(coarse_size == '1.0-0.5') %>% 
  dplyr::bind_rows(round_sand_pure_clay_PL_values) %>% 
  dplyr::select(sample_name, PL)

#-------------------------------------------------------------

# adhesion limits -------------------------------------

# sand size mixes
# for experiment 1, apparently the round sand AL data 
# were kept in a different file. So were the data 
# from mixes 11-16. Need to combine here 

sand_size_AL_data <- list.files(
  path = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/',
  pattern = 'adhesion_limit', full.names = T) %>% 
  purrr::map(readr::read_csv, col_types = 'icicccc', na = c('NA', '', '-')) %>% 
  dplyr::bind_rows() %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::contains('tin'),
                              .fns = readr::parse_number)) %>% 
  dplyr::rename(sample_name = expt_mix_num)

sand_size_AL_values <- sand_size_AL_data %>% 
  soiltestr::add_w() %>% 
  dplyr::group_by(sample_name) %>% 
  dplyr::summarise(AL = mean(water_content, na.rm = TRUE))

# silt size mixes 

# create a case for the no-silt added mix, number 49, then add it at the end

# don't really need to do all the extra changes because they are 
# just selected off, but doing anyway for extra safety
silt_size_pure_clay_AL_value <- sand_size_AL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'sil-co-sil crushed qz',
                coarse_size_max_particle_size = '<0.05',
                sample_name = 49L) %>% 
  dplyr::select(sample_name, AL)

silt_size_AL_values <- soiltestr::AL_batch_analysis(
  dir = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/silt_mixes/atterberg_limits_2021-02-09/') %>% 
  purrr::pluck("AL_avg_values") %>% 
  dplyr::select(sample_name, water_content) %>% 
  dplyr::mutate(
    sample_name = as.integer(
      stringr::str_remove(
        as.character(sample_name), "mix_"))) %>% 
  dplyr::rename(AL = water_content) %>% 
  dplyr::bind_rows(silt_size_pure_clay_AL_value)

# combine as for LL and PL


mancino_sand_mixes_AL_values <- sand_size_AL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(coarse_name == "Mancino_angular") %>% 
  dplyr::select(sample_name, AL)

all_expt_1_AL_values <- dplyr::bind_rows(
  mancino_sand_mixes_AL_values,
  silt_size_AL_values
)


# for experiment 2
round_sand_pure_clay_AL_values <- sand_size_AL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(dplyr::near(coarse_pct, 0),
                coarse_size == '1.0-0.5') %>% 
  dplyr::mutate(coarse_name = 'Granusil_4095',
                sample_name = 42L)

all_expt_2_AL_values <- sand_size_AL_values %>% 
  dplyr::left_join(metadata, by = 'sample_name') %>% 
  dplyr::filter(coarse_size == '1.0-0.5') %>% 
  dplyr::bind_rows(round_sand_pure_clay_AL_values) %>% 
  dplyr::select(sample_name, AL)







# combine all three limits into one tibble for experiment 1 (sand/silt size)
# and another for experiment 2 (sand angularity) ----------------------

# check the sample_name vectors to be sure they are identical


check_1 <- all(mget(ls(pattern = "all_expt_1_[APL]L_values")) %>% 
                 purrr::map("sample_name") %>% 
                 purrr::map_lgl(., identical, .[[1]]))

check_2 <- all(mget(ls(pattern = "all_expt_2_[APL]L_values")) %>% 
                 purrr::map("sample_name") %>% 
                 purrr::map_lgl(., identical, .[[1]]))

if(!all(check_1, check_2)){stop("not all sample_name entries are the same")}


# use reduce to join the data and then pivot it to long format

# write a quick helper function for this task; it can be used 
# for both experiments 

combine_att_lims <- function(experiment){
  
  experiment <- as.character(experiment)
  
  #  browser()
  
  dfs <- ls(pattern = glue::glue("all_expt_{experiment}_[APL]L_values"), 
            envir = rlang::caller_env())
  
  
  combined_att_lims <- dfs %>% 
    mget(envir = rlang::caller_env()) %>% 
    purrr::reduce(dplyr::left_join, by = 'sample_name', ) %>% 
    tidyr::pivot_longer(dplyr::matches("^[APL]L$"),
                        names_to = 'test_type',
                        values_to = 'water_content')
  
  return(combined_att_lims)
  
}

# the function to combine all the limits 
# won't work with map because of some kind of lexical scoping problem
# just call the function twice 


expt1_data <- combine_att_lims(1) %>% 
  dplyr::left_join(metadata, by = 'sample_name') 
# %>% 
#   dplyr::mutate(experiment_name = 'oversizeAttLims_experiment-1') %>% 
#   dplyr::relocate(experiment_name, .before = dplyr::everything())

expt2_data <- combine_att_lims(2) %>% 
  dplyr::left_join(metadata, by = 'sample_name') 
# %>% 
#   dplyr::mutate(experiment_name = 'oversizeAttLims_experiment-2') %>% 
#   dplyr::relocate(experiment_name, .before = dplyr::everything())

# combine the data frames and add a column that has the predicted water content for each  mixture based on the linear law 

combined_expts_df <- dplyr::bind_rows(expt1_data, expt2_data)

# create tibble of what the values _should_ be based on the linear law of mixtures 

clay_only_mixtures <- combined_expts_df %>% 
  dplyr::filter(coarse_pct == 0)

clay_only_AL <- unique(clay_only_mixtures[clay_only_mixtures$test_type == "AL", ]$water_content)

clay_only_LL <- unique(clay_only_mixtures[clay_only_mixtures$test_type ==  "LL", ]$water_content)

clay_only_PL <- unique(clay_only_mixtures[clay_only_mixtures$test_type == "PL", ]$water_content)

clay_only_PI <- clay_only_LL - clay_only_PL

clay_only_water_contents <- tibble::tibble(
  test_type = c("LL", "PL", "AL", "PI"),
  clay_only_water_content = c(clay_only_LL, clay_only_PL, clay_only_AL, clay_only_PI)
)

# combined_expts_w_predicted_water_contents <- combined_expts_df %>% 
#   dplyr::left_join(clay_only_water_contents,
#                    by = 'test_type') %>% 
#   dplyr::mutate(
#     predicted_water_content = dplyr::case_when(
#       is.na(water_content) ~ NA_real_,
#       is.nan(water_content) ~ NA_real_,
#       TRUE ~ clay_only_water_content * (1 - coarse_pct)),
#     linear_law_deviation = water_content - predicted_water_content
#     )

# join with metadata about the sands 

# read other metadata about the sands 
d_50_values <- readr::read_rds(
  './ecmdata/derived-data/dynamic-number-references/experiment-1-dx-values.rds'
)

sand_metadata <- readr::read_csv(
  './ecmdata/metadata/experiment-1-expt_sand_numbers-metadata.csv',
  col_types = 'icc'
) %>% 
  dplyr::mutate(coarse_size  = paste0(upper_mm, "-", lower_mm))



# data frame for LL, AL, and PL 



everything_besides_PI_values <- combined_expts_df %>% 
  dplyr::left_join(sand_metadata, by = "coarse_size") %>% 
  dplyr::left_join(d_50_values, by = "expt_sand_number") %>% 
  dplyr::distinct()



# compute PI with pivoting and then return to tidy format

output_tibble <- everything_besides_PI_values %>% 
  tidyr::pivot_wider(names_from = test_type, values_from = water_content) %>% 
  dplyr::mutate(PI = LL - PL) %>% 
  tidyr::pivot_longer(
    cols = c("AL", "PL", "LL", "PI"),
    names_to = 'test_type',
    values_to = 'water_content'
  ) %>% 
    dplyr::left_join(
      clay_only_water_contents,
      by = 'test_type') %>% 
    dplyr::mutate(
      predicted_water_content = dplyr::case_when(
        is.na(water_content) ~ NA_real_,
        is.nan(water_content) ~ NA_real_,
        TRUE ~ clay_only_water_content * (1 - coarse_pct)),
      linear_law_deviation = water_content - predicted_water_content
    ) %>% 
  dplyr::arrange(sample_name, coarse_pct, coarse_size, test_type) 



# output_tibble <- combined_expts_w_predicted_water_contents %>%
#   dplyr::select(
#     sample_name, coarse_name, upper_mm, lower_mm, d50, coarse_size, coarse_pct, 
#                 test_type, water_content) %>%
#  dplyr::arrange(sample_name, coarse_pct, coarse_size, test_type) 


# write to disk 
if(!interactive()){

  # get output file from Make 
  
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  cat("---------------------------------", 
      "Generating file:", output_file_path, 
      "---------------------------------",
      sep = "\n\n")
  
  
  readr::write_rds(
  output_tibble, 
  output_file_path
  )
} else{
  print(output_tibble)
}
