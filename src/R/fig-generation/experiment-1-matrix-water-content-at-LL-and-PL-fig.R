# find matrix water content at PL for each mix in Experiment 1 

source("./src/R/helpers/oversizeALims-utils.R")
library(purrr)
library(ggplot2)
theme_set(ecmfuns::theme_ecm_bw())

att_lims <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-atterberg-limits-cleaned-data.rds"
) %>% 
  dplyr::filter(
   # coarse_name %in% c('Mancino_angular', 'Flint_325_Sil-co-sil_52'),
    test_type %in% c("PL", "LL")) %>% 
  dplyr::mutate(
    matrix_water_content = water_content / (1-coarse_pct),
    coarse_size = paste(coarse_size, "mm"),
    # test_type = forcats::fct_reorder(test_type, water_content, .desc = F)
    test_type = factor(test_type, levels = rev(c("LL", "PL")))
  )

# att_lims %>% 
#   ggplot(aes(coarse_pct, matrix_water_content, color = test_type))+
#   geom_point()+
#   facet_wrap(~coarse_size)



pure_clay_LL <- att_lims %>% 
    dplyr::filter(
      dplyr::near(coarse_pct, 0),
      test_type == "LL") %>% 
  dplyr::select(coarse_size, test_type, water_content) %>% 
  dplyr::distinct()

pure_clay_PL <- att_lims %>% 
  dplyr::filter(
    dplyr::near(coarse_pct, 0),
    test_type == "PL") %>% 
  dplyr::select(coarse_size, test_type, water_content) %>% 
  dplyr::distinct()


experiment_1_matrix_water_content_at_LL_and_PL <- att_lims %>% 
  ggplot(aes(coarse_pct, matrix_water_content, color = test_type))+
  geom_hline(data = pure_clay_LL, 
             aes(yintercept = water_content,
                 color = test_type),
             alpha = 1/2,
             linetype = 'longdash') +
  geom_hline(data = pure_clay_PL, 
             aes(yintercept = water_content,
                 color = test_type),
             alpha = 1/2,
             linetype = 'longdash')+
  geom_point(alpha = 1 / 2) +
  scale_x_continuous(
    expression('Coarse addition mass, g g' ^ 1 ~ "" %*% 100),
    labels = scales::label_percent(accuracy = 1, suffix = "")
  ) +
  scale_y_continuous(
    expression('Matrix water content, g g' ^ 1 ~ "" %*% 100),
    labels = scales::label_percent(accuracy = 1, suffix = "")
  ) +
  # colorspace::scale_color_discrete_diverging(palette = "Blue-Red")+
  colorblindr::scale_color_OkabeIto() +
  guides(color = guide_legend("Test type")) +
  labs(title = "Matrix water content of soil mixtures at LL and PL.")+
  facet_wrap(~coarse_size)

save_fig(
  plot = experiment_1_matrix_water_content_at_LL_and_PL
)
