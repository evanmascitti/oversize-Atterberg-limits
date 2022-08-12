# compute the expected transitional fines content using an Se value of 0.9 and 
# the observed water content at the plastic limit 

library(purrr)
library(soiltestr)

# set up variables used later on
# for now hard-code the Gs of the Casselman clay as 2.78 and the sand Gs as 2.67.
# I have measured this in the past but need to either 
# find those data or re-do the test so I can use here 

# Gs values for both components
casselman_Gs <- 2.78
sand_Gs <- 2.67

# tests were performed at ~ 22 deg C in the lab so 
# use this to compute water density at this temp
water_Gs <- unlist(h2o_properties_w_temp_c[dplyr::near(h2o_properties_w_temp_c$water_temp_c, 22), 'water_density_Mg_m3'])

# set effective saturation to 90%, similar to what's observed in Proctor tests

effective_saturation <- 0.9


# Now do the  calculations 

# First find the sand contents at which the samples 
# could no longer be rolled out, i.e. do not 
# have a measurable plastic limit

max_rollable_samples_dfs <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds"
) %>% 
  split(~sand_name) %>% 
  map(~dplyr::filter(., !is.na(water_content), test_type == "PL")) %>% 
  map(dplyr::arrange, sand_pct) %>% 
  map(dplyr::select, sand_name, sand_pct, water_content)
  


PL_tfcs_df <- max_rollable_samples_dfs %>%
  map(~dplyr::filter(., dplyr::near(max(sand_pct, na.rm = T), sand_pct))) %>% 
  dplyr::bind_rows()


# unpack the individual cells into single variables 
# for the water content and the sand % at each max sand content 
high_Cu_PL <- unlist(PL_tfcs_df[PL_tfcs_df$sand_name == 'high_Cu_Quickcrete', 'water_content'])
high_Cu_max_rollable_sand_pct <- unlist(PL_tfcs_df[PL_tfcs_df$sand_name == 'high_Cu_Quickcrete', 'sand_pct'])


low_Cu_PL <- unlist(PL_tfcs_df[PL_tfcs_df$sand_name == 'low_Cu_Quickcrete', 'water_content'])
low_Cu_max_rollable_sand_pct <-  unlist(PL_tfcs_df[PL_tfcs_df$sand_name == 'low_Cu_Quickcrete', 'sand_pct'])

# find void ratios for each sand 

sand_void_ratios <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-sand-physical-properties-cleaned-data.rds"
)

high_Cu_e_sa <- unlist(sand_void_ratios[sand_void_ratios$sand_name == 'high_Cu_Quickcrete'  & sand_void_ratios$sand_configuration == 'loose', 'void_ratio'])


low_Cu_e_sa <- unlist(sand_void_ratios[sand_void_ratios$sand_name == 'low_Cu_Quickcrete'  & sand_void_ratios$sand_configuration == 'loose', 'void_ratio'])


# write function to do this analysis correctly without copy-paste as it is a gory formula with lots of parentheses 

compute_tfc <- function(w, Gsa, Gc, Gw, Se, e_sa){
  
  
  numerator <-  1 + ( ( ( (w * Gc) / Gw)  ) / Se )
  
  denominator <-  1 + ( (e_sa * Gc) / Gsa)
  
  m_sa <-numerator / denominator
  
  return(m_sa)
  
}

# compute tfc for both sands using the PL as the water content

PL_high_Cu_tfc <- unname(compute_tfc(w = high_Cu_PL,Gc = casselman_Gs, Gsa = sand_Gs, Gw = water_Gs, Se = effective_saturation, e_sa = high_Cu_e_sa))

PL_low_Cu_tfc <- unname(compute_tfc(w = high_Cu_PL, Gc = casselman_Gs, Gsa = sand_Gs, Gw = water_Gs, Se = effective_saturation, e_sa = low_Cu_e_sa))



# now do the same for the LL 
# this finds the max sand content at which the sample flowed rather than slid in the Casagrande cup. 

max_LL_testable_samples_dfs <- readr::read_rds(
  file = "./ecmdata/derived-data/cleaned-rds-files/uniformity-experiment-atterberg-limits-cleaned-data.rds"
) %>% 
  split(~sand_name) %>% 
  map(~dplyr::filter(., !is.na(water_content), test_type == "LL")) %>% 
  map(dplyr::arrange, sand_pct) %>% 
  map(dplyr::select, sand_name, sand_pct, water_content)

LL_tfcs_df <- max_LL_testable_samples_dfs %>%
  map(~dplyr::filter(., dplyr::near(max(sand_pct, na.rm = T), sand_pct))) %>% 
  dplyr::bind_rows()

# write the LL tfcs data frame to disk just like I did above 


# unpack the individual cells into single variables 
# for the water content and the sand % at each max sand content 
high_Cu_LL <- unlist(LL_tfcs_df[LL_tfcs_df$sand_name == 'high_Cu_Quickcrete', 'water_content'])
high_Cu_max_LL_testable_sand_pct <- unlist(LL_tfcs_df[LL_tfcs_df$sand_name == 'high_Cu_Quickcrete', 'sand_pct'])


high_Cu_PL <- unlist(LL_tfcs_df[LL_tfcs_df$sand_name == 'low_Cu_Quickcrete', 'water_content'])
low_Cu_max_LL_testable_sand_pct <-  unlist(LL_tfcs_df[LL_tfcs_df$sand_name == 'low_Cu_Quickcrete', 'sand_pct'])


# compute for both sands using the LL as the water content and the
# same void ratios as were used for the PL (i.e. maximum void ratio/minimum density)
LL_high_Cu_tfc <- unname(compute_tfc(w = high_Cu_PL,Gc = casselman_Gs, Gsa = sand_Gs, Gw = water_Gs, Se = 0.95, e_sa = high_Cu_e_sa))

LL_low_Cu_tfc <- unname(compute_tfc(w = high_Cu_PL, Gc = casselman_Gs, Gsa = sand_Gs, Gw = water_Gs, Se = 0.98, e_sa = low_Cu_e_sa))




# write stuff to disk 

# this is the real thing with Make

if(!interactive()){

  output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  
  output_list <- mget(x = c("PL_low_Cu_tfc", "PL_high_Cu_tfc", "LL_low_Cu_tfc", "LL_high_Cu_tfc"))
  
  readr::write_rds(
  x = output_list,
  file = output_file_path
)
}else{
  message(crayon::black("High Cu TFC for PL = ", PL_high_Cu_tfc, "\n"))
  message(crayon::black("Low Cu TFC = for PL =", PL_low_Cu_tfc))
  message(crayon::black("High Cu TFC for LL = ", LL_high_Cu_tfc, "\n"))
  message(crayon::black("Low Cu TFC for LL = ", LL_low_Cu_tfc))
}


# save the maximumtestable sand contents as their own dynamic reference. 
# Technically this violates my rule with Make, but it is not worth further splitting 
# this script when the values are already computed here. 

readr::write_rds(
  x = list(
    high_Cu_max_rollable_sand_pct = high_Cu_max_rollable_sand_pct,
    low_Cu_max_rollable_sand_pct = low_Cu_max_rollable_sand_pct,
    high_Cu_max_LL_testable_sand_pct = high_Cu_max_LL_testable_sand_pct,
    low_Cu_max_LL_testable_sand_pct = low_Cu_max_LL_testable_sand_pct),
  file = "./ecmdata/derived-data/dynamic-number-references/uniformity-experiment-max-testable-sand-contents.rds")

