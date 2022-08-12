# this is to make a point about the number of particles per gram 

library(magrittr)

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]



# filter out the silt-bearing coarse addition, then
# compute the number of particles per unit mass 
# for each size fraction. 
particle_numbers_tbl <- readr::read_rds('ecmdata/raw-data/experiment-1-coarse-particles-d50.rds') %>% 
  dplyr::filter(expt_sand_number < 6) %>% 
  dplyr::mutate(
    d50 = round(d50, 2),
    radius_cm = (d50/10) / 2,
    single_particle_mass = 2.65 * (4/3) * pi * (radius_cm^3),
    particles_per_gram = 1 / single_particle_mass
  )

coarsest_sand_d_50_mm <- max(particle_numbers_tbl$d50)
finest_sand_d_50_mm <- min(particle_numbers_tbl$d50)
coarsest_sand_n_particles_per_gram <- min(particle_numbers_tbl$particles_per_gram)
finest_sand_n_particles_per_gram <- max(particle_numbers_tbl$particles_per_gram)

# scoop up the single values into a list 

formatted_values <- mget(
  ls(pattern = 'n_particles_per_gram|d_50_mm'),
  envir = rlang::current_env()
) %>% purrr::map_dbl(
  signif,
  digits =2
  ) %>% 
  tibble::enframe() %>% 
  dplyr::mutate(
    value = dplyr::if_else(
      value > 100,
      signif(value, 3),
      value
    )) 


output_list <- formatted_values$value %>% 
  as.list() %>% 
  purrr::set_names(nm = formatted_values$name)


readr::write_rds(
  x = output_list,
  file = output_file_path
)
