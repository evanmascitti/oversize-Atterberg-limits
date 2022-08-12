library(ggplot2)
library(purrr)
theme_set(ecmfuns::theme_ecm_bw())


x <- readr::read_rds(file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds")


experiment_1_PIs <- x %>% 
  dplyr::filter(test_type == "PI") %>% 
  ggplot(aes(coarse_size, water_content))+
  geom_point()+
  geom_smooth(se= F, methodl =lm, formula = y~x)+
  facet_wrap(~coarse_pct)

ecmfuns::save_fig(experiment_1_PIs)

