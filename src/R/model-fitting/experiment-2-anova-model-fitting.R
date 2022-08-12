
# this fits a two-way linear model with interaction and runs an ANOVA 
# test with type III Sums of Squares

library(magrittr)

# take command line argument for output

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

cat("----------------------------------------", 
    "Building model file:", 
    output_file_path, 
    "----------------------------------------", 
    sep = "\n")


# read data

experiment_2_data <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/experiment-2-atterberg-limits-cleaned-data.rds') %>% 
  dplyr::mutate(
    sand_shape = dplyr::case_when(
      coarse_name == "Mancino_angular" ~ "angular",
      coarse_name == "Granusil_4095" ~ "round",  
    )) %>% 
  dplyr::filter(!is.na(water_content))

# fit model to test the effects of sand % and angularity
 # write function so it can be applied to subsets of the data, i.e. 
# for each characteristic water content 

fit_experiment_2_model <- function(x){

  crossed_lm <- na.omit(lm(
  data = x,
  #formula =  water_content ~ coarse_pct + sand_shape
  formula = water_content ~ splines::ns(coarse_pct, 2) * sand_shape
)
)
}

# split-apply-combine 
model_args <- experiment_2_data %>% 
  split(~test_type) %>% 
  tibble::enframe(name = "test_type",
                  value = "x")
  
models <- purrr::map(model_args$x, fit_experiment_2_model) %>% 
  purrr::set_names(paste("experiment_2", model_args$test_type, "model", sep = "_"))

readr::write_rds(
  x = models,
  file = output_file_path
)


# tidyr::crossing(
#   d50 = c(0.01, 0.1, 1, 10),
#   coarse_pct = seq(0.1, 0.8, 0.1),
#   test_type = c("Liquid\nlimit", "Plastic\nlimit")
#   ) %>% 
#   modelr::add_predictions(model = crossed_lm) %>% 
#   ggplot(aes(d50, pred, 
#              color = factor(coarse_pct),
#              ))+
#   geom_point()+
#   geom_smooth(method = 'lm', formula = y~splines::ns(x,2), se = F, size = 0.25)+
#   scale_x_continuous(trans = 'log10')+
#   facet_grid(test_type~coarse_pct)

