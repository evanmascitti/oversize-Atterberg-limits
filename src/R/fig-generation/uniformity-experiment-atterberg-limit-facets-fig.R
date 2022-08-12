# This script buids a faceted plot comparing each Atterberg limit test result
# for the two sands


suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
  })


all_att_lims_results <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds'
  ) %>% 
  dplyr::mutate(
    sand_name = dplyr::case_when(
      sand_name == "high_Cu_Quickcrete" ~ "High-C<sub>u</sub>",
      sand_name == "low_Cu_Quickcrete" ~ "Low-C<sub>u</sub>"),
    test_type = dplyr::case_when(
      test_type == 'LL' ~ 'Liquid limit',
      test_type == 'PL' ~ 'Plastic limit',
    ))


uniformity_experiment_atterberg_limit_facets <- all_att_lims_results[!is.na(all_att_lims_results$water_content), ] %>%
  ggplot(aes(sand_pct , water_content, color = sand_name, group = test_type))+
  geom_smooth(
    aes(group = sand_name),
    method = lm,
    se = F,
    formula = y~x,
    size = 0.25,
    alpha = 2/3,
    show.legend = FALSE
   )+
  geom_point(alpha = 1/2)+
  facet_wrap(~test_type)+
  scale_x_continuous(expression('Sand content, g g'^1%*%100),
                     limits = c(0,1),
                     breaks= scales::breaks_width(width = 0.1),
                     labels = scales::label_percent(suffix = "", accuracy = 1 ))+
  scale_y_continuous(expression('Water content, g g'^1%*%100),
                     labels = scales::label_percent(suffix = "",
                                                    accuracy = 1))+
 scale_color_manual(values =  colorblindr::palette_OkabeIto[5:6])+
  guides(
    color = guide_legend(title = 'Sand uniformity',
                         title.hjust = 0.5)
  )+
  theme(legend.text = ggtext::element_markdown(),
        strip.background = element_blank(),
        strip.text = element_text(face = 'bold', size = 10),
        panel.grid.minor = element_blank(),
        legend.position = c(0.95, 0.95),
        legend.justification = c(0.95, 0.95),
        #legend.background = element_rect(colour = 'grey75')
        )
  

if(interactive()) print(uniformity_experiment_atterberg_limit_facets)

# save to disk

ecmfuns::save_fig(uniformity_experiment_atterberg_limit_facets)

