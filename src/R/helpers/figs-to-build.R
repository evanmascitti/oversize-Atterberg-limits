library(magrittr, quietly = T)
cat(
	gsub('-fig.R', '.pdf', list.files(path = 'src/R/fig-generation/', pattern = "-fig.R")) %>% 
	paste0('figs/pdf/', .),
	sep = "\n"
)
	

		 
