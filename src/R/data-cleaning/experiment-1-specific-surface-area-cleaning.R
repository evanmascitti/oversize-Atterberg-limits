# computes specific surface area for each "coarse addition" in Experiment 1

library(purrr)


meta <- readr::read_csv(
  file = "./ecmdata/metadata/experiment-1-expt_sand_numbers-metadata.csv",
  show_col_types = F
) %>% 
  tidyr::unite(
    col = 'mm_range',
    c(upper_mm, lower_mm),
    sep = "-",
    remove = F
  ) %>% 
  dplyr::mutate(
    mean_diameter = (upper_mm + lower_mm) / 2
  )

psas <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/experiment-1-particle-size-curves-cleaned-data.rds") %>% 
  dplyr::left_join(meta, by = 'expt_sand_number') %>% 
  dplyr::filter(!is.na(mm_range)) %>% 
  dplyr::group_by(expt_sand_number) %>% 
  dplyr::mutate(
    pct_in_bin =  100 * (percent_passing - dplyr::lead(percent_passing)))

geometry_data <- psas %>% 
  dplyr::mutate(
    particle_diameter_mm = mean_diameter,
    particle_radius_mm = particle_diameter_mm / 2,
    particle_radius_cm = 0.1 * particle_radius_mm,
    particle_vol_cm3 = (4 / 3) * pi * (particle_radius_cm ^ 3),
    particle_surf_area_cm2 = 4 * pi * (particle_radius_cm ^ 2),
    Gs = 2.65,
    particle_mass = Gs * particle_vol_cm3,
    n_particles_per_g = 1 / particle_mass,
    surf_area_per_g = particle_surf_area_cm2 * n_particles_per_g,
    sa_contribution = (surf_area_per_g * pct_in_bin) ) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(expt_sand_number, particle_diameter_mm, n_particles_per_g, surf_area_per_g) %>% 
  dplyr::summarise(
    total_sa = sum(sa_contribution, na.rm = T),
    .groups = 'drop'
  ) %>% 
  dplyr::select(-expt_sand_number)


# write to disk

if(!interactive()){

  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  message("Building file: \n",
          output_file_path,
          "\n - - - - - - - - - - - - - - -")
  readr::write_rds(
    x = geometry_data,
    file = output_file_path)
  
}
