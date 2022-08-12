# This script buids a faceted plot comparing each Atterberg limit test result for experiment 2 


suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
  })

# filter out adhesion limit data 

all_att_lims_results <- readr::read_rds('./ecmdata/derived-data/cleaned-rds-files/experiment-2-atterberg-limits-cleaned-data.rds') %>% 
  dplyr::mutate(
    coarse_name = dplyr::case_when(
      coarse_name == "Mancino_angular" ~ "Angular",
      coarse_name == "Granusil_4095" ~ "Round"
    ),
    test_type = dplyr::case_when(
      test_type == "LL" ~ "Liquid limit",
      test_type == "PL" ~ "Plastic limit",
      test_type == "AL" ~ "Adhesion limit",
    )) %>% 
  dplyr::filter(test_type != 'Adhesion limit')

experiment_2_atterberg_limit_facets <- all_att_lims_results[!is.na(all_att_lims_results$water_content), ] %>%
  ggplot(aes(coarse_pct , water_content, color = coarse_name, group = test_type))+
  geom_smooth(method = 'lm',
              formula = y~splines::ns(x,2),
              se = FALSE,
              size = 0.25,
              aes(group = coarse_name),
              show.legend = FALSE)+
  geom_point(alpha = 1/2)+
  facet_wrap(~test_type)+
  scale_x_continuous(expression('Sand content, g g'^1%*%100),
                     limits = c(0,1),
                     breaks = scales::breaks_width(width = 0.2),
                     labels = scales::label_percent(suffix = "", accuracy = 1 ))+
  scale_y_continuous(expression('Water content, g g'^1%*%100),
                     labels = scales::label_percent(suffix = "",
                                                    accuracy = 1))+
  colorblindr::scale_color_OkabeIto()+
  guides(color = guide_legend("Sand shape"))+
  theme(strip.background = element_blank(),
        strip.text = element_text(face = 'bold', size = 10),
        legend.position = c(0.95, 0.95),
        legend.justification = c(0.95, 0.95))
experiment_2_atterberg_limit_facets
# +
#   guides(
#     color = guide_legend(title = NULL)
#   )
  

if(interactive()) print(experiment_2_atterberg_limit_facets)

# save to disk

ecmfuns::save_fig(experiment_2_atterberg_limit_facets)

