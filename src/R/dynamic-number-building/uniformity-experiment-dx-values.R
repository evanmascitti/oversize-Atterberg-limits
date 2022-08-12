# This script plots the particle size distributions for the 
# Quickcrete sands and chooses their D 60 and D 10 values,
# then computes the Cu for each sand. 

# The output is a named list. It contains the characteristic diameters and Cu
# value for the particular sand. 


# take command line argument for output file 

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

# this code is copied from the fig building script, to visually 
# examine the PSD curves 

library(magrittr)
library(soiltestr)
library(ggplot2)

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

all_samples_percent_passing <- 
  dplyr::bind_rows(sand_percent_passing_data,
                   clay_percent_passing_data) %>% 
  dplyr::mutate(
    color  = dplyr::case_when(
      sample_name == "High Cu" ~ "#4A211A",
      sample_name == "Low Cu" ~ "#AE8F60",
      sample_name == "Casselman_clay" ~ "#A57251",
    ))

curve_labels_data <- tibble::tibble(
  x = c(7, 250, 3000),
  y = c(0.3, 0.7, 0.8),
  text = c(
    expression("\u2190 Illitic clay"~""),
    expression("\u2192"~C[u]~"sand --- "),
    expression("\u2190 High"~C[u]~"sand")
  ),
  color = c("#A57251", "#AE8F60", "#4A211A"))


d_50_segments_df <- readr::read_rds('./ecmdata/derived-data/dynamic-number-references/uniformity-experiment-dx-values.rds') %>% 
  purrr::pluck("uniformity_experiment_d_50_values") %>% 
  tibble::enframe(name = "sample_name", value = "d_50") %>% 
  dplyr::rename(x= d_50) %>% 
  dplyr::mutate(x = 1000*x) %>% 
  dplyr::mutate(xend = x,
                y=-Inf,
                yend = 0.5)


uniformity_experiment_particle_size_curves <- all_samples_percent_passing %>% 
  ggpsd(color  = color, group = sample_name)+
  guides(color = guide_legend(title = NULL))+
  geom_hline(yintercept = 0.50, color = 'grey70')+
  geom_text(data = curve_labels_data, 
            inherit.aes = FALSE,
            aes(x =x , y=y, 
                label = text, color = color),
            parse = TRUE,
            size   = 3)+
  scale_color_identity()

uniformity_experiment_particle_size_curves$labels$title <- "Mix component particle size distributions - Experiment 3" 

# guess at the diameters and draw lines based on these visual assessments
# of the line intersections
uniformity_experiment_particle_size_curves+
  ggplot2::geom_vline(xintercept = c(425, 490 ))

# yep, these look pretty good. 
# try log-linear interpolation to do it programatically/reproducibly

# compute d_x values  ---------------------------------------------------


# Now set the data frame of interest to the data which I already 
# used to make the plot above. 

uniformity_experiment_sand_psds <- uniformity_experiment_particle_size_curves$data


# Here is where I actually compute the values after looking @ the plot:


# the commented-out code below is moot because I wrote a function
# to do this action for any particle diameter....not generalizable 
# to any soils, but because the d10 and d60 for these samples 
# lie between the same particle diameters it works here and reduces 
# duplication 

# d_50_split_df_mods <- uniformity_experiment_sand_psds$data %>%
#   dplyr::filter(microns %in% c(250, 500),
#   stringr::str_detect(sample_name , "Cu$")) %>%
#   split(~sample_name) %>%
#   purrr::map(~lm(data = ., formula = microns ~ I(10^percent_passing)))
# d_50_split_df_mods
# 
# purrr::map(.x = d_50_split_df_mods, .f = predict.lm, new_data = data.frame(percent_passing = 0.5))

# for some reason I can't get this to work with a functional. 
# Just do them one at a time 

