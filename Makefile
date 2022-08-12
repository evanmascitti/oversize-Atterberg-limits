include mf-vars.mk

.PHONY: all 
all: presentations  paper 
#submission

# .PHONY: presentations paper
presentations: $(HTML_PRESENTATIONS) 
paper: $(PAPER_PDF_FILES) $(PAPER_DOCX_FILES) $(WORD_EQUATION_DOCXS) figures 
figures: $(ALL_FIGURES)
# this is to compile everything needed to  submit the manuscript
#submission.zip: paper 
	
# ------------------------  Paper rules  -----------------------------

# pattern rule to render all manuscript-related documents as .pdf files
./paper/%.pdf: ./paper/%.Rmd $(PAPER_DEPENDENCIES)
	@echo -e updated paper dependencies are $?
	$(R_SCRIPT) -e "rmarkdown::render(input = '$<', output_format = 'bookdown::pdf_document2')"

# and as word 

./paper/%.docx: ./paper/%.Rmd $(PAPER_DEPENDENCIES)
	@echo -e updated paper dependencies are $?
	$(R_SCRIPT) -e "rmarkdown::render(input = '$<', output_format = 'officedown::rdocx_document')"


# equations to copy-paste into word docs to distribute to committee 

./paper/equation-rendering-for-word/%.docx: ./paper/equation-rendering-for-word/%.Rmd
	$(R_SCRIPT) -e "rmarkdown::render(input = '$<')"

# to manually render a document with the date in the file name, 
# run the following command in the R console 
#rmarkdown::render("paper/oversizeAttLims-paper.Rmd",
 #                 output_file = paste0(paste0"oversize-Attlims-paper_2021-08-11",
  #                output_format = "all")


# ----------------------  Presentation rules  ------------------------

# pattern rule to render HTML presentations
./presentations/%.html: ./presentations/%.Rmd $(PRESENTATION_DEPENDENCIES)
	@echo -e updated presentation dependencies are $?
	$(R_SCRIPT) -e "rmarkdown::render('$<')"

# -----------------------  Figure rules  -----------------------------

# pattern rule to build pdf figures (other formats are automatically built
# by calling ecmfuns::export_plot() )

./figs/pdf/%.pdf: ./src/R/fig-generation/%-fig.R 
	$(R_SCRIPT) $< $@ #added the $@ on 2022-04-05; earlier figures saved via 
	# manual call to ggsave
	./src/bash/rm-Rplots-pdf.sh

# explicitly declare the data dependencies for each figure 

