# compute amount of water per gram of soil based on the particle geometry 
# and water layer thickness 

library(purrr)
library(ggplot2)
theme_set(ecmfuns::theme_ecm_bw())

n_water_layers <-  20
water_shell_thickness_cm <- (0.3 * (10 ^ -9)) * n_water_layers # 0.3 nanometers for one molecule, converted to cm and assuming n layers of water moluecules thick
water_density <- 1


water_films_data <- tibble::tibble(
  particle_diameter_mm = seq(0.1, 2, 0.01),
  particle_radius_mm = particle_diameter_mm / 2,
  particle_radius_cm = 0.1 * particle_radius_mm,
  particle_vol_cm3 = (4 / 3) * pi * (particle_radius_cm ^ 3),
  particle_surf_area_cm2 = 4 * pi * (particle_radius_cm ^ 2),
  Gs = 2.65,
  particle_mass = Gs * particle_vol_cm3,
  n_particles_per_g = 1 / particle_mass,
  surf_area_per_g = particle_surf_area_cm2 * n_particles_per_g
) %>%
  dplyr::mutate(
    encapsulating_water_shell_volume_cm3 = (4/3) * pi * ((particle_radius_cm + water_shell_thickness_cm)^3),
    water_shell_only_volume_cm3 = encapsulating_water_shell_volume_cm3 - particle_vol_cm3,
    water_shell_volume_per_g_solids = water_shell_only_volume_cm3 * n_particles_per_g,
    water_shell_mass_per_g_solids = water_shell_volume_per_g_solids * water_density
    # h2o_shell_vol_per_g = surf_area_per_g * h2o_film_thickness,
    # h2o_shell_vol_diff = h2o_shell_vol_per_g - dplyr::lag(h2o_shell_vol_per_g)
  ) %>% 
  dplyr::select(
    particle_diameter_mm, water_shell_mass_per_g_solids
  ) 

# water_films_data %>%
#   ggplot(aes(particle_diameter_mm, water_shell_mass_per_g_solids))+
#   geom_line(size = 0.25)+
#   scale_x_continuous(
#     "Particle diameter, mm",
#     trans = 'log10',
#     breaks = c(2, 1, 0.5, 0.25, 0.15))+# surf_areas$particle_diameter_mm)
#   scale_y_continuous(
#     expression("Water mass per gram solids, g g"^1),
#     n.breaks =10)


water_mass_per_g_model <- lm(
  data = water_films_data,
  formula = water_shell_mass_per_g_solids ~ log10(particle_diameter_mm)
)

predict_water_mass_per_g <- function(d){
water_mass <- unname(predict(object = water_mass_per_g_model, newdata = data.frame(particle_diameter_mm = d)))

# message(crayon::blue("---------------------------------\nWater mass per gram of soil solids:", round(water_mass, 4), "\n---------------------------------"))
message(crayon::blue("Water mass per gram of soil solids:"))

return(water_mass)
}

#predict_water_mass_per_g(d = 1.4)
