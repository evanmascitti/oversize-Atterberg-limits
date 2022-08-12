# This script builds a set of small multiples with each plotting water 
# content against % coarse addition (6 data points per plot; 3 limits x 7 sizes)

library(ggplot2)
library(purrr)
theme_set(ecmfuns::theme_ecm_bw())

# read main data set , which also includes D50 values

expt1_all_data <- readr::read_rds(
  'ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds'
) 
# %>% 
#   dplyr::mutate(test_type = dplyr::case_when(
#     test_type == "LL" ~ "Liquid\nlimit",
#     test_type == "PL" ~ "Plastic\nlimit",
#     test_type == "AL" ~ "Adhesion\nlimit",
#   ))




# filter out adhesion limit data 

plotting_data <- expt1_all_data %>% 
  dplyr::filter(
    test_type %in% c("LL", "PL")
    # the below is for when the test names are actually spelled out
    # instead of abbreviated 
  #   !stringr::str_detect(
  #   string = test_type,
  #   stringr::regex(pattern = 'adhesion', ignore_case = T)
  # )
  ) %>% 
  dplyr::mutate(
    upper_microns = as.numeric(upper_mm) * 1000, 
    lower_microns = as.numeric(lower_mm) * 1000,
    #coarse_size = paste0(upper_microns, "-", lower_microns, " \u03bcm"),
    #coarse_size = paste0(upper_microns, "-", lower_microns, " \u03bcm"),
    coarse_size = paste0(upper_microns, "-", lower_microns),
    #coarse_size = (factor(coarse_size), d50),
    d50_microns = d50 * 1000,
    # facet_label = paste0(
    #   "atop(",
    #   "textstyle(D[50]==",
    #   signif(d50_microns, digits = 2),
    #   "~\u03bcm",
    #   "), textstyle(",
    #   coarse_size, 
    #   "~\u03bcm",
    #   ")",
    #   ")"
    # ),
    facet_label = paste0(
      "atop(textstyle(",
      coarse_size, 
      "~\u03bcm",
      "), ",
      "textstyle(D[50]==",
      signif(d50_microns, digits = 2),
      "~\u03bcm",
      "), )"
    ),
    facet_label = forcats::fct_reorder(facet_label, d50_microns))
    # facet_label = paste0(
    #   "atop(",
    #   "textstyle(D[50]==",
    #   signif(d50, digits = 2),
    #   ")~\"mm\", textstyle(",
    #   coarse_size, 
    #   "~\"mm\"),",
    #   ")"
    # ))
  # dplyr::mutate(
  #   facet_label = paste0(
  #     "atop(textstyle(",
  #     coarse_size, 
  #     "~\"mm\"),",
  #     "textstyle(D[50]==",
  #     signif(d50, digits = 2),
  #     ")~\"mm\"",
  #     ")"
  #   ))
    #coarse_size = map(coarse_size, bquote(atop(.(.), D[50]==.(d50) )))
    # coarse_size = paste0(coarse_size, "mm", "\n", "D\u2085\u2080", "=", d50, "mm") # map(coarse_size, ~expression(atop(., D[50]==d_0)))
  
  

# make the plot 

# this would work with base R plotting but does not for ggplot 
# par(lheight=0.2) 



experiment_1_atterberg_limit_facets <- plotting_data %>% 
  ggplot(aes(
    coarse_pct, water_content, color = test_type))+
  geom_line(aes(y = predicted_water_content,
                color = NULL,
                group = test_type),
            linetype = 'dashed',
            size= 0.25)+
  geom_point(size = 1)+
  geom_smooth(method = lm, formula = y~splines::ns(x, 2),
              se= F, size = 0.25)+
  scale_color_brewer(palette = 'Dark2')+
  scale_x_continuous(
    #expression('Coarse addition mass, g g' ^ 1 ~ "" %*% 100),
    expression('Coarse addition mass (%)'),
    limits = c(0, 1),
    labels = scales::label_percent(suffix = "", accuracy = 1),
    breaks = seq(0, 1, 0.2)) +
  #scale_y_continuous(expression('Water content, g g'^1~""%*%100),
  scale_y_continuous(expression('Gravimetric water content (%)'),
                     labels = scales::label_percent(suffix = "", accuracy = 1))+
  #facet_grid(test_type~coarse_size)+
  facet_grid(test_type~facet_label, labeller = label_parsed)+
  #labs(title = 'Coarse addition size (mm)')+
  theme(strip.text.y = element_text(angle = 0),
        strip.text.x = element_text(size = 24/.pt),
        strip.background = element_blank(),
        axis.text.x = element_text(size  = 7, angle = 30),
        legend.position = 'none',
        axis.text.y = element_text(size  = 7),
        plot.title = element_text(face = 'plain', size = 10, hjust = 0.5),
        panel.grid.major = element_line(size = 0.25, color = 'grey95'),
        panel.grid.minor = element_line(size = 0.25, color = 'grey95'),
        axis.ticks = element_line(size = 0.25))

experiment_1_atterberg_limit_facets

ecmfuns::save_fig(experiment_1_atterberg_limit_facets)