# experiment 1
$(PDF_FIGS_DIR)/experiment-1-particle-size-curves.pdf: $(CLEANED_RDS_DIR)/experiment-1-particle-size-curves-cleaned-data.rds $(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-1-dx-values.rds 
$(PDF_FIGS_DIR)/experiment-1-atterberg-limit-facets.pdf: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds
$(PDF_FIGS_DIR)/experiment-1-d50-effect-size.pdf: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds
$(PDF_FIGS_DIR)/experiment-1-atterberg-limits-vs-d50-facets.pdf: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds
$(PDF_FIGS_DIR)/experiment-1-d50-slopes-vs-sand-percent.pdf: $(FITTED_MODELS_DIR)/experiment-1-atterberg-limits-vs-d50-by-coarse-percent-model.rds
$(PDF_FIGS_DIR)/experiment-1-matrix-water-content-at-LL-and-PL.pdf: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds

# experiment 2
$(PDF_FIGS_DIR)/experiment-2-atterberg-limit-facets.pdf: $(CLEANED_RDS_DIR)/experiment-2-atterberg-limits-cleaned-data.rds

# experiment 3
$(PDF_FIGS_DIR)/experiment-3-atterberg-limit-facets.pdf: $(CLEANED_RDS_DIR)/experiment-3-atterberg-limits-cleaned-data.rds
$(PDF_FIGS_DIR)/experiment-3-particle-size-curves.pdf: $(EXPERIMENT_3_PSA_FILES) $(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-3-dx-values.rds 

# explicit rules for building image or PNG-only figures, which don't end up as pdfs

./figs/png/image-figs/sand-photo-micrographs.png: $(R_FIGS_DIR)/sand-photo-micrographs-fig-PNG-ONLY.R  $(wildcard ./photos-videos-screenshots/sand-photo-micrographs/*.png)
	$(R_SCRIPT) $< $@

./figs/png/image-figs/adhesion-limit-method.png: $(R_FIGS_DIR)/adhesion-limit-method-fig-PNG-ONLY.R  $(wildcard ./photos-videos-screenshots/adhesion-limit/*)
	$(R_SCRIPT) $< $@


# ------------------- Dynamic number references -----------------
# these are values I want to reference in R Markdown without
# re-computing them every time I compile the document. Instead I
# do the calculations in separate R scripts and save them as .rds
# files in the derived data directory

$(DYNAMIC_NUMBER_REFERENCES_DIR)/%.rds: $(DYNAMIC_NUMBER_REFERENCES_GENERATING_DIR)/%.R
	$(R_SCRIPT) $< $@

# additional data dependencies for each dynamic reference .rds file
$(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-3-dx-values.rds: $(wildcard ./ecmdata/raw-data/experiment-3/psa-data_2020-06-21/*.csv) # taking this one out because it is triggering a re-build every time... just copy the code which makes the plot for visual estimations. $(RDS_FIGS_DIR)/experiment-3-particle-size-curves.rds

$(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-1-dx-values.rds: ./ecmdata/metadata/experiment-1-expt_sand_numbers-metadata.csv ./ecmdata/raw-data/experiments-1-and-2/experiment-1-sand-size-graphically-determined-D50-values.csv ./ecmdata/raw-data/experiments-1-and-2/experiment-1-silt-size-graphically-determined-D50-values.csv


$(DYNAMIC_NUMBER_REFERENCES_DIR)/particles-per-gram.rds: ./ecmdata/raw-data/experiment-1-coarse-particles-d50.rds

$(DYNAMIC_NUMBER_REFERENCES_DIR)/largest-experiment-2-difference.rds: ./ecmdata/derived-data/cleaned-rds-files/experiment-2-atterberg-limits-cleaned-data.rds

$(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-3-pure-clay-atterberg-limit-values.rds: ./ecmdata/derived-data/cleaned-rds-files/experiment-3-atterberg-limits-cleaned-data.rds

$(DYNAMIC_NUMBER_REFERENCES_DIR)/experiment-3-TFC-calculations-from-void-ratio.rds: $(CLEANED_RDS_DIR)/experiment-3-sand-physical-properties-cleaned-data.rds

# -------------------------  Model fitting  ------------------------

# pattern rule to build each model file
$(FITTED_MODELS_DIR)/%-model.rds: $(R_MODEL_FITTING_DIR)/%-model-fitting.R
	$(R_SCRIPT) $< $@

# specific data dependencies
$(FITTED_MODELS_DIR)/experiment-1-d50-effect-size-model.rds: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds
$(FITTED_MODELS_DIR)/experiment-1-atterberg-limits-vs-d50-by-coarse-percent-model.rds: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds


$(FITTED_MODELS_DIR)/experiment-2-anova-model.rds: $(CLEANED_RDS_DIR)/experiment-2-atterberg-limits-cleaned-data.rds

$(FITTED_MODELS_DIR)/experiment-3-anova-model.rds: $(CLEANED_RDS_DIR)/experiment-3-atterberg-limits-cleaned-data.rds





# -------------------------- Data cleaning  ------------------------

# pattern rule to build cleaned rds files

$(CLEANED_RDS_DIR)/%-cleaned-data.rds: $(R_DATA_CLEANING_DIR)/%-cleaning.R
	$(R_SCRIPT) $< $@

# must separately declare raw data dependencies for each individual cleaned rds file:

$(CLEANED_RDS_DIR)/both-experiments-1-and-2-atterberg-limits-cleaned-data.rds: $(shell find ./ecmdata/raw-data/experiments-1-and-2 -name "*.csv" -type f )

$(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds: $(CLEANED_RDS_DIR)/both-experiments-1-and-2-atterberg-limits-cleaned-data.rds

$(CLEANED_RDS_DIR)/experiment-1-estimated-toughness-values-cleaned-data.rds: $(CLEANED_RDS_DIR)/experiment-1-atterberg-limits-cleaned-data.rds

$(CLEANED_RDS_DIR)/experiment-2-atterberg-limits-cleaned-data.rds: $(CLEANED_RDS_DIR)/both-experiments-1-and-2-atterberg-limits-cleaned-data.rds

$(CLEANED_RDS_DIR)/experiment-3-atterberg-limits-cleaned-data.rds: $(shell find ./ecmdata/raw-data/experiment-3 -name "*.csv" -type f )

$(CLEANED_RDS_DIR)/experiment-1-specific-surface-area-cleaned-data.rds: ./ecmdata/metadata/experiment-1-expt_sand_numbers-metadata.csv $(CLEANED_RDS_DIR)/experiment-1-particle-size-curves-cleaned-data.rds 

$(CLEANED_RDS_DIR)/experiments-1-and-2-coarse-additions-bulk-density-and-porosity-cleaned-data.rds: $(EXPERIMENTS_1_and_2_F1815_CSVS)

$(CLEANED_RDS_DIR)/experiment-3-sand-physical-properties-cleaned-data.rds: $(EXPERIMENT_3_F1815_CSVS)


# -----------------  Variable checking/debugging ---------------------

#.PHONY: vars_check
vars_check:
	@echo -e \\n experiment 1 and 2 F1815 .csv files are $(EXPERIMENTS_1_and_2_F1815_CSVS)
	# @echo -e \\n paper dependencies are $(PAPER_DEPENDENCIES) \\n ----------------
	#	@echo -e presentation dependencies are $(CSS_FILES) and $(HTML_PRESENTATIONS)
	# @echo -e files to build tables $(TABLE_BUILDING_FILES)
#	@echo -e clean rds files to build are $(FUTURE_CLEANED_RDS_FILES)
	# @echo -e presentations are $(HTML_PRESENTATIONS)
	# @echo -e PDF figures are $(PDF_FIGS)
	# @echo -e PNG image figures are $(IMAGE_FIGS)
	# @echo -e other PNG-only figures are $(PNG_ONLY_FIGS)
	# @echo -e paper-related files to produce are  $(patsubst %.Rmd,%.pdf,$(wildcard ./paper/*.Rmd) )
#	@echo -e \\n paper pdf files to build are $(PAPER_PDF_FILES)
#	@echo -e \\n presentation dependencies are $(PRESENTATION_DEPENDENCIES) \\n ----------------
#	@echo -e \\n experiment 3 psa data dependencies are $(EXPERIMENT_3_PSA_FILES)
#	@echo -e \\n dynamic number reference files are $(DYNAMIC_NUMBER_REFERENCES)
	#@echo -e fitted models dir is $(FITTED_MODELS_DIR)
	#@echo -e fitted model files are $(FITTED_MODEL_FILES)





