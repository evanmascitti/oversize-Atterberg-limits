# this script takes all the 'cleaned' rds files and writes them to .csv format
# while journals want 'raw' or 'unprocessed' data, I think they really mean they
# want the data passed into statistical models or figures....not the actual 'unclean'
# data. 

# I can put the `Makefile` online, though it will not be totally linked with 
# the raw data. I guess it can just live on Github if somebody wants to actually
# reproduce the entire thing. 




# for the first paper  ----------------------------------------------------

# technically there are three data sets of observations....one for the LL raw observations, 
# one for derived LL values, and one for PL raw observations.
# However I am just going to include the single data set containing all the 
# derived values, because this is what was passed into the stats and the figures. 
# there is also the estimated toughness values, which are computed from this same 
# data set.
# I guess I can include another R script that calculates this value for each observation


library(magrittr)

part_I_atterberg_limits <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds"
) %>% 
  dplyr::arrange(dplyr::desc(max_particle_size), dplyr::desc(coarse_pct))

part_I_estimated_toughness <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-estimated-toughness-values-cleaned-data.rds"
) %>% 
  dplyr::arrange(dplyr::desc(coarse_size ), dplyr::desc(coarse_pct))



# for paper 2 -------------------------------------------------------------


part_II_shape_expt_atterberg_limits <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-2-atterberg-limits-cleaned-data.rds"
)

part_II_uniformity_expt_atterberg_limits <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds"
)


# combine the various tibbles into a data frame and write using the appropriate 
# names 

sheets_to_write <- list(
  part_I_atterberg_limits = part_I_atterberg_limits, 
  part_I_estimated_toughness = part_I_estimated_toughness, 
  part_II_shape_expt_atterberg_limits =   part_II_shape_expt_atterberg_limits, 
  part_II_uniformity_expt_atterberg_limits =   part_II_uniformity_expt_atterberg_limits) %>% 
  tibble::enframe(name = "file", value = "x") %>% 
  dplyr::mutate(
    file = fs::path("paper", "data-files-for-submission", paste0(file, ".csv"))
  )


# write to disk 

purrr::pwalk(sheets_to_write, readr::write_csv, na = "-")
