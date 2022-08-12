# calculate difference in LL and PL between the
# uniform and non-uniform sands

# looks like there's no correlation with percent sand...
# the mean value is ~0.6% water content for both LL and PL

library(magrittr)
library(ggplot2)

x <- readr::read_rds("./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds")

res<- x %>% 
  tidyr::pivot_wider(id_cols = c(sand_pct, test_type),names_from = sand_name,
                     values_from = water_content
  ) %>% 
  dplyr::mutate(diff = high_Cu_Quickcrete - low_Cu_Quickcrete)

res %>% 
  split(~test_type) %>% 
  purrr::map("diff") %>% 
  purrr::map_dbl(mean, na.rm = T)

res %>% 
  ggplot(aes(sand_pct, diff, color = test_type))+
  geom_point(alpha = 1/2)+
  geom_smooth(se = F, method = 'lm', formula = y~x, linetype = 'longdash', size = 0.25)+
  colorblindr::scale_color_OkabeIto()+
  ecmfuns::theme_ecm_bw()