# high_Cu_d_50 <- predict.lm(object = d_50_split_df_mods[["High Cu"]], newdata = data.frame(percent_passing = 0.5))
# low_Cu_d_50 <- predict.lm(object = d_50_split_df_mods[["Low Cu"]], newdata = data.frame(percent_passing = 0.5))
# 
# uniformity_experiment_d_50_values <- list(high_Cu_d_50 = high_Cu_d_50,
#                                  low_Cu_d_50 =low_Cu_d_50)
# 
# # choose D 10 and D 60 also; D 10 should occur between 150 and 200 microns 
# d_10_split_df_mods <- uniformity_experiment_psds$data %>%
#   dplyr::filter(microns %in% c(150, 250),
#                 stringr::str_detect(sample_name , "Cu$")) %>%
#   split(~sample_name) %>%
#   purrr::map(~lm(data = ., formula = microns ~ I(10^percent_passing)))
# 
# high_Cu_d_10 <- predict.lm(object = d_50_split_df_mods[["High Cu"]], newdata = data.frame(percent_passing = 0.1))
# low_Cu_d_10 <- predict.lm(object = d_50_split_df_mods[["Low Cu"]], newdata = data.frame(percent_passing = 0.1))

get_d_x_pct_passing <- function(df, microns_range, d_x){

  # browser()
  
  d_x_split_df_mods <- df %>%
  dplyr::filter(microns %in% microns_range,
                stringr::str_detect(sample_name , "Cu$")) %>%
  split(~sample_name) %>%
  purrr::map(~lm(data = ., formula = microns ~ I(10^percent_passing)))

assign(x = paste0("high_Cu_d_", 100*d_x),
        value = predict.lm(object = d_x_split_df_mods[["High Cu"]],
                           newdata = data.frame(percent_passing = d_x))
 )

assign(x = paste0("low_Cu_d_", 100*d_x),
       value = predict.lm(object = d_x_split_df_mods[["Low Cu"]],
                          newdata = data.frame(percent_passing = d_x))
)


return_vector <- unlist(mget(x = ls(pattern = "(high|low)_Cu"), envir = rlang::current_env())       )

return(return_vector)
}


# create tibble of arguments over which to iterate 
cu_args <- tibble::tibble(
  df = purrr::rerun(.n = 3, dplyr::filter(uniformity_experiment_sand_psds, sample_name != "Casselman_clay")),
  microns_range = list(
    c(150, 250),
    c(250, 500),
    c(500, 1000)
    ),
    d_x = c(0.1, 0.5, 0.6)
  )


# run function for all 3 characteristic diameters of interest 
characteristic_diameters <- purrr::pmap(
  cu_args, 
  get_d_x_pct_passing) %>% 
  purrr::set_names(nm = paste0("d_", 100*cu_args$d_x)) %>% 
  tibble::as_tibble() %>% 
  dplyr::mutate(
    sample_name = stringr::str_extract(
      names(d_10), 
      "(low|high)_Cu")) %>% 
  dplyr::relocate(sample_name, 
                  .before = dplyr::everything())

# there is one exception that needs to be fixed: the d_10 value for the low Cu
# sand does not fall within the same range as that of the d_10 value for the 
# high Cu sand. 

# re-compute this value and insert it into the characteristic diameters tibble

low_Cu_d_10_corrected <- get_d_x_pct_passing(
  df = dplyr::filter(uniformity_experiment_sand_psds, sample_name != "Casselman_clay"),
  microns_range = c(250, 500),
  d_x = 0.1)[["low_Cu_d_10.1"]]

characteristic_diameters[characteristic_diameters$sample_name == "low_Cu", ]$d_10 <- low_Cu_d_10_corrected

characteristic_diameters_w_corrected_Cu_values <- characteristic_diameters  %>% 
  dplyr::mutate(Cu = d_60 /d_10)


# create named character vector containing Cu values 
uniformity_experiment_Cu_values <- purrr::set_names(
  signif(
    characteristic_diameters_w_corrected_Cu_values[["Cu"]], 
  2),
  characteristic_diameters_w_corrected_Cu_values[["sample_name"]])
  


# create data frame to show D50 values 
uniformity_experiment_d_50_values <- signif(
  0.001 * purrr::set_names(
    characteristic_diameters_w_corrected_Cu_values[["d_50"]],
    characteristic_diameters_w_corrected_Cu_values[["sample_name"]]),
  2)


# save results as a list 
output_list <- list(
  uniformity_experiment_Cu_values = uniformity_experiment_Cu_values,
  uniformity_experiment_d_50_values = uniformity_experiment_d_50_values
)

cat("Output d_x values are:")

print(output_list)

# write to disk
readr::write_rds(
  output_list,
  output_file_path
)
