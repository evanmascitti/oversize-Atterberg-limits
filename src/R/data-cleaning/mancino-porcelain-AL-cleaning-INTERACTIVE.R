library(magrittr)

# raw <- readr::read_csv(
#   'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/adhesion_limit_raw_data_mixes_11-15.csv'
# ) %>% 
#   soiltestr::add_w() %>% 
#   dplyr::rename(sample_name = expt_mix_num)
# 
# 
# raw %>% 
#   dplyr::group_by(sample_name) %>% 
#   dplyr::summarise(AL = mean(water_content, na.rm = TRUE))
#   
# raw %>% 
#   dplyr::filter(sample_name %in% c(10,12,13) || !sample_name & rep %in% c(4:6)) %>% 
#   dplyr::group_by(sample_name) %>% 
#   dplyr::summarise(AL = mean(water_content, na.rm = TRUE))
# 
# raw %>% 
#   dplyr::filter(rep <= 3, sample_name %in% c(11,14,15)) %>% 
#   dplyr::group_by(sample_name) %>% 
#   dplyr::summarise(AL = mean(water_content, na.rm = TRUE))
# 
# raw %>% 
#   dplyr::filter(rep > 3) %>% 
#   dplyr::group_by(sample_name) %>% 
#   dplyr::summarise(AL = mean(water_content, na.rm = TRUE))

# pretty sure that reps 4-6 are the ones to use for the 20 pct sand mixes.
# don't have any notes but why would  I have re-done them otherwise??

# Here I use only the results from reps 4-6, add the rest of the mixes, and 
# save as a new csv


all_others <- readr::read_csv(
  file = 'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/adhesion_limit_raw_data_all_other_mixes.csv',
  col_types = 'icidddc', na = c('NA', '', '-')
) %>% 
  dplyr::rename(sample_name = expt_mix_num)

mixes_11_to_15 <- readr::read_csv(
  'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/adhesion_limit_raw_data_mixes_11-15.csv',
  col_types = 'icidddc'
) %>% 
  dplyr::rename(sample_name = expt_mix_num)


# make a test for whether samples have extra reps

extra_reps_test <- mixes_11_to_15 %>% 
  dplyr::group_by(sample_name) %>% 
  tidyr::nest() %>% 
  dplyr::mutate(has_extra_reps = purrr::map_lgl(
    data, 
    ~length(.$rep) > 3
  ))

# apply the test and make a tibble for each case, then choose the appropriate reps
no_extra_reps <- extra_reps_test[!extra_reps_test$has_extra_reps, c('sample_name','data')] %>% 
  tidyr::unnest(data)

has_extra_reps <- extra_reps_test[extra_reps_test$has_extra_reps, c('sample_name','data')] %>% 
  tidyr::unnest(data) %>% 
  dplyr::filter(rep > 3)


# combine and write to disk

dplyr::bind_rows(all_others, no_extra_reps, has_extra_reps) %>% 
  readr::write_csv(
    'ecmdata/derived-data/mancino-intermediate-data/all-porcelain-AL-samples_2021-06-04.csv'
  )

