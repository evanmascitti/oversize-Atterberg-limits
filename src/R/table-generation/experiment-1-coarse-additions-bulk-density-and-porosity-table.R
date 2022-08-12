# makes a table of dry density and total porosity, 
# decided not to include error/tolerances for a cleaner look 
# and because they are not really necessary for these 
# characterization data 



library(kableExtra)
library(purrr)

summarized_f1815_data <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiments-1-and-2-coarse-additions-bulk-density-and-porosity-cleaned-data.rds")


f1815_tibble <-  summarized_f1815_data %>% 
  dplyr::select(sand_size, test_type, total_porosity_mean) %>% 
  dplyr::mutate(total_porosity_mean = sprintf(total_porosity_mean, fmt = "%.2f")) %>% 
  tidyr::pivot_wider(names_from = test_type, values_from = total_porosity_mean)


latex_caption <- 'Minimum and maximum porosity values for the coarse additions used in Experiment 1. '
html_caption <- 'Minimum and maximum porosity values for the coarse additions used in Experiment 1.'

# build kable for each format
latex_kable <- f1815_tibble %>%
  kableExtra::kbl(format = 'latex',
                  caption = latex_caption,
                  align = 'lcc',
                  booktabs = TRUE,
                  escape = FALSE,
                  col.names = c("Size range", "$\\phi_{min}$", "$\\phi_{max}$")) %>%
  kableExtra::row_spec(row = 0, bold = TRUE) %>%
  kableExtra::add_header_above(header = c(" " = 1,
                                          "Total porosity (v/v)" = 2)) %>%
  kableExtra::kable_styling(latex_options = 'basic')



html_kable <- f1815_tibble %>%
  kableExtra::kbl(format = 'html',
                  align = 'lcc',
                  caption = html_caption,
                  col.names = c("Size range", "\u03d5 (min)", "\u03d5 (max)")) %>%
  kableExtra::row_spec(row = 0, bold = TRUE) %>%
  kableExtra::add_header_above(header = c(" " = 1,
                                          "Total porosity (v/v)" = 2)) %>%
  kableExtra::kable_styling()

experiment_1_f1815_word_table <- f1815_tibble 

experiment_1_porosity_tables <- list(
  latex_kable = latex_kable,
  html_kable = html_kable,
  word_table = experiment_1_f1815_word_table)


# remove extra objects to reduce clutter in environment

all_objects <- ls()

keep_objects <- c(
  "experiment_1_porosity_tables"
  )

rm(list = c(all_objects[! all_objects %in% keep_objects], "all_objects", "keep_objects"))

