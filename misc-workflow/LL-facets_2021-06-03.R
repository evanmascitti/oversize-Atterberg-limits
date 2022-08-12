# adapt this to fit the cleaned data set, i.e. for other limits in addition to
# the LL

all_mancino_LL_values %>% 
  dplyr::filter(!stringr::str_detect(coarse_name, "Granusil")) %>% 
  ggplot2::ggplot(ggplot2::aes(
    coarse_pct, LL, color = coarse_size))+
  ggplot2::geom_point()+
  ggplot2::geom_smooth(method = 'lm', formula = y~splines::ns(x, 2), 
                       se = FALSE)+
  ggplot2::theme_classic()+
  ggplot2::facet_wrap(facets = ~coarse_size, nrow = 1)
