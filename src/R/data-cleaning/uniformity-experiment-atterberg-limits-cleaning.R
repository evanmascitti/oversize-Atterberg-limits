# This script pulls in all the LL and PL tests on the two separate trials for 
# the mixes I made with 2 kinds of Quickcrete sand and the Casselman clay. 

# There are a few mixes that I re-did due to sample mix-ups or not really trusting 
# the results...in this script I make those corrections and output the cleaned 
# data set as a tidy tibble in .rds format. 


# Fortunately I did most of these tests after figuring out how to structure the
# raw data files and folders correctly...so the code should be pretty concise. 


# accept output file path as an input for compatibility with 
# GNU Make 


if(!interactive()){
  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  cat("Output file path is: ", output_file_path)
}

# set option for tin tares 

options(soiltestr.tin_tares = dplyr::bind_rows(asi468::tin_tares))

suppressPackageStartupMessages({
  library(soiltestr)
  library(purrr)
  })

metadata <- readr::read_csv('ecmdata/metadata/uniformity-experiment-mixes-metadata.csv',
                            col_types = 'icd')

att_lims_dirs <- list.files(path = 'ecmdata/raw-data/uniformity-experiment/',
                            pattern = "atterberg_limits_\\d{4}-\\d{2}-\\d{2}",
                            full.names = T)

all_PL_results <- att_lims_dirs %>% 
  map(PL_batch_analysis, tin_tares = dplyr::bind_rows(asi468::tin_tares))

PL_results <- map(all_PL_results, 'PL_avg_values') %>% 
  dplyr::bind_rows() %>% 
  dplyr::mutate(sample_name = readr::parse_number(as.character(sample_name))) %>% 
  dplyr::select(-batch_sample_number) %>% 
  dplyr::left_join(metadata, by = 'sample_name')



suspect_PLs <- PL_results[PL_results$sample_name %in% c(31:33), ]

# this was for edam commenting out now that script is set
# library(ggplot2)
# theme_set(theme_classic())
# 
# PL_results %>% 
#   dplyr::filter(sand_pct > 0.35) %>% 
#   ggplot(aes(sand_pct, water_content, color = sand_name, label = sample_name))+
#   geom_point()+
#  # geom_text(size = 2, 
#             # nudge_x = 0.01, 
#             # nudge_y = 0.0025, 
#             # aes(color= NULL))+
#   geom_text(data = suspect_PLs,
#             aes(label = paste(sample_name,date, sep = " | "), color = NULL),
#             size = 3)+
#   facet_wrap(~sand_name)
# 
# 
# 
# PL_results %>% 
#   dplyr::filter(!sample_name %in% c(31:33)) %>% 
#   ggplot(aes(sand_pct, water_content, color = sand_name, label = sample_name))+
#   geom_point()+
#   geom_smooth(size = 0.25,
#               se= F,
#               method = lm,
#               formula = y~x)+
#   geom_text(
#     data = dplyr::left_join(PL_results[PL_results$sample_name %in% c(36:37), ], metadata),
#     aes(label = sample_name, color = NULL))



# Well, this is super-duper frustrating. I still can't really tell which results are correct....presumably it's the ones from Feb 6, which were re-dos of the earlier data, but it really 
# looks like sample number 31 is the bigger problem, not 32 and 33. And samples 36-37 seem to be fine. 
# I guess I am just going to test these 3 mixes AGAIN and use the new results. 
# Pretty frustrating, but I want it to be correct. 


# try looking @ the LL data 

all_LL_results <- att_lims_dirs %>% 
  map(LL_batch_analysis)


LL_results <- all_LL_results %>% 
  map("LL_results") %>% 
  dplyr::bind_rows() %>% 
  dplyr::mutate(sample_name = readr::parse_number(as.character(sample_name))) %>% 
  dplyr::left_join(metadata, by = 'sample_name')


suspect_LLs <- LL_results[LL_results$sample_name %in% c(28, 32:33, 36:37), ] %>% 
  dplyr::left_join(metadata, by = c("sample_name", "sand_name", "sand_pct"))

# commenting out now that code is working 

# LL_results %>% 
#   ggplot(aes(sand_pct ,water_content, color = sand_name))+
#   geom_point()+
#   # geom_text(size = 2, 
#   # nudge_x = 0.01, 
#   # nudge_y = 0.0025, 
#   # aes(color= NULL))+
#   geom_text(data = suspect_LLs,
#             aes(label = paste(date, sample_name, sep = " | "), color = NULL),
#             size = 3)+
#   facet_wrap(~sand_name)


