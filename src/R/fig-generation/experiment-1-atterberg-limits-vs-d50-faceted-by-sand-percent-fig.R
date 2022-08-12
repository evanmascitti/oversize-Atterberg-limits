suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
})

# build vector of lines for showing logarithmic scale 
sand_log_lines <- c(seq(0.02, 0.2, 0.02),
                    seq(0.2, 2, 0.2),
                    seq(2, 20, 2))

# wrangle data 
experiment_1_data <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds'
) %>% 
  dplyr::filter(test_type %in% c('LL', 'PL')) %>% 
  dplyr::mutate(coarse_pct_label = paste(100*coarse_pct, "%")) %>% 
  dplyr::mutate(test_type = forcats::fct_reorder(test_type, water_content, .desc = TRUE)) %>% 
  dplyr::select(sample_name, test_type, coarse_size, coarse_pct, coarse_pct_label, d50,water_content) %>% 
  tidyr::pivot_wider(names_from = test_type, values_from = water_content) %>% 
  dplyr::mutate(PI = LL - PL) %>% 
  tidyr::pivot_longer(cols = c(PL, LL, PI),
                      names_to = 'test_type', 
                      values_to = 'water_content')

# build separate data frame for arrows and labels....currently not using though
PI_arrow_labs <- experiment_1_data %>% 
  tidyr::pivot_wider(names_from = test_type, values_from = water_content) %>% 
  dplyr::mutate(
    y_text_loc = (((LL - PL) / 2) + PL),
    y_arrow_bottom = ((((
      LL - PL
    )) * 0.2) + PL),
    y_arrow_top = ((((
      LL - PL
    )) * 0.8)) + PL,
    text = "PI"
  ) %>% 
  dplyr::filter(coarse_size == '0.25-0.15') %>% 
  tidyr::drop_na() %>% 
  dplyr::arrange(dplyr::desc(coarse_pct))

# construct plot 
experiment_1_atterberg_limits_vs_d50_faceted_by_sand_percent <- experiment_1_data %>% 
  dplyr::filter(test_type %in% c("LL", "PL")) %>% 
  ggplot()+
  geom_vline(xintercept= sand_log_lines, color='grey95', size = 0.25)+
  geom_point(aes(d50, water_content, color= test_type))+
  geom_smooth(aes(d50, water_content, color= test_type), method=lm, formula = y~((x)), se=FALSE, show.legend = FALSE, size = 0.3)+
  scale_x_continuous(trans = 'log10', limits = c(0.02, 2), n.breaks=4)+
  scale_y_continuous(limits= c(0, 0.5), labels = scales::percent_format(accuracy = 1, suffix = ''))+
  # geom_segment(data= PI_arrow_labs,
  #              aes(x=d50, xend=d50, y=y_arrow_bottom, yend= y_arrow_top),
  #              color= 'grey20',
  #              alpha = 1/3,
  #              arrow = arrow(length = unit(0.075, 'inches'), type =  'open', ends= 'both',
  #                            angle=20))+
  # geom_text(data = PI_arrow_labs,
  #           aes(x= d50 - 0.7, y= y_text_loc, label= text),
  #           color= 'grey20')+
  labs(x=expression('D'[50]~'of coarse fraction, mm'),
       y=expression('Water content, g g'^1~""%*%100), 
       title = expression('Percent coarse addition, g g'^-1)
  )+
  guides(color = guide_legend())+
  scale_color_manual(values = colorblindr::palette_OkabeIto[2:1])+ # annoying but can't figure out how to make color scale and factor levels work in tandem. For only 2 levels I'm ok with hard-coding it. 
  facet_wrap(~coarse_pct_label, nrow=1)+
  theme(legend.position = c(0.98, 0.99),
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.margin = margin(),
        strip.background = element_blank(),
        #strip.text = element_text(face = 'bold'),
        plot.title = element_text(size = 11, face = 'plain', hjust = 0.5,
                                  margin = margin()))

if(interactive()){print(experiment_1_atterberg_limits_vs_d50_faceted_by_sand_percent)}

# write to disk 
ecmfuns::save_fig(experiment_1_atterberg_limits_vs_d50_faceted_by_sand_percent)


