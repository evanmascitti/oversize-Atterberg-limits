# this script installs renv, which is an R package for archiving code. 
# running this script will then install all software required to 
# compile the results of this project. 


Rscript --no-save --no-restore --no-site-file --verbose -e 'if(!requireNamespace("renv", quietly = T)){install.packages("renv")}'
Rscript --no-save --no-restore --no-site-file --verbose -e 'renv::restore()'


