new_manuscript_version <- function(rmd_file){
  
  # for word 
  rmarkdown::render(
    input = rmd_file,
    output_file = here::here(
     "paper", "dated-drafts", paste0("oversizeAttLims-paper-part-1_", Sys.Date(), ".docx")),
    output_format = "officedown::rdocx_document")
  
  # for pdf 
  rmarkdown::render(
    input = rmd_file,
    output_file = here::here(
      "paper", "dated-drafts", paste0("oversizeAttLims-paper-part-1_", Sys.Date(), ".pdf")),
    output_format = "bookdown::pdf_document2")
  
}

# run function to update pdf and word versions 
new_manuscript_version(rmd_file = 'paper/oversizeAttLims-paper-part-1.Rmd')
