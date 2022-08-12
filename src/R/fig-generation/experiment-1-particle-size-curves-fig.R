# This script draws the particle size distributions of 
# all 6 coarse addition types in experiment 1

library(magrittr)
library(ggplot2)
library(soiltestr)
source(here::here("src/R/helpers/oversizeALims-utils.R"))


experiment_1_samples_percent_passing <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/experiment-1-particle-size-curves-cleaned-data.rds'
)


avg_d_df <-  readr::read_rds('./ecmdata/derived-data/dynamic-number-references/experiment-1-dx-values.rds') %>% 
  dplyr::rename(x= d50) %>% 
  dplyr::mutate(x = 1000*x) %>% 
  dplyr::mutate(xend = x,
                y=-Inf,
                yend = 0.5)

experiment_1_particle_size_curves <- experiment_1_samples_percent_passing %>% 
  soiltestr::ggpsd(color = factor(unique_sample_ID), log_lines = FALSE, 
                   bold_log_lines = FALSE)+
  scale_color_manual(values = c(colorblindr::palette_OkabeIto[1:length(unique(experiment_1_samples_percent_passing$unique_sample_ID))-1], 'grey50'))+
  #colorblindr::scale_color_OkabeIto()+
 geom_segment(
    data = avg_d_df,
    inherit.aes = FALSE,
      aes(
        y = y,
      yend = yend,
      x = x,
      xend = xend),
      color = 'grey70',
    linetype = 'dashed',
    #arrow = arrow(ends = 'first')
    )+
  geom_hline(yintercept = 0.5, 
             color = 'grey70', size = 0.3)+
  scale_x_continuous("Particle diameter, \u03bcm",
                     trans = 'log10',
                     breaks = c(0.2, 2, avg_d_df$x),
                     labels = as.character(c(0.2, 2, avg_d_df$x)))+
  annotate('text', x = 6, y = 0.75, label = 'Porcelain clay', 
           size = 2.5,
           color = 'grey70')+
  geom_segment(data = NULL,
               inherit.aes = FALSE,
               aes(x = 6, y = 0.72, xend = 8, yend = 0.65),
               arrow = arrow(length = unit(0.05, "inches"),
                             type = 'closed'),
               color = 'grey70')+
  annotate('text', x = 3, y = 0.3, label = 'Coarse additions', 
           size = 2.5,
           color = 'grey50')+
  geom_segment(data = NULL,
               inherit.aes = FALSE,
               aes(x = 6.5, y = 0.3, xend = 8, yend = 0.3),
               arrow = arrow(length = unit(0.05, "inches"),
                             type = 'closed'),
               color = 'grey50')+
  theme(
    legend.position = 'none',
    panel.grid = element_blank()
  )
# +
#   ggplot2::annotation_logticks(
#     sides = 'b',
#     colour = 'grey75',
#     size = 0.5
#   )

experiment_1_particle_size_curves$labels$title <- "PSDs of mix components - Experiment 1"

if(!interactive()){
 
  save_fig(
  experiment_1_particle_size_curves)
}
