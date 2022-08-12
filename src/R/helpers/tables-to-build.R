library(magrittr, quietly = T)
cat(
	gsub('-tab.R', '.rds', list.files(path = 'src/R/tab-generation/', pattern = "tab.R$")) %>% 
	paste0('tables/', .),
	sep = "\n"
)
	

		 
