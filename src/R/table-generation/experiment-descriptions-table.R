# builds a table of metadata about each experiment 

library(purrr)
library(kableExtra)
source("./src/R/helpers/oversizeALims-utils.R")

expt_tbl <- readr::read_csv(
  file = "./ecmdata/metadata/experiment-descriptions.csv",
  show_col_types = F,
  lazy = F
)


expt_lines <- expt_tbl %>% 
  split(~Experiment) %>% 
  map_chr(nrow) %>% 
  cumsum()

latex_caption <- "Summary of variables tested and materials utilized for Experiments 1-3."
html_caption <- "Summary of variables tested and materials utilized for Experiments 1-3."

experiment_descriptions_latex_kable <- expt_tbl %>% 
  kbl(format = 'latex', booktabs = T, caption = latex_caption,
      col.names = c(
        "Experiment",	"Variable",	"Fines mineralogy",	"Dominant size range \\n of coarse addition (\\u03bcm)",
        "Range of coarse addition mass %"
        ),
      #escape = FALSE
      ) %>%
  column_spec(4, width = "5cm") %>% 
  collapse_rows(columns = c(1:3, 5)) %>% 
  row_spec(row = 0, bold = TRUE) %>% 
  row_spec(row = expt_lines, hline_after = TRUE) %>% 
  kable_styling(latex_options = c("hold_position"))
  


experiment_descriptions_html_kable <- expt_tbl %>% 
  kbl(format = 'html', booktabs = T, caption = html_caption) %>%
  column_spec(4, width = "5cm") %>% 
  collapse_rows(columns = c(1:3, 5)) %>% 
  row_spec(row = 0, bold = TRUE) %>% 
  row_spec(row = expt_lines, hline_after = TRUE) %>% 
  kable_styling()



experiment_descriptions_word_table <- expt_tbl 


# write to disk for debugging purposes

save_dummy_latex(x = experiment_descriptions_latex_kable,
                 name = 'experiment-descriptions-latex-kable')




# writeLines(
#   text = experiment_descriptions_latex_kable,
#   con = "./debugging/experiment-descriptions-latex-kable.tex"
# )
