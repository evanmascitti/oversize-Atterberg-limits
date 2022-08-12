library(tidyverse)
# The data for porcelain mixes 31-36 imported from the
# old location don't have tin numbers. 
# I had not yet made a set and named with the date,
# but there is are 4 files in that old location
# containing tin tares. 

# I did a check to see what the differences are among them,
# and there is actually no difference at all for tin numbers < 50,
# which all of the samples mentioned above qualify for. 

# I also checked these against the asi468::tin_tares 
# object, and they are the same as the May 24, 2020 set. 
# So rather than having to copy yet another old excel file 
# I am going to just use the asi468 data object

# I will save this file in the raw data directory even though I have changed this....it is still truly raw data and belongs 
# with the corresponding files.

# I still saved this script so there is a record of how the file 
# was created from the original version, which remains in the old 
# location (i.e. data-lab/Mancino_porcelain/etc)

mixes_31_to_36_AL_data <- readr::read_csv(
  '../../A_inf_soils_PhD/data-lab/Mancino_porcelain/data/compiled_raw_data_for_sharing/adhesion_limit_raw_data_mixes_31-36.csv'
)

cleaned <- mixes_31_to_36_AL_data %>% 
  dplyr::mutate(across(matches('tin_w_.*_sample'),
                       parse_number)
  ) %>% 
  left_join(asi468::tin_tares$`2020-05-24`) %>% 
  select(expt_mix_num,
         test_type,
         rep,
         tin_w_wet_sample,
         tin_w_OD_sample, 
         tin_tare,
         comments
         )

readr::write_csv(
  cleaned,
  'ecmdata/raw-data/imported-from-old-directories/Mancino-porcelain/compiled_raw_data_for_sharing/adhesion_limit_raw_data_mixes_31-36.csv'
)
                
