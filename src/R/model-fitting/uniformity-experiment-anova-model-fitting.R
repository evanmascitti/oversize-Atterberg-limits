
# this script fits a two-way linear model with interaction and runs an ANOVA 
# test with type III Sums of Squares for the uniformity experiment.

# It does not use splines as the shape of the relationship appears pretty
# much linear until 70% sand, above which it is debatable whether 
# a new line should be fit or if there is a curve

library(magrittr)

# take command line argument for output

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

cat("----------------------------------------", 
    "Building model file:", 
    output_file_path, 
    "----------------------------------------", 
    sep = "\n")


# read data

uniformity_experiment_data <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds') %>%
  dplyr::filter(!is.na(water_content))

# fit model to test the effects of sand % and angularity
 # write function so it can be applied to subsets of the data, i.e. 
# for each characteristic water content 

fit_uniformity_experiment_model <- function(x){

  crossed_lm <- na.omit(lm(
  data = x,
  formula = water_content ~ sand_pct * sand_name
)
)
  
}

# split-apply-combine 
model_args <- uniformity_experiment_data %>% 
  split(~test_type) %>% 
  tibble::enframe(name = "test_type",
                  value = "x")
  
models <- purrr::map(model_args$x, fit_uniformity_experiment_model) %>% 
  purrr::set_names(paste("uniformity_experiment", model_args$test_type, "model", sep = "_"))

readr::write_rds(
  x = models,
  file = output_file_path
)

