# This is to check that the tin numbers for any date are the same
# I didn't always specify which set were used, so I am going to
# assume that the set used corresponds to the most recently added new 
# file containing tin tares prior to a given test date.

# This script checks what the differences are for the tin tares 
# over different files. 

# I am pretty sure they are exactly the same except that more 
# tins are progressively added. 



library(tidyverse)

tables <- list.files(path = '../../A_inf_soils_PhD/data-lab/Mancino_porcelain/',
           pattern = 'water_content_tin_tare',
           full.names = T) %>% 
  set_names(str_extract(., "\\d{4}-\\d{2}-\\d{2}")) %>% 
  map(readxl::read_excel)

names <- (tables)  


less_than_50 <- tables %>% 
  map(dplyr::filter, tin_number < 50) %>% 
  unname()

# I tried using identical which was not working the way I would 
# have expected.....this seems to confirm they are all the same
# for the lower-numbered tins

all_equal_tin_tares <- purrr::reduce(less_than_50, left_join)


# try comparing to the asi468 data object 

asi468::tin_tares$`2020-05-24` %>% 
  dplyr::select(-tin_tare_set) %>% 
  dplyr::filter(tin_number < 50) %>% 
  dplyr::left_join(all_equal_tin_tares)

# yep, they're the same ! 
