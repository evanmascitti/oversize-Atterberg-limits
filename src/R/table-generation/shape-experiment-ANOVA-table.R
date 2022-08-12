# This script gets sourced every time I compile an .Rmd document 
# which uses the table. 

# Not ultra-elegant, but it works and there isn't too much duplication, 
# I just have to change some options to go between LaTeX and HTML. 

# This script always uses the here package to build file paths because 
# it is called by multiple .Rmd documents which live in different directories. 


# load packages 
suppressPackageStartupMessages({
  library(magrittr)
  library(kableExtra)})



# import data 
model_objects <- readr::read_rds(
  here::here(
    'ecmdata/derived-data/models/experiment-2-anova-model.rds')
)

# these are the same but I'm leaving the code as-is, because it allows 
# me to easily change the caption later if I want 

latex_caption <- 'Analysis of variance table for each characteristic water content in Experiment 1.'
html_caption <- 'Analysis of variance table for each characteristic water content in Experiment 1.'

# for now I have decided not to include the AL data. 
# However if I change my mind, 
# I think the code is flexible enough to just remove the 
# filter statement below and also adjust the row packing statements # in the kable calls, and it should all update.


tidy_anova_tables <- purrr::map(.x = model_objects,
                               .f = car::Anova,
                               type = 3) %>% 
  purrr::map(broom::tidy) %>% 
  tibble::enframe(name = 'test_type') %>% 
  dplyr::mutate(test_type = stringr::str_extract(test_type, "(?<=experiment_2_)[ALP]L")) %>% 
  tidyr::unnest(value) %>% 
  dplyr::filter(test_type != "AL")

latex_term_column <-  rep(
  c(
  "Intercept",
  "\\% coarse addition",
  "Shape",
  "\\% coarse addition x Shape",
  "Residuals"),
  times = length(unique(tidy_anova_tables$test_type)))

html_term_column <-  rep(
  c(
    "Intercept",
    "% coarse addition",
    "Shape",
    "% coarse addition x Shape",
    "Residuals"),
  times = length(unique(tidy_anova_tables$test_type)))


# build kable for each format 
latex_kable <- tidy_anova_tables %>% 
  dplyr::mutate(
    term = latex_term_column,
    sumsq = round(sumsq, digits = 4),
    statistic = dplyr::case_when(
      is.na(statistic) ~ NA_character_,
      TRUE ~ as.character(round(statistic, digits = 1))),
    p.value = dplyr::case_when(
      p.value < 0.001 ~ "<0.001",
      is.na(p.value) ~ NA_character_,
      TRUE ~ as.character(signif(p.value, digits = 2))
    )) %>% 
  kableExtra::kbl(format = 'latex',
                  caption = latex_caption,
                  booktabs = TRUE,
                  escape = FALSE,
                  col.names = c("Test type", "Term", "Sum Sq.", "Deg. of Fr.", "F-Statistic", "P-value")) %>% 
  kableExtra::pack_rows(start_row = 1, end_row = 5, hline_after = TRUE) %>%
  kableExtra::pack_rows(start_row = 6, end_row = 10, hline_after = TRUE) %>%
  kableExtra::collapse_rows(columns = 1) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::kable_styling(latex_options = 'basic')
  


html_kable <- tidy_anova_tables %>% 
  # dplyr::mutate(term = html_term_column) %>%
  # pixiedust::dust() %>%
  # pixiedust::sprinkle(cols = c("statistic"), round = 2 ) %>%
  # pixiedust::sprinkle(cols = c("sumsq"), round = 4 ) %>%
  # pixiedust::sprinkle(cols = "p.value", fn = quote(pixiedust::pval_string(value))) %>%
  dplyr::mutate(
    term = html_term_column,
    sumsq = round(sumsq, digits = 4),
    statistic = dplyr::case_when(
      is.na(statistic) ~ NA_character_,
      TRUE ~ as.character(round(statistic, digits = 1))),
    p.value = dplyr::case_when(
      p.value < 0.001 ~ "<0.001",
      is.na(p.value) ~ NA_character_,
      TRUE ~ as.character(signif(p.value, digits = 2))
    )) %>% 
  kableExtra::kbl(format = 'html',
                  caption = html_caption,
                  col.names = c("Test type", "Term", "Sum Sq.", "Deg. of Fr.", "F-Statistic", "P-value")) %>% 
  #row_spec(row = c(0, 1, 2, 6, 7, 11, 12), bold = TRUE) %>% 
  kableExtra::pack_rows(start_row = 1, end_row = 5, hline_after = TRUE) %>%
  kableExtra::pack_rows(start_row = 6, end_row = 10, hline_after = TRUE) %>%
#  kableExtra::pack_rows(start_row = 11, end_row = 15, hline_after = TRUE) %>% 
  kableExtra::collapse_rows(columns = 1) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::kable_styling()


word_flextable <- tidy_anova_tables %>% 
  dplyr::mutate(term = html_term_column) %>% 
  # pixiedust::dust() %>% 
  # pixiedust::sprinkle(cols = c("statistic"), round = 2 ) %>%
  # pixiedust::sprinkle(cols = c("sumsq"), round = 4 ) %>% 
  # pixiedust::sprinkle(cols = "p.value", fn = quote(pixiedust::pval_string(value))) %>% 
  set_names(c("Test type", "Term", "Sum Sq.", "Deg. of Fr.", "F-Statistic", "P-value")) %>% 
  flextable::flextable()


shape_experiment_anova_tables <- list(
  latex_kable = latex_kable,
  html_kable = html_kable,
  word_flextable = word_flextable)

# remove other objects to prevent clutter in environment where 
# this script is sourced

rm(
  model_objects,
  latex_caption,
  html_caption,
  tidy_anova_tables,
  latex_term_column,
  html_term_column)

