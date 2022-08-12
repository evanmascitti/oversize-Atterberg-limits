# apparently I can't use Make to save a kable as an .rds object because 
# the reference label seems to get lost, and bookdown won't recognize it. 
# the code below was for when I was trying to do that. 
# output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
# 
# cat("Building file:", output_file_path, "---------------------", 
#     sep = "\n\n")

# Instead, I'll just build the kable here and assign it as an object....
# then this gets sourced every time I compile an .Rmd document 
# which uses the table. 

# Not ultra-elegant, but it works and there isn't too much duplication, 
# I just have to change some options for each one. 

# This script always uses the here package to build file paths because 
# it is called by multiple .Rmd documents which live in different directories. 


# load packages 
suppressPackageStartupMessages({
  library(magrittr)
  library(kableExtra)})



# import d50 values for each sample 
d50_values <- readr::read_rds(
  here::here(
    'ecmdata/derived-data/dynamic-number-references/experiment-1-dx-values.rds')
)



usga_sand_sizes_table <- readr::read_csv(
  here::here('ecmdata/metadata/USGA-sieve-sizes.csv'),
  col_types = "iccccc"
) %>% 
  dplyr::left_join(d50_values, by = "expt_sand_number") %>% 
  dplyr::arrange(dplyr::desc(upper_mm)) %>% 
  tidyr::unite(upper_mm, lower_mm,
               col = "size_range",
               sep = " - ") %>% 
  dplyr::select(-expt_sand_number) %>% 
  dplyr::mutate(d50 = signif(d50, 2))

latex_usga_names <- c(
  "Size class",
  "Sub-class",
  "U.S. mesh sizes",
  "Range",
  "D\\textsubscript{50}"
 )

html_usga_names <- latex_usga_names
html_usga_names[5] <- "D~50~"


# build kable for output either as latex or html

usga_sand_sizes_latex_kable <- usga_sand_sizes_table %>% 
  kableExtra::kbl(format = 'latex',
                  booktabs = TRUE, 
                  col.names = latex_usga_names,
                  caption = "USGA particle size classes used for Experiment 1.",
                  align = 'llcll',
                  escape = FALSE,
                  digits = 2) %>% 
  kableExtra::collapse_rows(columns = 1, latex_hline = 'major') %>% 
  kableExtra::add_header_above(header = c(" " = 3, "Sieve diameter (mm)" = 2)) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::kable_styling()


usga_sand_sizes_html_kable <- usga_sand_sizes_table %>% 
  kableExtra::kbl(format = 'html',
                  col.names = html_usga_names,
                  caption = "USGA particle size classes used for Experiment 1.",
                  align = 'llcll',
                  digits = 2) %>% 
  kableExtra::collapse_rows(columns = 1) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::kable_styling()


# for word output 

usga_sand_sizes_word_table <- flextable::flextable(as.data.frame(usga_sand_sizes_table))
