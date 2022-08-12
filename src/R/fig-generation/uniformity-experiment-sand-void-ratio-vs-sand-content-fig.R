# plot the void ratio of the sand phase at the plastic limit 
# water content as a function of sand content 

library(purrr)
library(ggplot2)
theme_set(ecmfuns::theme_ecm_bw())
source("./src/R/helpers/oversizeALims-utils.R")

# setup variables....test time temperature 
# was ~ 22 deg C in the lab

water_G_s <- unlist(soiltestr::h2o_properties_w_temp_c[dplyr::near(soiltestr::h2o_properties_w_temp_c$water_temp_c, 22L), 'water_density_Mg_m3'])

G_c <- 2.78 # hard coded for now but should link to pycnometer data 
G_sa <- 2.67 # same


# read Atterberg limits 
attlims <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds"
) %>% 
  dplyr::select(sand_name, sand_pct, test_type, water_content) %>% 
  dplyr::filter(test_type %in% c("LL", "PL"))


# compute intergranular porosity
n_sa_values <- attlims %>% 
  dplyr::rename(
    m_sa = sand_pct,
    w = water_content
    ) %>% 
  dplyr::mutate(
    m_c = 1 - m_sa,
    effective_saturation = dplyr::case_when(
      test_type == "PL" ~ 0.9,
      test_type == "LL" ~ 0.95),
    G_w = water_G_s,
    numerator = (m_c / G_c) + (( (w / G_w) + ( (w /G_w) * (1 -effective_saturation) / effective_saturation))),
    denominator = (m_sa / G_sa) + (m_c / G_c) + (( (w / G_w) + ( (w /G_w) * (1 -effective_saturation) / effective_saturation))),
    n_sa = numerator / denominator
  ) %>% 
  dplyr::mutate(
    sand_clean_name = dplyr::case_when(
      sand_name == "high_Cu_Quickcrete" ~ "High-C<sub>u</sub> sand",
      sand_name == "low_Cu_Quickcrete" ~ "Low-C<sub>u</sub> sand"),
    # test_type = forcats::fct_reorder(test_type, w, max, na.rm = TRUE))
    test_type = factor(test_type, levels = rev(c("PL", "LL"))))


# read porosity data 
porosity_df <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-sand-physical-properties-cleaned-data.rds"
) %>% 
  dplyr::mutate(
    n_sa = void_ratio / (1 + void_ratio),
    test_type = list(c("LL", "PL"))
  ) %>% 
  tidyr::unnest(test_type) %>% 
  dplyr::filter(sand_configuration == 'loose') %>%
  dplyr::select(sand_name, test_type, n_sa) %>% 
  dplyr::mutate(
    sand_clean_name = dplyr::case_when(
      sand_name == "high_Cu_Quickcrete" ~ "High-C<sub>u</sub> sand",
      sand_name == "low_Cu_Quickcrete" ~ "Low-C<sub>u</sub> sand"))



# build plot 
uniformity_experiment_sand_void_ratio_vs_sand_content <- n_sa_values %>% 
  ggplot(aes(m_sa, n_sa, color = test_type))+ # , group = sand_clean_name))+
  geom_point(, alpha = 2/3)+
  geom_smooth(formula = y~x, method = lm, se = F, size = 0.25)+
  geom_hline(data = porosity_df, aes(yintercept = n_sa, group = sand_clean_name),
             linetype = 'longdash', color = 'grey75')+
  geom_text(
    data = porosity_df, label = expression("   Max. pure sand"~n[sa]), aes( y = n_sa + 0.01 ), x = -Inf, size = 6/ .pt, vjust = 'bottom', hjust = 'inward', color = 'grey50')+
  scale_x_continuous(expression("Sand content, % g g"^-1), labels = scales::label_percent(accuracy = 1, suffix = ""), limits = c(0, 0.8), breaks = scales::breaks_width(0.2))+
  scale_y_continuous(expression(n[sa]~", m"^3*"m"^-3), breaks = scales::breaks_width(0.2), 
                     limits = c(0, 1))+
  scale_color_manual(values =  colorblindr::palette_OkabeIto[5:6])+
  labs(title = expression(bold(n[sa])~"as a function of sand content"))+
  coord_fixed(0.5)+
  facet_grid(test_type~sand_clean_name)+
  theme(legend.text = ggtext::element_markdown(),
        strip.text.y = ggtext::element_markdown(size = 32 / .pt, angle = 0),
        strip.text.x = ggtext::element_markdown(size = 32 / .pt, angle = 0),
        strip.background = element_blank(),
        legend.position = 'none')

save_fig(uniformity_experiment_sand_void_ratio_vs_sand_content)
