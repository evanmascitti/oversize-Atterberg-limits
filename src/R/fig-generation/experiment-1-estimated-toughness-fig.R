# This script generates a figure showing the estimated 
# toughness for each mix, computed from the Moreno-Marato
# equation.

suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
  })


# show the data only up to 70% sand or silt; all mixtures had 
# measurable PI at this mass %

expt_1_toughness_data <- readr::read_rds(
  file = here::here("ecmdata", "derived-data", "cleaned-rds-files", "experiment-1-estimated-toughness-values-cleaned-data.rds")
)
  
#   readr::read_rds(
#   "ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds" 
# ) %>% 
#   dplyr::filter(coarse_pct <= 0.7) %>% 
#   dplyr::select(coarse_name, coarse_size, coarse_pct, test_type, water_content) %>% 
#   dplyr::distinct() %>% 
#   tidyr::pivot_wider(
#     names_from = test_type, 
#     values_from = water_content
#     ) %>% 
#   dplyr::mutate(PI = LL- PL) %>% 
#   ecmfuns::add_mormar_toughness_est() %>% 
#   dplyr::rename(t_max = mormar_toughness_est)

experiment_1_estimated_toughness <- expt_1_toughness_data %>% 
  ggplot(aes(
    coarse_pct, t_max, color = coarse_size))+
  geom_point(alpha = 2/3)+
  geom_line(alpha = 2/3, size = 0.3, show.legend = FALSE)+
 # geom_smooth(method = lm, formula = y~splines::ns(x, 2),
 #             se= F, size = 0.25)+
  colorblindr::scale_color_OkabeIto()+
  guides(color = guide_legend(title = 'Coarse addition\nsize range (mm)',
                              reverse = TRUE))+
  scale_x_continuous(expression('Coarse addition mass, g g'^1~""%*%100), 
                     limits = c(0,1), 
                     labels = scales::label_percent(suffix = "", accuracy = 1), 
                     breaks = seq(0, 1, 0.2))+
  scale_y_continuous(expression('Estimated '*T[max]*' (kJ m'^3*')'), 
                     labels = scales::label_comma())+
  ecmfuns::theme_ecm_bw()+
  theme(panel.grid.minor = element_blank())

ecmfuns::save_fig(experiment_1_estimated_toughness)
