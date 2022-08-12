
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


# read data and filter out adhesion limit data

experiment_1_data <- readr::read_rds(
  './ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds'
) %>% 
  dplyr::filter(test_type != "AL")

# fit model to test the effect 
 
crossed_lm <- lm(
  data = experiment_1_data,
  formula = linear_law_deviation ~ I(log10(d50)^2) * coarse_pct
)

readr::write_rds(
  x = crossed_lm,
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

