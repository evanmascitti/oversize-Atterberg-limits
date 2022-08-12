# Borrowed this preamble from https://tech.davis-hansson.com/p/make/
# some very sensible defaults. For now I will keep the
# tabs, but I like the concept of the angle bracket instead
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ifeq ($(origin .RECIPEPREFIX), undefined)
#  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
# endif
# .RECIPEPREFIX = >

# redefine the Rscript command to include the options I want
R_SCRIPT = Rscript --no-save --no-restore --no-site-file --verbose


#----------------------------------------------------------------
# Variables for main metatargets

# use substitution to generate the figures that _should_
# exist based on the stems of R scripts that generate them
# this is the best way because it trickles down
# to the cleaned data files through the dependency tree,
# and because though I might want to clean out all the intermediate
# data files, I will _never_ delete a code file

# use an R script to build the file names....much easier than
# using Make's text functions. Tried to silence this many
# ways but without success


PDF_FIGS_DIR = ./figs/pdf
#PDF_FIGS = $(shell Rscript --no-save --no-restore --no-site-file src/R/helpers/figs-to-build.R)
PDF_FIGS = $(shell $(R_SCRIPT) src/R/helpers/figs-to-build.R)


PNG_ONLY_FIGS = # empty for now
#./figs/png/image-figs/sand-photo-micrographs.png#./figs/png/image-figs/adhesion-limit-method.png


IMAGE_FIGS = ./figs/png/image-figs/sand-photo-micrographs.png ./figs/png/image-figs/adhesion-limit-method.png


ILLUSTRATIONS = ./illustrations/tfc-by-sand-uniformity/uniformity-effect-on-transitional-fines-content.pdf

# still don't get how define works as this break
# the makefile. I guess it can only be used for commands and not for text strings.
#define IMAGE_FIGS
#./figs/png/image-figs/sand-photo-micrographs.png
#./figs/png/image-figs/adhesion-limit-method.png
#endef


RDS_FIGS_DIR = ./figs/rds
ALL_FIGURES = $(PDF_FIGS) $(PNG_ONLY_FIGS) $(IMAGE_FIGS) $(ILLUSTRATIONS)
#--------- all files needed for the manuscript ------------

PAPER_PDF_FILES = $(patsubst %.Rmd,%.pdf,$(wildcard ./paper/*.Rmd) )
PAPER_DOCX_FILES = $(patsubst %.Rmd,%.docx,$(wildcard ./paper/*.Rmd) )
WORD_EQUATION_DOCXS = $(patsubst %.Rmd,%.docx,$(wildcard ./paper/equation-rendering-for-word/*.Rmd) )

PAPER_DEPENDENCIES = $(FUTURE_CLEANED_RDS_FILES) $(TABLE_BUILDING_FILES) $(ALL_FIGURES) $(DYNAMIC_NUMBER_REFERENCES) $(FITTED_MODEL_FILES) $(wildcard ./paper/*.bib) $(wildcard ./paper/*.csl) ./paper/preamble.tex 


# table variables

# create a list of dependency files that are used
# when sourcing R scripts inside the .Rmd....this is kind of
# opaque, but kableExtra won't work with bookdown for cross-references. This will allow me to keep each table in an external script
# but also ensure the Rmd is always using the most updated version.

TABLE_BUILDING_FILES = $(wildcard $(R_TABLES_DIR)/*.R)




# ------------ presentation dependencies -------------------

# create a list of dependency files that will be used for ALL
# presentations....then each presentation can be rendereed with a
# pattern rule that also includes these dependencies

# first some intermediate variables 
RMD_PRESENTATION_FILES = $(wildcard presentations/*.Rmd)
HTML_PRESENTATIONS = $(RMD_PRESENTATION_FILES:Rmd=html)
CSS_FILES = $(wildcard ./presentations/*.css)

# and now the whole list 

PRESENTATION_DEPENDENCIES = $(CSS_FILES) $(TABLE_BUILDING_FILES) $(FUTURE_CLEANED_RDS_FILES) $(ALL_FIGURES) $(DYNAMIC_NUMBER_REFERENCES) $(FITTED_MODEL_FILES)


# -------------------------- cleaned rds files ---------------------

FUTURE_CLEANED_RDS_FILES = $(addprefix $(CLEANED_RDS_DIR)/, $(patsubst %-cleaning.R,%-cleaned-data.rds,$(notdir $(wildcard $(R_DATA_CLEANING_DIR)/*-cleaning.R) ) ) )

# variables related to model-fitting

FITTED_MODELS_DIR = ./ecmdata/derived-data/models
R_MODEL_FITTING_DIR = ./src/R/model-fitting
FITTED_MODEL_FILES =  $(patsubst %-model-fitting.R,%-model.rds, $(addprefix $(FITTED_MODELS_DIR)/,$(notdir $(wildcard $(R_MODEL_FITTING_DIR)/*.R ) ) ) )

# ------------  other misc variables for data dependencies --------

UNIFORMITY_EXPERIMENT_PSA_FILES = $(wildcard ./ecmdata/raw-data/uniformity-experiment/psa-data_2020-06-21/*.csv) $(wildcard ./ecmdata/raw-data/uniformity-experiment/psa-data_2021-03-06/*.csv) 

EXPERIMENTS_1_and_2_F1815_CSVS = $(shell find ./ecmdata/raw-data/experiments-1-and-2/F1815-cylinders-data -name "*.csv" -type f)

UNIFORMITY_EXPERIMENT_F1815_CSVS = $(shell find ./ecmdata/raw-data/uniformity-experiment/F1815-cylinders-data -name "*.csv" -type f)


# -----------------------------------------------------------------------



DYNAMIC_NUMBER_REFERENCES_GENERATING_DIR = ./src/R/dynamic-number-building
DYNAMIC_NUMBER_REFERENCES_DIR = ./ecmdata/derived-data/dynamic-number-references
DYNAMIC_NUMBER_REFERENCES = $(patsubst %.R,%.rds, $(addprefix $(DYNAMIC_NUMBER_REFERENCES_DIR)/,$(notdir $(wildcard $(DYNAMIC_NUMBER_REFERENCES_GENERATING_DIR)/*.R ) ) ) )


#------------------------------------------------------------------
#   Define directories to look in for particular kinds of scripts

R_DATA_CLEANING_DIR = ./src/R/data-cleaning
R_DATA_GENERATION_DIR = ./src/R/data-generation

R_FIGS_DIR = ./src/R/fig-generation
R_TABLES_DIR = ./src/R/table-generation


#------------------------------------------------------------------
#   Define directories to look in for particular kinds of files

CLEANED_RDS_DIR = ./ecmdata/derived-data/cleaned-rds-files
RAW_DATA_DIR = ./ecmdata/raw-data

# ------------------------------------------------------------------

# Variables to find all csv-based raw data files associated with
# a given part of the project

# none established yet

