# Plot the difference between the predicted and measured LL and PL for the particle size experiment (originally experiment 1)

# can't figure out why there are still values at 80% for the coarse 
# sands. These should be NA values. Have not been able to track down 
# where the calculation went awry.

library(ggplot2)
library(purrr)
theme_set(ecmfuns::theme_ecm_bw())
source("./src/R/helpers/oversizeALims-utils.R")

# read data 

plotting_data <-  readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds"
) %>% 
  dplyr::filter(
    test_type %in% c("LL", "PL")
  ) %>% 
  dplyr::mutate(
    facet_label = paste0(
      "atop(",
      "textstyle(D[50]==",
      signif(d50, digits = 2),
      "), textstyle(",
      coarse_size, 
      "),",
      ")"
    ))



# build plot 

experiment_1_linear_law_deviations <- plotting_data %>% 
  ggplot(aes(
    coarse_pct, linear_law_deviation, color = test_type))+
  geom_point(size = 1)+
  geom_smooth(method = lm, formula = y~splines::ns(x, 2),
              se= F, size = 0.25)+
  scale_color_brewer(palette = 'Dark2')+
  scale_x_continuous(
    expression('Coarse addition mass (%)'),
    limits = c(0, 1),
    labels = scales::label_percent(suffix = "", accuracy = 1),
    breaks = seq(0, 1, 0.2)) +
  scale_y_continuous(expression(Delta~'gravimetric water content (%)'),
                     labels = scales::label_percent(suffix = "", accuracy = 1))+
  facet_grid(test_type~facet_label, labeller = label_parsed)+
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


# experiment_1_linear_law_deviations <- attlims %>% 
#   ggplot(aes(coarse_pct, linear_law_deviation, color = factor(coarse_size), fill = factor(coarse_size)))+
#   geom_point()+
#   geom_smooth(method = lm, formula = y~splines::ns(x, 2), se = F, size = 0.25)+
#   facet_grid(test_type~coarse_size)+
#   scale_x_continuous(expression("Coarse addition mass (%)"),
#                      labels = scales::label_percent(accuracy = 1, suffix = ""))+
#   scale_y_continuous(expression(Delta[w]~"from predicted by linear law, g g"^-1*"x 100"))+
#   guides(color = guide_legend("Coarse addition\nsize"),
#          fill = guide_legend("Coarse addition\nsize"))+
#   theme(legend.position = 'none')



  
# write to disk 
save_fig(plot = experiment_1_linear_law_deviations)
