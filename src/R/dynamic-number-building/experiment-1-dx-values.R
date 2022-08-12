# This script computes the D50 for each of the 6 coarse additions used in 
# experiment 1. Note that the D60 and D10 are not computed here though they 
# could be added later. 


# The script uses data collected in Summer of 2020....maybe eventually I can figure out the log-linear interpolation, but for now I'll just use the graphically-determined parameters. 
# The script writes an rds file containing these data in a format that can be re-used for tables, figures, or other analyses. 



output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

'ecmdata/raw-data/experiment-1-coarse-particles-d50.rds'

library(magrittr)

metadata <- readr::read_csv('./ecmdata/metadata/experiment-1-expt_sand_numbers-metadata.csv', col_types = 'idd')

sand_d_50_values <- readr::read_csv('./ecmdata/raw-data/experiments-1-and-2/experiment-1-sand-size-graphically-determined-D50-values.csv',
                col_types = 'icdddd') %>% 
  dplyr::transmute(expt_sand_number = expt_sand_number,
                   d50 = D50 / 1000) %>% 
  dplyr::left_join(metadata, by = 'expt_sand_number') %>% 
  dplyr::select(expt_sand_number, d50)

silt_d_50 <- readr::read_csv(
  file = './ecmdata/raw-data/experiments-1-and-2/experiment-1-silt-size-graphically-determined-D50-values.csv',
  col_types = 'id'
)

coarse_particles_d_50_values <- dplyr::bind_rows(
  sand_d_50_values, silt_d_50
)

readr::write_rds(
  x = coarse_particles_d_50_values,
  file = output_file_path)



# some extra stuff I played around with  ----------------------------------


# the d50 values from the geotech package seem wrong 

# sand_pct_passing_data <- readr::read_csv('ecmdata/raw-data/experiment-1/experiment-1-sands-pct-passing.csv', col_types = 'idd')


# get_d50 <- function(x){
#   
#   geotech::Dsize(N=50, size = x$size, percent = x$percent)
# }
# 
# sand_pct_passing_data %>% 
#   dplyr::transmute(expt_sand_number = expt_sand_number,
#                    size = microns / 1000,
#                    percent = pct_passing * 100) %>% 
#   split(~expt_sand_number) %>% 
#   lapply(get_d50)
# 
# 
# 
# library(ggplot2)
# plot_fun <- function(df, id){
#   df %>% 
#     ggplot(aes(microns, pct_passing))+
#     geom_point()+
#     geom_line()+
#     scale_x_continuous(trans = 'log10')
# }
# 
# 
# sand_pct_passing_data %>% 
#   split(~expt_sand_number) %>% 
#   lapply(plot_fun)
# 
# plots <- sand_pct_passing_data %>% 
#   dplyr::rename(percent_passing = pct_passing) %>% 
#   split(~expt_sand_number) %>% 
#   lapply(soiltestr::ggpsd)
# 
# plots[[2]]
# plots[[3]]
# 
# sand_pct_passing_data %>%
#   tibble::rownames_to_column() %>% 
#   dplyr::group_by(expt_sand_number) %>%  
#   dplyr::mutate(diff = abs(pct_passing - dplyr::lag(pct_passing))) %>% 
#   # dplyr::group_by(dplyr::across(.cols = -diff)) %>% 
#   dplyr::summarise(diff = max(diff, na.rm = TRUE))
# dplyr::filter(diff == max(diff))

