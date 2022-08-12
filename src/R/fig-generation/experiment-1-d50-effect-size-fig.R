# This figure boils down the size "bins" into a single representative particle diameter and shows the amount of deviation from the linear law as a function of the size and % sand. 
# There is one line per sand % and one data point per mixture.


suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
})

# read main data set 

expt1_all_data <- readr::read_rds(
  'ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds'
) %>% 
  dplyr::mutate(test_type = dplyr::case_when(
    test_type == "LL" ~ "Liquid limit",
    test_type == "PL" ~ "Plastic limit",
    test_type == "AL" ~ "Adhesion limit",
  ))

# filter out adhesion limit data and the 0% coarse addition data points

plotting_data <- expt1_all_data %>% 
  dplyr::filter(
    !stringr::str_detect(
      string = test_type,
      stringr::regex(pattern = 'adhesion', ignore_case = T)),
    coarse_pct != 0)
#%>% 
 # dplyr::left_join(sand_metadata, by = "coarse_size") %>% 
  #dplyr::left_join(d_50_values, by = "expt_sand_number") %>% 
  #dplyr::relocate(expt_sand_number, .after = sample_name) %>% 
  #dplyr::filter(coarse_pct < 0.8)


# create data frame for labeling the lines 

coarse_pct_labels_df <- plotting_data %>% 
  dplyr::filter(d50  == min(plotting_data$d50)) %>% 
  dplyr::mutate(text = paste0(100*coarse_pct, "%"),
                d50 = d50  - 0.001)


# plot with % coarse addition as a factor

# experiment_1_d50_effect_size <- plotting_data %>% 
#   ggplot(aes(d50, linear_law_deviation, 
#              color = factor(100*coarse_pct),
#              #group = coarse_pct
#   ))+
#   geom_point(alpha = 1/2)+
#   ggrepel::geom_text_repel(
#     show.legend = FALSE,
#     data = coarse_pct_labels_df,
#     aes(label = text),
#     size = 3,
#     nudge_x = -0.1,
#     nudge_y = 0.005,
#     direction = "y"
#   )+
#   geom_smooth(method = 'lm', 
#               formula = y~splines::ns(x,2), 
#               se = F, 
#               size = 0.25)+
#   scale_x_continuous(name = expression(D[50]~"(mm)"),
#                      trans = 'log10',
#                      #breaks = c(0.05, 0.15, 0.25, 0.5, 1, 2)
#                      breaks = unique(plotting_data$d50),
#                      labels = scales::label_number(accuracy = 0.01))+
#   expand_limits(x = 0.013)+
#   scale_y_continuous(expression(Delta~'water content, g g'^1~""%*%100), 
#                      labels = scales::label_percent(suffix = "", accuracy = 1))+
#   colorblindr::scale_color_OkabeIto()+
#   guides(color = guide_legend(reverse = TRUE,
#                               title = "% Coarse\naddition"))+
#   facet_wrap(~test_type)+
#   theme(
#     panel.grid.major.y = element_blank(),
#     panel.grid.minor.y = element_blank(),
#     panel.grid.minor.x = element_blank(),
#     panel.grid.major.x = element_line(size = 0.25, colour = 'grey95'),
#     strip.background = element_blank(),
#     strip.text = element_text(face = 'bold', size = 10),
#     legend.position = 'none'
#     
#   )

# plot with % coarse addition as a continuous variable 
experiment_1_d50_effect_size <- plotting_data %>% 
  ggplot(aes(d50, linear_law_deviation, 
             color = coarse_pct))+
  geom_point(alpha = 1/2)+
  ggrepel::geom_text_repel(
    show.legend = FALSE,
    data = coarse_pct_labels_df,
    aes(label = text),
    size = 3,
    nudge_x = -0.1,
    nudge_y = 0.005,
    direction = "y"
  )+
  geom_smooth(aes(group = coarse_pct),
              method = 'lm', 
              formula = y~splines::ns(x,2), 
              se = F, 
              size = 0.25,
              alpha = 2/3)+
  scale_x_continuous(name = expression(D[50]~"(mm)"),
                     trans = 'log10',
                     #breaks = c(0.05, 0.15, 0.25, 0.5, 1, 2)
                     breaks = unique(plotting_data$d50),
                     labels = scales::label_number(
                       accuracy = 0.01))+
  expand_limits(x = 0.013)+
  scale_y_continuous(
    name = expression(Delta~'water content, g g'^1~""%*%100),
    labels = scales::label_percent(suffix = "", accuracy = 1))+
  colorspace::scale_color_binned_sequential(palette = "Blues2")+
  guides(color = guide_legend(reverse = TRUE,
                              title = "% Coarse\naddition"))+
  facet_wrap(~test_type)+
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_line(size = 0.25, colour = 'grey95'),
    strip.background = element_blank(),
    strip.text = element_text(face = 'bold', size = 10),
    legend.position = 'none')

if(interactive()){print(experiment_1_d50_effect_size)}
ecmfuns::save_fig(experiment_1_d50_effect_size)

# -------------------------------------------------

# some extra code I used to iterate through some plots 


# plotting_data %>% 
#   ggplot(aes(d50, linear_law_deviation, 
#              color = factor(coarse_pct),
#              #group = test_type
#   ))+
#   geom_point()+
#   geom_smooth(method = 'lm', formula = y~splines::ns(x,2), se = F, size = 0.25)+
#   scale_x_continuous(trans = 'log10')+
#   #facet_wrap(~test_type)
#   facet_grid(test_type~coarse_pct)
# 
# # plot with % coarse addition as a continuous variable 
# plotting_data %>% 
#   ggplot(aes(d50, linear_law_deviation, 
#              color = coarse_pct,
#              group = coarse_pct
#   ))+
#   geom_point(shape =1)+
#   geom_smooth(method = 'lm', 
#               formula = y~splines::ns(x,2), 
#               se = F, 
#               size = 0.25)+
#   scale_x_continuous(trans = 'log10')+
#   colorspace::scale_color_binned_sequential(palette = 'Grays')+
#   facet_wrap(~test_type)

#----------------------------------------------------------------------

