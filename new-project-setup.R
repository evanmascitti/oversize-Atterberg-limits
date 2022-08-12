# create directories

lapply(c("paper",
         "presentations",
         "archive",
         "ecmdata",
         "ecmdata/derived-data",
         "ecmdata/derived-data/cleaned-rds-files",
         "ecmdata/raw-data",
         "photos-videos-screenshots",
		 "figs",
		 paste0(
		 "figs/", 
		 c("pdf", 
		 "png", 
		 "svg", 
		 "rds")
		 ),
         "tables",
         "src",
         "src/R",
         paste0(
           "src/R/",
           c(
             "data-generation",
             "data-cleaning",
             "fig-generation",
             "table-generation"
           )
         ),
         "misc-workflow", "debugging"),
       dir.create)

# create files 

# write Makefile
writeLines(
  text = 'include mf-vars.mk',
  con = 'Makefile'
)

# write extra file to store makefile variables and other commands
writeLines(
text = c(
  "# Borrowed this preamble from https://tech.davis-hansson.com/p/make/  ",
  "SHELL := bash ",
  ".ONESHELL:",
  ".SHELLFLAGS := -eu -o pipefail -c",
  ".DELETE_ON_ERROR"),
con = 'mf-vars.mk'
)

# write script to build dependency graph for Make
writeLines(text = "#!/bin/bash \n\n make -Bnd | make2graph | dot -Tpdf -o makefile-graph.pdf  ; make -Bnd | make2graph | dot -Tsvg -o makefile-graph.svg",
           con = "update-makefile-graph.sh")


# populate YAML for experiment notes file 

writeLines(con = "misc-workflow/experiment-notes.Rmd",
           text = c('---',
                    paste0('title: ',
                           '\"Experiment notes for ',
                           commandArgs(trailingOnly = F)[[1]],
                           'experiment\"'),
                    paste0('date: "begun ',
                           Sys.Date(),
                           '; last updated `r Sys.Date()` \"'
                    ),
                    'output: html_document',
                    '---'
           )
)



# be sure to call the following lines inside RStudio to create a project
# build R project infrastructure

# usethis::create_package(path = ".")
# usethis::proj_set(basename(here::here()))
# usethis::use_readme_rmd()
# usethis::use_mit_license("Evan C. Mascitti")
# usethis::use_git()
# usethis::use_github(private = TRUE)
