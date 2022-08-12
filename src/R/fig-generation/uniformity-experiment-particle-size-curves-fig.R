# This script creates a plot directly from raw data....because the calculations 
# are simple and handled by soiltestr, no need to make an intermediate data file.
# Just ensure that the dependencies are properly stated with the makefile. 

# setup, enure soiltestr can find correct equipment by setting options
library(soiltestr)
library(ggplot2)
library(soiltestr)

options(
  soiltestr.beaker_tares = asi468::psa_beaker_tares,
  soiltestr.tin_tares = asi468::tin_tares
)

# wrangle the percent passing for the two sands 
sand_percent_passing_data <- psa(dir = './ecmdata/raw-data/uniformity-experiment/psa-data_2020-06-21/',
    tin_tares = asi468::tin_tares,
    beaker_tares = asi468::psa_beaker_tares) %>% 
  purrr::pluck("cumulative_percent_passing") %>% 
  dplyr::filter(stringr::str_detect(sample_name, "Quickcrete_(high|low)_Cu")) %>% 
  dplyr::mutate(
    sample_name = stringr::str_remove(sample_name, pattern ="Quickcrete"),
    sample_name = stringr::str_trim(
      stringr::str_to_title(
        stringr::str_replace_all(
          sample_name,
          pattern ="_",
          replacement = " ")))
      )


# wrangle the percent passing data for the clay 

clay_percent_passing_data <- psa(dir = './ecmdata/raw-data/uniformity-experiment/psa-data_2021-03-06/')$averages$cumulative_percent_passing

# add colors....commenting out code for two browns which are similar 
# to sand colors....however, the two sands are really the _same_
# color and this might be misleading....better to just use the same 
# OkabeIto scale as for the LL and PL figure that appears later....using the regular OkabeIto for PSA curves in experiments 1 and the LL/PL plots in experient 2... so probably best to stay away from those same colors for experiment 3. 

hex_colors_df <- tibble::tribble(
  ~sample_name, ~color,
  "Low Cu", colorblindr::palette_OkabeIto[6],
  "High Cu",colorblindr::palette_OkabeIto[5],
  "Casselman_clay", "#A57251"
)


all_samples_percent_passing <- 
  dplyr::bind_rows(sand_percent_passing_data,
                   clay_percent_passing_data) %>% 
  dplyr::left_join(hex_colors_df, by = 'sample_name')

curve_labels_data <- tibble::tibble(
  x = c(6, 270, 3000),
  y = c(0.3, 0.7, 0.85),
  sample_name = c("Casselman_clay", "Low Cu", "High Cu"),
  text = c(
    expression("Illitic clay"~""),
    expression("Low"~C[u]~"sand "),
    expression("High"~C[u]~"sand")
    
  )) %>% 
  dplyr::left_join(hex_colors_df, by = 'sample_name')


# version for using arrows 
# curve_labels_data <- tibble::tibble(
#    x = c(8, 200, 3500),
#    y = c(0.3, 0.65, 0.75),
#    text = c(
#      expression("Illitic clay"~""),
#      expression("Low"~C[u]~"sand "),
#      expression("High"~C[u]~"sand")
#      ),
#    color = c("#A57251", "#AE8F60", "#4A211A"))
   

# arrows_data <- curve_labels_data %>% 
#   dplyr::mutate(
#     x = c(4.5, 400, 2000),
#     xend = c(3.5, 450, 1500),
#     yend = y)


d_50_segments_df <- readr::read_rds('./ecmdata/derived-data/dynamic-number-references/uniformity-experiment-dx-values.rds') %>% 
  purrr::pluck("uniformity_experiment_d_50_values") %>% 
  tibble::enframe(name = "sample_name", value = "d_50") %>% 
  dplyr::rename(x= d_50) %>% 
  dplyr::mutate(x = 1000*x) %>% 
  dplyr::mutate(xend = x,
                y=-Inf,
                yend = 0.5)
   
   
uniformity_experiment_particle_size_curves <- all_samples_percent_passing %>% 
  ggpsd(color  = color, group = sample_name, log_lines = T, bold_log_lines = F)+
  guides(color = guide_legend(title = NULL))+
  geom_hline(yintercept = 0.5, color = 'grey70', size = 0.3)+
  ggplot2::geom_segment(
    data = d_50_segments_df,
    inherit.aes = FALSE,
    aes(
      y = y,
      yend = yend,
      x = x,
      xend = xend),
    color = 'grey70',
    linetype = 'dashed',
    size = 0.3
    )+
  geom_text(data = curve_labels_data, 
             inherit.aes = FALSE,
             aes(x =x , y=y, 
                 label = text, 
                 color = color),
             parse = TRUE,
            size   = 2.5)+
  # geom_segment(
  #   data = arrows_data,
  #   inherit.aes = FALSE,
  #   aes(x =x,
  #       xend = xend,
  #       y= y, 
  #       yend =yend,
  #       color = color),
  #   arrow = arrow(length = unit(0.05, "in"),
  #                 angle = 20,
  #                 type = 'closed'))+
  scale_color_identity()

uniformity_experiment_particle_size_curves$labels$title <- "PSD of mix components - uniformity experiment"  

if(interactive()){print(uniformity_experiment_particle_size_curves)}

ecmfuns::save_fig(uniformity_experiment_particle_size_curves)
