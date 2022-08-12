list.files(path = '../../A_inf_soils_PhD/data-lab/Qc_Cu_Casselman/data/raw_data/',
           pattern = 'atterberg[-_]limits', full.names = T) %>% 
  purrr::map(fs::dir_copy, new_path = './ecmdata/raw-data/imported-from-old-directories/Qc-Cu-Casselman/')

# copy all other files; this will include copies of the data which I already
# copied above; I will only use those raw data files but I also need to grab
# the metadata, etc. and this feels like the safest way rather than trying 
# to pick out the individual files I need right now...if I later discover 
# that something else is needed, it might be harder to find. 


# I couldn't get the code below to work so I just did this 
# with windows file explorer.

# The only files I didn't copy were the Rproj and git files.

# # directories first
# list.files(path = '../../A_inf_soils_PhD/data-lab/Qc_Cu_Casselman/', full.names = T) %>% 
#   .[fs::is_dir(.)] %>% 
#   purrr::map(., ~fs::dir_copy(
#     path = ., 
#     new_path = 'ecmdata/raw-data/imported-from-old-directories/Qc-Cu-Casselman/all-copied-files-from-old-location/'))
