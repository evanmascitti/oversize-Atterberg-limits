suppressPackageStartupMessages({
  library(purrr)
  library(magick)
})

output_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
cat("Building figure:", output_file_path, "---------------------", 
    sep = "\n\n")

imgs <- list.files(path = "./photos-videos-screenshots/adhesion-limit/",
                   full.names = T) %>% 
  image_read() %>% 
  image_scale(geometry = geometry_size_pixels(width = "2000")) %>% 
  image_annotate(text = paste0(c("A", "B"), "."),
                 color = "white",
                 location = "+75+25",
                 size = 250,
                 strokecolor = 'black') %>% 
  image_border(geometry = "10x10", color = 'white') %>% 
  image_append(stack = F)

# check appearance 
# imgs %>%
#  image_scale("400")

image_write(image = imgs, 
            format = "png",
            path = output_file_path)

