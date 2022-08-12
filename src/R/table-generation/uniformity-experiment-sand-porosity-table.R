
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

# compute dry density of the sand packed in a dry condition using a single lift with the ASTM F1815 compactor (I think 15 blows??)

# for air-dry sand, assume water content of 0.1% i.e. 0.001

data_path <- here::here('ecmdata/raw-data/uniformity-experiment/F1815-cylinders-data')

raw_compaction_data <-  list.files(
  path = data_path,
  pattern = 'uniformity-experiment.*\\.csv$',
  full.names = TRUE) %>%
  purrr::map(readr::read_csv, na = "-",
             col_types = 'icciiccicdddiddi') %>% 
  dplyr::bind_rows() %>% 
  dplyr::select(-experiment_number)

results <- raw_compaction_data %>% 
  dplyr::left_join(asi468::pvc_perc_cylinders, by = 'cylinder_ID') %>% 
  dplyr::mutate(sand_only = filled_wt / 1.001,
                dry_density = sand_only / (ht_cm * area_cm2)) %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::mutate(porosity = 1 - (dry_density / 2.65))

n_reps <- results %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::count() %>% 
  purrr::pluck('n') %>% 
  unique()

# fit models to get parameter estimates for each test x sample combo
# (these are just the means for this simple test )

pooled_sds <- results %>% 
  dplyr::mutate(sand_configuration2 = sand_configuration) %>% 
  dplyr::group_by(sand_configuration2) %>% 
  tidyr::nest() %>% 
  dplyr::mutate(
    model = purrr::map(data, ~lm(data = ., formula = porosity ~ sand_name)),
    pooled_sd = purrr::map_dbl(model, sigma)
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::transmute(sand_configuration = sand_configuration2,
                   pooled_sd = pooled_sd)

# check assumption of homogeneity of variance with Levene test 
#str(car::leveneTest(model))
#car::leveneTest(model)[["Pr(>F)"]]
# it's p = 0.271, so ok to use pooled standard deviation 

# pooled_porosity_sd <- sigma(model)

formatted_summary <- results %>% 
  dplyr::group_by(sand_name, sand_configuration) %>% 
  dplyr::summarize(
    dplyr::across(
      .cols = c(dry_density, porosity),
      .fns = list(mean = ~sprintf(mean(., na.rm = TRUE), fmt = "%.2f")),
      .names = "{.fn}_{.col}"
    ) ,
    .groups = 'drop') %>% 
  dplyr::left_join(pooled_sds, by = 'sand_configuration') %>% 
  dplyr::mutate(se_porosity = signif(pooled_sd / sqrt(n_reps), digits = 1))

names_lookup <- tibble::tibble(
  sand_name = c("high_Cu_Quickcrete", "low_Cu_Quickcrete"),
  clean_sand_name = c("High-Cu", "Low-Cu")
)

porosity_table <- formatted_summary %>% 
  dplyr::mutate(porosity = paste(mean_porosity,
                                    "\u00b1",
                                    2 * se_porosity)) %>% 
  dplyr::left_join(names_lookup, by = 'sand_name') %>% 
  dplyr::ungroup() %>% 
  dplyr::select(clean_sand_name, sand_configuration, porosity) %>% 
  dplyr::arrange(dplyr::desc(clean_sand_name)) %>%
  tidyr::pivot_wider(names_from = sand_configuration, values_from = porosity) %>% 
  dplyr::select(clean_sand_name, loose, dense)

# build kable objects -----------------------------------------------------

# these are the same but I'm leaving the code as-is, because it allows 
# me to easily change the caption later if I want 

latex_caption <- 'Minimum and maximum porosity values for the two sands used in Experiment 3. Uncertainty values represent pooled standard error within each test method.'
html_caption <- 'Minimum and maximum porosity values for the two sands used in Experiment 3. Uncertainty values represent pooled standard error within each test method.'


# build kable for each format 
latex_kable <- porosity_table %>% 
  kableExtra::kbl(format = 'latex',
                  caption = latex_caption,
                  align = 'lcc',
                  booktabs = TRUE,
                  escape = FALSE,
                  col.names = c("Sand label", "$\\phi_{min}$", "$\\phi_{max}$")) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::add_header_above(header = c(" " = 1,
                                          "Total porosity (v/v)" = 2)) %>% 
  kableExtra::kable_styling(latex_options = 'basic')



html_kable <- porosity_table %>% 
  kableExtra::kbl(format = 'html',
                  align = 'lcc',
                  caption = html_caption,
                  col.names = c("Sand label", "\u03d5 (min)", "\u03d5 (max)")) %>% 
  kableExtra::row_spec(row = 0, bold = TRUE) %>% 
  kableExtra::add_header_above(header = c(" " = 1,
                                          "Total porosity (v/v)" = 2)) %>% 
  kableExtra::kable_styling()


uniformity_experiment_sand_porosity_tables <- list(latex_kable = latex_kable,
                                  html_kable = html_kable)

# remove other objects to prevent clutter in environment where 
# this script is sourced

rm(list = ls(pattern = "[^uniformity_experiment_sand_porosity_tables]"))

# ls()

########

