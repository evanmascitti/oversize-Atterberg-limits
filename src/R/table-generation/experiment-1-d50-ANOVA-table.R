# This script gets sourced every time I compile an .Rmd document 
# which uses the table. 

# Not ultra-elegant, but it works and there isn't too much duplication, 
# I just have to change some options to go between LaTeX and HTML. 

# This script always uses the here package to build file paths because 
# it is called by multiple .Rmd documents which live in different directories. 


# load packages 
library(magrittr)
library(kableExtra)
source(here::here("src/R/helpers/oversizeALims-utils.R"))



# import data 
model_object <- readr::read_rds(
  here::here(
    'ecmdata/derived-data/models/experiment-1-d50-effect-size-model.rds')
)

latex_caption <- 'Analysis of variance table for the \\% coarse addition x D\\textsubscript{50} linear model. Significant effects at p=0.05 in bold.'
html_caption <- 'Analysis of variance table for the percent coarse addition x D~50~ linear model. Significant effects at p=0.05 in bold.'


tidy_anova_table <- car::Anova(mod = model_object, type = 3) %>% 
  broom::tidy(model_object)

# build kable for output either as latex or html

latex_kable <- format_anova_table(
  mod = model_object, 
  type = 3,
  terms = c("Intercept",
            "log\\textsubscript{10}(D\\textsubscript{50})\\textsuperscript{2}",
            "\\% coarse addition",
            "log\\textsubscript{10}(D\\textsubscript{50})\\textsuperscript{2} x \\% coarse addition",
            "Residual error"),
  caption = latex_caption)

# latex_kable <- tidy_anova_table %>% 
#   dplyr::mutate(
#     term = 
#       c("Intercept",
#         "log\\textsubscript{10}(D\\textsubscript{50})\\textsuperscript{2}",
#         "\\% coarse addition",
#         "log\\textsubscript{10}(D\\textsubscript{50})\\textsuperscript{2} x \\% coarse addition",
#         "Residual error")
#   ) %>% 
#   dplyr::mutate(
#     statistic = format(sumsq, digits = 1),
#     sumsq = format(sumsq, digits = 2, drop0trailing = TRUE),
#     p.value = dplyr::if_else(
#       p.value < 0.001,
#       "<0.001",
#       format(p.value, digits = 3, drop0trailing = FALSE)
#     )) %>% 
#   dplyr::rename(Term = term, `Sum of sq.` = sumsq,
#                 `Deg. of Fr.` = df,
#                 `F-statistic` = statistic, `p-value` = p.value) %>% 
#   # pixiedust::dust() %>% 
#   # pixiedust::sprinkle(cols = c("sumsq", "meansq", "statistic"), round = 2 ) %>% 
#   # pixiedust::sprinkle(cols = "p.value", fn = quote(pixiedust::pval_string(value))) %>% 
#   kableExtra::kbl(format = 'latex',
#                   escape = FALSE,
#                   booktabs = TRUE,
#                   caption= latex_caption, 
#                   col.names = c("Term", "Sum Sq.", "Deg. of Fr.",  "F-Statistic", "P-value")) %>% 
#   row_spec(row = c(0, 3, 4), bold = TRUE) %>% 
#   kableExtra::kable_styling(latex_options = 'basic')


html_kable <- tidy_anova_table %>% 
  dplyr::mutate(
    term = 
      c("Intercept",
        "log~10~(D~50~)^2^",
        "Pct. coarse addition",
        "log~10~(D~50~)^2^ x Pct. coarse addition",
        "Residual error")
  ) %>% 
  pixiedust::dust() %>% 
  pixiedust::sprinkle(cols = c("sumsq", "meansq", "statistic"), round = 2 ) %>% 
  pixiedust::sprinkle(cols = "p.value", fn = quote(pixiedust::pval_string(value))) %>% 
  kableExtra::kbl(format = 'html',
                  caption= html_caption, 
                  col.names = c("Term", "Deg. of Fr.", "Sum Sq.", "F-Statistic", "P-value")) %>% 
  row_spec(row = c(0, 3, 4), bold = TRUE) %>% 
  kableExtra::kable_styling()

# for word 

word_flextable <- tidy_anova_table %>% 
  purrr::set_names(c("Term", "Deg. of Fr.", "Sum Sq.", "F-Statistic", "P-value")) %>% 
  flextable::flextable()
# %>% 
# this seems to erase the table contents so not using 
# word_flextable <- flextable::bold(word_flextable, i = 3)
# word_flextable <- flextable::bold(word_flextable, i = 5)

  
experiment_1_d50_anova_tables <- list(latex_kable = latex_kable,
                                      html_kable = html_kable,
                                      word_flextable = word_flextable)





# remove other objects to prevent clutter in environment where 
# this script is sourced

rm(list = ls(pattern = "[^experiment_1_d50_anova_tables]"))

ls()

