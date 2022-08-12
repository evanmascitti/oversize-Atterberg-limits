# This script splits the data from Experiment 3 
# by sand type and fits a segmented regression
# to the LL and PL data. If desired to run for 
# just one of these , it is straightforward 
# to run a filter statement before fitting 
# the models or even at the end, before making 
# the ggplot. 

# Basically, it doesn't work very well.
# It puts the breakpoints at too low a sand %....
# The deviations along the line seem to of 
# comparable magnitude to those comprising the 
# 'true' break in the curve, and there just aren't 
# that many points above the 'threshold' point
# anyway....there's obviously a physical meaning 
# behind that as the test won't really work 
# once the TFC has been substantially surpassed. 

# Here I have kept the code anyway; it may find 
# use in other experiments, specifically 
# my cleat-mark test. 

# I have tried another package called 'segmented';
# it seems to have a lot more functions but 
# it is basically impossible to use with iteration
# because it includes a check about whether one 
# of the arguments is a data frame....when you use 
# a loop or functional (like lapply or purrr::map),
# a placeholder is used when you fit an lm (i.e. data = .).....so when the segmented function goes to # look for that name in the global environment, it 
# isn't found. In my mind this is a deal-breaker not to be able to use a simple call to lapply or map. 

# Instead I found another package which is not on # CRAN, but gives a much, much simpler output and overall user interface. 

# Here is the command to install the package from github remotes::install_github("MatthieuStigler/seglm")

###--------------------------------------


suppressPackageStartupMessages({
  library(seglm)
  library(magrittr)
  library(ggplot2)
  library(segmented)
  theme_set(ecmfuns::theme_ecm_bw())
})

all_att_lims_results <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds'
)


# filter any NA observations as these will throw 
# a non-helpful error messabe from seglm_lm 

test_dfs <- all_att_lims_results[,  c('test_type', 'sand_name', 'water_content', 'sand_pct')] %>% 
  tidyr::drop_na() %>%
  as.data.frame() %>% 
  dplyr::filter(sand_pct > 0.15) %>% 
  dplyr::group_by(sand_name, test_type) %>% 
  dplyr::group_split() 

labs <- purrr::map_chr(test_dfs,
                       .f = ~paste(unique(.$test_type),
                                   unique(.$sand_name), sep = "|"))

named_dfs <- set_names(test_dfs, value = labs)

# compute the breakpoints
# there is a little skip 
# in the data at 15% sand which throws off the 
# regression for the high Cu sand ....just run
# it for samples > 15% sand 

tfcs <-  named_dfs %>% 
  purrr::map(~seglm_lm(
    data = ., 
    formula = water_content ~ sand_pct, th_var_name = 'sand_pct')) %>% 
  purrr::map('th_val') %>%
  unlist() %>% 
  tibble::enframe(name = 'id', value = 'tfc') %>% 
  tidyr::separate(col  = id,
                  into = c('test_type',
                           'sand_name'),
                  sep = "\\|")


# plot the results with a line for each subset 
all_att_lims_results %>% 
  dplyr::left_join(tfcs) %>% 
  #dplyr::left_join(LL_tfc, by = 'sand_name') %>% 
  dplyr::mutate(exceeds_tfc  = sand_pct > tfc) %>% 
  ggplot(aes(sand_pct, water_content, 
             group = exceeds_tfc,
             color = sand_name))+
  geom_point()+
  geom_smooth(method = lm,
              formula = y~x,
              se = FALSE,
              size = 0.25)+
  facet_grid(test_type~sand_name)