# OK, this sheds a bit more light.
# The LL data for samples 36 and 37 should come from feb 4. And the LL data for samples 32 and 33 should come from feb 6.
# Try that filter and look @ the LL plots again.

# commenting out now that code is working 
# LL_results %>% 
#   dplyr::filter(
#     ! (sample_name %in% c(32:33) & date  == '2021-01-28'),
#     ! (sample_name %in% c(36:37) & date  == '2021-01-29')
#   ) %>% 
#   ggplot(aes(sand_pct ,water_content, color = sand_name))+
#   geom_point()

# looking better....now there is also an extra data point for mix 28, which I 
# think was also messed up...label that one 

# commenting out now that code is working 
# 
# LL_results %>% 
#   ggplot(aes(sand_pct ,water_content, color = sand_name))+
#   geom_point()+
#  geom_text(data = suspect_LLs[suspect_LLs$sample_name == 28, , drop= FALSE],
#             aes(label = paste(date, sample_name, sep = " | "), color = NULL),
#             size = 3)+
#   facet_wrap(~sand_name)

# yes, not much of a difference, but remove the point from jan 23

# commenting out now that code is working 
# 
# LL_results %>% 
#   dplyr::filter(
#     !(sample_name %in% c(32:33) & date  == '2021-01-28'),
#     !(sample_name %in% c(36:37) & date  == '2021-01-29'),
#     !(sample_name == 28 & date  == '2021-01-23')
#   ) %>% 
#   ggplot(aes(sand_pct ,water_content, color = sand_name))+
#   geom_point()

# OK, I think we have established which points to filter out.
# Try doing it for both the PL and LL samples and re-make the plots.

# bind the data frames together and then filter out those erroneous points 

all_att_lims_results <- dplyr::bind_rows(LL_results, PL_results) %>% 
  dplyr::filter(
    !(sample_name %in% c(32:33) & date  == '2021-01-28'),
    !(sample_name %in% c(36:37) & date  == '2021-01-29'),
    !(sample_name == 28 & date  == '2021-01-23')
  ) %>% 
  dplyr::select(-batch_sample_number)

# commenting out now that code is working 
# 
# all_att_lims_results %>%
#   ggplot(aes(sand_pct , water_content, color = sand_name, group = test_type))+
#   geom_point()+
#   geom_smooth(method = lm,
#               formula = y~x,
#               se = F,
#               size = 0.25)+
#   facet_wrap(~sand_name)


# write the new data file to disk so it can be used elsewehere 

readr::write_rds(
  x = all_att_lims_results,
  file = output_file_path
  )




#----------------------------------------------------------
#---------------------------------------------------------

# check out the trends with some additional plots;
# this code could easily be re-used later even though 
# I have commented it out here 
# 
# all_att_lims_results %>% 
#   ggplot(aes(sand_pct , water_content, color = sand_name, group = test_type))+
#   geom_point()+
#   geom_smooth(method = lm,
#               formula = y~x,
#               se = F)+
#   facet_wrap(~sand_name)
# 
# # the abrupt change in slope is clearer when plotted as 4 separate panels
# all_att_lims_results %>% 
#   ggplot(aes(sand_pct , water_content, color = sand_name, group = test_type))+
#   geom_point()+
#  facet_grid(sand_name~test_type)
# 
# # now try comparing the sands on a per-test basis 
# 
# all_att_lims_results %>% 
#   ggplot(aes(sand_pct , water_content, color = sand_name, group = test_type))+
#   geom_point()+
#   facet_wrap(~test_type)
# 
# # Probably the better way to show this is just to plot PI
# # this one makes facets 
# 
# all_att_lims_results %>% 
#   tidyr::pivot_wider(names_from = 'test_type',
#                      values_from = 'water_content') %>% 
#   dplyr::mutate(PI = LL - PL) %>% 
#   tidyr::pivot_longer(cols = c(LL, PL, PI),
#                       names_to = 'test_type',
#                      values_to = 'water_content'
#                      ) %>% 
#   ggplot(aes(sand_pct , PI, color = sand_name, group = test_type))+
#   geom_point()+
#   facet_wrap(~test_type)
# 
# # and this one makes the PI plot only 
# 
# all_att_lims_results %>% 
#   tidyr::pivot_wider(names_from = 'test_type',
#                      values_from = 'water_content') %>% 
#   dplyr::mutate(PI = LL - PL) %>% 
#  ggplot(aes(sand_pct , PI, color = sand_name))+
#  geom_smooth(method = lm,
#               formula = y~x, 
#               se = T, 
#               size = 0.25,
#              alpha = 1/5
#               )+
#   geom_point()
  




