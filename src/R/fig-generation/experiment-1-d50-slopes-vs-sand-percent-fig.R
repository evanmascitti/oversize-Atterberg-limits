
# Plots the slopes of the models against % coarse addition

suppressPackageStartupMessages({
  library(magrittr)
  library(ggplot2)
  theme_set(ecmfuns::theme_ecm_bw())
})


experiment_1_models <- readr::read_rds(
  './ecmdata/derived-data/models/experiment-1-atterberg-limits-vs-d50-by-coarse-percent-model.rds'
)

experiment_1_d50_slopes_vs_sand_percent <- experiment_1_models %>% 
  ggplot(aes(coarse_pct, slope, color = test_type))+
  geom_point(size = 1.75, alpha = 2/3)+
  geom_smooth(method = lm, formula = y~I(x^2), se = FALSE, 
              show.legend = FALSE, size = 0.25)+
  scale_x_continuous(
    expression('Coarse addition mass, g g' ^ 1 ~ "" %*% 100),
    limits = c(0, 1),
    breaks = scales::breaks_width(width = 0.2),
    labels = scales::label_percent(suffix = "", accuracy = 1)) +
  scale_y_continuous(latex2exp::TeX(input = '$\\left|\\frac{\\mathrm{d}_{w}}{\\mathrm{d}_{log_{10}(D_{50})}}\\right|$'),
                     breaks = scales::breaks_width(width = 0.02),
                     labels = scales::label_number(accuracy = 0.01))+
  scale_color_manual(values =  colorblindr::palette_OkabeIto[2:1])+
  guides(color = guide_legend(reverse = T))+
  #labs(title = expression(D[50]~"influence with coarse additions"))+
  theme(legend.title = element_blank(),
        legend.position = c(0.94, 0.45),
        legend.background = element_rect(color = 'grey75'),
        # legend.margin = margin(),
        legend.justification = c(1,1),
        axis.title.y = element_text(angle = 0, vjust = 0.5))

if(interactive()){print(experiment_1_d50_slopes_vs_sand_percent)}

ecmfuns::save_fig(experiment_1_d50_slopes_vs_sand_percent)


