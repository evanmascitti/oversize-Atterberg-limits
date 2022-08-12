# This script gets sourced every time I compile an .Rmd document 
# which uses the table. 

# Not ultra-elegant, but it works and there isn't too much duplication, 
# I just have to change some options to go between LaTeX and HTML. 

# This script always uses the here package to build file paths because 
# it is called by multiple .Rmd documents which live in different directories. 


# load packages 
library(purrr)
library(kableExtra)



# import data 
model_objects <- readr::read_rds(
  here::here(
    'ecmdata/derived-data/models/uniformity-experiment-anova-model.rds')
)



# this allows for different parsing for special characters, etc. 

latex_caption <- 'Analysis of variance table for each characteristic water content in Experiment 2. Significant effects at \u03b1=0.05 in bold.'
html_caption <- 'Analysis of variance table for each characteristic water content in Experiment 2. Significant effects at &alpha;=0.05 in bold.'

tidy_anova_tables <- purrr::map(.x = model_objects,
                               .f = car::Anova,
                               type = 3) %>% 
  purrr::map(broom::tidy) %>% 
  tibble::enframe(name = 'test_type') %>% 
  dplyr::mutate(test_type = stringr::str_extract(test_type, "(?<=uniformity_experiment_)[ALP]L")) %>% 
  tidyr::unnest(value)


latex_term_column <-  rep(
  c(
  "Intercept",
  "\\% sand",
  "Uniformity",
  "\\% sand x Uniformity",
  "Residuals"),
  times = length(unique(tidy_anova_tables$test_type)))

html_term_column <- latex_term_column
html_term_column[c(2, 7)] <- "% sand"
html_term_column[c(4, 9)] <- "% sand x Uniformity"

bold_rows <- tidy_anova_tables %>% 
  tibble::rownames_to_column() %>% 
  split(~test_type) %>% 
  map(dplyr::filter, p.value < 0.05) %>% 
  map("rowname") %>% 
  map(as.integer) %>% 
  unlist()


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
  


html_kable <-  tidy_anova_tables %>% 
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
  purrr::set_names(nm = c("Test type", "Term", "Sum Sq.", "Deg. of Fr.", "F-Statistic", "P-value")) %>% 
  flextable::flextable()

uniformity_experiment_tables <- list(
  latex_kable = latex_kable,
  html_kable = html_kable,
  word_flextable = word_flextable)


# remove extraneous objects so only the relevant anova table
# objects are returned, preventing clutter in environment where 
# this script is sourced

rm(model_objects,latex_caption , html_caption, 
   tidy_anova_tables, latex_term_column, 
   html_term_column)


